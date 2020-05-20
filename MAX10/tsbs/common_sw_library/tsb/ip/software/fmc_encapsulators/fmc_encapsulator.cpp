/*
 * fmc_encapsulator.cpp
 *
 *  Created on: Sep 3, 2013
 *      Author: yairlinn
 */

#include "fmc_encapsulator.h"

#define check_if_fmc_present_return_if_not() do { if (!(fmc_present_ptr->is_enabled(fmc_num))) { \
                                          std::ostringstream ostr; \
                                          ostr << "Error! FMC " << fmc_num << " Not Present! at  File: " << __FILE__ << " Line: " << __LINE__ << " Function: " << __func__ << std::endl; \
                                          return ostr.str(); \
                                      }; \
                                      if (!uart_ptr) { \
                                          std::ostringstream ostr; \
                                          ostr << "Error! fmc_encapsulator for FMC " << fmc_num << " UART PTR is null; FILE: " << __FILE__ << " Line: " << __LINE__ << " Function: " << __func__ << std::endl; \
                                          return ostr.str(); \
                                      }; \
                                } while (0)



fmc_encapsulator::~fmc_encapsulator() {
	// TODO Auto-generated destructor stub
}

std::string fmc_encapsulator::exec_fmc_command(std::string the_command) {
	check_if_fmc_present_return_if_not();
	return uart_ptr->exec_internal_command(the_command);
}

std::string fmc_encapsulator::get_hardware_version(){
	return exec_fmc_command("version");
}


std::string fmc_encapsulator::get_software_version(){
	return exec_fmc_command("sw_date");
}

std::string fmc_encapsulator::get_project_name(){
	return exec_fmc_command("project_name");
}

std::string fmc_encapsulator::get_fmc_name() {
	return exec_fmc_command("fmc_name");
}

unsigned long fmc_encapsulator::get_desired_fmc_num() {
	std::string desired_fmc_str = exec_fmc_command("desired_fmc");
	return conv_dec_string_to_unsigned_long(desired_fmc_str);
}

unsigned long fmc_encapsulator::get_actual_fmc_num() {
	std::string actual_fmc_str = exec_fmc_command("actual_fmc");
	return conv_dec_string_to_unsigned_long(actual_fmc_str);
}

std::string fmc_encapsulator::get_devices(){
	check_if_fmc_present_return_if_not();
	return exec_fmc_command("get_devices");
}

unsigned long fmc_encapsulator::get_num_attached_uarts_num(){
	std::string dnum_uarts_str = exec_fmc_command("num_uarts");
	return conv_dec_string_to_unsigned_long(dnum_uarts_str);
}

std::string fmc_encapsulator::get_desired_fmc() {
	return exec_fmc_command("desired_fmc");
}

std::string fmc_encapsulator::get_actual_fmc() {
	return exec_fmc_command("actual_fmc");
}


std::string fmc_encapsulator::get_num_attached_uarts(){
	return exec_fmc_command("num_uarts");
}
