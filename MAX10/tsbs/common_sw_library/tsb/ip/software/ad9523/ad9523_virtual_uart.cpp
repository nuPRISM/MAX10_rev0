/*
 * ad9523_virtual_uart.cpp
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#include "ad9523_virtual_uart.h"
#include "basedef.h"
#include <sstream>
#include <iostream>
#include <string>
#include <stdio.h>
#include "linnux_utils.h"
#include "basedef.h"
#include "debug_macro_definitions.h"
#include <vector>
extern "C" {
#include <xprintf.h>
}

#define u(x) do { if (DEBUG_ad9523_DEVICE_DRIVER) {x;} } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if (DEBUG_ad9523_DEVICE_DRIVER) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} } while (0)

unsigned long long ad9523_virtual_uart::read_control_reg(unsigned long address,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return 0;
		}
		return this->ad9523_read(address);
};

void ad9523_virtual_uart::write_control_reg(unsigned long address,
		unsigned long long data,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	this->ad9523_write(address,data);
};



ad9523_virtual_uart::ad9523_virtual_uart(unsigned long current_chipselect_index) :
	virtual_uart_register_file(),
	ad9523_driver(current_chipselect_index) {
default_register_descriptions[0x000] = "SPI_mode_config"                                 ;
default_register_descriptions[0x004] = "Readback_control"                                                            ;
default_register_descriptions[0x005] = "EEPROM_ID_LSB"                                    ;
default_register_descriptions[0x006] = "EEPROM_ID_MSB"                                    ;
default_register_descriptions[0x010] = "PLL1_REFA_R_LSB"                                    ;
default_register_descriptions[0x011] = "PLL1_REFA_R_MSB"                                    ;
default_register_descriptions[0x012] = "PLL1_REFB_R_LSB"                                    ;
default_register_descriptions[0x013] = "PLL1_REFB_R_LSB"                                     ;
default_register_descriptions[0x014] = "PLL1_reference test divider"                                                        ;
default_register_descriptions[0x015] = "PLL1_reserved"                                                        ;
default_register_descriptions[0x016] = "PLL1_feedback_N_LSB"                                     ;
default_register_descriptions[0x017] = "PLL1_feedback_N_MSB"                                     ;
default_register_descriptions[0x018] = "PLL1_charge_pump_A"                                                            ;
default_register_descriptions[0x019] = "PLL1_charge_pump_B"                                                               ;
default_register_descriptions[0x01A] = "PLL1_input_recev";
default_register_descriptions[0x01B] = "REF_TEST"                                     ;
default_register_descriptions[0x01C] = "PLL1_misc"                                                         ;
default_register_descriptions[0x01D] = "PLL1_LF_Zero_R"                                     ;
default_register_descriptions[0x0F0] = "PLL2_charge_pump"                                                                 ;
default_register_descriptions[0x0F1] = "PLL2_feedback_N"                                   ;
default_register_descriptions[0x0F2] = "PLL2_control"                                                                 ;
default_register_descriptions[0x0F3] = "VCO_control"                                                                ;
default_register_descriptions[0x0F4] = "VCO_dividers"                                                              ;
default_register_descriptions[0x0F5] = "PLL2_LF_CTRL_A"                                    ;
default_register_descriptions[0x0F6] = "PLL2_LF_CTRL_B"                                    ;
default_register_descriptions[0x0F7] = "PLL2_R2_divider"                                                                   ;
default_register_descriptions[0x190] = "Channel_0_CTRL_A"                                   ;
default_register_descriptions[0x191] = "Channel_0_CTRL_B"                                   ;
default_register_descriptions[0x192] = "Channel_0_CTRL_C"                                   ;
default_register_descriptions[0x193] = "Channel_1_CTRL_A"                                   ;
default_register_descriptions[0x194] = "Channel_1_CTRL_B"                                   ;
default_register_descriptions[0x195] = "Channel_1_CTRL_C"                                   ;
default_register_descriptions[0x196] = "Channel_2_CTRL_A"                                   ;
default_register_descriptions[0x197] = "Channel_2_CTRL_B"                                   ;
default_register_descriptions[0x198] = "Channel_2_CTRL_C"                                   ;
default_register_descriptions[0x199] = "Channel_3_CTRL_A"                                   ;
default_register_descriptions[0x19A] = "Channel_3_CTRL_B"                                   ;
default_register_descriptions[0x19B] = "Channel_3_CTRL_C"                                   ;
default_register_descriptions[0x19C] = "Channel_4_CTRL_A"                                   ;
default_register_descriptions[0x19D] = "Channel_4_CTRL_B"                                   ;
default_register_descriptions[0x19E] = "Channel_4_CTRL_C"                                   ;
default_register_descriptions[0x19F] = "Channel_5_CTRL_A"                                   ;
default_register_descriptions[0x1A0] = "Channel_5_CTRL_B"                                   ;
default_register_descriptions[0x1A1] = "Channel_5_CTRL_C"                                   ;
default_register_descriptions[0x1A2] = "Channel_6_CTRL_A"                                   ;
default_register_descriptions[0x1A3] = "Channel_6_CTRL_B"                                   ;
default_register_descriptions[0x1A4] = "Channel_6_CTRL_C"                                   ;
default_register_descriptions[0x1A5] = "Channel_7_CTRL_A"                                   ;
default_register_descriptions[0x1A6] = "Channel_7_CTRL_B"                                   ;
default_register_descriptions[0x1A7] = "Channel_7_CTRL_C"                                   ;
default_register_descriptions[0x1A8] = "Channel_8_CTRL_A"                                   ;
default_register_descriptions[0x1A9] = "Channel_8_CTRL_B"                                   ;
default_register_descriptions[0x1AA] = "Channel_8_CTRL_C"                                   ;
default_register_descriptions[0x1AB] = "Channel_9_CTRL_A"                                   ;
default_register_descriptions[0x1AC] = "Channel_9_CTRL_B"                                   ;
default_register_descriptions[0x1AD] = "Channel_9_CTRL_C"                                   ;
default_register_descriptions[0x1AE] = "Channel_10_CTRL_A"                                   ;                 
default_register_descriptions[0x1AF] = "Channel_10_CTRL_B"                                   ;                 
default_register_descriptions[0x1B0] = "Channel_10_CTRL_C"                                   ;
default_register_descriptions[0x1B1] = "Channel_11_CTRL_A"                                   ;
default_register_descriptions[0x1B2] = "Channel_11_CTRL_B"                                   ;
default_register_descriptions[0x1B3] = "Channel_11_CTRL_C"                                   ;
default_register_descriptions[0x1B4] = "Channel_12_CTRL_A"                                   ;
default_register_descriptions[0x1B5] = "Channel_12_CTRL_B"                                   ;
default_register_descriptions[0x1B6] = "Channel_12_CTRL_C"                                   ;
default_register_descriptions[0x1B7] = "Channel_13_CTRL_A"                                   ;
default_register_descriptions[0x1B8] = "Channel_13_CTRL_B"                                   ;
default_register_descriptions[0x1B9] = "Channel_13_CTRL_C"                                   ;
default_register_descriptions[0x1BA] = "PLL1_output"                                       ;
default_register_descriptions[0x1BB] = "PLL1_output_chan_ctrl"                                ;
default_register_descriptions[0x22C] = "Readback_0"                                                 ;
default_register_descriptions[0x22D] = "Readback_1"                                                 ;
default_register_descriptions[0x22E] = "Readback_2"                                                 ;
default_register_descriptions[0x22F] = "Readback_3"                                                 ;
default_register_descriptions[0x230] = "Status_A"                                       ;
default_register_descriptions[0x231] = "Status_B"                                       ;
default_register_descriptions[0x232] = "Status_C"                                       ;
default_register_descriptions[0x233] = "Powerdown"                                      ;
default_register_descriptions[0x234] = "Update_all_regs"                                       ;

    std::ostringstream ostr;
	for (unsigned int i = 0x0A00; i < 0x0A16; i++) {
		ostr.str("");
		ostr << std::hex << "EEPROM_BUF_SEG_" << i << std::dec;
		default_register_descriptions[i] = ostr.str();
	}
	
	default_register_descriptions[0xB00] = "EEPROM_STATUS"  ;
	default_register_descriptions[0xB01] = "EEPROM_ERR_CHECK"; 
	default_register_descriptions[0xB02] = "EEPROM_CONTROL1";
	default_register_descriptions[0xB03] = "EEPROM_CONTROL2";
	
	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(default_register_descriptions);

	this->set_control_reg_map_desc(default_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << " set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
};
