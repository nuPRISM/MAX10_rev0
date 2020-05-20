/*
 * memory_mapped_uart_based_io_read_write_class.cpp
 *
 *  Created on: Feb 27, 2015
 *      Author: yairlinn
 */

#include <stdio.h>
#include <iostream>
#include "basedef.h"
#ifndef DEBUG_MEMORY_MAPPED_UART_BASED_IO_READ_WRITE_CLASS
#define DEBUG_MEMORY_MAPPED_UART_BASED_IO_READ_WRITE_CLASS (0)
#endif

#define u(x) do { if (DEBUG_MEMORY_MAPPED_UART_BASED_IO_READ_WRITE_CLASS) { std::cout << x; std::cout.flush();   } } while (0)
#include "memory_mapped_uart_based_io_read_write_class.h"
   unsigned long memory_mapped_uart_based_io_read_write_class::read(unsigned long addr) {
		  //address should be in WORDS
	   unsigned long actual_address = addr;
	   unsigned long read_value = IORD(control_base,actual_address);
	     u("in read, to reg = " << std::hex << addr << " read value = " << read_value << " Actual Address = " << actual_address << " control_base = " << control_base << " calculated_address = " << __IO_CALC_ADDRESS_NATIVE ((control_base), (actual_address)) << std::dec << std::endl );
         return read_value;
	   };
	    void memory_mapped_uart_based_io_read_write_class::write (unsigned long addr, unsigned long data){
	    	unsigned long actual_address = addr;
	        u("in write, to reg = " << addr << "Actual Address = " << actual_address << " control_base = " << control_base << " calculated_address = " << __IO_CALC_ADDRESS_NATIVE ((control_base), (actual_address)) << std::endl );
		    IOWR(control_base,actual_address,data);
	   };

	    unsigned long memory_mapped_uart_based_io_read_write_class::read_status(unsigned long addr) {
	    	unsigned long actual_address = addr;
	 	    unsigned long read_value = IORD(status_base,actual_address);
	    	u("in read_status, to reg = " << std::hex << addr << " read value = " << read_value << " Actual Address = " << actual_address << " status_base = " << status_base << " calculated_address = " << __IO_CALC_ADDRESS_NATIVE ((status_base), (actual_address)) << std::dec << std::endl );

		     return read_value;
	   };

    memory_mapped_uart_based_io_read_write_class::~memory_mapped_uart_based_io_read_write_class(){

    };
