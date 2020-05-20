/*
 * ltc2668_virtual_uart.cpp
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#include "ltc2668_virtual_uart.h"
#include "basedef.h"
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

unsigned long long ltc2668_virtual_uart::read_control_reg(unsigned long address,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return 0;
		}
		return this->ltc2668_read(address);
};

void ltc2668_virtual_uart::write_control_reg(unsigned long address,
		unsigned long long data,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	this->ltc2668_write(address,data);
};


ltc2668_virtual_uart::ltc2668_virtual_uart() :
	virtual_uart_register_file(),
	ltc2668_driver() {
	
	
		default_register_descriptions[0x000] = "DAC00"                           ;
		default_register_descriptions[0x001] = "DAC01"                           ;
		default_register_descriptions[0x002] = "DAC02"                                           ;
		default_register_descriptions[0x003] = "DAC03"                                    ;
		default_register_descriptions[0x004] = "DAC04"                                   ;
		default_register_descriptions[0x005] = "DAC05"                                 ;
		default_register_descriptions[0x006] = "DAC06"                                  ;
		default_register_descriptions[0x007] = "DAC07"                                      ;
		default_register_descriptions[0x008] = "DAC08"                                           ;
		default_register_descriptions[0x009] = "DAC19"                                     ;
		default_register_descriptions[0x00A] = "DAC10"                             ;
		default_register_descriptions[0x00B] = "DAC11"                                ;
		default_register_descriptions[0x00C] = "DAC12"                                ;
		default_register_descriptions[0x00D] = "DAC13"                                   ;
		default_register_descriptions[0x00E] = "DAC14"                                   ;
		default_register_descriptions[0x00F] = "DAC15"                                   ;

	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(default_register_descriptions);

	this->set_control_reg_map_desc(default_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << " set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
};
