/*
 * ad9680_virtual_uart.cpp
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#include "ad9680_virtual_uart.h"
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

unsigned long long ad9680_virtual_uart::read_control_reg(unsigned long address,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return 0;
		}
		return this->ad9680_read(address);
};

void ad9680_virtual_uart::write_control_reg(unsigned long address,
		unsigned long long data,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	this->ad9680_write(address,data);
};



ad9680_virtual_uart::ad9680_virtual_uart(unsigned long current_chipselect_index) :
	virtual_uart_register_file(),
	ad9680_driver(current_chipselect_index) {
	
	
		default_register_descriptions[0x000] = "INTERFACE_cfg_A"                                        ;
		default_register_descriptions[0x001] = "INTERFACE_cfg_B"                                        ;
		default_register_descriptions[0x002] = "DEVICE_cfg"                                             ;
		default_register_descriptions[0x003] = "CHIP_TYPE"                                              ;
		default_register_descriptions[0x004] = "CHIP_ID(low)"                                           ;
		default_register_descriptions[0x005] = "CHIP_ID(high)"                                          ;
		default_register_descriptions[0x006] = "CHIP_GRADE"                                             ;
		default_register_descriptions[0x008] = "Deviceindex"                                            ;
		default_register_descriptions[0x00A] = "Scratchpad"                                             ;
		default_register_descriptions[0x00B] = "SPIrevision"                                            ;
		default_register_descriptions[0x00C] = "VendorID(low)"                                          ;
		default_register_descriptions[0x00D] = "VendorID(high)"                                         ;
		default_register_descriptions[0x015] = "AnalogIn(local)"                                        ;
		default_register_descriptions[0x016] = "Interm(local)"                                          ;
		default_register_descriptions[0x934] = "Incap(local)"                                           ;
		default_register_descriptions[0x018] = "BufferCtrl1(local)"                                     ;
		default_register_descriptions[0x019] = "BufferCtrl2(local)"                                     ;
		default_register_descriptions[0x01A] = "BufferCtrl3(local)"                                     ;
		default_register_descriptions[0x11A] = "BufferCtrl4(local)"                                     ;
		default_register_descriptions[0x935] = "BufferCtrl5(local)"                                     ;
		default_register_descriptions[0x025] = "In_FS_range(local)"                                     ;
		default_register_descriptions[0x030] = "In_FS_Ctrl(local)"                                      ;
		default_register_descriptions[0x024] = "V_1P0Ctrl"                                              ;
		default_register_descriptions[0x028] = "Temperaturediode"                                       ;
		default_register_descriptions[0x03F] = "PDWNSTBYpinCtrl(local)"                                ;
		default_register_descriptions[0x040] = "ChippinCtrl"                                            ;
		default_register_descriptions[0x10B] = "ClkDiv"                                                 ;
		default_register_descriptions[0x10C] = "ClkDivphase(local)"                                     ;
		default_register_descriptions[0x10D] = "ClkDivandSYSREFCtrl"                                    ;
		default_register_descriptions[0x117] = "ClkdelayCtrl"                                           ;
		default_register_descriptions[0x118] = "Clkfinedelay(local)"                                    ;
		default_register_descriptions[0x11C] = "Clkstatus"                                              ;
		default_register_descriptions[0x120] = "SYSREF_pm_Ctrl1"                                        ;
		default_register_descriptions[0x121] = "SYSREF_pm_Ctrl2"                                        ;
		default_register_descriptions[0x123] = "SYSREF_pm_TSdlyCtrl"                                    ;
		default_register_descriptions[0x128] = "SYSREF_pm_Status1"                                      ;
		default_register_descriptions[0x129] = "SYSREF_pm_ClkdivStat"                                   ;
		default_register_descriptions[0x12A] = "SYSREF_pm"                                              ;
		default_register_descriptions[0x1FF] = "Chipsyncmode"                                           ;
		default_register_descriptions[0x200] = "Chipapplicationmode"                                    ;
		default_register_descriptions[0x201] = "Chipdecimationratio"                                    ;
		default_register_descriptions[0x228] = "Customeroffset"                                         ;
		default_register_descriptions[0x245] = "Fastdetect(FD)Ctrl(local)"                              ;
		default_register_descriptions[0x247] = "FDupperThrLSB(local)"                                   ;
		default_register_descriptions[0x248] = "FDupperThrMSB(local)"                                   ;
		default_register_descriptions[0x249] = "FDlowerThrLSB(local)"                                   ;
		default_register_descriptions[0x24A] = "FDlowerThrMSB(local)"                                   ;
		default_register_descriptions[0x24B] = "FDdwelltimeLSB(local)"                                  ;
		default_register_descriptions[0x24C] = "FDdwelltimeMSB(local)"                                  ;
		default_register_descriptions[0x26F] = "SignalMonSynchCtrl"                                     ;
		default_register_descriptions[0x270] = "SignalMonCtrl(local)"                                   ;
		default_register_descriptions[0x271] = "SignalMonPeriodReg0(local)"                             ;
		default_register_descriptions[0x272] = "SignalMonPeriodReg1(local)"                             ;
		default_register_descriptions[0x273] = "SignalMonPeriodReg2(local)"                             ;
		default_register_descriptions[0x274] = "SignalMonresultCtrl(local)"                             ;
		default_register_descriptions[0x275] = "SignalMonResultReg0(local)"                             ;
		default_register_descriptions[0x276] = "SignalMonResultReg1(local)"                             ;
		default_register_descriptions[0x277] = "SignalMonResultReg1(local)"                             ;
		default_register_descriptions[0x278] = "SignalMonperiodcounterresult(local)"                    ;
		default_register_descriptions[0x279] = "SignalMonSPORToverJESD204B"                             ;
		default_register_descriptions[0x27A] = "SPORToverJESD204BInsel(local)"                          ;
		default_register_descriptions[0x300] = "DDCsynchCtrl"                                           ;
		default_register_descriptions[0x310] = "DDC0Ctrl"                                               ;
		default_register_descriptions[0x311] = "DDC0Insel"                                              ;
		default_register_descriptions[0x314] = "DDC0frequencyLSB"                                       ;
		default_register_descriptions[0x315] = "DDC0frequencyMSB"                                       ;
		default_register_descriptions[0x320] = "DDC0phaseLSB"                                           ;
		default_register_descriptions[0x321] = "DDC0phaseMSB"                                           ;
		default_register_descriptions[0x327] = "DDC0Outtestmodesel"                                     ;
		default_register_descriptions[0x330] = "DDC1Ctrl"                                               ;
		default_register_descriptions[0x331] = "DDC1Insel"                                              ;
		default_register_descriptions[0x334] = "DDC1frequencyLSB"                                       ;
		default_register_descriptions[0x335] = "DDC1frequencyMSB"                                       ;
		default_register_descriptions[0x340] = "DDC1phaseLSB"                                           ;
		default_register_descriptions[0x341] = "DDC1phaseMSB"                                           ;
		default_register_descriptions[0x347] = "DDC1Outtestmodesel"                                     ;
		default_register_descriptions[0x350] = "DDC2Ctrl"                                       ;
		default_register_descriptions[0x351] = "DDC2Insel"                                              ;
		default_register_descriptions[0x354] = "DDC2frequencyLSB"                                       ;
		default_register_descriptions[0x355] = "DDC2frequencyMSB"                                       ;
		default_register_descriptions[0x360] = "DDC2phaseLSB"                                           ;
		default_register_descriptions[0x361] = "DDC2phaseMSB"                                           ;
		default_register_descriptions[0x367] = "DDC2Outtestmodesel"                                     ;
		default_register_descriptions[0x370] = "DDC3Ctrl"                                               ;
		default_register_descriptions[0x371] = "DDC3Insel"                                              ;
		default_register_descriptions[0x374] = "DDC3frequencyLSB"                                       ;
		default_register_descriptions[0x375] = "DDC3frequencyMSB"                                       ;
		default_register_descriptions[0x380] = "DDC3phaseLSB"                                           ;
		default_register_descriptions[0x381] = "DDC3phaseMSB"                                           ;
		default_register_descriptions[0x387] = "DDC3Outtestmodesel"                                     ;
		default_register_descriptions[0x550] = "ADCtestmodes(local)"                                    ;
		default_register_descriptions[0x551] = "UserPattern1LSB"                                        ;
		default_register_descriptions[0x552] = "UserPattern1MSB"                                        ;
		default_register_descriptions[0x553] = "UserPattern2LSB"                                        ;
		default_register_descriptions[0x554] = "UserPattern2MSB"                                        ;
		default_register_descriptions[0x555] = "UserPattern3LSB"                                        ;
		default_register_descriptions[0x556] = "UserPattern3MSB"                                        ;
		default_register_descriptions[0x557] = "UserPattern4LSB"                                        ;
		default_register_descriptions[0x558] = "UserPattern4MSB"                                        ;
		default_register_descriptions[0x559] = "OutModeCtrl1"                                           ;
		default_register_descriptions[0x55A] = "OutModeCtrl2"                                           ;
		default_register_descriptions[0x561] = "Outmode"                                                ;
		default_register_descriptions[0x562] = "Outoverrange(OR)clear"                                  ;
		default_register_descriptions[0x563] = "OutORstatus"                                            ;
		default_register_descriptions[0x564] = "Outchannelselect"                                       ;
		default_register_descriptions[0x56E] = "JESD204BlanerateCtrl"                                   ;
		default_register_descriptions[0x56F] = "JESD204BPLLlockstatus"                                  ;
		default_register_descriptions[0x570] = "JESD204Bquickcfguration"                               ;
		default_register_descriptions[0x571] = "JESD204BLinkModeCtrl1"                                  ;
		default_register_descriptions[0x572] = "JESD204BLinkModeCtrl2"                                  ;
		default_register_descriptions[0x573] = "JESD204BLinkModeCtrl3"                                  ;
		default_register_descriptions[0x574] = "JESD204BLinkModeCtrl4"                                  ;
		default_register_descriptions[0x578] = "JESD204BLMFCoffset"                                     ;
		default_register_descriptions[0x580] = "JESD204BDIDcfg"                                         ;
		default_register_descriptions[0x581] = "JESD204BBIDcfg"                                         ;
		default_register_descriptions[0x583] = "JESD204BLIDcfg1"                                        ;
		default_register_descriptions[0x584] = "JESD204BLIDcfg2"                                        ;
		default_register_descriptions[0x585] = "JESD204BLIDcfg3"                                        ;
		default_register_descriptions[0x586] = "JESD204BLIDcfg4"                                        ;
		default_register_descriptions[0x58B] = "JESD204BparametersSCRL"                                ;
		default_register_descriptions[0x58C] = "JESD204BFcfg"                                           ;
		default_register_descriptions[0x58D] = "JESD204BKcfg"                                           ;
		default_register_descriptions[0x58E] = "JESD204BMcfg"                                           ;
		default_register_descriptions[0x58F] = "JESD204BCSNcfg"                                        ;
		default_register_descriptions[0x590] = "JESD204BN_prime_cfg"                                    ;
		default_register_descriptions[0x591] = "JESD204BScfg"                                           ;
		default_register_descriptions[0x592] = "JESD204BHDandCFcfg"                                     ;
		default_register_descriptions[0x5A0] = "JESD204BCHKSUM0"                                        ;
		default_register_descriptions[0x5A1] = "JESD204BCHKSUM1"                                        ;
		default_register_descriptions[0x5A2] = "JESD204BCHKSUM2"                                        ;
		default_register_descriptions[0x5A3] = "JESD204BCHKSUM3"                                        ;
		default_register_descriptions[0x5B0] = "JESD204Blanepowerdown"                                  ;
		default_register_descriptions[0x5B2] = "JESD204BSERDOUT0_pm"                                    ;
		default_register_descriptions[0x5B3] = "JESD204BSERDOUT1_pm"                                    ;
		default_register_descriptions[0x5B5] = "JESD204BSERDOUT2_pm"                                    ;
		default_register_descriptions[0x5B6] = "JESD204BSERDOUT3_pm"                                    ;
		default_register_descriptions[0x5BF] = "JESDserdriveadj"                                        ;
		default_register_descriptions[0x5C1] = "Deemphselect"                                           ;
		default_register_descriptions[0x5C2] = "DeemphSERDOUT0_pm"                                      ;
		default_register_descriptions[0x5C3] = "DeemphSERDOUT1_pm"                                      ;
		default_register_descriptions[0x5C4] = "DeemphSERDOUT2_pm"                                      ;
		default_register_descriptions[0x5C5] = "DeemphSERDOUT3_pm"                                      ;
	
	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(default_register_descriptions);

	this->set_control_reg_map_desc(default_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << " set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
};
