/*
 * lmk04828_virtual_uart.cpp
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#include "lmk04828_virtual_uart.h"
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

unsigned long long lmk04828_virtual_uart::read_control_reg(unsigned long address,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return 0;
		}
		return this->lmk04828_read(address);
};

void lmk04828_virtual_uart::write_control_reg(unsigned long address,
		unsigned long long data,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	this->lmk04828_write(address,data);
};

register_desc_map_type default_register_descriptions;


lmk04828_virtual_uart::lmk04828_virtual_uart() :
	virtual_uart_register_file(),
	lmk04828_driver() {
	default_register_descriptions[0x0   ]="RESET";
	default_register_descriptions[0x2   ]="POWERDOWN";
	default_register_descriptions[0x003 ]="ID_DEVICE_TYPE";
	default_register_descriptions[0x4   ]="ID_PROD(15:8)";
	default_register_descriptions[0x5   ]="ID_PROD(7:0)";
	default_register_descriptions[0x006 ]="ID_MASKREV";
	default_register_descriptions[0x0C  ]="ID_VNDR(15:8)";
	default_register_descriptions[0x0D  ]="ID_VNDR(7:0)";
	default_register_descriptions[0x100 ]="CLKout0_1_ODL";
	default_register_descriptions[0x108 ]="CLKout2_3_ODL";
	default_register_descriptions[0x110 ]="CLKout4_5_ODL";
	default_register_descriptions[0x118 ]="CLKout6_7_ODL";
	default_register_descriptions[0x120 ]="CLKout8_9_ODL";
	default_register_descriptions[0x128 ]="CLKout10_11_ODL";
	default_register_descriptions[0x130 ]="CLKout12_13_ODL";	
	default_register_descriptions[0x101 ]="DCLKout0_DDLY_CNTH";
	default_register_descriptions[0x109 ]="DCLKout2_DDLY_CNTH";
	default_register_descriptions[0x111 ]="DCLKout4_DDLY_CNTH";
	default_register_descriptions[0x119 ]="DCLKout6_DDLY_CNTH";
	default_register_descriptions[0x121 ]="DCLKout8_DDLY_CNTH";
	default_register_descriptions[0x129 ]="DCLKout10_DDLY_CYNTH";
	default_register_descriptions[0x131 ]="DCLKout12_DDLY_CYNTH";
	default_register_descriptions[0x103 ]="DCLKout0_ADLY";
	default_register_descriptions[0x10B ]="DCLKout2_ADLY";
	default_register_descriptions[0x113 ]="DCLKout4_ADLY";
	default_register_descriptions[0x11B ]="DCLKout6_ADLY";
	default_register_descriptions[0x123 ]="DCLKout8_ADLY";
	default_register_descriptions[0x12B ]="DCLKout10_ADLY";
	default_register_descriptions[0x133 ]="DCLKout12_ADLY";
	default_register_descriptions[0x104 ]="DCLKout0_HS";
	default_register_descriptions[0x10C ]="DCLKout2_HS";
	default_register_descriptions[0x114 ]="DCLKout4_HS";
	default_register_descriptions[0x11C ]="DCLKout6_HS";
	default_register_descriptions[0x124 ]="DCLKout8_HS";
	default_register_descriptions[0x12C ]="DCLKout10_ADLY";
	default_register_descriptions[0x134 ]="DCLKout12_ADLY";	
	default_register_descriptions[0x105 ]="SDCLKout1_ADLY";
	default_register_descriptions[0x10D ]="SDCLKout2_ADLY";
	default_register_descriptions[0x115 ]="SDCLKout3_ADLY";
	default_register_descriptions[0x11D ]="SDCLKout7_ADLY";
	default_register_descriptions[0x125 ]="SDCLKout9_ADLY";
	default_register_descriptions[0x12D ]="SDCLKout11_ADLY";
	default_register_descriptions[0x135 ]="SDCLKout13_ADLY";
	default_register_descriptions[0x106 ]="DDCLKout1_DDLY_PD";
	default_register_descriptions[0x10E ]="DDCLKout2_DDLY_PD";
	default_register_descriptions[0x116 ]="DDCLKout3_DDLY_PD";
	default_register_descriptions[0x11E ]="DDCLKout7_DDLY_PD";
	default_register_descriptions[0x126 ]="DDCLKout9_DDLY_PD";
	default_register_descriptions[0x12E ]="DDCLKout11_DDLY_PD";
	default_register_descriptions[0x136 ]="DDCLKout13_DDLY_PD";
	default_register_descriptions[0x107 ]="SDCLKout1_POL";
	default_register_descriptions[0x10F ]="SDCLKout2_POL";
	default_register_descriptions[0x117 ]="SDCLKout3_POL";
	default_register_descriptions[0x11F ]="SDCLKout7_POL";
	default_register_descriptions[0x127 ]="SDCLKout9_POL";
	default_register_descriptions[0x12F ]="SDCLKout11_POL";
	default_register_descriptions[0x137 ]="SDCLKout13_POL";
	default_register_descriptions[0x138 ]="VCO_MUX";
	default_register_descriptions[0x139 ]="SYSREF_CLKin0_MUX";
	default_register_descriptions[0x13A ]="SYSREF_DIV(12:8)";
	default_register_descriptions[0x13B ]="SYSREF_DIV(7:0)";
	default_register_descriptions[0x13C ]="SYSREF_DDLY(12:8)";
	default_register_descriptions[0x13D ]="SYSREF_DDLY(7:0)";
	default_register_descriptions[0x13E ]="SYSREF_PULSE_CNT";
	default_register_descriptions[0x13F ]="PLL2_NCLK_MUX";
	default_register_descriptions[0x140 ]="PLL1_PD";
	default_register_descriptions[0x141 ]="DDLYdSYSREF_EN";
	default_register_descriptions[0x142 ]="DDLYd_STEP_CNT";
	default_register_descriptions[0x143 ]="SYSREF_CLR";
	default_register_descriptions[0x144 ]="SYNC_DISSYSREF";
	default_register_descriptions[0x145 ]="FIXED_REGISTER";
	default_register_descriptions[0x146 ]="CLKin2_EN";
	default_register_descriptions[0x147 ]="CLKin_SEL_POL";
	default_register_descriptions[0x148 ]="CLKin_SEL0_MUX";
	default_register_descriptions[0x149 ]="SDIO_RDBK_TYPE";
	default_register_descriptions[0x14A ]="RESET_MUX";
	default_register_descriptions[0x14B ]="MAN_DAC(9:8)";
	default_register_descriptions[0x14C ]="MAN_DAC(7:0)";
	default_register_descriptions[0x14D ]="DAC_TRIP_LOW";
	default_register_descriptions[0x14E ]="DAC_CLK_MULT";
	default_register_descriptions[0x14F ]="DAC_CLK_CNTR";
	default_register_descriptions[0x150 ]="CLKin_OVERRIDE";
	default_register_descriptions[0x151 ]="HOLDOVER_DLD_CNT(13:8)";
	default_register_descriptions[0x152 ]="HOLDOVER_DLD_CNT(7:0)";
	default_register_descriptions[0x153 ]="CLKin0_R(13:8)";
	default_register_descriptions[0x154 ]="CLKin0_R(7:0)";
	default_register_descriptions[0x155 ]="CLKin1_R(13:8)";
	default_register_descriptions[0x156 ]="CLKin1_R(7:0)";
	default_register_descriptions[0x157 ]="CLKin2_R(13:8)";
	default_register_descriptions[0x158 ]="CLKin2_R(7:0)";
	default_register_descriptions[0x159 ]="PLL1_N(13:8)";
	default_register_descriptions[0x15A ]="PLL1_N(7:0)";
	default_register_descriptions[0x15B ]="PLL1_WND_SIZE";
	default_register_descriptions[0x15C ]="PLL1_DLD_CNT(13:8)";
	default_register_descriptions[0x15D ]="PLL1_DLD_CNT(7:0)";
	default_register_descriptions[0x15E ]="PLL1_R_DLY";
	default_register_descriptions[0x15F ]="PLL1_LD_MUX";
	default_register_descriptions[0x160 ]="PLL2_R[11:8]";
	default_register_descriptions[0x161 ]="PLL2_R[7:0]";
	default_register_descriptions[0x162 ]="PLL2_P";
	default_register_descriptions[0x163 ]="PLL2_N_CAL(17:16)";
	default_register_descriptions[0x164 ]="PLL2_N_CAL(15:8)";
	default_register_descriptions[0x165 ]="PLL2_N_CAL(7:0)";
	default_register_descriptions[0x166 ]="PLL2_N(17:16)";
	default_register_descriptions[0x167 ]="PLL2_N(15:8)";
	default_register_descriptions[0x168 ]="PLL2_N(7:0)";
	default_register_descriptions[0x169 ]="PLL2_WND_SIZE";
	default_register_descriptions[0x16A ]="PLL2_DLD_CNT(13:8)";
	default_register_descriptions[0x16B ]="PLL2_DLD_CNT(7:0)";
	default_register_descriptions[0x16C ]="PLL2_LF_R4";
	default_register_descriptions[0x16D ]="PLL2_LF_C4";
	default_register_descriptions[0x16E ]="PLL2_LD_MUX";
	default_register_descriptions[0x173 ]="PLL2_PRE_PD";
//	default_register_descriptions[0x174 ]="VCO1_DIV";
	default_register_descriptions[0x17C ]="OPT_REG_1";
	default_register_descriptions[0x17D ]="OPT_REG_2";
	default_register_descriptions[0x182 ]="RB_PLL1_LD_LOST";
	default_register_descriptions[0x183 ]="RB_PLL2_LD_LOST";
	default_register_descriptions[0x184 ]="RB_DAC_VALUE(9:8)";
	default_register_descriptions[0x185 ]="RB_DAC_VALUE(7:0)";
	default_register_descriptions[0x188]="RB_HOLDOVER";
//	default_register_descriptions[0x1FFD]="SPI_LOCK(23:16)";
//	default_register_descriptions[0x1FFE ]="SPI_LOCK(15:8)";
//	default_register_descriptions[0x1FFF ]="SPI_LOCK(7:0)";
	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(default_register_descriptions);

	this->set_control_reg_map_desc(default_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << " set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
};
