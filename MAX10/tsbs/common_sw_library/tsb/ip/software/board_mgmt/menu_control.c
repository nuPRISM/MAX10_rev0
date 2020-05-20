/*
 * Copyright (c) 2009 Xilinx, Inc.  All rights reserved.
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 */

/*
 * helloworld.c: simple test application
 */

#include "basedef.h"
#include <stdio.h>
#include "sys/alt_stdio.h"
#include <string.h>
#include "adc_mcs_basedef.h"
#include <xprintf.h>
#include "rsscanf.h"
#include "misc_str_utils.h"
#include "process_command.h"
#include "new_simple_uart_driver.h"
#include "pio_encapsulator.h"
#include "alt_eeprom.h"
#include "fifoed_avalon_uart.h"
#include "alt_types.h"
#include "sys/alt_dev.h"
#include "fifoed_avalon_uart.h"
#include "jtag_safe_print.h"

//#include "memory_comm_encapsulator_c.h"

//int ALT_OPEN (const char* file, int flags, int mode)
//extern fifoed_avalon_uart_state* fifoed_avalon_uart_0;
char MCS_PROCESSOR_NAME[16] = "BOARD_MGMT\0\0\0\0\0\0\0";
int enable_debug_printfs = BOARD_MANAGEMENT_DEBUG;

FILE* uart_fp;

void print(char *str);


//int verbose_jtag_debug_mode = 1;
int allow_stdout_printf = 1;



unsigned char chan_getc() {
#ifdef USE_UART_FOR_COMMUNICATION_WITH_MAIN_PROCESSOR
	int c;
	dp("getc waiting for char...");
	c = getc(uart_fp);
	dp("getc got %x which is char %c\n",(unsigned int)c, c);
	if (c > 0) {
		return ((char) c);
	} else {
		return 0;
	}
#else
	alt_printf("error: using mem_comm but got call to chan_getc!\n");
	return 0;
#endif
}

void chan_putc(unsigned char c) {
#ifdef USE_UART_FOR_COMMUNICATION_WITH_MAIN_PROCESSOR
	if (allow_stdout_printf) {
		putc((int)c,uart_fp);
    }
#else
   alt_printf("error: using mem_comm but got call to chan_putc!\n");
#endif
}


int menu_control()
{

//	xdev_out(chan_putc);
//	xdev_in(chan_getc);
//
//	allow_stdout_printf = 1; //Assume that we're connected
//
//
//#ifdef USE_UART_FOR_COMMUNICATION_WITH_MAIN_PROCESSOR
//    dp("Entered Menu Control\n");
//	uart_fp = fopen ("/dev/BoardManagement_0_fifoed_avalon_uart_0", "r+"); //Open file for reading and writing
//	dp("uart_fp = %x\n",(int)(uart_fp));
//	if (uart_fp == NULL) {
//		alt_printf("Error: could not open UART!!! - stopping\n");
//		while (1) {};
//	}
//
//	char command_response_str[UART_MEMM_COMM_MAX_STR_LENGTH_IN_CHARS];
//	char cmd_buf[UART_MEMM_COMM_COMMAND_BUFFER_LENGTH_IN_CHARS];
//#else
//	init_memory_comm_encapsulator();
//	char command_response_str[BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_MAX_STR_LENGTH_IN_CHARS];
//	char cmd_buf[BOARD_MGMT_MEMM_COMM_AUX_COMMAND_BUFFER_LENGTH];
//
//#endif
//	command_response_str[0] = '\0';
//
//	for (;;)
//	{
//
//#ifdef USE_UART_FOR_COMMUNICATION_WITH_MAIN_PROCESSOR
//		dp("waiting for command...\n");
//		command_response_str[0] = '\0'; //reset response string
//		//command_received = xgets(cmd_buf,ADC_MCS_COMMAND_BUFFER_LENGTH);
//		fgets(cmd_buf,(ADC_MCS_COMMAND_BUFFER_LENGTH-1),uart_fp);
//		dp("command received: %s\n",cmd_buf);
//		process_command(cmd_buf,command_response_str,UART_MEMM_COMM_MAX_STR_LENGTH_IN_CHARS-UART_MEMM_COMM_DEFAULT_STRING_SAFETY_BUFFER_IN_CHARS);
//		dp("command response: %s\n",command_response_str);
//		//xprintf("%s",command_response_str);
//#else
//		dp("setting command_response to mem_comm...\n");
//		mem_comm_set_command_response(command_response_str);
//		command_response_str[0] = '\0'; //reset response string
//		dp("waiting for command from mem_comm...\n");
//	    mem_comm_get_new_command(cmd_buf,BOARD_MGMT_MEMM_COMM_AUX_COMMAND_BUFFER_LENGTH);
//		dp("command received: %s\n",cmd_buf);
//	    process_command(cmd_buf,command_response_str,BOARD_MGMT_MEMM_COMM_AUX_COMMAND_BUFFER_LENGTH,BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_MAX_STR_LENGTH_IN_CHARS-BOARD_MGMT_MEMM_COMM_DEFAULT_STRING_SAFETY_BUFFER_IN_CHARS);
//	    dp("command response: %s\n",command_response_str);
//#endif
//	}
//
//	/* Event loop never exits. */
//	while (1);

	return (0);
}


