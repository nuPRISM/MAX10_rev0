/*
 * ad9695_virtual_uart.cpp
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#include "ad9695_virtual_uart.h"
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

#define u(x) do { if (DEBUG_ad9695_DEVICE_DRIVER) {x;} } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if (DEBUG_ad9695_DEVICE_DRIVER) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} } while (0)

unsigned long long ad9695_virtual_uart::read_control_reg(unsigned long address,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return 0;
		}
		return this->ad9695_read(address);
};

void ad9695_virtual_uart::write_control_reg(unsigned long address,
		unsigned long long data,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	this->ad9695_write(address,data);
};



ad9695_virtual_uart::ad9695_virtual_uart() :
	virtual_uart_register_file(),
	ad9695_driver() {
default_register_descriptions[0x0000] = "SPI_Conf_A";                                        ;
default_register_descriptions[0x0001] = "SPI_Conf_B";                                        ;
default_register_descriptions[0x0002] = "Chip_config"                                        ;
default_register_descriptions[0x0003] = "Chip_type"                                          ;
default_register_descriptions[0x0004] = "Chip_ID_LSB"                                        ;
default_register_descriptions[0x0005] = "Chip_ID_MSB"                                        ;
default_register_descriptions[0x0006] = "Chip_grade"                                         ;
default_register_descriptions[0x0008] = "Device_index"	                                     ;
default_register_descriptions[0x000A] = "Scratch_pad"                                        ;
default_register_descriptions[0x000B] = "SPI_revision"                                       ;
default_register_descriptions[0x000C] = "Vendor_ID_LSB"                                      ;
default_register_descriptions[0x000D] = "Vendor_ID_MSB"                                      ;
default_register_descriptions[0x000F] = "Transfer"                                           ;
default_register_descriptions[0x003F] = "Chip_powerdown"                                     ;
default_register_descriptions[0x0040] = "Chip_Pin_Ctrl1"                                     ;
default_register_descriptions[0x0041] = "Chip_Pin_Ctrl2"                                     ;
default_register_descriptions[0x0042] = "Chip_Pin_Ctrl3"                                     ;
default_register_descriptions[0x0108] = "Clock_div_control"                                  ;
default_register_descriptions[0x0109] = "Clock_div_phase"                                    ;
default_register_descriptions[0x010A] = "Clock_div_SYSREF_ctrl"                              ;
default_register_descriptions[0x010B] = "Clock_div_SYSREF_status"                            ;
default_register_descriptions[0x0110] = "Clock_delay_control"                                ;
default_register_descriptions[0x0111] = "Clock_super_fine_delay"                             ;
default_register_descriptions[0x0112] = "Clock_fine_delay"                                   ;
default_register_descriptions[0x0113] = "Dig_clock_super_fine_delay"                         ;
default_register_descriptions[0x0114] = "Dig_clock_fine_delay"                               ;
default_register_descriptions[0x011A] = "Clock_detect_ctrl"                                  ;
default_register_descriptions[0x011B] = "Clock_status"                                       ;
default_register_descriptions[0x011C] = "Clock_DCS1"                                         ;
default_register_descriptions[0x011E] = "Clock_DCS2"                                         ;
default_register_descriptions[0x0120] = "SYSREF_Control1"                                    ;
default_register_descriptions[0x0121] = "SYSREF_Control2"                                    ;
default_register_descriptions[0x0122] = "SYSREF_Control3"                                    ;
default_register_descriptions[0x0123] = "SYSREF_Control4"                                    ;
default_register_descriptions[0x0128] = "SYSREF_Status_1"                                    ;
default_register_descriptions[0x0129] = "SYSREF_Status_2"                                    ;
default_register_descriptions[0x012A] = "SYSREF_Status_3"                                    ;
default_register_descriptions[0x01FF] = "Chip_sync mode"                                     ;
default_register_descriptions[0x0200] = "Chip_mode"                                          ;
default_register_descriptions[0x0201] = "Chip_decimation_ratio"                              ;
default_register_descriptions[0x0245] = "Fast_detect_control"                                ;
default_register_descriptions[0x0247] = "Fast_detect_uppper_LSB"                             ;
default_register_descriptions[0x0248] = "Fast_detect_upper_MSB"                              ;
default_register_descriptions[0x0249] = "Fast_detect_low_LSB"                                ;
default_register_descriptions[0x024A] = "Fast_detect_low_MSB"                                ;
default_register_descriptions[0x024B] = "Fast_detect_dwell_LSB"                              ;
default_register_descriptions[0x024C] = "Fast_detect_dwell_MSB"                              ;
default_register_descriptions[0x026F] = "Signal_mon_sync_control"                            ;
default_register_descriptions[0x0270] = "Signal_mon_control"                                 ;
default_register_descriptions[0x0271] = "Signal_Mon_Period_0"                                ;
default_register_descriptions[0x0272] = "Signal_Mon_Period_1"                                ;
default_register_descriptions[0x0273] = "Signal_Mon_Period_2"                                ;
default_register_descriptions[0x0274] = "Signal_mon_status_control"                          ;
default_register_descriptions[0x0275] = "Signal_Mon_Status_0"                                ;
default_register_descriptions[0x0276] = "Signal_Mon_Status_1"                                ;
default_register_descriptions[0x0277] = "Signal_Mon_Status_2"                                ;
default_register_descriptions[0x0278] = "Signal_mon_status_frame_counter"                    ;
default_register_descriptions[0x0279] = "Signal_mon_serial_framer_control"                   ;
default_register_descriptions[0x027A] = "SPORT_over_JESD204B_input_sel"                      ;
default_register_descriptions[0x0300] = "DDC_sync_control"                                   ;
default_register_descriptions[0x0310] = "DDC_0_control"                                      ;
default_register_descriptions[0x0311] = "DDC_0_input select"                                 ;
default_register_descriptions[0x0314] = "DDC_0_NCO control"                                  ;
default_register_descriptions[0x0315] = "DDC_0_phase control"                                ;
default_register_descriptions[0x0316] = "DDC_0_Phase_Inc_0"                                  ;
default_register_descriptions[0x0317] = "DDC_0_Phase_Inc_1"                                  ;
default_register_descriptions[0x0318] = "DDC_0_Phase_Inc_2"                                  ;
default_register_descriptions[0x0319] = "DDC_0_Phase_Inc_3"                                  ;
default_register_descriptions[0x031A] = "DDC_0_Phase_Inc_4"                                  ;
default_register_descriptions[0x031B] = "DDC_0_Phase_Inc_5"                                  ;
default_register_descriptions[0x031D] = "DDC_0_Phase_Offset_0"                               ;
default_register_descriptions[0x031E] = "DDC_0_Phase_Offset_1"                               ;
default_register_descriptions[0x031F] = "DDC_0_Phase_Offset_2"                               ;
default_register_descriptions[0x0320] = "DDC_0_Phase_Offset_3"                               ;
default_register_descriptions[0x0321] = "DDC_0_Phase_Offset_4"                               ;
default_register_descriptions[0x0322] = "DDC_0_Phase_Offset_5"                               ;
default_register_descriptions[0x0327] = "DDC_0_test_enable"                                  ;
default_register_descriptions[0x0330] = "DDC_1_control"                                      ;
default_register_descriptions[0x0331] = "DDC_1_input_select"                                 ;
default_register_descriptions[0x0334] = "DDC_1_NCO_control"                                  ;
default_register_descriptions[0x0335] = "DDC_1_phase_control"                                ;
default_register_descriptions[0x0336] = "DDC_1_Phase_Inc_0"                                  ;
default_register_descriptions[0x0337] = "DDC_1_Phase_Inc_1"                                  ;
default_register_descriptions[0x0338] = "DDC_1_Phase_Inc_2"                                  ;
default_register_descriptions[0x0339] = "DDC_1_Phase_Inc_3"                                  ;
default_register_descriptions[0x033A] = "DDC_1_Phase_Inc_4"                                  ;
default_register_descriptions[0x033B] = "DDC_1_Phase_Inc_5"                                  ;
default_register_descriptions[0x033D] = "DDC_1_Phase_Offset_0"                               ;
default_register_descriptions[0x033E] = "DDC_1_Phase_Offset_1"                               ;
default_register_descriptions[0x033F] = "DDC_1_Phase_Offset_2"                               ;
default_register_descriptions[0x0340] = "DDC_1_Phase_Offset_3"                               ;
default_register_descriptions[0x0341] = "DDC_1_Phase_Offset_4"                               ;
default_register_descriptions[0x0342] = "DDC_1_Phase_Offset_5"                               ;
default_register_descriptions[0x0347] = "DDC_1_test_enable"	                                 ;
default_register_descriptions[0x0350] = "DDC_2_control"	                                     ;
default_register_descriptions[0x0351] = "DDC_2_input_select"                                 ;
default_register_descriptions[0x0354] = "DDC_2_NCO_control"                                  ;
default_register_descriptions[0x0355] = "DDC_2_phase_control"                                ;
default_register_descriptions[0x0356] = "DDC_2_Phase_Increment_0"                            ;
default_register_descriptions[0x0357] = "DDC_2_Phase_Increment_1"                            ;
default_register_descriptions[0x0358] = "DDC_2_Phase_Increment_2"                            ;
default_register_descriptions[0x0359] = "DDC_2_Phase_Increment_3"                            ;
default_register_descriptions[0x035A] = "DDC_2_Phase_Increment_4"                            ;
default_register_descriptions[0x035B] = "DDC_2_Phase_Increment_5"                            ;
default_register_descriptions[0x035D] = "DDC_2_Phase_Offset_0"                               ;
default_register_descriptions[0x035E] = "DDC_2_Phase_Offset_1"                               ;
default_register_descriptions[0x035F] = "DDC_2_Phase_Offset_2"                               ;
default_register_descriptions[0x0360] = "DDC_2_Phase_Offset_3"                               ;
default_register_descriptions[0x0361] = "DDC_2_Phase_Offset_4"                               ;
default_register_descriptions[0x0362] = "DDC_2_Phase_Offset_5"                               ;
default_register_descriptions[0x0367] = "DDC_2_test_enable"                                  ;
default_register_descriptions[0x0370] = "DDC_3_control"                                      ;
default_register_descriptions[0x0371] = "DDC_3_input_select"                                 ;
default_register_descriptions[0x0374] = "DDC_3_NCO_control"                                  ;
default_register_descriptions[0x0375] = "DDC_3_phase_control"                                ;
default_register_descriptions[0x0376] = "DDC_3_Phase_Inc_0"                                  ;
default_register_descriptions[0x0377] = "DDC_3_Phase_Inc_1"                                  ;
default_register_descriptions[0x0378] = "DDC_3_Phase_Inc_2"                                  ;
default_register_descriptions[0x0379] = "DDC_3_Phase_Inc_3"                                  ;
default_register_descriptions[0x037A] = "DDC_3_Phase_Inc_4"                                  ;
default_register_descriptions[0x037B] = "DDC_3_Phase_Inc_5"                                  ;
default_register_descriptions[0x037D] = "DDC_3_Phase_Offset_0"                               ;
default_register_descriptions[0x037E] = "DDC_3_Phase_Offset_1"                               ;
default_register_descriptions[0x037F] = "DDC_3_Phase_Offset_2"                               ;
default_register_descriptions[0x0380] = "DDC_3_Phase_Offset_3"                               ;
default_register_descriptions[0x0381] = "DDC_3_Phase_Offset_4"                               ;
default_register_descriptions[0x0382] = "DDC_3_Phase_Offset_5"                               ;
default_register_descriptions[0x0387] = "DDC_3_test_enable"		                             ;
default_register_descriptions[0x0390] = "DDC_0_Phase_Inc_Frac_A0"                            ;
default_register_descriptions[0x0391] = "DDC_0_Phase_Inc_Frac_A1"                            ;
default_register_descriptions[0x0392] = "DDC_0_Phase_Inc_Frac_A2"                            ;
default_register_descriptions[0x0393] = "DDC_0_Phase_Inc_Frac_A3"                            ;
default_register_descriptions[0x0394] = "DDC_0_Phase_Inc_Frac_A4"                            ;
default_register_descriptions[0x0395] = "DDC_0_Phase_Inc_Frac_A5"                            ;
default_register_descriptions[0x0398] = "DDC_0_Phase_Inc_Frac_B0"                            ;
default_register_descriptions[0x0399] = "DDC_0_Phase_Inc_Frac_B1"                            ;
default_register_descriptions[0x039A] = "DDC_0_Phase_Inc_Frac_B2"                            ;
default_register_descriptions[0x039B] = "DDC_0_Phase_Inc_Frac_B3"                            ;
default_register_descriptions[0x039C] = "DDC_0_Phase_Inc_Frac_B4"                            ;
default_register_descriptions[0x039D] = "DDC_0_Phase_Inc_Frac_B5"                            ;
default_register_descriptions[0x03A0] = "DDC_1_Phase_Inc_Frac_A0"                            ;
default_register_descriptions[0x03A1] = "DDC_1_Phase_Inc_Frac_A1"                            ;
default_register_descriptions[0x03A2] = "DDC_1_Phase_Inc_Frac_A2"                            ;
default_register_descriptions[0x03A3] = "DDC_1_Phase_Inc_Frac_A3"                            ;
default_register_descriptions[0x03A4] = "DDC_1_Phase_Inc_Frac_A4"                            ;
default_register_descriptions[0x03A5] = "DDC_1_Phase_Inc_Frac_A5"                            ;
default_register_descriptions[0x03A8] = "DDC_1_Phase_Inc_Frac_B0"                            ;
default_register_descriptions[0x03A9] = "DDC_1_Phase_Inc_Frac_B1"                            ;
default_register_descriptions[0x03AA] = "DDC_1_Phase_Inc_Frac_B2"                            ;
default_register_descriptions[0x03AB] = "DDC_1_Phase_Inc_Frac_B3"                            ;
default_register_descriptions[0x03AC] = "DDC_1_Phase_Inc_Frac_B4"                            ;
default_register_descriptions[0x03AD] = "DDC_1_Phase_Inc_Frac_B5"                            ;
default_register_descriptions[0x03B0] = "DDC_2_Phase_Inc_Frac_A0"                            ;
default_register_descriptions[0x03B1] = "DDC_2_Phase_Inc_Frac_A1"                            ;
default_register_descriptions[0x03B2] = "DDC_2_Phase_Inc_Frac_A2"                            ;
default_register_descriptions[0x03B3] = "DDC_2_Phase_Inc_Frac_A3"                            ;
default_register_descriptions[0x03B4] = "DDC_2_Phase_Inc_Frac_A4"                            ;
default_register_descriptions[0x03B5] = "DDC_2_Phase_Inc_Frac_A5"                            ;
default_register_descriptions[0x03B8] = "DDC_2_Phase_Inc_Frac_B0"                            ;
default_register_descriptions[0x03B9] = "DDC_2_Phase_Inc_Frac_B1"                            ;
default_register_descriptions[0x03BA] = "DDC_2_Phase_Inc_Frac_B2"                            ;
default_register_descriptions[0x03BB] = "DDC_2_Phase_Inc_Frac_B3"                            ;
default_register_descriptions[0x03BC] = "DDC_2_Phase_Inc_Frac_B4"                            ;
default_register_descriptions[0x03BD] = "DDC_2_Phase_Inc_Frac_B5"                            ;
default_register_descriptions[0x03C0] = "DDC_3_Phase_Inc_Frac_A0"                            ;
default_register_descriptions[0x03C1] = "DDC_3_Phase_Inc_Frac_A1"                            ;
default_register_descriptions[0x03C2] = "DDC_3_Phase_Inc_Frac_A2"                            ;
default_register_descriptions[0x03C3] = "DDC_3_Phase_Inc_Frac_A3"                            ;
default_register_descriptions[0x03C4] = "DDC_3_Phase_Inc_Frac_A4"                            ;
default_register_descriptions[0x03C5] = "DDC_3_Phase_Inc_Frac_A5"                            ;
default_register_descriptions[0x03C8] = "DDC_3_Phase_Inc_Frac_B0"                            ;
default_register_descriptions[0x03C9] = "DDC_3_Phase_Inc_Frac_B1"                            ;
default_register_descriptions[0x03CA] = "DDC_3_Phase_Inc_Frac_B2"                            ;
default_register_descriptions[0x03CB] = "DDC_3_Phase_Inc_Frac_B3"                            ;
default_register_descriptions[0x03CC] = "DDC_3_Phase_Inc_Frac_B4"                            ;
default_register_descriptions[0x03CD] = "DDC_3_Phase_Inc_Frac_B5"                            ;
default_register_descriptions[0x0550] = "ADC_test_mode_control"                              ;
default_register_descriptions[0x0551] = "User_Pattern_1_LSB"                                 ;
default_register_descriptions[0x0552] = "User_Pattern_1_MSB"                                 ;
default_register_descriptions[0x0553] = "User_Pattern_2_LSB"                                 ;
default_register_descriptions[0x0554] = "User_Pattern_2_MSB"                                 ;
default_register_descriptions[0x0555] = "User_Pattern_3_LSB"                                 ;
default_register_descriptions[0x0556] = "User_Pattern_3_MSB"                                 ;
default_register_descriptions[0x0557] = "User_Pattern_4_LSB"                                 ;
default_register_descriptions[0x0558] = "User_Pattern_4_MSB"                                 ;
default_register_descriptions[0x0559] = "Output_Mode_Control_1"                              ;
default_register_descriptions[0x055A] = "Output_Mode_Control_2"                              ;
default_register_descriptions[0x0561] = "Output_sample_mode"                                 ;
default_register_descriptions[0x0562] = "Output_overrange_clear"                             ;
default_register_descriptions[0x0563] = "Output_overrange_status"                            ;
default_register_descriptions[0x0564] = "Output_channel_select"                              ;
default_register_descriptions[0x056E] = "PLL_control"                                        ;
default_register_descriptions[0x056F] = "PLL_status"                                         ;
default_register_descriptions[0x0571] = "JESD204B_Link_Control_1"                            ;
default_register_descriptions[0x0572] = "JESD204B_Link_Control_2"                            ;
default_register_descriptions[0x0573] = "JESD204B_Link_Control_3"                            ;
default_register_descriptions[0x0574] = "JESD204B_Link_Control_4"                            ;
default_register_descriptions[0x0578] = "JESD204B_LMFC_offset"                               ;
default_register_descriptions[0x0580] = "JESD204B_device_ident_DID"                          ;
default_register_descriptions[0x0581] = "JESD204B_bank_ident_BID"                            ;
default_register_descriptions[0x0583] = "JESD204B_Lane_Ident_LID0"                           ;
default_register_descriptions[0x0584] = "JESD204B_LID1_conf"                                 ;
default_register_descriptions[0x0585] = "JESD204B_LID2_conf"                                 ;
default_register_descriptions[0x0586] = "JESD204B_LID3_conf"                                 ;
default_register_descriptions[0x058B] = "JESD204B_L"                                         ;
default_register_descriptions[0x058C] = "JESD204B_F"                                         ;
default_register_descriptions[0x058D] = "JESD204B_K"                                         ;
default_register_descriptions[0x058E] = "JESD204B_M"                                         ;
default_register_descriptions[0x058F] = "JESD204B_CS_and_N"                                  ;
default_register_descriptions[0x0590] = "JESD204B_SCV_NP"                                    ;
default_register_descriptions[0x0591] = "JESD204B_JV_S"                                      ;
default_register_descriptions[0x0592] = "JESD204B_HD_CF"                                     ;
default_register_descriptions[0x05A0] = "JESD204B_Checksum_0_cfg"                            ;
default_register_descriptions[0x05A1] = "JESD204B_Checksum_1_cfg"                            ;
default_register_descriptions[0x05A2] = "JESD204B_Checksum_2_cfg"                            ;
default_register_descriptions[0x05A3] = "JESD204B_Checksum_3_cfg"                            ;
default_register_descriptions[0x05B0] = "JESD204B_lane_powerdown"                            ;
default_register_descriptions[0x05B2] = "JESD204B_Lane_Assign1"                              ;
default_register_descriptions[0x05B3] = "JESD204B_Lane_Assign2"                              ;
default_register_descriptions[0x05B5] = "JESD204B_Lane_Assign3"                              ;
default_register_descriptions[0x05B6] = "JESD204B_Lane_Assign4"                              ;
default_register_descriptions[0x05BF] = "SERDOUT_data_invert"                               ;
default_register_descriptions[0x05C0] = "JESD204B_Swing_Adjust_1"                            ;
default_register_descriptions[0x05C1] = "JESD204B_Swing_Adjust_2"                            ;
default_register_descriptions[0x05C2] = "JESD204B_Swing_Adjust_3"                            ;
default_register_descriptions[0x05C3] = "JESD204B_Swing_Adjust_4"                            ;
default_register_descriptions[0x05C4] = "SERDOUT0_preemph_sel"                               ;
default_register_descriptions[0x05C6] = "SERDOUT1_preemph_sel"                               ;
default_register_descriptions[0x05C8] = "SERDOUT2_preemph_sel"                               ;
default_register_descriptions[0x05CA] = "SERDOUT3_preemph_sel"                               ;
default_register_descriptions[0x1222] = "JESD204B_PLL_calibration"                           ;
default_register_descriptions[0x1228] = "JESD204B_PLL_start_up_ctrl"                         ;
default_register_descriptions[0x1262] = "JESD204B_PLL_LOL_bit_ctrl"                          ;
default_register_descriptions[0x0DF8] = "Programmable_filter_control"                        ;
default_register_descriptions[0x0DF9] = "PFILT_gain"                                         ;
    std::ostringstream ostr;
	for (unsigned int i = 0x0E00; i < 0x0E80; i++) {
		ostr.str("");
		ostr << std::hex << "FIR_X_COEFF_" << i << std::dec;
		default_register_descriptions[i] = ostr.str();
	}
	
	for (unsigned int i = 0x0F00; i < 0xF80; i++) {
		ostr.str("");
		ostr << std::hex << "FIR_Y_COEFF_" << i << std::dec;
		default_register_descriptions[i] = ostr.str();
	}
	
		default_register_descriptions[0x0701] = "DC_Offset_Cal_Control_1" ;
		default_register_descriptions[0x073B] = "DC_Offset_Cal_Control_2";
		default_register_descriptions[0x18A6] = "VREF_control";
		default_register_descriptions[0x18E3] = "External_VCM_buffer_control";
		default_register_descriptions[0x18E6] = "Temperature_diode_export";
		default_register_descriptions[0x1908] = "Analog_input_control";
		default_register_descriptions[0x1910] = "Input_full_scale_control";
		default_register_descriptions[0x1A4C] = "Buffer_Control_1";
		default_register_descriptions[0x1A4D] = "Buffer_Control_2";
		default_register_descriptions[0x1B03] = "Buffer_Control_3";
		default_register_descriptions[0x1B08] = "Buffer_Control_4";
		default_register_descriptions[0x1B10] = "Buffer_Control_5";
	
	
	
	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(default_register_descriptions);

	this->set_control_reg_map_desc(default_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << " set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
};
