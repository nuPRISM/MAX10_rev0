/*
 * memory_comm_encapsulator.cpp
 *
 *  Created on: Nov 19, 2011
 *      Author: user
 */
extern "C" {
#include "memory_comm_encapsulator_c.h"
#include "strlen.h"
#include "system.h"
#include "sys/alt_stdio.h"
#include "adc_mcs_basedef.h"
#include "xprintf.h"
#include "dp_mem_api.h"
#include "altera_avalon_pio_regs.h"
}

#include <stdio.h>
#include <string.h>
#include <iostream>


static volatile unsigned long command_counter;
static volatile unsigned long *response_str_length_ptr;
static volatile unsigned long *command_ctr_ptr;
static volatile unsigned long *command_ready_ptr;
static volatile unsigned long *command_request_ptr;
static volatile unsigned long *alive_magic_word_ptr;
static volatile unsigned long response_str_32bit_offset;
static volatile unsigned long *response_str_ptr;
static volatile unsigned long *command_str_ptr;

#define d_dm(x) do {			\
                    if (dual_port_ram_container_DEBUG) {std::cout << " File: " << __FILE__ << " Line: " << __LINE__ << " Func: " << __func__ << std::endl; x;}\
                } while (0)

extern int verbose_jtag_debug_mode;

#define DEBUG_MEM_COMM

void init_memory_comm_encapsulator()
{
	mem_comm_set_command_counter(0);
	command_ctr_ptr = (unsigned long *) (BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_REGION_BASE+BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_OFFSET_COMMAND_COUNTER_OFFSET);
	response_str_length_ptr = (unsigned long *) (BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_REGION_BASE+BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_OFFSET_COMMAND_LENGTH_OFFSET);
	response_str_32bit_offset = (BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_REGION_BASE_OFFSET_IN_BYTES + BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_OFFSET_START_OF_RESPONSE_STR) >> 2;
	command_ready_ptr = (unsigned long *) (BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_REGION_BASE+BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_OFFSET_COMMAND_READY_OFFSET);
	command_request_ptr = (unsigned long *) (BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_REGION_BASE+BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_OFFSET_COMMAND_REQUEST_OFFSET);
	alive_magic_word_ptr = (unsigned long*) (BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_REGION_BASE+BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_OFFSET_SLAVE_ALIVE_OFFSET);
	response_str_ptr = (unsigned long*) (BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_REGION_BASE+BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_OFFSET_START_OF_RESPONSE_STR);
	command_str_ptr = (unsigned long*) (BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_REGION_BASE+BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_OFFSET_START_OF_RESPONSE_STR);
	*command_request_ptr = 0;
	*command_ready_ptr = 1;
	*alive_magic_word_ptr = BOARD_MGMT_MEMM_COMM_AUX_MEMORY_MEMORY_COMM_IS_ALIVE_MAGIC_WORD;
	d_dm( unsigned long tmp = (*alive_magic_word_ptr); alt_printf("*alive_magic_word_ptr = %x, alive_magic_word_ptr = %x", tmp, ((unsigned long) alive_magic_word_ptr)));
} ;



void write_to_dut_gp_ram(unsigned long offset, unsigned long data)
{
	write_32_bits_to_dp_mem(offset,data);
}

unsigned long read_from_dut_gp_ram(unsigned long offset)
{
	return read_32_bits_from_dp_mem(offset);
}

static void print_str_to_gp_ram(char* the_str, unsigned long offset, unsigned long len)
	   {
	   	unsigned long i;
	   	unsigned long val_to_write;
	   	unsigned long current_offset = offset;

		if (len > BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_MAX_STR_LENGTH_IN_CHARS) {
			the_str[BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_MAX_STR_LENGTH_IN_CHARS-1] = '\0';
			d_dm(alt_printf("[print_str_to_gp_ram] Error: Response: [%s] too long, truncating to %x characters\n",the_str,BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_MAX_STR_LENGTH_IN_CHARS));
		}

	   	for (i = 0; (i+3) < len; i+=4)
	   	{
	   		val_to_write = (((unsigned long) the_str[i+3]) << 24) + (((unsigned long) the_str[i+2]) << 16) + (((unsigned long) the_str[i+1]) << 8) + ((unsigned long) the_str[i]);
	   		write_to_dut_gp_ram(current_offset,val_to_write);
	   		//d_dm(alt_printf("Wrote val: %x to address %x\n", val_to_write,current_offset));
	   		current_offset += 1;
	   	}

	   	val_to_write = 0;
	   	if (i != len) {
	   		val_to_write = (((i+3) < len) ? (((unsigned long) the_str[i+3]) << 24) : 0) +
	   				       (((i+2) < len) ? (((unsigned long) the_str[i+2]) << 16) : 0) +
	   				       (((i+1) < len) ? (((unsigned long) the_str[i+1]) << 8) : 0) +
	   		               (((i) < len) ? (((unsigned long) the_str[i])) : 0);
	   	}
	   	write_to_dut_gp_ram(current_offset,val_to_write);
   		//d_dm(alt_printf("Wrote val: %x to address %x\n", val_to_write,current_offset));
}

static void get_str_from_gp_ram(volatile unsigned long offset, char* buff, unsigned int maxlen)
{
	unsigned long c1, c2 , c3, c4;
	unsigned long val;
	unsigned long position_counter;
	unsigned long current_offset = offset;
	position_counter = 0;
	do  {
		val = read_32_bits_from_dp_mem(current_offset);
		d_dm(alt_printf("[get_str_from_gp_ram] read value of %x from addr %x\n",val,current_offset));
		if ((c1 = (val & 0xFF)) != 0) buff[position_counter++] = ((char)(c1));
		if ((c2 = (val & 0xFF00)) != 0) buff[position_counter++] = ((char)(c2 >> 8));
		if ((c3 = (val & 0xFF0000)) != 0) buff[position_counter++] =((char)(c3 >> 16));
		if ((c4 = (val & 0xFF000000)) != 0) buff[position_counter++] = ((char)(c4 >> 24));
		d_dm(alt_printf("[get_str_from_gp_ram] c1 = %x cc1 = %c c2 = %x cc2 = %c c3 = %x cc3 = %c c4 = %x cc4 = %c\n",c1,(char)c1,c2,(char)c2,c3,(char)c3,c4,(char)c4));
		current_offset++;
	} while ((position_counter< maxlen) && !((c1 == 0) || (c2 == 0) || (c3 == 0) || (c4 == 0)));

	if (position_counter < maxlen)
	{
	  buff[position_counter] = '\0';
	} else {
		buff[maxlen-1] = '\0'; //just in case
	}
	d_dm(alt_printf("[get_str_from_gp_ram]Got Command of: [%s]\n",buff));

}
static void get_str_from_gp_ram_direct(volatile unsigned long* start_addr, char* buff, unsigned int maxlen)
{
	unsigned char c1, c2 , c3, c4;
	unsigned long val;
	unsigned long position_counter;
	unsigned long current_offset = 0;
	unsigned long addr;
	position_counter = 0;
	do  {
		addr= ((unsigned long) start_addr)+current_offset*4;
		val = *((unsigned long *) addr);
		d_dm(alt_printf("[get_str_from_gp_ram_direct] read value of %x from addr %x\n",val,(unsigned int) addr));
		c1 = (char) val & 0xFF;
		c2 = (char) ((val >> 8) & 0xFF);
		c3 = (char) ((val >> 16) & 0xFF);
		c4 = (char) ((val >> 24) & 0xFF);
		if (c1 != 0) buff[position_counter++] = c1;
		if (c2 != 0) buff[position_counter++] = c2;
		if (c3 != 0) buff[position_counter++] = c3;
		if (c4 != 0) buff[position_counter++] = c4;
		d_dm(alt_printf("[get_str_from_gp_ram_direct] c1 = %c c2 = %c c3 = %c c4 = %c\n",c1,c2,c3,c4));
		current_offset++;
	} while ((position_counter< maxlen) && !((c1 == 0) || (c2 == 0) || (c3 == 0) || (c4 == 0)));

	if (position_counter < maxlen)
	{
	  buff[position_counter] = '\0';
	} else {
		buff[maxlen-1] = '\0'; //just in case
	}
	d_dm(alt_printf("[get_str_from_gp_ram_direct]Got Command of: [%s]\n",buff));

}
unsigned long mem_comm_get_command_counter() { return command_counter;};
void mem_comm_set_command_counter(unsigned long x) { command_counter = x; };
void mem_comm_set_command_response(char* the_response)
{
    unsigned long len;
    len = strlen(the_response);

	if (verbose_jtag_debug_mode) {
		d_dm(alt_printf("Sending string response [%s]\n",the_response));
	}
	if (len > BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_MAX_STR_LENGTH_IN_CHARS) {
		the_response[BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_MAX_STR_LENGTH_IN_CHARS-1] = '\0';
		d_dm(alt_printf("[mem_comm_set_command_response] Error: Response: [%s] too long, truncating to %x characters\n",the_response,BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_MAX_STR_LENGTH_IN_CHARS));
	}

	mem_comm_set_command_counter(mem_comm_get_command_counter()+1);

	*response_str_length_ptr = len;
	*command_ctr_ptr=mem_comm_get_command_counter();
	print_str_to_gp_ram(the_response,response_str_32bit_offset,len);
	//snprintf((char *)response_str_ptr,BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_MAX_STR_LENGTH_IN_CHARS,"%s",the_response);
	*command_request_ptr = 0;
	*command_ready_ptr = 1;
	d_dm(alt_printf("[mem_comm_set_command_response] sent string: (%s) \n",(char *)the_response));
};

void mem_comm_get_new_command(char* buff, unsigned int maxlen)
{

	if (verbose_jtag_debug_mode) {
		d_dm(alt_printf("\n[mem_comm_get_new_command] Waiting for command, command_request_ptr = %x\n",((unsigned long)command_request_ptr)));
	}

	int counter = 0;
	while (!(*command_request_ptr))
	{
		/*
		int i;
		counter++;
		for (i = 0; i < 10000; i++) {
			IORD_ALTERA_AVALON_PIO_DATA(BOARDMANAGEMENT_0_GP_IN_BASE); //do something that cannot be optimized out
		};*/
	//	d_dm(alt_printf("[mem_comm_get_new_command] Still waiting for command... *command_request_ptr = %x command_request_ptr = %x counter = %d\n",(*command_request_ptr),command_request_ptr,counter));
#if BOARD_MGMT_MEMM_COMM_AUX_ALLOW_COMMANDS_FROM_LOCAL_CONSOLE
				 if (!(read_switches() && BOARD_MGMT_MEMM_COMM_AUX_USE_MEM_COMM_INPUT_FOR_COMMMANDS_SWITCH_MASK))
				 {
					 d_dm(alt_printf("[mem_comm_get_new_command] Aborted command wait due to user request\n"));
					 buff[0] = '\0';
					 return;
				 }
#endif

	}
    *command_request_ptr = 0; //so we don't get the same command twice

	if (verbose_jtag_debug_mode) {
		d_dm(alt_printf("[mem_comm_get_new_command] Recognized Command Condition!\n"));
	}

	//get_str_from_gp_ram(response_str_32bit_offset,buff,maxlen-1);
	get_str_from_gp_ram_direct(response_str_ptr,buff,maxlen-1);

	//snprintf(buff,BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_MAX_STR_LENGTH_IN_CHARS,"%s",(char *)command_str_ptr);
	d_dm(alt_printf("[mem_comm_set_command_response] sent string: (%s) \n",(char *)buff));
	if (verbose_jtag_debug_mode) {
		d_dm(alt_printf("[mem_comm_get_new_command]Got Command of: [%s]\n",buff));
	}

};
