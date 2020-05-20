/*
 * emif_diag_virtual_uart.cpp
 *
 *  Created on: Feb 12, 2014
 *      Author: yairlinn
 */

#include "emif_diag_virtual_uart.h"

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

register_desc_map_type default_emif_diag_device_driver_register_descriptions;

emif_diag_device_driver_virtual_uart::emif_diag_device_driver_virtual_uart() :
		virtual_uart_register_file()
        {
	default_emif_diag_device_driver_register_descriptions[ 0x1  ] = "Monitor_Type"                                  ;
	default_emif_diag_device_driver_register_descriptions[ 0x2  ] ="Monitor_Version"                               ;
	default_emif_diag_device_driver_register_descriptions[ 0x8  ] ="RST_CTRL_AND_STATUS"                            ;
	default_emif_diag_device_driver_register_descriptions[ 0x10 ] ="ADDR_AND_DATA_WIDTHS"                                 ;
	default_emif_diag_device_driver_register_descriptions[ 0x11 ] = "BYTEEN_AND_BURST_WIDTH"                                ;
	default_emif_diag_device_driver_register_descriptions[ 0x14 ] = "CLK_CYCLE_COUNT"                           ;
	default_emif_diag_device_driver_register_descriptions[ 0x18 ] = "TRANSFER_CNT"                          ;
	default_emif_diag_device_driver_register_descriptions[ 0x1C ] = "WRITE_COUNTER"                     ;
	default_emif_diag_device_driver_register_descriptions[ 0x20 ] = "READ_COUNTER"                      ;
	default_emif_diag_device_driver_register_descriptions[ 0x24 ] = "READTOTAL_COUNTER"                     ;
	default_emif_diag_device_driver_register_descriptions[ 0x28 ] = "NTC_WAITREQUEST"                      ;
	default_emif_diag_device_driver_register_descriptions[ 0x2c ] = "NTC_NOREADDATAVALID"                      ;
	default_emif_diag_device_driver_register_descriptions[ 0x30 ] = "NTC_MASTER_WRITE_IDLE_COUNTER"                       ;
	default_emif_diag_device_driver_register_descriptions[ 0x34 ] = "NTC_MASTER_IDLE_COUNTER"                      ;
	default_emif_diag_device_driver_register_descriptions[ 0x40 ] = "READ_LATENCY_MIN"                           ;
	default_emif_diag_device_driver_register_descriptions[ 0x44 ] = "READ_LATENCY_MAX"                           ;
	default_emif_diag_device_driver_register_descriptions[ 0x48 ] = "READ_LATENCY_TOTAL_31_0"                             ;
	default_emif_diag_device_driver_register_descriptions[ 0x49 ] = "READ_LATENCY_TOTAL_63_32"                        ;
	default_emif_diag_device_driver_register_descriptions[ 0x50 ] = "ILLEGAL_COMMAND"                            ;

	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(default_emif_diag_device_driver_register_descriptions);

	this->set_control_reg_map_desc(default_emif_diag_device_driver_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << "emif_diag_device_driver_virtual_uart set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
}
