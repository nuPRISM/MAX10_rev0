/*
 * register_keeper_api.cpp
 *
 *  Created on: Apr 13, 2011
 *      Author: linnyair
 */

#include "register_keeper_api.h"
#include <alt_types.h>
#include <altera_avalon_pio_regs.h>
#include <sys/alt_irq.h>
#include <system.h>
#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <iostream>
#include <fstream>
#include <map>
#include <float.h>
#include <vector>
#include <unistd.h>
#include <time.h>
extern int verbose_jtag_debug_mode;

void write_value_to_reg_keeper_reg(unsigned int address, unsigned long data)
{
	safe_print(std::cout << "Error: write_value_to_reg_keeper_reg not supported!\n");
	/*
	if (verbose_jtag_debug_mode) {
	    printf("Writing:(%X) to reg keeper address (%X)\n",data,(unsigned int) address);
	}
	IOWR_ALTERA_AVALON_PIO_DATA(
			PCBI_MAPPED_REG_KEEPER_BASE+(address<<2),
			data
	);
*/
}

unsigned long read_value_from_reg_keeper_reg(unsigned int address)
{
	safe_print(std::cout << "Error: read_value_from_reg_keeper_reg not supported!\n");
	return 0xeaaeaa;
    /*
	return (IORD_ALTERA_AVALON_PIO_DATA(PCBI_MAPPED_REG_KEEPER_BASE+(address<<2)));
	*/
}

void write_PCBI_reg(unsigned int address, unsigned long data)
{
	safe_print(std::cout << "Error: write_PCBI_reg not supported!\n");
	/*
	if (verbose_jtag_debug_mode) {
	  printf("Writing:(%X) to PCBI address (%X)\n",data,(unsigned int) address);
	}

	IOWR_ALTERA_AVALON_PIO_DATA(
			PCBI_BRIDGE_0_BASE+(address<<2), //the <<2 is to counteract what is done in addr_gen module
			data
	);
  */
}

unsigned long read_PCBI_reg(unsigned int address)
{
	safe_print(std::cout << "Error: read_PCBI_reg not supported!\n");
	return 0;
	//return (IORD_ALTERA_AVALON_PIO_DATA(PCBI_BRIDGE_0_BASE+(address<<2))); //the <<2 is to counteract what is done in addr_gen module

}

void set_large_mux_selector(unsigned long sel)
{
	safe_print(std::cout << "Error: set_large_mux_selector not supported!\n");
/*
	IOWR_ALTERA_AVALON_PIO_DATA(
			LARGE_DATA_INPUT_SELECT_BASE,
			sel
	);
	*/
}

unsigned long read_large_mux_input_data(unsigned long sel)
{
	safe_print(std::cout << "Error: read_large_mux_input_data not supported!\n");
	return 0xeaaeaa;
	/*set_large_mux_selector(sel);
	usleep(1);
	return (IORD_ALTERA_AVALON_PIO_DATA(LARGE_DATA_MUX_BASE));
	*/
}



unsigned long long get_64_bit_value_from_large_mux(unsigned long low_32bit_address)
{
	safe_print(std::cout << "Error: get_64_bit_value_from_large_mux not supported!\n");
	return 0xeaaeaa;

	/*
	unsigned long long low_part = read_large_mux_input_data(low_32bit_address);
	unsigned long long high_part = read_large_mux_input_data(low_32bit_address + 1);
	unsigned long long total = (high_part << 32) + low_part;
	return total;
	*/
}
