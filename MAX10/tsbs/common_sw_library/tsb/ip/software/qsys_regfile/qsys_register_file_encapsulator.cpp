/*
 * qsys_register_file_encapsulator.cpp
 *
 *  Created on: May 20, 2016
 *      Author: user
 */

#include <stdio.h>
#include <stdlib.h> // malloc, free
#include <string.h>
#include <stddef.h>
#include <unistd.h>  // usleep (unix standard?)
//#include "sys/alt_flash.h"
//#include "sys/alt_flash_types.h"
#include "io.h"
#include "alt_types.h"  // alt_u32
#include "altera_avalon_pio_regs.h" //IOWR_ALTERA_AVALON_PIO_DATA
#include "sys/alt_irq.h"  // interrupt
#include "sys/alt_alarm.h" // time tick function (alt_nticks(), alt_ticks_per_second())
#include "sys/alt_timestamp.h"
#include "sys/alt_stdio.h"
#include "basedef.h"
#include "qsys_register_file_encapsulator.h"
#include "qsys_slave_template_macros.h"

#ifndef DEBUG_QSYS_REGISTER_FILE
#define DEBUG_QSYS_REGISTER_FILE 0
#endif


#define d_da(x) do { if (DEBUG_QSYS_REGISTER_FILE) { x; } } while(0)


#define BYTES_PER_WORD (4)

            	 unsigned long qsys_register_file_encapsulator::get_datain_reg_word_addr(unsigned long regnum){
            		 return (SLAVE_TEMPLATE_PER_REGISTER_WORD_SPAN*regnum+SLAVE_TEMPLATE_DATA_IN_OFFSET);
            	 }
            	 unsigned long qsys_register_file_encapsulator::get_dataout_reg_word_addr(unsigned long regnum){
            		 return (SLAVE_TEMPLATE_PER_REGISTER_WORD_SPAN*regnum+SLAVE_TEMPLATE_DATA_OUT_OFFSET);
            	 }

qsys_register_file_encapsulator::~qsys_register_file_encapsulator() {
	// TODO Auto-generated destructor stub
}


unsigned long qsys_register_file_encapsulator::read_datain(unsigned the_reg_num){
	 return read(get_datain_reg_word_addr(the_reg_num));
};

unsigned long qsys_register_file_encapsulator::read_dataout(unsigned the_reg_num){
	 return read(get_dataout_reg_word_addr(the_reg_num));
};

void qsys_register_file_encapsulator::write_dataout(unsigned the_reg_num, unsigned long data) {
	return write(get_dataout_reg_word_addr(the_reg_num),data);
};
void qsys_register_file_encapsulator::turn_on_dataout_bit(unsigned the_reg_num, unsigned long bit){
	return (turn_on_bit(get_dataout_reg_word_addr(the_reg_num),bit));
};

void qsys_register_file_encapsulator::turn_off_dataout_bit(unsigned the_reg_num, unsigned long bit){
	return (turn_off_bit(get_dataout_reg_word_addr(the_reg_num),bit));
};


unsigned long qsys_register_file_encapsulator::get_datain_bit(unsigned the_reg_num, unsigned long bit){
	return (get_bit(get_datain_reg_word_addr(the_reg_num),bit));
}

unsigned long qsys_register_file_encapsulator::get_dataout_bit(unsigned the_reg_num, unsigned long bit){
	return (get_bit(get_dataout_reg_word_addr(the_reg_num),bit));
}


