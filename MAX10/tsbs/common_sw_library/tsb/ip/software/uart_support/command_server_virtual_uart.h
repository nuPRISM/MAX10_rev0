/*
 * command_server_virtual_uart.h
 *
 *  Created on: Jan 29, 2014
 *      Author: yairlinn
 */

#ifndef COMMAND_SERVER_VIRTUAL_UART_H_
#define COMMAND_SERVER_VIRTUAL_UART_H_

#include "virtual_uart_register_file.h"
#include <string>

typedef std::string (*command_server_command_function_type)(std::string the_command, void* additional_data);

class command_server_virtual_uart : public virtual_uart_register_file {
	command_server_command_function_type command_function;
protected:
	void* additional_data;
public:
	command_server_virtual_uart() : virtual_uart_register_file() { set_additional_data(NULL);} ;

	command_server_command_function_type get_command_function() const {
		return command_function;
	}

	void set_command_function(command_server_command_function_type commandFunction) {
		command_function = commandFunction;
	}

	void set_additional_data(void* additional_data) {
			this->additional_data = additional_data;
	}

	void* get_additional_data() {
				return additional_data;
	}

	virtual std::string exec_internal_command(std::string the_command, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual std::string exec_internal_command_get_ascii_response(std::string the_command, unsigned long secondary_uart_address = 0, int* errorptr = NULL);

};

#endif /* COMMAND_SERVER_VIRTUAL_UART_H_ */
