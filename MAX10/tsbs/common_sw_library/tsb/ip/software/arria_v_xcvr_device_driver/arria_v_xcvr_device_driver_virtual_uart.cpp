/*
 * arria_v_xcvr_device_driver_virtual_uart.cpp
 *
 *  Created on: Feb 12, 2014
 *      Author: yairlinn
 */

#include "arria_v_xcvr_device_driver_virtual_uart.h"

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

register_desc_map_type default_arria_v_xcvr_device_driver_register_descriptions;

arria_v_xcvr_device_driver_virtual_uart::arria_v_xcvr_device_driver_virtual_uart() :
		virtual_uart_register_file()
        {
	default_arria_v_xcvr_device_driver_register_descriptions[0x22  ]="pm_tx_pll_is_locked";
	default_arria_v_xcvr_device_driver_register_descriptions[0x41  ]="reset_ch_bitmask";
	default_arria_v_xcvr_device_driver_register_descriptions[0x42  ]="reset_ctrl_status";
	default_arria_v_xcvr_device_driver_register_descriptions[0x44  ]="reset_fine_control";
	default_arria_v_xcvr_device_driver_register_descriptions[0x61  ]="phy_serial_loopback";
	default_arria_v_xcvr_device_driver_register_descriptions[0x63  ]="pma_rx_signaldetect";
	default_arria_v_xcvr_device_driver_register_descriptions[0x64 ]="pma_rx_set_locktodata";
	default_arria_v_xcvr_device_driver_register_descriptions[0x65 ]="pma_rx_set_locktoref";
	default_arria_v_xcvr_device_driver_register_descriptions[0x66 ]="pma_rx_is_lockedtodata";
	default_arria_v_xcvr_device_driver_register_descriptions[0x67 ]="pma_rx_is_lockedtoref";
	default_arria_v_xcvr_device_driver_register_descriptions[0x80 ]="lane_or_group_number";
	default_arria_v_xcvr_device_driver_register_descriptions[0x81 ]="rx_bitsSlipAndPhComp";
	default_arria_v_xcvr_device_driver_register_descriptions[0x82 ]="txPhaseCompFifoErr";
	default_arria_v_xcvr_device_driver_register_descriptions[0x83 ]="txBitSlipInvPolarity";
	default_arria_v_xcvr_device_driver_register_descriptions[0x84 ]="RxInvPolAndBitSlip";
	default_arria_v_xcvr_device_driver_register_descriptions[0x85 ]="RxBitSlip";

		static const unsigned long reg_include_init_array[] = {
				0x22 ,
				0x41 ,
				0x42 ,
				0x44 ,
				0x61 ,
				0x63 ,
				0x64 ,
				0x65 ,
				0x66 ,
				0x67 ,
				0x80 ,
				0x81 ,
				0x82 ,
				0x83 ,
				0x84 ,
				0x85
		};
		uart_regfile_single_uart_included_regs_type the_included_regs(reg_include_init_array,reg_include_init_array+sizeof(reg_include_init_array)/sizeof(reg_include_init_array[0]));

		this->set_control_reg_map_desc(default_arria_v_xcvr_device_driver_register_descriptions);
		this->set_included_ctrl_regs(the_included_regs);

		dureg(safe_print(std::cout << "arria_v_xcvr_device_driver_virtual_uart set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
}
