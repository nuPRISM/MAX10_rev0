/*
 * uart_vector_config_encapsulator.cpp
 *
 *  Created on: May 13, 2013
 *      Author: yairlinn
 */

#include "uart_vector_config_encapsulator.h"
#include <sstream>
#include <iostream>
#include <string>
#include "linnux_utils.h"

unsigned long uart_vector_config_encapsulator::get_max_uart_num() const
{
    return max_uart_num;
}

unsigned long uart_vector_config_encapsulator::get_raw_uart_enabled_vector() const
{
    return raw_uart_enabled_vector;
}

void uart_vector_config_encapsulator::set_max_uart_num(unsigned long  max_uart_num)
{
    this->max_uart_num = max_uart_num;
}

void uart_vector_config_encapsulator::set_raw_uart_enabled_vector(unsigned long  raw_uart_enabled_vector)
{
    this->raw_uart_enabled_vector = raw_uart_enabled_vector;
}

uart_vector_config_encapsulator::~uart_vector_config_encapsulator() {
	// TODO Auto-generated destructor stub
}

std::string uart_vector_config_encapsulator::get_tcl_vector_of_enable_status() {
    std::ostringstream ostr;

    for (unsigned  i = 0; i < 32; i++) {
    	if (this->is_enabled(i)) {
    		ostr << "1 ";
    	} else {
    		ostr << "0 ";
    	}
    }
/*
    for (unsigned i = this->get_max_uart_num(); i < 32; i++ ) {
    	ostr << "0 "; //pad with zeros until 32 bits
    }
*/
    return TrimSpacesFromString(ostr.str());
};

std::string uart_vector_config_encapsulator::get_tcl_vector_of_virtual_enable_status() {
    std::ostringstream ostr;

    for (unsigned  i = 0; i < get_max_num_of_virtual_uarts(); i++) {
    	if (this->virtual_uart_is_enabled(i)) {
    		ostr << "1 ";
    	} else {
    		ostr << "0 ";
    	}
    }
/*
    for (unsigned i = this->get_max_uart_num(); i < 32; i++ ) {
    	ostr << "0 "; //pad with zeros until 32 bits
    }
*/
    return TrimSpacesFromString(ostr.str());
};


std::string uart_vector_config_encapsulator::get_tcl_vector_of_all_enable_status() {
    std::ostringstream ostr;
    ostr << get_tcl_vector_of_enable_status() << " " << get_tcl_vector_of_virtual_enable_status();
    return ostr.str();
}
