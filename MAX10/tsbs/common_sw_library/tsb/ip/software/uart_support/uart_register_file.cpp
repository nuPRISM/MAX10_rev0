/*
 * uart_register_file.cpp
 *
 *  Created on: Apr 8, 2013
 *      Author: yairlinn
 */

#include "uart_register_file.h"
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

#define u(x) do { if (UART_REG_DEBUG) {x; fflush(NULL); std::cout.flush();}} while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); fflush(NULL);std::cout.flush();} while (0)
#define debureg(x)  do { if (UART_REG_DEBUG) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} fflush(NULL);std::cout.flush();} while (0)

void uart_register_file::set_last_error(unsigned int error_number, unsigned int secondary_uart_address) {
	this->last_error.set_error(error_number);
	this->last_error.set_secondary_uart_index(secondary_uart_address);
}


unsigned long long uart_register_file::get_uart_unsigned_long_long_response(unsigned long secondary_uart_address, int* errorptr)
{
	//this->set_timeout(get_secondary_uart_timeout_in_ticks(secondary_uart_address));
	std::string uart_result = getstr(max_response_length, errorptr);
	unsigned long long result = conv_hex_string_to_unsigned_long_long(uart_result);
	return result;
}

std::string uart_register_file::get_uart_string_response(unsigned long secondary_uart_address, int* errorptr)
{
	//this->set_timeout(get_secondary_uart_timeout_in_ticks(secondary_uart_address));
	std::string uart_result = TrimSpacesFromString(getstr(max_response_length,errorptr));
	return uart_result;
}

uart_user_types uart_register_file::get_user_type(unsigned long secondary_uart_address) {
	if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return 0;
		}

	 return this->regfile_params[secondary_uart_address].USER_TYPE;
}

std::string uart_register_file::get_uart_status_or_control_description_ascii_response(unsigned long secondary_uart_address, int* errorptr)
{
	std::string actual_result;
	std::string result = get_uart_string_response(secondary_uart_address,errorptr);
	size_t first_noneof = result.find_first_not_of("0\n\r");
	u(safe_print(std::cout << " end number: " << first_noneof << "result length: " << result.length() << " comparison: " << (first_noneof >= result.length()) <<std::endl;));
	if (first_noneof >= result.length())
	{
		//all zeros
		actual_result = "";
		u(safe_print(std::cout << " All zero's fix, actual_result = " << actual_result << std::endl;));
	} else {
		actual_result = TrimSpacesFromString(conv_hex_string_to_safe_ascii(result));
		u(safe_print(std::cout << " No all zero's fix, actual_result = " << actual_result << std::endl;));
	}
	u(safe_print(std::cout<< "Result of UART read is: " << result << " result length: " << result.length() << " which is string: " << actual_result << std::endl;));
	return actual_result;
}

void uart_register_file::write_series_of_control_words(register_address_value_pairs_type register_address_value_pairs_in_order,  unsigned long secondary_uart_address, int* errorptr) {
     for (unsigned int i=0; i < register_address_value_pairs_in_order.size(); i++) {
		 this->write_control_reg(register_address_value_pairs_in_order.at(i).first,register_address_value_pairs_in_order.at(i).second, secondary_uart_address, errorptr);
	  }
}

register_address_value_pairs_type uart_register_file::convert_string_to_register_address_value_pairs_in_order(std::string the_string, bool use_hex_notation) {
	return convert_string_to_vector_of_pairs<unsigned long, unsigned long long>(the_string," \t\n\r",use_hex_notation);
}

void uart_register_file::write_str_series_of_control_words(std::string the_string,  bool use_hex_notation, unsigned long secondary_uart_address, int* errorptr) {
         this->write_series_of_control_words(convert_string_to_register_address_value_pairs_in_order(the_string,use_hex_notation),secondary_uart_address,errorptr);
}
std::string uart_register_file::get_control_desc(unsigned long address,  unsigned long secondary_uart_address, int* errorptr)
{
	int local_error = 0;
	std::ostringstream str_to_uart;
	std::string actual_result;

	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return "";
	}

	if ((special_uart_maps == NULL) || (special_uart_maps->count(this->get_user_type(secondary_uart_address)) == 0))
     {
		lock();
		u(safe_print(std::cout << "uart_register_file::get_control_desc: " << device_name << " secondary uart:" << secondary_uart_address <<  std::hex << " address: 0x" << address << std::dec<< std::endl;));

		if (secondary_uart_address == 0) {
		    str_to_uart << "N " << std::hex << address;
		} else {
			str_to_uart << "U " << std::hex << secondary_uart_address << " N " << address;
		}
#if CHECK_UART_REGFILE_ERROR_AND_RETRY
	int max_trys = 0;
	do {
	local_error = 0;
#endif
		writestr(str_to_uart.str());
		actual_result=get_uart_status_or_control_description_ascii_response(secondary_uart_address,&local_error);
#if CHECK_UART_REGFILE_ERROR_AND_RETRY
	if (local_error != 0) {
		safe_print(std::cout << "uart_register_file::get_control_desc: " << device_name << " secondary uart:" << secondary_uart_address <<  std::hex << " address: 0x" << address << std::dec<< "Error encountered: " << local_error << std::endl;);
		writestr(""); //get uart regfile to idle state
		max_trys++;
	}
	} while ((local_error != 0) && (max_trys < MAX_TRYS_FOR_UART_REGFILE_RETRY));
#endif
		unlock();

     } else {
    	 if (special_uart_maps->find(this->get_user_type(secondary_uart_address))->second.get_ctrl_descs().count(address) == 0) {
    		 return "";
    	 } else {
    	     return special_uart_maps->find(this->get_user_type(secondary_uart_address))->second.get_ctrl_descs().find(address)->second;
    	 }
     }

	if (local_error != 0) {
		this->set_last_error(local_error,secondary_uart_address);
	}

	if (errorptr) {
		*errorptr = local_error;
	}
	return actual_result;
};

std::string uart_register_file::get_status_desc(unsigned long address, unsigned long secondary_uart_address, int* errorptr)
{
    int local_error = 0;
	std::ostringstream str_to_uart;
	std::string actual_result;


	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return "";
	}

	if ((special_uart_maps == NULL) || (special_uart_maps->count(this->get_user_type(secondary_uart_address)) == 0))
	     {
		lock();
		u(safe_print(std::cout << "uart_register_file::get_status_desc: " << device_name << " secondary uart:" << secondary_uart_address <<  std::hex << " address: 0x" << address << std::dec<< std::endl;));
		if (secondary_uart_address == 0) {
		     str_to_uart << "M " << std::hex << address;
		} else {
			str_to_uart << "U " << std::hex << secondary_uart_address << " M " << address;
		}
#if CHECK_UART_REGFILE_ERROR_AND_RETRY
	int max_trys = 0;
	do {
	local_error = 0;
#endif
		writestr(str_to_uart.str());
		actual_result=get_uart_status_or_control_description_ascii_response(secondary_uart_address,&local_error);
#if CHECK_UART_REGFILE_ERROR_AND_RETRY
	if (local_error != 0) {
		safe_print(std::cout << "uart_register_file::get_status_desc: " << device_name << " secondary uart:" << secondary_uart_address <<  std::hex << " address: 0x" << address << std::dec<< "Error encountered: " << local_error << std::endl;);
		writestr(""); //get uart regfile to idle state
		max_trys++;
	}
	} while ((local_error != 0) && (max_trys < MAX_TRYS_FOR_UART_REGFILE_RETRY));
#endif
		unlock();

	} else {
	        	 if (special_uart_maps->find(this->get_user_type(secondary_uart_address))->second.get_status_descs().count(address) == 0) {
	        		 return "";
	        	 } else {
	        	     return special_uart_maps->find(this->get_user_type(secondary_uart_address))->second.get_status_descs().find(address)->second;
	        	 }
	}

	if (local_error != 0) {
		this->set_last_error(local_error,secondary_uart_address);
	}

	if (errorptr) {
				*errorptr = local_error;
	}
	return actual_result;
};

unsigned long long uart_register_file::read_control_reg(unsigned long address, unsigned long secondary_uart_address, int* errorptr)
{

	int local_error=0;
	unsigned long long result;

	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return 0;
	}

	lock();
	std::ostringstream str_to_uart;
	u(safe_print(std::cout << "uart_register_file::read_control_reg: " << device_name << " secondary uart:" << secondary_uart_address <<  std::hex << " address: 0x" << address << std::dec<< std::endl;));
	if (secondary_uart_address == 0) {
	    str_to_uart << "R " << std::hex << address;
	} else {
		str_to_uart << "U " << std::hex << secondary_uart_address << " R " << address;
	}

#if CHECK_UART_REGFILE_ERROR_AND_RETRY
	int max_trys = 0;
	do {
	local_error = 0;
#endif
	writestr(str_to_uart.str());
	result = get_uart_unsigned_long_long_response(secondary_uart_address,&local_error);
#if CHECK_UART_REGFILE_ERROR_AND_RETRY
	if (local_error != 0) {
		safe_print(std::cout << "uart_register_file::read_control_reg: " << device_name << " secondary uart:" << secondary_uart_address <<  std::hex << " address: 0x" << address << std::dec<< "Error encountered: " << local_error << std::endl;);
		writestr(""); //get uart regfile to idle state
		max_trys++;
	}
	} while ((local_error != 0) && (max_trys < MAX_TRYS_FOR_UART_REGFILE_RETRY));
#endif
	u(safe_print(std::cout<< "Result of UART read is: " << std::hex << result << std::dec << " which is the decimal number: " << result << std::endl;));
	unlock();

	if (local_error != 0) {
		this->set_last_error(local_error,secondary_uart_address);
	}

	if (errorptr) {
		*errorptr = local_error;
	}
	return result;
};

void uart_register_file::write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address, int* errorptr)
{
	int local_error=0;


	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	lock();
	std::ostringstream str_to_uart;
	u(safe_print(std::cout << "uart_register_file::write_control_reg device: " << device_name << " secondary uart:" << secondary_uart_address << std::hex << " address: 0x" << address << " data: 0x" << data << std::dec<< std::endl;));
	if (secondary_uart_address == 0) {
	     str_to_uart << "W" << " " << std::hex << data << " " << address;
	} else {
		str_to_uart << "U " << std::hex << secondary_uart_address << " W" << " " << data << " " << address;
	}
	u(safe_print(std::cout << "Writing string: [" << str_to_uart.str() << "]\n";));
#if CHECK_UART_REGFILE_ERROR_AND_RETRY
	int max_trys = 0;
	do {
	local_error = 0;
#endif
	writestr(str_to_uart.str());
	getstr(max_response_length,&local_error); //get dummy CR/LF that is sent back when write operation is complete
#if CHECK_UART_REGFILE_ERROR_AND_RETRY
	if (local_error != 0) {
		safe_print(std::cout << "uart_register_file::write_control_reg: " << device_name << " secondary uart:" << secondary_uart_address <<  std::hex << " address: 0x" << address << std::dec<< "Error encountered: " << local_error << std::endl;);
		writestr(""); //get uart regfile to idle state
		max_trys++;
	}
	} while ((local_error != 0) && (max_trys < MAX_TRYS_FOR_UART_REGFILE_RETRY));
#endif

	if (local_error != 0) {
		this->set_last_error(local_error,secondary_uart_address);
	}

	if (errorptr) {
			*errorptr = local_error;
	}
	unlock();
};


unsigned long uart_register_file::get_control_bit(unsigned the_reg_num, unsigned long bit, unsigned long secondary_uart_address = 0, int* errorptr = NULL){
	unsigned long long  val;
	val = this->read_control_reg(the_reg_num,secondary_uart_address,errorptr);
	return ((val & (((unsigned long long)1) << ((unsigned long long) bit))) != 0);
}

unsigned long uart_register_file::get_status_bit(unsigned the_reg_num, unsigned long bit, unsigned long secondary_uart_address = 0, int* errorptr = NULL){
	unsigned long long  val;
	val = this->read_status_reg(the_reg_num,secondary_uart_address,errorptr);
	return ((val & (((unsigned long long)1) << ((unsigned long long) bit))) != 0);
}

void uart_register_file::set_bit(unsigned the_reg_num, unsigned long bit, unsigned int val, unsigned long secondary_uart_address = 0, int* errorptr = NULL) {
	if (val) {
	        this->turn_on_bit(the_reg_num,bit,secondary_uart_address,errorptr);
		} else {
			this->turn_off_bit(the_reg_num,bit,secondary_uart_address,errorptr);
		}
}
void uart_register_file::turn_on_bit(unsigned the_reg_num, unsigned long bit, unsigned long secondary_uart_address = 0, int* errorptr = NULL) {
	unsigned long long  val;
	val = this->read_control_reg(the_reg_num,secondary_uart_address,errorptr);
	val = val | (((unsigned long long)1) <<  ((unsigned long long) bit));
	this->write_control_reg(the_reg_num,val,secondary_uart_address,errorptr);
}
void uart_register_file::turn_off_bit(unsigned the_reg_num, unsigned long bit, unsigned long secondary_uart_address = 0, int* errorptr = NULL) {
	unsigned long long  val;
	val = this->read_control_reg(the_reg_num,secondary_uart_address,errorptr);
   	val = val & (~(((unsigned long long)1) << ((unsigned long long) bit)));
	this->write_control_reg(the_reg_num,val,secondary_uart_address,errorptr);
}


std::string uart_register_file::unsafe_exec_internal_command(std::string the_command, unsigned long secondary_uart_address, int* errorptr)
{
	int local_error=0;
	std::string result;
	//unsafe in the sense that we don't check for a valid uart
	lock();
	std::ostringstream str_to_uart;
	u(safe_print(std::cout << "uart_register_file::exec_internal_command device: " << device_name << " secondary uart:" << secondary_uart_address << std::hex << " command (" << the_command << ")" << std::endl;));
	if (secondary_uart_address == 0) {
	    str_to_uart << "t" << " " << the_command;
	} else {
		str_to_uart << "U " << std::hex << secondary_uart_address << " t" << " " << the_command;
	}
	u(safe_print(std::cout << "Writing string: [" << str_to_uart.str() << "]\n";));

#if CHECK_UART_REGFILE_ERROR_AND_RETRY
	int max_trys = 0;
	do {
	local_error = 0;
#endif
	writestr(str_to_uart.str());
	result = get_uart_string_response(secondary_uart_address,&local_error);
#if CHECK_UART_REGFILE_ERROR_AND_RETRY
	if (local_error != 0) {
		safe_print(std::cout << "uart_register_file::unsafe_exec_internal_command: " << device_name << " secondary uart:" << secondary_uart_address <<  std::hex << "commmand: " << the_command << std::dec<< "Error encountered: " << local_error << std::endl;);
		writestr(""); //get uart regfile to idle state
		max_trys++;
	}
	} while ((local_error != 0) && (max_trys < MAX_TRYS_FOR_UART_REGFILE_RETRY));
#endif
	u(safe_print(std::cout << "Got response: [" << result << "]\n";));
	unlock();

	if (local_error != 0) {
		this->set_last_error(local_error,secondary_uart_address);
	}

	if (errorptr) {
			*errorptr = local_error;
	}
	return result;
};

std::string uart_register_file::exec_internal_command(std::string the_command, unsigned long secondary_uart_address, int* errorptr)
{
	int local_error=0;
	std::string result;
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return "";
	}

	lock();
	std::ostringstream str_to_uart;
	u(safe_print(std::cout << "uart_register_file::exec_internal_command device: " << device_name << " secondary uart:" << secondary_uart_address << std::hex << " command (" << the_command << ")" << std::endl;));
	if (secondary_uart_address == 0) {
	    str_to_uart << "t" << " " << the_command;
	} else {
		str_to_uart << "U " << std::hex << secondary_uart_address << " t" << " " << the_command;
	}
	u(safe_print(std::cout << "Writing string: [" << str_to_uart.str() << "]\n";));
#if CHECK_UART_REGFILE_ERROR_AND_RETRY
	int max_trys = 0;
	do {
	local_error = 0;
#endif
	writestr(str_to_uart.str());
	result = get_uart_string_response(secondary_uart_address,&local_error);
#if CHECK_UART_REGFILE_ERROR_AND_RETRY
	if (local_error != 0) {
		safe_print(std::cout << "uart_register_file::exec_internal_command: " << device_name << " secondary uart:" << secondary_uart_address <<  std::hex << " command: " << the_command << std::dec<< "Error encountered: " << local_error << std::endl;);
		writestr(""); //get uart regfile to idle state
		max_trys++;
	}
	} while ((local_error != 0) && (max_trys < MAX_TRYS_FOR_UART_REGFILE_RETRY));
#endif
	u(safe_print(std::cout << "Got response: [" << result << "]\n";));
	unlock();

	if (local_error != 0) {
		this->set_last_error(local_error,secondary_uart_address);
	}

	if (errorptr) {
				*errorptr = local_error;
	}
	return result;
};
std::string uart_register_file::exec_internal_command_get_ascii_response(std::string the_command, unsigned long secondary_uart_address, int* errorptr)
{

	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return "";
	}

	std::string initial_result = exec_internal_command(the_command,secondary_uart_address,errorptr);
	std::string result = TrimSpacesFromString(conv_hex_string_to_safe_ascii(initial_result));
	return result;
};

unsigned long long uart_register_file::read_status_reg(unsigned long address, unsigned long secondary_uart_address, int* errorptr){
    int local_error = 0;
    unsigned long long result;
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return 0xEAA;
	}

	lock();
	std::ostringstream str_to_uart;
	u(safe_print(std::cout << "uart_register_file::read_status_reg: " << device_name << " secondary uart:" << secondary_uart_address <<  std::hex << " address: 0x" << address << std::dec<< std::endl;));
	if (secondary_uart_address == 0) {
	    str_to_uart << "S " << std::hex << address;
	} else {
		str_to_uart << "U " << std::hex << secondary_uart_address  << " S " << address;
	}
#if CHECK_UART_REGFILE_ERROR_AND_RETRY
	int max_trys = 0;
	do {
	local_error = 0;
#endif
	writestr(str_to_uart.str());
	result = get_uart_unsigned_long_long_response(secondary_uart_address,&local_error);
#if CHECK_UART_REGFILE_ERROR_AND_RETRY
	if (local_error != 0) {
		safe_print(std::cout << "uart_register_file::read_status_reg: " << device_name << " secondary uart:" << secondary_uart_address <<  std::hex << " address: 0x" << address << std::dec<< "Error encountered: " << local_error << std::endl;);
		writestr(""); //get uart regfile to idle state
		max_trys++;
	}
	} while ((local_error != 0) && (max_trys < MAX_TRYS_FOR_UART_REGFILE_RETRY));
#endif
	u(safe_print(std::cout<< "Result of UART status read is: " << std::hex << result << std::dec <<  " which is the decimal number: " << result << std::endl;));
	unlock();

	if (local_error != 0) {
		this->set_last_error(local_error,secondary_uart_address);
	}

	if (errorptr) {
					*errorptr = local_error;
	}
	return result;
};


unsigned long long uart_register_file::read_info_reg(unsigned long address, unsigned long secondary_uart_address, int* errorptr){
    int local_error = 0;
    unsigned long long result;
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return 0xEAA;
	}

	lock();
	std::ostringstream str_to_uart;
	u(safe_print(std::cout << "uart_register_file::read_info_reg: " << device_name << " secondary uart:" << secondary_uart_address <<  std::hex << " address: 0x" << address << std::dec<< std::endl;));
	if (secondary_uart_address == 0) {
	   str_to_uart << "I " << std::hex << address;
	} else {
		str_to_uart << "U " << std::hex << secondary_uart_address  << " I " << address;
	}
#if CHECK_UART_REGFILE_ERROR_AND_RETRY
	int max_trys = 0;
	do {
	local_error = 0;
#endif
	writestr(str_to_uart.str());
	result = get_uart_unsigned_long_long_response(secondary_uart_address,&local_error) & 0xff; //Info read is always a byte read
#if CHECK_UART_REGFILE_ERROR_AND_RETRY
	if (local_error != 0) {
		safe_print(std::cout << "uart_register_file::read_info_reg: " << device_name << " secondary uart:" << secondary_uart_address <<  std::hex << " address: 0x" << address << std::dec<< "Error encountered: " << local_error << std::endl;);
		writestr(""); //get uart regfile to idle state
		max_trys++;
	}
	} while ((local_error != 0) && (max_trys < MAX_TRYS_FOR_UART_REGFILE_RETRY));
#endif
	u(safe_print(std::cout<< "Result of UART info read is: " << std::hex << result << std::dec << " which is the decimal number: " << result << std::endl;));
	unlock();

	if (local_error != 0) {
		this->set_last_error(local_error,secondary_uart_address);
	}

	if (errorptr) {
						*errorptr = local_error;
	}
	return result;
};

void uart_register_file::get_raw_info(std::vector<unsigned long>& raw_info,  unsigned long secondary_uart_address, int* errorptr) {

	if (!secondary_uart_is_within_range(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		std::cout.flush();
		return;
	}

	std::ostringstream str_to_uart;
	for (int i=0; i < UART_REGISTER_FILE_NUM_INFO_REGS; i++)
	{
		u(safe_print(std::cout << " i = " << i << "\n";));
		raw_info.at(i) = read_info_reg(i, secondary_uart_address,errorptr);
		if ((errorptr != NULL) && ((*errorptr) < 0)) {
		    safe_print(std::cout << "Error during read UART: " << get_device_name() << " File: " << __FILE__ << " Line: " << __LINE__ << " Func: " << __func__);
			return; //an error has occurred
		}
	}
}

void uart_register_file::make_named_param_map(unsigned long secondary_uart_address) {
	if (!secondary_uart_is_within_range(secondary_uart_address)) {
		dureg(safe_print(std::cout << "make_named_param_map: invalid secondary Address: " << secondary_uart_address<< std::endl););
		std::cout.flush();
		return;
	}

	named_param_map[secondary_uart_address] = convert_string_to_key_value_map<std::string,std::string>(TrimSpacesFromString(get_params_str(secondary_uart_address))," \t\n\r");
}

std::string uart_register_file::get_params_str(unsigned long secondary_uart_address){
	std::ostringstream retstr;

	if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return "";
	}

	retstr << "DEVICE_NAME " << device_name << " VERSION " << regfile_params.at(secondary_uart_address).VERSION
			<< " USER_TYPE " << regfile_params.at(secondary_uart_address).USER_TYPE
			<< " DATA_WIDTH " << regfile_params.at(secondary_uart_address).DATA_WIDTH << " ADDRESS_WIDTH "
			<< regfile_params.at(secondary_uart_address).ADDRESS_WIDTH
			<< " STATUS_ADDRESS_START " << regfile_params.at(secondary_uart_address).STATUS_ADDRESS_START
			<< " NUM_OF_CONTROL_REGS " << regfile_params.at(secondary_uart_address).NUM_OF_CONTROL_REGS
			<< " NUM_OF_STATUS_REGS " << regfile_params.at(secondary_uart_address).NUM_OF_STATUS_REGS
			<< " INIT_ALL_CONTROL_REGS_TO_DEFAULT " << regfile_params.at(secondary_uart_address).INIT_ALL_CONTROL_REGS_TO_DEFAULT
			<< " USE_AUTO_RESET " << regfile_params.at(secondary_uart_address).USE_AUTO_RESET << " DISPLAY_NAME \""
			<< regfile_params.at(secondary_uart_address).DISPLAY_NAME << "\"" << ""
			<< " NUM_SECONDARY_UARTS " << regfile_params.at(secondary_uart_address).NUM_SECONDARY_UARTS
			<< " ADDRESS_OF_THIS_UART " << regfile_params.at(secondary_uart_address).ADDRESS_OF_THIS_UART
			<< " IS_SECONDARY_UART " << regfile_params.at(secondary_uart_address).IS_SECONDARY_UART
	        << " CLOCK_RATE_IN_HZ "               << regfile_params.at(secondary_uart_address).CLOCK_RATE_IN_HZ
	        << " WATCHDOG_LIMIT_IN_CLOCK_CYCLES " << regfile_params.at(secondary_uart_address).WATCHDOG_LIMIT_IN_CLOCK_CYCLES
	        << " WATCHDOG_LIMIT_IN_SYSTEM_TICKS " << regfile_params.at(secondary_uart_address).WATCHDOG_LIMIT_IN_SYSTEM_TICKS
	        << " IS_ACTUALLY_PRESENT " << regfile_params.at(secondary_uart_address).IS_ACTUALLY_PRESENT
	        << " ENABLE_ERROR_MONITORING "                   << regfile_params.at(secondary_uart_address).ENABLE_ERROR_MONITORING
	        << " DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS "<< regfile_params.at(secondary_uart_address).DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS
	        << " IGNORE_TIMING_TO_READ_LD "                  << regfile_params.at(secondary_uart_address).IGNORE_TIMING_TO_READ_LD
	        << " USE_GENERIC_ATTRIBUTE_FOR_READ_LD "          << regfile_params.at(secondary_uart_address).USE_GENERIC_ATTRIBUTE_FOR_READ_LD
	        << " WISHBONE_INTERFACE_IS_PART_OF_BRIDGE "       << regfile_params.at(secondary_uart_address).WISHBONE_INTERFACE_IS_PART_OF_BRIDGE
	        << " ENABLE_STATUS_WISHBONE_INTERFACE "          << regfile_params.at(secondary_uart_address).ENABLE_STATUS_WISHBONE_INTERFACE
	        << " ENABLE_CONTROL_WISHBONE_INTERFACE "         << regfile_params.at(secondary_uart_address).ENABLE_CONTROL_WISHBONE_INTERFACE
	        << " STATUS_WISHBONE_NUM_ADDRESS_BITS "           << regfile_params.at(secondary_uart_address).STATUS_WISHBONE_NUM_ADDRESS_BITS
	        << " CONTROL_WISHBONE_NUM_ADDRESS_BITS "         << regfile_params.at(secondary_uart_address).CONTROL_WISHBONE_NUM_ADDRESS_BITS
	        << " WISHBONE_STATUS_BASE_ADDRESS "              << regfile_params.at(secondary_uart_address).WISHBONE_STATUS_BASE_ADDRESS
	        << " WISHBONE_CONTROL_BASE_ADDRESS "             << regfile_params.at(secondary_uart_address).WISHBONE_CONTROL_BASE_ADDRESS
	        ;


	return retstr.str();
};

void uart_register_file::init_params(map_of_str_to_uint_type* uart_map_of_display_name_to_secondary_address) {
	std::vector<unsigned long> raw_info(UART_REGISTER_FILE_NUM_INFO_REGS);

	int err = 0;
	int current_secondary_uart = 0;
	regfile_params.resize(1);

	for (current_secondary_uart = 0; current_secondary_uart <= this->get_max_secondary_uarts(); current_secondary_uart++) {

                    err = 0;

                   //debureg(safe_print(std::cout << "in init_params UART: " << get_device_name() << " File: " << __FILE__ << " Line: " << __LINE__ << " Func: " << __func__ << "\n"));
                   //debureg(std::cout.flush());

                    if (current_secondary_uart == 0) {
                        this->set_timeout(DEFAULT_INITIAL_PRIMARY_UART_TIMEOUT_IN_SYSTEM_TICKS);
                    } else {
		                this->set_timeout(DEFAULT_INITIAL_SECONDARY_UART_TIMEOUT_IN_SYSTEM_TICKS);
                    }

                    //debureg(std::cout.flush());
                    //debureg(safe_print(std::cout << "before get_raw_info UART: " << get_device_name() << " File: " << __FILE__ << " Line: " << __LINE__ << " Func: " << __func__<< "\n"));
                    //debureg(std::cout.flush());

                    regfile_params.at(current_secondary_uart).IS_ACTUALLY_PRESENT = 1; //let's be optimistic

                    get_raw_info(raw_info, current_secondary_uart, &err);

                    //debureg(safe_print(std::cout << "after get_raw_info UART: " << get_device_name() << " File: " << __FILE__ << " Line: " << __LINE__ << " Func: " << __func__<< "\n"));
					//std::cout.flush();

					if (err <0) {
						    regfile_params.at(current_secondary_uart).IS_ACTUALLY_PRESENT = 0;
						    safe_print(std::cout << "Error: UART: " << get_device_name() << " File: " << __FILE__ << " Line: " << __LINE__ << " Func: " << __func__<< " secondary_uart = " << current_secondary_uart << " Timeout Error has been detected!\n";);
					} else {
					        regfile_params.at(current_secondary_uart).IS_ACTUALLY_PRESENT = 1;
					}

					//debureg(safe_print(std::cout << "UART: " << get_device_name() << " File: " << __FILE__ << " Line: " << __LINE__ << " Func: " << __func__<< "\n"));

					if (regfile_params.at(current_secondary_uart).IS_ACTUALLY_PRESENT)
					  {
						//debureg(safe_print(std::cout << "UART: " << get_device_name() << " File: " << __FILE__ << " Line: " << __LINE__ << " Func: " << __func__<< "\n"));

							if (current_secondary_uart == 0) {
								this->set_timeout(DEFAULT_POST_INIT_PRIMARY_UART_TIMEOUT_IN_SYSTEM_TICKS);
							} else {
								this->set_timeout(DEFAULT_POST_INIT_SECONDARY_UART_TIMEOUT_IN_SYSTEM_TICKS);
							}

							//debureg(safe_print(std::cout << "UART: " << get_device_name() << " File: " << __FILE__ << " Line: " << __LINE__ << " Func: " << __func__));
							//debureg(safe_print(std::cout << " after get_raw_info current_secondary_uart = " << current_secondary_uart << "\n";));

							regfile_params.at(current_secondary_uart).DATA_WIDTH                          = (raw_info.at(1) << 8) + raw_info.at(0);
							regfile_params.at(current_secondary_uart).ADDRESS_WIDTH                       = (raw_info.at(3) << 8) + raw_info.at(2);
							regfile_params.at(current_secondary_uart).STATUS_ADDRESS_START                = (raw_info.at(5) << 8) + raw_info.at(4);
							regfile_params.at(current_secondary_uart).NUM_OF_CONTROL_REGS                 = (raw_info.at(7) << 8) + raw_info.at(6);
							regfile_params.at(current_secondary_uart).NUM_OF_STATUS_REGS                  = (raw_info.at(9) << 8) + raw_info.at(8);
							regfile_params.at(current_secondary_uart).INIT_ALL_CONTROL_REGS_TO_DEFAULT    = raw_info.at(10) & 0x2;
							regfile_params.at(current_secondary_uart).USE_AUTO_RESET                      = raw_info.at(10) & 0x1;
							regfile_params.at(current_secondary_uart).VERSION                             = raw_info.at(15);
							regfile_params.at(current_secondary_uart).USER_TYPE                           = raw_info.at(32);
							regfile_params.at(current_secondary_uart).ADDRESS_OF_THIS_UART                = raw_info.at(33);
							regfile_params.at(current_secondary_uart).IS_SECONDARY_UART                   = raw_info.at(34);
							regfile_params.at(current_secondary_uart).NUM_SECONDARY_UARTS                 = raw_info.at(35);
							regfile_params.at(current_secondary_uart).CLOCK_RATE_IN_HZ                    = (raw_info.at(39) << 24) + (raw_info.at(38) << 16) + (raw_info.at(37) << 8) + raw_info.at(36);
							regfile_params.at(current_secondary_uart).WATCHDOG_LIMIT_IN_CLOCK_CYCLES      = (raw_info.at(43) << 24) + (raw_info.at(42) << 16) + (raw_info.at(41) << 8) + raw_info.at(40);
							regfile_params.at(current_secondary_uart).WATCHDOG_LIMIT_IN_SYSTEM_TICKS = ((regfile_params.at(current_secondary_uart).WATCHDOG_LIMIT_IN_CLOCK_CYCLES == 0)
									                                                                    || (regfile_params.at(current_secondary_uart).CLOCK_RATE_IN_HZ == 0)) ? 0 :
									                                                                    ((unsigned)
									                                                                    (((((double)regfile_params.at(current_secondary_uart).WATCHDOG_LIMIT_IN_CLOCK_CYCLES)/((double)regfile_params.at(current_secondary_uart).CLOCK_RATE_IN_HZ ))*((double)(OS_TICKS_PER_SEC))) + 1));


							regfile_params.at(current_secondary_uart).ENABLE_ERROR_MONITORING                     =  extract_bit_range( raw_info.at( 0x32 ),1,1);
							regfile_params.at(current_secondary_uart).DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  =  extract_bit_range( raw_info.at( 0x32 ),0,0);
							regfile_params.at(current_secondary_uart).IGNORE_TIMING_TO_READ_LD                    =  extract_bit_range( raw_info.at( 0x32 ),3,3);
							regfile_params.at(current_secondary_uart).USE_GENERIC_ATTRIBUTE_FOR_READ_LD           =  extract_bit_range( raw_info.at( 0x32 ),2,2);
							regfile_params.at(current_secondary_uart).WISHBONE_INTERFACE_IS_PART_OF_BRIDGE        =  extract_bit_range( raw_info.at( 0x33 ),2,2);
							regfile_params.at(current_secondary_uart).ENABLE_STATUS_WISHBONE_INTERFACE            =  extract_bit_range( raw_info.at( 0x33 ),1,1);
							regfile_params.at(current_secondary_uart).ENABLE_CONTROL_WISHBONE_INTERFACE           =  extract_bit_range( raw_info.at( 0x33 ),0,0);
							regfile_params.at(current_secondary_uart).STATUS_WISHBONE_NUM_ADDRESS_BITS            =  raw_info.at (0x34) ;
							regfile_params.at(current_secondary_uart).CONTROL_WISHBONE_NUM_ADDRESS_BITS           =  raw_info.at (0x35);


                            regfile_params.at(current_secondary_uart).WISHBONE_STATUS_BASE_ADDRESS     = (raw_info.at(0x39) << 24) + (raw_info.at(0x38) << 16) + (raw_info.at(0x37) << 8) + raw_info.at(0x36);
                            regfile_params.at(current_secondary_uart).WISHBONE_CONTROL_BASE_ADDRESS    = (raw_info.at(0x3D) << 24) + (raw_info.at(0x3C) << 16) + (raw_info.at(0x3B) << 8) + raw_info.at(0x3A);
                            //regfile_params.at(current_secondary_uart).WISHBONE_CONTROL_BASE_ADDRESS    = (raw_info.at(0x43) << 24) + (raw_info.at(0x42) << 16) + (raw_info.at(0x41) << 8) + raw_info.at(0x40);




							regfile_params.at(current_secondary_uart).DISPLAY_NAME  = "";

								for (int i = 31; i >= 16; i= i-1) {
									if (raw_info[i] != 0) {
										regfile_params.at(current_secondary_uart).DISPLAY_NAME += ((char)(raw_info.at(i)));
									}
								}
								regfile_params.at(current_secondary_uart).DISPLAY_NAME = TrimSpacesFromString(regfile_params.at(current_secondary_uart).DISPLAY_NAME);
								if (auto_append_uart_indices_to_display_name) {
									std::ostringstream uart_string_to_append;
									if (primary_uart_num_if_known < 0) {
									  uart_string_to_append << std::dec << "_Ux_" << current_secondary_uart;
									} else {
									   uart_string_to_append << std::dec << "_U_" << primary_uart_num_if_known << "_" << current_secondary_uart;
									}
									regfile_params.at(current_secondary_uart).DISPLAY_NAME += uart_string_to_append.str();

								}
								 if (uart_map_of_display_name_to_secondary_address != NULL) {
																(*uart_map_of_display_name_to_secondary_address)[regfile_params.at(current_secondary_uart).DISPLAY_NAME] = current_secondary_uart;
								 }
							//debureg(safe_print(std::cout << " after regfile assignments  current_secondary_uart = " << current_secondary_uart << "\n";));

						    make_named_param_map(current_secondary_uart);

							if (current_secondary_uart == 0) {
								//debureg(safe_print(std::cout << " in secondary_uart_assignment regfile assignments  current_secondary_uart = " << current_secondary_uart << "\n";));

								set_max_secondary_uarts(regfile_params.at(0).NUM_SECONDARY_UARTS);
								regfile_params.resize(this->get_max_secondary_uarts()+1);
							}

							if ((special_uart_maps != NULL) &&
						        (special_uart_maps->count(this->get_user_type(current_secondary_uart)) != 0))  {
								set_included_ctrl_regs(special_uart_maps->find(this->get_user_type(current_secondary_uart))->second.get_ctrl_included(),current_secondary_uart);
								set_included_status_regs(special_uart_maps->find(this->get_user_type(current_secondary_uart))->second.get_status_included(),current_secondary_uart);
							}


					}
					//debureg(safe_print(std::cout << " end of loop current_secondary_uart = " << current_secondary_uart << "\n";));

	}
	this_has_been_initialized = true;

	u(safe_print(std::cout << get_params_str() << "\n" ));
}

std::string uart_register_file::get_display_name(unsigned long secondary_uart_address)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
			safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl);
			return "INVALID";
	}

	return regfile_params.at(secondary_uart_address).DISPLAY_NAME;
};


unsigned long uart_register_file::get_version(unsigned long secondary_uart_address)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
			safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl);
			return 0;
	}

	return regfile_params.at(secondary_uart_address).VERSION;
};


unsigned long uart_register_file::get_secondary_uart_timeout_in_ticks(unsigned long secondary_uart_address)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
			safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl);
			return 0;
	}

	return regfile_params.at(secondary_uart_address).WATCHDOG_LIMIT_IN_SYSTEM_TICKS;
};
unsigned long uart_register_file::is_actually_present(unsigned long secondary_uart_address)
{
	if (!secondary_uart_is_within_range(secondary_uart_address)) {
			safe_print(std::cout << "uart_register_file::is_actually_present invalid secondary Address: " << secondary_uart_address<< std::endl);
			return 0;
	}

	return regfile_params.at(secondary_uart_address).IS_ACTUALLY_PRESENT;
};

std::string uart_register_file::read_all_ctrl_desc(unsigned long secondary_uart_address, int* errorptr) {
	std::ostringstream retstr;

		if (!is_valid_secondary_uart(secondary_uart_address)) {
					safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl);
					return "";
		}
		if (included_ctrl_regs[secondary_uart_address].size() == 0) {
			unsigned upper_limit = this->regfile_params.at(secondary_uart_address).NUM_OF_CONTROL_REGS;
		    for (unsigned i = 0; i < upper_limit; i++) {
								retstr << i << " \"" <<  removeAllSpacesFromString(this->get_control_desc(i,secondary_uart_address,errorptr))  << "\"";
								if (i != (upper_limit-1)) {
									retstr << " ";
								}
						}
			}  else {
					for (unsigned i = 0; i < included_ctrl_regs[secondary_uart_address].size(); i++) {
							unsigned current_reg = included_ctrl_regs[secondary_uart_address].at(i);
							retstr << current_reg << " \"" <<  removeAllSpacesFromString(this->get_control_desc(current_reg,secondary_uart_address,errorptr))  << "\"";
							if (i != (included_ctrl_regs[secondary_uart_address].size()-1)) {
								retstr << " ";
							}
					}
			}
		return retstr.str();
}


register_desc_map_type uart_register_file::read_all_ctrl_desc_as_map(unsigned long secondary_uart_address, int* errorptr) {

	    register_desc_map_type retmap;
		if (!is_valid_secondary_uart(secondary_uart_address)) {
					safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl);
					return retmap;
		}
		if (included_ctrl_regs[secondary_uart_address].size() == 0) {
			unsigned upper_limit = this->regfile_params.at(secondary_uart_address).NUM_OF_CONTROL_REGS;
		    for (unsigned i = 0; i < upper_limit; i++) {
		    	retmap[i] =  removeAllSpacesFromString(this->get_control_desc(i,secondary_uart_address,errorptr));

						}
			}  else {
					for (unsigned i = 0; i < included_ctrl_regs[secondary_uart_address].size(); i++) {
							unsigned current_reg = included_ctrl_regs[secondary_uart_address].at(i);
							retmap[current_reg] = removeAllSpacesFromString(this->get_control_desc(current_reg,secondary_uart_address,errorptr));
					}
			}
		return retmap;
}



std::string  uart_register_file::read_all_status_desc(unsigned long secondary_uart_address, int* errorptr) {
	std::ostringstream retstr;

	if (!is_valid_secondary_uart(secondary_uart_address)) {
				safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl);
				return "";
	}
	if (included_status_regs[secondary_uart_address].size() == 0) {
		unsigned upper_limit = this->regfile_params.at(secondary_uart_address).NUM_OF_STATUS_REGS;
		for (unsigned i = 0; i < upper_limit; i++) {
						retstr << i << " \"" << removeAllSpacesFromString(this->get_status_desc(i,secondary_uart_address,errorptr)) << "\"";
						if (i != (upper_limit-1)) {
							retstr << " ";
						}
				}
	} else {
		for (unsigned i = 0; i < included_status_regs[secondary_uart_address].size(); i++) {
				unsigned current_reg = included_status_regs[secondary_uart_address].at(i);
				retstr << current_reg << " \"" <<  removeAllSpacesFromString(this->get_status_desc(current_reg,secondary_uart_address,errorptr))  << "\"";
				if (i != (included_status_regs[secondary_uart_address].size()-1)) {
					retstr << " ";
				}
		}
	}
	return retstr.str();
}



register_desc_map_type  uart_register_file::read_all_status_desc_as_map(unsigned long secondary_uart_address, int* errorptr) {
    register_desc_map_type retmap;

	if (!is_valid_secondary_uart(secondary_uart_address)) {
				safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl);
				return retmap;
	}
	if (included_status_regs[secondary_uart_address].size() == 0) {
		unsigned upper_limit = this->regfile_params.at(secondary_uart_address).NUM_OF_STATUS_REGS;
		for (unsigned i = 0; i < upper_limit; i++) {
						retmap[i] = removeAllSpacesFromString(this->get_status_desc(i,secondary_uart_address,errorptr));
				}
	} else {
		for (unsigned i = 0; i < included_status_regs[secondary_uart_address].size(); i++) {
				unsigned current_reg = included_status_regs[secondary_uart_address].at(i);
				retmap[current_reg] = removeAllSpacesFromString(this->get_status_desc(current_reg,secondary_uart_address,errorptr));
		}
	}
	return retmap;
}

std::string uart_register_file::read_all_ctrl(unsigned long secondary_uart_address, int* errorptr,  int pretty_format, int hex_format) {
	std::ostringstream retstr;
	//debureg(xprintf("x1"));
	if (!is_valid_secondary_uart(secondary_uart_address)) {
				safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl);
				return "";
	}
	//debureg(xprintf("x2"));

	if (hex_format) {
		retstr << std::hex;
	}

	if (included_ctrl_regs[secondary_uart_address].size() == 0) {
		unsigned upper_limit = this->regfile_params.at(secondary_uart_address).NUM_OF_CONTROL_REGS;
	    for (unsigned i = 0; i < upper_limit; i++) {
	    	//debureg(xprintf("x3"));

							retstr << i << " " << this->read_control_reg(i,secondary_uart_address,errorptr);
							//debureg(xprintf("x4"));
							if (pretty_format) {
							        retstr << "\n";
							 } else {
									if (i != (upper_limit-1)) {
										retstr << " ";
									}
							 }
					}
		}  else {
				for (unsigned i = 0; i < included_ctrl_regs[secondary_uart_address].size(); i++) {
					   //debureg(xprintf("x5"));

						unsigned current_reg = included_ctrl_regs[secondary_uart_address].at(i);
						retstr << current_reg << " " << this->read_control_reg(current_reg,secondary_uart_address,errorptr);
						//debureg(xprintf("x6"));
                        if (pretty_format) {
                        	retstr << "\n";
                        } else {
							if (i != (included_ctrl_regs[secondary_uart_address].size()-1)) {
								retstr << " ";
							}
                        }
						//debureg(xprintf("x7"));

				}
		}
	//debureg(xprintf("x8"));

	return retstr.str();
}

std::string  uart_register_file::read_all_status(unsigned long secondary_uart_address, int* errorptr,  int pretty_format, int hex_format) {
	std::ostringstream retstr;

	if (!is_valid_secondary_uart(secondary_uart_address)) {
		safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl);
		return "";
	}

	if (hex_format) {
			retstr << std::hex;
	}

	if (included_status_regs[secondary_uart_address].size() == 0) {
		unsigned upper_limit = this->regfile_params.at(secondary_uart_address).NUM_OF_STATUS_REGS;
		for (unsigned i = 0; i < upper_limit; i++) {
			retstr << i << " " << this->read_status_reg(i,secondary_uart_address,errorptr);
			if (pretty_format) {
				retstr << "\n";
			}  else {
				if (i != (upper_limit-1)) {
					retstr << " ";
				}
		   }
	}
   } else {
	for (unsigned i = 0; i < included_status_regs[secondary_uart_address].size(); i++) {
		unsigned current_reg = included_status_regs[secondary_uart_address].at(i);
		retstr << current_reg << " " << this->read_status_reg(current_reg,secondary_uart_address,errorptr);
		if (pretty_format) {
			retstr << "\n";
		}  else {
			if (i != (included_status_regs[secondary_uart_address].size()-1)) {
				retstr << " ";
			}
		}
	}
}
return retstr.str();
}

 std::string  uart_register_file::read_all_control_and_status(unsigned long secondary_uart_address, int* errorptr){
		std::ostringstream retstr;
		retstr << "{control} {" << read_all_ctrl(secondary_uart_address,errorptr) << "} {status} {" << read_all_status(secondary_uart_address,errorptr) << "}";
		return retstr.str();
 }

uart_regfile_single_uart_included_regs_type uart_register_file::get_included_ctrl_regs(unsigned long secondary_uart_address)
    {

            return included_ctrl_regs[secondary_uart_address];

    }

    void uart_register_file::set_included_ctrl_regs(uart_regfile_single_uart_included_regs_type includedCtrlRegs, unsigned long secondary_uart_address)
    {
    		              included_ctrl_regs[secondary_uart_address] = includedCtrlRegs;

    }

    uart_regfile_single_uart_included_regs_type uart_register_file::get_included_status_regs(unsigned long  secondary_uart_address)
    {
    	            return included_status_regs[secondary_uart_address];

    }

    void uart_register_file::set_included_status_regs(uart_regfile_single_uart_included_regs_type includedStatusRegs, unsigned long  secondary_uart_address)
    {
           included_status_regs[secondary_uart_address] = includedStatusRegs;

    }

     std::string uart_register_file::get_included_status_regs_as_string(unsigned long  secondary_uart_address)
    {
    	          return convert_vector_to_string<unsigned long >(included_status_regs[secondary_uart_address]);

    }

    std::string uart_register_file::get_included_ctrl_regs_as_string(unsigned long  secondary_uart_address)
    {
          return convert_vector_to_string<unsigned long >(included_ctrl_regs[secondary_uart_address]);

    }

    unsigned long uart_register_file::get_max_included_ctrl_register (unsigned long secondary_uart_address){
    	if (included_ctrl_regs.find(secondary_uart_address) == included_ctrl_regs.end()) {
    		    return 0;
    	} else {
    		if (included_ctrl_regs[secondary_uart_address].size() == 0) {
    			return 0;
    		} else {
    	       return(1+(*std::max_element(included_ctrl_regs[secondary_uart_address].begin(),included_ctrl_regs[secondary_uart_address].end())));
    	   }
    	}
    };

    unsigned long uart_register_file::get_max_included_status_register (unsigned long secondary_uart_address){
    	if (included_status_regs.find(secondary_uart_address) == included_status_regs.end()) {
    	    		return 0;
    	} else {
    		if (included_status_regs[secondary_uart_address].size() == 0) {
    			return 0;
    		} else {
    	         return(1+(*std::max_element(included_status_regs[secondary_uart_address].begin(),included_status_regs[secondary_uart_address].end())));
    		}
       }
    };


    std::string  uart_regfile_repository_class::read_multiple_control_and_status(std::vector<std::string>& uarts_to_acquire, int* errorptr){
     		std::ostringstream retstr;
     		std::string uart_name;
     		int primary_uart_num;
     		int secondary_uart_num;
 			//debureg(xprintf("1"));
     		for (unsigned i=0; i < uarts_to_acquire.size(); i++) {
     			//debureg(xprintf("1"));
     			uart_name = uarts_to_acquire.at(i);
     			//debureg(xprintf("2"));
     			primary_uart_num = get_primary_uart_from_string(uart_name);
     			//debureg(xprintf("3"));
     			secondary_uart_num = get_secondary_uart_from_string(uart_name);
     			//debureg(std::cout << "uart_regfile_repository::read_multiple_control_and_status: " << __FILE__ << " Line: " << __LINE__ << " UART name: " << uart_name << " uarts_to_acquire.size() " << uarts_to_acquire.size() << std::endl);
     			if ((primary_uart_num == -1) || (secondary_uart_num == -1)) {
        		    std::cout << "Error: uart_regfile_repository::read_multiple_control_and_status: " << __FILE__ << " Line: " << __LINE__ << " Unknown UART: " << uart_name << std::endl;
     				return "";
     			}
     			//debureg(xprintf("5"));
     			retstr << "{control " << uart_name << "}";
     			//debureg(xprintf("6"));
     			retstr << " {" << get_uart_ptr_from_number(primary_uart_num)->read_all_ctrl(secondary_uart_num,errorptr) << "} ";
     			//debureg(xprintf("7"));
     			retstr << "{status " << uart_name << "}";
     			//debureg(xprintf("8"));
     		    retstr << " {" << get_uart_ptr_from_number(primary_uart_num)->read_all_status(secondary_uart_num,errorptr) << "} ";
     		    //debureg(xprintf("9"));
     		}
     		return (TrimSpacesFromString(retstr.str()));
      }

    vector_of_uart_primary_and_secondary_defs uart_regfile_repository_class::get_all_uarts_of_type(uart_user_types user_type){
    	vector_of_uart_primary_and_secondary_defs result_vec;
    	uart_regfile_display_string_mapping_type::iterator it;
    			std::ostringstream ostr;

    				 for (it=uart_display_name_to_addr_map.begin(); it!=uart_display_name_to_addr_map.end(); ++it) {
    					 if (this->get_uart_ptr_from_number(it->second.get_uart_primary_index())->get_user_type(it->second.get_uart_secondary_index()) == user_type) {
    						 result_vec.push_back(it->second);
    					 ostr << "{" << it->second.get_uart_primary_index();
    					   if (it->second.get_uart_secondary_index() != 0) {
    						 ostr << "_" << it->second.get_uart_secondary_index();
    					   }
    					   ostr <<"} ";
    					   // {" << get_uart_ptr_from_number(it->second.get_uart_primary_index())->get_params_str(it->second.get_uart_secondary_index()) << "} ";
    					 }
    				 };
					  std::cout << ostr.str();
					  return result_vec;

    }



	void uart_register_file::set_lock_acquired_indication_pio (altera_pio_encapsulator* lock_acquired_indication_pio) {
	        this->lock_acquired_indication_pio = lock_acquired_indication_pio;
	}

	altera_pio_encapsulator* uart_register_file::get_lock_acquired_indication_pio() {
			return lock_acquired_indication_pio;
	}

    unsigned int uart_register_file::get_lock_acquired_pio_bit() {
  	  return this->lock_acquired_pio_bit;
    }

    unsigned int uart_register_file::set_lock_acquired_pio_bit(unsigned int lock_acquired_pio_bit) {
        	  this->lock_acquired_pio_bit = lock_acquired_pio_bit;
    }

    int uart_register_file::lock() {
    	int lock_result = semaphore_locking_class::lock();
    	if (lock_result == RETURN_VAL_TRUE) {
    		altera_pio_encapsulator* lock_pio = this->get_lock_acquired_indication_pio();
    		if (lock_pio != NULL) {
    			lock_pio->turn_on_bit(this->get_lock_acquired_pio_bit());
    		}
    	}
    	return lock_result;
    }

        int uart_register_file::unlock() {
        	int unlock_result = semaphore_locking_class::unlock();
        	if (unlock_result == RETURN_VAL_TRUE) {
        		altera_pio_encapsulator* lock_pio = this->get_lock_acquired_indication_pio();
        		if (lock_pio != NULL) {
        			lock_pio->turn_off_bit(this->get_lock_acquired_pio_bit());
        		}
        	}
        	return unlock_result;
        }
