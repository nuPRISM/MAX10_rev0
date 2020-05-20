/*
 * board_mgmt_encapsulator.cpp
 *
 *  Created on: Sep 4, 2013
 *      Author: yairlinn
 */

#include "board_mgmt_encapsulator.h"
#include "basedef.h"
#if SUPPORT_BOARD_MANAGEMENT_UART
#include "board_management.h"
extern tBoard g_board;
#endif



board_mgmt_encapsulator::~board_mgmt_encapsulator() {
	// TODO Auto-generated destructor stub
}

#include "board_mgmt_encapsulator.h"

#define check_if_board_mgmt_present_return_if_not() do { \
                                      if (!uart_ptr) { \
                                          std::ostringstream ostr; \
                                          ostr << "Error! board_mgmt_encapsulator " << " UART PTR is null; FILE: " << __FILE__ << " Line: " << __LINE__ << " Function: " << __func__ << std::endl; \
                                          return ostr.str(); \
                                      }; \
                                } while (0)


#define check_if_board_mgmt_present_return_if_not_return_json_undefined() do { \
                                      if (!uart_ptr) { \
                                          std::ostringstream ostr; \
                                          ostr << "Error! board_mgmt_encapsulator " << " UART PTR is null; FILE: " << __FILE__ << " Line: " << __LINE__ << " Function: " << __func__ << std::endl; \
                                          std::cout << ostr.str(); \
                                          return json_rabbit_string(std::string("{ \"Undefined\" : \"Undefined\" }"));\
                                      }; \
                                } while (0)

std::string board_mgmt_encapsulator::exec_board_mgmt_command(std::string the_command) {
	check_if_board_mgmt_present_return_if_not();
	return uart_ptr->exec_internal_command(the_command);
}

std::string board_mgmt_encapsulator::get_hardware_version(){
	return exec_board_mgmt_command("version");
}

std::string board_mgmt_encapsulator::get_software_version(){
	return exec_board_mgmt_command("sw_date");
}

std::string board_mgmt_encapsulator::get_project_name(){
	return exec_board_mgmt_command("project_name");
}

std::string board_mgmt_encapsulator::get_name() {
	return exec_board_mgmt_command("fmc_name");
}


std::string board_mgmt_encapsulator::get_devices(){
	check_if_board_mgmt_present_return_if_not();
	return exec_board_mgmt_command("get_devices");
}

std::string board_mgmt_encapsulator::get_json_status_str() {
	 if (!uart_ptr) {
	     std::ostringstream ostr;
	     safe_print(std::cout << "Error! board_mgmt_encapsulator " << " UART PTR is null; FILE: " << __FILE__ << " Line: " << __LINE__ << " Function: " << __func__ << std::endl);
	     return std::string("{ \"Undefined\" : \"Undefined\"}" );
	 };

	return exec_board_mgmt_command("get_json_status");
}

json::Value board_mgmt_encapsulator::get_json_status_object() {
	//std::string json_str = get_json_status_str();
	//json::Value jo = json::load_string(json_str.c_str());
	//return jo;
#if SUPPORT_BOARD_MANAGEMENT_UART

	return g_board.get_json_object();
#else
	json::Value jo(json::object());
	return jo;
#endif

}


unsigned long board_mgmt_encapsulator::get_num_attached_uarts_num(){
	std::string num_uarts_str = exec_board_mgmt_command("num_uarts");
	return conv_dec_string_to_unsigned_long(num_uarts_str);
}

std::string board_mgmt_encapsulator::get_num_attached_uarts(){
	return exec_board_mgmt_command("num_uarts");
}

std::string board_mgmt_encapsulator::write_spartan_hex(unsigned long addr, unsigned long numbytes, unsigned long fmc_num){
	std::ostringstream command_str;
	command_str << "program_spartan_hex " << std::hex << addr << " " << numbytes << " " << fmc_num << std::dec;
	return exec_board_mgmt_command(command_str.str());
}


std::string board_mgmt_encapsulator::write_to_spartan_flash(unsigned long addr, unsigned long numbytes, unsigned long offset){
	std::ostringstream command_str;
	command_str << "write_to_spartan_flash " << std::hex << addr << " " << numbytes << " " << offset << std::dec;
	return exec_board_mgmt_command(command_str.str());
}

std::string board_mgmt_encapsulator::write_stratix_hex(unsigned long addr, unsigned long numbytes){
	std::ostringstream command_str;
	command_str << "program_stratix_hex " << std::hex << addr << " " << numbytes << std::dec;
	return exec_board_mgmt_command(command_str.str());
}
std::string board_mgmt_encapsulator::write_to_stratix_flash(unsigned long addr, unsigned long numbytes, unsigned long offset){
	std::ostringstream command_str;
	command_str << "write_to_stratix_flash " << std::hex << addr << " " << numbytes << " " << offset << std::dec;
	return exec_board_mgmt_command(command_str.str());
}
