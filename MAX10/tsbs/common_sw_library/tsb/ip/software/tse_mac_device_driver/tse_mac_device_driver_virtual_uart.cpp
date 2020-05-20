/*
 * tse_mac_device_driver_virtual_uart.cpp
 *
 *  Created on: Feb 12, 2014
 *      Author: yairlinn
 */

#include "tse_mac_device_driver_virtual_uart.h"

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

register_desc_map_type default_tse_mac_device_driver_register_descriptions;

tse_mac_device_driver_virtual_uart::tse_mac_device_driver_virtual_uart(int the_enable_phy_register_tunneling) :
		virtual_uart_register_file()
        {
	default_tse_mac_device_driver_register_descriptions[ 0   >>2] = "REV"                                  ;
	default_tse_mac_device_driver_register_descriptions[ 0x4 >>2] ="SCRATCH"                               ;
	default_tse_mac_device_driver_register_descriptions[ 0x8 >>2] ="CMD_CONFIG"                            ;
	default_tse_mac_device_driver_register_descriptions[ 0xC >>2] ="MAC_0"                                 ;
	default_tse_mac_device_driver_register_descriptions[ 0x10>>2] = "MAC_1"                                ;
	default_tse_mac_device_driver_register_descriptions[ 0x14>>2] = "FRM_LENGTH"                           ;
	default_tse_mac_device_driver_register_descriptions[ 0x18>>2] = "PAUSE_QUANT"                          ;
	default_tse_mac_device_driver_register_descriptions[ 0x1C>>2] = "RX_SECTION_EMPTY"                     ;
	default_tse_mac_device_driver_register_descriptions[ 0x20>>2] = "RX_SECTION_FULL"                      ;
	default_tse_mac_device_driver_register_descriptions[ 0x24>>2] = "TX_SECTION_EMPTY"                     ;
	default_tse_mac_device_driver_register_descriptions[ 0x28>>2] = "TX_SECTION_FULL"                      ;
	default_tse_mac_device_driver_register_descriptions[ 0x2c>>2] = "RX_ALMOST_EMPTY"                      ;
	default_tse_mac_device_driver_register_descriptions[ 0x30>>2] = "RX_ALMOST_FULL"                       ;
	default_tse_mac_device_driver_register_descriptions[ 0x34>>2] = "TX_ALMOST_EMPTY"                      ;
	default_tse_mac_device_driver_register_descriptions[ 0x38>>2] = "TX_ALMOST_FULL"                       ;
	default_tse_mac_device_driver_register_descriptions[ 0x3c>>2] = "MDIO_ADDR0"                           ;
	default_tse_mac_device_driver_register_descriptions[ 0x40>>2] = "MDIO_ADDR1"                           ;
	default_tse_mac_device_driver_register_descriptions[ 0x58>>2] = "REG_STAT"                             ;
	default_tse_mac_device_driver_register_descriptions[ 0x5c>>2] = "TX_IPG_LENGTH"                        ;
	default_tse_mac_device_driver_register_descriptions[ 0x60>>2] = "A_MACID_1"                            ;
	default_tse_mac_device_driver_register_descriptions[ 0x64>>2] = "A_MACID_2"                            ;
	default_tse_mac_device_driver_register_descriptions[ 0x68>>2] = "A_FRAMES_TX_OK"                       ;
	default_tse_mac_device_driver_register_descriptions[ 0x6c>>2] = "A_FRAMES_RX_OK"                       ;
	default_tse_mac_device_driver_register_descriptions[ 0x70>>2] = "A_FRAME_CHECK_SEQ_ERRS"               ;
	default_tse_mac_device_driver_register_descriptions[ 0x74>>2] = "A_ALIGNMENT_ERRS"                     ;
	default_tse_mac_device_driver_register_descriptions[ 0x78>>2] = "A_OCTETS_TX_OK"                       ;
	default_tse_mac_device_driver_register_descriptions[ 0x7c>>2] = "A_OCTETS_RX_OK"                       ;
	default_tse_mac_device_driver_register_descriptions[ 0x80>>2] = "A_TX_PAUSE_MAC_CTRL_FRAMES"           ;
	default_tse_mac_device_driver_register_descriptions[ 0x84>>2] = "A_RX_PAUSE_MAC_CTRL_FRAMES"           ;
	default_tse_mac_device_driver_register_descriptions[ 0x88>>2] = "IF_IN_ERRORS"                         ;
	default_tse_mac_device_driver_register_descriptions[ 0x8c>>2] = "IF_OUT_ERRORS"                        ;
	default_tse_mac_device_driver_register_descriptions[ 0x90>>2] = "IF_IN_UCAST_PKTS"                     ;
	default_tse_mac_device_driver_register_descriptions[ 0x94>>2] = "IF_IN_MULTICAST_PKTS"                 ;
	default_tse_mac_device_driver_register_descriptions[ 0x98>>2] = "IF_IN_BROADCAST_PKTS"                 ;
	default_tse_mac_device_driver_register_descriptions[ 0x9C>>2] = "IF_OUT_DISCARDS"                      ;
	default_tse_mac_device_driver_register_descriptions[ 0xA0>>2] = "IF_OUT_UCAST_PKTS"                    ;
	default_tse_mac_device_driver_register_descriptions[ 0xA4>>2] = "IF_OUT_MULTICAST_PKTS"                ;
	default_tse_mac_device_driver_register_descriptions[ 0xA8>>2] = "IF_OUT_BROADCAST_PKTS"                ;
	default_tse_mac_device_driver_register_descriptions[ 0xAC>>2] = "STATS_DROP_EVENTS"                    ;
	default_tse_mac_device_driver_register_descriptions[ 0xB0>>2] = "STATS_OCTETS"                         ;
	default_tse_mac_device_driver_register_descriptions[ 0xB4>>2] = "STATS_PKTS"                           ;
	default_tse_mac_device_driver_register_descriptions[ 0xB8>>2] = "STATS_UNDERSIZE_PKTS"                 ;
	default_tse_mac_device_driver_register_descriptions[ 0xBC>>2] = "STATS_OVERSIZE_PKTS"                  ;
	default_tse_mac_device_driver_register_descriptions[ 0xC0>>2] = "STATS_PKTS_64_OCTETS"                 ;
	default_tse_mac_device_driver_register_descriptions[ 0xC4>>2] = "STATS_PKTS_65_TO_127_OCTETS"          ;
	default_tse_mac_device_driver_register_descriptions[ 0xC8>>2] = "STATS_PKTS_128_TO_255_OCTETS"         ;
	default_tse_mac_device_driver_register_descriptions[ 0xCC>>2] = "STATS_PKTS_256_TO_511_OCTETS"         ;
	default_tse_mac_device_driver_register_descriptions[ 0xD0>>2] = "STATS_PKTS_512_TO_1023_OCTETS"        ;
	default_tse_mac_device_driver_register_descriptions[ 0xD4>>2] = "STATS_PKTS_1024_TO_1518_OCTETS"       ;
	default_tse_mac_device_driver_register_descriptions[ 0xD8>>2] = "STATS_PKTS_1519_TO_X_OCTETS"          ;
	default_tse_mac_device_driver_register_descriptions[ 0xDC>>2] = "ETHER_STATS_JABBERS"                  ;
	default_tse_mac_device_driver_register_descriptions[ 0xE0>>2] = "ETHER_STATS_FRAGMENTS"                ;
	default_tse_mac_device_driver_register_descriptions[ 0xE8>>2] = "TX_CMD_STAT"                          ;
	default_tse_mac_device_driver_register_descriptions[ 0xEC>>2] = "RX_CMD_STAT"                          ;

	enable_phy_register_tunneling = the_enable_phy_register_tunneling;

	for (int i = 0; i < 32; i++) {
		std::ostringstream legend;
		legend << i;
	    default_tse_mac_device_driver_register_descriptions[ 0x80 + i]  = std::string("MDIO_SPACE0_") + legend.str();
	    if (enable_phy_register_tunneling) {
	       default_tse_mac_device_driver_register_descriptions[ 0xA0 + i]  = std::string("MDIO_SPACE1_") + legend.str();
	    }
	}

	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(default_tse_mac_device_driver_register_descriptions);

	this->set_control_reg_map_desc(default_tse_mac_device_driver_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << "tse_mac_device_driver_virtual_uart set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
}
