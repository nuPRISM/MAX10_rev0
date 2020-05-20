/****************************************************************************
 * Copyright © 2006 Altera Corporation, San Jose, California, USA.           *
 * All rights reserved. All use of this software and documentation is        *
 * subject to the License Agreement located at the end of this file below.   *
 ****************************************************************************/
/*****************************************************************************
*  File: external_boot.c
*
*  Purpose: This is an example of some code that could run on an external
*  processor to control the booting of a Nios II processor.  Using a 
*  PIO and the cpu_resetrequest signal, this routine holds the main Nios II 
*  processor in reset while it copies an application from a boot record 
*  in flash to RAM.  It then calls ReleaseMainCPU(), which calculates the 
*  entry point of the application, constructs a Nios II instruction which 
*  branches to that entry point, then writes the instruction to the Nios II 
*  reset address and releases the Nios II from reset.
*
*  This example code is of course predicated on the fact that the main Nios II
*  CPU's reset address is set to some volatile memory (RAM).  Otherwise, we 
*  cant write an instruction to the reset address.
*  
*****************************************************************************/
#include <unistd.h>
#include <string.h>
#include <sys/alt_log_printf.h>
#include <altera_avalon_pio_regs.h>
#include <sys/alt_stdio.h>
#include "bootloader.h"
#include <system.h>
#include <alt_types.h>
#include <io.h>
#include <sys/alt_alarm.h>
#include <sys/alt_cache.h>
#include <sys/alt_dev.h>
#include <sys/alt_irq.h>
#include <sys/alt_sys_init.h>
#include "altera_avalon_jtag_uart_regs.h"
#include "altera_avalon_jtag_uart.h"
#include "xprintf.h"
#include "system.h"
#include "basedef.h"
#include "bootloader_config.h"
#include "top_level_control.h"
#if BOOTLOADER_USE_MY_JTAG_WRITE
#include "my_jtag_write.h"
#endif
#include "priv/alt_file.h"
#include "sys/ioctl.h"
#include "c_pio_encapsulator.h"
#include "get_main_processor_reset_address.h"
#include "get_dut_processor_reset_address.h"

#if BOOTLOADER_WAIT_FOR_DDR_TO_SUCCESSFULLY_CALIBRATE_BEFORE_CONTINUING
//#include "emif_debug_api.h"
#endif

#if BOOTLOADER_TEST_MEMORY_BEFORE_LOADING_FLASH
#include "mem_test_func.h"
int TestRam(alt_u32 memory_base, alt_u32 memory_end);
#endif


#ifndef GET_MIN_VAL
#define GET_MIN_VAL(x,y) ((x > y) ? (y) : (x))
#endif

#ifndef GET_MAX_VAL
#define GET_MAX_VAL(x,y) ((x > y) ? (x) : (y))
#endif

#define infinite_loop_with_message(args...) do { \
		        my_printf(args); \
				usleep(1000000); \
	          } while (1)

int jumped_to_command_server_because_bootloader_disabled = 0;

#if COMMAND_SERVER_ENABLE_PETIT_FILE_SYSTEM
#include "pff.h"
#include "petit_fatfs_macro_definitions.h"
FATFS bootloader_fatfs;			/* File system object */

alt_u32 LoadSWImageFromFile ( char* filename, int* success );

static void put_rc (FRESULT rc)
{
	const char *p;
	static const char str[] =
		"OK\0DISK_ERR\0NOT_READY\0NO_FILE\0NOT_OPENED\0NOT_ENABLED\0NO_FILE_SYSTEM\0";
	FRESULT i;

	for (p = str, i = 0; i != rc && *p; i++) {
		while(*p++);
	}
	xprintf("%src=%u FR_%s\n", COMMENT_STR, (UINT)rc, p);
}


#endif

alt_u32 LoadFlashImage ( alt_u8 *flash_image_ptr_1,  int* success );
void make_reset_addr_branch_to_itself(bootloader_index_of_processors_t the_processor);
void ReleaseMainCPU(void entry_point(void));

#define JTAGPRINT(name) do { if (!jtag_has_been_disconnected) { MyJtagWrite(name, strlen(name)); } } while (0)
pio_encapsulator_struct      bootloader_reset_control_pio;
pio_encapsulator_struct      bootloader_gpio_out_pio;
pio_encapsulator_struct      bootloader_enable_and_params_pio;
pio_encapsulator_struct      bootloader_reset_and_bootloader_request_pio;
bootloader_boot_source_type  bootloader_nios_sw_source;
pio_encapsulator_struct* bootloader_internal_pio_list_head;

// Stores the transmit state of the JTAG_UART
volatile alt_u32 jtag_uart_state;

#define debug_do(x) do { if (DEBUG_BOOTLOADER) { x; }; } while (0)

/*
 * Globally accessable variable.
 */


int jtag_has_been_disconnected = 0;
int did_hard_reset = 0;
alt_alarm jtag_check_alarm;
extern int get_card_revision();
#if !BOOTLOADER_USER_EXTERNAL_COMMAND_GET_FUNCTION
#define command_server_get_command(buf,len) xgets(buf,len)
#endif

#if !BOOTLOADER_USER_EXTERNAL_COMMAND_POST_PROCESSING_FUNCTION
 static void commmand_server_post_process_command_response(char* command_response_str,int command_was_successful) {
		if (command_response_str[0] != '\0') { xprintf("%s\n",command_response_str);}
						if (command_was_successful) {
						     xprintf("OK\n");
						} else {
							 xprintf("ERR\n");
						}
 }
#endif

#if BOOTLOADER_DO_EXTERNAL_DO_SOMETHING_RIGHT_AT_THE_VERY_BEGINNING
	extern void bootloader_external_do_something_at_the_very_beginning();
#endif

#if BOOTLOADER_DO_EXTERNAL_PRE_BOOT_INITIALIZATION
	extern void bootloader_external_pre_boot_initialization();
#endif

#if BOOTLOADER_DO_EXTERNAL_POST_BOOT_CLEANUP
	extern void bootloader_external_post_boot_cleanup();
#endif

#if BOOTLOADER_DO_EXTERNAL_PRE_NIOS_SW_LOAD_INITIALIZATION
	extern void bootloader_external_pre_nios_sw_load_initialization();
#endif

#if BOOTLOADER_DO_EXTERNAL_POST_NIOS_SW_LOAD_CLEANUP
	extern void bootloader_external_post_nios_sw_load_cleanup(int);
#endif

#if BOOTLOADER_DO_GET_BOOT_SOURCE_EXTERNALLY
    extern bootloader_boot_source_type get_bootloader_nios_sw_source();
#else
	bootloader_boot_source_type get_bootloader_nios_sw_source() {
		bootloader_boot_source_type bootloader_nios_sw_source_local = c_pio_encapsulator_extract_bit_range(&bootloader_enable_and_params_pio,BOOTLOADER_BOOT_SOURCE_LSB_BIT_INDEX,BOOTLOADER_BOOT_SOURCE_MSB_BIT_INDEX);
		return bootloader_nios_sw_source_local;
	}
#endif


#if BOOTLOADER_DO_HOOK_WHEN_DDR_CALIBRATION_FAILS
	extern void bootloader_external_handle_ddr_calibration_fail();
#endif

#if BOOTLOADER_DO_HOOK_WHEN_BOOTLOADER_IS_DISABLED
	extern void bootloader_post_disabled_cleanup();
#endif

int jtag_is_connected()
{
	int jtag_is_now_connected;
	ioctl(STDOUT_FILENO,TIOCGCONNECTED,&jtag_is_now_connected);
	return jtag_is_now_connected;
}

void disconnect_jtag() {
	alt_io_redirect("/dev/null", "/dev/null", "/dev/null");
	jtag_has_been_disconnected = 1;
}



#if BOOTLOADER_ENABLE_JTAG_ALARM
alt_u32 check_if_jtag_has_been_disconnected (void* context)
{
	if (jtag_is_connected())
	{
		if (jtag_has_been_disconnected)
		{
			 alt_io_redirect(ALT_STDOUT, ALT_STDIN, ALT_STDERR);

			 fflush(NULL); //flush all cstdio streams

			 clearerr(stdout);
			 clearerr(stdin);
			 clearerr(stderr);

			 jtag_has_been_disconnected = 0;
		}
	} else
	{
		disconnect_jtag();
	}
	return(BOOTLOADER_JTAG_CHECK_ALARM_NUM_SECONDS*alt_ticks_per_second()); //return number of ticks until next alarm
}
#endif

char outbuf[MAXSTR+1];

#if BOOTLOADER_USE_MY_JTAG_WRITE
#define my_printf(args...) do { xsprintf(outbuf,args);  JTAGPRINT(outbuf); } while (0)
#else
#define my_printf(args...) do { xsprintf(outbuf,args);  xprintf(outbuf); } while (0)
#endif


unsigned char bootloader_chan_getc() {
#if !(BOOTLOADER_DISABLE_GETC)
	int c;
	c = alt_getchar();
	if (c > 0) {
		return ((char) c);
	} else {
		return 0;
	}
#else
	return 0
#endif

}

void bootloader_chan_putc(unsigned char c) {
	 if (!jtag_has_been_disconnected) {
#if BOOTLOADER_USE_MY_JTAG_WRITE
	MyJtagWrite(&c,1);
#else
	alt_putchar((int)c);
#endif
	 }
}

void clear_boot_success_confirm_pio_out() {
	IOWR_ALTERA_AVALON_PIO_DATA(BOOTLOADER_BOOT_SUCCESS_CONFIRM_PIO_OUT_BASE,0);
}
unsigned long read_boot_success_confirm_pio_in() {
 return IORD(BOOTLOADER_BOOT_SUCCESS_CONFIRM_PIO_IN_BASE,0);
}

int boot_success_has_been_confirmed() {
	return (read_boot_success_confirm_pio_in() == BOOT_CONFIRM_SUCCESS_MAGIC_WORD);
}

unsigned long read_main_nios_pc() {
 return IORD(BOOTLOADER_MAIN_NIOS_PC_MONITOR_BASE,0);
}

void print_main_nios_pc() {
	my_printf("pc = %x\n",read_main_nios_pc());
}
void print_seq_of_main_nios_pcs(unsigned long num_to_print) {
	unsigned long i;
	for (i = 0; i < num_to_print; i++) {
		print_main_nios_pc();
	}
}
alt_u32 get_configuration_settings() {
	return (c_pio_encapsulator_read(&bootloader_enable_and_params_pio));
}

int ddr_pll_is_locked() {
	 unsigned int configuration_settings =  get_configuration_settings();
		 return ((configuration_settings & (1 << BOOTLOADER_DDR_PLL_LOCKED_STATUS_BIT)) != 0);
}
int ddr_calibration_has_failed() {
	 unsigned int configuration_settings =  get_configuration_settings();
		 return ((configuration_settings & (1 << BOOTLOADER_DDR_FAIL_STATUS_BIT)) != 0);
}

int ddr_calibration_has_succeeded() {
	 unsigned int configuration_settings =  get_configuration_settings();
     return ((configuration_settings & (1 << BOOTLOADER_DDR_SUCCESS_STATUS_BIT)) != 0);
}
void bootloader_do_ddr_reset() {
	c_pio_encapsulator_turn_off_bit(&bootloader_gpio_out_pio,BOOTLOADER_DDR_TRIGGER_A_RESET_BIT);
	c_pio_encapsulator_turn_on_bit(&bootloader_gpio_out_pio,BOOTLOADER_DDR_TRIGGER_A_RESET_BIT);
	c_pio_encapsulator_turn_off_bit(&bootloader_gpio_out_pio,BOOTLOADER_DDR_TRIGGER_A_RESET_BIT);
}

int software_reset_request_pending() {
	 unsigned int configuration_settings =  get_configuration_settings();
	 return ((configuration_settings & (1 << REQUEST_SOFTWARE_RELOAD_BIT)) != 0);
}


int get_bootloader_image_index() {
	int bootloader_image_index = c_pio_encapsulator_extract_bit_range(&bootloader_enable_and_params_pio,BOOTLOADER_BOOT_SOURCE_LSB_SW_IMAGE_INDEX,BOOTLOADER_BOOT_SOURCE_MSB_SW_IMAGE_INDEX);
	return bootloader_image_index;
}

void clear_software_reset_request() {
	c_pio_encapsulator_turn_on_bit(&bootloader_gpio_out_pio,BOOTLOADER_CLEAR_SOFTWARE_RESET_REQUEST_BIT_INDEX);
	c_pio_encapsulator_turn_off_bit(&bootloader_gpio_out_pio,BOOTLOADER_CLEAR_SOFTWARE_RESET_REQUEST_BIT_INDEX);
}

void set_main_cpu_reset_inactive() {
	  //IOWR( BOOTLOADER_MAIN_CPU_RESET_PIO_BASE, 0, RESET_INACTIVE ); //make sure reset is inactive
	  c_pio_encapsulator_turn_off_bit(&bootloader_reset_control_pio, RESET_ACTIVE_BIT_NUM );
}

void set_main_cpu_reset_active() {
	//IOWR( BOOTLOADER_MAIN_CPU_RESET_PIO_BASE, 0, RESET_ACTIVE );
    c_pio_encapsulator_turn_on_bit(&bootloader_reset_control_pio, RESET_ACTIVE_BIT_NUM );
}

void set_dut_cpu_reset_inactive() {
	  //IOWR( BOOTLOADER_MAIN_CPU_RESET_PIO_BASE, 0, RESET_INACTIVE ); //make sure reset is inactive
	  c_pio_encapsulator_turn_off_bit(&bootloader_reset_control_pio, DUT_RESET_ACTIVE_BIT_NUM );
}

void set_dut_cpu_reset_active() {
	//IOWR( BOOTLOADER_MAIN_CPU_RESET_PIO_BASE, 0, RESET_ACTIVE );
    c_pio_encapsulator_turn_on_bit(&bootloader_reset_control_pio, DUT_RESET_ACTIVE_BIT_NUM );
}

void clear_resettaken_capture_register() {
	c_pio_encapsulator_clear_capture_reg(&bootloader_reset_control_pio);

	//IOWR( BOOTLOADER_MAIN_CPU_RESET_PIO_BASE, 3, 0 ); // capture register is at offset 3.
}

alt_u32 read_main_nios_resettaken() {
	unsigned long data;
	c_pio_encapsulator_read_capture_reg(&bootloader_reset_control_pio,&data);
	return ((data & (1 << MAIN_NIOS_RESETTAKEN_BIT_NUM)) != 0);  //added 0x01 in order to avoid possibility of higher order bits being nonzero (seen this before)
	//return IORD( BOOTLOADER_MAIN_CPU_RESET_PIO_BASE, 3 ) & 0x01; //added 0x01 in order to avoid possibility of higher order bits being nonzero (seen this before)
}

alt_u32 read_dut_nios_resettaken() {
	unsigned long data;
	c_pio_encapsulator_read_capture_reg(&bootloader_reset_control_pio,&data);
	return ((data & (1 << DUT_NIOS_RESETTAKEN_BIT_NUM)) != 0);  //added 0x01 in order to avoid possibility of higher order bits being nonzero (seen this before)
	//return IORD( BOOTLOADER_MAIN_CPU_RESET_PIO_BASE, 3 ) & 0x01; //added 0x01 in order to avoid possibility of higher order bits being nonzero (seen this before)
}

void set_hard_reset_active() {
	//IOWR(BOOTLOADER_PIO_RESET_AND_BOOTLOADER_REQUEST_BASE,0,HARD_RESET_ACTIVE);
	c_pio_encapsulator_turn_on_bit(&bootloader_reset_and_bootloader_request_pio,HARD_RESET_ACTIVE_BIT_NUM);
	usleep(SAFETY_SLEEP_INTERVAL_USEC);
}

void set_hard_reset_inactive() {
	//IOWR(BOOTLOADER_PIO_RESET_AND_BOOTLOADER_REQUEST_BASE,0,HARD_RESET_INACTIVE);
	c_pio_encapsulator_turn_off_bit(&bootloader_reset_and_bootloader_request_pio,HARD_RESET_ACTIVE_BIT_NUM);
	usleep(SAFETY_SLEEP_INTERVAL_USEC);
}

unsigned long get_main_processor_reset_address_in_bootloader_address_space() {
  return (BOOTLOADER_MEMORY_OF_MAIN_PROCESSOR_IN_BOOTLOADER_ADDRESS_SPACE + MAIN_CPU_RESET_ADDR);
}

unsigned long get_dut_processor_reset_address_in_bootloader_address_space() {
  return (BOOTLOADER_MEMORY_OF_DUT_PROCESSOR_IN_BOOTLOADER_ADDRESS_SPACE + DUT_CPU_RESET_ADDR);
}

unsigned long get_processor_reset_address_in_bootloader_address_space(bootloader_index_of_processors_t processor_index) {
	switch (processor_index) {
	case BOOTLOADER_INDEX_OF_MAIN_PROCESSOR : return get_main_processor_reset_address_in_bootloader_address_space();
	case BOOTLOADER_INDEX_OF_DUT_PROCESSOR  : return get_dut_processor_reset_address_in_bootloader_address_space();
	default : infinite_loop_with_message("unknown processor index 0x%x",processor_index);

	}
    return 0; //will never get here
}

void release_main_cpu_reset() {
 	  set_hard_reset_inactive();
      set_main_cpu_reset_inactive();
}

void release_dut_cpu_reset() {
      set_dut_cpu_reset_inactive();
}

void bootloader_print_pio_statuses(pio_encapsulator_struct* pio_list_head) {
    my_printf("%s\n%sPIO List",COMMENT_STR,COMMENT_STR);
	print_underline();
	for (pio_encapsulator_struct* pio_ptr = pio_list_head; pio_ptr != NULL; pio_ptr=pio_ptr->next) {
	my_printf("%sName: %-40s Type: %-10s Base Address: 0x%08x Val: 0x%08x\n",COMMENT_STR,
			pio_ptr->name,
			pio_ptr->pio_type == ALTERA_PIO_TYPE_INPUT ? "INPUT" :
					(ALTERA_PIO_TYPE_OUTPUT ? "OUTPUT" : "BIDIR"),
					pio_ptr->base_address,
					c_pio_encapsulator_read(pio_ptr));
	}
}

void bootloader_print_all_pio_statuses() {
	bootloader_print_pio_statuses(bootloader_internal_pio_list_head);
}
/*****************************************************************************
*  Function: main
*
*  Purpose: This routine loads an application to RAM from flash, then calls
*  ReleaseMainCPU() to handoff execution to start the main Nios II CPU.
*
*****************************************************************************/
int main(void)
{
	jtag_uart_state = 0x1;
	int load_image_success = 0;
	int CRC_error_check_result;
	int mem_test_error;
	bootloader_internal_pio_list_head = &bootloader_reset_control_pio;
	c_pio_encapsulator_init(&bootloader_reset_control_pio, BOOTLOADER_MAIN_CPU_RESET_PIO_BASE,ALTERA_PIO_TYPE_INOUT, "RESET_NIOS_PIO",0,&bootloader_gpio_out_pio   );
	c_pio_encapsulator_init(&bootloader_gpio_out_pio, BOOTLOADER_GPIO_OUT_BASE,ALTERA_PIO_TYPE_OUTPUT, "GPIO_OUT_PIO",1,&bootloader_reset_and_bootloader_request_pio   );
	c_pio_encapsulator_init(&bootloader_reset_and_bootloader_request_pio, BOOTLOADER_PIO_RESET_AND_BOOTLOADER_REQUEST_BASE, ALTERA_PIO_TYPE_OUTPUT, "RESET_AND_BL_REQ",2,&bootloader_enable_and_params_pio);
	c_pio_encapsulator_init(&bootloader_enable_and_params_pio,BOOTLOADER_ENABLE_AND_PARAMS_PIO_BASE,ALTERA_PIO_TYPE_INPUT,"ENABLE_AND_PARAMS",3,NULL);

	usleep(BOOTLOADER_TIME_TO_WAIT_ON_STARTUP);

		#if BOOTLOADER_DO_EXTERNAL_DO_SOMETHING_RIGHT_AT_THE_VERY_BEGINNING
			bootloader_external_do_something_at_the_very_beginning();
		#endif

	 if (COMPLETELY_DISABLE_BOOTLOADER_ONLY_WRITE_HELLO_WORLD) {
		 do {
			 release_main_cpu_reset();
			  if (BOOTLOADER_DO_DUT_PROCESSOR_RESET_HANDLING) {
				  usleep(SAFETY_SLEEP_INTERVAL_USEC);
				  release_dut_cpu_reset();
			  }
			 my_printf("Hello World!\n");
			 usleep(1000000);
		 } while(1);
	 }



#if BOOTLOADER_CHECK_JTAG_DISCONNECT_AT_START

    if (!jtag_is_connected()) {
    	disconnect_jtag();
    }
#endif



#if !(BOOTLOADER_DISABLE_GETC)
  xdev_in(bootloader_chan_getc);
#endif
	xdev_out(bootloader_chan_putc);
#if BOOTLOADER_ENABLE_JTAG_ALARM
	if (alt_alarm_start (&jtag_check_alarm,
			BOOTLOADER_JTAG_CHECK_ALARM_NUM_SECONDS*alt_ticks_per_second(),
				check_if_jtag_has_been_disconnected,
				NULL) < 0)
	{
		xprintf("Error in registering JTAG_CHECK_ALARM: No system clock available\n");
	} else {
		xprintf("Registered JTAG_CHECK_ALARM\n");
	}
	int timeout = BOOTLOADER_JTAG_CHECK_ALARM_NUM_SECONDS;
	ioctl(STDOUT_FILENO,TIOCSTIMEOUT,&timeout);
#endif

start_the_bootloader:
  debug_do(my_printf("bootloader version: "));
  debug_do(my_printf(__TIME__));
  debug_do(my_printf(" "));
  debug_do(my_printf(__DATE__));
  debug_do(my_printf("\n"));
  debug_do(my_printf("Main CPU reset address = 0x%x\n",get_main_processor_reset_address_in_bootloader_address_space()));

  debug_do(print_seq_of_main_nios_pcs(DEBUG_NUM_PCS_TO_PRINT));

#if BOOTLOADER_WAIT_FOR_DDR_TO_SUCCESSFULLY_CALIBRATE_BEFORE_CONTINUING
  debug_do(my_printf("Waiting for DDR Calibration, currently fail = %d success = %d PLL lock = %d\n",ddr_calibration_has_failed(),ddr_calibration_has_succeeded(),ddr_pll_is_locked()));
  #if (BOOTLOADER_DO_HOOK_WHEN_DDR_CALIBRATION_FAILS)
        bootloader_external_handle_ddr_calibration_fail();
  #else

		  while (ddr_calibration_has_failed() || (!ddr_calibration_has_succeeded())) {
			  debug_do(my_printf("Waiting for DDR Calibration, currently fail = %d success = %d PLL lock = %d\n",ddr_calibration_has_failed(),ddr_calibration_has_succeeded(),ddr_pll_is_locked()));
			  bootloader_print_all_pio_statuses(bootloader_internal_pio_list_head);
			  //emif_complete_status_report();
			  if (ddr_calibration_has_failed()) {
				 debug_do(my_printf("DDR Calibration, failed, so doing a DDR reset\n"));
				 bootloader_do_ddr_reset();
			  }
			  usleep(BOOTLOADER_WAIT_INTERVAL_FOR_DDR_TO_CALIBRATE);
		  }
#endif
  debug_do(my_printf("DDR Calibration successful, fail = %d success = %d PLL lock = %d\n",ddr_calibration_has_failed(),ddr_calibration_has_succeeded(),ddr_pll_is_locked()));
  //emif_complete_status_report();

#endif

  debug_do(my_printf("Now making sure Main NIOS is branching to itself when released\n"));
  make_reset_addr_branch_to_itself(BOOTLOADER_INDEX_OF_MAIN_PROCESSOR); //make main NIOS do an infinite loop so that it doesn't execute junk, before we release it. Writing to the DDR RAM when the ELF is loaded will overwrite this

  if (BOOTLOADER_DO_DUT_PROCESSOR_RESET_HANDLING) {
	  debug_do(my_printf("\nNow making sure DUT NIOS is branching to itself when released\n"));
	  make_reset_addr_branch_to_itself(BOOTLOADER_INDEX_OF_DUT_PROCESSOR); //make dut NIOS do an infinite loop so that it doesn't execute junk, before we release it. Writing to the DDR RAM when the ELF is loaded will overwrite this
	  usleep(SAFETY_SLEEP_INTERVAL_USEC);
	  release_dut_cpu_reset();
  }

  alt_u32 entry_point;
  int temp;
  unsigned long configuration_settings;
  debug_do(my_printf("Now sleeping a little bit\n"));
  usleep(TIME_TO_WAIT_BEFORE_DOING_ANYTHING_USECS);
  debug_do(my_printf("Card revision is: 0x%x\n",get_card_revision()));



  debug_do(print_seq_of_main_nios_pcs(DEBUG_NUM_PCS_TO_PRINT));

  unsigned long trys_so_far = 0;
  unsigned long got_resettaken = 0;


 if (ONLY_WRITE_HELLO_WORLD) {
	 do {
		 release_main_cpu_reset();
		 my_printf("Hello World!\n");
		 usleep(1000000);
	 } while(1);
 }

#if BOOTLOADER_DO_EXTERNAL_PRE_BOOT_INITIALIZATION
    debug_do(my_printf("Now doing external preboot initialization\n"));
	bootloader_external_pre_boot_initialization();
#endif


 if (software_reset_request_pending()) {
	     		debug_do(my_printf("Woke up to find a software reset request, probably this is the cause!\n"));
	     		clear_software_reset_request();
	       }

 unsigned int num_of_boot_trys = 0;

 retry_boot_sequence:
  do {


		  //Read configuration settings. Currently, it is only enable/disable, from the DIP switches.
		  //In the future, this could be used to select the ELF desired
		  configuration_settings = get_configuration_settings();


		  debug_do(my_printf("Detected configuration settings: %x \n", configuration_settings););


		  if ((((configuration_settings & BOOT_LOADER_IS_ENABLED_MASK) != BOOT_LOADER_IS_ENABLED_MASK) || DISABLE_BOOTLOADER_FOR_DEBUG) & (!ALWAYS_DO_BOOTLOADER))  {

			  release_main_cpu_reset(); //make sure reset is inactive
			  debug_do(my_printf("Boot loader is disabled as per configuration; waiting until it is enabled...\n"));
			  if (!BOOTLOADER_WAIT_FOR_ENABLE_IF_DISABLED)  {
				              jumped_to_command_server_because_bootloader_disabled = 1;
				  			  goto execute_the_command_server_after_boot;
				  		  }
	      }

				  if (!ALWAYS_DO_BOOTLOADER) {
						  do {
							 configuration_settings = get_configuration_settings();
							 if (PRINT_PC_PERIODICALLY_WHILE_WAITING_FOR_ENABLE) {
								  usleep(1000000); //just make sure we are not taking up any qsys system resources by accessing the on-chip ram
								  debug_do(print_main_nios_pc());
							  }
						  } while (((configuration_settings & BOOT_LOADER_IS_ENABLED_MASK) != BOOT_LOADER_IS_ENABLED_MASK) || DISABLE_BOOTLOADER_FOR_DEBUG) ;
				  }

		  bootloader_nios_sw_source = get_bootloader_nios_sw_source();
		  debug_do(my_printf("Bootloader source is: %d\n",bootloader_nios_sw_source));
		  debug_do(my_printf("Now resetting main processor\n"));
		  usleep(SAFETY_SLEEP_INTERVAL_USEC);

		  if (BOOTLOADER_DO_HARD_RESET_IF_SOFT_RESET_FAILS && (BOOTLOADER_MAX_TIMES_TO_TRY_SOFT_RESET_BEFORE_GOING_TO_HARD_RESET == 0)) {
		  			 goto do_hard_reset_now;
		  }
		  // Before getting started, we need to place and hold the main Nios II CPU in reset
		  // But first we need to clear the edge capture register in the PIO, so we
		  // can see when the CPU actually achieves reset (using the cpu_resettaken pin)
		  release_main_cpu_reset();
		  usleep(SAFETY_SLEEP_INTERVAL_USEC);
		  clear_resettaken_capture_register(); // capture register is at offset 3.
		  usleep(SAFETY_SLEEP_INTERVAL_USEC);
		  // Now we try to reset the main CPU by setting the cpu_resetrequest pin high.
		  set_main_cpu_reset_active();
		  debug_do(my_printf("Waiting for cpu_resetaken...\n"));
		  usleep(SAFETY_SLEEP_INTERVAL_USEC);
		  // Here we wait for the edge capture register of the PIO to show us that
		  // the cpu_resettaken pin toggled high.
		  unsigned long loop_counter = 0;
		  do
		  {
			temp = read_main_nios_resettaken();
			print_seq_of_main_nios_pcs(DEBUG_NUM_PCS_TO_PRINT);
			usleep(SAFETY_SLEEP_INTERVAL_USEC);
			//debug_do(my_printf("temp = %x\n",temp));
			usleep(INTERVAL_TO_WAIT_BEFORE_POLLING_RESETTAKEN_AGAIN_USEC);
			loop_counter++;
		  } while( (temp == 0x0) && (loop_counter < NUM_OF_TIMES_TO_CHECK_RESETTAKEN_BEFORE_RETRYING));

		  if (temp != 0x0) {
			  got_resettaken = 1;
		  }
		  else {
			  if (BOOTLOADER_DO_HARD_RESET_IF_SOFT_RESET_FAILS && (trys_so_far >= BOOTLOADER_MAX_TIMES_TO_TRY_SOFT_RESET_BEFORE_GOING_TO_HARD_RESET))
			  {
do_hard_reset_now: release_main_cpu_reset();
				   usleep(SAFETY_SLEEP_INTERVAL_USEC);
				   debug_do(my_printf("SW resettaken not received in time, doing hard reset\n"));
				   set_hard_reset_active();
				   did_hard_reset = 1;
			  } else {
			   debug_do(my_printf("resettaken not received in time, retrying, try = %x \n",trys_so_far));
			   trys_so_far++;
			  }
		  }
  } while ((!got_resettaken)  && (!(did_hard_reset && BOOTLOADER_DO_HARD_RESET_IF_SOFT_RESET_FAILS)) && WAIT_FOR_RESET_REQUEST);
  debug_do(print_seq_of_main_nios_pcs(DEBUG_NUM_PCS_TO_PRINT));
  debug_do(my_printf("Got cpu_resetaken!\n"));
  clear_boot_success_confirm_pio_out();
  debug_do(my_printf("Cleared boot success indication\n"));
  usleep(SAFETY_SLEEP_INTERVAL_USEC);
  debug_do(my_printf("Trying to load FLASH image....\n"));
  usleep(SAFETY_SLEEP_INTERVAL_USEC);


#if BOOTLOADER_TEST_MEMORY_BEFORE_LOADING_FLASH
  debug_do(my_printf("Testing memory....\n"));
  mem_test_error = TestRam(BOOTLOADER_BASE_ADDRESS_OF_MEMORY_TO_TEST_WITH_MEMORY_TESTER,BOOTLOADER_SIZE_OF_MEMORY_TO_TEST_WITH_MEMORY_TESTER_IN_BYTES);
  if (mem_test_error) {
  	  debug_do(my_printf("Memory test error! Aborting main Nios image load.\n"));
	  release_main_cpu_reset();
      goto execute_the_command_server_after_boot;
  } else {
  	  debug_do(my_printf("Memory test successful!\n"));
  }
#endif
  desired_boot_image_index = get_bootloader_image_index(); //this is default, unless changed by bootloader_external_pre_nios_sw_load_initialization;
#if BOOTLOADER_DO_EXTERNAL_PRE_NIOS_SW_LOAD_INITIALIZATION
	 bootloader_external_pre_nios_sw_load_initialization();
#endif
  debug_do(my_printf("Boot image index: %d\n",desired_boot_image_index));

#if COMMAND_SERVER_ENABLE_PETIT_FILE_SYSTEM
  if (((!BOOTLOADER_ENABLE_SELECTION_FROM_MULTIPLE_BOOT_SOURCES) && BOOTLOADER_LOAD_NIOS_SW_FROM_FILE) || (BOOTLOADER_ENABLE_SELECTION_FROM_MULTIPLE_BOOT_SOURCES && (bootloader_nios_sw_source == BOOTLOADER_BOOT_SW_FROM_SD_CARD))) {


	  FRESULT rc = pf_mount(&bootloader_fatfs);
	  if (rc != FR_OK) {
		  put_rc(rc);
	  } else {
	  	  debug_do(my_printf("trying to load nios_sw_from file....\n"));
	  	  entry_point = LoadSWImageFromFile(BOOTLOADER_FILE_FROM_WHICH_TO_LOAD_NIOS_SW, &load_image_success) + get_main_processor_reset_address_in_bootloader_address_space();
		  #if BOOTLOADER_DO_EXTERNAL_POST_NIOS_SW_LOAD_CLEANUP
			    bootloader_external_post_nios_sw_load_cleanup(load_image_success);
		  #endif

	  	  if(load_image_success)  // load the image
		    {
		  	debug_do(my_printf("Loaded image successfully, now releasing CPU and jumping to entry point\n"));
		  	usleep(SAFETY_SLEEP_INTERVAL_USEC);
		  	debug_do(print_seq_of_main_nios_pcs(DEBUG_NUM_PCS_TO_PRINT));
		      // Release the main CPU from reset now that it has code to run.
		      ReleaseMainCPU((void(*)(void))(entry_point));
		    }
		  else
		    {
		  	  debug_do(my_printf("Error while loading software from FLASH, deasserting main CPU reset\n"));
		    }
	  }
  }
	  else {
#endif



  // Now load the application from the boot record in flash.
#if BOOTLOADER_ENABLE_BOOT_IMAGE_CRC_CHECKING
  debug_do(my_printf("Calculating CRC of Flash image\n"));
  if ((CRC_error_check_result = ValidateFlashImage(flash_image_ptr[desired_boot_image_index])) != BOOTLOADER_CRCS_VALID) {
			  load_image_success = 0;
			  switch (CRC_error_check_result) {
			  case BOOTLOADER_SIGNATURE_INVALID :  debug_do(my_printf("Flash image signature invalid!\n")); break;
			  case BOOTLOADER_HEADER_CRC_INVALID :  debug_do(my_printf("Flash image header CRC invalid!\n")); break;
			  case BOOTLOADER_DATA_CRC_INVALID :  debug_do(my_printf("Flash image data CRC invalid!\n")); break;
			  default: debug_do(my_printf("Unknown Flash CRC validation issue!\n")); break;
			  }
		  } else {
			  debug_do(my_printf("Flash Image CRC Verified!\n"));
#endif
	   debug_do(my_printf("Starting load of flash image to memory....\n"));
       entry_point = LoadFlashImage(flash_image_ptr[desired_boot_image_index], &load_image_success) + get_main_processor_reset_address_in_bootloader_address_space();
		#if BOOTLOADER_DO_EXTERNAL_POST_NIOS_SW_LOAD_CLEANUP
				bootloader_external_post_nios_sw_load_cleanup(load_image_success);
		#endif
#if BOOTLOADER_ENABLE_BOOT_IMAGE_CRC_CHECKING
		  }
#endif
  if(load_image_success)  // load the image
  {
	debug_do(my_printf("Loaded image successfully, now releasing CPU and jumping to entry point\n"));
	usleep(SAFETY_SLEEP_INTERVAL_USEC);
	debug_do(print_seq_of_main_nios_pcs(DEBUG_NUM_PCS_TO_PRINT));
    // Release the main CPU from reset now that it has code to run.
    ReleaseMainCPU((void(*)(void))(entry_point));
  }
  else
  {
	  debug_do(my_printf("Error while loading software from FLASH, deasserting main CPU reset\n"));
	  release_main_cpu_reset();
  }
#if COMMAND_SERVER_ENABLE_PETIT_FILE_SYSTEM
	  }
#endif
  debug_do(my_printf("Waiting a little bit to see if boot is successful\n"));
  usleep(TIME_TO_WAIT_BEFORE_CHECKING_IF_BOOT_WAS_SUCCESSFUL_USECS);
  if (boot_success_has_been_confirmed()) {
	  debug_do(my_printf("Boot Success has been confirmed!!!\n"));
  } else {
	  if (BOOTLOADER_COPY_TO_MEMORY_BUT_DO_NOT_BOOT) {
		  debug_do(my_printf("Not checking boot success because BOOTLOADER_COPY_TO_MEMORY_BUT_DO_NOT_BOOT enabled\n"));
	  } else {
	    debug_do(my_printf("Boot failed, boot success PIO is 0x%x, expected 0x%x, going to try boot again, try# = 0x%x\n", read_boot_success_confirm_pio_in(),BOOT_CONFIRM_SUCCESS_MAGIC_WORD,num_of_boot_trys));
	    num_of_boot_trys++;
	    goto retry_boot_sequence;
	  }
  }
  usleep(TIME_TO_WAIT_BEFORE_CHECKING_IF_BOOT_WAS_SUCCESSFUL_USECS);

execute_the_command_server_after_boot:

if (jumped_to_command_server_because_bootloader_disabled) {
#if BOOTLOADER_DO_HOOK_WHEN_BOOTLOADER_IS_DISABLED
    debug_do(my_printf("Executing disabled bootloader hook\n"));
    bootloader_post_disabled_cleanup();
#endif
} else {
#if BOOTLOADER_DO_EXTERNAL_POST_BOOT_CLEANUP
     bootloader_external_post_boot_cleanup();
#endif
}

        if (ENABLE_COMMAND_SERVER_AFTER_BOOT) {
		init_command_server_command_execute();
			char command_response_str[INTERNAL_COMMAND_RESPONSE_MAXLENGTH];
			command_response_str[0] = '\0';

			char cmd_buf[INTERNAL_COMMAND_BUFFER_LENGTH];

			for (;;)
			{
				int command_received;
				int command_was_successful;
				command_response_str[0] = '\0'; //reset response string
				cmd_buf[0] = '\0'; //reset command string

				do {
				command_received = command_server_get_command(cmd_buf,INTERNAL_COMMAND_BUFFER_LENGTH);
				} while (my_strlen(cmd_buf) == 0);

				command_was_successful = execute_command_server_command(
												cmd_buf,
												command_response_str
										 );

				commmand_server_post_process_command_response(command_response_str,command_was_successful);
			}


	} else {

	  // All done, time to exit.
	  while (1) {
		  usleep(1000000); //just make sure we are not taking up any qsys system resources by accessing the on-chip ram
		  if (PRINT_PC_PERIODICALLY_AFTER_BOOT) {
			  debug_do(print_main_nios_pc());
		  }
		  if (software_reset_request_pending()) {
				debug_do(my_printf("Got request to reload software!\n"));
				usleep(1000000); //wait to allow printf to display
				goto start_the_bootloader;
		  }
	  };
	}
}

/*****************************************************************************
*  Function: ReleaseMainCPU
*
*  Purpose: This is where the interesting stuff happens.  At this point we've
*  copied an application to the main Nios II program memory and we're holding
*  the CPU in reset.  We want to release it from reset so it can run the
*  application, only the application's entry point may not be at the CPU's 
*  reset address.  Luckily we have the entry point from the boot record, 
*  passed in here as the function pointer "entry_point".  We compare the
*  entry point to the CPU's reset address and calculate how far the CPU has
*  to branch to get there.  From that information, we construct a Nios II 
*  instruction that jumps the appropriate distance, then stuff it into memory
*  at the main CPU's reset address.  We release the CPU from reset, and if all
*  goes well, it executes the branch instruction we put at its reset address
*  and branches to the application's entry point, successfully launching the 
*  application.
*
*****************************************************************************/
void ReleaseMainCPU(void entry_point(void))
{
  int offset;
  unsigned int branch_instruction;

  // Calculate the offset the main cpu needs to jump from its reset address
  offset = (int)entry_point - get_main_processor_reset_address_in_bootloader_address_space();
  
  // We only need to formulate a branch instruction if the the reset address 
  // does not already point to the entry point of the application. If the 
  // reset address already points to the application entry point, we can just 
  // release the main Nios II CPU from reset and everything should be happy.
  if( offset )
  { 
    // Now construct the appropriate branch instruction "br" we need to stuff 
    // into the main cpu reset address.  The relative offset we use for the 
    // instruction must be 4 bytes less than the actual entry point because
    // that is how Nios II defines the "br" instruction.

    // Branch instruction encoding
    //  31  29  27  25  23  21  19  17  15  13  11  09  07  05  03  01 
    //    30  28  26  24  22  20  18  16  14  12  10  08  06  04  02  00
    //  ----------------------------------------------------------------
    // |    0    |    0    |    16-bit relative jump -4    |   0x06     |
    //  ----------------------------------------------------------------
    branch_instruction = ((offset - 4) << 6) | 0x6;

  
    // Write the instruction to the main CPU reset address
    IOWR(get_main_processor_reset_address_in_bootloader_address_space(), 0, branch_instruction);
  }
  // Now we can release the main CPU from reset
  release_main_cpu_reset();

  // We're done.  
  return;

}

void make_reset_addr_branch_to_itself(bootloader_index_of_processors_t the_processor)
{
  unsigned int branch_instruction;
  unsigned int nop_instruction;
/*
  // Calculate the offset the main cpu needs to jump from its reset address
  offset = 4;


  // Branch instruction encoding
  //  31  29  27  25  23  21  19  17  15  13  11  09  07  05  03  01
  //    30  28  26  24  22  20  18  16  14  12  10  08  06  04  02  00
  //  ----------------------------------------------------------------
  // |    0    |    0    |    16-bit relative jump -4    |   0x06     |
  //  ----------------------------------------------------------------
  branch_instruction = ((0xffff & (offset - 4)) << 6) | 0x6;
  */

  //branch_instruction = (((get_main_processor_reset_address_in_bootloader_address_space()) >> 2) << 6) | 0x01; //immediate jump
  
  branch_instruction = ((0xFFF4) << 6)| 0x06; //jump to -12 immediate offset, which jumps from 8 to 0 (8+4-12 = 0)
  nop_instruction = ((0x31) << 11) | 0x3a;

  debug_do(my_printf("nop_instruction = %x \n", nop_instruction););
  debug_do(my_printf("branch_instruction = %x \n", branch_instruction););
  // Write the instruction to the main CPU reset address
  IOWR(get_processor_reset_address_in_bootloader_address_space(the_processor), 0, nop_instruction);
  IOWR(get_processor_reset_address_in_bootloader_address_space(the_processor), 1, nop_instruction);
  IOWR(get_processor_reset_address_in_bootloader_address_space(the_processor), 2, branch_instruction);
  debug_do(my_printf("Processor 0x%x Instruction at 0 = 0x%x \n", the_processor, IORD(get_processor_reset_address_in_bootloader_address_space(the_processor), 0)););
  debug_do(my_printf("Processor 0x%x Instruction at 4 = 0x%x \n", the_processor, IORD(get_processor_reset_address_in_bootloader_address_space(the_processor), 1)););
  debug_do(my_printf("Processor 0x%x Instruction at 8 = 0x%x \n", the_processor, IORD(get_processor_reset_address_in_bootloader_address_space(the_processor), 2)););
  // We're done.
  return;

}





#if COMMAND_SERVER_ENABLE_PETIT_FILE_SYSTEM


int func_open_nios_sw_file(char* filename, unsigned int num_chars_to_print) {
  DIR dir;				/* Directory object */
  FILINFO fno;			/* File information object */
  UINT bw, br, i;
  FRESULT rc;
  long p1, p2, p3;
  BYTE res, buff[1024];
  UINT w, cnt, s1, s2, ofs;
  make_string_uppercase(filename);
  trim_trailing_spaces(filename);
  res =  pf_open(filename);
  if (res != FR_OK) { put_rc(res); return FALSE; }
  p1 = GET_MIN_VAL(bootloader_fatfs.fsize, num_chars_to_print); //length of file to print
  ofs = bootloader_fatfs.fptr;
  unsigned int charcnt = 0;
  while (p1) {
  	if ((UINT)p1 >= 16) { cnt = 16; p1 -= 16; }
  	else 				{ cnt = (UINT)p1; p1 = 0; }
  	res = pf_read(buff, cnt, &w);
  	if (res != FR_OK) { put_rc(res); return FALSE; }
  	if (!w) break;
  	buff[w] = '\0';
	if (charcnt < num_chars_to_print) {
		put_dump(buff, ofs, cnt, DW_CHAR);
	}
  	ofs += 16;
  	charcnt += cnt;
  }
 return TRUE;
}
int CopyFromFile( void * dest, unsigned int file_offset, size_t length )
{
  const int MAX_NUM_OF_BYTES_TO_READ_EACH_TIME = DEFAULT_SECTOR_SIZE_FOR_FILE_SYSTEM_CARD;
  BYTE res;
  UINT w = 0, ofs = 0;
  unsigned int cnt = 0;
  unsigned int charcnt = 0;
  unsigned int p1 = length;
  pf_lseek(file_offset);
  while (p1) {
  	if ((UINT)p1 >= MAX_NUM_OF_BYTES_TO_READ_EACH_TIME) { cnt = MAX_NUM_OF_BYTES_TO_READ_EACH_TIME; p1 -= MAX_NUM_OF_BYTES_TO_READ_EACH_TIME; }
  	else 				{ cnt = (UINT)p1; p1 = 0; }
  	res = pf_read((void *)(dest+charcnt), cnt, &w);
  	if (res != FR_OK) { put_rc(res);   return charcnt; }
  	if (!w) break;
  	if (BOOTLOADER_PRINT_OUT_FLASH_ELF_FILE_AS_IT_IS_READ) {
  		put_dump((void *)(dest+charcnt), ofs, cnt, DW_CHAR);
  	}
  	ofs += MAX_NUM_OF_BYTES_TO_READ_EACH_TIME;
  	charcnt += cnt;
  }
  return charcnt;
}

alt_u32 LoadSWImageFromFile ( char* filename, int* success )
{
  alt_u32 next_flash_offset;
  alt_u32 length;
  alt_u32 address;
  func_open_nios_sw_file(filename,BOOTLOADER_DO_FLASH_HEXDUMP ? HEXDUMP_BLOCK_SIZE : 0);
  next_flash_offset =  32;
  *success = 0;
  /*
   * Flash images are not guaranteed to be word-aligned within the flash
   * memory, so a word-by-word copy loop should not be used.
   *
   * The "memcpy()" function works well to copy non-word-aligned data, and
   * it is relativly small, so that's what we'll use.
   */

  // Get the first 4 bytes of the boot record, which should be a length record
  CopyFromFile( (void*)(&length), next_flash_offset, (size_t)(4) );
  next_flash_offset += 4;

  // Now loop until we get an entry record, or a halt recotd
  while( (length != 0) && (length != 0xffffffff) )
  {
    // Get the next 4 bytes of the boot record, which should be an address
    // record
	  CopyFromFile( (void*)(&address), next_flash_offset, (size_t)(4) );
	  next_flash_offset += 4;

    address -= get_main_processor_absolute_reset_address_in_main_processor_address_space(); //make sure address is relative

    debug_do(my_printf("addr =0x%x length=0x%x\n", address,length););
#if (!DO_NOT_DO_ACTUAL_COPY_TO_DDR)
    // Copy the next "length" bytes to "address"
    CopyFromFile( (void*)(address + get_main_processor_reset_address_in_bootloader_address_space()), next_flash_offset, (size_t)(length) );
    next_flash_offset += length;
#endif

    // Get the next 4 bytes of the boot record, which now should be another
    // length record
    CopyFromFile( (void*)(&length), next_flash_offset, (size_t)(4) );
    next_flash_offset += 4;
  }

  // "length" was read as either 0x0 or 0xffffffff, which means we are done
  // copying.
  if( length == 0xffffffff )
  {
    // We read a HALT record, so return a 0
	*success = 0;
    return 0;
  }
  else // length == 0x0
  {
    // We got an entry record, so read the next 4 bytes for the entry address
	  CopyFromFile( (void*)(&address), next_flash_offset, (size_t)(4) );
	  next_flash_offset += 4;

    // Return the entry point address
	  *success = 1;
    return address;
  }
}

#endif
/*****************************************************************************
*  Function: CopyFromFlash
*
*  Purpose:  This subroutine copies data from a flash memory to a buffer
*  The function uses the appropriate copy routine for the flash that is
*  defined by FLASH_TYPE.  EPCS devices cant simply be read from using
*  memcpy().
*
*****************************************************************************/

void* CopyFromFlash( void * dest, const void * src, size_t num )
{

    memcpy( dest, src, num );

  return (dest);
}

#ifndef HEXDUMP_COLS
#define HEXDUMP_COLS 8
#endif

void my_hexdump(void *mem, unsigned int len)
{
        unsigned int i, j;
        my_printf("addr = 0x%08x\n ", mem);
        for(i = 0; i < len + ((len % HEXDUMP_COLS) ? (HEXDUMP_COLS - len % HEXDUMP_COLS) : 0); i++)
        {
                /* print offset */
                if(i % HEXDUMP_COLS == 0)
                {
                        my_printf("0x%06x: ", i);
                }

                /* print hex data */
                if(i < len)
                {
                        my_printf("%02x ", 0xFF & ((char*)mem)[i]);
                }
                else /* end of block, just aligning for ASCII dump */
                {
                        my_printf("   ");
                }

                /* print ASCII dump */
                if(i % HEXDUMP_COLS == (HEXDUMP_COLS - 1))
                {
                        for(j = i - (HEXDUMP_COLS - 1); j <= i; j++)
                        {
                                if(j >= len) /* end of block, not really printing */
                                {
                                	my_printf(" ");
                                }
                                else if(isprint(((char*)mem)[j])) /* printable char */
                                {
                                        my_printf("%c",0xFF & ((char*)mem)[j]);
                                }
                                else /* other char */
                                {
                                        my_printf(".");
                                }
                        }
                        my_printf("\n");
                }
        }
}
/*****************************************************************************
*  Function: LoadFlashImage
*
*  Purpose:  This subroutine loads an image from flash into the Nios II 
*  memory map.  It decodes boot records in the format produced from the 
*  elf2flash utility, and loads the image as directed by those records.  
*  The format of the boot record is described in the text of the application 
*  note.
*
*****************************************************************************/
alt_u32 LoadFlashImage ( alt_u8 *flash_image_ptr_1,  int* success )
{
  alt_u8 *next_flash_byte;
  alt_u32 length;
  alt_u32 address;
  *success = 0;
  next_flash_byte = (alt_u8 *) flash_image_ptr_1 + 32;
#if BOOTLOADER_DO_FLASH_HEXDUMP
  debug_do(my_hexdump(flash_image_ptr_1,HEXDUMP_BLOCK_SIZE));
#endif
  /*
   * Flash images are not guaranteed to be word-aligned within the flash 
   * memory, so a word-by-word copy loop should not be used.
   * 
   * The "memcpy()" function works well to copy non-word-aligned data, and 
   * it is relativly small, so that's what we'll use.
   */
   
  // Get the first 4 bytes of the boot record, which should be a length record
  CopyFromFlash( (void*)(&length), (void*)(next_flash_byte), (size_t)(4) );
  next_flash_byte += 4;
  
  // Now loop until we get an entry record, or a halt recotd
  while( (length != 0) && (length != 0xffffffff) )
  {
    // Get the next 4 bytes of the boot record, which should be an address 
    // record
    CopyFromFlash( (void*)(&address), (void*)(next_flash_byte), (size_t)(4) );
    next_flash_byte += 4;
    
    address -= get_main_processor_absolute_reset_address_in_main_processor_address_space(); //make sure address is relative

    debug_do(my_printf("addr =0x%x length=0x%x\n", address,length););
#if (!DO_NOT_DO_ACTUAL_COPY_TO_DDR)
    // Copy the next "length" bytes to "address"
    CopyFromFlash( (void*)(address + get_main_processor_reset_address_in_bootloader_address_space()), (void*)(next_flash_byte), (size_t)(length) );
    next_flash_byte += length;
#endif

    // Get the next 4 bytes of the boot record, which now should be another 
    // length record
    CopyFromFlash( (void*)(&length), (void*)(next_flash_byte), (size_t)(4) );
    next_flash_byte += 4;
  }
  
  // "length" was read as either 0x0 or 0xffffffff, which means we are done 
  // copying.
  if( length == 0xffffffff )
  {
    // We read a HALT record, so return a 0
	*success = 0;
    return 0;
  }
  else // length == 0x0
  {
    // We got an entry record, so read the next 4 bytes for the entry address
    CopyFromFlash( (void*)(&address), (void*)(next_flash_byte), (size_t)(4) );
    next_flash_byte += 4;
    
    // Return the entry point address
	*success = 1;
    return address;
  }
}


#if BOOTLOADER_ENABLE_BOOT_IMAGE_CRC_CHECKING

/*****************************************************************************
*  Function: ValidateFlashImage
*
*  Purpose:  This routine validates a flash image based upon three critera:
*            1.) It contains the correct flash image signature
*            2.) A CRC check of the image header
*            3.) A CRC check of the image data (payload)
*
*  Since it's inefficient to read individual bytes from EPCS, and since
*  we dont really want to expend RAM to buffer the entire image, we comprimise
*  in the case of EPCS, and create a medium-size buffer, who's size is
*  adjustable by the user.
*
*****************************************************************************/
int ValidateFlashImage(void *image_ptr)
{
  my_flash_header_type temp_header  __attribute__((aligned(4)));

  /*
   * Again, we don't assume the image is word aligned, so we copy the header
   * from flash to a word aligned buffer.
   */
    CopyFromFlash(&temp_header, image_ptr, 32);

  // Check the signature first
  if( temp_header.signature == 0xa5a5a5a5 )
  {
    // Signature is good, validate the header crc
    if( temp_header.header_crc != FlashCalcCRC32( (alt_u8*)image_ptr, 28) )
    {
      // Header crc is not valid
      return BOOTLOADER_HEADER_CRC_INVALID;
     }
    else
    {
      // header crc is valid, now validate the data crc
      if ( temp_header.data_crc == FlashCalcCRC32( image_ptr + 32, temp_header.data_length) )
      {
        // data crc validates, the image is good
        return BOOTLOADER_CRCS_VALID;
      }
      else
      {
        // data crc is not valid
        return BOOTLOADER_DATA_CRC_INVALID;
      }
    }
  }
  else
  {
    // bad signature, return 1
    return BOOTLOADER_SIGNATURE_INVALID;
  }
}

/*****************************************************************************
*  Function: FlashCalcCRC32
*
*  Purpose:  This subroutine calcuates a reflected CRC32 on data located
*  flash.  The routine buffers flash contents locally in order
*  to support EPCS flash as well as CFI
*
*****************************************************************************/
alt_u32 FlashCalcCRC32(alt_u8 *flash_addr, int bytes)
{
  alt_u32 crcval = 0xffffffff;
  int i, buf_index, copy_length;
  alt_u8 cval;
  char flash_buffer[BOOTLOADER_FLASH_BUFFER_LENGTH];

  while(bytes != 0)
  {
    copy_length = (BOOTLOADER_FLASH_BUFFER_LENGTH < bytes) ? BOOTLOADER_FLASH_BUFFER_LENGTH : bytes;
    CopyFromFlash(flash_buffer, flash_addr, copy_length);
    for(buf_index = 0; buf_index < copy_length; buf_index++ )
    {
      cval = flash_buffer[buf_index];
      crcval ^= cval;
      for (i = 8; i > 0; i-- )
      {
        crcval = (crcval & 0x00000001) ? ((crcval >> 1) ^ 0xEDB88320) : (crcval >> 1);
      }
      bytes--;
    }
    flash_addr += BOOTLOADER_FLASH_BUFFER_LENGTH;
  }
  return crcval;
}
#endif

#if BOOTLOADER_TEST_MEMORY_BEFORE_LOADING_FLASH

		  /******************************************************************
		  *  Function: TestRam
		  *
		  *  Purpose: Performs a full-test on the RAM specified.  The tests
		  *           run are:
		  *             - MemTestDataBus
		  *             - MemTestAddressBus
		  *             - MemTest8_16BitAccess
		  *             - MemTestDevice
		  *
		  ******************************************************************/
		  int TestRam(alt_u32 memory_base, alt_u32 memory_size)
		  {

		    int ret_code = 0x0;

            debug_do(my_printf("Testing RAM from 0x%X to 0x%X\n", memory_base, (memory_base + memory_size -1)));

		    /* Test Data Bus. */
		    ret_code = MemTestDataBus(memory_base);

		    if (ret_code) {
		    	debug_do(my_printf(" -Data bus test failed at bit 0x%X", (int)ret_code));
		    } else {
		    	debug_do(my_printf(" -Data bus test passed\n"));
		    }

		    /* Test Address Bus. */
		    if (!ret_code)
		    {
		      ret_code  = MemTestAddressBus(memory_base, memory_size);
		      if  (ret_code) {
		    	  debug_do(my_printf(" -Address bus test failed at address 0x%X", (int)ret_code));
		      } else {
		    	  debug_do(my_printf(" -Address bus test passed\n"));
		      }
		    }

		    /* Test byte and half-word access. */
		    if (!ret_code)
		    {
		      ret_code = MemTest8_16BitAccess(memory_base);
		      if  (ret_code) {
		    	  debug_do(my_printf(" -Byte and half-word access test failed at address 0x%X", (int)ret_code));
		      } else {
		    	  debug_do(my_printf(" -Byte and half-word access test passed\n"));
		      }
		    }

#if BOOTLOADER_DO_BITWISE_MEMORY_TEST_THAT_TAKES_A_LONG_TIME
		    /* Test that each bit in the device can store both 1 and 0. */
		    if (!ret_code)
		    {
		      debug_do(my_printf(" -Testing each bit in memory device"));
		      ret_code = MemTestDevice(memory_base, memory_size);
		      if  (ret_code) {
		    	  debug_do(my_printf("  failed at address 0x%X", (int)ret_code));
		      } else {
		    	  debug_do(my_printf("  passed\n"));
		      }
		    }
#endif
		    if (!ret_code) {
		    	debug_do(my_printf("Memory at 0x%X Okay\n", memory_base));
		    }

		    return ret_code;
		  }





#endif
