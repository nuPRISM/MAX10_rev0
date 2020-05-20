/*
 * virtual_uart_register_file.h
 *
 *  Created on: Jan 27, 2014
 *      Author: yairlinn
 */

#ifndef VIRTUAL_UART_REGISTER_FILE_H_
#define VIRTUAL_UART_REGISTER_FILE_H_

#include "uart_register_file.h"
#include <string>
#include <iostream>

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <map>
#include <utility>

class virtual_uart_register_file_address_defs {
public:
unsigned long control_addr_min;
unsigned long control_addr_max;
unsigned long status_addr_min;
unsigned long status_addr_max;
	virtual_uart_register_file_address_defs() {
	 control_addr_min = 0;
	 control_addr_max = 0;
	 status_addr_min = 0;
	 status_addr_max = 0;
	}
};

class virtual_uart_register_file: public uart_register_file {
protected:
	virtual_uart_register_file_address_defs address_defs;
	register_desc_map_type  control_reg_map_desc;
	register_desc_map_type status_reg_map_desc;
public:
	virtual_uart_register_file();

	virtual unsigned long read_from_virtual_jtag_addr(unsigned long base_address, unsigned long offset_in_words);
	virtual void write_to_virtual_jtag_addr(unsigned long base_address, unsigned long offset_in_words, unsigned long data);
	virtual void set_params(uart_register_file_info_struct the_params);
	virtual void set_address_defs(virtual_uart_register_file_address_defs the_address_defs) { this->address_defs =  the_address_defs;};
	virtual std::string get_control_desc(unsigned long address,  unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual std::string get_status_desc(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual void write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual std::string exec_internal_command(std::string the_command, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual std::string exec_internal_command_get_ascii_response(std::string the_command, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual unsigned long long read_status_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual std::string get_params_str(unsigned long secondary_uart_address = 0);
	virtual void basic_setup_as_memory_mapped_device_driver(std::string name, std::string device_name, unsigned long start_addr, unsigned long span_in_words, unsigned long user_type,map_of_str_to_uint_type* uart_map_of_display_name_to_secondary_address = NULL);
	virtual void setup_as_memory_mapped_device_driver_w_both_control_and_status(std::string name, std::string device_name,
			unsigned long ctrl_start_addr,
			unsigned long ctrl_span_in_words,
			unsigned long status_start_addr,
			unsigned long status_span_in_words,
			unsigned long user_type,
			map_of_str_to_uint_type* uart_map_of_display_name_to_secondary_address = NULL);
	virtual void init_params(map_of_str_to_uint_type* uart_map_of_display_name_to_secondary_address = NULL);

	virtual register_desc_map_type get_control_reg_map_desc() const {
		return control_reg_map_desc;
	}

	virtual void set_control_reg_map_desc(register_desc_map_type controlRegMapDesc) {
		control_reg_map_desc = controlRegMapDesc;
	}

	register_desc_map_type get_status_reg_map_desc() const {
		return status_reg_map_desc;
	}

	void set_status_reg_map_desc(register_desc_map_type statusRegMapDesc) {
		status_reg_map_desc = statusRegMapDesc;
	}
;
};

#endif /* VIRTUAL_UART_REGISTER_FILE_H_ */
