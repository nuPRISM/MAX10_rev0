/*
 * fmc_encapsulator.h
 *
 *  Created on: Sep 3, 2013
 *      Author: yairlinn
 */

#ifndef FMC_ENCAPSULATOR_H_
#define FMC_ENCAPSULATOR_H_
#include "uart_support/uart_encapsulator.h"
#include "uart_support/uart_register_file.h"
#include "uart_support/uart_vector_config_encapsulator.h"
#include "altera_pio_encapsulator.h"
#include "flow_through_fifo_encapsulator.h"
#include "fmc_present_encapsulator.h"

#include <stdio.h>

#include <stddef.h>
#include <string>
#include <iostream>
#include <sstream>
#include "linnux_utils.h"
#include <assert.h>

class fmc_encapsulator {
protected:
	 unsigned long fmc_num;
	 uart_register_file *uart_ptr;
	 fmc_present_encapsulator *fmc_present_ptr;

public:
	 fmc_encapsulator() {
		 uart_ptr = NULL;
		 fmc_present_ptr = NULL;
	 }
	void init(unsigned long the_fmc_num,uart_register_file *the_uart_ptr, fmc_present_encapsulator *the_fmc_present_ptr){
		assert (the_uart_ptr != 0);
		assert (the_fmc_present_ptr != 0);
		uart_ptr = the_uart_ptr;
		fmc_present_ptr = the_fmc_present_ptr;
		fmc_num = the_fmc_num;
	}
	std::string exec_fmc_command(std::string the_command);
	std::string get_hardware_version();
	std::string get_software_version();
	std::string get_project_name();
	std::string get_fmc_name();
	std::string get_devices();
	unsigned long get_num_attached_uarts_num();
	unsigned long get_desired_fmc_num();
	unsigned long get_actual_fmc_num();
	std::string get_num_attached_uarts();
	std::string get_desired_fmc();
	std::string get_actual_fmc();
	virtual ~fmc_encapsulator();
};

#endif /* FMC_ENCAPSULATOR_H_ */
