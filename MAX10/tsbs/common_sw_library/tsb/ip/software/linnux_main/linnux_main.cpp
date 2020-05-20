#include "linnux_main.h"
#include "command_server_basedef.h"
#include "malloc.h"
#include "matlab_curve_linetype_generator.h"
#include "jim.h"
#include "sys/ioctl.h"
#include "send_to_ethernet_stdout.h"
#include "iof/io.hpp"

extern "C" {
#include "my_mem_defs.h"
#include "mem.h"
#include "ucos_ii.h"
#include "simple_socket_server.h"
#include "http.h"
#include "os_cpu.h"
#include "ipport.h"
#include "memwrap.h"
#ifdef UDP_INSERTER_0_BASE
#include "demo_control.h"
#endif
#ifdef 	MSGDMA_0_CSR_BASE
#include "altera_msgdma.h"
#endif

}

#include "smtpfuncs.h"
#include "chan_fatfs/integer.h"
#include "chan_fatfs/diskio.h"
#include "chan_fatfs/ff.h"
#include "strtk.hpp"
#include "chan_fatfs/fatfs_linnux_api.h"
#include <unistd.h>
#include "CBaseConverter.h"
#include "get_new_command_for_linnux.h"
#include "alt_error_handler.hpp"
#include "linnux_remote_command_container.h"
#include "linnux_remote_command_response_container.h"
#include "cpp_linnux_dns_tools.h"
#include "altera_eth_tse_regs.h"
#include "altera_avalon_pio_regs.h"
#include "cpp_to_c_header_interface.h"
#include "ucos_cpp_utils.h"
#include "tinyformat.h"
#include "linnux_server_dns_utils.h"
#include "global_stream_defs.hpp"
#include "memory_comm_encapsulator.h"
//#include "spi_encapsulator.h"
//#include "adc12eu050_controller.h"
#include "uart_support/uart_encapsulator.h"
#include "uart_support/uart_register_file.h"
#include "uart_support/uart_vector_config_encapsulator.h"
#include "altera_pio_encapsulator.h"
#include "flow_through_fifo_encapsulator.h"
#include "fmc_present_encapsulator.h"
#include "led_encapsulator.h"
#include "fmc_encapsulator.h"
#include "board_mgmt_encapsulator.h"
#include "dual_port_memory_comm_encapsulator.h"
#include "card_configuration_encapsulator.h"
#include "iniche_diag_interface.h"
#include "uart_support/virtual_uart_register_file.h"
#include "priv/alt_file.h"
#include "telnet_object_process.h"
#include "jansson.hpp"
#include "json_serializer_class.h"
#ifdef UDP_INSERTER_0_BASE
#include "udp_streamer_telnet_interace.h"
#endif
#include "jsonp_menu.h"
#include "smart_buffer.h"
#include "multi_stream_packetizer.h"

using namespace mspkt;

extern void my_puts_to_command_uart (std::string);
//std::string system_h_str;
extern std::map<std::string,std::string>* get_system_h_parser_value_map_ptr();

int get_mem_region_data_for_http_file_download(unsigned int index, unsigned int *base_address, unsigned int *length);

#if SUPPORT_GENERAL_FLASH_PROGRAMMING_IN_LINNUX_MAIN
extern int generic_flash_program(int flash_index, const void* src_addr, int length);
#endif

#if (SUPPORT_BOARD_MANAGEMENT_UART)
   #include "board_management.h"
#endif

#include "vme_fifo_device_driver_virtual_uart.h"
//#include "udp_streamer_telnet_interace.h"
#include "base64.h"
#include "crc32.h"
#include "easyzlib.h"

//#include "tcl_new_procs.h"
#ifdef 	MSGDMA_0_CSR_BASE
		#include "dma_and_udp_controller.h"
		#include "msgdma_encapsulator.h"
		#include "descriptor_ram_encapsulator.h"

		extern msgdma::msgdma_mm_to_st_encapsulator msgdma0;
		extern msgdma::msgdma_mm_to_mm_encapsulator msgdma_mm_to_mm_0;
		extern msgdma::msgdma_mm_to_st_encapsulator msgdma1;
		extern msgdma::msgdma_mm_to_mm_encapsulator msgdma_mm_to_mm_1;

		extern smartbuf::smart_buffer_repository dma_smart_buffers;
		extern dmaudpctrl::dma_and_udp_controller dma_and_udp_controller_inst;
		extern descram::descriptor_ram_encapsulator dmadescriptor_ram;

#endif

#include "sysh_parser.h"

alt_u32 get_configuration_settings() {
#ifdef BOOT_LOADER_PARAM_PIO_ADDRESS_BASE
	return (IORD_ALTERA_AVALON_PIO_DATA(BOOT_LOADER_PARAM_PIO_ADDRESS_BASE));
#else
	return 0;
#endif
}
int need_to_load_fallback_image() {
    #ifdef BOOT_LOADER_PARAM_PIO_ADDRESS_BASE
	 return ((get_configuration_settings() & (1 << USE_FALLBACK_IMAGE_BIT)) != 0);
#else
	return 0;
#endif
}

 extern syshparser::sysh_parser system_h_parser;
extern std::string get_software_version();
extern std::string get_hardware_version();
extern std::string do_custom_command(std::string& input_str_from_external_func, int is_called_from_tcl_script, LINNUX_COMAND_TYPES calling_command_type, int* command_found = NULL);

int do_not_start_prbs_generator_0 = 1;


int linnux_profiling_enabled = LINNUX_ENABLE_PROFILING;

#define outp(x) if (((!is_called_from_tcl_script) && (calling_command_type == LINNUX_IS_A_CONSOLE_COMMAND)) \
		              || (is_called_from_tcl_script && print_messages_even_when_in_tcl_shell) || we_are_in_deep_debug_mode) { \
		        out_to_all_streams(x); \
	         };
#define outpc(x) if  ((((!is_called_from_tcl_script) || print_messages_even_when_in_tcl_shell) && verbose_jtag_debug_mode) || we_are_in_deep_debug_mode) { outp(x); };
//#define outprintf(format_str, args...) { char *__outprintf__tmpbuf=NULL; int __outprintf__error_code = my_trio_asprintf(&__outprintf__tmpbuf,format_str,args); if (__outprintf__error_code >= 0) { outp(__outprintf__tmpbuf); my_mem_free(__outprintf__tmpbuf);}};
#define outprintf(format_str, args...) do { char __outprintf__tmpbuf[4096]; snprintf(__outprintf__tmpbuf,4000,format_str,args); outp(__outprintf__tmpbuf);} while(0)


//these statements are unsafe within loops because a "continue" statement will cause the inner "while(0)" to continue;
#define profile_and_record_unsafe_for_loops(ostr,x) do {  if (!linnux_profiling_enabled) { x; } else { \
                                   unsigned long long ____time_spent = profile(x); \
                                   ostr << "Statement (" << #x << ") in (" << __FILE__ << ") and line (" << __LINE__ << ") Took:" << ____time_spent << " cycles, which is: " << get_timestamp_diff_in_usec(____time_spent) << " usec" << std::endl;\
                               }} while (0)

//these statements are unsafe within loops because a "continue" statement will cause the inner "while(0)" to continue;
#define profile_and_print_unsafe_for_loops(x) do {  if (!linnux_profiling_enabled) { x; } else { \
                                   unsigned long long ____time_spent = profile(x); \
                                   outp("Statement (" << #x << ") in (" << __FILE__ << ") and line (" << __LINE__ << ") Took:" << ____time_spent << " cycles, which is: " << get_timestamp_diff_in_usec(____time_spent) << " usec" << std::endl;);\
                               }} while (0)

#define fifo_u(x) do { if (DEBUG_FIFO_AND_GP_FIFO_ACQUISITION) { x; } } while(0)

static unsigned long test_udp_packet[16] = {
	  	0x00800010,
	//  0x10000080,
		0x12345678,
		0xABCDEF01,
		0x11223344,
		0x55667788,
		0x09304859,
		0x48395024,
		0x94385942,
		0x98495864,
		0x91938548,
		0x38940193,
		0x84937853,
		0x89308528,
		0x93854902,
		0x89578239,
		0x93854783
};


using namespace std;
stringstream myostream;
stringstream c_myostream;
stringstream dut_proc_myostream;
stringstream device_monitor_myostream;

extern LINNUX_CONSOLE_STRING_DESCS_TYPE linnux_console_string_descs;
extern altera_pio_encapsulator nios_uart_enabled_word;
#ifdef PIO_RESET_AND_BOOTLOADER_REQUEST_BASE
      extern altera_pio_encapsulator reset_and_bootloader_request;
#endif
extern fmc_present_encapsulator fmc_present_inst;
extern board_mgmt_encapsulator board_mgmt_inst;
extern uart_register_file *top_level_uart_regfile;
extern uart_regfile_repository_class uart_regfile_repository;
extern vector<unsigned long>* binary_response;
extern std::vector<fmc_encapsulator> fmc_inst;
extern card_configuration_encapsulator card_configuration;
extern telnet_process_object *linnux_main_telnet_inst;

volatile int button_irq_edge_capture = 0;
volatile int button_irq_edge_capture_raw = 0;
int sjtol_stop_has_been_requested = 0;
int tcl_script_stop_has_been_requested = 0;
int force_empty_sjtol_function = 0;
int force_eyed_test_mode = 0;
int print_messages_even_when_in_tcl_shell = 0;
int enable_semaphore_information_logging = ENABLE_SEMAPHORE_LOGGING_DEFAULT;
unsigned int enable_ucos_statistics_gathering = ENABLE_UCOS_STATISTICS_GATHERING;
int verbose_jtag_debug_mode = ENTER_VERBOSE_MODE_ON_STARTUP;
int we_are_in_control_verbose_mode = 0;

int linnux_is_in_tcl_mode = 0;
unsigned int tcp_ip_services_to_shutdown = 0;
unsigned int tcp_ip_rx_buffer_error_simulation = 0;
int linnux_ftp_debug = 0;
unsigned int linnux_print_task_statistics = LINNUX_PRINT_TASK_STATISTICS_DEFAULT;
unsigned int print_packet_log = 0;
unsigned int linnux_printf_ucos_diag = 0;
unsigned int serious_network_event_has_occured = 0;
unsigned int use_network_watchdog_task = 1;
unsigned int task_to_delete_please = 0;
unsigned int req_network_watchdog_to_delete_task = 0;
unsigned int enable_deep_packet_stats = 0;
int enable_auto_logfile_generation = DEFAULT_AUTO_LOGFILE_ENABLE;
extern unsigned char board_mac_addr[6];
int memory_error_inform_only  = 0;
int put_telnet_in_a_safe_state= 0;
int put_http_in_a_safe_state  = 0;
int put_ftp_in_a_safe_state   = 0;
int we_are_in_deep_debug_mode = 0;
int we_are_in_ethernet_quiet_mode = 1;

string tcl_script_file_to_load_before_BER_func_in_SJTOL;
string tcl_proc_name_run_before_BER_func_in_SJTOL;
int tcl_script_registered_as_before_BER_func = 0;

std::string tcl_proc_name_for_DUT_diag;
std::string tcl_script_file_to_load_for_DUT_diag_proc;
int tcl_script_registered_DUT_diag_func = 0;

std::map<unsigned,std::string> stored_commands;

#ifdef LINNUX_TEST_RX_BUF_ERROR
int allow_packet_buffer_addition = 1;
#else
int allow_packet_buffer_addition = 0;
#endif

log_file_encapsulator auto_log_file;
log_file_encapsulator manual_log_file;


/* Button pio functions */

/*
 Some simple functions to:
 1.  Define an interrupt handler function.
 2.  Register this handler in the system.
 */

/*******************************************************************
 * static void handle_button_interrupts( void* context, alt_u32 id)*
 *                                                                 *
 * Handle interrupts from the buttons.                             *
 * This interrupt event is triggered by a button/switch press.     *
 * This handler sets *context to the value read from the button    *
 * edge capture register.  The button edge capture register        *
 * is then cleared and normal program execution resumes.           *
 * The value stored in *context is used to control program flow    *
 * in the rest of this program's routines.                         *
 *                                                                 *
 * Provision is made here for systems that might have either the   *
 * legacy or enhanced interrupt API active, or for the Nios II IDE *
 * which does not support enhanced interrupts. For systems created *
 * using the Nios II softawre build tools, the enhanced API is     *
 * recommended for new designs.                                    *
 ******************************************************************/


void print_memory_usage()
{

	//mallinfo returns a structure describing the current state of memory allocation.
	//The structure is defined in malloc.h.
	//The following fields are defined:
	//arena is the total amount of space in the heap;
	//ordblks is the number of chunks which are not in use;
	//uordblks is the total amount of space allocated by malloc;
	//fordblks is the total amount of space not in use;
	//keepcost is the size of the top most memory block.


	struct mallinfo mallinfo_inst = mallinfo();
	out_to_all_streams("\n******************************\n");
	out_to_all_streams("\n*    Memory Usage Summary    *\n");
	out_to_all_streams("\n******************************\n");
	out_to_all_streams("total amount of space in the heap:         " << mallinfo_inst.arena << endl);
	out_to_all_streams("number of chunks which are not in use:     " << mallinfo_inst.ordblks << endl);
	out_to_all_streams("total amount of space allocated by malloc: " << mallinfo_inst.uordblks << endl);
	out_to_all_streams("total amount of space not in use:          " << mallinfo_inst.fordblks << endl);
	out_to_all_streams("size of the top most memory block:         " << mallinfo_inst.keepcost << endl);

	malloc_stats();

}



//#ifdef PIO_BUTTON_BASE

#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
static void handle_button_interrupts(void* context)
#else
static void handle_button_interrupts(void* context, alt_u32 id)
#endif
{
//	/* Cast context to edge_capture's type. It is important that this be
//	 * declared volatile to avoid unwanted compiler optimization.
//	 */
//	volatile int* edge_capture_ptr = (volatile int*) context;
//	/* Store the value in the Button's edge capture register in *context. */
//	*edge_capture_ptr = IORD_ALTERA_AVALON_PIO_EDGE_CAP(PIO_BUTTON_BASE);
//	/* Reset the Button's edge capture register. */
//	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(PIO_BUTTON_BASE, 0);
//
//	/*
//	 * Read the PIO to delay ISR exit. This is done to prevent a spurious
//	 * interrupt in systems with high processor -> pio latency and fast
//	 * interrupts.
//	 */
//	IORD_ALTERA_AVALON_PIO_EDGE_CAP(PIO_BUTTON_BASE);
//	button_irq_edge_capture = button_irq_edge_capture | button_irq_edge_capture_raw;
//	do_interrupt_critical_operations();
//	display_interrupt_reg_on_leds();
}

/* Initialize the button_pio. */

static void init_button_pio()
{
//	/* Recast the edge_capture pointer to match the alt_irq_register() function
//	 * prototype. */
//	void* edge_capture_ptr = (void*) &button_irq_edge_capture_raw;
//	/* Enable all 4 button interrupts. */
//	IOWR_ALTERA_AVALON_PIO_IRQ_MASK(PIO_BUTTON_BASE, 0xf);
//	/* Reset the edge capture register. */
//	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(PIO_BUTTON_BASE, 0x0);
//	/* Register the interrupt handler. */
//#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
//	alt_ic_isr_register(PIO_BUTTON_IRQ_INTERRUPT_CONTROLLER_ID, PIO_BUTTON_IRQ, handle_button_interrupts, edge_capture_ptr, 0x0);
//#else
//	alt_irq_register( PIO_BUTTON_IRQ, edge_capture_ptr,
//			handle_button_interrupts);
//#endif
}
//#endif /* PIO_BUTTON_BASE */

linnux_menu_mapping_type linnux_main_menu_mapStringValues;
linnux_menu_mapping_type linnux_control_menu_mapStringValues;
jsonp_menu_mapping_type jsonp_menu_mapStringValues;


//==========================================================================================================================
//
//
// FIFO and Dual Port RAM Container Instantiations
//
//
//==========================================================================================================================



#ifdef LEGACY_ITEMS_HAVE_BEEN_INCLUDED_IN_SYSTEM
gp_fifo_encapsulator Input_FIFO_Container(
		LEGACY_ITEMS_0_INPUT_SIGNAL_FIFO_READ_DATA_BASE,
		LEGACY_ITEMS_0_INPUT_SIGNAL_FIFO_FLAGS_BASE,
		LEGACY_ITEMS_0_INPUT_SIGNAL_FIFO_CONTROL_BASE,
		INPUT_SIGNAL_FIFO_DATA_MASK,
		NUM_OF_FIFO_VALUES_IN_INPUT_SIGNAL_FIFO,
		"Input_FIFO");

gp_fifo_encapsulator Output_FIFO_Container(
		LEGACY_ITEMS_0_OUTPUT_SIGNAL_FIFO_READ_DATA_BASE,
		LEGACY_ITEMS_0_OUTPUT_SIGNAL_FIFO_FLAGS_BASE,
		LEGACY_ITEMS_0_OUTPUT_SIGNAL_FIFO_CONTROL_BASE,
		OUTPUT_SIGNAL_FIFO_DATA_MASK,
		NUM_OF_FIFO_VALUES_IN_OUTPUT_SIGNAL_FIFO,
		"Output_FIFO",
		OUTPUT_FIFO_LSB_INDEX,
		OUTPUT_FIFO_MSB_INDEX);

correlation_fifo_class Corr_FIFO_Container(
		LEGACY_ITEMS_0_CORR_FIFO_READ_DATA_BASE,
		LEGACY_ITEMS_0_CORR_FIFO_FLAGS_BASE,
		LEGACY_ITEMS_0_CORR_FIFO_CONTROL_BASE,
		CORR_FIFO_DATA_MASK,
		NUM_OF_FIFO_VALUES_IN_CORR_FIFO,
		CORR_FIFO_DATA_SELECT_REG_ADDR,
		CORR_FIFO_DATA_SELECT_BIT_NUM,
		CORR_FIFO_TRANSPOSE_SYMBOLS_BIT_NUM_VAL,
		CORR_FIFO_TRANSPOSE_SYMBOLS,
		"CORR_FIFO"
		);

EyeD_FIFO_Access_Container EyeD_FIFO_Container(
		LEGACY_ITEMS_0_BETTER_EYED_FIFO_READ_DATA_BASE,
		LEGACY_ITEMS_0_BETTER_EYED_FIFO_FLAGS_BASE,
		LEGACY_ITEMS_0_BETTER_EYED_FIFO_CONTROL_BASE,
		INPUT_EYED_FIFO_DATA_MASK,
		NUM_OF_FIFO_VALUES_IN_INPUT_EYED_FIFO,
		LEGACY_ITEMS_0_BETTER_EYED_CONTROLLER_0_BASE,
		EYED_SYMBOL_COUNT_LIMIT_REG_ADDR,
		EYED_SAMPLE_COUNT_LIMIT_REG_ADDR,
		EYED_TIMEOUT_TIME,
		EYED_MAX_NUM_SAMPLES_PER_BLOCK,
		EYED_NUM_SIGNAL_LEVELS,
		EYED_TRIGGER_SEL_AND_SEQ_DET_REG_ADDR,
		EYED_TRIGGER_SEL_MASK,
		"EYED_FIFO");

dual_port_ram_container input_bit_pattern_dual_port_ram("bit_pattern_RAM",
		MAX_NUM_OF_32BIT_VALUES_IN_PATTERN_RAM,
		LEGACY_ITEMS_0_PATTERN_GEN_DUAL_PORT_64K_RAM_BASE,
		PATGEN_RAM_ADDR_MIN_REG_ADDR,
		PATGEN_RAM_ADDR_MAX_REG_ADDR);

dual_port_ram_container BERC_bit_pattern_dual_port_ram(
		"BERC_bit_pattern_RAM",
		MAX_NUM_OF_32BIT_VALUES_IN_PATTERN_RAM,
		LEGACY_ITEMS_0_BERC_PATTERN_GEN_DUAL_PORT_64K_RAM_BASE,
		PATGEN_RAM_ADDR_MIN_REG_ADDR,
		PATGEN_RAM_ADDR_MAX_REG_ADDR);
#endif

#ifdef MEMORY_COMM_DUAL_PORT_RAM_BASE
dual_port_ram_container DUT_GP_dual_port_ram(
		"memory_comm_dual_port_ram",
		MAX_NUM_OF_32BIT_VALUES_IN_DUT_GP_DUAL_PORT_RAM_0,
		MEMORY_COMM_DUAL_PORT_RAM_BASE,
		UINT_MAX,
		UINT_MAX);

dual_port_memory_comm_encapsulator dut_proc_cmd_communicator(
		&DUT_GP_dual_port_ram,
		SLAVE_MEMORY_COMM_REGION_BASE_OFFSET,
		SLAVE_MEMORY_COMM_IS_ALIVE_MAGIC_WORD,
		MAX_NUM_OF_32BIT_VALUES_IN_SLAVE_MEMORY_COMM_RESPONSE_STR,
		MAX_ALLOWED_WAIT_FOR_SLAVE_MEM_COMM_COMMAND_RESPONSE_IN_SECS
	);
#endif
#ifdef UDP_INSERTER_0_BASE

std::vector<udp_streamer_telnet_interace> udp_streamers(NUM_OF_UDP_STREAMING_CHAINS);
#endif

//==========================================================================================================================

//
//
// Matlab Curve Generator for TCL
//
//
//==========================================================================================================================

matlab_curve_linetype_generator matlab_curve_linetype_generator_for_tcl;



//==========================================================================================================================
//
//
// SPI encapsulator
//
//
//==========================================================================================================================

/*
spi_encapsulator spi_master_inst(ADC_SPI_MASTER_BASE);
spi_encapsulator spi_test_slave_inst(SPI_TEST_SLAVE_BASE);

altera_pio_encapsulator adc_aux_control(SPARTAN_ADC_SPI_AUX_CTRL_BASE);
*/

led_encapsulator user_leds(PIO_LEDS_BASE);

/*
std::vector<adc12eu050_controller> adc_controller_vec(NUM_OF_FMC_ADCS,&spi_master_inst);
*/

json::Value motherboard_json_object(json::object());
json::Value board_mgmt_json_object(json::object());
json::Value total_json_object(json::object());
json::Value maxv_json_object(json::object());
json::Value fmc_json_object[NUM_OF_FMCS];
json::Value system_h_json_object(json::object());

//==========================================================================================================================
//
//
// FIFO and Dual Port RAM Container Instantiations End
//
//
//==========================================================================================================================

//==========================================================================================================================
//
//
// FIFO and Dual Port RAM Container Instantiations End
//
//
//==========================================================================================================================

//==========================================================================================================================
//
// Seven Segment Controller Instantiation
//
//==========================================================================================================================


//seven_segment_encapsulator seven_segment_encapsulator_inst(SEVEN_SEG_DATA_REG_ADDR, SEVEN_SEG_DATA_MASK, SEVEN_SEG_NUM_DIGITS, SEVEN_SEG_INITIAL_VALUE);

//===============================================================================================


void write_decimal_to_7seg_encapsulator(unsigned int the_decimal)
{
	//seven_segment_encapsulator_inst.write_as_decimal_number(the_decimal);
}
//===============================================================================================

void initial_message()
{
	out_to_all_streams("\n\n**************************************************\n");
	out_to_all_streams(    "*        Griffin Web Server                         *\n");
	out_to_all_streams(    "*        Brought to you by Yair Linn             *\n");
	out_to_all_streams(    "**************************************************\n");
	out_to_all_streams("\nPress H for help\n");
}

extern std::vector<multi_stream_packetizer*> multi_stream_packetizer_vector;
extern std::vector<gp_fifo_encapsulator*> fifo_pointer_vector;
extern vme_fifo_device_driver_virtual_uart * vme_fifo_ptr;
extern std::vector<flow_through_fifo_encapsulator*> VME_FIFO_Vector;

extern gp_fifo_encapsulator GP_FIFO_0_Container;
extern gp_fifo_encapsulator GP_FIFO_1_Container;

CBaseConverter binary_base_converter(2);


//==========================================================================================================================
//
// Interface to JIM TCL
//
//==========================================================================================================================


Jim_Interp* Jim_interactive_TCL_shell;
Jim_Interp* Jim_persistent_autonomous_TCL_shell;
Jim_Interp* Jim_persistent_autonomous_TCL_shell_for_DUT_diag;




unsigned long active_led=0;
unsigned long active_toggle_led=0;
unsigned long new_command_toggle_led=0;
unsigned long tcl_active_led=0;
unsigned long jtag_disconnected_led=0;
unsigned long software_activity_toggle_led=0;
unsigned long general_linnux_active_led = 0;
int jtag_has_been_disconnected=0;

#define get_user_leds ((jtag_disconnected_led << 4) + (active_toggle_led << 3) + (active_led << 2) +  (new_command_toggle_led << 1) + (software_activity_toggle_led<<0))

//#define get_user_leds ((jtag_disconnected_led << 4) + (active_toggle_led << 3) + (active_led << 2) +  (new_command_toggle_led << 1) + (tcl_active_led << 0) + (software_activity_toggle_led<<0) + (general_linnux_active_led<<2))

alt_alarm jtag_check_alarm;
alt_alarm activity_check_alarm;

void reconnect_jtag() {
           fflush(NULL); //flush all cstdio streams

           clearerr(stdout);
           clearerr(stdin);
           clearerr(stderr);

           cin.clear();
           cout.clear();
		   cout.flush();
		   cout.sync_with_stdio();
		   cin.sync_with_stdio();
		   cin.clear();
		   cout.clear();
		   cout.flush();

}

void smtp_hello_world()
{
	safe_print(printf ("Now starting send mail...\n"));
	if (send_mail("smtp.linnux.ca", "yairlinn@linnux.ca", "yairlinn@gmail.com",
			"Hello World!",
			"yairlinn@gmail.com",
			"Hello World") != 0)
		{ safe_print(printf("Message send failed!\n"));}
	else
		{ safe_print(printf("Message sent successfully!\n"));}

}



alt_u32 check_if_jtag_has_been_disconnected (void* context)
{
	int jtag_is_now_connected;
	ioctl(STDOUT_FILENO,TIOCGCONNECTED,&jtag_is_now_connected);
	if (jtag_is_now_connected)
	{
		if (jtag_has_been_disconnected)
		{
			 alt_io_redirect(ALT_STDOUT, ALT_STDIN, ALT_STDERR);
//			cin.clear();
//			cout.clear();
//			out_to_all_streams("[COUT]: Cout and Cin have been reset due to jtag disconnect and reconnect\n");
//			outprintf ("[PRINTF]: Cout and Cin have been reset due to jtag disconnect and reconnect\n");

			 fflush(NULL); //flush all cstdio streams

			 clearerr(stdout);
			 clearerr(stdin);
			 clearerr(stderr);

			 cin.clear();
		     cout.clear();
		     cout.flush();
		     cout.sync_with_stdio();
		     cin.sync_with_stdio();
		     cin.clear();
		     cout.clear();
		     cout.flush();

			jtag_has_been_disconnected = 0;
		}
	} else
	{
		jtag_has_been_disconnected = 1;
		alt_io_redirect("/dev/null", "/dev/null", "/dev/null");
	}
	jtag_disconnected_led = jtag_has_been_disconnected;
	user_leds.write(get_user_leds);
	return(LINNUX_JTAG_CHECK_ALARM_NUM_SECONDS*alt_ticks_per_second()); //return number of ticks until next alarm
}


alt_u32 software_activity_alarm_handle (void* context)
{
	software_activity_toggle_led = 1-software_activity_toggle_led;
	user_leds.write(get_user_leds);
	return(LINNUX_ACTIVITY_CHECK_ALARM_NUM_SECONDS*alt_ticks_per_second()); //return number of ticks until next alarm
}

#include "jim_linnux_main_procs.inc"


int SD_card_is_detected() {
	unsigned long long sd_card_det = top_level_uart_regfile->read_status_reg(SD_DETECT_STATUS_REG_ADDR);
    return ((sd_card_det & 0x1) == 0); //bit is active low
}

void enable_simult_fifo_capture()
{
	//top_level_uart_regfile->write_control_reg(SIMULT_FIFO_CAPTURE_REG_ADDR,1);
	//usleep(WAIT_TIME_UNTIL_UART_REGISTER_WRITE_HAS_SURELY_PASSED_IN_US);
}
void disable_simult_fifo_capture()
{
	//top_level_uart_regfile->write_control_reg(SIMULT_FIFO_CAPTURE_REG_ADDR,0);
	//usleep(WAIT_TIME_UNTIL_UART_REGISTER_WRITE_HAS_SURELY_PASSED_IN_US);
}

int enable_generator_0_for_udp_stream_0(void *data_ptr) {
	//top_level_uart_regfile->write_control_reg(UDP_PACKET_EMULATOR_FOR_GENERATOR_0_ENABLE_REG_ADDR,1);
	return (0);
}

int disable_generator_0_for_udp_stream_0(void *data_ptr) {
	//top_level_uart_regfile->write_control_reg(UDP_PACKET_EMULATOR_FOR_GENERATOR_0_ENABLE_REG_ADDR,0);
	return (0);
}


int enable_generator_1_for_udp_stream_1(void *data_ptr) {
	//top_level_uart_regfile->write_control_reg(UDP_PACKET_EMULATOR_FOR_GENERATOR_1_ENABLE_REG_ADDR,0xFFFF);
	return (0);
}

int disable_generator_1_for_udp_stream_1(void *data_ptr) {
	//top_level_uart_regfile->write_control_reg(UDP_PACKET_EMULATOR_FOR_GENERATOR_1_ENABLE_REG_ADDR,0);
	return (0);
}

int enable_generator_2_for_udp_stream_2(void *data_ptr) {
	//top_level_uart_regfile->write_control_reg(UDP_PACKET_EMULATOR_FOR_GENERATOR_2_ENABLE_REG_ADDR,1);
	return (0);
}

int disable_generator_2_for_udp_stream_2(void *data_ptr) {
	//top_level_uart_regfile->write_control_reg(UDP_PACKET_EMULATOR_FOR_GENERATOR_2_ENABLE_REG_ADDR,0);
	return (0);
}

int enable_generator_3_for_udp_stream_3(void *data_ptr) {
	//top_level_uart_regfile->write_control_reg(UDP_PACKET_EMULATOR_FOR_GENERATOR_3_ENABLE_REG_ADDR,1);
	return (0);
}

int disable_generator_3_for_udp_stream_3(void *data_ptr) {
	//top_level_uart_regfile->write_control_reg(UDP_PACKET_EMULATOR_FOR_GENERATOR_3_ENABLE_REG_ADDR,0);
	return (0);
}


std::string tcl_DUT_diag_cpp_wrapper_func()
{
	/* working with:
	 *
	 //std::string tcl_proc_name_for_DUT_diag;
     //std::string tcl_script_file_to_load_for_DUT_diag_proc;
     //int tcl_script_registered_DUT_diag_func = 0;
	*/

    std::string result_str="";
    int retcode;
	ostringstream command_line_str;

	if (tcl_script_registered_DUT_diag_func)
	{
		command_line_str << tcl_proc_name_for_DUT_diag;
		retcode = Jim_Eval(Jim_persistent_autonomous_TCL_shell_for_DUT_diag, command_line_str.str().c_str());
		if (retcode == JIM_ERR)
		{
			        out_to_all_streams("Error in TCL function " << tcl_proc_name_for_DUT_diag << " for DUT diag\n");
		#ifdef LINNUX_USE_JIM_51
					Jim_PrintErrorMessage(Jim_persistent_autonomous_TCL_shell_for_DUT_diag);
		#else
					Jim_MakeErrorMessage(Jim_persistent_autonomous_TCL_shell_for_DUT_diag);
		#endif
		} else {
			result_str = std::string(Jim_GetString(Jim_GetResult(Jim_persistent_autonomous_TCL_shell_for_DUT_diag),NULL));
		}
		return (result_str);
	}
	else
	{
		result_str = "Warning: no TCL DUT diag proc registered\n";
	    out_to_all_streams(result_str);
		return (result_str);
	}
}

void init_tcl_interps () {
#ifdef LINNUX_USE_JIM_51
	Jim_InitEmbedded();
#endif
	/* Create an interpreter */
	Jim_interactive_TCL_shell = Jim_CreateInterp();
	/* Add all the Jim core commands */
	Jim_RegisterCoreCommands(Jim_interactive_TCL_shell);
	//Jim_CreateCommand(Jim_interactive_TCL_shell, "ylcmd", exec_linnux_command_from_jim_tcl, NULL, NULL);
	register_yl_commands_tcl(Jim_interactive_TCL_shell);


	Jim_persistent_autonomous_TCL_shell= Jim_CreateInterp();
	Jim_RegisterCoreCommands(Jim_persistent_autonomous_TCL_shell);
	register_yl_commands_tcl(Jim_persistent_autonomous_TCL_shell);

	Jim_persistent_autonomous_TCL_shell_for_DUT_diag = Jim_CreateInterp();
	Jim_RegisterCoreCommands(Jim_persistent_autonomous_TCL_shell_for_DUT_diag);
	register_yl_commands_tcl(Jim_persistent_autonomous_TCL_shell_for_DUT_diag);
}


void get_maxv_version_numbers(unsigned& year, unsigned& month,unsigned& day,unsigned& hour ) {
	        if (uart_regfile_repository.uart_exists("MAXV")) {
			    	      int err = 0;
			    	      year = uart_regfile_repository.named_read_control_reg("MAXV",0,&err);
			    	      month = uart_regfile_repository.named_read_control_reg("MAXV",1,&err);
			    	      day   = uart_regfile_repository.named_read_control_reg("MAXV",2,&err);
			    	      hour = uart_regfile_repository.named_read_control_reg("MAXV",3,&err);
			    	   } else {
			    		   year = month = day = hour = 0;

			    	   }
}

std::string get_maxv_version_string() {
	      ostringstream ostr;
	      unsigned year,month,day,hour;
          get_maxv_version_numbers(year,month,day,hour);
		  ostr << std::hex << hour << ":00 " << day << "/" << month << "/" << year << std::dec;
		  return ostr.str();
}



void update_json_motherboard_object() {
	motherboard_json_object.set_key("SoftwareVersion" , json::Value(get_software_version()));
	motherboard_json_object.set_key("HardwareVersion" , json::Value(get_hardware_version()));
	motherboard_json_object.set_key("CardAssignedNum" , json::Value(card_configuration.get_card_assigned_number()));
	motherboard_json_object.set_key("CardHardwareRev" , json::Value(card_configuration.get_card_revision()));
	motherboard_json_object.set_key("CardIsMaster"    , json::Value(card_configuration.is_master()));
	motherboard_json_object.set_key("CardIsMaster"    , json::Value(card_configuration.is_slave()));
	std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
	TrimSpaces(timestamp_str);
	motherboard_json_object.set_key("DateAndTimeWhenJsonGenerated", json::Value(timestamp_str));
	std::ostringstream ostr;
	ostr << os_critical_low_level_system_timestamp();
	motherboard_json_object.set_key("TimestampWhenJsonGenerated", json::Value(ostr.str()));
	motherboard_json_object.set_key("use_dhcp"                  , json::Value(card_configuration.GetInteger("network", "use_dhcp", DEFAULT_INI_FILE_USE_DHCP))) ;
	motherboard_json_object.set_key("use_autonegotiation"       , json::Value(card_configuration.GetInteger("network", "use_autonegotiation", DEFAULT_INI_USE_AUTONEGOTIATION))) ;
	motherboard_json_object.set_key("default_ethernet_speed_mbps"       , json::Value(card_configuration.GetInteger("network", "default_ethernet_speed_mbps", DEFAULT_INI_DEFAULT_ETHERNET_SPEED_MBPS))) ;
	motherboard_json_object.set_key("default_ethernet_duplex"       , json::Value(card_configuration.GetInteger("network", "default_ethernet_duplex", DEFAULT_INI_DEFAULT_ETHERNET_DUPLEX))) ;
	motherboard_json_object.set_key("default_static_ip"         , json::Value(card_configuration.Get("network", "default_static_ip", DEFAULT_INI_FILE_DEFAULT_STATIC_IP)));
	motherboard_json_object.set_key("default_gateway"           , json::Value(card_configuration.Get("network", "gateway", DEFAULT_INI_FILE_DEFAULT_GATEWAY)));
	motherboard_json_object.set_key("default_mask"              , json::Value(card_configuration.Get("network", "mask", DEFAULT_INI_FILE_DEFAULT_MASK)));
	motherboard_json_object.set_key("ntp_server"                , json::Value(card_configuration.Get("network", "ntp_server", DEFAULT_INI_FILE_NTP_SERVER_IP_ADDRESS))) ;
	motherboard_json_object.set_key("project_name"              , json::Value(card_configuration.Get("project", "project_name", DEFAULT_INI_FILE_PROJECT_NAME) )) ;
	motherboard_json_object.set_key("project_role"              , json::Value(card_configuration.Get("project", "project_role", DEFAULT_INI_FILE_PROJECT_ROLE)) ) ;
	motherboard_json_object.set_key("physical_card"             , json::Value(LINNUX_PHYSICAL_CARD_DESCRPTION));
	motherboard_json_object.set_key("mac_address"               ,json::Value(get_mac_addr_string_from_char_array(board_mac_addr)));
	motherboard_json_object.set_key("is_fallback_image"         ,json::Value(need_to_load_fallback_image()));
}


void update_json_system_h_object() {
	static int is_firsttime = 1;
	if (is_firsttime) {
		is_firsttime  = 0;
		std::map<std::string,std::string>* system_h_parser_value_map_ptr = get_system_h_parser_value_map_ptr();
		system_h_parser.set_value_map(system_h_parser_value_map_ptr);
	    //system_h_parser.parse_into_value_map(system_h_str);
		system_h_parser.convert_to_json((void *) &system_h_json_object);
		safe_print(printf("\nFinished parsing system.h ...\n"));

	}
}


void update_maxv_json_object() {
	maxv_json_object.set_key("HardwareVersion", json::Value(get_maxv_version_string()));
}

void update_json_fmc_object(unsigned long fmc_num) {
	if (fmc_num >= NUM_OF_FMCS) {
		std::cout << "Error fmc_num =  " << fmc_num << "but max can be only " << (NUM_OF_FMCS - 1) << "\n"; 	std::cout.flush();
		return;
	}
	fmc_json_object[fmc_num] = json::object();
    //std::cout << "cp1 in update_json_fmc_object fmc_num =  " << fmc_num << "\n"; 	std::cout.flush();

    fmc_json_object[fmc_num].set_key("SoftwareVersion" ,json::Value(fmc_inst.at(fmc_num).get_software_version()));

	//std::cout << "cp2 in update_json_fmc_object fmc_num =  " << fmc_num <<"\n";	std::cout.flush();

	fmc_json_object[fmc_num].set_key("HardwareVersion", json::Value(fmc_inst.at(fmc_num).get_hardware_version()));

	//std::cout << "cp3 in update_json_fmc_object fmc_num =  " << fmc_num << "\n"; 	std::cout.flush();

	fmc_json_object[fmc_num].set_key("ProjectName" , json::Value(fmc_inst.at(fmc_num).get_project_name()));

	//std::cout << "cp4 in update_json_fmc_object fmc_num =  " << fmc_num << "\n";   	std::cout.flush();

	fmc_json_object[fmc_num].set_key("FMC_Name" , json::Value(fmc_inst.at(fmc_num).get_fmc_name()));
	fmc_json_object[fmc_num].set_key("DesiredFMC" ,json::Value(fmc_inst.at(fmc_num).get_desired_fmc()));
	fmc_json_object[fmc_num].set_key("ActualFMC" , json::Value(fmc_inst.at(fmc_num).get_actual_fmc()));
	fmc_json_object[fmc_num].set_key("ConnectedDevices" ,json::Value(fmc_inst.at(fmc_num).get_devices()));
	//std::cout << "cp5 in update_json_fmc_object fmc_num =  " << fmc_num << "\n"; 	std::cout.flush();
	std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
	TrimSpaces(timestamp_str);
	fmc_json_object[fmc_num].set_key("DateAndTimeWhenJsonGenerated", json::Value(timestamp_str));
	std::ostringstream ostr;
	ostr << os_critical_low_level_system_timestamp();
	fmc_json_object[fmc_num].set_key("TimestampWhenJsonGenerated", json::Value(ostr.str()));
}


void update_json_board_mgmt_object() {
		if (board_mgmt_inst.is_enabled()) {
			//std::cout << "cp1 in update_json_board_mgmt_object " << "\n"; 	std::cout.flush();

				board_mgmt_json_object.set_key("SoftwareVersion", json::Value(TrimSpacesFromString(board_mgmt_inst.get_software_version())));
			//	std::cout << "cp1 in update_json_board_mgmt_object " << "\n"; 	std::cout.flush();

				board_mgmt_json_object.set_key("HardwareVersion" , json::Value(TrimSpacesFromString(board_mgmt_inst.get_hardware_version())));
			//	std::cout << "cp2 in update_json_board_mgmt_object " << "\n"; 	std::cout.flush();

				board_mgmt_json_object.set_key("ProjectName" , json::Value(TrimSpacesFromString(board_mgmt_inst.get_project_name())));
			//	std::cout << "cp3 in update_json_board_mgmt_object " << "\n"; 	std::cout.flush();

				board_mgmt_json_object.set_key("ConnectedDevices" , json::Value(TrimSpacesFromString(board_mgmt_inst.get_devices())));
			//	std::cout << "cp5 in update_json_board_mgmt_object " << "\n"; 	std::cout.flush();

				board_mgmt_json_object.set_key("DeepStatus",board_mgmt_inst.get_json_status_object()); //this statement crashes the program
			//	std::cout << "cp6 in update_json_board_mgmt_object " << "\n"; 	std::cout.flush();

				//board_mgmt_json_object["DeepStatus"] =  json::Value(board_mgmt_inst.get_json_status_str()); //this statement crashes the program



				std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
				TrimSpaces(timestamp_str);
			//	std::cout << "cp7 in update_json_board_mgmt_object " << "\n"; 	std::cout.flush();

				board_mgmt_json_object.set_key("DateAndTimeWhenJsonGenerated",json::Value(timestamp_str));
				std::ostringstream ostr;
				ostr << os_critical_low_level_system_timestamp();
			//	std::cout << "cp8 in update_json_board_mgmt_object " << "\n"; 	std::cout.flush();

				board_mgmt_json_object.set_key("TimestampWhenJsonGenerated", json::Value(ostr.str()));
			//	std::cout << "cp9 in update_json_board_mgmt_object " << "\n"; 	std::cout.flush();

			//	 std::cout << "Exiting update_json_board_mgmt_object \n";
		}
		//std::cout.flush();

}


void update_total_json_object() {
	update_json_motherboard_object();
	update_json_system_h_object();
	update_maxv_json_object();
    if (board_mgmt_inst.is_enabled()) {
	   update_json_board_mgmt_object();
    }




    if (board_mgmt_inst.is_enabled()) {
    	total_json_object.set_key("BoardMgmt",board_mgmt_json_object);
    }

    /*
    json::Value ja(json::array());
      	for (int i = 0; i < NUM_OF_FMCS; i++) {
      		if (fmc_present_inst.is_enabled(i)) {
      		    	    update_json_fmc_object(i);
      		    	    //std::cout << "after update_json_fmc_object i =  " << i << "\n";    	std::cout.flush();
      		    	    ja.set_at(i,fmc_json_object[i]);
      		    	    // std::cout << "after  fmc_object_array.Insert i =  " << i << "\n";	std::cout.flush();
      		    	} else {
      		          ja.set_at(i,json::Value("FMC Not Enabled or Present"));
      		    	}
      	}

   	total_json_object.set_key("FMCs",ja);

   	*/

    for (int i = 0; i < NUM_OF_FMCS; i++) {
	             ostringstream ostr;
        	     ostr<<"FMC_" << i;
          		if (fmc_present_inst.is_enabled(i)) {

          		    	    update_json_fmc_object(i);
          		    	    //std::cout << "after update_json_fmc_object i =  " << i << "\n";    	std::cout.flush();
          		    	  total_json_object.set_key(ostr.str(),fmc_json_object[i]);
          		    	    // std::cout << "after  fmc_object_array.Insert i =  " << i << "\n";	std::cout.flush();
          		    	} else {
          		    		total_json_object.set_key(ostr.str(),json::Value("FMC Not Enabled or Present"));
          		    	}
          	}
    total_json_object.set_key("MAXV",maxv_json_object);
   	total_json_object.set_key("Motherboard",motherboard_json_object);
   	total_json_object.set_key("system_h",system_h_json_object);

}
std::string print_fifo_help_string(vector<gp_fifo_encapsulator*> fifo_ptr_vec)
{
	std::ostringstream ostr;
	ostr << "Fifo Legend\n";
	ostr << "===========\n";
	for (unsigned int i = 0; i < fifo_ptr_vec.size(); i++)
	{
		if (fifo_ptr_vec[i] != NULL) {
		ostr << "[" << i << "]: " << fifo_ptr_vec[i]->get_description() << "\n";
		} else {
			ostr << "[" << i << "]: Disabled \n";
		}
	}
	return ostr.str();
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// iniche diag support
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

char     local_record_diag_menu_in_stream_cbuf[CBUFLEN];

/* Generic IO structure that do_command() will be called with */
//struct GenericIO  std_io2   =  {  cbuf, std_out, 0, std_in   }  ;

std::ostringstream local_iniche_diag_str;
int global_is_called_from_tcl_script = 0; //aux variable for local_record_diag_menu_in_stream
LINNUX_COMAND_TYPES global_calling_command_type; //aux variable for local_record_diag_menu_in_stream


int local_record_diag_menu_in_stream (long id, char * outbuf, int len){
	//xprintf("[record_diag_menu_in_stream] %s",outbuf);
	if (outbuf)
	{
     int is_called_from_tcl_script = global_is_called_from_tcl_script;
     LINNUX_COMAND_TYPES calling_command_type = global_calling_command_type;
     outp(outbuf);
	 local_iniche_diag_str << outbuf;
	}
	return len;
}

struct GenericIO local_record_output_pio = { local_record_diag_menu_in_stream_cbuf, local_record_diag_menu_in_stream, 789, NULL};



std::string local_do_iniche_diag_command(std::string cmdstr, int is_called_from_tcl_script, LINNUX_COMAND_TYPES calling_command_type) {
	  global_is_called_from_tcl_script = is_called_from_tcl_script;
	  global_calling_command_type = calling_command_type;
      strncpy(local_record_diag_menu_in_stream_cbuf,cmdstr.c_str(),CBUFLEN-1);
      local_record_diag_menu_in_stream_cbuf[CBUFLEN-1]='\0'; //just in case
      local_iniche_diag_str.str("");
#ifdef IN_MENUS
      do_command(&local_record_output_pio);
#endif
      return local_iniche_diag_str.str();
}




/*******************************************************************************
 * int main()                                                                  *
 *                                                                             *
 ******************************************************************************/

void bedrock_linnux_main(void *pd)
{

	bedrock_linnux_main_context_class* bedrock_linnux_main_context_inst = (bedrock_linnux_main_context_class*) pd;
	reconnect_jtag();

	initial_message();


	init_tcl_interps();

	std::ifstream in_file;
	string testbench_desc_str;
	string sipo_str;
	string anticipated_sipo_val;
	string data_capt_ram_str;
	string anticipated_data_capt_ram_val;

	unsigned long command_argument1, command_argument2;
	string input_str;
	string catsd_filename_string;
	string current_str;
	string bitpattern_filename_string;
	string FIR_control_String;

	int num_args_received;

	//============================================================================
			//
			// Initialize menus and test dual port RAMs, display initial message
	//
	//============================================================================
	Menu_System_Initialize(linnux_main_menu_mapStringValues);
	Control_Menu_System_Initialize(linnux_control_menu_mapStringValues);
	JSONP_Menu_System_Initialize(jsonp_menu_mapStringValues);

	matlab_curve_linetype_generator_for_tcl.reset_curve_count();
	matlab_curve_linetype_generator_for_tcl.set_mode(MATLAB_CURVE_LINEGEN_MANUAL);
	matlab_curve_linetype_generator_for_tcl.set_increase_every(7, 4, 1);


	//============================================================================
	//
	// UDP Streamers init
	//
	//============================================================================
#ifdef UDP_INSERTER_0_BASE
	udp_streamers.at(0).set_udp_inserter_base(UDP_INSERTER_0_BASE);
	udp_streamers.at(1).set_udp_inserter_base(UDP_INSERTER_1_BASE);
	udp_streamers.at(2).set_udp_inserter_base(UDP_INSERTER_2_BASE);
	udp_streamers.at(3).set_udp_inserter_base(UDP_INSERTER_3_BASE);

	udp_streamers.at(0).set_generator_enable_func_pointer(enable_generator_0_for_udp_stream_0);
	udp_streamers.at(0).set_generator_disable_func_pointer(disable_generator_0_for_udp_stream_0);
	udp_streamers.at(1).set_generator_enable_func_pointer(enable_generator_1_for_udp_stream_1);
	udp_streamers.at(1).set_generator_disable_func_pointer(disable_generator_1_for_udp_stream_1);
	udp_streamers.at(2).set_generator_enable_func_pointer(enable_generator_2_for_udp_stream_2);
	udp_streamers.at(2).set_generator_disable_func_pointer(disable_generator_2_for_udp_stream_2);
	udp_streamers.at(3).set_generator_enable_func_pointer(enable_generator_3_for_udp_stream_3);
	udp_streamers.at(3).set_generator_disable_func_pointer(disable_generator_3_for_udp_stream_3);
#endif
	//============================================================================
	//
	// Initialize ADCs
	//
	//============================================================================

	//safe_print(std::cout << "HW Reset of all ADCs...\n");
	//
	//
	//
	//safe_print(std::cout << "Initializing ADCs...\n");
	//for (int i = 0; i < adc_controller_vec.size(); i++ ) {
	//	adc_controller_vec.at(i).set_slave_num(i);
	//	adc_controller_vec.at(i).init();
	//}
	//
	//safe_print(std::cout << "Finished initializing ADCs.\n");



	//============================================================================
	//
	// Menu Command Handling
	//
	//============================================================================

	linnux_remote_command_container *remote_command_container_inst = NULL;
	linnux_remote_command_container *initial_command_container_inst;


	initial_command_container_inst = new linnux_remote_command_container;
	initial_command_container_inst->set_command_string("tcl source linnux_init.tcl");
	initial_command_container_inst->set_command_type(LINNUX_IS_A_CONSOLE_COMMAND);
	initial_command_container_inst->set_erase_this_command(0);
	initial_command_container_inst->set_job_index(0);
	initial_command_container_inst->set_telnet_console_index(0);
	initial_command_container_inst->set_send_email_notification(0);
	initial_command_container_inst->set_telnet_console_index(0);
	initial_command_container_inst->set_telnet_job_index(0);

	char command_str[4096];
	string command_string;
	string original_input_str;
	string actual_redirect_filename;
	char cmd_filename[4096];
	vector<string> command_strings_from_file(0), tmp_command_strings_from_file(0);
	char cmd_str[4096];
	string argument_str;
	int argument_str_pos_start;
	int retcode;
	int be_quiet_for_this_command = 0;
	INT8U error_code;
	std::string result_string;
	unsigned long long start_timestamp, end_timestamp, delta_timestamp;
	double command_time_in_seconds;
	linnux_remote_command_response_container *command_response_record = NULL;
	/* Continue 0-ff counting loop. */
	ostringstream jim_tcl_retcode_str;
	ostringstream auto_log_filename;
	std::string execution_time_str, end_execution_time_str;

	int is_first_time = 1;
	ostringstream board_id_prompt, board_id_tcl_prompt;
	board_id_prompt << "linnux_board"<< get_linnux_board_id()<<"["<<TrimSpacesFromString(low_level_get_testbench_description())<<"]";
	board_id_tcl_prompt << board_id_prompt.str() << "[TCL]";

	reconnect_jtag(); //one last chance to reconnect jtag

	while (1)
	{
		if (linnux_is_in_tcl_mode)
		{
			if (!be_quiet_for_this_command) { out_to_all_streams("\n["<<board_id_tcl_prompt.str()<<"]>>>"); };
		}
		else
		{
			if (!be_quiet_for_this_command) { out_to_all_streams("\n["<<board_id_prompt.str()<<"]>>>"); };
		}
		send_myostream_to_ethernet_stdout();

		general_linnux_active_led = 0;

		if (remote_command_container_inst != NULL) {
			delete remote_command_container_inst;
			remote_command_container_inst = NULL;
		}

								if (is_first_time) {
									   is_first_time = 0;
									   remote_command_container_inst = initial_command_container_inst;
								} else {
									  remote_command_container_inst = get_new_command_for_linnux_from_cin_or_ethernet(bedrock_linnux_main_context_inst->get_mem_comm_ucos_vector_ptr());
								}
		unsigned long long total_time_for_this_command = profile(
								switch (remote_command_container_inst->get_command_type())
								{
								case LINNUX_IS_A_TCL_COMMAND    : be_quiet_for_this_command = 0;  break;
								case LINNUX_IS_A_YAIRL_COMMAND  : be_quiet_for_this_command = 0; break;
								case LINNUX_IS_A_CONSOLE_COMMAND: be_quiet_for_this_command = 0; break;
								case LINNUX_IS_A_SYSCON_COMMAND : be_quiet_for_this_command = !verbose_jtag_debug_mode;  break;
								case LINNUX_IS_A_TELNET_SYSCON_COMMAND : be_quiet_for_this_command = 1; break;
								default: safe_print(std::cout << "Error: Unknown command type [" << remote_command_container_inst->get_command_type() << "] for command (" << remote_command_container_inst->get_command_string() << ") !!!!" << endl); break;
								}

								binary_response = NULL; //just in case

								general_linnux_active_led = 1;

								original_input_str = remote_command_container_inst->get_command_string();
								if (!be_quiet_for_this_command) { out_to_all_streams("\n[linnux main] Executing: [" << TrimSpacesFromString(remote_command_container_inst->get_command_string()) << "] for job index: [" <<remote_command_container_inst->get_job_index() << "]" << " of type: [" << remote_command_container_inst->get_command_type() << "]"); };

								if (remote_command_container_inst->get_command_type() == LINNUX_IS_A_CONSOLE_COMMAND) {
									if (!be_quiet_for_this_command) { out_to_all_streams("\nFrom Telnet Console: [" << remote_command_container_inst->get_telnet_console_index() << "] with Telnet job index: [" << remote_command_container_inst->get_telnet_job_index() << "]"); };
								}

								if (!be_quiet_for_this_command) { out_to_all_streams(std::endl); };

								start_timestamp = os_critical_low_level_system_timestamp();
								auto_log_filename.str("");

								if (((remote_command_container_inst->get_command_type() == LINNUX_IS_A_YAIRL_COMMAND) || (remote_command_container_inst->get_command_type() == LINNUX_IS_A_TCL_COMMAND)) && enable_auto_logfile_generation)
								{
									if (auto_log_file.is_open())
									{
										auto_log_file.close();
									}
									auto_log_filename << std::string(LINNUX_AUTO_LOG_FILE_NAME_PREFIX) << string("log_file_for_job_") << remote_command_container_inst->get_job_index() << "_timestamp_"<< start_timestamp << ".txt";
									execution_time_str = string(get_current_time_and_date_as_string());
									if (auto_log_file.open_for_write(auto_log_filename.str()) != LINNUX_RETVAL_ERROR)
									{
										auto_log_file.write_str("###################################################################\n");
										auto_log_file.write_str("Log file for command:\n");
										auto_log_file.write_str(remote_command_container_inst->get_command_string());
										auto_log_file.write_str("\n");
										auto_log_file.write_str(string("Executed on: ").append(execution_time_str).append("\n"));
										auto_log_file.write_str("###################################################################\n");
									}
								}

								if (verbose_jtag_debug_mode) {
									if (!be_quiet_for_this_command) {
										safe_print(std::cout << "Got command string: " << original_input_str << std::endl);
									};
								}
								new_command_toggle_led = (1-new_command_toggle_led);
								user_leds.write (get_user_leds);

								if (original_input_str == "")
								{
									continue;
								}
								input_str = original_input_str;

								sscanf(input_str.c_str(), "%4000s", command_str); //up to 4000 chars for the command name, avoid overflow
								ConvertToLowerCase(command_str);
								if (string(command_str) == string("exittcl"))
								{
									linnux_is_in_tcl_mode = 0;
									continue;
								}

								if ((linnux_is_in_tcl_mode && (remote_command_container_inst->get_command_type() == LINNUX_IS_A_CONSOLE_COMMAND)) || (remote_command_container_inst->get_command_type() == LINNUX_IS_A_TCL_COMMAND))
								{
									original_input_str = string("tcl ").append(original_input_str);
									input_str = original_input_str;
								}

								if (monitoring_telnet_available_for_sending())	{
												//we have room for a new message
												std::string timestamp_str = get_current_time_and_date_as_string();
												TrimSpaces(timestamp_str);
												ostringstream ostr;
												ostr << "[T:" << (int) remote_command_container_inst->get_command_type() << " (" << linnux_console_string_descs[remote_command_container_inst->get_command_type()] << ") CON: " << remote_command_container_inst->get_telnet_console_index() << " CMD][" << timestamp_str << "][" << remote_command_container_inst->get_command_string() << "]" << std::endl;
									post_string_to_monitoring_telnet(ostr);
										}


								ConvertToLowerCase(input_str);
								num_args_received = sscanf(input_str.c_str(), "%4000s %6lX %8lX\n", command_str, &command_argument1, &command_argument2);

								if (num_args_received > 0)
								{
									if (TrimSpacesFromString(std::string(command_str)) == "")
									{
										safe_print(std::cout << "Found Effectively null command string!" << std::endl);
										command_string = "noop";
									} else {
										command_string = command_str;
									}
								} else
								{
									command_string = "noop";
								}
						/*
								if (!be_quiet_for_this_command) {
									safe_print(std::cout << "Command String = [" << command_string << "]" << std::endl);
								};
						*/
								if (remote_command_container_inst->get_erase_this_command())
								{
									if (auto_log_file.is_open())
									{
										auto_log_file.write_str("Command was not executed (erased) due to user request\n");
									}
								} else
								{
									switch (linnux_main_menu_mapStringValues[command_string])
									{
									case enSVPicolPersistentExec:
										num_args_received = sscanf(input_str.c_str(), "%4000s < %4000s\n", command_str, cmd_filename);
										if (num_args_received != 2)
										{
											num_args_received = sscanf(input_str.c_str(), "%4000s %4000s\n", command_str, cmd_str);
											if (num_args_received != 2)
											{
												if (num_args_received == 1)
												{
													out_to_all_streams("Entering TCL mode. Type exittcl to return to normal operating mode.\n");
													linnux_is_in_tcl_mode = 1;
													break;
												}
												out_to_all_streams("Error: Usage is  < filename\nor\ntcl tcl_inline_script\n");
											} else
											{
												argument_str_pos_start = original_input_str.find(" ") + 1;
												argument_str = original_input_str.substr(argument_str_pos_start);
												tcl_active_led = 1;
												user_leds.write (get_user_leds);
												retcode = Jim_Eval(Jim_interactive_TCL_shell, argument_str.c_str());
												jim_tcl_retcode_str.str("");
												jim_tcl_retcode_str << retcode;
												tcl_active_led = 0;
												user_leds.write (get_user_leds);
												if (retcode == JIM_ERR)
												{
						#ifdef LINNUX_USE_JIM_51
													Jim_PrintErrorMessage(Jim_interactive_TCL_shell);
						#else
													Jim_MakeErrorMessage(Jim_interactive_TCL_shell);
						#endif
												}

											}
											break;
										} else
										{
											tcl_active_led = 1;
											user_leds.write (get_user_leds);
											Jim_Source_tcl_script_from_file(cmd_filename, 1);
											tcl_active_led = 0;
											user_leds.write (get_user_leds);
											break;
										}
									case enSVNOOP:
										safe_print(printf("[Linnux] Encountered NOOP command\n"));
										result_string = "";
										break;
									default:
										result_string = do_linnux_command(original_input_str, 0, remote_command_container_inst->get_command_type());
										break;

									}
								}
								end_timestamp = os_critical_low_level_system_timestamp();
								delta_timestamp = end_timestamp - start_timestamp;

								command_time_in_seconds = ((double) delta_timestamp )*LINNUX_HARDWARE_TIMESTAMP_CLOCK_CYCLE_LENGTH;


								command_response_record = new linnux_remote_command_response_container;
								command_response_record->set_command_string(remote_command_container_inst->get_command_string());
								command_response_record->set_job_index(remote_command_container_inst->get_job_index());
								command_response_record->set_command_type(remote_command_container_inst->get_command_type());
								command_response_record->set_hardware_timestamp_delta(delta_timestamp);
								command_response_record->set_completion_time_in_seconds(command_time_in_seconds);
								command_response_record->set_completion_hardware_timestamp(end_timestamp);
								command_response_record->set_send_email_notification(remote_command_container_inst->get_send_email_notification());
								command_response_record->set_email_address(remote_command_container_inst->get_email_address());
								command_response_record->set_log_filename(auto_log_filename.str());
								command_response_record->set_command_was_erased(remote_command_container_inst->get_erase_this_command());
								command_response_record->set_erase_this_command(remote_command_container_inst->get_erase_this_command());
								command_response_record->set_mem_comm_instance(remote_command_container_inst->get_mem_comm_instance());

								if (!be_quiet_for_this_command) {
									end_execution_time_str = string(get_current_time_and_date_as_string());
									command_response_record->set_start_time_str(remote_command_container_inst->get_start_time_str());
									command_response_record->set_end_time_str(end_execution_time_str);
								}

								command_response_record->set_telnet_job_index(remote_command_container_inst->get_telnet_job_index());
								command_response_record->set_telnet_console_index(remote_command_container_inst->get_telnet_console_index());
								command_response_record->set_response_queue(remote_command_container_inst->get_response_queue());

								if (remote_command_container_inst->get_erase_this_command()) {
									command_response_record->set_results_file_name("");
								} else	{
									command_response_record->set_results_file_name(remote_command_container_inst->get_results_file_name());
								}

								if (command_response_record->get_command_was_erased())
								{
									command_response_record->set_result_string("Command Was Erased Due To User Request");
									if (auto_log_file.is_open()) { auto_log_file.close(); };
								} else
								{
									switch (command_response_record->get_command_type())
									{
									case LINNUX_IS_A_TCL_COMMAND    : command_response_record->set_result_string(jim_tcl_retcode_str.str()); if (auto_log_file.is_open()) { auto_log_file.close(); }; break;
									case LINNUX_IS_A_YAIRL_COMMAND  : command_response_record->set_result_string(result_string); if (auto_log_file.is_open()) { auto_log_file.close(); }; break;
									case LINNUX_IS_A_CONSOLE_COMMAND: command_response_record->set_result_string(""); break;
									case LINNUX_IS_A_SYSCON_COMMAND        : command_response_record->set_result_string(result_string); /*auto_log_file.close(); */ break;
									case LINNUX_IS_A_TELNET_SYSCON_COMMAND : command_response_record->set_result_string(result_string); /*auto_log_file.close(); */ break;
									default: safe_print(std::cout << "Error: Unknown command type [" << command_response_record->get_command_type() << "] command is (" << command_response_record->get_command_string() << std::endl); break;
									}
								}

								/*
								if (!be_quiet_for_this_command) {
									std::string timestamp_str = get_current_time_and_date_as_string();
										TrimSpaces(timestamp_str);

									safe_print(std::cout << "[ " << timestamp_str << " ] LINNUX sending back completion notice response: for job [" << command_response_record->get_job_index() << "] for command: [" << TrimSpacesFromString(command_response_record->get_command_string()) << "]" << endl);
								};
							   */

								if (monitoring_telnet_available_for_sending()) {
										std::string timestamp_str = get_current_time_and_date_as_string();
										TrimSpaces(timestamp_str);
										ostringstream ostr;
										ostr << "[T:" << command_response_record->get_command_type() << " (" << linnux_console_string_descs[command_response_record->get_command_type()] << ") CON: " << command_response_record->get_telnet_console_index() << " REP][" << timestamp_str << "][" << command_response_record->get_result_string() << "]" << std::endl;
										post_string_to_monitoring_telnet(ostr);
								}

								if (command_response_record->get_command_type() == LINNUX_IS_A_SYSCON_COMMAND) {
									memory_comm_debug(
											safe_print(std::cout << "command_response_record->get_command_type() is: " << command_response_record->get_command_type() << " Command is: (" <<  original_input_str << ")" << "end command is: (" <<
																	 command_response_record->get_command_string() << ")" << "Result String:  (" << result_string <<  ")" <<
																	 " Command source: " << command_response_record->get_mem_comm_instance()->get_command_buffer_name() <<
																	 " Command counter: " << command_response_record->get_mem_comm_instance()->get_command_counter()
																	 <<std::endl)
											);
									if (command_response_record->get_mem_comm_instance()->get_use_url_encode_decode()) {
										std::string actual_result_string =  cgicc::form_urlencode(result_string);
										command_response_record->get_mem_comm_instance()->set_command_response(actual_result_string,binary_response);
									} else {
									   command_response_record->get_mem_comm_instance()->set_command_response(result_string,binary_response);
									}
									delete command_response_record;
									command_response_record = NULL;
								} else
									if (command_response_record->get_command_type() == LINNUX_IS_A_TELNET_SYSCON_COMMAND) {
										//safe_print(std::cout << "command_response_record->get_command_type() is: " << command_response_record->get_command_type() << " Command is: (" <<  original_input_str << ")" << "end command is: (" << command_response_record->get_command_string() << ")" << "Result String:  (" << result_string <<  ")" <<std::endl);
										OS_EVENT *response_queue = command_response_record->get_response_queue();
										if (response_queue != NULL) {
											error_code = OSQPost(response_queue, (void *) command_response_record);
											if (error_code != OS_NO_ERR) {
												safe_print(std::cout << "Error while posting string [" << command_response_record->get_result_string() <<"]" << "error code is [" << error_code << "]" << std::endl);
												delete command_response_record;
												command_response_record = NULL;
											}
										} else {
											safe_print(std::cout << "Error: trying to reply to TELNET_SYSCON but response queue is NULL!!! console number = [" << remote_command_container_inst->get_telnet_console_index() <<"]"  << std::endl);
										}
									}
									else {
										if (SSSLINNUX_HTTP_TCL_Command_Response_Q != NULL) {
											error_code = OSQPost(SSSLINNUX_HTTP_TCL_Command_Response_Q, (void *) command_response_record);
											if (error_code != OS_NO_ERR) {
												safe_print(std::cout << "Error while posting string [" << command_response_record->get_result_string() <<"]" << "error code is [" << error_code << "]" << std::endl);
												delete command_response_record;
												command_response_record = NULL;
											}
										}
									}

								if (!be_quiet_for_this_command) { out_to_all_streams("\n[LINNUX]: Finished Executing command at time: " << end_execution_time_str << std::endl); };
        );
		if ((!be_quiet_for_this_command) && linnux_profiling_enabled) {
			out_to_all_streams("[LINNUX]: Total command execution time was: " << total_time_for_this_command << " cycles, which is: " << get_timestamp_diff_in_usec(total_time_for_this_command) << " usecs" << std::endl);
		}
		MyOSTimeDlyHMSM(0,0,0,LINNUX_DELAY_BETWEEN_COMMAND_EXECUTION_IN_MAIN);//delay the task to give a chance to the Ethernet to function
	}
}



string inner_do_linnux_command(linnux_menu_mapping_type& s_mapStringValues,  string& input_str_from_external_func,
		int is_called_from_tcl_script, int is_called_from_command_window, LINNUX_COMAND_TYPES calling_command_type, int is_a_recursive_call = 0, int* command_found = NULL)
{
	string testbench_desc_str;
	string sipo_str;
	string anticipated_sipo_val;
	string data_capt_ram_str;
	string anticipated_data_capt_ram_val;
	int simult_capture_fileid;
    vector<unsigned long> simult_fifo_capture_response;
	unsigned long spi_temp;
	int verbose_fifo_print;

	unsigned long led_type;
	unsigned long pattern_value;
	gp_fifo_encapsulator* current_fifo_container_ptr;
	vector<string> eyed_strs;
	int fifo_display_format;
	int fifo_num;
	float pk_to_pkval;

	vector<unsigned long> current_fifo_data;
	vector<unsigned long> cumulative_fifo_data0, cumulative_fifo_data1;
    unsigned int switch_val;

	char command_char[4096];
	char aux_cmd[4096];

	char catsd_filename[4096];
	string catsd_filename_string;
	string current_str;
	string bitpattern_filename_string;
	char bitpattern_filename_str[4096];
	int num_fifo_capture_iterations;

	string FIR_control_String;
	char redirect_filename[1024];

	unsigned long command_argument1;
	unsigned long command_argument2;

	unsigned long read_value;
	int num_args_received;
	unsigned long  curr_mask;

	string tmpstr;
	unsigned int tmpuint;
	int cpu_sr;
	long heap_usage;
	//============================================================================
	//
	// Menu Command Handling
	//
	//============================================================================

	mem_reporting_structure_type memh_info;

	char command_str[4096];
	string command_string;
	string actual_redirect_filename;

	char cmd_filename[1024];

	string original_input_str;

	vector<string> command_strings_from_file(0);
	vector<string> parsed_redirect_filenames;

	char cmd_str[4096];
	string fifo_vec_string;
	string argument_str;
	unsigned int argument_str_pos_start;
	unsigned int argument_str_pos_finish;

	ostringstream result_str;
	int retcode;
	int file_index;
	//long RJ_scaling_coeff;
	ostringstream manual_log_filename;
	int manual_log_file_error;
	string input_str;
	string argvstr;
	string::size_type argvstr_start;

	int dut_proc_cmd_result;
	std::string dut_proc_cmd_response;

	if (command_found) {
							  *command_found = 1; //let's be optimistic
	}

	do
	{

		active_toggle_led = (1-active_toggle_led);
		active_led = 1;
        user_leds.write(get_user_leds);


				if (command_strings_from_file.size() != 0) //if we are in an "exec"
				{
					input_str = command_strings_from_file.at(0);
					outp ("Executing command: " << command_strings_from_file.at(0) << endl);
					command_strings_from_file.erase(command_strings_from_file.begin());
				} else
				{
					input_str = input_str_from_external_func;
				}

		original_input_str = input_str;
		ConvertToLowerCase(input_str);
		num_args_received = sscanf(input_str.c_str(), "%500s %6lX %8lX\n", command_str, &command_argument1, &command_argument2);
		command_string = command_str;
		if ((command_string.length() >= 2))
		{
			if ((command_string.at(0) == '/') && (command_string.at(1) == '/'))
			{
				continue; //handle comment
			}
		}

		actual_redirect_filename = "";
		argument_str_pos_start = original_input_str.find(">");
		if (argument_str_pos_start != string::npos)
		{
			argument_str = original_input_str.substr(argument_str_pos_start + 1);
			TrimSpaces(argument_str);
			parsed_redirect_filenames = convert_string_to_vector<string> (argument_str, " ");
			if (parsed_redirect_filenames.size() != 0)
			{
				actual_redirect_filename = parsed_redirect_filenames.at(0); //first filename is what we want, ignore the rest
			}
		}

		argvstr_start = original_input_str.find(" ");
		if (argvstr_start != string::npos) {
			argvstr = original_input_str.substr(argvstr_start + 1);
			TrimSpaces(argvstr);
		} else {
			argvstr = "";
		}

		//safe_print(std::cout << "[linnux_main] argvstr = [" << argvstr << "]" << std::endl);
	
StringValue mapped_val = s_mapStringValues[command_string];

		switch (mapped_val)
		{

		case enSVGetSWVersion :  {
			   result_str << get_software_version();
			   continue;
				   }
		case enSVUDPStreamCmd :  {
#ifdef UDP_INSERTER_0_BASE
 					                        	                    argument_str_pos_start = input_str.find(" ") + 1;
					                        						argument_str = TrimSpacesFromString(input_str.substr(argument_str_pos_start));
					                        	                    char nsmenu_command[2000];
					                                              	num_args_received = sscanf(argument_str.c_str(), "%1000s\n", nsmenu_command);
					                                              	int result;
					                                              	result = execute_udp_stream_command(nsmenu_command,argument_str.c_str());
                                                                    safe_print(std::cout << "udp stream command, executed (" << nsmenu_command << ")" << "argument_str = (" << argument_str << ")" << " input str = (" << input_str << ")" << std::endl);
#endif
                                                                    continue;
					                                               }
		case enSVExecUARTInternalCommand : {
																	unsigned uart_num;
																	unsigned address;
																	ostringstream str_to_uart;
																	int secondary_uart_addr = 0;
																	num_args_received = sscanf(input_str.c_str(), "%1000s %u %d %1000s\n", command_char, &uart_num,  &secondary_uart_addr, aux_cmd);
																	outpc("UART internal command params: UART: " << uart_num << " command : (" << aux_cmd << ") " << std::endl;);
																	if (uart_num > (uart_regfile_repository.size()-1))
																	{
																		safe_print(printf("Error: (1) Usage is: uart_exec_internal_command uart_num the_command. Command was: (%s); uart_num = %d num_args_received = %d max_uart_num()-1 = (%d), (num_args_received < 3) = (%d) (uart_num > (uart_regfile_repository.size()-1)) = %d ((num_args_received < 3) || (uart_num > (uart_regfile_repository.size()-1))) = %d\n",
																				input_str.c_str(),
																				(int) uart_num,
																				(int) num_args_received,uart_regfile_repository.size()-1,
																				(int) ((num_args_received < 3)),
																				(int) ((uart_num > (uart_regfile_repository.size()-1))),
																				(int) ((num_args_received < 3) || (uart_num > (uart_regfile_repository.size()-1)))));
																		continue;
																	} else
																	if (num_args_received < 4) {
																		safe_print(printf("Error: (2) Usage is: uart_exec_internal_command uart_num the_command. Command was: (%s); uart_num = %d num_args_received = %d max_uart_num()-1 = (%d), (num_args_received < 3) = (%d) (uart_num > (uart_regfile_repository.size()-1)) = %d ((num_args_received < 3) || (uart_num > (uart_regfile_repository.size()-1))) = %d\n",
																		input_str.c_str(),
																		(int) uart_num,
																		(int) num_args_received,uart_regfile_repository.size()-1,
																		(int) ((num_args_received < 4)),
																		(int) ((uart_num > (uart_regfile_repository.size()-1))),
																		(int) ((num_args_received < 4) || (uart_num > (uart_regfile_repository.size()-1)))));
																		continue;
																	} else
																	{
																			//find the complete string to end of line
																			unsigned int argument_str_pos_start = input_str.find(" ") + 1;
																			std::string  argument_str = TrimSpacesFromString(input_str.substr(argument_str_pos_start));
																			argument_str_pos_start = argument_str.find(" ") + 1;
																		    argument_str = TrimSpacesFromString(argument_str.substr(argument_str_pos_start));
																			argument_str_pos_start = argument_str.find(" ") + 1;
																			argument_str = TrimSpacesFromString(argument_str.substr(argument_str_pos_start));
																			std::string uart_result = ( uart_regfile_repository.get_uart_ptr_from_number(uart_num))->exec_internal_command(argument_str, secondary_uart_addr);
																			outpc("Result of UART read is: (" << uart_result << ")" << std::endl;);
																			result_str << uart_result;
																			continue;

																	}

																}


		case enSVExecUARTInternalCommandASCII  : {
        	                                                                    unsigned uart_num;
        																		ostringstream str_to_uart;
        																		int secondary_uart_addr = 0;
        																		num_args_received = sscanf(input_str.c_str(), "%1000s %u %d %1000s\n", command_char, &uart_num,  &secondary_uart_addr, aux_cmd);
        																		outpc("UART internal command return ascii params: UART: " << uart_num << " command : (" << aux_cmd << ") " << std::endl;);
        																		if ((num_args_received < 4) || (uart_num > uart_regfile_repository.size()-1))
        																		{
        																			safe_print(printf("Error: (%s) Usage is: uart_exec_internal_command_ascii_response uart_num the_command\n",input_str.c_str()));
        																			continue;
        																		} else {

        																				//find the complete string to end of line
        																				unsigned int argument_str_pos_start = input_str.find(" ") + 1;
        																				std::string  argument_str = TrimSpacesFromString(input_str.substr(argument_str_pos_start));
        																				argument_str_pos_start = argument_str.find(" ") + 1;
        																				argument_str = TrimSpacesFromString(argument_str.substr(argument_str_pos_start));
        																				argument_str_pos_start = argument_str.find(" ") + 1;
        				        														argument_str = TrimSpacesFromString(argument_str.substr(argument_str_pos_start));

        																				std::string uart_result = ( uart_regfile_repository.get_uart_ptr_from_number(uart_num))->exec_internal_command_get_ascii_response(argument_str, secondary_uart_addr);
        																				outpc("Result of UART read is: (" << uart_result << ")" << std::endl;);
        																				result_str << uart_result;
        																				continue;

        																		}
		                                                      }

		    case enSVPicolPersistentExec: out_to_all_streams("Error: cannot call TCL from within TCL (e.g. tcl ylcmd tcl): command_String = ["<<command_string<<"]; "<< "input_str = [" << "] " << input_str_from_external_func << std::endl);
		                                  continue;
		    case enSVNOOP : continue;
			case enSVPicolExec:
				num_args_received = sscanf(input_str.c_str(), "%100s < %1000s\n", command_str, cmd_filename);
				if (num_args_received != 2)
				{

					num_args_received = sscanf(input_str.c_str(), "%s %4000s\n", command_str, cmd_str);
					if (num_args_received != 2)
					{
						out_to_all_streams("Error: Usage is  < filename\nor\ntcl tcl_inline_script\n");
					} else
					{
						argument_str_pos_start = original_input_str.find(" ") + 1;
						argument_str = original_input_str.substr(argument_str_pos_start);
						retcode = Jim_Source_autonomous_tcl_script(NULL, argument_str);
						if (retcode == JIM_ERR)
						{
#ifdef LINNUX_USE_JIM_51
							Jim_PrintErrorMessage(Jim_interactive_TCL_shell);
#else
							Jim_MakeErrorMessage(Jim_interactive_TCL_shell);
#endif
						}
					}
					continue;

				} else
				{
					Jim_Source_tcl_script_from_file(cmd_filename, 0);
					continue;
				}

			case enSVExec:
				num_args_received = sscanf(input_str.c_str(), "%100s %500s\n", command_str, cmd_filename);
				if (num_args_received != 2)
				{
					out_to_all_streams("Error: Usage is execyl filename\n");
					continue;
				} else
				{
					command_strings_from_file = read_from_sd_card_into_string_vector(string(cmd_filename));
					continue;
				}


					case enSVusleep:
						num_args_received = sscanf(input_str.c_str(), "%1000s %u\n", command_char, &tmpuint);
						if ((num_args_received != 2))
						{
							out_to_all_streams("Error: Usage is usleep num_microseconds (decimal number)\n");
							continue;
						} else
						{
							usleep(tmpuint);
							continue;
						}

					case  enSVGetHWVersion : {
						 result_str << get_hardware_version();
						 outp("Hardware Version is: " << result_str.str() << "\n");
					} continue;

					case  enSVGetMACAddr: {
						result_str << get_mac_addr_string_from_char_array(board_mac_addr);
						outp("MAC address is: " << result_str.str() << "\n");
					} continue;
					case enSVGetLowLevelTimestamp :/* //OS_ENTER_CRITICAL();
						                            result_str << verbose_low_level_system_timestamp();
						                            //OS_EXIT_CRITICAL();*/
						                            result_str << os_critical_low_level_system_timestamp();
					                                outp("Low Level Timestamp is: " << result_str.str() << "\n");
						                            continue;

					case enSVGetLowLevelTimestampSecs :  result_str << c_low_level_system_timestamp_in_secs();
						                                 outp("Low Level Timestamp in Seconds is: " << result_str.str() << "\n");
											             continue;

					case  enSVSetPrintPkt:  print_packet_log = 1;
											outpc("[linnux_main] Set pkt print\n");
											continue;


					case  enSVClearPrintPkt: print_packet_log = 0;
					                         outpc("[linnux_main] Clear pkt print\n");
											 continue;

					case enSVEnableDeepPacketStats : enable_deep_packet_stats = 1;
					                                 outpc("[linnux_main] Enabling Deep Packet Stats\n");
						                             continue;

					case enSVDisableDeepPacketStats: enable_deep_packet_stats = 0;
						                             outpc("[linnux_main] Disabling Deep Packet Stats\n");
                                                     continue;

	              case enSVEnableLINNUXProfiling : linnux_profiling_enabled = 1;
	                                               out_to_all_streams("Enabled Profiling\n");
						                           continue;

					case enSVDisableLINNUXProfiling: linnux_profiling_enabled = 0;
					                                 out_to_all_streams("Disabled Profiling\n");
						                             continue;

					case enSVPrintUCOSStats : result_str << raw_print_ucosdiag();
					                          out_to_all_streams(result_str.str())
					                          continue;

					case enSVSetPrintUCOSStats : linnux_printf_ucos_diag = 1;
					                             outpc("[linnux_main] Set UCOS Diag\n");
					                             continue;

					case enSVClearPrintUCOSStats : linnux_printf_ucos_diag = 0;
					                               outpc("[linnux_main] Clear UCOS Diag\n");
					                               continue;

					case enSVWriteLED: if ((num_args_received != 2))
					                   {
					                   	out_to_all_streams("Error: Usage is write_led  pattern\n (pattern in hexadecimal) \n");
					                   	continue;
					                   }
					                   pattern_value = command_argument1;
									   user_leds.write(pattern_value);
					                   continue;

					case enSVReadLED : if ((num_args_received != 1))
									   {
										out_to_all_streams("Error: Usage is read_led\n\n");
										continue;
									   }

                   					   result_str << user_leds.read();
                   					   outp("LED state is: " << hex << get_red_led_state() << dec << std::endl);

						               continue;

					case enSVReadSwitches : num_args_received = sscanf(input_str.c_str(), "%1000s %u\n", command_char, &tmpuint);
											if ((num_args_received != 2))
											{
												out_to_all_streams("Error: Usage is read_switch switch_num (decimal number)\n");
												continue;
											}
						                    curr_mask = 1;
										    curr_mask = curr_mask << tmpuint;
										    switch_val = (read_switches() & curr_mask) != 0;
										    result_str << switch_val;
										    outp ("Switch " << tmpuint << " is " << (switch_val ? "On" : "Off") << std::endl);
						                    continue;

					case enSVMacStats:
					{
						// allocate a structure to hold the current register values
						np_tse_mac MY_MAC;
                         unsigned PCS_CONTROL,
                         PCS_STATUS,
                         PCS_PARTNER_ABILITY,
                         PCS_LINK_TIMER,
                         PCS_IF_MODE;








						// read all the registers
						MY_MAC.REV								= IORD_ALTERA_TSEMAC_REV(TSE_MAC_BASE);
						MY_MAC.SCRATCH							= IORD_ALTERA_TSEMAC_SCRATCH(TSE_MAC_BASE);
						MY_MAC.COMMAND_CONFIG					= IORD_ALTERA_TSEMAC_CMD_CONFIG(TSE_MAC_BASE);
						MY_MAC.MAC_0							= IORD_ALTERA_TSEMAC_MAC_0(TSE_MAC_BASE);
						MY_MAC.MAC_1							= IORD_ALTERA_TSEMAC_MAC_1(TSE_MAC_BASE);
						MY_MAC.FRM_LENGTH						= IORD_ALTERA_TSEMAC_FRM_LENGTH(TSE_MAC_BASE);
						MY_MAC.PAUSE_QUANT						= IORD_ALTERA_TSEMAC_PAUSE_QUANT(TSE_MAC_BASE);
						MY_MAC.RX_SECTION_EMPTY					= IORD_ALTERA_TSEMAC_RX_SECTION_EMPTY(TSE_MAC_BASE);
						MY_MAC.RX_SECTION_FULL					= IORD_ALTERA_TSEMAC_RX_SECTION_FULL(TSE_MAC_BASE);
						MY_MAC.TX_SECTION_EMPTY					= IORD_ALTERA_TSEMAC_TX_SECTION_EMPTY(TSE_MAC_BASE);
						MY_MAC.TX_SECTION_FULL					= IORD_ALTERA_TSEMAC_TX_SECTION_FULL(TSE_MAC_BASE);
						MY_MAC.RX_ALMOST_EMPTY					= IORD_ALTERA_TSEMAC_RX_ALMOST_EMPTY(TSE_MAC_BASE);
						MY_MAC.RX_ALMOST_FULL					= IORD_ALTERA_TSEMAC_RX_ALMOST_FULL(TSE_MAC_BASE);
						MY_MAC.TX_ALMOST_EMPTY					= IORD_ALTERA_TSEMAC_TX_ALMOST_EMPTY(TSE_MAC_BASE);
						MY_MAC.TX_ALMOST_FULL					= IORD_ALTERA_TSEMAC_TX_ALMOST_FULL(TSE_MAC_BASE);
						MY_MAC.MDIO_ADDR0						= IORD_ALTERA_TSEMAC_MDIO_ADDR0(TSE_MAC_BASE);
						MY_MAC.MDIO_ADDR1						= IORD_ALTERA_TSEMAC_MDIO_ADDR1(TSE_MAC_BASE);
						MY_MAC.REG_STAT							= IORD_ALTERA_TSEMAC_REG_STAT(TSE_MAC_BASE);
						MY_MAC.TX_IPG_LENGTH					= IORD_ALTERA_TSEMAC_TX_IPG_LENGTH(TSE_MAC_BASE);
						MY_MAC.aMACID_1							= IORD_ALTERA_TSEMAC_A_MACID_1(TSE_MAC_BASE);
						MY_MAC.aMACID_2							= IORD_ALTERA_TSEMAC_A_MACID_2(TSE_MAC_BASE);
						MY_MAC.aFramesTransmittedOK				= IORD_ALTERA_TSEMAC_A_FRAMES_TX_OK(TSE_MAC_BASE);
						MY_MAC.aFramesReceivedOK				= IORD_ALTERA_TSEMAC_A_FRAMES_RX_OK(TSE_MAC_BASE);
						MY_MAC.aFramesCheckSequenceErrors		= IORD_ALTERA_TSEMAC_A_FRAME_CHECK_SEQ_ERRS(TSE_MAC_BASE);
						MY_MAC.aAlignmentErrors					= IORD_ALTERA_TSEMAC_A_ALIGNMENT_ERRS(TSE_MAC_BASE);
						MY_MAC.aOctetsTransmittedOK				= IORD_ALTERA_TSEMAC_A_OCTETS_TX_OK(TSE_MAC_BASE);
						MY_MAC.aOctetsReceivedOK				= IORD_ALTERA_TSEMAC_A_OCTETS_RX_OK(TSE_MAC_BASE);
						MY_MAC.aTxPAUSEMACCtrlFrames			= IORD_ALTERA_TSEMAC_A_TX_PAUSE_MAC_CTRL_FRAMES(TSE_MAC_BASE);
						MY_MAC.aRxPAUSEMACCtrlFrames			= IORD_ALTERA_TSEMAC_A_RX_PAUSE_MAC_CTRL_FRAMES(TSE_MAC_BASE);
						MY_MAC.ifInErrors						= IORD_ALTERA_TSEMAC_IF_IN_ERRORS(TSE_MAC_BASE);
						MY_MAC.ifOutErrors						= IORD_ALTERA_TSEMAC_IF_OUT_ERRORS(TSE_MAC_BASE);
						MY_MAC.ifInUcastPkts					= IORD_ALTERA_TSEMAC_IF_IN_UCAST_PKTS(TSE_MAC_BASE);
						MY_MAC.ifInMulticastPkts				= IORD_ALTERA_TSEMAC_IF_IN_MULTICAST_PKTS(TSE_MAC_BASE);
						MY_MAC.ifInBroadcastPkts				= IORD_ALTERA_TSEMAC_IF_IN_BROADCAST_PKTS(TSE_MAC_BASE);
						MY_MAC.ifOutDiscards					= IORD_ALTERA_TSEMAC_IF_OUT_DISCARDS(TSE_MAC_BASE);
						MY_MAC.ifOutUcastPkts					= IORD_ALTERA_TSEMAC_IF_OUT_UCAST_PKTS(TSE_MAC_BASE);
						MY_MAC.ifOutMulticastPkts				= IORD_ALTERA_TSEMAC_IF_OUT_MULTICAST_PKTS(TSE_MAC_BASE);
						MY_MAC.ifOutBroadcastPkts				= IORD_ALTERA_TSEMAC_IF_OUT_BROADCAST_PKTS(TSE_MAC_BASE);
						MY_MAC.etherStatsDropEvent				= IORD_ALTERA_TSEMAC_ETHER_STATS_DROP_EVENTS(TSE_MAC_BASE);
						MY_MAC.etherStatsOctets					= IORD_ALTERA_TSEMAC_ETHER_STATS_OCTETS(TSE_MAC_BASE);
						MY_MAC.etherStatsPkts					= IORD_ALTERA_TSEMAC_ETHER_STATS_PKTS(TSE_MAC_BASE);
						MY_MAC.etherStatsUndersizePkts			= IORD_ALTERA_TSEMAC_ETHER_STATS_UNDERSIZE_PKTS(TSE_MAC_BASE);
						MY_MAC.etherStatsOversizePkts			= IORD_ALTERA_TSEMAC_ETHER_STATS_OVERSIZE_PKTS(TSE_MAC_BASE);
						MY_MAC.etherStatsPkts64Octets			= IORD_ALTERA_TSEMAC_ETHER_STATS_PKTS_64_OCTETS(TSE_MAC_BASE);
						MY_MAC.etherStatsPkts65to127Octets		= IORD_ALTERA_TSEMAC_ETHER_STATS_PKTS_65_TO_127_OCTETS(TSE_MAC_BASE);
						MY_MAC.etherStatsPkts128to255Octets		= IORD_ALTERA_TSEMAC_ETHER_STATS_PKTS_128_TO_255_OCTETS(TSE_MAC_BASE);
						MY_MAC.etherStatsPkts256to511Octets		= IORD_ALTERA_TSEMAC_ETHER_STATS_PKTS_256_TO_511_OCTETS(TSE_MAC_BASE);
						MY_MAC.etherStatsPkts512to1023Octets	= IORD_ALTERA_TSEMAC_ETHER_STATS_PKTS_512_TO_1023_OCTETS(TSE_MAC_BASE);
						MY_MAC.etherStatsPkts1024to1518Octets	= IORD_ALTERA_TSEMAC_ETHER_STATS_PKTS_1024_TO_1518_OCTETS(TSE_MAC_BASE);
						MY_MAC.etherStatsPkts1519toXOctets						= IORD_ALTERA_TSEMAC_ETHER_STATS_PKTS_1519_TO_X_OCTETS(TSE_MAC_BASE);
						MY_MAC.etherStatsJabbers						= IORD_ALTERA_TSEMAC_ETHER_STATS_JABBERS(TSE_MAC_BASE);
						MY_MAC.etherStatsFragments						= IORD_ALTERA_TSEMAC_ETHER_STATS_FRAGMENTS(TSE_MAC_BASE);
						MY_MAC.TX_CMD_STAT						= IORD_ALTERA_TSEMAC_TX_CMD_STAT(TSE_MAC_BASE);
						MY_MAC.RX_CMD_STAT						= IORD_ALTERA_TSEMAC_RX_CMD_STAT(TSE_MAC_BASE);
						PCS_CONTROL =                          IORD_32DIRECT(TSE_MAC_BASE, TSE_PCS_CONTROL        );
						PCS_STATUS  =                          IORD_32DIRECT(TSE_MAC_BASE, TSE_PCS_STATUS         );
						PCS_PARTNER_ABILITY =                  IORD_32DIRECT(TSE_MAC_BASE, TSE_PCS_PARTNER_ABILITY);
						PCS_LINK_TIMER =                       IORD_32DIRECT(TSE_MAC_BASE, TSE_PCS_LINK_TIMER     );
						PCS_IF_MODE =                          IORD_32DIRECT(TSE_MAC_BASE, TSE_PCS_IF_MODE        );

						outprintf("%s","********************* CURRENT MAC STATS *********************\n\n");

						outprintf("                           REV = 0x%08X\n", MY_MAC.REV);
						outprintf("                       SCRATCH = 0x%08X\n", MY_MAC.SCRATCH);
						outprintf("                COMMAND_CONFIG = 0x%08X\n", MY_MAC.COMMAND_CONFIG);
						outprintf("                         MAC_0 = 0x%08X\n", MY_MAC.MAC_0);
						outprintf("                         MAC_1 = 0x%08X\n", MY_MAC.MAC_1);
						outprintf("                    FRM_LENGTH = 0x%08X  %uu\n", MY_MAC.FRM_LENGTH, MY_MAC.FRM_LENGTH);
						outprintf("                   PAUSE_QUANT = 0x%08X\n", MY_MAC.PAUSE_QUANT);
						outprintf("              RX_SECTION_EMPTY = 0x%08X\n", MY_MAC.RX_SECTION_EMPTY);
						outprintf("               RX_SECTION_FULL = 0x%08X\n", MY_MAC.RX_SECTION_FULL);
						outprintf("              TX_SECTION_EMPTY = 0x%08X\n", MY_MAC.TX_SECTION_EMPTY);
						outprintf("               TX_SECTION_FULL = 0x%08X\n", MY_MAC.TX_SECTION_FULL);
						outprintf("               RX_ALMOST_EMPTY = 0x%08X\n", MY_MAC.RX_ALMOST_EMPTY);
						outprintf("                RX_ALMOST_FULL = 0x%08X\n", MY_MAC.RX_ALMOST_FULL);
						outprintf("               TX_ALMOST_EMPTY = 0x%08X\n", MY_MAC.TX_ALMOST_EMPTY);
						outprintf("                TX_ALMOST_FULL = 0x%08X\n", MY_MAC.TX_ALMOST_FULL);
						outprintf("                    MDIO_ADDR0 = 0x%08X\n", MY_MAC.MDIO_ADDR0);
						outprintf("                    MDIO_ADDR1 = 0x%08X\n", MY_MAC.MDIO_ADDR1);
						outprintf("                      REG_STAT = 0x%08X\n", MY_MAC.REG_STAT);
						outprintf("                 TX_IPG_LENGTH = 0x%08X  %uu\n", MY_MAC.TX_IPG_LENGTH, MY_MAC.TX_IPG_LENGTH);
						outprintf("                      aMACID_1 = 0x%08X\n", MY_MAC.aMACID_1);
						outprintf("                      aMACID_2 = 0x%08X\n", MY_MAC.aMACID_2);
						outprintf("          aFramesTransmittedOK = 0x%08X  %uu\n", MY_MAC.aFramesTransmittedOK, MY_MAC.aFramesTransmittedOK);
						outprintf("             aFramesReceivedOK = 0x%08X  %uu\n", MY_MAC.aFramesReceivedOK, MY_MAC.aFramesReceivedOK);
						outprintf("    aFramesCheckSequenceErrors = 0x%08X  %uu\n", MY_MAC.aFramesCheckSequenceErrors, MY_MAC.aFramesCheckSequenceErrors);
						outprintf("              aAlignmentErrors = 0x%08X  %uu\n", MY_MAC.aAlignmentErrors, MY_MAC.aAlignmentErrors);
						outprintf("          aOctetsTransmittedOK = 0x%08X  %uu\n", MY_MAC.aOctetsTransmittedOK, MY_MAC.aOctetsTransmittedOK);
						outprintf("             aOctetsReceivedOK = 0x%08X  %uu\n", MY_MAC.aOctetsReceivedOK, MY_MAC.aOctetsReceivedOK);
						outprintf("         aTxPAUSEMACCtrlFrames = 0x%08X  %uu\n", MY_MAC.aTxPAUSEMACCtrlFrames, MY_MAC.aTxPAUSEMACCtrlFrames);
						outprintf("         aRxPAUSEMACCtrlFrames = 0x%08X  %uu\n", MY_MAC.aRxPAUSEMACCtrlFrames, MY_MAC.aRxPAUSEMACCtrlFrames);
						outprintf("                    ifInErrors = 0x%08X  %uu\n", MY_MAC.ifInErrors, MY_MAC.ifInErrors);
						outprintf("                   ifOutErrors = 0x%08X  %uu\n", MY_MAC.ifOutErrors, MY_MAC.ifOutErrors);
						outprintf("                 ifInUcastPkts = 0x%08X  %uu\n", MY_MAC.ifInUcastPkts, MY_MAC.ifInUcastPkts);
						outprintf("             ifInMulticastPkts = 0x%08X  %uu\n", MY_MAC.ifInMulticastPkts, MY_MAC.ifInMulticastPkts);
						outprintf("             ifInBroadcastPkts = 0x%08X  %uu\n", MY_MAC.ifInBroadcastPkts, MY_MAC.ifInBroadcastPkts);
						outprintf("                 ifOutDiscards = 0x%08X  %uu\n", MY_MAC.ifOutDiscards, MY_MAC.ifOutDiscards);
						outprintf("                ifOutUcastPkts = 0x%08X  %uu\n", MY_MAC.ifOutUcastPkts, MY_MAC.ifOutUcastPkts);
						outprintf("            ifOutMulticastPkts = 0x%08X  %uu\n", MY_MAC.ifOutMulticastPkts, MY_MAC.ifOutMulticastPkts);
						outprintf("            ifOutBroadcastPkts = 0x%08X  %uu\n", MY_MAC.ifOutBroadcastPkts, MY_MAC.ifOutBroadcastPkts);
						outprintf("           etherStatsDropEvent = 0x%08X  %uu\n", MY_MAC.etherStatsDropEvent, MY_MAC.etherStatsDropEvent);
						outprintf("              etherStatsOctets = 0x%08X  %uu\n", MY_MAC.etherStatsOctets, MY_MAC.etherStatsOctets);
						outprintf("                etherStatsPkts = 0x%08X  %uu\n", MY_MAC.etherStatsPkts, MY_MAC.etherStatsPkts);
						outprintf("       etherStatsUndersizePkts = 0x%08X  %uu\n", MY_MAC.etherStatsUndersizePkts, MY_MAC.etherStatsUndersizePkts);
						outprintf("        etherStatsOversizePkts = 0x%08X  %uu\n", MY_MAC.etherStatsOversizePkts, MY_MAC.etherStatsOversizePkts);
						outprintf("        etherStatsPkts64Octets = 0x%08X  %uu\n", MY_MAC.etherStatsPkts64Octets, MY_MAC.etherStatsPkts64Octets);
						outprintf("   etherStatsPkts65to127Octets = 0x%08X  %uu\n", MY_MAC.etherStatsPkts65to127Octets, MY_MAC.etherStatsPkts65to127Octets);
						outprintf("  etherStatsPkts128to255Octets = 0x%08X  %uu\n", MY_MAC.etherStatsPkts128to255Octets, MY_MAC.etherStatsPkts128to255Octets);
						outprintf("  etherStatsPkts256to511Octets = 0x%08X  %uu\n", MY_MAC.etherStatsPkts256to511Octets, MY_MAC.etherStatsPkts256to511Octets);
						outprintf(" etherStatsPkts512to1023Octets = 0x%08X  %uu\n", MY_MAC.etherStatsPkts512to1023Octets, MY_MAC.etherStatsPkts512to1023Octets);
						outprintf("etherStatsPkts1024to1518Octets = 0x%08X  %uu\n", MY_MAC.etherStatsPkts1024to1518Octets, MY_MAC.etherStatsPkts1024to1518Octets);
						outprintf("   etherStatsPkts1519toXOctets = 0x%08X  %uu\n", MY_MAC.etherStatsPkts1519toXOctets, MY_MAC.etherStatsPkts1519toXOctets);
						outprintf("             etherStatsJabbers = 0x%08X  %uu\n", MY_MAC.etherStatsJabbers, MY_MAC.etherStatsJabbers);
						outprintf("           etherStatsFragments = 0x%08X  %uu\n", MY_MAC.etherStatsFragments, MY_MAC.etherStatsFragments);
						outprintf("                   TX_CMD_STAT = 0x%08X\n", MY_MAC.TX_CMD_STAT);
						outprintf("                   RX_CMD_STAT = 0x%08X\n", MY_MAC.RX_CMD_STAT);
		                outprintf("           PCS_CONTROL         = 0x%08X\n", 	PCS_CONTROL              );
						outprintf("           PCS_STATUS          = 0x%08X\n", 	PCS_STATUS               );
						outprintf("           PCS_PARTNER_ABILITY = 0x%08X\n"     , 	PCS_PARTNER_ABILITY       );
						outprintf("           PCS_LINK_TIMER      = 0x%08X\n"     , 	PCS_LINK_TIMER            );
                        outprintf("           PCS_IF_MODE         = 0x%08X\n"     , 	PCS_IF_MODE               );

						outprintf("%s","\n");
					    continue;
					}
					    case enSVIPConfig : result_str << "\nBoard Name: "<< cpp_get_current_linnux_board_hostname() <<
					    		            "\nIP Address: "<< get_LINNUX_BOARD_IPADDR(0) << "." << get_LINNUX_BOARD_IPADDR(1) << "." << get_LINNUX_BOARD_IPADDR(2) << "." << get_LINNUX_BOARD_IPADDR(3) <<"\n";
                                            result_str << "Subnet Mask: " << get_LINNUX_BOARD_MSKADDR(0) << "." << get_LINNUX_BOARD_MSKADDR(1) << "." << get_LINNUX_BOARD_MSKADDR(2) << "." << get_LINNUX_BOARD_MSKADDR(3) <<"\n";
                                            result_str << "Gateway: " << get_LINNUX_BOARD_GWADDR(0) << "." << get_LINNUX_BOARD_GWADDR(1) << "." << get_LINNUX_BOARD_GWADDR(2) << "." << get_LINNUX_BOARD_GWADDR(3) <<"\n";
                                            result_str << "DNS 0: " << get_LINNUX_DNS_ADDR(0,0) << "." << get_LINNUX_DNS_ADDR(0,1) << "." << get_LINNUX_DNS_ADDR(0,2) << "." << get_LINNUX_DNS_ADDR(0,3) <<"\n";
                                            result_str << "DNS 1: " << get_LINNUX_DNS_ADDR(1,0) << "." << get_LINNUX_DNS_ADDR(1,1) << "." << get_LINNUX_DNS_ADDR(1,2) << "." << get_LINNUX_DNS_ADDR(1,3) <<"\n";
                                            result_str << "DNS 2: " << get_LINNUX_DNS_ADDR(2,0) << "." << get_LINNUX_DNS_ADDR(2,1) << "." << get_LINNUX_DNS_ADDR(2,2) << "." << get_LINNUX_DNS_ADDR(2,3) <<"\n";
                                            outp(result_str.str());
					    	                continue;


#ifdef  LEGACY_ITEMS_HAVE_BEEN_INCLUDED_IN_SYSTEM
	case enSSVWritePatgenRAM:
					case enSVWritePatgenRAM:
						if (num_args_received != 3)
						{
							outp("Error: Usage is > ADDR VAL (hexadecimal numbers)\n");
							continue;
						} else
						{

							BERC_bit_pattern_dual_port_ram.write_ram(command_argument1, command_argument2);
							outprintf("Wrote to PatGen Ram (%6lX) value (%8lX)\n", command_argument1, command_argument2);
							continue;
						}



					case enSSVReadPatgenRAM:
					case enSVReadPatgenRAM:
						if (num_args_received != 2)
						{
							outp("Error: Usage is < ADDR (hexadecimal number)\n");
							continue;
						} else
						{
							read_value = input_bit_pattern_dual_port_ram.read_ram(command_argument1);
							outprintf("Read from PatGen Ram (%6lX) value (%8lX)\n", command_argument1, read_value);
							result_str << read_value;
							continue;
						}
					case enSSVWriteBERCPatgenRAM:
					case enSVWriteBERCPatgenRAM:
						if (num_args_received != 3)
						{
							outp("Error: Usage is | ADDR VAL (hexadecimal numbers)\n");
							continue;
						} else
						{

							BERC_bit_pattern_dual_port_ram.write_ram(command_argument1, command_argument2);
							outprintf("Wrote to BERC PatGen Ram (%6lX) value (%8lX)\n", command_argument1, command_argument2);
							continue;
						}

					case enSSVReadBERCPatgenRAM:
					case enSVReadBERCPatgenRAM:
						if (num_args_received != 2)
						{
							outp("Error: Usage is \\ ADDR (hexadecimal number)\n");
							continue;
						} else
						{
							read_value = BERC_bit_pattern_dual_port_ram.read_ram(command_argument1);
							outprintf("Read from BERC PatGen Ram (%6lX) value (%8lX)\n", command_argument1, read_value);
							result_str << read_value;
							continue;
						}
#endif

					    case enSVPrintPktlog : result_str << raw_print_pktlog();
					                           out_to_all_streams(result_str.str());
					                           continue;

					    case enSVFTPDebug : out_to_all_streams("Entering FTP debug mode");
					                        linnux_ftp_debug = 1;
					                        continue;

					    case enSVFTPNoDebug: out_to_all_streams("Exiting FTP debug mode");
                                             linnux_ftp_debug = 0;
                                             continue;

					    case enSVEnableUCOSStatPrint: linnux_print_task_statistics = 1;
					                                  out_to_all_streams("Allowing UCOS statistics print\n");
					    	                          continue;
					    case enSVDisableUCOSStatPrint:linnux_print_task_statistics = 0;
					                                  out_to_all_streams("Disabling UCOS statistics print\n");
					    	                          continue;;

					    case enSVPrintUCOSStatsNow :  result_str << get_task_stat_str();
						                              outp(result_str.str());
			                                          continue;



					    case enSVOSTaskDel :    int task_to_delete_perhaps;
					    	                    num_args_received = sscanf(input_str.c_str(), "%1000s %d\n", command_char, &task_to_delete_perhaps);
												if ((num_args_received != 2))
												{
													out_to_all_streams("Error: Usage is os_task_del task_prio (decimal number) \n");
													continue;
												} else
												{
            										outp("Will try to delete task: " << (int) task_to_delete_perhaps << "\n");
            										task_to_delete_please = task_to_delete_perhaps;
            										req_network_watchdog_to_delete_task = 1;
													continue;
												}
					    	                    continue;

					case enSVInicheDiag: argument_str_pos_start = original_input_str.find(" ");
					                     if (argument_str_pos_start != string::npos)
					                     {
						                   argument_str = original_input_str.substr(argument_str_pos_start + 1);
					                     } else {
					                    	out_to_all_streams("Error: iniche_diag: Command not found!\n");
					                    	continue;
					                     }
					                     TrimSpaces(argument_str);
					                     result_str << local_do_iniche_diag_command(argument_str,is_called_from_tcl_script,calling_command_type);
										 outp(result_str.str());
						                 continue;

					case enSVTestTCPIPBufferRecovery: out_to_all_streams("Simulating TCPIP Rx Buffer Error....\n");
								                      tcp_ip_rx_buffer_error_simulation = 1;
									                  continue;

					case enSVCatSDFile:
						num_args_received = sscanf(original_input_str.c_str(), "%1000s %s\n", command_char, catsd_filename);
						if (num_args_received != 2)
						{
							out_to_all_streams("Error: Usage is cat filename\n");
							continue;
						} else
						{
							//cat_file_from_SD_card(catsd_filename);
							fatfs_print_file_contents(string(catsd_filename));
							continue;
						}
#ifdef  LEGACY_ITEMS_HAVE_BEEN_INCLUDED_IN_SYSTEM
case enSVLoadUserPatternFromSDCard:
						num_args_received = sscanf(input_str.c_str(), "%s %s\n", command_char, bitpattern_filename_str);
						if (num_args_received != 2)
						{
							outp("Error: Usage is: load_user_bit_pattern filename\n");
							continue;
						} else
						{
							bitpattern_filename_string = bitpattern_filename_str;
							input_bit_pattern_dual_port_ram.load_bit_pattern_from_file_to_dual_port_ram(bitpattern_filename_string);
							BERC_bit_pattern_dual_port_ram.load_bit_pattern_from_file_to_dual_port_ram(bitpattern_filename_string);
							continue;
						}
#endif
					case enSVlsSDCard:
						//ls_SD_card();
						result_str << fatfs_showdir();
						outp(result_str.str());
						continue;

					case enSVRM:
						num_args_received = sscanf(original_input_str.c_str(), "%s %s\n", command_char, catsd_filename);
						if (num_args_received != 2)
						{
							out_to_all_streams("Error: Usage is rm filename\n");
							continue;
						} else
						{
							f_unlink(catsd_filename);
							continue;
						}

					case enSVWriteStrToFile:
						num_args_received = sscanf(original_input_str.c_str(), "%s %d %s\n", command_char, &file_index, catsd_filename);
						if (num_args_received != 3)
						{
							out_to_all_streams("Error: Usage is write_str_to_file file_index str\n");
							continue;
						} else
						{
							linnux_sd_card_write_string_to_file(file_index, string(catsd_filename));
							continue;
						}

					case enSVReadStrFromFile:
						num_args_received = sscanf(original_input_str.c_str(), "%s %d\n", command_char, &file_index);
						if (num_args_received != 2)
						{
							out_to_all_streams("Error: Usage is read_str_from_file file_index\n");
							continue;
						} else
						{
							result_str << linnux_sd_card_read_string_from_file(file_index);
							continue;
						}
					case enSVOpenFileForRead:
						num_args_received = sscanf(original_input_str.c_str(), "%s %s\n", command_char, catsd_filename);
						if (num_args_received != 2)
						{
							out_to_all_streams("Error: Usage is open_file_for_read filename\n");
							continue;
						} else
						{
							result_str << linnux_sd_card_file_open_for_read(catsd_filename);
							continue;
						}
					case enSVOpenFileForWrite:
						num_args_received = sscanf(original_input_str.c_str(), "%s %s\n", command_char, catsd_filename);
						if (num_args_received != 2)
						{
							out_to_all_streams("Error: Usage is open_file_for_write filename\n");
							continue;
						} else
						{
							result_str << linnux_sd_card_file_open_for_write(string(catsd_filename));
							continue;
						}

					case enSVOpenFileForOverWrite:
											num_args_received = sscanf(original_input_str.c_str(), "%s %s\n", command_char, catsd_filename);
											if (num_args_received != 2)
											{
												out_to_all_streams("Error: Usage is open_file_for_overwrite filename\n");
												continue;
											} else
											{
												result_str << linnux_sd_card_file_open_for_overwrite(string(catsd_filename));
												continue;
											}

					case enSVCloseFile:
						num_args_received = sscanf(original_input_str.c_str(), "%s %d\n", command_char, &file_index);
						if (num_args_received != 2)
						{
							out_to_all_streams("Error: Usage is close_file file_index\n");
							continue;
						} else
						{
							result_str << linnux_sd_card_fclose(file_index);
							continue;
						}

					case enSVCloseAllFiles : result_str << linnux_sd_card_close_all_files();
					                         out_to_all_streams("Closed a total of: " << result_str.str() << " files\n");
					                         continue;

					case enSVRename:
						num_args_received = sscanf(original_input_str.c_str(), "%s %s %s\n", command_char, catsd_filename, bitpattern_filename_str);
						if (num_args_received != 3)
						{
							out_to_all_streams("Error: Usage is rm src dest\n");
							continue;
						} else
						{
							f_rename(catsd_filename, bitpattern_filename_str);
							continue;
						}

					case enSVCopyFile:
						num_args_received = sscanf(original_input_str.c_str(), "%s %s %s\n", command_char, catsd_filename, bitpattern_filename_str);
						if (num_args_received != 3)
						{
							out_to_all_streams("Error: Usage is cp src dest\n");
							continue;
						} else
						{
							fatfs_copy_file(catsd_filename, bitpattern_filename_str);
							continue;
						}

					case enSVMountSD:
						if (fatfs_mount_SD_drive())
						{
							if (fatfs_check_init_SD_drive())
							{
								out_to_all_streams("SD Card Mounted Successfully!\n");
							}
						} else
						{
							out_to_all_streams("SD Card Mounted unsuccessful!\n");
						}
						continue;

					case enSVUnMountSD:
						if (fatfs_unmount_SD_drive())
						{
							out_to_all_streams("SD Card Unmounted successfully!\n");
						} else
						{
							out_to_all_streams("SD Card Unmount unsuccessful!\n");
						}
						continue;

					case enSVMkdir:
						num_args_received = sscanf(input_str.c_str(), "%s %s\n", command_char, catsd_filename);
						if (num_args_received != 2)
						{
							out_to_all_streams("Error: Usage is mkdir dirname");
							continue;
						} else
						{
							result_str << f_mkdir(catsd_filename);
							continue;
						}

					case enSVChdir:
						num_args_received = sscanf(input_str.c_str(), "%s %s\n", command_char, catsd_filename);
						if (num_args_received != 2)
						{
							out_to_all_streams("Error: Usage is chdir filename\n");
							continue;
						} else
						{
							result_str <<  f_chdir(catsd_filename);
							continue;
						}

					case enSVPwd:
						f_getcwd(catsd_filename, 1024);
						outp("Current path is: " << string(catsd_filename) << endl);
						result_str << string(catsd_filename);
						continue;

					case enSVuParse:
						argument_str_pos_start = original_input_str.find(" ");
						if (argument_str_pos_start != string::npos)
						{
							argument_str = original_input_str.substr(argument_str_pos_start + 1);
						}
						TrimSpaces(argument_str);
						//out_to_all_streams("\n[Linnux Main] Evaluating: [" << argument_str << "]\n");
						//safe_print(std::cout << "\n[Linnux Main] Evaluating: [" << argument_str << "]\n");
						tmpstr = linnux_uparse(argument_str);
						result_str << tmpstr;
						outp("Result: [" << tmpstr << "]" << std::endl);
						//out_to_all_streams("[Linnux Main]Result: [" << tmpstr << "]\n");
						//safe_print(std::cout << "[Linnux Main]Result: [" << tmpstr << "]" << std::endl);
						continue;


					case enSVExprtk:
						argument_str_pos_start = original_input_str.find(" ");
						if (argument_str_pos_start != string::npos)
						{
							argument_str = original_input_str.substr(argument_str_pos_start + 1);
						}
						TrimSpaces(argument_str);
						//out_to_all_streams("\n[Linnux Main] Evaluating: [" << argument_str << "]\n");
						//safe_print(std::cout << "\n[Linnux Main] Evaluating: [" << argument_str << "]\n");
						tmpstr = linnux_exprtk_uparse(argument_str);
						result_str << tmpstr;
						outp("Result: [" << tmpstr << "]" << std::endl);
						//out_to_all_streams("[Linnux Main]Result: [" << tmpstr << "]\n");
						//safe_print(std::cout << "[Linnux Main]Result: [" << tmpstr << "]" << std::endl);
						continue;

					case enSVExprtkTest:  int exprk_test_result;
					                      outp("Starting exprtk test: [" <<  command_argument1 << "]" << std::endl);
					                      exprk_test_result = exprtk_test(command_argument1);
					                      outp("Exprtk test result: [" <<  exprk_test_result << "]" << std::endl);
						                  continue;
					case enSVTime:
						result_str << time(NULL);
						outp("Time (secs) = " << result_str.str() << endl);
						continue;



					case enSVMem: memh_info = mem_display(0);
					              result_str << memh_info.current_alloc << " " << memh_info.max_alloc;
					              if ( memh_info.current_alloc < 0) {
					                  out_to_all_streams("Error: MEM package not enabled, heap allocation is not tracked (received heap count =" <<  memh_info.current_alloc << ")" << std::endl);
					              } else {
					            	  outp("Total number of allocated bytes in heap under MEM control: " << memh_info.current_alloc << std::endl);
					            	  outp("Total MAX number of allocated bytes in heap under MEM control: " << memh_info.max_alloc << std::endl);
					              }
					              if (MEM_WRAPPERS) {
					                heap_usage = (long)brmem.brallocb - (long)brmem.brfreeb;
					                result_str << " " << heap_usage;
					                outp("Total number of allocated bytes in heap under NicheStack Wrap control: " << heap_usage << std::endl);
					              } else {
					            	     out_to_all_streams("Error: NicheStack Wrap package not enabled, NicheStack heap allocation is not tracked (received heap count =" << heap_usage << ")" << std::endl);
					              }
						          continue;



					case enSVReconnectJTAG : if (!cout.good())
												{
						                           out_to_all_streams("Cout is indeed bad!\n");
												} else
											    {
													out_to_all_streams ("Cout not detected as bad.\n");
												 }
					                           if (!cin.good())
												{
					                        	   out_to_all_streams("Cin is indeed bad!\n");
												} else
												{
													out_to_all_streams("Cin not detected as bad.\n");
												 }
					                           fflush(NULL); //flush all cstdio streams

					                           clearerr(stdout);
					                           clearerr(stdin);
					                           clearerr(stderr);

					                           cin.clear();
					                           cout.clear();
											   cout.flush();
											   cout.sync_with_stdio();
											   cin.sync_with_stdio();
											   cin.clear();
											   cout.clear();
							 				   cout.flush();
											   continue;

					case enSVdisableJTAGUART:{
					                            alt_io_redirect("/dev/null", "/dev/null", "/dev/null");
					                            outp("Disabled JTAG UART\n");
						                        continue;
					                         };

					case enSVenableJTAGUART :{
 					                            alt_io_redirect(ALT_STDOUT, ALT_STDIN, ALT_STDERR);
 					                            reconnect_jtag();
 					                            outp("Enabled JTAG UART\n");
						                        continue;
									         };


					case enSVSetLEDMask: if (num_args_received != 2)
						                 {
						                    out_to_all_streams("Error: Usage is set_led_mask val (hexadecimal number)\n");
						                 	continue;
						                 } else
						                 {
						                 	//set_led_mask(command_argument1);
						                 	outprintf("Set LED mask to (%6lX)\n", command_argument1);
						                 	result_str << command_argument1;
						                 	continue;
						                 }

					case enSVDisablePRBSGen0:out_to_all_streams("Disabled PRBS Generator 0\n");
					                         do_not_start_prbs_generator_0 = 1;
					                         continue;

					case enSVEnablePRBSGen0:out_to_all_streams("Enabled PRBS Generator 0 \n");
					                        do_not_start_prbs_generator_0 = 0;
					                        continue;

	               case enSVEnterEthernetQuietMode:  out_to_all_streams("Entering Ethernet Quiet Mode \n");
					                             we_are_in_ethernet_quiet_mode = 1;
					                             continue;

					case enSVExitEthernetQuietMode: we_are_in_control_verbose_mode = 0;
					                             out_to_all_streams("Exiting Ethernet Quiet Mode\n");
										         continue;

                    case enSVEnterControlExtraVerboseMode:  out_to_all_streams("Entering Control Verbose Mode\n");
                                                 we_are_in_control_verbose_mode = 1;
					                             continue;

					case enSVExitControlExtraVerboseMode: we_are_in_control_verbose_mode = 0;
					                             out_to_all_streams("ExitingControl Verbose Mode\n");
										         continue;

					case enSVEnableSemaphoreLogging  :  enable_semaphore_information_logging = 1;
						                                out_to_all_streams("Enabling Ethernet Logging\n");
						                                continue;

					case enSVDisableSemaphoreLogging : enable_semaphore_information_logging = 0;
						                               out_to_all_streams("Disabling Ethernet Logging\n");
						                               continue;

					case enableUCOSStatisticsGathering  :  enable_ucos_statistics_gathering = 1;
						                                out_to_all_streams("Enabling UCOS Statistics Gathering\n");
						                                continue;

					case disableUCOSStatisticsGathering : enable_ucos_statistics_gathering = 0;
						                               out_to_all_streams("Disabling UCOS Statistics Gathering\n");
						                               continue;
					case enSVMemCheck : out_to_all_streams("Doing Memory Check  (on stdout only!).......");
 				 	                    send_myostream_to_ethernet_stdout();
 				 	                    usleep(2000000); //allow output to reach remote telnet terminals
					                    mem_check();
					                    out_to_all_streams("Finished Memory Check");
                                        continue;

					case enSVMemDisplay : out_to_all_streams("Displaying Memory (on stdout only!)......." << std::endl);
	                                      send_myostream_to_ethernet_stdout();
	                                      usleep(2000000); //allow output to reach remote telnet terminals

	                                      memh_info = mem_display(1);
	                                       result_str << memh_info.current_alloc << " " << memh_info.max_alloc;
	                                       if ( memh_info.current_alloc < 0) {
	                                           out_to_all_streams("Error: MEM package not enabled, heap allocation is not tracked (received heap count =" <<  memh_info.current_alloc << ")" << std::endl);
	                                       } else {
	                                     	  outp("Total number of allocated bytes in heap under MEM control: " << memh_info.current_alloc << std::endl);
	                                     	  outp("Total MAX number of allocated bytes in heap under MEM control: " << memh_info.max_alloc << std::endl);
	                                       }

	                                       if (MEM_WRAPPERS) {
											  heap_usage = (long)brmem.brallocb - (long)brmem.brfreeb;
											  result_str << " " << heap_usage;
													  outp("Total number of allocated bytes in heap under NicheStack Wrap control: " << heap_usage << std::endl);
													  outp(tfm::format("wrappers: allocs: %lu,  frees: %lu,  allocbytes: %lu   freebytes: %lu\n alloced: current bytes: %ld  max bytes: %lu\n biggest block: %u,  allocs failed: %lu\n",
														   brmem.brallocs, brmem.brfrees, brmem.brallocb, brmem.brfreeb, (long)brmem.brallocb - (long)brmem.brfreeb, brmem.brmaxmem, brmem.brmaxsize, brmem.brfailed));
                            			  } else {
                        				       out_to_all_streams("Error: NicheStack Wrap package not enabled, NicheStack heap allocation is not tracked (received heap count =" << heap_usage << ")" << std::endl);
	                                       }
						                  continue;

					case  enSVOpenLogFile: num_args_received = sscanf(input_str.c_str(), "%s %s\n", command_str, cmd_str);
											if (num_args_received != 2)
											{
												out_to_all_streams("Error: Usage is  start_logging_to_file filename\n");
											} else
											{
												if (manual_log_file.is_open())
												{
													out_to_all_streams("Error: Please close existing log file first via the command finish_logging_to_file\n");
												} else
												{

													manual_log_filename << LINNUX_AUTO_LOG_FILE_NAME_PREFIX << string(cmd_str);
													if ((manual_log_file_error = manual_log_file.open_for_write(manual_log_filename.str())) != LINNUX_RETVAL_ERROR)
													{
														manual_log_file.write_str("##############################################\n");
														manual_log_file.write_str("Linnux Log file\n");
														manual_log_file.write_str("##############################################\n");
													} else
													{
														out_to_all_streams_safe("Error in opening file [" << manual_log_filename.str() << "], error is: " << manual_log_file_error << std::endl);
													}
												}
											}
						                   continue;

					case enSVCloseLogFile:  if (manual_log_file.close())
											{
												out_to_all_streams_safe("Closed file: [" << manual_log_file.get_filename() << "] succesfully\n" <<std::endl);
											} else
											{
												out_to_all_streams_safe("Error while closing file: [" << manual_log_file.get_filename() << "] succesfully\n" <<std::endl);
											}
						                    continue;
#ifdef  LEGACY_ITEMS_HAVE_BEEN_INCLUDED_IN_SYSTEM
					case enSVDisplayEyeDMatrix:
						//if (force_empty_sjtol_function)
						//{
						//  	cout << "Warning: in SJTOL test mode, not performing eyed  operation\n";
						//	continue;
						//}
						long num_eyed_symbols, num_eyed_samples_per_capture;
						num_args_received = sscanf(input_str.c_str(), "%s %ld %ld > %s\n", command_char, &num_eyed_symbols, &num_eyed_samples_per_capture, redirect_filename);
						if (num_args_received < 3)
						{
							outp("Error: Usage is: eyed_print num_symbols num_samples_per_capture [> filename]  (all numbers are decimal number)\n");
							continue;
						} else
						{
							eyed_strs = EyeD_FIFO_Container.acquire_and_print_eyed_mat(num_eyed_symbols, num_eyed_samples_per_capture, actual_redirect_filename);
							result_str << "\"" << eyed_strs[0] << "\" \"" << eyed_strs[1] << "\"" << " \"" << eyed_strs[2] << "\"";
							outp(eyed_strs[1]);
							continue;
						}


					case enSVGetEyeDPeaktoPeak:
						                       // if (force_empty_sjtol_function)
						                       // {
						                       // 	cout << "Warning: in SJTOL test mode, not performing eyed pkpk operation\n";
						                       // 	continue;
						                       // }
						                        //eyed_strs = EyeD_FIFO_Container.acquire_and_print_eyed_mat(PK_PK_MEASUREMENT_NUM_EYED_SYMBOLS, PK_PK_MEASUREMENT_NUM_EYED_SAMPLES_PER_CAPTURE, "");
						                        //outp(eyed_strs[1]);
						                        EyeD_FIFO_Container.set_num_eyed_samples_per_capture(PK_PK_MEASUREMENT_NUM_EYED_SAMPLES_PER_CAPTURE);
												EyeD_FIFO_Container.acquire_eyed_mat(PK_PK_MEASUREMENT_NUM_EYED_SYMBOLS);
                                                pk_to_pkval = EyeD_FIFO_Container.get_peak_to_peak_value();
					                            result_str << pk_to_pkval;
					                            outp("Peak to Peak value is: " << pk_to_pkval);
					                            continue;


					case enSVSetEyeDTriggerClk:
						sscanf(input_str.c_str(), "%s %lX\n", command_char, &command_argument1);
						if (num_args_received != 2)
						{
							outp("Error: usage is set_eyed_trigger_clock clk_id (=0 for jittered clock, =1 for unjittered clock)\n");
							continue;
						}
						if (command_argument1)
							EyeD_FIFO_Container.set_EYED_clock_to_jitter_free_clock();
						else
							EyeD_FIFO_Container.set_EYED_clock_to_jittered_clock();
						continue;


					case enSVSelectCorrFIFOInput:
						unsigned int corr_fifo_input_sel;
						num_args_received = sscanf(input_str.c_str(), "%s %u\n", command_char, &corr_fifo_input_sel);
						if (num_args_received != 2)
						{
							outp("Error: Usage is: select_corr_fifo_input sel (decimal number)\n");
							continue;
						} else
						{
							Corr_FIFO_Container.select_corr_fifo_input(corr_fifo_input_sel);
							continue;
						}
#endif

					case enSVEnableFIFOAcquisition :
						                        num_args_received = sscanf(input_str.c_str(), "%s %d\n", command_char, &fifo_num);
												if (num_args_received < 2)
												{
													outp("Error: Usage is: enable_fifo_acquisition fifo_num\n");
													outp("fifo display format is 0 for decimal 1 for hex, 2 for binary.\n");
													outp(print_fifo_help_string(fifo_pointer_vector));
													continue;
												} else
												{
													if ((fifo_num >= 0) && (fifo_num < fifo_pointer_vector.size()))
													{
														current_fifo_container_ptr = fifo_pointer_vector.at(fifo_num);
														if (current_fifo_container_ptr == NULL) {
															outp("Error: FIFO " << fifo_num << "is not enabled!\n");
															continue;
														}
													} else
													{
														outp("Error: unknown FIFO requested\n");
														continue;
													}
													current_fifo_container_ptr->set_up_fifo_for_acquisition();
													continue;
												}

					case enSVCompleteFIFOAcquisition:
						                        num_args_received = sscanf(input_str.c_str(), "%s %d %d %d > %s\n", command_char, &fifo_num, &verbose_fifo_print, &fifo_display_format, redirect_filename);
												if (num_args_received < 4)
												{
													outp("Error: Usage is: get_fifo_data fifo_num verbose fifo_display_format [> filename] \n");
													outp("fifo display format is 0 for decimal 1 for hex, 2 for binary.\n");
													outp(print_fifo_help_string(fifo_pointer_vector));
													continue;
												} else
												{
													if ((fifo_num >= 0) && (fifo_num < fifo_pointer_vector.size()))
													{
														current_fifo_container_ptr = fifo_pointer_vector.at(fifo_num);
														if (current_fifo_container_ptr == NULL) {
															outp("Error: FIFO " << fifo_num << "is not enabled!\n");
															continue;
														}
													} else
													{
														outp("Error: unknown FIFO requested\n");
														continue;
													}
													if (actual_redirect_filename == "")
													{
														current_fifo_container_ptr->complete_FIFO_acquisition_and_print_to_console((LINNUX_FIFO_DATA_FORMATS) fifo_display_format,  verbose_fifo_print);
													} else
													{
														current_fifo_container_ptr->capture_and_save_to_file(actual_redirect_filename, (LINNUX_FIFO_DATA_FORMATS)fifo_display_format, 1, 1);
													}
													current_fifo_data = current_fifo_container_ptr->get_fifo_last_read_contents();
													//result_str << "\"[ list " << convert_vector_to_string<unsigned long> (current_fifo_data) << " ]\"";
													result_str << convert_vector_to_string<unsigned long> (current_fifo_data);
													continue;
												}


					case enSVGetFIFOULong:
						num_args_received = sscanf(input_str.c_str(), "%s %d %d %d\n", command_char, &fifo_num, &verbose_fifo_print, &fifo_display_format);
												if (num_args_received < 4)
												{
													outp("Error: Usage is: get_fifo_data_ulong fifo_num verbose fifo_display_format \n");
													outp("fifo display format is 0 for decimal 1 for hex, 2 for binary. \n");
													print_fifo_help_string(fifo_pointer_vector);
													continue;
												} else
												{
													if ((fifo_num >= 0) && (fifo_num <= fifo_pointer_vector.size()))
													{
														current_fifo_container_ptr = fifo_pointer_vector.at(fifo_num);
														if (current_fifo_container_ptr == NULL) {
															outp("Error: FIFO " << fifo_num << "is not enabled!\n");
															continue;
														}
													} else
													{
														outp("Error: unknown FIFO requested\n");
														continue;
													}
													current_fifo_container_ptr->capture_only();
													binary_response=current_fifo_container_ptr->get_ptr_to_contents();
													continue;

												}
					case enSVGetFIFOULongNoAquire:
						                        num_args_received = sscanf(input_str.c_str(), "%s %d %d %d\n", command_char, &fifo_num, &verbose_fifo_print, &fifo_display_format);
												if (num_args_received < 4)
												{
													outp("Error: Usage is: get_fifo_data_ulong_nowait fifo_num verbose fifo_display_format \n");
													outp("fifo display format is 0 for decimal 1 for hex, 2 for binary. \n");
													print_fifo_help_string(fifo_pointer_vector);
													continue;
												} else
												{
													if ((fifo_num >= 0) && (fifo_num <= fifo_pointer_vector.size()))
													{
														current_fifo_container_ptr = fifo_pointer_vector.at(fifo_num);
														if (current_fifo_container_ptr == NULL) {
															outp("Error: FIFO " << fifo_num << "is not enabled!\n");
															continue;
														}
													} else
													{
														outp("Error: unknown FIFO requested\n");
														continue;
													}
													current_fifo_container_ptr->capture_only(0); //no not aquire fifo
													binary_response=current_fifo_container_ptr->get_ptr_to_contents();
													continue;

												}
					case enSVGetFIFO:
						num_args_received = sscanf(input_str.c_str(), "%s %d %d %d > %s\n", command_char, &fifo_num, &verbose_fifo_print, &fifo_display_format, redirect_filename);
						if (num_args_received < 4)
						{
							outp("Error: Usage is: get_fifo_data fifo_num verbose fifo_display_format [> filename] \n");
							outp("fifo display format is 0 for decimal 1 for hex, 2 for binary.\n");
							print_fifo_help_string(fifo_pointer_vector);
							continue;
						} else
						{
							if ((fifo_num >= 0) && (fifo_num < fifo_pointer_vector.size()))
							{
								current_fifo_container_ptr = fifo_pointer_vector.at(fifo_num);
								if (current_fifo_container_ptr == NULL) {
									outp("Error: FIFO " << fifo_num << "is not enabled!\n");
									continue;
								}
							} else
							{
								cout << "Error: unknown FIFO requested\n";
								continue;
							}
							if (actual_redirect_filename == "")
							{
								current_fifo_container_ptr->acquire_and_print_contents_to_console((LINNUX_FIFO_DATA_FORMATS) fifo_display_format,  verbose_fifo_print);
							} else
							{
								current_fifo_container_ptr->capture_and_save_to_file(actual_redirect_filename, (LINNUX_FIFO_DATA_FORMATS)fifo_display_format, 1);
							}
							current_fifo_data = current_fifo_container_ptr->get_fifo_last_read_contents();
							//result_str << "\"[ list " << convert_vector_to_string<unsigned long> (current_fifo_data) << " ]\"";
							result_str << convert_vector_to_string<unsigned long> (current_fifo_data);


							/*nonzero_elements_count = 0;
					 current_fifo_data = current_fifo_container_ptr->get_fifo_last_read_contents();
					 for (current_fifo_element_index = 0; current_fifo_element_index < ((unsigned long) current_fifo_data.size()); current_fifo_element_index++)
					 {
					 //cout << current_fifo_data[current_fifo_element_index] << "...";
					 nonzero_elements_count += current_fifo_data[current_fifo_element_index] > 0xFF;
					 }
					 cout << "Fifo Contains: " << nonzero_elements_count << " non-zero elements " << " gone through " << current_fifo_element_index << " elements, size = "
					 << current_fifo_container_ptr->get_fifo_last_read_contents().size() << " " << ((unsigned long) current_fifo_data.size()) << "\n";
							 */
							continue;

						}

					case enSVMultipleGetFIFO:
						num_args_received = sscanf(input_str.c_str(), "%s %d %d %d %d > %s\n", command_char, &fifo_num, &verbose_fifo_print, &fifo_display_format, &num_fifo_capture_iterations,
								redirect_filename);
						if (num_args_received < 5)
						{
							outp("Error: Usage is: get_fifo_data fifo_num verbose fifo_display_format num_fifo_capture_iterations [> filename] \n");
							outp("fifo display format is 0 for decimal 1 for hex, 2 for binary.\n");
							outp(print_fifo_help_string(fifo_pointer_vector));
							continue;
						} else
						{
							if ((fifo_num >= 0) && (fifo_num < fifo_pointer_vector.size()))
							{
								current_fifo_container_ptr = fifo_pointer_vector.at(fifo_num);
								if (current_fifo_container_ptr == NULL) {
									outp("Error: FIFO " << fifo_num << "is not enabled!\n");
									continue;
								}
							} else
							{
								cout << "Error: unknown FIFO requested\n";
								continue;
							}
							cumulative_fifo_data0.clear();
							string total_capture_str_fifo;
							total_capture_str_fifo = "";

							for (int i = 0; i < num_fifo_capture_iterations; i++)
							{
								cout << "\nAcquiring " << current_fifo_container_ptr->get_description() << " Iteration " << i << "\n===================\n";
								if (current_fifo_container_ptr->capture_and_save_to_string(total_capture_str_fifo, (LINNUX_FIFO_DATA_FORMATS)fifo_display_format, (i == 0), (i == (num_fifo_capture_iterations - 1))) == -1)
								{
									cout << "User Requested stop....";
									continue;
								}
								//first.insert(first.end(), second.begin(), second.end());
								current_fifo_data = current_fifo_container_ptr->get_fifo_last_read_contents();
								cumulative_fifo_data0.insert(cumulative_fifo_data0.end(),current_fifo_data.begin(),current_fifo_data.end());
							}
							//result_str << "\"[ list " << convert_vector_to_string<unsigned long>(cumulative_fifo_data0) << " ]\"";
							result_str << convert_vector_to_string<unsigned long>(cumulative_fifo_data0);
							if (actual_redirect_filename == "")
							{
								if (verbose_fifo_print)
								{
									cout << total_capture_str_fifo;
								}
								continue;
							} else
							{
								simult_capture_fileid = linnux_sd_card_file_open_for_write(actual_redirect_filename);
								if (simult_capture_fileid < 0)
								{
									cout << "Error: bad filehandle\n";
									continue;
								}
								linnux_sd_card_write_string_to_file(simult_capture_fileid, total_capture_str_fifo);
								linnux_sd_card_fclose(simult_capture_fileid);
							}
							continue;

						}



					case enSVSimultUARTGPFIFOAcquire:
					case enSVSimultUARTGPFIFOAcquireCompressed:
					case enSVSimultUARTGPFIFOAcquireHWTriggeredData:
					case enSVSimultUARTGPFIFOAcquireHWTriggeredDataCompressed: {
						                        unsigned int primary_uart_num;
						                        unsigned int secondary_uart_num;
						                        int numvalues_to_read;
						                        num_args_received = sscanf(input_str.c_str(), "%s %u %u %d %d %d > %s\n", command_char, &primary_uart_num, &secondary_uart_num, &verbose_fifo_print, &fifo_display_format, &numvalues_to_read, redirect_filename);
												if (num_args_received < 5)
												{
													outp("Error: Usage is: simult_capture_of_uart_nios_dacs verbose fifo_display_format [> filename] \n");
													outp("fifo display format is 0 for decimal 1 for hex, 2 for binary.\n");
													continue;
												}

												if (num_args_received < 6) {
													numvalues_to_read = -1;
												}

												{
													unsigned long long ____time_spent;

													gp_fifo_encapsulator* fifo0_ptr = (gp_fifo_encapsulator*) NULL;
													gp_fifo_encapsulator* fifo1_ptr = (gp_fifo_encapsulator*) NULL;
													uart_register_file* uart_ptr = uart_regfile_repository.get_uart_ptr_from_number(primary_uart_num);
													____time_spent = profile(
													if (uart_ptr == NULL) {
														std::cout << "[simult_capture_of_uart_nios_dacs] Could not find uart # " << primary_uart_num << std::endl;
														std::cout.flush();
														continue;
													}

													for (unsigned i = 0; i < fifo_pointer_vector.size(); i++) {
														if (fifo_pointer_vector.at(i) == NULL) {
															continue;
														}

														fifo_u(
																safe_print(std::cout << " i = " << i << " uart_ptr = " << uart_ptr
																		<< " fifo_pointer_vector.at(i)->get_uart_ptr() = " << fifo_pointer_vector.at(i)->get_uart_ptr()
																		<< " fifo_pointer_vector.at(i)->get_secondary_uart_num() = " << fifo_pointer_vector.at(i)->get_secondary_uart_num()
																		<< " fifo_pointer_vector.at(i)->get_gp_fifo_index() " << fifo_pointer_vector.at(i)->get_gp_fifo_index() << std::endl;);
																std::cout.flush();
                                                        );

														if ((fifo_pointer_vector.at(i)->get_uart_ptr() == uart_ptr) && (fifo_pointer_vector.at(i)->get_secondary_uart_num() == secondary_uart_num) && (fifo_pointer_vector.at(i)->get_gp_fifo_index() == 0))  {
															fifo0_ptr = fifo_pointer_vector.at(i);
														} else
														{
															if ((fifo_pointer_vector.at(i)->get_uart_ptr() == uart_ptr) && (fifo_pointer_vector.at(i)->get_secondary_uart_num() == secondary_uart_num) && (fifo_pointer_vector.at(i)->get_gp_fifo_index() == 1))  {
															   fifo1_ptr = fifo_pointer_vector.at(i);
															}
														}
														if ((fifo0_ptr != (gp_fifo_encapsulator*) NULL) && (fifo1_ptr != (gp_fifo_encapsulator*) NULL)) {
															break;
														}
													}

													if ((fifo0_ptr == (gp_fifo_encapsulator*) NULL) || (fifo1_ptr == (gp_fifo_encapsulator*) NULL)) {
														safe_print(std::cout << "[simult_capture_of_uart_nios_dacs] Could not find FIFOs! fifo0_ptr = " << fifo0_ptr <<  " fifo1_ptr = " << fifo1_ptr << std::endl;);
														std::cout.flush();
														continue;
													}
													);
													fifo_u(
															safe_print(std::cout <<  "Time Spent on finding FIFOs is: " << ____time_spent << " cycles, which is: " << get_timestamp_diff_in_usec(____time_spent) << " usec" << std::endl;);
													);

										            if ((numvalues_to_read > (long) (fifo1_ptr->get_fifo_capacity())) || (numvalues_to_read < 0)) {
											            safe_print(std::cout <<  "Error numvalues_to_read: " << numvalues_to_read << " FIFO capacity is: " << fifo1_ptr->get_fifo_capacity() << ", reverting to latter" << std::endl;);
											            numvalues_to_read = (fifo1_ptr->get_fifo_capacity());
										            }

										            if (fifo0_ptr->get_uses_ext_memory_instead_of_fifos()) {
										               fifo0_ptr->acquire_ext_memory_fifo(numvalues_to_read); //no need to call second fifo acquisition because external memory acqs always simultaneous
										               /*
										               std::vector<unsigned long> tempvec(numvalues_to_read*2,1234);
										               //std::stringstream result;
										               std::copy(tempvec.begin(), tempvec.end(), std::ostream_iterator<unsigned long>(result_str, " "));

											           //append_vector_to_ostringstream<unsigned long>(tempvec,result_str);
											           */
											           continue;

										               //fifo0_ptr->transfer_ext_memory_fifo_data(numvalues_to_read);
										               //fifo1_ptr->transfer_ext_memory_fifo_data(numvalues_to_read);
										            } else {
																if ((mapped_val == enSVSimultUARTGPFIFOAcquireHWTriggeredData) || (mapped_val == enSVSimultUARTGPFIFOAcquireHWTriggeredDataCompressed)) {

																		fifo0_ptr->enable_simult_fifo_capture();
																		fifo0_ptr->set_up_fifo_for_acquisition(0);
																		fifo1_ptr->set_up_fifo_for_acquisition(0);
																		fifo0_ptr->complete_FIFO_acquisition_and_print_to_console((LINNUX_FIFO_DATA_FORMATS) fifo_display_format, verbose_fifo_print, numvalues_to_read);
																		fifo1_ptr->complete_FIFO_acquisition_and_print_to_console((LINNUX_FIFO_DATA_FORMATS) fifo_display_format, verbose_fifo_print, numvalues_to_read);
																		fifo0_ptr->flush_FIFO_contents();
																		fifo1_ptr->flush_FIFO_contents();
																		fifo0_ptr->disable_simult_fifo_capture();
																} else {
																		if (actual_redirect_filename == "")
																		{
																			____time_spent = profile (
																			fifo0_ptr->enable_simult_fifo_capture();
																			fifo1_ptr->set_up_fifo_for_acquisition();
																			fifo_u(outp("\nGP Fifo 0 Contents\n===================\n"););
																			fifo0_ptr->acquire_and_print_contents_to_console((LINNUX_FIFO_DATA_FORMATS) fifo_display_format, verbose_fifo_print,0,numvalues_to_read);
																			fifo_u(outp("\nGP Fifo 1 Contents\n===================\n"););
																			fifo1_ptr->complete_FIFO_acquisition_and_print_to_console((LINNUX_FIFO_DATA_FORMATS) fifo_display_format, verbose_fifo_print,numvalues_to_read);
																			fifo0_ptr->disable_simult_fifo_capture();
																			);

																			fifo_u(safe_print(std::cout <<  "Time Spent on actual FIFO acquisition is: " << ____time_spent << " cycles, which is: " << get_timestamp_diff_in_usec(____time_spent) << " usec" << std::endl;));

																		} else
																		{
																			fifo0_ptr->enable_simult_fifo_capture();
																			fifo1_ptr->set_up_fifo_for_acquisition();
																			fifo_u(outp("\nGP Fifo 0 Contents\n===================\n"););
																			simult_capture_fileid = fifo0_ptr->capture_and_save_to_file(actual_redirect_filename, (LINNUX_FIFO_DATA_FORMATS) fifo_display_format, 0,0,numvalues_to_read);
																			fifo_u(outp("\nGP Fifo 1 Contents\n===================\n"););
																			fifo1_ptr->complete_fifo_capture(simult_capture_fileid, (LINNUX_FIFO_DATA_FORMATS) fifo_display_format, 1, numvalues_to_read);
																			fifo0_ptr->disable_simult_fifo_capture();
																		}
																}
												    }
										            if ((mapped_val == enSVSimultUARTGPFIFOAcquireCompressed)  || (mapped_val == enSVSimultUARTGPFIFOAcquireHWTriggeredDataCompressed)) {
										            	fifo_u(std::cout <<  "Starting Compression..." << std::endl; std::cout.flush(););
										            	____time_spent = profile (
										            	 std::ostringstream tempstream;
										            	 append_vector_to_ostringstream<unsigned long>(fifo0_ptr->get_fifo_last_read_contents(),tempstream);
										            	 tempstream << " ";
										            	 append_vector_to_ostringstream<unsigned long>(fifo1_ptr->get_fifo_last_read_contents(),tempstream);
										            	 result_str << compress_and_convert_c_string_to_base64(tempstream.str().c_str(),tempstream.str().length());
										            	 );
										            	fifo_u(std::cout <<  "Time Spent on converting fifo results vector to compressed base64 string is: " << ____time_spent << " cycles, which is: " << get_timestamp_diff_in_usec(____time_spent) << " usec" << std::endl;);
										            } else {

											            ____time_spent = profile (
											            append_vector_to_ostringstream<unsigned long>(fifo0_ptr->get_fifo_last_read_contents(),result_str);
											            result_str << " ";
											            append_vector_to_ostringstream<unsigned long>(fifo1_ptr->get_fifo_last_read_contents(),result_str);
											            );
											            //std::cout <<  "Time Spent on converting fifo results vector to string is: " << ____time_spent << " cycles, which is: " << get_timestamp_diff_in_usec(____time_spent) << " usec" << std::endl;
										            }

													continue;

												}
												continue;
					}

						continue;

						case enSVSimultMultiPacketizerAcquire                          :
						case enSVSimultMultiPacketizerAcquireCompressed                :
						case enSVSimultMultiPacketizerAcquireHWTriggeredData           :
						case enSVSimultMultiPacketizerAcquireHWTriggeredDataCompressed : {
													unsigned int packetizer_index;
							                        int numvalues_to_read;

													num_args_received = sscanf(input_str.c_str(), "%s %u %u\n", command_char, &packetizer_index, &numvalues_to_read);

													if (num_args_received < 2)
													{
														outp("Error: wrong num of parameters for acquiring multi stream packetizer\n");
														std::cout << "Error: wrong num of parameters for acquiring multi stream packetizer\n" << std::endl;
														continue;
													}

													if (num_args_received < 3) {
														numvalues_to_read = -1;
													}

													if (multi_stream_packetizer_vector.size() <= packetizer_index) {
														outp(" Error:packetizer_index = " << packetizer_index << "multi_stream_packetizer_vector.size() = " << multi_stream_packetizer_vector.size()  <<  "\n");
														std::cout << " Error:packetizer_index = " << packetizer_index << "multi_stream_packetizer_vector.size() = " << multi_stream_packetizer_vector.size()  <<  "\n" << std::endl;
														continue;
													}

													 result_str << multi_stream_packetizer_vector.at(packetizer_index)->acquire_data(numvalues_to_read); //no need to call second fifo acquisition because external memory acqs always simultaneous
											         outp(result_str.str());
													 continue;
                                 				}

						case enSVGetIndexedMemParams : {
							unsigned int memory_index;
							num_args_received = sscanf(input_str.c_str(), "%s %u\n", command_char, &memory_index);

						     if (num_args_received < 2)
						     {
						    	std::string error_message = "Error: wrong num of parameters for acquiring multi stream packetizer";
						        result_str  << "0 " << error_message;

						     	outp(error_message);
						     	outp("\n");

						     	std::cout << error_message << std::endl;
						     	continue;
						     }
						    unsigned int memory_region_base;
						    unsigned int memory_region_length;
							int res = get_mem_region_data_for_http_file_download(memory_index,&memory_region_base,&memory_region_length);
							if (!res) {
								std::string error_message = "Error while finding memory region";
								result_str  << "0 " << error_message << " " << memory_index;

								outp(error_message);
								outp("\n");

								std::cout << error_message << std::endl;
								continue;
							}
							result_str << "1 " << memory_region_base << " " << memory_region_length;
						    outp(result_str.str());
						} ; continue;

#ifdef UDP_INSERTER_0_BASE
					case enSVUDPStreamStart:{
						                          int stream_num, ip_int_0, ip_int_1, ip_int_2, ip_int_3, ip_port;
														num_args_received = sscanf(input_str.c_str(), "%s %d %d.%d.%d.%d %d\n",
																command_char,
																&stream_num,
																&ip_int_0,
																&ip_int_1,
																&ip_int_2,
																&ip_int_3,
																&ip_port
																);
														if (num_args_received < 7)
														{
															out_to_all_streams("Error: Usage is: udp_stream_start stream_index ip_addr port\n");
															result_str << "0 ERROR: Streamer index out of range";
															continue;
														} else
														{
															if ((stream_num < 0) || ( stream_num >= udp_streamers.size())) {
																out_to_all_streams("Error: Usage is: udp_stream_start stream_index ip_addr port, stream " << stream_num << " is invalid\n");
																result_str << "0 ERROR: Streamer index out of range";
																continue;
															}
															int error_val = udp_streamers.at(stream_num).start_udp_stream(ip_int_0, ip_int_1, ip_int_2, ip_int_3, ip_port,NULL);
															if (error_val != LINNUX_RETVAL_ERROR) {
															    outp("UDP Stream " << stream_num << " Started!\n");
															    result_str << "1 OK";
															} else {
																outp("Error starting UDP Stream " << stream_num << "\n");
																result_str << "0 ERROR";
															}
														}
														continue;
					                       }

					case	enSVUDPStreamStop:
					                                          {
											                          int stream_num;
																			num_args_received = sscanf(input_str.c_str(), "%s %d\n",
																					command_char,
																					&stream_num
																					);
																			if (num_args_received < 2)
																			{
																				out_to_all_streams("Error: Usage is: udp_stream_stop stream_index\n");
																				result_str << "0 ERROR: Usage is: udp_stream_stop stream_index";
																				continue;
																			} else
																			{
																				if ((stream_num < 0) || ( stream_num >= udp_streamers.size())) {
																					out_to_all_streams("Error: Usage is: udp_stream_stop stream_index stream " << stream_num << " is invalid\n");
																					result_str << "0 ERROR: Streamer index out of range";
																					continue;
																				}
																				int error_val = udp_streamers.at(stream_num).stop_udp_stream(NULL);
																				if (error_val != LINNUX_RETVAL_ERROR) {
																				    outp("UDP Stream " << stream_num << " Stopped!\n");
																				    result_str << "1 OK";
																				} else {
																					outp("Error Stopping UDP Stream " << stream_num << "\n");
																					result_str << "0 ERROR";
																				}
																			}
																			continue;
										                       }
#endif
					case enSVGetActiveDevices : result_str << ACTIVE_DEVICES_STRING;
					                            outp(result_str.str());
							                    continue;

					case enSVTriggerVMEFIFOs : {
						if (vme_fifo_ptr != NULL) {
							vme_fifo_ptr->trigger(NULL);
							outp("Triggered ADC FIFOs\n");

						} else {
							safe_print(std::cout << "Error: No VME FIFOs present!" << std::endl);
							continue;
						}

					}
					continue;

					case enSVReleaseTriggerForVMEFIFOs : {
						if (vme_fifo_ptr != NULL) {
							vme_fifo_ptr->release_trigger(NULL);
							outp("Released ADC FIFO Trigger\n");
						} else {
							safe_print(std::cout << "Error: No VME FIFOs present!" << std::endl);
						}
						continue;
					}
                    continue;

					case enSVClearVMEFIFOs:{
						if (vme_fifo_ptr != NULL) {
							vme_fifo_ptr->clear_fifos(NULL);
							outp("Cleared ADC FIFOs\n");
						} else {
							safe_print(std::cout << "Error: No VME FIFOs present!" << std::endl);
						}
						continue;
					}
					continue;

					case enSVAcquireMultipleVMEFIFOs : {
						num_args_received = sscanf(original_input_str.c_str(), "%1000s %1000s\n", command_char, catsd_filename);
						if (num_args_received != 2)
						{
								out_to_all_streams("Error: Usage is acquire_multiple_adc_fifos comma_separated_fifo_indices\n");
								continue;
						}
						std::vector<unsigned> fifos_to_acquire = convert_string_to_vector<unsigned>(std::string(catsd_filename),",");
						outp("FIFOs that will be acquired: requested: ( "<< catsd_filename << " ) " << " parsed: (" << convert_vector_to_string<unsigned>(fifos_to_acquire) << ")\n");
						result_str << convert_vector_of_vectors_to_string<unsigned long>(vme_fifo_ptr->trigger_and_acquire_multiple_fifos(fifos_to_acquire));
		                outp(result_str.str());
		                continue;
					}
					continue;

					case enSVReadMultipleUARTCtrlAndStatus: {
						num_args_received = sscanf(original_input_str.c_str(), "%1000s %4000s\n", command_char, catsd_filename);
						if (num_args_received != 2)
						{
								out_to_all_streams("Error: Usage is uart_multiple_read_all_ctrl_and_status comma_separated_uart_indices\n");
								continue;
						}

						std::vector<std::string> uarts_to_acquire = convert_string_to_vector<std::string>(std::string(catsd_filename),",");
						outp("UARTS thats will be acquired: requested: ( "<< catsd_filename << " ) " << " parsed: (" << convert_vector_to_string<std::string>(uarts_to_acquire) << ")\n");
						result_str << uart_regfile_repository.read_multiple_control_and_status(uarts_to_acquire);
						outp(result_str.str());
						continue;
					}

					case enSVJSONPAcquireMultipleVMEFIFOs : {
						num_args_received = sscanf(original_input_str.c_str(), "%1000s %1000s\n", command_char, catsd_filename);
						if (num_args_received != 2)
						{
								out_to_all_streams("Error: Usage is jsonp_acquire_multiple_adc_fifos comma_separated_fifo_indices\n");
								continue;
						}
						std::vector<unsigned> fifos_to_acquire = convert_string_to_vector<unsigned>(std::string(catsd_filename),",");
						outp("FIFOs that will be acquired: requested: ( "<< catsd_filename << " ) " << " parsed: (" << convert_vector_to_string<unsigned>(fifos_to_acquire) << ")\n");
						multiple_fifo_response_vector_type fifo_acquisition_results = vme_fifo_ptr->trigger_and_acquire_multiple_fifos(fifos_to_acquire);
						result_str << "{";
						for (unsigned i = 0; i < fifos_to_acquire.size(); i++) {
							result_str << "'WADC" << ((fifos_to_acquire.at(i) < 10) ? "0" : "") << fifos_to_acquire.at(i) << "':[";
							//std::vector<unsigned long> current_data = fifo_acquisition_results.at(i);
							result_str << convert_vector_to_string<unsigned long>(fifo_acquisition_results.at(i),0,std::string(","));
							result_str << "]";
							if (i != fifos_to_acquire.size()-1) {
								result_str <<",";
							}
						}
						result_str << "}";
		                outp(result_str.str());
		                continue;
					}
					continue;


					case enSVEnableVMEFifoFlowthrough :
					{
						int fifo_num;
						num_args_received = sscanf(input_str.c_str(), "%s %d\n", command_char, &fifo_num);
						if (num_args_received < 2)
						{
							outp("Error: Usage is: enable_vme_fifo_flowthrough fifo_num\n");
							continue;
						} else
						{
							if (fifo_num < 0 || fifo_num >= VME_FIFO_Vector.size())
							{
							  safe_print(std::cout << "Error: enable_vme_fifo_flowthrough: fifo_num must be between 0 and " << VME_FIFO_Vector.size() -1 << " but got: (" << fifo_num << ") " << std::endl);
							} else
							{
							  VME_FIFO_Vector.at(fifo_num)->enable_flowthrough();
							  safe_print(std::cout << "Flowthrough enabled on FIFO:  " << fifo_num << std::endl);
							}
							continue;
						}
					}

					case enSVDisableVMEFifoFlowthrough:
					                    {
											int fifo_num;
											num_args_received = sscanf(input_str.c_str(), "%s %d\n", command_char, &fifo_num);
											if (num_args_received < 2)
											{
												outp("Error: Usage is: disable_vme_fifo_flowthrough fifo_num\n");
												continue;
											} else
											{
												if (fifo_num < 0 || fifo_num >= VME_FIFO_Vector.size())
												{
												  safe_print(std::cout << "Error: disable_vme_fifo_flowthrough: fifo_num must be between 0 and " << VME_FIFO_Vector.size() -1 << " but got: (" << fifo_num << ") " << std::endl);
												} else
												{
												  VME_FIFO_Vector.at(fifo_num)->disable_flowthrough();
												  safe_print(std::cout << "Flowthrough disabled on FIFO:  " << fifo_num << std::endl);
												}
												continue;
											}
										}

					case enSVDisableVMEFifoWrclk:
					{
						int fifo_num;
						num_args_received = sscanf(input_str.c_str(), "%s %d\n", command_char, &fifo_num);
						if (num_args_received < 2)
						{
							outp("Error: Usage is: disable_vme_fifo_wrclk fifo_num\n");
							continue;
						} else
						{
							if (fifo_num < 0 || fifo_num >= VME_FIFO_Vector.size())
							{
							  safe_print(std::cout << "Error: disable_vme_fifo_wrclk: fifo_num must be between 0 and " << VME_FIFO_Vector.size() -1 << " but got: (" << fifo_num << ") " << std::endl);
							} else
							{
							  VME_FIFO_Vector.at(fifo_num)->disable_wrclk();
							  safe_print(std::cout << "wrclk disabled on FIFO:  << " << fifo_num << std::endl);
							}
							continue;
						}
					}

					case enSVEnableVMEFifoWrclk:
					{
										int fifo_num;
										num_args_received = sscanf(input_str.c_str(), "%s %d\n", command_char, &fifo_num);
										if (num_args_received < 2)
										{
											outp("Error: Usage is: enable_vme_fifo_wrclk fifo_num\n");
											continue;
										} else
										{
											if (fifo_num < 0 || fifo_num >= VME_FIFO_Vector.size())
											{
											  safe_print(std::cout << "Error: enable_vme_fifo_wrclk: fifo_num must be between 0 and " << VME_FIFO_Vector.size() -1 << " but got: (" << fifo_num << ") " << std::endl);
											} else
											{
											  VME_FIFO_Vector.at(fifo_num)->enable_wrclk();
											  safe_print(std::cout << "wrclk enabled on FIFO:  " << fifo_num << std::endl);
											}
											continue;
										}
									}

					case enSVEnterEyeDTestMode :  force_eyed_test_mode = 1;
					                              outp("Entering EyeD Test Mode\n");
											      continue;

					case enSVExitEyeDTestMode: force_eyed_test_mode = 0;
					                           outp("Exiting EyeD Test Mode\n");
					                           continue;

					case enSVSendSMTPHelloSWorld: outp("Sending SMTP hello world...\n");
					                              smtp_hello_world();
                                                  continue;


/*
	case enSVSPITXByte    :  {
						                      unsigned slave_num, byte_to_send;
					                            int spi_tx_result;
									          num_args_received = sscanf(input_str.c_str(), "%s %u %2X\n", command_char, &slave_num, &byte_to_send);
									          outp(std::hex << " recieved SPI TX params: Slave: " << slave_num << " Byte: " << slave_num << std::dec<< std::endl);
									          if (num_args_received < 3)
									          {
									          	outp("Error: Usage is: spi_tx_byte slave_num_decimal byte_hex \n");
									          	continue;
									          } else
									          {
									          	spi_tx_result = spi_master_inst.transmit_byte(slave_num,byte_to_send);
									          	result_str << spi_tx_result;
									          	outp("Result of SPI transmit: " << spi_tx_result << std::endl);
									          	continue;
									          }
					                         }
					case enSVSPIRXByte    :
						                {
												unsigned rx_slave_num;
												unsigned char read_byte;
												int spi_rx_result;
												num_args_received = sscanf(input_str.c_str(), "%s %u\n", command_char, &rx_slave_num);
												outp(std::hex << " recieved SPI read params: Slave: " << rx_slave_num << std::dec<< std::endl);
												if (num_args_received < 2)
												{
													outp("Error: Usage is: spi_rx_byte slave_num_decimal\n");
													continue;
												} else
												{
													spi_rx_result = spi_test_slave_inst.read_byte(rx_slave_num,read_byte);
													result_str << spi_rx_result << " " << read_byte;
													outp("Result of SPI transmit: " << spi_rx_result << " read byte: " << read_byte << std::endl);
													continue;
												}
						                }
										continue;


					case enSVSPITX16bit    :   {
						                        unsigned slave_num, spi_data_to_send;
									            int spi_tx_result;
												num_args_received = sscanf(input_str.c_str(), "%s %u %4X\n", command_char, &slave_num, &spi_data_to_send);
												outp(std::hex << " recieved SPI TX params: Slave: " << slave_num << " 16bits: " << spi_data_to_send << std::dec<< std::endl);
												if (num_args_received < 3)
												{
													outp("Error: Usage is: spi_tx_byte slave_num_decimal 16_bits_hex \n");
													continue;
												} else
												{
													spi_tx_result = spi_master_inst.transmit_16bit(slave_num,spi_data_to_send);
													result_str << spi_tx_result;
													outp("Result of SPI transmit: " << spi_tx_result << std::endl);
													continue;
												}
					                           }
					                          continue;

                   case enSVSPIRX16bit    :
                                      {
                                    	  alt_u16 spi_data;
                                    unsigned rx_slave_num;
                   					int spi_rx_result;
                   					num_args_received = sscanf(input_str.c_str(), "%s %u\n", command_char, &rx_slave_num);
                   					outpc(std::hex << " recieved SPI read params: Slave: " << rx_slave_num << std::dec<< std::endl);
                   					if (num_args_received < 2)
                   				  	{
                   				 		outp("Error: Usage is: spi_rx_16bit slave_num_decimal\n");
                   				 	 	continue;
                   					 } else
                   				 	 {
                   						spi_rx_result = spi_test_slave_inst.read_16bit(rx_slave_num,spi_data);
                   						result_str << spi_rx_result << " " << spi_data;
                   						outpc("Result of SPI transmit: " << spi_rx_result << " read 16bit: " << spi_data << std::endl);
                   				 		continue;
                   					 }
                                    }
                   					continue;

					case enSVSPIGetTXData :  spi_temp = spi_master_inst.get_txdata();
					                    result_str <<spi_temp;
					                    outpc("SPI Master TX Data = 0x" << std::hex << spi_temp << std::dec << std::endl);
					                    continue;

					case enSVSPIGetRXData :  spi_temp = spi_master_inst.get_rxdata();
										result_str <<spi_temp;
										outpc("SPI Master RX Data = 0x" << std::hex << spi_temp << std::dec << std::endl);
										continue;


					case enSVSPITestSlaveGetTXData:
					                             spi_temp = spi_test_slave_inst.get_txdata();
										         result_str <<spi_temp;
										         outpc("SPI Master TX Data = 0x" << std::hex << spi_temp << std::dec << std::endl);
										         continue;

					case enSVSPITestSlaveGetRXData: spi_temp = spi_test_slave_inst.get_rxdata();
												    result_str <<spi_temp;
												    outpc("SPI Master RX Data = 0x" << std::hex << spi_temp << std::dec << std::endl);
													continue;



					case enSVADCWriteReg  :{
											unsigned adc_num, reg, val;
											int spi_tx_result;
											num_args_received = sscanf(input_str.c_str(), "%s %u %2X %4X\n", command_char, &adc_num, &reg, &val);
											outpc( " recieved ADC params: ADC: " << adc_num << std::hex << " reg: 0x" << reg << " val: 0x" << val << std::dec<< std::endl);
											if ((num_args_received < 4) || (adc_num >= NUM_OF_FMC_ADCS))
											{
												outp("Error: Usage is: adc_write_reg adc_num reg_hex 16_bits_hex\n");
												continue;
											} else
											{
												spi_tx_result = adc_controller_vec.at(adc_num).write_reg(reg,val);
												outpc("Result of ADC_Write_Reg SPI transmit: " << spi_tx_result << std::endl);
												continue;
											}
										   }

						                    continue;
				case enSVADCReadReg   : {
					                    unsigned adc_num, reg;
					                    alt_u16 val;
										int spi_tx_result;
										num_args_received = sscanf(input_str.c_str(), "%s %u %2X\n", command_char, &adc_num, &reg);
										outpc("received ADC params: ADC: " << adc_num << std::hex << " reg: 0x" << reg << std::dec<< std::endl);
										if ((num_args_received < 3) || (adc_num >= NUM_OF_FMC_ADCS))
										{
											outp("Error: Usage is: adc_read_reg adc_num reg_hex\n");
											continue;
										} else
										{
											spi_tx_result = adc_controller_vec.at(adc_num).read_reg(reg,val);
											outpc("Result of ADC_read_reg SPI transmit: " << spi_tx_result << " Read val: 0x" << std::hex << val << std::dec << std::endl);
											result_str << val;
											continue;
										}
									   }

						                    continue;
					case enSVADCInit      : {
											unsigned adc_num;
											num_args_received = sscanf(input_str.c_str(), "%s %u\n", command_char, &adc_num);
											outpc("received ADC params: ADC: " << adc_num);
											if ((num_args_received < 2) || (adc_num >= NUM_OF_FMC_ADCS))
											{
												outp("Error: Usage is: adc_init adc_num\n");
												continue;
											} else
											{
												adc_controller_vec.at(adc_num).init();
												continue;
											}
										   }

				                              continue;
					case enSVADCSWReset   : {
												unsigned adc_num;
												num_args_received = sscanf(input_str.c_str(), "%s %u\n", command_char, &adc_num);
												outpc("received ADC params: ADC: " << adc_num);
												if ((num_args_received < 2) || (adc_num >= NUM_OF_FMC_ADCS))
												{
													outp("Error: Usage is: adc_sw_reset adc_num\n");
													continue;
												} else
												{
													adc_controller_vec.at(adc_num).sw_reset();
													continue;
												}
											   }
											continue;

					case enSVHWResetAllADCs:{
						                      adc_aux_control.turn_off_bit(0);
						                      adc_aux_control.turn_on_bit(0);
						                      adc_aux_control.turn_off_bit(0);
						                      outpc("Reset ADCs!" << std::endl);
						                      continue;
											}
											continue;
*/

					case enSVGetUARTEnabledVector :{
						                             //result_str << uart_regfile_repository.get_tcl_vector_of_enable_status();
						                             result_str << uart_regfile_repository.get_tcl_vector_of_all_enable_status();
						                             outp("UART enabled vector is: [" << result_str.str() << "]" << std::endl);
                                                     continue;
					                               } continue;



					case enSVGetUARTPrimaryNumberFromName :{
						                                    num_args_received = sscanf(input_str.c_str(), "%1000s %1000s\n", command_char, &catsd_filename);
															if (num_args_received < 2) {
																outp("Error: Usage is: get_uart_primary_number uart_name\n");
																continue;
															} else {
																std::string uart_name = catsd_filename;
															    result_str << uart_regfile_repository.get_primary_uart_index_from_name(uart_name);
																 outp("UART of Name " <<  uart_name << " is primary number: (" << result_str.str() << ")" << std::endl);
																 continue;
															}
					                                      } continue;

					case enSVGetUARTSecondaryNumberFromName :{
																num_args_received = sscanf(input_str.c_str(), "%1000s %1000s\n", command_char, &catsd_filename);
																if (num_args_received < 2) {
																	outp("Error: Usage is: get_uart_secondary_number uart_name\n");
																	continue;
																} else {
																	std::string uart_name = catsd_filename;
																	result_str << uart_regfile_repository.get_secondary_uart_index_from_name(uart_name);
																	 outp("UART of Name " <<  uart_name << " is secondary number: (" << result_str.str() << ")" << std::endl);
																	 continue;
																}
															  } continue;
					case enSVUART_write : {
						                                            unsigned uart_num;
																	unsigned address;
																	unsigned long long data_to_write;
																	ostringstream str_to_uart;
																	num_args_received = sscanf(input_str.c_str(), "%s %u %4X %llX\n", command_char, &uart_num, &address, &data_to_write);
																	outpc("received UART params: UART: " << uart_num << std::hex << " address: 0x" << address << " data: 0x" << data_to_write << std::dec<< std::endl);
																	if ((num_args_received < 4) || (uart_num > uart_regfile_repository.size()-1))
																	{
																			outprintf("Error: (%s) Usage is: uart_write uart_num address_hex data_hex\n", input_str.c_str());
																			continue;
																	} else
																	{
						 											    str_to_uart << "W " << " " << std::hex << data_to_write << " " << address;
						 											    outp("Writing string: [" << str_to_uart.str() << "]\n");
																		uart_regfile_repository.get_uart_ptr_from_number(uart_num)->writestr(str_to_uart.str());
																		continue;
																	}

					                      }
					                      continue;


					case enSVUART_read : {

											unsigned uart_num;
											unsigned address;
											ostringstream str_to_uart;
											num_args_received = sscanf(input_str.c_str(), "%s %u %4X\n", command_char, &uart_num, &address);
											outpc("received UART params: UART: " << uart_num << std::hex << " address: 0x" << address << std::dec<< std::endl);
											if ((num_args_received < 3) || (uart_num > uart_regfile_repository.size()-1))
											{
													outprintf("Error: (%s) Usage is: uart_read uart_num address_hex\n", input_str.c_str());
													continue;
											} else
											{
 											    str_to_uart << "R " << std::hex << address;
												uart_regfile_repository.get_uart_ptr_from_number(uart_num)->writestr(str_to_uart.str());
												std::string uart_result = uart_regfile_repository.get_uart_ptr_from_number(uart_num)->getstr(100);
												outp("Result of UART read is: " << uart_result);
												result_str << uart_result;
												continue;
											}

					                     }
					                      continue;



					case enSVUART_reg_write : {
						                        unsigned uart_num;
												unsigned address;
												unsigned long long data_to_write;
												int secondary_uart_addr = 0;
												ostringstream str_to_uart;
												num_args_received = sscanf(input_str.c_str(), "%s %u %X %llX %d\n", command_char, &uart_num, &address, &data_to_write, &secondary_uart_addr);
												outpc("received REGFILE UART params: UART: " << uart_num << std::hex << " address: 0x" << address << " data: 0x" << data_to_write << std::dec<< std::endl);
												if ((num_args_received < 4) || (uart_num > uart_regfile_repository.size()-1))
												{
														outprintf("Error: (%s) Usage is: uart_regfile_reg_write uart_num address_hex data_hex\n", input_str.c_str());
														continue;
												} else {
														uart_regfile_repository.get_uart_ptr_from_number(uart_num)->write_control_reg(address,data_to_write,secondary_uart_addr);
														continue;
												}
					                        }
					                        continue;



					case enSVUART_reg_read : {

												unsigned uart_num;
												unsigned address;
												ostringstream str_to_uart;
												int secondary_uart_addr = 0;
												num_args_received = sscanf(input_str.c_str(), "%s %u %X %d\n", command_char, &uart_num, &address, &secondary_uart_addr);
												outpc("received REGFILE UART params: UART: " << uart_num << std::hex << " address: 0x" << address << std::dec<< std::endl);
												if ((num_args_received < 3) || (uart_num > uart_regfile_repository.size()-1))
												{
													outprintf("Error: (%s) Usage is: uart_regfile_reg_read uart_num address_hex\n", input_str.c_str());
													continue;
												} else {
														unsigned long long uart_result = ( uart_regfile_repository.get_uart_ptr_from_number(uart_num))->read_control_reg(address,secondary_uart_addr);
														outp("Result of UART read is: " << uart_result);
														result_str << uart_result;
														continue;
												}

											}
					                      continue;



					case enSVUART_info_read : {
												unsigned uart_num;
												unsigned address;
												ostringstream str_to_uart;
												int secondary_uart_addr = 0;
												num_args_received = sscanf(input_str.c_str(), "%s %u %X %d\n", command_char, &uart_num, &address, &secondary_uart_addr);
												outpc("received REGFILE UART params: UART: " << uart_num << std::hex << " address: 0x" << address << std::dec<< std::endl);
												if ((num_args_received < 3) || (uart_num > uart_regfile_repository.size()-1))
												{
													outprintf("Error: (%s) Usage is: uart_regfile_info_read uart_num address_hex\n", input_str.c_str());
													continue;
												} else
												{

														unsigned long long uart_result = ( uart_regfile_repository.get_uart_ptr_from_number(uart_num))->read_info_reg(address,secondary_uart_addr);
														outp("Result of info UART read is: " << uart_result);
														result_str << uart_result;
														continue;

												}

											}
											continue;

					case enSVUART_status_read : {

																unsigned uart_num;
																unsigned address;
																ostringstream str_to_uart;
																int secondary_uart_addr = 0;
																num_args_received = sscanf(input_str.c_str(), "%s %u %X %d\n", command_char, &uart_num, &address, &secondary_uart_addr);
																outpc("received REGFILE UART params: UART: " << uart_num << std::hex << " address: 0x" << address << std::dec<< std::endl);
																if ((num_args_received < 3) || (uart_num > uart_regfile_repository.size()-1))
																{
																		outprintf("Error: (%s) Usage is: uart_regfile_status_read uart_num address_hex\n", input_str.c_str());
																		continue;
																} else
																{
																	 unsigned long long uart_result = ( uart_regfile_repository.get_uart_ptr_from_number(uart_num))->read_status_reg(address, secondary_uart_addr);
																	outp("Result of status UART read is: " << uart_result);
																	result_str << uart_result;
																	continue;

																}

										                     }
										                     continue;

					case enSVGetUARTIncludedStatusRegs: {
						                                       unsigned long volatile num_args_received;
															   unsigned long volatile uart_num;
															   ostringstream str_to_uart;
															   int secondary_uart_addr = 0;
															   num_args_received = sscanf(input_str.c_str(), "%s %lu %d\n", command_char, &uart_num, &secondary_uart_addr);
															   outpc("received REGFILE UART params: UART: " << uart_num << std::endl);
															   unsigned long max_uart_num =  (uart_regfile_repository.size()-1);
															   //safe_print(std::cout << " get_param uart_num = " << uart_num << " max_uart_num = " << max_uart_num << std::endl);
															   if ((num_args_received < 2))
															   {
																   outprintf("Error 1: (%s) Usage is: uart_get_included_status_regs uart_num, num_args_received = %d uart_num = %u lim = %d comp=%d\n", input_str.c_str(),num_args_received,uart_num, (int) (uart_regfile_repository.size()-1), (int) (uart_num > (uart_regfile_repository.size()-1)));
																   continue;
															   } else
															   if (uart_num > max_uart_num)
															   {
																   outprintf("Error 2: (%s) Usage is: uart_get_included_status_regs uart_num, num_args_received = %d uart_num = %u lim = %d comp=%d\n", input_str.c_str(),num_args_received,uart_num, (int) (uart_regfile_repository.size()-1), (int) (uart_num > (uart_regfile_repository.size()-1)));
																																   continue;
															   } else
															   {

																	   std::string uart_result = ( uart_regfile_repository.get_uart_ptr_from_number(uart_num))->get_included_status_regs_as_string(secondary_uart_addr);
																	   outp("Result of uart_get_included_status_regs is: " << uart_result << "\n");
																	   //std::cout << "Result of UART regfile parameter read for UART " << uart_num << " is: " << uart_result << "\n";
																	   result_str << uart_result;
																	   continue;

															   }

														   }
														   continue;
					case enSVGetUARTIncludedCtrlRegs  :  {
															unsigned long volatile num_args_received;
															   unsigned long volatile uart_num;
															   ostringstream str_to_uart;
															   int secondary_uart_addr = 0;
															   num_args_received = sscanf(input_str.c_str(), "%s %lu %d\n", command_char, &uart_num, &secondary_uart_addr);
															   outpc("received REGFILE UART params: UART: " << uart_num << std::endl);
															   unsigned long max_uart_num =  (uart_regfile_repository.size()-1);
															   //safe_print(std::cout << " get_param uart_num = " << uart_num << " max_uart_num = " << max_uart_num << std::endl);
															   if ((num_args_received < 2))
															   {
																   outprintf("Error 1: (%s) Usage is: uart_get_included_ctrl_regs uart_num, num_args_received = %d uart_num = %u lim = %d comp=%d\n", input_str.c_str(),num_args_received,uart_num, (int) (uart_regfile_repository.size()-1), (int) (uart_num > (uart_regfile_repository.size()-1)));
																   continue;
															   } else
															   if (uart_num > max_uart_num)
															   {
																   outprintf("Error 2: (%s) Usage is: uart_get_included_ctrl_regs uart_num, num_args_received = %d uart_num = %u lim = %d comp=%d\n", input_str.c_str(),num_args_received,uart_num, (int) (uart_regfile_repository.size()-1), (int) (uart_num > (uart_regfile_repository.size()-1)));
																																   continue;
															   } else
															   {

																	   std::string uart_result = ( uart_regfile_repository.get_uart_ptr_from_number(uart_num))->get_included_ctrl_regs_as_string(secondary_uart_addr);
																	   outp("Result of uart_get_included_status_regs is: " << uart_result << "\n");
																	   //std::cout << "Result of UART regfile parameter read for UART " << uart_num << " is: " << uart_result << "\n";
																	   result_str << uart_result;
																	   continue;

															   }

														   }
														   continue;


					   case enSVUART_regfile_get_params : {    unsigned long volatile num_args_received;
															   unsigned long volatile uart_num;
															   ostringstream str_to_uart;
															   int secondary_uart_addr = 0;
															   num_args_received = sscanf(input_str.c_str(), "%s %lu %d\n", command_char, &uart_num, &secondary_uart_addr);
															   outpc("received REGFILE UART params: UART: " << uart_num << std::endl);
															   unsigned long max_uart_num =  (uart_regfile_repository.size()-1);
															   //safe_print(std::cout << " get_param uart_num = " << uart_num << " max_uart_num = " << max_uart_num << std::endl);
															   if ((num_args_received < 2))
															   {
																   outprintf("Error 1: (%s) Usage is: uart_regfile_get_params uart_num, num_args_received = %d uart_num = %u lim = %d comp=%d\n", input_str.c_str(),num_args_received,uart_num, (int) (uart_regfile_repository.size()-1), (int) (uart_num > (uart_regfile_repository.size()-1)));
																   continue;
															   } else
															   if (uart_num > max_uart_num)
															   {
																   outprintf("Error 2: (%s) Usage is: uart_regfile_get_params uart_num, num_args_received = %d uart_num = %u lim = %d comp=%d\n", input_str.c_str(),num_args_received,uart_num, (int) (uart_regfile_repository.size()-1), (int) (uart_num > (uart_regfile_repository.size()-1)));
																   																   continue;
															   } else
															   {

																	   std::string uart_result = ( uart_regfile_repository.get_uart_ptr_from_number(uart_num))->get_params_str(secondary_uart_addr);
																	   outp("Result of UART regfile parameter read is: " << uart_result << "\n");
																	   //std::cout << "Result of UART regfile parameter read for UART " << uart_num << " is: " << uart_result << "\n";
																	   result_str << uart_result;
																	   continue;

															   }

														   }
														   continue;

					                        case enSVUART_regfile_get_version : {
					  															   unsigned uart_num;
					  															   ostringstream str_to_uart;
					  															  int secondary_uart_addr = 0;
					  															   num_args_received = sscanf(input_str.c_str(), "%s %u %d\n", command_char, &uart_num, &secondary_uart_addr);
					  															   outpc("received REGFILE UART version: UART: " << uart_num << std::endl);
					  															   if ((num_args_received < 2) || (uart_num > uart_regfile_repository.size()-1))
					  															   {
					  																   outprintf("Error: (%s) Usage is: uart_regfile_get_version uart_num\n", input_str.c_str());
					  																   continue;
					  															   } else
					  															   {

					  																	   unsigned long uart_result = ( uart_regfile_repository.get_uart_ptr_from_number(uart_num))->get_version(secondary_uart_addr);
					  																	   outp("Result of UART regfile parameter read is: " << uart_result << "\n");
					  																	   result_str << uart_result;
					  																	   continue;

					  															   }

					  														   }
					  														   continue;


					                        case enSVUART_regfile_get_status_desc : {
																						unsigned uart_num;
																						unsigned address;
																						ostringstream str_to_uart;
																						int secondary_uart_addr = 0;
																						num_args_received = sscanf(input_str.c_str(), "%s %u %X %d\n", command_char, &uart_num, &address, &secondary_uart_addr);
																						outpc("received REGFILE UART params: UART: " << uart_num << std::hex << " address: 0x" << address << std::dec<< std::endl);
																						if ((num_args_received < 3) || (uart_num > uart_regfile_repository.size()-1))
																						{
																								outprintf("Error: (%s) Usage is: uart_regfile_status_desc uart_num address_hex\n", input_str.c_str());
																								continue;
																						} else
																						{
																							std::string uart_result = ( uart_regfile_repository.get_uart_ptr_from_number(uart_num))->get_status_desc(address, secondary_uart_addr);
																							outp("Result of status UART status desc read is: " << uart_result << std::endl);
																							result_str << uart_result;
																							continue;

																						}

																					 }
																				  continue;

					                        case enSVUART_regfile_get_control_desc: {
																						unsigned uart_num;
																						unsigned address;
																						ostringstream str_to_uart;
																						int secondary_uart_addr = 0;
																						num_args_received = sscanf(input_str.c_str(), "%s %u %X %d\n", command_char, &uart_num, &address, &secondary_uart_addr);
																						outpc("received REGFILE UART params: UART: " << uart_num << std::hex << " address: 0x" << address << std::dec<< std::endl);
																						if ((num_args_received < 3) || (uart_num > uart_regfile_repository.size()-1))
																						{
																								outprintf("Error: (%s) Usage is: uart_regfile_ctrl_desc uart_num address_hex\n", input_str.c_str());
																								continue;
																						} else
																						{
																								std::string uart_result = ( uart_regfile_repository.get_uart_ptr_from_number(uart_num))->get_control_desc(address, secondary_uart_addr);
																							outp("Result of status UART control desc is: " << uart_result);
																							result_str << uart_result;
																							continue;

																						}

																					 }
																					 continue;

											case enSVIsMaster : {
												                  int is_master = card_configuration.is_master();
												                  result_str << is_master;
												                  outp("Card is " << (is_master ? "" : "not") << " a master" << std::endl);

											                      continue;
											}
											case enSVIsSlave  : {
								                  int is_slave = card_configuration.is_slave();
								                  result_str << is_slave;
								                  outp("Card is " << (is_slave ? "" : "not") << " a slave"  << std::endl);
							                      continue;
							                 }

											case enSVGetCardAssignedNum :  {
								                  int assigned_num = card_configuration.get_card_assigned_number();
								                  result_str << assigned_num;
								                  outp("Card assigned number is " <<  assigned_num << std::endl);
							                      continue;
							                 }
											case enSVGetCardRevision : {
								                  int hw_rev = card_configuration.get_card_assigned_number();
								                  result_str << hw_rev;
								                  outp("Card hardware revision is Rev. " <<  hw_rev << std::endl);
							                      continue;
							                 }

											case enSVEnterJtagDebug :   verbose_jtag_debug_mode = 1;
																		out_to_all_streams("Entered JTAG Debug Mode");
																		continue;

											case enSVExitJtagDebug  : verbose_jtag_debug_mode = 0;
											                          out_to_all_streams("Exited JTAG Debug Mode");
											                          continue;

											case enSVEnableAutoLogFile  : enable_auto_logfile_generation = 1;
											                              outp("Enabled auto logfile");
												                          continue;

											case enSVDisableAutoLogFile : enable_auto_logfile_generation = 0;
											                              outp("Disabled auto logfile");
												                          continue;
/*
											case enSVProgramSpartanHexFile : {
												char bitpattern_filename_str[4096];
												num_args_received = sscanf(input_str.c_str(), "%s %s\n", command_char, bitpattern_filename_str);
												if (num_args_received != 2)
												{
													out_to_all_streams("Error: Usage is: program_spartan_hex_file filename\n");
													continue;
												} else
												{
												    std::vector<unsigned long> read_values;
												    read_values = read_from_sd_card_into_ulong_vector(std::string(bitpattern_filename_str));
												    unsigned long upper_limit;
												    if (read_values.size() > 100 ) {
												  	  upper_limit = 100;
												    } else {
												  	  upper_limit = read_values.size();
												    }
												    for (int i = 0; i < upper_limit; i++) {
												    	   outprintf("%08d: %08x\n",i,read_values.at(i));
												    	}

												    board_mgmt_inst.write_spartan_hex((unsigned long)&read_values);
												    continue;

												}
											}
												continue;
*/
											                          /*
											case enSVProgramSpartanHexFileAsBytes :  {
												char bitpattern_filename_str[4096];
												num_args_received = sscanf(input_str.c_str(), "%s %s\n", command_char, bitpattern_filename_str);
												if (num_args_received != 2)
												{
													out_to_all_streams("Error: Usage is: program_spartan_hex_byte_file filename\n");
													continue;
												} else
												{
												    std::vector<unsigned char> read_values;
												    read_values = read_from_sd_card_into_byte_vector(std::string(bitpattern_filename_str));
												    unsigned long upper_limit;
												    if (read_values.size() > 100 ) {
												  	  upper_limit = 100;
												    } else {
												  	  upper_limit = read_values.size();
												    }
												    for (int i = 0; i < upper_limit; i++) {
												    	   outprintf("%08d: %02x\n",i,(unsigned) read_values.at(i));
												    	}

												    board_mgmt_inst.write_spartan_hex((unsigned long)&read_values);
												    continue;

												}
											}
												continue;
*/

										    case enSVGetProjectName             :  { result_str << LINNUX_PROJECT_NAME            ; outp(result_str.str()); continue; } continue;
										    case enSVGetLogicalCardDescription  :  { result_str << LINNUX_LOGICAL_CARD_DESCRIPTION; outp(result_str.str()); continue; } continue;
										    case enSVGetPhysicalCardDescription :  { result_str << LINNUX_PHYSICAL_CARD_DESCRPTION; outp(result_str.str()); continue; } continue;

										    case   enSVMalloc         : {
										    				int numbytes;
														num_args_received = sscanf(input_str.c_str(), "%s %d\n", command_char, &numbytes);
														if (num_args_received < 2)
														{
															outp("Error: Usage is: malloc numbytes (decimal)\n");
															continue;
														} else
														{
															unsigned long the_ptr = (unsigned long) my_mem_malloc(numbytes);
															result_str << the_ptr;
															outp("Malloc'ed " << numbytes << " returned pointer : " << result_str.str() << "\n" );
															continue;
														}

										    }
										    continue;

											case   enSVFree           : {
												unsigned long the_ptr;
												num_args_received = sscanf(input_str.c_str(), "%s %lu\n", command_char, &the_ptr);
												if (num_args_received < 2)
												{
													outp("Error: Usage is: free the_ptr (decimal) \n");
													continue;
												} else
												{
													my_mem_free((void *)the_ptr);
													result_str << the_ptr;
													outp("Freed the pointer: " << the_ptr << "\n" );
													continue;
												}


											} continue;


											case  enSVPrintStrfromPtr : {
												unsigned long the_ptr;
												unsigned int max_numchars;
												num_args_received = sscanf(input_str.c_str(), "%s %lu %u\n", command_char, &the_ptr, &max_numchars);
												if (num_args_received < 3)
												{
													outp("Error: Usage is: printstr the_ptr max_numchars (decimal)\n");
													continue;
												} else
												{
													char *temp_ptr = (char *)my_mem_malloc(max_numchars+10);
													if (temp_ptr != NULL) {
													   snprintf(temp_ptr, max_numchars, "%s", (char*) the_ptr);
													   result_str << std::string(temp_ptr);
													   my_mem_free((void *)temp_ptr);
													   outp("Printstr printed string at: " << the_ptr << " max chars : " << max_numchars << "resultr returned is: (" << result_str.str() << ")\n" );
													} else {
														outp("Error: printstr: temp_ptr == NULL!\n");
													}

													continue;
												}


											}
											continue;
											case enSVProgramSpartanHexFileAsBytes :  {
																							unsigned char *outbuf = NULL;
																							int fmc_num=-1;
																							num_args_received = sscanf(input_str.c_str(), "%1000s %s %d\n", command_char, bitpattern_filename_str,&fmc_num);
																							if ((num_args_received != 3) || (fmc_num < 0) || (fmc_num >=NUM_OF_FMCS))
																							{
																								out_to_all_streams("Error: Usage is: program_spartan_hex_byte_file filename fmc_num\n");
																								continue;
																							} else
																							{
																								int op_result;
																								unsigned int bytes_actually_read = 0;
																								out_to_all_streams("Now reading File " << bitpattern_filename_str << " into memory ...\n"); std::cout.flush();
																								op_result = read_binary_file_from_sd_card_into_char_array(
																										std::string(bitpattern_filename_str),
																										&outbuf,
																										bytes_actually_read
																										);
																							   if (op_result != LINNUX_RETVAL_ERROR) {
																									unsigned long upper_limit;
																									if (bytes_actually_read > 100 ) {
																									  upper_limit = 100;
																									} else {
																									  upper_limit = bytes_actually_read;
																									}

																									for (int i = 0; i < upper_limit; i++) {
																										   outprintf("%08d: %02x\n",i,(unsigned) outbuf[i]);
																										}
																									out_to_all_streams("Finished reading File " << bitpattern_filename_str << " into memory, now programming flash ...\n"); std::cout.flush();

																									result_str << board_mgmt_inst.write_spartan_hex((unsigned long)outbuf,bytes_actually_read,(unsigned long)fmc_num);
																									out_to_all_streams("Finished Programming FLASH with file " << bitpattern_filename_str << "\n"); std::cout.flush();

																							   } else {
																								   outp("Error while opening file: " << bitpattern_filename_str << "\n");
																							   }

																							   if (outbuf != NULL) {
																								   my_mem_free(outbuf);
																							   }
																							   continue;
																							}
																						}
																							continue;
											case enSVProgramStratixHexFileAsBytes :  {
												unsigned char *outbuf = NULL;

												num_args_received = sscanf(input_str.c_str(), "%1000s %s %d\n", command_char, bitpattern_filename_str);
												if (num_args_received != 2)
												{
													out_to_all_streams("Error: Usage is: program_stratix_hex_byte_file filename\n");
													continue;
												} else
												{
													int op_result;
													unsigned int bytes_actually_read = 0;
													out_to_all_streams("Now reading File " << bitpattern_filename_str << " into memory ...\n"); std::cout.flush();
													op_result = read_binary_file_from_sd_card_into_char_array(
															std::string(bitpattern_filename_str),
															&outbuf,
															bytes_actually_read
													);
													if (op_result != LINNUX_RETVAL_ERROR) {
														unsigned long upper_limit;
														if (bytes_actually_read > 100 ) {
															upper_limit = 100;
														} else {
															upper_limit = bytes_actually_read;
														}

														for (int i = 0; i < upper_limit; i++) {
															outprintf("%08d: %02x\n",i,(unsigned) outbuf[i]);
														}
														std::cout << "Finished reading File " << bitpattern_filename_str << " into memory, bytes read = " << bytes_actually_read << " now programming Stratix flash ...\n"; std::cout.flush();


														result_str << board_mgmt_inst.write_stratix_hex((unsigned long)outbuf,bytes_actually_read);
														std::cout <<"Finished Programming Stratix FLASH with file " << bitpattern_filename_str << "\n"; std::cout.flush();

													} else {
														outp("Error while opening file: " << bitpattern_filename_str << "\n");
													}

													if (outbuf != NULL) {
														my_mem_free(outbuf);
													}
													continue;
												}
											}
											continue;

#if SUPPORT_GENERAL_FLASH_PROGRAMMING_IN_LINNUX_MAIN
											case enSVProgramEPCQ :  {
																							unsigned char *outbuf = NULL;
                                                                                            unsigned int flash_index;
																							num_args_received = sscanf(input_str.c_str(), "%1000s %u %4000s\n", command_char, &flash_index, bitpattern_filename_str);
																							if (num_args_received != 3)
																							{
																								out_to_all_streams("Error: Usage is: program_flash flash_index filename\n");
																								continue;
																							} else
																							{
																								int op_result;
																								unsigned int bytes_actually_read = 0;
																								out_to_all_streams("Now reading File " << bitpattern_filename_str << " into memory ...\n"); std::cout.flush();
																								op_result = read_binary_file_from_sd_card_into_char_array(
																										std::string(bitpattern_filename_str),
																										&outbuf,
																										bytes_actually_read
																								);
																								if (op_result != LINNUX_RETVAL_ERROR) {
																									unsigned long upper_limit;
																									if (bytes_actually_read > 100 ) {
																										upper_limit = 100;
																									} else {
																										upper_limit = bytes_actually_read;
																									}

																									for (int i = 0; i < upper_limit; i++) {
																										outprintf("%08d: %02x\n",i,(unsigned) outbuf[i]);
																									}
																									std::cout << "Finished reading File " << bitpattern_filename_str << " into memory, bytes read = " << bytes_actually_read << " now programming Stratix flash ...\n"; std::cout.flush();
																									result_str << generic_flash_program(flash_index,outbuf,bytes_actually_read);
																									std::cout <<"Finished Programming FLASH with file " << bitpattern_filename_str << "\n"; std::cout.flush();

																								} else {
																									outp("Error while opening file: " << bitpattern_filename_str << "\n");
																								}

																								if (outbuf != NULL) {
																									my_mem_free(outbuf);
																								}
																								continue;
																							}
																						}
																						continue;
#endif


											case enSVProgramSpartanPOFFile: {
																																			unsigned long memory_location;
																																			int length = -1;
																																			num_args_received = sscanf(input_str.c_str(), "%s %lu %d\n", command_char, &memory_location, &length);
																																			if ((num_args_received != 3) || (length < 0))
																																			{
																																				out_to_all_streams("Error: Usage is: program_spartan_pof_file_from_memory memory_location length (decimal)\n");
																																				continue;
																																			} else
																																			{
																																			   result_str << board_mgmt_inst.write_spartan_hex(memory_location,length,0);
																																			   outp(" Wrote Spartan POF into flash from memory location " << memory_location << " Length = " << length << "result = " << result_str.str());
																																			   continue;
																																			}

											} continue;

						case enSVProgramStratixPOFFile : {

											} continue;


						case enSVProgramWriteToSpartanFLASH : {
												 unsigned char *outbuf = NULL;
                                                               unsigned long memory_location;
                                                               int length = -1;
                                                               unsigned long offset;
                                                               num_args_received = sscanf(input_str.c_str(), "%s %lu %d %lu\n", command_char, &memory_location, &length, &offset);
                                                               if ((num_args_received != 4) || (length < 0))
                                                               {
                                                               	out_to_all_streams("Error: Usage is: write_to_spartan_flash memory_location length offset (decimal)\n");
                                                               	continue;
                                                               } else
                                                               {
                                                                  result_str << board_mgmt_inst.write_to_spartan_flash(memory_location,length,offset);
                                                                  outp(" Wrote Spartan POF into flash from memory location " << memory_location << " Length = " << length << " offset = " << offset << " result = " << result_str.str());
                                                                  continue;
                                                               }


											} continue;

						case enSVProgramWriteToStratixFLASH : {
												unsigned char *outbuf = NULL;
												unsigned long memory_location;
											  int length = -1;
											  unsigned long offset;
											  num_args_received = sscanf(input_str.c_str(), "%s %lu %d %lu\n", command_char, &memory_location, &length, &offset);
											  if ((num_args_received != 4) || (length < 0))
											  {
											  	out_to_all_streams("Error: Usage is: write_to_stratix_flash memory_location length offset (decimal)\n");
											  	continue;
											  } else
											  {
											     result_str << board_mgmt_inst.write_to_stratix_flash(memory_location,length,offset);
											     outp(" Wrote Spartan POF into flash from memory location " << memory_location << " Length = " << length << " offset = " << offset << " result = " << result_str.str());
											     continue;
											  }

											} continue;

						case enSVWriteBinaryDataToMemory :  {
                                                              unsigned long memory_location;
                                                              int length = -1;
                                                              num_args_received = sscanf(input_str.c_str(), "%s %lu", command_char, &memory_location);
                                                              if (num_args_received != 2)
                                                              {
                                                              	out_to_all_streams("Error: Usage is: write_binary_data_to_memory memory_location (decimal)\n");
                                                              	continue;
                                                              } else
                                                              {
                                                            	  //std::cout << "Received string at timestamp: " << get_current_time_and_date_as_string_trimmed() << std::endl; cout.flush();
                                                            	  TrimSpaces(original_input_str);
                                                            	 // std::cout << "Trimmed Spaces at timestamp: " << get_current_time_and_date_as_string_trimmed() << std::endl;cout.flush();
                                                            	  std::vector<std::string> parsed_string_vec = convert_string_to_vector<std::string>(original_input_str," ");
                                                            	 // std::cout << "Parsed string at timestamp: " << get_current_time_and_date_as_string_trimmed() << std::endl;
                                                            	  std::string binary_data;
                                                            	  strtk::convert_base64_to_bin(parsed_string_vec.at(parsed_string_vec.size()-1),binary_data);
                                                            	 // std::cout << "Converted to base64 string at timestamp: " << get_current_time_and_date_as_string_trimmed() << std::endl;cout.flush();
                                                            	  //binary_data = base64_decode(parsed_string_vec.at(parsed_string_vec.size()-1));
                                                                  memmove((void *) memory_location, (void *)binary_data.c_str(), binary_data.length());
                                                            	 // std::cout << "memmoved to destination memory at timestamp: " << get_current_time_and_date_as_string_trimmed() << std::endl;cout.flush();

                                                                  outp(" Wrote binary data to memory location " << memory_location << " base64 data (first 100): " <<  parsed_string_vec.at(parsed_string_vec.size()-1).substr(0,99) << " binary data (first 100): " <<  binary_data.substr(0,99) << std::endl  );
                                                                  continue;
                                                              }


											} continue;
						case enSVReadBinaryDataFromMemory :  {
											                                      unsigned long memory_location;
											                                      unsigned long length = 0;
											                                      num_args_received = sscanf(input_str.c_str(), "%s %lu %lu", command_char, &memory_location, &length);
											                                      if ((num_args_received != 3) || length > MAX_LENGTH_OF_MEMORY_TO_READ_AS_BLOCK)
											                                      {
											                                      	out_to_all_streams("Error: Usage is: read_binary_data_from_memory memory_location (decimal). Lengths must not be bigger than " << MAX_LENGTH_OF_MEMORY_TO_READ_AS_BLOCK << "\n");
											                                      	continue;
											                                      } else
											                                      {
											                                    	  char* tempCharArray = (char*) my_mem_malloc(sizeof(char)*(length+10)); //some margin
											                                    	  //binary_data = base64_decode(parsed_string_vec.at(parsed_string_vec.size()-1));
											                                          memmove((void *) tempCharArray, (void *)memory_location, length);
											                                    	  std::string binary_data(tempCharArray,length);
											                                    	  my_mem_free(tempCharArray);
											                                    	  std::string base64data;
											                                    	  strtk::convert_bin_to_base64(binary_data,base64data);
											                                    	  result_str << base64data;
											                                    	 // std::cout << "memmoved to destination memory at timestamp: " << get_current_time_and_date_as_string_trimmed() << std::endl;cout.flush();

											                                          outp(" retrieved from memory location " << memory_location << " base64 data (first 100): " <<  base64data.substr(0,99) << " binary data (first 100): " <<  binary_data.substr(0,99) << std::endl  );
											                                          continue;
											                                      }


						                                          } continue;

						case enSVDoCustomCommand : {
							    std::string argument_list;
							    std::size_t argument_pos = input_str_from_external_func.find_first_of(" \n\r\t");
								if (argument_pos != std::string::npos) {
									argument_list = input_str_from_external_func.substr(argument_pos);
									TrimSpaces(argument_list);
								} else {
									argument_list = "";
								}
						        result_str << do_custom_command(argument_list, is_called_from_tcl_script, calling_command_type, command_found);
						}
					    continue;

#ifdef PIO_RESET_AND_BOOTLOADER_REQUEST_BASE
				    case  enSVRequestPFLReconfigure: {
									    	   std::cout << " Requesting FPGA reconfiguration! \n "; std::cout.flush();
                                               outp(" Requesting FPGA reconfiguration! \n ");
                                               reset_and_bootloader_request.turn_on_bit(REQUEST_FPGA_RECONFIGURE_BIT);
                                               reset_and_bootloader_request.turn_on_bit(REQUEST_FPGA_RECONFIGURE_BIT);
                                               reset_and_bootloader_request.turn_on_bit(REQUEST_FPGA_RECONFIGURE_BIT);
                                               reset_and_bootloader_request.turn_off_bit(REQUEST_FPGA_RECONFIGURE_BIT);
                                               while (1) {};

                                               std::cout << " Requested FPGA reconfiguration! \n "; std::cout.flush();
                                               outp(" Requested FPGA reconfiguration! \n ");

									    	   continue;} continue;
									       case  enSVRequestSoftwareReload: {
									    	   std::cout << " Requesting ELF reload! \n "; std::cout.flush();
									    	   outp(" Requesting FELF reload! \n ");
									    	   reset_and_bootloader_request.turn_on_bit(REQUEST_ELF_RELOAD_BIT);
									    	   std::cout << " Requested ELF reload! \n "; std::cout.flush();
									    	   outp(" Requested ELF reload! \n ");

									    	   while (1) {};

									    	   continue;
									       } continue;
#endif
				case  enSVUARTReadAllCtrl      : {    unsigned long volatile num_args_received;
										   unsigned long volatile uart_num;
										   ostringstream str_to_uart;
										   int secondary_uart_addr = 0;
										   num_args_received = sscanf(input_str.c_str(), "%s %lu %d\n", command_char, &uart_num, &secondary_uart_addr);
										   unsigned long max_uart_num =  (uart_regfile_repository.size()-1);
										   //safe_print(std::cout << " get_param uart_num = " << uart_num << " max_uart_num = " << max_uart_num << std::endl);
										   if ((num_args_received < 2))
										   {
											   outprintf("Error 1: (%s) Usage is: uart_read_all_ctrl uart_num, num_args_received = %d uart_num = %u lim = %d comp=%d\n", input_str.c_str(),num_args_received,uart_num, (int) (uart_regfile_repository.size()-1), (int) (uart_num > (uart_regfile_repository.size()-1)));
											   continue;
										   } else
										   if (uart_num > max_uart_num)
										   {
											   outprintf("Error 2: (%s) Usage is: uart_read_all_ctrl uart_num, num_args_received = %d uart_num = %u lim = %d comp=%d\n", input_str.c_str(),num_args_received,uart_num, (int) (uart_regfile_repository.size()-1), (int) (uart_num > (uart_regfile_repository.size()-1)));
											   																   continue;
										   } else
										   {

												   std::string uart_result = ( uart_regfile_repository.get_uart_ptr_from_number(uart_num))->read_all_ctrl(secondary_uart_addr);
												   outp("Result of UART regfile parameter read is: " << uart_result << "\n");
												  // std::cout << "Result of UART regfile parameter read all ctrl  UART " << uart_num << " Secondary: " << secondary_uart_addr <<  " is: " << uart_result << "\n";
												   result_str << uart_result;
												   continue;

										   }

									   }
									   continue;
				case enSVUARTReadAllCtrlAndStatus :{    unsigned long volatile num_args_received;
				   unsigned long volatile uart_num;
				   ostringstream str_to_uart;
				   int secondary_uart_addr = 0;
				   num_args_received = sscanf(input_str.c_str(), "%s %lu %d\n", command_char, &uart_num, &secondary_uart_addr);
				   unsigned long max_uart_num =  (uart_regfile_repository.size()-1);
				   //safe_print(std::cout << " get_param uart_num = " << uart_num << " max_uart_num = " << max_uart_num << std::endl);
				   if ((num_args_received < 2))
				   {
					   outprintf("Error 1: (%s) Usage is: uart_read_all_ctrl uart_num, num_args_received = %d uart_num = %u lim = %d comp=%d\n", input_str.c_str(),num_args_received,uart_num, (int) (uart_regfile_repository.size()-1), (int) (uart_num > (uart_regfile_repository.size()-1)));
					   continue;
				   } else
				   if (uart_num > max_uart_num)
				   {
					   outprintf("Error 2: (%s) Usage is: uart_read_all_ctrl uart_num, num_args_received = %d uart_num = %u lim = %d comp=%d\n", input_str.c_str(),num_args_received,uart_num, (int) (uart_regfile_repository.size()-1), (int) (uart_num > (uart_regfile_repository.size()-1)));
					   																   continue;
				   } else
				   {

					       result_str << (uart_regfile_repository.get_uart_ptr_from_number(uart_num))->read_all_control_and_status(secondary_uart_addr);
						   outp("Result of UART regfile read all control and status is: " << result_str.str() << "\n");
						   continue;

				   }

			   }
			continue;
				case  enSVUARTReadAllCtrlDesc      : {    unsigned long volatile num_args_received;
										   unsigned long volatile uart_num;
										   ostringstream str_to_uart;
										   int secondary_uart_addr = 0;
										   num_args_received = sscanf(input_str.c_str(), "%s %lu %d\n", command_char, &uart_num, &secondary_uart_addr);
										   unsigned long max_uart_num =  (uart_regfile_repository.size()-1);
										   //safe_print(std::cout << " get_param uart_num = " << uart_num << " max_uart_num = " << max_uart_num << std::endl);
										   if ((num_args_received < 2))
										   {
											   outprintf("Error 1: (%s) Usage is: uart_read_all_ctrl_desc uart_num, num_args_received = %d uart_num = %u lim = %d comp=%d\n", input_str.c_str(),num_args_received,uart_num, (int) (uart_regfile_repository.size()-1), (int) (uart_num > (uart_regfile_repository.size()-1)));
											   continue;
										   } else
										   if (uart_num > max_uart_num)
										   {
											   outprintf("Error 2: (%s) Usage is: uart_read_all_ctrl_desc uart_num, num_args_received = %d uart_num = %u lim = %d comp=%d\n", input_str.c_str(),num_args_received,uart_num, (int) (uart_regfile_repository.size()-1), (int) (uart_num > (uart_regfile_repository.size()-1)));
											   																   continue;
										   } else
										   {

												   std::string uart_result = ( uart_regfile_repository.get_uart_ptr_from_number(uart_num))->read_all_ctrl_desc(secondary_uart_addr);
												   outp("Result of UART regfile parameter read is: " << uart_result << "\n");
												   //std::cout << "Result of UART regfile parameter read all ctrl  UART " << uart_num << " Secondary: " << secondary_uart_addr <<  " is: " << uart_result << "\n";
												   result_str << uart_result;
												   continue;

										   }

									   }
									   continue;


				 case  enSVUARTReadAllStatus    :  {    unsigned long volatile num_args_received;
										   unsigned long volatile uart_num;
										   ostringstream str_to_uart;
										   int secondary_uart_addr = 0;
										   num_args_received = sscanf(input_str.c_str(), "%s %lu %d\n", command_char, &uart_num, &secondary_uart_addr);
										   unsigned long max_uart_num =  (uart_regfile_repository.size()-1);
										   //safe_print(std::cout << " get_param uart_num = " << uart_num << " max_uart_num = " << max_uart_num << std::endl);
										   if ((num_args_received < 2))
										   {
											   outprintf("Error 1: (%s) Usage is: uart_read_all_status uart_num, num_args_received = %d uart_num = %u lim = %d comp=%d\n", input_str.c_str(),num_args_received,uart_num, (int) (uart_regfile_repository.size()-1), (int) (uart_num > (uart_regfile_repository.size()-1)));
											   continue;
										   } else
										   if (uart_num > max_uart_num)
										   {
											   outprintf("Error 2: (%s) Usage is: uart_read_all_status uart_num, num_args_received = %d uart_num = %u lim = %d comp=%d\n", input_str.c_str(),num_args_received,uart_num, (int) (uart_regfile_repository.size()-1), (int) (uart_num > (uart_regfile_repository.size()-1)));
											   																   continue;
										   } else
										   {

												   std::string uart_result = ( uart_regfile_repository.get_uart_ptr_from_number(uart_num))->read_all_status(secondary_uart_addr);
												   outp("Result of UART regfile parameter read is: " << uart_result << "\n");
												  // std::cout << "Result of UART regfile parameter read all status  UART " << uart_num << " Secondary: " << secondary_uart_addr <<  " is: " << uart_result << "\n";
												   result_str << uart_result;
												   continue;

										   }

									   } continue;

				 case  enSVUARTReadAllStatusDesc    :  {    unsigned long volatile num_args_received;
													   unsigned long volatile uart_num;
													   ostringstream str_to_uart;
													   int secondary_uart_addr = 0;
													   num_args_received = sscanf(input_str.c_str(), "%s %lu %d\n", command_char, &uart_num, &secondary_uart_addr);
													   unsigned long max_uart_num =  (uart_regfile_repository.size()-1);
													   //safe_print(std::cout << " get_param uart_num = " << uart_num << " max_uart_num = " << max_uart_num << std::endl);
													   if ((num_args_received < 2))
													   {
														   outprintf("Error 1: (%s) Usage is: uart_read_all_status_desc uart_num, num_args_received = %d uart_num = %u lim = %d comp=%d\n", input_str.c_str(),num_args_received,uart_num, (int) (uart_regfile_repository.size()-1), (int) (uart_num > (uart_regfile_repository.size()-1)));
														   continue;
													   } else
													   if (uart_num > max_uart_num)
													   {
														   outprintf("Error 2: (%s) Usage is: uart_read_all_status_desc uart_num, num_args_received = %d uart_num = %u lim = %d comp=%d\n", input_str.c_str(),num_args_received,uart_num, (int) (uart_regfile_repository.size()-1), (int) (uart_num > (uart_regfile_repository.size()-1)));
														   																   continue;
													   } else
													   {

															   std::string uart_result = ( uart_regfile_repository.get_uart_ptr_from_number(uart_num))->read_all_status_desc(secondary_uart_addr);
															   outp("Result of UART regfile parameter read is: " << uart_result << "\n");
															   //std::cout << "Result of UART regfile parameter read all status  UART " << uart_num << " Secondary: " << secondary_uart_addr <<  " is: " << uart_result << "\n";
															   result_str << uart_result;
															   continue;

													   }

												   } continue;



		       case  enSVUARTWriteAllCtrl     : {
		    	                                    std::string the_cmd;
		    	                                    std::string the_uart;
		    	                                    std::string the_reglist;

													num_args_received = sscanf(original_input_str.c_str(), "%1000s %4000s %4000s\n", command_char, catsd_filename, bitpattern_filename_str);
													if (num_args_received != 3)
													{
															out_to_all_streams("Error: Usage is uart_write_multiple_ctrl composite_uart_num comma_separated_data_address_pairs_in_hex\n");
															continue;
													}
													istringstream istr;
													istr.str(original_input_str);
													iof::scans(istr,"%s %s %s",the_cmd,the_uart,the_reglist);
													std::vector<unsigned> uart_name_composite = convert_string_to_vector<unsigned>(the_uart,"_");
													if ((uart_name_composite.size() < 1) || (uart_name_composite.size() > 2)) {
														out_to_all_streams("Error: uart_write_multiple_ctrl: UART num illegal, command is: (" << original_input_str << ")" << std::endl);
														continue;
													}
													if (uart_name_composite.size() == 1) {
														uart_name_composite.push_back(0); //primary uart so secondary uart number is 0;
													}
													std::vector<std::pair<unsigned long, unsigned long long> > address_data_pairs = convert_string_to_vector_of_pairs_separate_hex_modifiers<unsigned long, unsigned long long>(the_reglist,",",false,true);
													uart_register_file* uart_ptr = uart_regfile_repository.get_uart_ptr_from_number(uart_name_composite.at(0));
													for (unsigned i = 0; i < address_data_pairs.size(); i++) {
														uart_ptr->write_control_reg(address_data_pairs.at(i).first,address_data_pairs.at(i).second,uart_name_composite.at(1));
														//std::cout << std::hex << "Wrote " << address_data_pairs.at(i).second << " to " << address_data_pairs.at(i).first << std::dec << std::endl;
													}
									            } continue;



		       case enSVGetAllUARTData : {
		    	                             result_str <<  uart_regfile_repository.get_all_uart_repository_params();
		    	   		    	             outp("Result of UART all param read: " << result_str.str() << std::endl);
		    	   							 continue;
									       } continue;

		       case enSVGetJSONString : {
		    	                                update_total_json_object();
		    	  								std::ostringstream ostr;
		    	  								result_str << total_json_object;
		    	  								outp("Json string is: " << result_str.str() << std::endl);
		    	  								continue;
		                                }
		                                continue;

		       case enSVGetMotherboardJSONString : {
				    	                                update_json_motherboard_object();
				    	  								std::ostringstream ostr;
				    	  								result_str << motherboard_json_object;
				    	  								outp("Motherboard Json string is: " << result_str.str() << std::endl);
				    	  								continue;
				                                }
				                                continue;

		       case enSVGetAllUARTCtrlIncluded :  {
                   result_str <<  uart_regfile_repository.get_all_uart_repository_ctrl_included_regs();
	    	             outp("Result of UART all ctrl included: " << result_str.str() << std::endl);
						 continue;
			       } continue;

		       case enSVGetMAXVVersionString : {
		    	   result_str << get_maxv_version_string();
		    	   outp("MAXV version is: " << result_str.str() << std::endl);
		    	   continue;
		       } continue;

		       case enSVGetAllUARTStatusIncluded :  {
                   result_str <<  uart_regfile_repository.get_all_uart_repository_status_included_regs();
	    	             outp("Result of UART all status included" << result_str.str() << std::endl);
						   continue;
			       } continue;


/*
 *
					                        case enSVUDPStreamCmd: {
 					                        	                    argument_str_pos_start = input_str.find(" ") + 1;
					                        						argument_str = TrimSpacesFromString(input_str.substr(argument_str_pos_start));
					                        	                    char nsmenu_command[2000];
					                                              	num_args_received = sscanf(argument_str.c_str(), "%1000s\n", nsmenu_command);
					                                              	int result;
					                                              	result = execute_udp_stream_command(nsmenu_command,argument_str.c_str());
                                                                    safe_print(std::cout << "udp stream command, executed (" << nsmenu_command << ")" << "argument_str = (" << argument_str << ")" << " input str = (" << input_str << ")" << std::endl);
                                                                    continue;
					                                               }

					                                               continue;
					                                               */


		       case enSVCalculateCRC : {
										   unsigned long max_str_length;
										   int length = -1;
										   num_args_received = sscanf(original_input_str.c_str(), "%s %4000s", command_char, cmd_str);
										   if (num_args_received != 2)
										   {
											out_to_all_streams("Error: Usage is: calculate_crc string (decimal)\n");
											continue;
										   } else
										   {
											   istringstream istr;
											   istr.str(original_input_str);
											   std::string command_string, data_string;
											  // istr >> iof::fmtr("%s %s") >> command_string >> data_string;
											   iof::scans(istr,"%s %s",command_string,data_string);
											//unsigned long the_crc = Crc32::get_string_crc(std::string(cmd_str));
											unsigned long the_crc = Crc32::get_string_crc(data_string);
											result_str << the_crc << " " << data_string;
											outp("Result is: " << result_str.str() << " crc is: " << the_crc << std::hex << " =0x " << std::dec << the_crc << " strlen(cmd_str) = " << strlen(cmd_str) << " \n"; std::cout.flush());
										   }

											continue;

                                      } continue;
		       case enSVGetRandomStringWithCRC : {
		    	                                                                unsigned long max_str_length;
		    	                                                                int length = -1;
		    	                                                                num_args_received = sscanf(input_str.c_str(), "%s %lu", command_char, &max_str_length);
		    	                                                                if (num_args_received != 2)
		    	                                                                {
		    	                                                                	out_to_all_streams("Error: Usage is: get_random_string_with_crc max_str_length (decimal)\n");
		    	                                                                	continue;
		    	                                                                } else
		    	                                                                {
		    	                                                                	int actual_len =randint(max_str_length)+1; //between 1 and len
    	                                                                			std::string random_str = gen_random_str(actual_len);
    	                                                                	        unsigned long the_crc =  Crc32::get_string_crc(random_str);
    	                                                                			result_str << the_crc << " " << random_str;
		    	                                                                	//std::cout << "Result is: " << result_str.str() << " crc is: " << the_crc << "String is (" << random_str << ")" << " actual len = " << actual_len << "max_str_legnth = " << max_str_length <<" \n";

		    	                                                                }

		    	                                                                	continue;

		                                              } continue;
#if (SUPPORT_BOARD_MANAGEMENT_UART)

		       case  enSVClearzl9101mFault : {

								  int fmc_index;
								  int num_args_received = sscanf(argvstr.c_str(), "%d", &fmc_index);
								  if ((num_args_received != 1) || (fmc_index < 0) || (fmc_index >= NUM_FMC_CARDS))
								  {
									out_to_all_streams("Error: Usage is: clear_zl9101m_faults fmc_index\n");
									result_str << 0;
									continue;
								  } else
								  {
									  result_str << clear_faults_in_regulator(fmc_index);
								  }

		    	   continue;
		       }
	    	   continue;

		       case enSVClearMainzl9101mFault :{
									   result_str << clear_faults_in_main_board_regulator();

				}
				continue;

#endif
#ifdef 	MSGDMA_0_CSR_BASE
				case enSVTestSendMemoryAsUDP: {
					out_to_all_streams(" Test: Sending Memory as UDP 0... " << std::endl);
					out_to_all_streams(" SGDMA device pointer is: " << (unsigned long) msgdma0.get_device_ptr() << std::endl);
                    int result = msgdma0.execute(&test_udp_packet[0],0x10);
                    out_to_all_streams(" Finished Sending Memory, result is:  " << result  << std::endl);
					std::cout.flush();
					continue;
				} continue;

				case enSVAsyncTestSendMemoryAsUDP: {
									out_to_all_streams(" Test: Sending Memory as UDP 0... " << std::endl);
									out_to_all_streams(" SGDMA device pointer is: " << (unsigned long) msgdma0.get_device_ptr() << std::endl);
				                    int result = msgdma0.execute_async(&test_udp_packet[0],0x10);
				                    out_to_all_streams(" Finished Sending Memory, result is:  " << result  << std::endl);
									std::cout.flush();
									continue;
								} continue;

				case enSVTestSendMemoryAsUDP1: {
									out_to_all_streams(" Test: Sending Memory as UDP 1... " << std::endl);
									out_to_all_streams(" SGDMA device pointer is: " << (unsigned long) msgdma1.get_device_ptr() << std::endl);
				                    int result = msgdma1.execute(&test_udp_packet[0],0x10);
				                    out_to_all_streams(" Finished Sending Memory, result is:  " << result  << std::endl);
									std::cout.flush();
									continue;
								} continue;

				case enSVAsyncTestSendMemoryAsUDP1: {
													out_to_all_streams(" Test: Sending Memory as UDP 1... " << std::endl);
													out_to_all_streams(" SGDMA device pointer is: " << (unsigned long) msgdma1.get_device_ptr() << std::endl);
								                    int result = msgdma1.execute_async(&test_udp_packet[0],0x10);
								                    out_to_all_streams(" Finished Sending Memory, result is:  " << result  << std::endl);
													std::cout.flush();
													continue;
												} continue;

				case enSVSendMemoryAsUDP:
				case enSVAsyncSendMemoryAsUDP: {
						unsigned long smart_buf_num;

						  std::vector<std::string> dma_commands =  convert_string_to_vector<std::string>(std::string(input_str),",");

							  for (size_t curr_command = 0; curr_command < dma_commands.size();  curr_command++) {
								  std::string current_dma_command =  dma_commands.at(curr_command);


								  if (curr_command == 0) {
									num_args_received = sscanf(current_dma_command.c_str(), "%s %lu", command_char, &smart_buf_num);
									if (num_args_received != 2)
									{
										out_to_all_streams("Error: Usage is: dma_to_udp smart_buf_num length_in_words (decimal) intented command is (" << current_dma_command << ")\n");
										result_str << "-1";
										continue;
									}

								  } else {
									  TrimSpaces(current_dma_command);
									  num_args_received = sscanf(current_dma_command.c_str(), "%lu", &smart_buf_num);
									  	if (num_args_received != 1)
									  	{
									  		out_to_all_streams("Error: Usage is: dma_to_udp smart_buf_num length_in_words (decimal) intented command is (" << current_dma_command << ")\n");
									  		result_str << " -1";
									  		continue;
									  	} else {
									  		result_str << " ";
									  	}
								  }

								  result_str << dma_and_udp_controller_inst.dma_to_udp_transfer(smart_buf_num,(mapped_val == enSVAsyncSendMemoryAsUDP));
							  }
						continue;
				} continue;
#endif
#ifdef MSGDMA_AVALON_MM_0_CSR_BASE
				case enSVResetHWDMAtoUDP : {
					                        msgdma0.do_sw_reset();
											msgdma_mm_to_mm_0.do_sw_reset();
					                        msgdma0.start();
						                    msgdma_mm_to_mm_0.start();
						                    outp("Reset HW DMA to UDP!!!\n")
                                            continue;
                                           }

				case enSVResetSWDMAtoUDP : {
					                        msgdma1.do_sw_reset();
										    msgdma_mm_to_mm_1.do_sw_reset();
											msgdma1.start();
											msgdma_mm_to_mm_1.start();
											outp("Reset SW DMA to UDP!!!\n")
				                            continue;
				                           }

				/*
				case enSVSendDMAMemorytoMemory: {
									unsigned long smart_buf_num,length_in_words, source_address;
									num_args_received = sscanf(input_str.c_str(), "%s %lx %lu %lu", command_char, &source_address, &smart_buf_num, &length_in_words);
									if (num_args_received != 4)
									{
										out_to_all_streams("Error: Usage is: dma_to_ddr source_address(hex) smart_buf_num(decimal) length_in_words(decimal)\n");
										continue;
									} else
									{
										alt_u32* current_smart_buf;
										current_smart_buf = dma_smart_buffers.get_buffer(smart_buf_num);
										if (current_smart_buf == NULL) {
											out_to_all_streams("Error: dma_to_ddr: current smart buf is NULL, index is " << smart_buf_num << "\n")
													result_str << (-1);
										} else {
											if ((length_in_words+1) > dma_smart_buffers.get_size_per_buf()) {
												out_to_all_streams("Error: dma_to_ddr: current smart buf size is " << dma_smart_buffers.get_size_per_buf() << " but length of transfer is" << (length_in_words+1) << " words! Transfer would cause buffer overflow, transfer aborted\n")
		                                        result_str << -1;
											} else {
											  current_smart_buf[0] = 0x80000000 + length_in_words;
											  msgdma_mm_to_mm_0.execute(source_address,current_smart_buf+1,length_in_words);
											  result_str << (unsigned long) current_smart_buf;
											}
										}
									}
									continue;
							} continue;*/
					#ifdef 	MSGDMA_0_CSR_BASE



				case enSVStoreDMADescriptor:
				case enSVRelativeStoreDMADescriptor: {
					unsigned  smartbuf_num;
					unsigned  length_in_words;
					unsigned  source_addr;
					unsigned descriptor_num;
					unsigned  control = 0;
					std::vector<std::string> dma_commands;
					dma_commands =  convert_string_to_vector<std::string>(std::string(input_str),",");
												 for (size_t curr_command = 0; curr_command < dma_commands.size();  curr_command++) {
													 std::string current_dma_command =  dma_commands.at(curr_command);

													 if (curr_command == 0) {
														 num_args_received = sscanf(current_dma_command.c_str(), "%1000s %u %u %x %u %x",command_char, &descriptor_num, &smartbuf_num, &source_addr, &length_in_words, &control);

														 if (num_args_received < 5)
														 {
															 out_to_all_streams("Error: Usage is: (relative_)store_dma_descriptor descriptor_num_decimal smart_buf_decimal source_addr_hex length_in_words_dec [control_in_hex]\n");
															 std::cout.flush();
															 result_str << "-1";
															 continue;

														 }

													 } else {
														 TrimSpaces(current_dma_command);
														 num_args_received = sscanf(current_dma_command.c_str(), "%u %u %x %u %x", &descriptor_num, &smartbuf_num, &source_addr, &length_in_words, &control);

														 if (num_args_received < 4)
														 {
															 out_to_all_streams("Error: Usage is: (relative_)store_dma_descriptor descriptor_num_decimal smart_buf_decimal source_addr_hex length_in_words_dec [control_in_hex]\n");
															 std::cout.flush();
															 result_str << " -1";
															 continue;
														 } else {
															 result_str << " ";
														 }
													 }
													 {
														 unsigned long dest_addr;
														 dest_addr = dma_and_udp_controller_inst.get_smart_buf_payload_start_addr(smartbuf_num);
														 if ((dest_addr == 0) || (smartbuf_num >= dma_and_udp_controller_inst.get_dma_smart_buffers_ptr()->get_num_on_chip_bufs())) {
															 out_to_all_streams("Error: Usage is: store_dma_descriptor: smart buffer " << smartbuf_num << " is out of range for HW DMA!\n");
															 result_str << LINNUX_RETVAL_ERROR;
															 continue;
														 }

														 if (mapped_val == enSVRelativeStoreDMADescriptor) {
															 result_str << dmadescriptor_ram.relative_construct_and_write_descriptor(
																	 descriptor_num,
																	 source_addr,
																	 dest_addr,
																	 length_in_words,
																	 control);
														 } else {
															 result_str << dmadescriptor_ram.construct_and_write_descriptor(
																	 descriptor_num,
																	 source_addr,
																	 dest_addr,
																	 length_in_words,
																	 control);
														 }


													 }
												 }
				           }

					continue;


				          case enSVRelativeSendDMAMemorytoMemory :
				          case enSVRelativeSendToUDPViaDDR :
				          case enSVSendDMAMemorytoMemory :
				          case enSVAsyncSendDMAMemorytoMemory :
				          case enSVSendToUDPViaDDR :
				          case enSVAsyncRelativeSendToUDPViaDDR:
				          case enSVAsyncSendToUDPViaDDR:
				          case enSVAsyncX2RelativeSendToUDPViaDDR:
				          case enSVAsyncX2SendToUDPViaDDR:

				          {
				        	  unsigned long smart_buf_num,length_in_words, source_address;
				        	  unsigned long preamble[DMA_SMART_BUFFER_PREAMBLE_WORDS];
				        	  unsigned long long time_spent;
				        	  std::string current_command;

				        	  std::vector<std::string> dma_commands;
                              unsigned long long total_time_for_this_command = profile(
				        	  profile_and_print_unsafe_for_loops(dma_commands =  convert_string_to_vector<std::string>(std::string(input_str),","));

				        	  for (size_t curr_command = 0; curr_command < dma_commands.size();  curr_command++) {
				        		  std::string current_dma_command =  dma_commands.at(curr_command);
				        		//  std::cout << "current_dma_command: " << current_dma_command << std::endl; std::cout.flush();

				        		// if (curr_command != 0) {
				        		//	  std::string command_name =  (iof::stringizer("%s%d") & "command" & curr_command);
				        		//	  current_dma_command = command_name  + current_dma_command;
				        		// }

				        		  for (int i = 0; i < DMA_SMART_BUFFER_PREAMBLE_WORDS; i++) {
				        			  preamble[i] = 0;
				        		  }

				        		  if (curr_command == 0) {
				        			  num_args_received = sscanf(current_dma_command.c_str(), "%1000s %lx %lu %lu %lx %lx %lx %lx %lx %lx %lx %lx",
				        					  command_char, &source_address, &smart_buf_num, &length_in_words,
				        					  preamble,
				        					  preamble+1,
				        					  preamble+2,
				        					  preamble+3,
				        					  preamble+4,
				        					  preamble+5,
				        					  preamble+6,
				        					  preamble+7);

				        			  if (num_args_received < 4)
				        			  {
				        				  out_to_all_streams("Error: Usage is: dma_to_udp_via_ddr source_address(hex) smart_buf_num(decimal) length_in_words(decimal) + up to 8 preamble words (hex), intented command is (" << current_dma_command << ")\n");
				        				  std::cout.flush();
				        				  result_str << "-1";
				        				  continue;

				        			  }

				        		  } else {
				        			  TrimSpaces(current_dma_command);
					        		  //std::cout << "current_dma_command after trim: " << current_dma_command << std::endl; std::cout.flush();

				        			  num_args_received = sscanf(current_dma_command.c_str(), "%lx %lu %lu %lx %lx %lx %lx %lx %lx %lx %lx",
				        					  &source_address,
				        					  &smart_buf_num,
				        					  &length_in_words,
				        					  preamble,
				        					  preamble+1,
				        					  preamble+2,
				        					  preamble+3,
				        					  preamble+4,
				        					  preamble+5,
				        					  preamble+6,
				        					  preamble+7);

				        			  if (num_args_received < 3)
				        			  {
				        				  out_to_all_streams("Error: parameters should be: source_address(hex) smart_buf_num(decimal) length_in_words(decimal) + up to 8 preamble words (hex), intented command is (" << current_dma_command << ")\n");
				        				  std::cout.flush();
				        				  result_str << " -1";
				        				  continue;
				        			  } else {
				        				  result_str << " ";
				        			  }
				        		  }

				        		  {
				        			  alt_u32* current_smart_buf;
				        			  current_smart_buf = dma_smart_buffers.get_buffer(smart_buf_num);
				        			  if (current_smart_buf == NULL) {
				        				  out_to_all_streams("Error: dma_to_udp_via_ddr: current smart buf is NULL, index is " << smart_buf_num << "\n")
				        																		result_str << (-1);
				        			  } else {


				        				  if (mapped_val == enSVSendDMAMemorytoMemory) {
				        					  result_str << dma_and_udp_controller_inst.dma_to_ddr_transfer(source_address,smart_buf_num,length_in_words,preamble,DMA_SMART_BUFFER_PREAMBLE_WORDS);
				        					  continue;
				        				  }

				        				  if (mapped_val == enSVAsyncSendDMAMemorytoMemory) {
				        								        					  result_str << dma_and_udp_controller_inst.dma_to_ddr_transfer(source_address,smart_buf_num,length_in_words,preamble,DMA_SMART_BUFFER_PREAMBLE_WORDS,true);
				        								        				 continue;
				        				  }

				        				  if (mapped_val == enSVSendToUDPViaDDR) {
				        					  result_str << dma_and_udp_controller_inst.dma_to_udp_via_ddr_transfer(source_address,smart_buf_num,length_in_words,preamble,DMA_SMART_BUFFER_PREAMBLE_WORDS);
				        					  continue;
				        				  }

				        				  if (mapped_val == enSVRelativeSendDMAMemorytoMemory) {
				        					  result_str << dma_and_udp_controller_inst.relative_dma_to_ddr_transfer(source_address,smart_buf_num,length_in_words,preamble,DMA_SMART_BUFFER_PREAMBLE_WORDS);
				        					  continue;
				        				  }

				        				  if (mapped_val == enSVRelativeSendToUDPViaDDR) {
				        					  result_str << dma_and_udp_controller_inst.relative_dma_to_udp_via_ddr_transfer(source_address,smart_buf_num,length_in_words,preamble,DMA_SMART_BUFFER_PREAMBLE_WORDS);
				        					  continue;
				        				  }

				        				  if (mapped_val == enSVAsyncSendToUDPViaDDR) {
				        					  result_str << dma_and_udp_controller_inst.dma_to_udp_via_ddr_transfer(source_address,smart_buf_num,length_in_words,preamble,DMA_SMART_BUFFER_PREAMBLE_WORDS,true);
				        					  continue;
				        				  }

				        				  if (mapped_val == enSVAsyncRelativeSendToUDPViaDDR) {
				        					  result_str << dma_and_udp_controller_inst.relative_dma_to_udp_via_ddr_transfer(source_address,smart_buf_num,length_in_words,preamble,DMA_SMART_BUFFER_PREAMBLE_WORDS,true);
				        					  continue;
				        				  }
				        				  if (mapped_val == enSVAsyncX2SendToUDPViaDDR) {
				        					  result_str << dma_and_udp_controller_inst.dma_to_udp_via_ddr_transfer(source_address,smart_buf_num,length_in_words,preamble,DMA_SMART_BUFFER_PREAMBLE_WORDS,true,true);
				        					  continue;
				        				  }

				        				  if (mapped_val == enSVAsyncX2RelativeSendToUDPViaDDR) {
				        					  result_str << dma_and_udp_controller_inst.relative_dma_to_udp_via_ddr_transfer(source_address,smart_buf_num,length_in_words,preamble,DMA_SMART_BUFFER_PREAMBLE_WORDS,true,true);
				        					  continue;
				        				  }
				        			  }
				        		  }
				        	  }

				          );
				          outp("Total time for this DMA command: " << total_time_for_this_command << " cycles, which is: " << get_timestamp_diff_in_usec(total_time_for_this_command) << " usecs" << std::endl);
				          } continue;
					#endif

#endif


				          case enSVSetStoredCommand:  {
				        	                                  unsigned command_index;
															  int num_args_received = sscanf(argvstr.c_str(), "%u", &command_index);
															  std::string the_stored_command;
															  if (num_args_received != 1)
															  {
																outp("Error: Usage is: set_stored_command command_index command \n");
																continue;
															  } else
															  {
																  the_stored_command = get_second_string_and_trim(argvstr);
																  stored_commands[command_index] = the_stored_command;
																  outp("Storing (" << the_stored_command << ") as stored command #"<< command_index);

															  }
				                                      }
													  continue;

				          case enSVExecStoredCommand:  {
				        	                                  if (is_a_recursive_call) {
				        	                                	  outp("Error: Usage is: exec_stored_command cannot be called within a stored command! \n");
				        	                                	  continue;
				        	                                  }
															  unsigned command_index;
															  int num_args_received = sscanf(argvstr.c_str(), "%u", &command_index);
															  if (num_args_received != 1) {
																  outp("Error: Usage is: exec_stored_command command_index \n");
																  continue;
															  }

															  if (stored_commands.find(command_index) != stored_commands.end()) {
																  result_str << inner_do_linnux_command(linnux_main_menu_mapStringValues,stored_commands[command_index], is_called_from_tcl_script,  is_called_from_command_window, calling_command_type,1);
																  continue;
															  }
														  }
														  continue;


					case enSVPrintStoredCommand :{
	        	                                  unsigned command_index;
												  int num_args_received = sscanf(argvstr.c_str(), "%u", &command_index);
												  if (num_args_received != 1) {
													  outp("Error: Usage is: print_stored_command command_index \n");
													  continue;
												  }

												  if (stored_commands.find(command_index) != stored_commands.end()) {
													  result_str << stored_commands[command_index];
													  outp("Stored Command " << command_index << " is (" << result_str.str() << ")" << std::endl);
													  continue;
												  } else {
													  outp("Stored Command " << command_index << " not found!!! " << std::endl);
												  }
											  }
											  continue;

					default:
						s_mapStringValues.erase(command_string);
						if (command_found) {
						  *command_found = 0;
						}
						out_to_all_streams("erased inadvertently created command: [" << command_string << "]" << std::endl);
						out_to_all_streams("Error: Unrecognized Command. [" << command_string << "].  Type 'H' for help.\n");
						result_str << "0 Error: Unrecognized Command";
		}
	} while (command_strings_from_file.size() > 0);

	active_led = 0;
	user_leds.write (get_user_leds);
	send_myostream_to_ethernet_stdout();
	//if (result_str.str().length() == 0) {
	//	result_str << "1 OK"; //avoid empty responses
    //}
	return (result_str.str());
}



string do_linnux_command(string& input_str_from_external_func, int is_called_from_tcl_script,LINNUX_COMAND_TYPES calling_command_type, int* command_found)
{
	return(inner_do_linnux_command(linnux_main_menu_mapStringValues,input_str_from_external_func,is_called_from_tcl_script,0,calling_command_type,0,command_found));
}




string bedrock_exec_linnux_command_from_picol(std::string cmd)
{
	return(inner_do_linnux_command(linnux_main_menu_mapStringValues,cmd,1,0,LINNUX_IS_A_TCL_COMMAND));
	//cout << "Exectute Linnux Command\n" << endl;
}

void bedrock_linnux_control_main(void *pd)
{
 linnux_remote_command_container* remote_command_container_inst = NULL;
 std::ostringstream board_id_prompt;
 board_id_prompt << "linnux_board"<< get_linnux_board_id()<<"["<<TrimSpacesFromString(low_level_get_testbench_description())<<"]"<<"[Control]";
 Control_Menu_System_Initialize(linnux_control_menu_mapStringValues);

 while(1)
 {
	 c_out_to_all_streams("\n["<<board_id_prompt.str()<<"]>>>");
 	 c_send_myostream_to_ethernet_stdout();
     std::string result_str;
     remote_command_container_inst = get_new_command_for_linnux_control_from_ethernet();

     if (remote_command_container_inst != NULL) {
             std::string command_str = remote_command_container_inst->get_command_string();
			 safe_print(std::cout << "\n[linnux_control] Received command: [" << remote_command_container_inst->get_command_string() << "]" << std::endl);
			 if (remote_command_container_inst->get_command_string() != "")
			 {
				 //inner_do_linnux_command(linnux_control_menu_mapStringValues,remote_command_container_inst->get_command_string(),global_testbench_pointer,0,1);
				 result_str = do_linnux_command(command_str,0,LINNUX_IS_A_CONSOLE_COMMAND);
				 if (we_are_in_control_verbose_mode) { out_to_all_streams(result_str); };
			 }
			 delete remote_command_container_inst;
			 remote_command_container_inst = NULL;
     } else {
    	 safe_print(std::cout << "bedrock_linnux_control_main: remote_command_container_inst = NULL!" << std::endl);
     }
 	 MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_PROCESS_DLY_MS);//delay the task to give a chance to the Ethernet to function
 }

}



string bedrock_exec_linnux_control_command_from_tcl(std::string cmd)
{
	return string("bedrock_exec_linnux_control_command_from_tcl done command");// (inner_do_linnux_command(linnux_control_menu_mapStringValues,cmd,global_testbench_pointer,0,1));
}



void bedrock_dut_processor_control_main(void *pd)
{

	INT8U error_code;

	    if (tcl_script_registered_DUT_diag_func) {
	     tcl_DUT_diag_cpp_wrapper_func();
	    }
		while(1)
		{
			MyOSTimeDlyHMSM(0,0,DEVICE_MONITOR_SLEEP_TIME_IN_SECS,0);
		}
		safe_print(printf("We should have never gotten here!\n"));

	/*
 linnux_remote_command_container* remote_command_container_inst = NULL;
 std::string the_command, dut_processor_cmd_response;
 std::ostringstream board_id_prompt;
 int dut_processor_cmd_result;
 board_id_prompt << "linnux_board"<< get_linnux_board_id()<<"["<<TrimSpacesFromString(low_level_get_testbench_description())<<"]"<<"[DUT Processor]";

 while(1)
 {
	 out_to_all_streams("\n["<<board_id_prompt.str()<<"]>>>");
 	 send_myostream_to_ethernet_stdout();
     remote_command_container_inst = get_new_command_for_dut_processor_control_from_ethernet();
     if (remote_command_container_inst != NULL) {
			 safe_print(std::cout << "\n[dut_processor_control] Received command: [" << remote_command_container_inst->get_command_string() << "]" << std::endl);
			 if ((the_command=remote_command_container_inst->get_command_string()) != "")
			 {
			  safe_print(std::cout << "Executing DUT Proc Command [" << the_command << "]" << std::endl);
			  dut_processor_cmd_result = 1;//execute_dut_proc_command_and_get_response(dut_proc_cmd_communicator,the_command,dut_processor_cmd_response);
			  safe_print(std::cout << "Got result: [" << dut_processor_cmd_result << "] response string: [" << dut_processor_cmd_response << "]" << std::endl);
			  out_to_all_streams("DUT Proc Result: [" << dut_processor_cmd_result << "] DUT Proc Response: " << dut_processor_cmd_response << "\n");
			 }
			 delete remote_command_container_inst;
			 remote_command_container_inst = NULL;
     } else {
    	 safe_print(std::cout << "bedrock_dut_processor_control_main: remote_command_container_inst = NULL!" << std::endl);
     }
 	 MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_PROCESS_DLY_MS);//delay the task to give a chance to the Ethernet to function
    }
   */
}
