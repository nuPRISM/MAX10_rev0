/*
 * ad9253_virtual_uart.cpp
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#include "ad9253_virtual_uart.h"
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

unsigned long long ad9253_virtual_uart::read_control_reg(unsigned long address,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return 0;
		}
		return this->AD9253_read(AD9253_R1B | address);
};

void ad9253_virtual_uart::write_control_reg(unsigned long address,
		unsigned long long data,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	this->AD9253_write((AD9253_R1B | address),data);
};

register_desc_map_type default_register_descriptions;


ad9253_virtual_uart::ad9253_virtual_uart() :
	virtual_uart_register_file(),
	AD9253_driver() {
	default_register_descriptions[0x0  ]="spi_cfg";
	default_register_descriptions[0x1  ]="chip_id";
	default_register_descriptions[0x2  ]="chip_grade";
	default_register_descriptions[0x5  ]="device_index";
	default_register_descriptions[0x8  ]="power_mode(global)";
	default_register_descriptions[0x9  ]="clock(global)";
	default_register_descriptions[0x0B ]="clk_divide(global)";
	default_register_descriptions[0x0C ]="EnhanceCtrl";
	default_register_descriptions[0x0D ]="TestMode(local)";
	default_register_descriptions[0x10 ]="Offset Adjust";
	default_register_descriptions[0x14 ]="OutputMode";
	default_register_descriptions[0x15 ]="OutputAdjust";
	default_register_descriptions[0x16 ]="OutputPhase";
	default_register_descriptions[0x18 ]="VRef";
	default_register_descriptions[0x19 ]="USER_PATT1_LSB";
	default_register_descriptions[0x1A ]="USER_PATT1_MSB";
	default_register_descriptions[0x1B ]="USER_PATT2_LSB";
	default_register_descriptions[0x1C ]="USER_PATT2_MSB";
	default_register_descriptions[0x21 ]="SerOutDatCtrl";
	default_register_descriptions[0x22 ]="SerChanStat";
	default_register_descriptions[0xFF ]="transfer";
	default_register_descriptions[0x100]="Resolution";
	default_register_descriptions[0x101]="UsrIOCtrl2";
	default_register_descriptions[0x102]="UsrIOCtrl3";
	default_register_descriptions[0x109]="Sync";
	static const unsigned long reg_include_init_array[] = {
			0x0  ,
			0x1  ,
			0x2  ,
			0x5  ,
			0x8  ,
			0x9  ,
			0x0B ,
			0x0C ,
			0x0D ,
			0x10 ,
			0x14 ,
			0x15 ,
			0x16 ,
			0x18 ,
			0x19 ,
			0x1A ,
			0x1B ,
			0x1C ,
			0x21 ,
			0x22 ,
			0xFF ,
			0x100,
			0x101,
			0x102,
			0x109

	};
	uart_regfile_single_uart_included_regs_type the_included_regs(reg_include_init_array,reg_include_init_array+sizeof(reg_include_init_array)/sizeof(reg_include_init_array[0]));

	this->set_control_reg_map_desc(default_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << " set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
};
