/*
 * board_mgmt_encapsulator.h
 *
 *  Created on: Sep 4, 2013
 *      Author: yairlinn
 */

#ifndef BOARD_MGMT_ENCAPSULATOR_H_
#define BOARD_MGMT_ENCAPSULATOR_H_
#include "uart_support/uart_encapsulator.h"
#include "uart_support/uart_register_file.h"
#include "uart_support/uart_vector_config_encapsulator.h"
#include "altera_pio_encapsulator.h"
#include "flow_through_fifo_encapsulator.h"
#include <fmc_present_encapsulator.h>
extern "C" {
#include <xprintf.h>
}
#include <stdio.h>

#include <stddef.h>
#include <string>
#include <iostream>
#include <sstream>
#include "linnux_utils.h"
#include <assert.h>

#include "jansson.hpp"
#include "json_serializer_class.h"

class board_mgmt_encapsulator{
protected:
	 uart_register_file *uart_ptr;
	 bool enabled;

public:
	 board_mgmt_encapsulator() {
			 uart_ptr = NULL;
			 enabled = false;
		 }
		void init(uart_register_file *the_uart_ptr){
			uart_ptr = the_uart_ptr;
			if (the_uart_ptr == NULL) {
				xprintf("[board_mgmt_encapsulator] Error: Null pointer passed to board_mgmt_encapsulator.init()\n");
				set_enabled(false);
			} else {
				set_enabled(true);
			}
		}
		bool is_enabled () { return (enabled); };
		std::string exec_board_mgmt_command(std::string the_command);
		std::string get_hardware_version();
		std::string get_software_version();
		std::string get_project_name();
		std::string get_name();
		std::string get_devices();
		std::string get_json_status_str();
		json::Value get_json_status_object();
		unsigned long get_num_attached_uarts_num();
		std::string get_num_attached_uarts();
		std::string write_spartan_hex(unsigned long addr, unsigned long numbytes, unsigned long fmc_num);
		std::string write_stratix_hex(unsigned long addr, unsigned long numbytes);
		std::string write_to_spartan_flash(unsigned long addr, unsigned long numbytes, unsigned long offset);
		std::string write_to_stratix_flash(unsigned long addr, unsigned long numbytes, unsigned long offset);
	virtual ~board_mgmt_encapsulator();

	void set_enabled(bool enabled) {
		this->enabled = enabled;
	}
};

#endif /* BOARD_MGMT_ENCAPSULATOR_H_ */
