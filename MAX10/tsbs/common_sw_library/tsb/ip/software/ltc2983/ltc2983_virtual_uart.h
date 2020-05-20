/*
 * ltc2983_virtual_uart.h
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#ifndef ltc2983_VIRTUAL_UART_H_
#define ltc2983_VIRTUAL_UART_H_

#include "debug_macro_definitions.h"
#include "command_server_virtual_uart.h"
#include "ltc2983_driver.h"
#include "arg.hh"
#include <map>

#ifndef DEBUG_LTC2983_VIRTUAL_UART
#define DEBUG_LTC2983_VIRTUAL_UART (0)
#endif

class ltc2983_virtual_uart;

typedef std::string(ltc2983_virtual_uart::*ltc2983_virtual_uart_function_type)(std::string);
typedef std::map<std::string,ltc2983_virtual_uart_function_type> ltc2983_string_to_function_map;
class ltc2983_virtual_uart: public command_server_virtual_uart,
		public ltc2983_driver
{
protected:
	std::string get_temp_from_channel(std::string the_command);
	std::string get_multiple_temps_from_channel(std::string the_command);
	std::string get_active_temp_channels(std::string the_command);
    std::string active_temp_channels_string;
    std::string active_temp_legend_string;
    std::string get_legend_strs(std::string the_command);
public:
	ltc2983_virtual_uart();
	ltc2983_string_to_function_map command_function_map;
	std::string dispatch(ltc2983_virtual_uart_function_type the_func, std::string the_parameter) {return (this->*the_func)(the_parameter);};
	virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
    virtual void write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);

	std::string get_active_temp_channels_string() const {
		return active_temp_channels_string;
	}

	void set_active_temp_channels_string(
			std::string activeTempChannelsString) {
		active_temp_channels_string = activeTempChannelsString;
	}

	std::string get_active_temp_legend_string() const {
		return active_temp_legend_string;
	}

	void set_active_temp_legend_string(
			std::string activeTempLegendString) {
		active_temp_legend_string = activeTempLegendString;
	}

	const ltc2983_string_to_function_map& get_command_function_map() const {
		return command_function_map;
	}

	void set_command_function_map(
			const ltc2983_string_to_function_map& commandFunctionMap) {
		command_function_map = commandFunctionMap;
	}
};

#endif /* ltc2983_VIRTUAL_UART_H_ */
