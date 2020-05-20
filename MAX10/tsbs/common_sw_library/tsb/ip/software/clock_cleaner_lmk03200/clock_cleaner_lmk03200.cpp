/*
 * clock_cleaner_lmk03200.cpp
 *
 *  Created on: Mar 6, 2014
 *      Author: yairlinn
 */

#include "clock_cleaner_lmk03200/clock_cleaner_lmk03200.h"
#include <system.h>
#include <drivers/inc/altera_avalon_spi.h>
#include <drivers/inc/altera_avalon_spi_regs.h>
#include <drivers/inc/altera_avalon_pio_regs.h>
#include <unistd.h>
#include "basedef.h"
#include "linnux_utils.h"

extern "C" {
#include "xprintf.h"
}


clock_cleaner_lmk03200::clock_cleaner_lmk03200() {
	// TODO Auto-generated constructor stub

}


void clock_cleaner_lmk03200::LMK03200_Cmd(unsigned long cmd) {
	alt_u8 tx_data[4];

	tx_data[0] = (cmd & 0xFF000000) >> 24;
	tx_data[1] = (cmd & 0x00FF0000) >> 16;
	tx_data[2] = (cmd & 0x0000FF00) >> 8;
	tx_data[3] = (cmd & 0x000000FF);
	alt_avalon_spi_command(this->get_spi_base(), 0, 1, (alt_u8*)&tx_data[0], 0, 0, ALT_AVALON_SPI_COMMAND_MERGE);
	alt_avalon_spi_command(this->get_spi_base(), 0, 1, (alt_u8*)&tx_data[1], 0, 0, ALT_AVALON_SPI_COMMAND_MERGE);
	alt_avalon_spi_command(this->get_spi_base(), 0, 1, (alt_u8*)&tx_data[2], 0, 0, ALT_AVALON_SPI_COMMAND_MERGE);
	alt_avalon_spi_command(this->get_spi_base(), 0, 1, (alt_u8*)&tx_data[3], 0, 0, 0);
	usleep(100000);
}

void clock_cleaner_lmk03200::LMK03200_Configure(void) {
	unsigned long long 	start_timestamp;
	unsigned long long 	end_timestamp;
	unsigned long long 	timestamp_difference;

	static const alt_u32 SYNC_BIT = 0x01;
	static const alt_u32 GOE_BIT  = 0x02;

	IOWR_ALTERA_AVALON_PIO_SET_BITS  (this->get_pio_out_addr(), SYNC_BIT); 	// SYNC HIGH
	IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(this->get_pio_out_addr(), GOE_BIT);

	LMK03200_Cmd(0x80000000);
	LMK03200_Cmd(0x10030300);
	LMK03200_Cmd(0x00030301);
	LMK03200_Cmd(0x00030302);
	LMK03200_Cmd(0x00030303);
	LMK03200_Cmd(0x00030304);
	LMK03200_Cmd(0x00030305);
	LMK03200_Cmd(0x00030306);
	LMK03200_Cmd(0x00030307);
	LMK03200_Cmd(0x0082800b);
	LMK03200_Cmd(0x028c800d);
	LMK03200_Cmd(0x0830040e);
	LMK03200_Cmd(0x0800180F);

	start_timestamp       = os_critical_low_level_system_timestamp();
	// Wait for lock detect
	while(IORD_ALTERA_AVALON_PIO_DATA(this->get_pio_in_addr()) == 0) {
		          end_timestamp=os_critical_low_level_system_timestamp();
		    	  if (start_timestamp > end_timestamp) {
		    		  /* in case of some weird timer wrap */ start_timestamp = end_timestamp;
		    	  }

		    	  timestamp_difference = (end_timestamp - start_timestamp);
		    	  if (timestamp_difference > LINNUX_LMK03200_TIMEOUT_TICKS) {
		    		  xprintf("Error: timeout in LMK03200_Configure: timeout\n");
		    	      break;
		    	  }

	};

	// Enable GOE
	IOWR_ALTERA_AVALON_PIO_SET_BITS(this->get_pio_out_addr(), GOE_BIT);

	// SETUP ZERO PHASE DELAY MODE
	LMK03200_Cmd(0x18030300);
	LMK03200_Cmd(0x0800040F);

	// Resync
	IOWR_ALTERA_AVALON_PIO_SET_BITS  (this->get_pio_out_addr(), SYNC_BIT);
	IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(this->get_pio_out_addr(), SYNC_BIT);
	IOWR_ALTERA_AVALON_PIO_SET_BITS  (this->get_pio_out_addr(), SYNC_BIT);
}
