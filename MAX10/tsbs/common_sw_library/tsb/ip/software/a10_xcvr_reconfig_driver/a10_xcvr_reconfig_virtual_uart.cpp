/*
 * a10_xcvr_reconfig_virtual_uart.cpp
 *
 *  Created on: Feb 20, 2014
 *      Author: yairlinn
 */

#include "a10_xcvr_reconfig_virtual_uart.h"


#include "basedef.h"
#include <sstream>
#include <iostream>
#include <string>
#include <stdio.h>
#include "linnux_utils.h"
#include "debug_macro_definitions.h"
#include <vector>
extern "C" {
#include <xprintf.h>
}

#ifndef A10_XCVR_RECONFIG_DEBUG
#define A10_XCVR_RECONFIG_DEBUG (0)
#endif


#define u(x) do { if (A10_XCVR_RECONFIG_DEBUG) {x;} } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if (A10_XCVR_RECONFIG_DEBUG) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} } while (0)

register_desc_map_type default_a10_xcvr_reconfig_register_descriptions;

a10_xcvr_reconfig_virtual_uart::a10_xcvr_reconfig_virtual_uart() :
		virtual_uart_register_file()
        {
	default_a10_xcvr_reconfig_register_descriptions [ 0x000 ] ="arbiter_ctrl_pma"                        ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x006 ] ="tx_pma_data_sel"                         ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x008 ] ="PRBS_Square_Wave_Block_Select"           ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x00A ] ="prbs_clken_rx"                           ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x00B ] ="rx_prbs_mask"                            ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x00C ] ="prbs9_dwidth_rx"                         ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x100 ] ="rx_cal_en"                               ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x105 ] ="pre_emp_switching_ctrl_1st_post_tap"     ;          
	default_a10_xcvr_reconfig_register_descriptions [ 0x106 ] ="pre_emp_switching_ctrl_2nd_post_tap"     ;          
	default_a10_xcvr_reconfig_register_descriptions [ 0x107 ] ="pre_emp_switching_ctrl_pre_tap_1t"       ;          
	default_a10_xcvr_reconfig_register_descriptions [ 0x108 ] ="pre_emp_switching_ctrl_pre_tap_2t"       ;          
	default_a10_xcvr_reconfig_register_descriptions [ 0x109 ] ="vod_output_swing_ctrl"                   ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x110 ] ="ser_mode"                                ;
    default_a10_xcvr_reconfig_register_descriptions [ 0x11B ]= "one_stage_enable"                        ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x11C ]= "eq_dc_gain_trim"                         ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x11D ]= "loopback_mode_diag_lp_en"                ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x11F ]= "eq_bw_sel"                               ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x132 ]= "reverse_serial_loopback"                 ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x137 ]= "diag_loopback_enable"                    ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x13C ]= "reverse_serial_loopback_mode"            ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x142 ]= "loopback_mode"                           ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x149 ]= "adp_adapt_control_sel"                   ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x14F ]= "adp_dfe_fxtap1"                          ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x150 ]= "adp_dfe_fxtap2"                          ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x151 ]= "adp_dfe_fxtap3"                          ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x152 ]= "adp_dfe_fxtap4"                          ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x153 ]= "adp_dfe_fxtap5"                          ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x154 ]= "adp_dfe_fxtap6"                          ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x155 ]= "adp_dfe_fxtap7"                          ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x157 ]= "adp_dfe_fxtap8"                          ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x158 ]= "adp_dfe_fxtap9"                          ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x159 ]= "adp_dfe_fxtap10"                         ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x15A ]= "adp_dfe_fxtap11"                         ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x160 ]= "adp_vga_sel"                             ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x166 ]= "rate_sw_flag"                            ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x166 ]= "adp_ctle_eqz_1s_sel"                     ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x167 ]= "adp_ctle_acgain_4s"                      ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x176 ]= "testmux"                                 ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x177 ]= "adapt_done"                              ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x200 ]= "IP_Identifier"                           ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x204 ]= "Status_Register_Ena"                     ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x205 ]= "Control_Register_Ena"                    ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x210 ]= "Num_Channels"                            ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x211 ]= "Channel_Number"                          ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x212 ]= "Duplex"                                  ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x213 ]= "PRBS_Soft_Ena"                           ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x214 ]= "ODI_Accel_Logic_Ena"                     ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x280 ]= "rx_is_lockedtodata"                      ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x281 ]= "tx_cal_busy"                             ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x2E0 ]= "set_rx_locktodata"                       ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x2E1 ]= "rx_seriallpbken"                         ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x2E1 ]= "rx_seriallpbken"                         ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x2E2 ]= "override_tx_digitalreset"                ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x300 ]= "Counter_enable"                          ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x300 ]= "Snapshot"                                ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x300 ]= "PRBS_Done"                               ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x301 ]= "Accum_error_cnt_7_0"                     ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x302 ]= "Accum_error_cnt_15_8"                    ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x303 ]= "Accum_error_cnt_23_16"                   ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x304 ]= "Accum_error_cnt_31_24"                   ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x305 ]= "Accum_error_cnt_39_32"                   ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x306 ]= "Accum_error_cnt_47_40"                   ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x307 ]= "Accum_error_cnt_49_48"                   ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x30D ]= "Accum_bit_cnt_7_0"                       ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x30E ]= "Accum_bit_cnt_15_8"                      ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x30F ]= "Accum_bit_cnt_23_16"                     ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x310 ]= "Accum_bit_cnt_31_24"                     ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x311 ]= "Accum_bit_cnt_39_32"                     ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x312 ]= "Accum_bit_cnt_47_40"                     ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x313 ]= "Accum_bit_cnt_49_48"                     ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x340 ]= "cfg_sel"                                 ;
	default_a10_xcvr_reconfig_register_descriptions [ 0x341 ]= "rcfg_busy"                               ;
	
	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(default_a10_xcvr_reconfig_register_descriptions);

	this->set_control_reg_map_desc(default_a10_xcvr_reconfig_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << "a10_xcvr_reconfig_virtual_uart set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
}
