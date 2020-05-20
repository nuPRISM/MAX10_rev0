/*
 * ads4249_virtual_uart.cpp
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#include "ads4249_virtual_uart.h"
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

unsigned long long ads4249_virtual_uart::read_control_reg(unsigned long address,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return 0;
		}
		return this->ads4249_read(address);
};

void ads4249_virtual_uart::write_control_reg(unsigned long address,
		unsigned long long data,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	this->ads4249_write(address,data);
};



ads4249_virtual_uart::ads4249_virtual_uart() :
	virtual_uart_register_file(),
	ads4249_driver() {
	
	
	default_register_descriptions[0x0000] = "readout"                                        ;
	default_register_descriptions[0x0001] = "LVDS_Swing"                                        ;
	default_register_descriptions[0x0003] = "perf_mode"                                        ;
	default_register_descriptions[0x0025] = "chA_gain_and_patt"                                        ;
	default_register_descriptions[0x0029] = "data_formait"                                        ;
	default_register_descriptions[0x002B] = "chB_gain_and_patt";
	default_register_descriptions[0x003D] = "enable_offset_corr";
	default_register_descriptions[0x003F] = "custom_patt_13_8";
	default_register_descriptions[0x0040] = "custom_patt_7_0";
	default_register_descriptions[0x0041] = "out_ctrl";
	default_register_descriptions[0x0042] = "clkout_ctrl";
	default_register_descriptions[0x0045] = "lvds_strength";
	default_register_descriptions[0x004A] = "chB_hi_freq_mode";
	default_register_descriptions[0x0058] = "chA_hi_freq_mode";
	default_register_descriptions[0x00BF] = "chA_offset_ped";
	default_register_descriptions[0x00C1] = "chB_offset_ped";
	default_register_descriptions[0x00CF] = "offset_corr";
	default_register_descriptions[0x00EF] = "en_low_speed";
	default_register_descriptions[0x00F1] = "en_lvds_swing";
	default_register_descriptions[0x00F2] = "chA_low_speed_mode";
	default_register_descriptions[0x00D2] = "high_perf_mode3";
	default_register_descriptions[0x00D5] = "high_perf_mode4_5";
	default_register_descriptions[0x00D7] = "high_perf_mode6_7";
	default_register_descriptions[0x00DB] = "high_perf_mode8";

	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(default_register_descriptions);

	this->set_control_reg_map_desc(default_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << " set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
};
