/*
 * register_status_encapsulator.cpp
 *
 *  Created on: May 27, 2011
 *      Author: linnyair
 */

#include "register_status_encapsulator.h"
using namespace std;

register_status_encapsulator::~register_status_encapsulator()
{
	// TODO Auto-generated destructor stub
}

string register_status_encapsulator::get_register_status_dump()
{
	ostringstream output_str_vec;
	char str[256];
	output_str_vec << "\n===============\n";
	output_str_vec << "Register Values\n";
	output_str_vec << "===============\n";
	for (unsigned long i = 0; i < num_of_control_registers; i++)
	{
		sprintf(str,"%.3lX",i);
		output_str_vec << "Control[" << str << "] = 0x" << hex << read_value_from_reg_keeper_reg(first_address+i) << dec << endl;
	}

	output_str_vec << "------\n";
	for (unsigned long i = 0; i < num_of_testbench_status_registers; i++)
		{
			sprintf(str,"%.3lX",i);
			output_str_vec << "Testbench_Status[" << str << "] = 0x" << hex << read_value_from_reg_keeper_reg(first_address+testbench_description_first_reg_offset+i) << dec << endl;
		}


	output_str_vec << "------\n";
	for (unsigned long i = 0; i < num_of_dut_gp_control_registers; i++)
		{
			sprintf(str,"%.3lX",i);
			output_str_vec << "DUT_GP_CONTROL[" << str << "] = 0x" << hex << read_value_from_reg_keeper_reg(first_address+dut_gp_control_first_reg_offset+i) << dec << endl;
		}


	output_str_vec << "------\n";
	for (unsigned long i = 0; i < num_of_dut_gp_status_registers; i++)
		{
			sprintf(str,"%.3lX",i);
			output_str_vec << "DUT_GP_STATUS[" << str << "] =  0x" << hex << read_value_from_reg_keeper_reg(first_address+dut_gp_status_first_reg_offset+i) << dec << endl;
		}
	output_str_vec << "===============\n";
	return (output_str_vec.str());

}

