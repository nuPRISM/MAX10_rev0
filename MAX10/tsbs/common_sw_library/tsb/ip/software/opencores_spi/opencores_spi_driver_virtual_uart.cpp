/*
 * opencores_spi_driver_virtual_uart.cpp
 *
 *  Created on: Feb 12, 2014
 *      Author: yairlinn
 */

#include "opencores_spi_driver_virtual_uart.h"
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

register_desc_map_type default_opencores_spi_register_descriptions;

opencores_spi_driver_virtual_uart::opencores_spi_driver_virtual_uart() :
		virtual_uart_register_file()
        {
	default_opencores_spi_register_descriptions[0x0  ]="Tx0/Rx0";
	default_opencores_spi_register_descriptions[0x1  ]="Tx1/Rx1";
	default_opencores_spi_register_descriptions[0x2  ]="Tx2/Rx2";
	default_opencores_spi_register_descriptions[0x3  ]="Tx3/Rx3";
	default_opencores_spi_register_descriptions[0x4  ]="CTRL";
	default_opencores_spi_register_descriptions[0x5  ]="DIVIDER";
	default_opencores_spi_register_descriptions[0x6 ]="CS_CONTROL";

		static const unsigned long reg_include_init_array[] = {
				0x0  ,
				0x1  ,
				0x2  ,
				0x3  ,
				0x4  ,
				0x5  ,
				0x6
		};
		uart_regfile_single_uart_included_regs_type the_included_regs(reg_include_init_array,reg_include_init_array+sizeof(reg_include_init_array)/sizeof(reg_include_init_array[0]));

		this->set_control_reg_map_desc(default_opencores_spi_register_descriptions);
		this->set_included_ctrl_regs(the_included_regs);

		dureg(safe_print(std::cout << "opencores_spi_driver_virtual_uart set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
}
