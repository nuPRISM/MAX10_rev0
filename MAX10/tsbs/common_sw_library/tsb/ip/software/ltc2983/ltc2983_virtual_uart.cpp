/*
 * ltc2983_virtual_uart.cpp
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#include "ltc2983_virtual_uart.h"
#include "command_server_virtual_uart.h"
#include "basedef.h"
#include <sstream>
#include <iostream>
#include <string>
#include <stdio.h>
#include "linnux_utils.h"
#include "basedef.h"
#include "arg.hh"
#include <vector>
#include <map>
extern "C" {
#include <xprintf.h>
}

#define u(x) do { if (DEBUG_LTC2983_VIRTUAL_UART) {x;} } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if (DEBUG_LTC2983_VIRTUAL_UART) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} } while (0)

register_desc_map_type ltc2983_default_register_descriptions;



unsigned long long ltc2983_virtual_uart::read_control_reg(unsigned long address,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return 0;
		}
		return this->ltc2983_read(address);
};

void ltc2983_virtual_uart::write_control_reg(unsigned long address,
		unsigned long long data,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	this->ltc2983_write(address,data);
};

std::string ltc2983_virtual_uart::get_temp_from_channel(std::string the_command) {
	int the_channel = convert_string_to_type<int>(the_command);
	u(safe_print(std::cout << "get_temp_from_channel::internal_parse_command:the_command (" << the_command << ")" << "Channel = " <<  the_channel << std::endl;));
	convert_channel(the_channel);
	float the_temp = read_temperature_results(the_channel);
	std::string retstr = convert_type_to_string<float>(the_temp,0);
	return retstr;
}

std::string ltc2983_virtual_uart::get_active_temp_channels(std::string the_command) {
	return this->get_active_temp_channels_string();
}
std::string ltc2983_virtual_uart::get_legend_strs(std::string the_command) {
	return this->get_active_temp_legend_string();
}

std::string ltc2983_virtual_uart::get_multiple_temps_from_channel(std::string the_command) {
	std::vector<unsigned> channels_to_acquire = convert_string_to_vector<unsigned>(the_command,",");
	u(safe_print(std::cout << "get_muliple_temps_from_channel: channels acquired:: (" << convert_vector_to_string<unsigned>(channels_to_acquire) << ")\n"));
	unsigned i, the_channel;
    std::string retstr;
	for (i = 0; i < channels_to_acquire.size(); i++)
	{
		the_channel = channels_to_acquire.at(i);
		convert_channel(the_channel);
		float the_temp = read_temperature_results(the_channel);
		retstr += convert_type_to_string<float>(the_temp,0);
		if (i != (channels_to_acquire.size()-1)) {
			retstr += " ";
		}
	}
	return retstr;
}


std::string ltc2983_internal_parse_command(std::string the_command, void* additional_data){
	ltc2983_virtual_uart* this_pointer = (ltc2983_virtual_uart*)additional_data;
	std::string trimmed_original_str, rest_of_command_string;

	trimmed_original_str = TrimSpacesFromString(ConvertStringToLowerCase(the_command));
	std::vector<std::string> command_vector = convert_string_to_vector<std::string>(trimmed_original_str, " ");

	if (!(command_vector.size() > 0)) {
		safe_print(std::cout << "ltc2983_virtual_uart::ltc2983_internal_parse_command: got no parsed data from command (" << the_command << ")" << std::endl;);
        return "";
	}

	std::string command_name = trimmed_original_str.substr(0,trimmed_original_str.find_first_of(" \n\r\t"));
	TrimSpaces(command_name);

	if (command_vector.size() > 1) {
	   rest_of_command_string = TrimSpacesFromString(trimmed_original_str.substr(trimmed_original_str.find_first_of(" \n\r\t")));
	} else {
		rest_of_command_string = "";
	}

	u(safe_print(std::cout << "ltc2983_virtual_uart::ltc2983_internal_parse_command command (" << the_command << ")" << " rest of the command " << rest_of_command_string << std::endl;));

	ltc2983_string_to_function_map::iterator it;
	it =this_pointer->command_function_map.find(command_vector.at(0));
	if (it != this_pointer->command_function_map.end()) {\
		ltc2983_virtual_uart_function_type the_command_func = this_pointer->command_function_map[command_vector.at(0)];
       return this_pointer->dispatch(the_command_func,rest_of_command_string);
	} else {
		safe_print(std::cout << "ltc2983_virtual_uart::internal_parse_command: unknown command from command (" << the_command << "), parsed command (" << command_vector.at(0) << ")" <<  std::endl;);
		        return "";
	}


}

ltc2983_virtual_uart::ltc2983_virtual_uart() :
	command_server_virtual_uart(),
	ltc2983_driver() {
		/*
	ltc2983_default_register_descriptions[0x0   ]="RESET";
	*/
	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(ltc2983_default_register_descriptions);
    this->set_additional_data((void*) this);
    command_function_map["get_temp"] = &ltc2983_virtual_uart::get_temp_from_channel;
    command_function_map["get_multiple_temps"] = &ltc2983_virtual_uart::get_multiple_temps_from_channel;
    command_function_map["get_active_temp_channels"] = &ltc2983_virtual_uart::get_active_temp_channels;
    command_function_map["get_legend_strs"] = &ltc2983_virtual_uart::get_legend_strs;

	this->set_control_reg_map_desc(ltc2983_default_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);
	this->set_command_function(ltc2983_internal_parse_command);

	dureg(safe_print(std::cout << " set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
};
