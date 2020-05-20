/*
 * fmc176_ad9517_virtual_uart.cpp
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#include "fmc176_ad9517_virtual_uart.h"
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

#define u(x) do { if (DEBUG_fmc176_ad9517_DEVICE_DRIVER) {x;} } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if (DEBUG_fmc176_ad9517_DEVICE_DRIVER) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} } while (0)

unsigned long long fmc176_ad9517_virtual_uart::read_control_reg(unsigned long address,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return 0;
		}
		return this->fmc176_ad9517_read(address);
};

void fmc176_ad9517_virtual_uart::write_control_reg(unsigned long address,
		unsigned long long data,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	this->fmc176_ad9517_write(address,data);
};



fmc176_ad9517_virtual_uart::fmc176_ad9517_virtual_uart() :
	virtual_uart_register_file(),
	fmc176_ad9517_driver() {
	default_register_descriptions[0x000] =	"Global_SPI_config";
	default_register_descriptions[0x003] =	"Part_ID"                      ;
	default_register_descriptions[0x004] =	"Readback_ctrl"             ;
	default_register_descriptions[0x010] =	"PFD_and_charge_pump"          ;
	default_register_descriptions[0x011] =	"R_counter_LSB"                ;
	default_register_descriptions[0x012] =	"R_counter_MSB"                ;
	default_register_descriptions[0x013] =	"A_counter"                    ;
	default_register_descriptions[0x014] =	"B_counter_LSB"                ;
	default_register_descriptions[0x015] =	"B_counter_MSB"                ;
	default_register_descriptions[0x016] =	"PLL_CTRL_1"                ;
	default_register_descriptions[0x017] =	"PLL_CTRL_2"                ;
	default_register_descriptions[0x018] =	"PLL_CTRL_3"                ;
	default_register_descriptions[0x019] =	"PLL_CTRL_4"                ;
	default_register_descriptions[0x01A] =	"PLL_CTRL_5"                ;
	default_register_descriptions[0x01B] =	"PLL_CTRL_6"                ;
	default_register_descriptions[0x01C] =	"PLL_CTRL_7"                ;
	default_register_descriptions[0x01D] =	"PLL_CTRL_8"                ;
	default_register_descriptions[0x01E] =	"PLL_CTRL_9"                ;
	default_register_descriptions[0x01F] =	"PLL_readback"                 ;
	default_register_descriptions[0x0A0] =	"OUT4_delay_bypass"            ;
	default_register_descriptions[0x0A1] =	"OUT4_delay_fullscale"        ;
	default_register_descriptions[0x0A2] =	"OUT4_delay_fraction"          ;
	default_register_descriptions[0x0A3] =	"OUT5_delay_bypass"            ;
	default_register_descriptions[0x0A4] =	"OUT5_delay_fullscale"        ;
	default_register_descriptions[0x0A5] =	"OUT5_delay_fraction"          ;
	default_register_descriptions[0x0A6] =	"OUT6_delay_bypass"            ;
	default_register_descriptions[0x0A7] =	"OUT6_delay_fullscale"        ;
	default_register_descriptions[0x0A8] =	"OUT6_delay_fraction"          ;
	default_register_descriptions[0x0A9] =	"OUT7_delay_bypass"            ;
	default_register_descriptions[0x0AA] =	"OUT7_delay_fullscale"        ;
	default_register_descriptions[0x0AB] =	"OUT7_delay_fraction"          ;
	default_register_descriptions[0x0F0] =	"OUT0"                         ;
	default_register_descriptions[0x0F1] =	"OUT1"                         ;
	default_register_descriptions[0x0F4] =	"OUT2"                         ;
	default_register_descriptions[0x0F5] =	"OUT3"                         ;
	default_register_descriptions[0x140] =	"OUT4"                         ;
	default_register_descriptions[0x141] =	"OUT5"                         ;
	default_register_descriptions[0x142] =	"OUT6"                         ;
	default_register_descriptions[0x143] =	"OUT7"                         ;
	default_register_descriptions[0x190] =	"Divider0_reg0"       ;
	default_register_descriptions[0x191] =	"Divider0_reg1"       ;
	default_register_descriptions[0x192] =	"Divider0_reg2"       ;
	default_register_descriptions[0x196] =	"Divider1_reg0"        ;
	default_register_descriptions[0x197] =	"Divider1_reg1"        ;
	default_register_descriptions[0x198] =	"Divider1_reg2"        ;
	default_register_descriptions[0x199] =	"Divider_2_reg0" ;
	default_register_descriptions[0x19A] =	"Divider_2_reg1" ;
	default_register_descriptions[0x19B] =	"Divider_2_reg2" ;
	default_register_descriptions[0x19C] =	"Divider_2_reg3" ;
	default_register_descriptions[0x19D] =	"Divider_2_reg4" ;
	default_register_descriptions[0x19E] =	"Divider_3_reg0" ;
	default_register_descriptions[0x19F] =	"Divider_3_reg1" ;
	default_register_descriptions[0x1A0] =	"Divider_3_reg2" ;
	default_register_descriptions[0x1A1] =	"Divider_3_reg3" ;
	default_register_descriptions[0x1A2] =	"Divider_3_reg4" ;
	default_register_descriptions[0x1E0] =	"VCO_divider";
	default_register_descriptions[0x1E1] =	"Input_CLKs";
	default_register_descriptions[0x230] =	"Powerdown_and_sync";
	default_register_descriptions[0x232] =	"Update_all_registers";
	
	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(default_register_descriptions);

	this->set_control_reg_map_desc(default_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << " set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
};
