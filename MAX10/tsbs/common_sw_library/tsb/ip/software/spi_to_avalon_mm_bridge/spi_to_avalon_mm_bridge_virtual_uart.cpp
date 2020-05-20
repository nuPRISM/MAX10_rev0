/*
 * spi_to_avalon_mm_bridge_virtual_uart.cpp
 *
 *  Created on: Jul 16, 2014
 *      Author: yairlinn
 */

#include "spi_to_avalon_mm_bridge/spi_to_avalon_mm_bridge_virtual_uart.h"
#include "basedef.h"
#include <sstream>
#include <iostream>
#include <string>
#include <stdio.h>
#include "linnux_utils.h"
#include "basedef.h"
#include <vector>
extern "C" {
#include "transaction_to_packet.h"
#include <xprintf.h>
}


#define u(x) do { if (SPI_BRIDGE_UART_REG_DEBUG || UART_REG_DEBUG) {x;} } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if  (SPI_BRIDGE_UART_REG_DEBUG || UART_REG_DEBUG) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} } while (0)

spi_to_avalon_mm_bridge_virtual_uart::spi_to_avalon_mm_bridge_virtual_uart() :
		virtual_uart_register_file() {


	// TODO Auto-generated constructor stub

}

unsigned int spi_to_avalon_mm_bridge_virtual_uart::read_8_bits_from_mapped_space(unsigned int absolute_address){

	    unsigned int retval;
		unsigned char read_buffer[4];

		u(safe_print(printf("Reading data from spi mapped memory address %x ...\n\n", absolute_address))); fflush(NULL);
		transaction_channel_read  (absolute_address,
									1,
									&read_buffer[0],
									0,
									this->get_spi_base_addr());

		retval =  (read_buffer[0]);
		u(safe_print(printf("Reading data from spi mapped memory address %x, data = %x\n",absolute_address, retval))); fflush(NULL);
		return retval;
};

void spi_to_avalon_mm_bridge_virtual_uart::write_8_bits_to_mapped_space(unsigned int absolute_address, unsigned int data){
		unsigned char data_buffer[4];

		u(safe_print(printf("Reading data from spi mapped memory address %x, data = %x\n",absolute_address, data & 0xFF))); fflush(NULL);
		data_buffer[0] = data & 0xFF;

		if(transaction_channel_write (absolute_address,
										1,
										&data_buffer[0],
										0,
										this->get_spi_base_addr()))
		{
			u(safe_print(printf("Write transaction successful\n\n"))); fflush(NULL);
		} else {
			u(safe_print(printf("Write transaction not successful\n\n"))); fflush(NULL);
		}
};

unsigned int spi_to_avalon_mm_bridge_virtual_uart::read_32_bits_from_mapped_space(unsigned int absolute_address){

	    unsigned int retval;
		unsigned char read_buffer[4];

		u(safe_print(printf("Reading data from spi mapped memory address %x ...\n\n", absolute_address))); fflush(NULL);
		transaction_channel_read  (absolute_address,
									4,
									&read_buffer[0],
									1,
									this->get_spi_base_addr());

		retval = (read_buffer[3] << 24) + (read_buffer[2] << 16) + (read_buffer[1] << 8) +  (read_buffer[0]);
		u(safe_print(printf("Reading data from spi mapped memory address %x, data = %x\n",absolute_address, retval))); fflush(NULL);
		return retval;
};

void spi_to_avalon_mm_bridge_virtual_uart::write_32_bits_to_mapped_space(unsigned int absolute_address, unsigned int data){
		unsigned char data_buffer[4];

		u(safe_print(printf("Reading data from spi mapped memory address %x, data = %x\n",absolute_address, data))); fflush(NULL);
		data_buffer[0] = data & 0xFF;
		data_buffer[1] = (data & 0xFF00) >> 8;
		data_buffer[2] = (data & 0xFF0000) >> 16;
		data_buffer[3] = (data & 0xFF000000) >> 24;

		if(transaction_channel_write (absolute_address,
										4,
										&data_buffer[0],
										1,
										this->get_spi_base_addr()))
		{
			u(safe_print(printf("Write transaction successful\n\n"))); fflush(NULL);
		} else {
			u(safe_print(printf("Write transaction not successful\n\n"))); fflush(NULL);
		}
};


unsigned long long spi_to_avalon_mm_bridge_virtual_uart::read_control_reg(unsigned long address, unsigned long secondary_uart_address, int* errorptr)
{


    if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return 0;
	}
	return this->read_8_bits_from_mapped_space(this->address_defs.control_addr_min + address);

};

void spi_to_avalon_mm_bridge_virtual_uart::write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address, int* errorptr)
{


	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	this->write_8_bits_to_mapped_space(this->address_defs.control_addr_min + address,data);
};
