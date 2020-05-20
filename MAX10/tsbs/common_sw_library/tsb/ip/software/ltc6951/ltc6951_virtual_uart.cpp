/*
 * ltc6951_virtual_uart.cpp
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#include "ltc6951_virtual_uart.h"
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

unsigned long long ltc6951_virtual_uart::read_control_reg(unsigned long address,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return 0;
		}
		return this->ltc6951_read(address);
};

void ltc6951_virtual_uart::write_control_reg(unsigned long address,
		unsigned long long data,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	this->ltc6951_write(address,data);
};



ltc6951_virtual_uart::ltc6951_virtual_uart(unsigned long chipselect, unsigned long id_no) :
	virtual_uart_register_file(),
	 ltc6951_driver(chipselect, id_no) {
	
	
		default_register_descriptions[0x000] = "h00"                                        ;
		default_register_descriptions[0x001] = "h01"                                        ;
		default_register_descriptions[0x002] = "h02"                                             ;
		default_register_descriptions[0x003] = "h03"                                           ;
		default_register_descriptions[0x004] = "h04"                                           ;
		default_register_descriptions[0x005] = "h05"                                           ;
        default_register_descriptions[0x006] = "h06"                                           ;
		default_register_descriptions[0x007] = "h07"                                           ;
		default_register_descriptions[0x008] = "h08"                                           ;
		default_register_descriptions[0x009] = "h09"                                           ;
		default_register_descriptions[0x00A] = "h0a"                                           ;
		default_register_descriptions[0x00B] = "h0a"                                           ;
		default_register_descriptions[0x00C] = "h0a"                                           ;
		default_register_descriptions[0x00D] = "h0a"                                           ;
		default_register_descriptions[0x00E] = "h0a"                                           ;
		default_register_descriptions[0x00F] = "h0a"                                           ;
		default_register_descriptions[0x010] = "h10"                                        ;
		default_register_descriptions[0x011] = "h11"                                        ;
		default_register_descriptions[0x012] = "h12"                                             ;
		default_register_descriptions[0x013] = "h13"                                           ;

	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(default_register_descriptions);

	this->set_control_reg_map_desc(default_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << " set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
};
