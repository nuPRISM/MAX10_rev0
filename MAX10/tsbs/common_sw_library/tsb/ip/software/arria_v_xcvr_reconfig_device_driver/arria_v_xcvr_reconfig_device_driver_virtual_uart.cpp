/*
 * arria_v_xcvr_reconfig_device_driver_virtual_uart.cpp
 *
 *  Created on: Feb 20, 2014
 *      Author: yairlinn
 */

#include "arria_v_xcvr_reconfig_device_driver_virtual_uart.h"

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

register_desc_map_type default_arria_v_xcvr_reconfig_device_driver_register_descriptions;

arria_v_xcvr_reconfig_device_driver_virtual_uart::arria_v_xcvr_reconfig_device_driver_virtual_uart() :
		virtual_uart_register_file()
        {
	// All values from Altera Transceiver Phy IP Core User Guide UG-01080 2013.12.20 Chapter 16


	    //default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x00  ]="VOD";
		//default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x01  ]="Pre-emphasis pre-tap";
		//default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x02  ]="Pre-emphasis first post-tap";
		//default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x03  ]="Pre-emphasis second post-tap";
	//default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x10  ]="RX equalization DC gain";
		//default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x11 ]="RX equalization control";
		//default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x20  ]="Pre-CDR Reverse Serial Loopback";
		//default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x21 ]="Post-CDR Reverse Serial Loopback";

    default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x08  ]="PMAA logical channel number";
    default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x09  ]="PMAA physical channel address";
    default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x0A  ]="PMAA control and status";
    default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x0B  ]="PMAA pma offset";
    default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x0C  ]="PMAA data";

	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x10  ]="EyeQ logical channel number";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x11 ] ="EyeQ physical channel address";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x12 ] ="EyeQ control and status";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x13 ] ="EyeQ offset";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x14 ] ="EyeQ data";

	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x18 ]="DFE logical channel number";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x19 ]="DFE physical channel address";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x1A ]="DFE control and status";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x1B ]="DFE offset";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x1C ]="DFE data";


	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x28 ]="AEQ logical channel number";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x29 ]="AEQ physical channel address";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x2A ]="AEQ control and status";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x2B ]="AEQ offset";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x2C ]="AEQ data";


	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x30 ]="ATX logical channel number";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x32 ]="ATX control and status";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x33 ]="ATX offset";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x34 ]="ATX data";

	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x38 ]="STRM logical channel number";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x39 ]="STRM physical channel address";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x3A ]="STRM control and status";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x3B ]="STRM offset";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x3C ]="STRM data";


	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x40 ]="RECONF logical channel number";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x41 ]="RECONF physical channel address";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x42 ]="RECONF control and status";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x43 ]="RECONF offset";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x44 ]="RECONF data";


	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x48 ]="DCD logical channel number";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x49 ]="DCD physical channel address";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x4B ]="DCD offset";
	default_arria_v_xcvr_reconfig_device_driver_register_descriptions[0x4C ]="DCD data";


		static const unsigned long reg_include_init_array[] = {
				0x08,
				0x09,
				0x0A,
				0x0B,
				0x0C,
				0x10,
				0x11,
				0x12,
				0x13,
				0x14,
				0x18,
				0x19,
				0x1A,
				0x1B,
				0x1C,
				0x28,
				0x29,
				0x2A,
				0x2B,
				0x2C,
				0x30,
				0x32,
				0x33,
				0x34,
				0x38,
				0x39,
				0x3A,
				0x3B,
				0x3C,
				0x40,
				0x41,
				0x42,
				0x43,
				0x44,
				0x48,
				0x49,
				0x4B,
				0x4C

		};

		uart_regfile_single_uart_included_regs_type the_included_regs(reg_include_init_array,reg_include_init_array+sizeof(reg_include_init_array)/sizeof(reg_include_init_array[0]));

		this->set_control_reg_map_desc(default_arria_v_xcvr_reconfig_device_driver_register_descriptions);
		this->set_included_ctrl_regs(the_included_regs);

		dureg(safe_print(std::cout << "arria_v_xcvr_reconfig_device_driver_virtual_uart set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
}
