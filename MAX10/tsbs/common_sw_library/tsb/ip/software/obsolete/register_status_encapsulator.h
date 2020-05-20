/*
 * register_status_encapsulator.h
 *
 *  Created on: May 27, 2011
 *      Author: linnyair
 */

#ifndef REGISTER_STATUS_ENCAPSULATOR_H_
#define REGISTER_STATUS_ENCAPSULATOR_H_
#include "register_keeper_api.h"
#include "chan_fatfs/terasic_linnux_driver.h"
#include "linnux_testbench_constants.h"
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
#include <string>
#include <sstream>
#include <iosfwd>
#include <map>
#include <float.h>
#include <vector>
#include <unistd.h>
#include <time.h>

class register_status_encapsulator {
	protected:
		           unsigned long first_address;
				   unsigned long testbench_description_first_reg_offset;
				   unsigned long dut_gp_control_first_reg_offset;
				   unsigned long dut_gp_status_first_reg_offset;
		           unsigned long num_of_testbench_status_registers;
		           unsigned long num_of_control_registers;
		           unsigned long num_of_dut_gp_status_registers;
		           unsigned long num_of_dut_gp_control_registers;
	public:
		std::string get_register_status_dump();
		register_status_encapsulator(
		   unsigned long first_address_val,
		   unsigned long testbench_description_first_reg_offset_val,
		   unsigned long dut_gp_control_first_reg_offset_val,
		   unsigned long dut_gp_status_first_reg_offset_val,
           unsigned long num_of_testbench_status_registers_val,
           unsigned long num_of_control_registers_val,
           unsigned long num_of_dut_gp_status_registers_val,
           unsigned long num_of_dut_gp_control_registers_val
         )
		{
		first_address = first_address_val;
		testbench_description_first_reg_offset = testbench_description_first_reg_offset_val;
		dut_gp_control_first_reg_offset = dut_gp_control_first_reg_offset_val;
		dut_gp_status_first_reg_offset = dut_gp_status_first_reg_offset_val;
		num_of_testbench_status_registers = num_of_testbench_status_registers_val;
		num_of_control_registers = num_of_control_registers_val;
		num_of_dut_gp_status_registers = num_of_dut_gp_status_registers_val;
		num_of_dut_gp_control_registers = num_of_dut_gp_control_registers_val;
		}
		virtual ~register_status_encapsulator();
};

#endif /* REGISTER_STATUS_ENCAPSULATOR_H_ */
