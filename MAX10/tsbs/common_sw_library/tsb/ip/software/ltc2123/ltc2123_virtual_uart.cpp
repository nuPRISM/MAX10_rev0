/*
 * ltc2123_virtual_uart.cpp
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#include "ltc2123_virtual_uart.h"
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

unsigned long long ltc2123_virtual_uart::read_control_reg(unsigned long address,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return 0;
		}
		return this->ltc2123_read(address);
};

void ltc2123_virtual_uart::write_control_reg(unsigned long address,
		unsigned long long data,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	this->ltc2123_write(address,data);
};



ltc2123_virtual_uart::ltc2123_virtual_uart(unsigned long chipselect, unsigned long id_no, unsigned long jesd_subclass) :
	virtual_uart_register_file(),
	 ltc2123_driver(chipselect, id_no, jesd_subclass){
	
	
		default_register_descriptions[0x000] = "Reset"                                        ;
		default_register_descriptions[0x001] = "PowerDown"                                        ;
		default_register_descriptions[0x002] = "ADC_CNTL"                                             ;
		default_register_descriptions[0x003] = "JESD_DID"                                           ;
		default_register_descriptions[0x004] = "JESD_BID"                                           ;
		default_register_descriptions[0x005] = "JESD_L"                                           ;
        default_register_descriptions[0x006] = "JESD_K"                                           ;
		default_register_descriptions[0x007] = "JESD_MODES"                                           ;
		default_register_descriptions[0x008] = "SUBCLASS"                                           ;
		default_register_descriptions[0x009] = "TEST_PATTERN"                                           ;
		default_register_descriptions[0x00A] = "CML_MANGNITUDE"                                           ;

	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(default_register_descriptions);

	this->set_control_reg_map_desc(default_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << " set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
};
