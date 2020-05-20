/*
 * generic_driver_encapsulator.cpp
 *
 *  Created on: Nov 7, 2015
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
#include "generic_driver_encapsulator.h"
#include "debug_macro_definitions.h"

#ifndef DEBUG_GENERIC_DRIVER
#define DEBUG_GENERIC_DRIVER 0
#endif

#define d_da(x) do { if (DEBUG_GENERIC_DRIVER) { x; } } while(0)

#define BYTES_PER_WORD (4)

generic_driver_encapsulator::~generic_driver_encapsulator() {
	// TODO Auto-generated destructor stub
}

generic_driver_encapsulator::generic_driver_encapsulator(unsigned long the_base_address, unsigned long span_in_bytes, std::string name,  unsigned long bytes_per_location) {
	this->span_in_bytes = span_in_bytes;
	this->base_address = the_base_address;
	this->name = name;
	this->bytes_per_location = bytes_per_location;
}

unsigned long generic_driver_encapsulator::read(unsigned the_reg_num){
	 unsigned long addr = base_address + bytes_per_location*the_reg_num;

	 unsigned long data;
	     switch (bytes_per_location) {
	     case 1: data	 = __builtin_ldbio((void *)addr); break;
	     case 2: data	 = __builtin_ldhio((void *)addr); break;
	     case 4: data	 = __builtin_ldwio((void *)addr); break;
	     default: data	 = __builtin_ldwio((void *)addr); break;
	 }
     d_da(printf("read from %x: got: %x base_address = %x the_reg_num = %x\n",addr,data,base_address,the_reg_num););
	 return data;
};

void generic_driver_encapsulator::write(unsigned the_reg_num, unsigned long data) {
	unsigned long addr = base_address + bytes_per_location*the_reg_num;

	 switch (bytes_per_location) {
		 case 1: __builtin_stbio((void *)addr,data);  break;
		 case 2: __builtin_sthio((void *)addr,data);  break;
		 case 4: __builtin_stwio((void *)addr,data);  break;
		 default: __builtin_stwio((void *)addr,data); break;
		 }

    d_da(printf("wrote to %x: with data: %x base_address = %x the_reg_num = %x\n",addr,data, base_address,the_reg_num););

	//IOWR_32DIRECT(base_address,BYTES_PER_WORD*the_reg_num,data);
};
unsigned long  generic_driver_encapsulator::get_span_in_bytes() const {
	return this->span_in_bytes;
};
void generic_driver_encapsulator::set_span_in_bytes(unsigned long span_in_bytes) {
	this->span_in_bytes = span_in_bytes;
};
unsigned long  generic_driver_encapsulator::get_base_address() const {
	return this->base_address;
};
void generic_driver_encapsulator::set_base_address(unsigned long base_address){
	this->base_address = base_address;
};
void generic_driver_encapsulator::turn_on_bit(unsigned the_reg_num, unsigned long bit){
	unsigned long  val;
		val = read(the_reg_num);
		//std::cout << std::hex << "read val = " << val << std::endl;
		val = val | (((unsigned long)1) << bit);
		//std::cout << std::hex << "new val = " << val << " bit =  " << bit << " mask = " << (((unsigned long)1) << bit) << std::endl;
		write(the_reg_num,val);
		//std::cout << std::hex << "confirmed val = " << read() << std::endl;
};

void generic_driver_encapsulator::turn_off_bit(unsigned the_reg_num, unsigned long bit){
	unsigned long  val;
	val = read(the_reg_num);
   	val = val & (~(((unsigned long)1) << bit));
	write(the_reg_num,val);
};

unsigned long generic_driver_encapsulator::get_bit(unsigned the_reg_num, unsigned long bit){
	unsigned long  val;
	val = read(the_reg_num);
	//std::cout << std::hex << "read val = " << val << std::endl;
	return ((val & (((unsigned long)1) << bit)) != 0);
}


void generic_driver_encapsulator::set_bit(unsigned the_reg_num, unsigned long bit, unsigned int val) {
	if (val) {
        this->turn_on_bit(the_reg_num,bit);
	} else {
		this->turn_off_bit(the_reg_num,bit);
	}
}

void generic_driver_encapsulator::set_bytes_per_location(unsigned long bytes_per_location) {
	this->bytes_per_location  = bytes_per_location;
}
unsigned long generic_driver_encapsulator::get_bytes_per_location() {
	return bytes_per_location;
}

unsigned long generic_driver_encapsulator::read_reg_by_byte_offset(unsigned long byte_offset){
	  unsigned long regnum;
	     switch (bytes_per_location) {
	     case 1:  regnum = byte_offset; break;
	     case 2:  regnum = byte_offset >> 1; break;
	     case 4:  regnum = byte_offset >> 2; break;
	     default: regnum = byte_offset >> 2; break;
	 }
	 return read(regnum);
};

void generic_driver_encapsulator::write_reg_by_byte_offset(unsigned long byte_offset, unsigned long data){
	  unsigned long regnum;
	  switch (bytes_per_location) {
	     case 1:  regnum = byte_offset; break;
	     case 2:  regnum = byte_offset >> 1; break;
	     case 4:  regnum = byte_offset >> 2; break;
	     default: regnum = byte_offset >> 2; break;
	 }
	 return write(regnum,data);
};
