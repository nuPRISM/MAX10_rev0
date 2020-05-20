/*
 * lmk04816_virtual_uart.cpp
 *
 *  Created on: Nov 21, 2016
 *      Author: yairlinn
 */

#include "lmk04816_virtual_uart.h"


lmk04816_virtual_uart::~lmk04816_virtual_uart() {
	// TODO Auto-generated destructor stub
}

#include "lmk04816_virtual_uart.h"
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

#ifndef DEBUG_lmk04816_VIRTUAL_UART
#define DEBUG_lmk04816_VIRTUAL_UART (0)
#endif

#define u(x) do { if (DEBUG_lmk04816_VIRTUAL_UART) {x;} } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if (DEBUG_lmk04816_VIRTUAL_UART) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} } while (0)

register_desc_map_type lmk04816_default_register_descriptions;



unsigned long long lmk04816_virtual_uart::read_control_reg(unsigned long address,
		unsigned long secondary_uart_address,
		int* errorptr)
{
   return this->read_reg(address);
};

void lmk04816_virtual_uart::write_control_reg(unsigned long address,
		unsigned long long data,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	this->write_reg(address,data);
};

lmk04816_virtual_uart::lmk04816_virtual_uart(unsigned long lmk_clk_base, unsigned long lmk_data_base,  unsigned long lmk_leu_base, unsigned long lmk_status_holdover_base) :
	command_server_virtual_uart(),
	lmk04816_uwire(lmk_clk_base, lmk_data_base,  lmk_leu_base, lmk_status_holdover_base) {
		/*
	lmk04816_default_register_descriptions[0x0   ]="RESET";
	*/
	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(lmk04816_default_register_descriptions);
    this->set_additional_data((void*) this);
	this->set_control_reg_map_desc(lmk04816_default_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << " set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
};
