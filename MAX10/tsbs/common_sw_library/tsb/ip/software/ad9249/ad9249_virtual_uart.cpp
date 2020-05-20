/*
 * ad9249_virtual_uart.cpp
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#include "ad9249_virtual_uart.h"
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

unsigned long long ad9249_virtual_uart::read_control_reg(unsigned long address,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return 0;
		}
		return this->ad9249_read(address);
};

void ad9249_virtual_uart::write_control_reg(unsigned long address,
		unsigned long long data,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	this->ad9249_write(address,data);
};



ad9249_virtual_uart::ad9249_virtual_uart() :
	virtual_uart_register_file(),
	ad9249_driver() {
	
	
		default_register_descriptions[0x000] = "SPI_CFG"                                        ;
		default_register_descriptions[0x001] = "CHIP_ID"                                        ;
		default_register_descriptions[0x002] = "CHIP_GRADE(global)"                                             ;
		default_register_descriptions[0x004] = "DEVICE_INDEX2"                                           ;
		default_register_descriptions[0x005] = "DEVICE_INDEX1"                                          ;
		default_register_descriptions[0x0FF] = "Transfer"                                             ;
		default_register_descriptions[0x008] = "PowerModes"                                            ;
		default_register_descriptions[0x009] = "Clock(global)"                                             ;
		default_register_descriptions[0x00B] = "ClockDivide(global)"                                            ;
		default_register_descriptions[0x00C] = "EnhancementCtrl"                                          ;
		default_register_descriptions[0x00D] = "TestMode"                                         ;
		default_register_descriptions[0x010] = "OffsetAdjust"                                        ;
		default_register_descriptions[0x014] = "OutputMode"                                          ;
		default_register_descriptions[0x015] = "OutputAdjust"                                           ;
		default_register_descriptions[0x016] = "OutputPhase"                                     ;
		default_register_descriptions[0x018] = "VREF"                                     ;
		default_register_descriptions[0x019] = "USER_PATT1_LSB"                                     ;
		default_register_descriptions[0x01A] = "USER_PATT1_MSB"                                     ;
		default_register_descriptions[0x01B] = "USER_PATT2_LSB"                                     ;
		default_register_descriptions[0x01C] = "USER_PATT2_MSB"                                     ;
		default_register_descriptions[0x021] = "SerOutDataCtrl(global)"                                     ;
		default_register_descriptions[0x022] = "SerChannelStatus(local)"                                      ;
		default_register_descriptions[0x100] = "ResolutionOverride"                                              ;
		default_register_descriptions[0x101] = "UserIOCtrl2"                                       ;
		default_register_descriptions[0x102] = "UserIOCtrl3"                                ;
		default_register_descriptions[0x109] = "Sync"                                            ;

	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(default_register_descriptions);

	this->set_control_reg_map_desc(default_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << " set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
};
