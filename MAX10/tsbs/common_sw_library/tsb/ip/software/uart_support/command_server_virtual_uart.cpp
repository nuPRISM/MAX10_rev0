/*
 * command_server_virtual_uart.cpp
 *
 *  Created on: Jan 29, 2014
 *      Author: yairlinn
 */

#include "command_server_virtual_uart.h"
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

#define u(x) do { if (UART_REG_DEBUG) {x;} } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if (UART_REG_DEBUG) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} } while (0)


std::string command_server_virtual_uart::exec_internal_command(std::string the_command, unsigned long secondary_uart_address, int* errorptr)
{

	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return "";
	}

	if (command_function == NULL) {
		dureg(safe_print(std::cout << "exec_internal_command called but command_function_is NULL! " << std::endl););
        return "";
	}

	return this->command_function(the_command,this->get_additional_data());
};

std::string command_server_virtual_uart::exec_internal_command_get_ascii_response(std::string the_command, unsigned long secondary_uart_address, int* errorptr)
{

	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return "";
	}

	std::string initial_result = exec_internal_command(the_command,secondary_uart_address,errorptr);
	dureg(safe_print(std::cout <<"exec_internal_command_get_ascii_response got initial response (" << initial_result<< ")" << std::endl););
	std::string result = TrimSpacesFromString(conv_hex_string_to_safe_ascii(initial_result));
	return result;
}
