/*
 * virtual_uart_register_file.cpp
 *
 *  Created on: Jan 27, 2014
 *      Author: yairlinn
 */

#include "virtual_uart_register_file.h"
#include <sstream>
#include <iostream>
#include <string>
#include <stdio.h>
#include "linnux_utils.h"
#include "basedef.h"
#include <vector>
extern "C" {
#include <xprintf.h>
}

virtual_uart_register_file::virtual_uart_register_file() : uart_register_file() {
	// TODO Auto-generated constructor stub
}


#define u(x) do { if (UART_REG_DEBUG) {x;} } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if (UART_REG_DEBUG) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} } while (0)


void virtual_uart_register_file::set_params(uart_register_file_info_struct the_params) {
	this->regfile_params.resize(1);
	regfile_params.at(0) = the_params;
}

unsigned long virtual_uart_register_file::read_from_virtual_jtag_addr(unsigned long base_address, unsigned long offset_in_words){
	return IORD_32DIRECT(base_address,(offset_in_words << 2));
};

void virtual_uart_register_file::write_to_virtual_jtag_addr(unsigned long base_address, unsigned long offset_in_words, unsigned long data){
	IOWR_32DIRECT(base_address,(offset_in_words << 2),data);
};

std::string virtual_uart_register_file::get_control_desc(unsigned long address,  unsigned long secondary_uart_address, int* errorptr)
{
	if (this->control_reg_map_desc.find(address) != control_reg_map_desc.end()) {
		return control_reg_map_desc[address];
	} else {
	    return "";
	}
};

std::string virtual_uart_register_file::get_status_desc(unsigned long address, unsigned long secondary_uart_address, int* errorptr)
{

		if (this->status_reg_map_desc.find(address) != status_reg_map_desc.end()) {
			return status_reg_map_desc[address];
		} else {
		    return "";
		}
};

unsigned long long virtual_uart_register_file::read_control_reg(unsigned long address, unsigned long secondary_uart_address, int* errorptr)
{


    if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return 0;
	}
	return this->read_from_virtual_jtag_addr(this->address_defs.control_addr_min,address);

};

void virtual_uart_register_file::write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address, int* errorptr)
{


	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	this->write_to_virtual_jtag_addr(this->address_defs.control_addr_min,address,data);
};

std::string virtual_uart_register_file::exec_internal_command(std::string the_command, unsigned long secondary_uart_address, int* errorptr)
{

	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return "";
	}
	return "";
};
std::string virtual_uart_register_file::exec_internal_command_get_ascii_response(std::string the_command, unsigned long secondary_uart_address, int* errorptr)
{
	return "";
};

unsigned long long virtual_uart_register_file::read_status_reg(unsigned long address, unsigned long secondary_uart_address, int* errorptr){

	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return 0xEAA;
	}
	unsigned long long result;
	result = this->read_from_virtual_jtag_addr(this->address_defs.status_addr_min,address);
	return result;
};

std::string virtual_uart_register_file::get_params_str(unsigned long secondary_uart_address){
	std::ostringstream retstr;

	if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return "";
	}

	retstr << uart_register_file::get_params_str()
	       << " CONTROL_ADDR_MIN " << this->address_defs.control_addr_min
			<< " CONTROL_ADDR_MAX " << this->address_defs.control_addr_max
			<< " STATUS_ADDR_MIN " << this->address_defs.status_addr_min
			<< " STATUS_ADDR_MAX " << this->address_defs.status_addr_max;

	return retstr.str();
};

void virtual_uart_register_file::init_params(map_of_str_to_uint_type* uart_map_of_display_name_to_secondary_address) {

	this_has_been_initialized = true;

	if (uart_map_of_display_name_to_secondary_address != NULL) {
		(*uart_map_of_display_name_to_secondary_address)[this->get_display_name()] = 0;
	}

	u(safe_print(std::cout << get_params_str() << "\n" ));
}

void virtual_uart_register_file::basic_setup_as_memory_mapped_device_driver(std::string name,
		std::string device_name,
		unsigned long start_addr,
		unsigned long span_in_words,
		unsigned long user_type,
		map_of_str_to_uint_type* uart_map_of_display_name_to_secondary_address
		) {
	    uart_register_file_info_struct                device_driver_virtual_uart_params;
	    virtual_uart_register_file_address_defs       device_driver_virtual_uart_addr_defs;

	    device_driver_virtual_uart_params.ADDRESS_OF_THIS_UART = 0;
	    device_driver_virtual_uart_params.ADDRESS_WIDTH = 16;
	    device_driver_virtual_uart_params.CLOCK_RATE_IN_HZ = 50000000; //dummy
	    device_driver_virtual_uart_params.DATA_WIDTH = 32;
	    device_driver_virtual_uart_params.DISPLAY_NAME = name;
	    device_driver_virtual_uart_params.INIT_ALL_CONTROL_REGS_TO_DEFAULT = 0;
	    device_driver_virtual_uart_params.IS_ACTUALLY_PRESENT = 1;
	    device_driver_virtual_uart_params.IS_SECONDARY_UART = 0;
	    device_driver_virtual_uart_params.NUM_OF_CONTROL_REGS = span_in_words;
	    device_driver_virtual_uart_params.NUM_OF_STATUS_REGS = 0;
	    device_driver_virtual_uart_params.NUM_SECONDARY_UARTS = 0;
	    device_driver_virtual_uart_params.USER_TYPE = user_type;
	    device_driver_virtual_uart_params.VERSION = 3;
	    device_driver_virtual_uart_addr_defs.control_addr_min= start_addr;
	    device_driver_virtual_uart_addr_defs.control_addr_max = device_driver_virtual_uart_addr_defs.control_addr_min + (device_driver_virtual_uart_params.NUM_OF_CONTROL_REGS << 2);
	    device_driver_virtual_uart_addr_defs.status_addr_min = 0;
	    device_driver_virtual_uart_addr_defs.status_addr_max = 0;
	    set_device_name(device_name);
	    set_params(device_driver_virtual_uart_params);
	    set_address_defs(device_driver_virtual_uart_addr_defs);
	    init_params(uart_map_of_display_name_to_secondary_address);

}


void virtual_uart_register_file::setup_as_memory_mapped_device_driver_w_both_control_and_status(std::string name, std::string device_name,
		unsigned long ctrl_start_addr,
		unsigned long ctrl_span_in_words,
		unsigned long status_start_addr,
		unsigned long status_span_in_words,
		unsigned long user_type,
		map_of_str_to_uint_type* uart_map_of_display_name_to_secondary_address
		) {
	    uart_register_file_info_struct                device_driver_virtual_uart_params;
	    virtual_uart_register_file_address_defs       device_driver_virtual_uart_addr_defs;

	    device_driver_virtual_uart_params.ADDRESS_OF_THIS_UART = 0;
	    device_driver_virtual_uart_params.ADDRESS_WIDTH = 16;
	    device_driver_virtual_uart_params.CLOCK_RATE_IN_HZ = 50000000; //dummy
	    device_driver_virtual_uart_params.DATA_WIDTH = 32;
	    device_driver_virtual_uart_params.DISPLAY_NAME = name;
	    device_driver_virtual_uart_params.INIT_ALL_CONTROL_REGS_TO_DEFAULT = 0;
	    device_driver_virtual_uart_params.IS_ACTUALLY_PRESENT = 1;
	    device_driver_virtual_uart_params.IS_SECONDARY_UART = 0;
	    device_driver_virtual_uart_params.NUM_OF_CONTROL_REGS = ctrl_span_in_words;
	    device_driver_virtual_uart_params.NUM_OF_STATUS_REGS  = status_span_in_words;
	    device_driver_virtual_uart_params.NUM_SECONDARY_UARTS = 0;
	    device_driver_virtual_uart_params.USER_TYPE = user_type;
	    device_driver_virtual_uart_params.VERSION = 3;
	    device_driver_virtual_uart_addr_defs.control_addr_min= ctrl_start_addr;
	    device_driver_virtual_uart_addr_defs.control_addr_max = device_driver_virtual_uart_addr_defs.control_addr_min + (device_driver_virtual_uart_params.NUM_OF_CONTROL_REGS << 2);
	    device_driver_virtual_uart_addr_defs.status_addr_min = status_start_addr;
	    device_driver_virtual_uart_addr_defs.status_addr_max = device_driver_virtual_uart_addr_defs.status_addr_min + (device_driver_virtual_uart_params.NUM_OF_STATUS_REGS << 2);;
	    set_device_name(device_name);
	    set_params(device_driver_virtual_uart_params);
	    set_address_defs(device_driver_virtual_uart_addr_defs);
	    init_params(uart_map_of_display_name_to_secondary_address);

}
