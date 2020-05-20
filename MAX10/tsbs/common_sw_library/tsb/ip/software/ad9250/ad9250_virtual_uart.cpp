/*
 * ad9250_virtual_uart.cpp
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#include "ad9250_virtual_uart.h"
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

#define u(x) do { if (DEBUG_ad9250_DEVICE_DRIVER) {x;} } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if (DEBUG_ad9250_DEVICE_DRIVER) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} } while (0)

unsigned long long ad9250_virtual_uart::read_control_reg(unsigned long address,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return 0;
		}
		return this->ad9250_read(address);
};

void ad9250_virtual_uart::write_control_reg(unsigned long address,
		unsigned long long data,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	this->ad9250_write(address,data);
};



ad9250_virtual_uart::ad9250_virtual_uart() :
	virtual_uart_register_file(),
	ad9250_driver() {
	default_register_descriptions[0x00] =	"Global_SPI_config";
	default_register_descriptions[0x01] =	"CHIP_ID";
	default_register_descriptions[0x02] =	"Chip_info";
	default_register_descriptions[0x05] =	"Channel_index";
	default_register_descriptions[0x08] =	"PDWN_modes"                       ;
	default_register_descriptions[0x09] =	"Global_clock_local"               ;
	default_register_descriptions[0x0A] =	"PLL_status"                       ;
	default_register_descriptions[0x0B] =	"Global_clk_div_local"             ;
	default_register_descriptions[0x0D] =	"Test_ctrl_reg_local"              ;
	default_register_descriptions[0x10] =	"Customer_offset_local"            ;
	default_register_descriptions[0x14] =	"Output_mode_local"                ;
	default_register_descriptions[0x15] =	"CML_output_adjust"                ;
	default_register_descriptions[0x18] =	"ADC_VREF"                         ;
	default_register_descriptions[0x19] =	"User_Test_Patt_1_L"               ;
	default_register_descriptions[0x1A] =	"User_Test_Patt_1_M"               ;
	default_register_descriptions[0x1B] =	"User_Test_Patt_2_L"               ;
	default_register_descriptions[0x1C] =	"User_Test_Patt_2_M"               ;
	default_register_descriptions[0x1D] =	"User_Test_Patt_3_L"               ;
	default_register_descriptions[0x1E] =	"User_Test_Patt_3_M"               ;
	default_register_descriptions[0x1F] =	"User_Test_Patt_4_L"               ;
	default_register_descriptions[0x20] =	"User_Test_Patt_4_M"               ;
	default_register_descriptions[0x21] =	"PLL_low_encode"                   ;
	default_register_descriptions[0x3A] =	"SYNCINB_SYSREF_CTRL_local"        ;
	default_register_descriptions[0x40] =	"DCC_CTRL_local"                   ;
	default_register_descriptions[0x41] =	"DCC_val_LSB_local"                ;
	default_register_descriptions[0x42] =	"DCC_val_MSB_local"                ;
	default_register_descriptions[0x45] =	"Fast_det_ctrl_local"              ;
	default_register_descriptions[0x47] =	"FD_upper_thr_local"               ;
	default_register_descriptions[0x48] =	"FD_upper_thr_local"               ;
	default_register_descriptions[0x49] =	"FD_lower_thr_local"               ;
	default_register_descriptions[0x4A] =	"FD_lower_thr_local"               ;
	default_register_descriptions[0x4B] =	"FD_dwell_time_local"              ;
	default_register_descriptions[0x4C] =	"FD_dwell_time_local"              ;
	default_register_descriptions[0x5E] =	"JESD204B_quick config"            ;
	default_register_descriptions[0x5F] =	"JESD204B_Link_CTRL_1"             ;
	default_register_descriptions[0x60] =	"JESD204B_Link_CTRL_2"             ;
	default_register_descriptions[0x61] =	"JESD204B_Link_CTRL_3"             ;
	default_register_descriptions[0x62] =	"JESD204B_Link_CTRL_4"             ;
	default_register_descriptions[0x63] =	"JESD204B_Link_CTRL_5"             ;
	default_register_descriptions[0x64] =	"JESD204B_DID_config"              ;
	default_register_descriptions[0x65] =	"JESD204B_BID_config"              ;
	default_register_descriptions[0x66] =	"JESD204B_LID_Config_0"            ;
	default_register_descriptions[0x67] =	"JESD204B_LID_Config_1"            ;
	default_register_descriptions[0x6E] =	"JESD204B_param_SCR_L"             ;
	default_register_descriptions[0x6F] =	"JESD204B_param_F"                 ;
	default_register_descriptions[0x70] =	"JESD204B_param_K"                 ;
	default_register_descriptions[0x71] =	"JESD204B_param_M"                 ;
	default_register_descriptions[0x72] =	"JESD204B_param_CS_N"              ;
	default_register_descriptions[0x73] =	"JESD204B_param_subclass_Np"       ;
	default_register_descriptions[0x74] =	"JESD204B_param_S"                 ;
	default_register_descriptions[0x75] =	"JESD204B_param_HD_and_CF"         ;
	default_register_descriptions[0x76] =	"JESD204B_RESV1"                   ;
	default_register_descriptions[0x77] =	"JESD204B_RESV2"                   ;
	default_register_descriptions[0x78] =	"JESD204B_CHKSUM0"                 ;
	default_register_descriptions[0x79] =	"JESD204B_CHKSUM1"                 ;
	default_register_descriptions[0x82] =	"JESD204B_Lane_Assign_1"           ;
	default_register_descriptions[0x83] =	"JESD204B_Lane_Assign_2"           ;
	default_register_descriptions[0x8B] =	"JESD204B_LMFC_offset"             ;
	default_register_descriptions[0xA8] =	"JESD204B_pre_emphasis"            ;
	default_register_descriptions[0xEE] =	"Internal_dig_clk_delay"           ;
	default_register_descriptions[0xEF] =	"Internal_dig_clk_delay"           ;
	default_register_descriptions[0xF3] =	"Internal_dig_clk_align"           ;
	default_register_descriptions[0xFF] =	"Device_update_global"             ;
	
	
	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(default_register_descriptions);

	this->set_control_reg_map_desc(default_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << " set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
};
