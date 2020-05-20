/*
 * i2c_device_driver_virtual_uart.cpp
 *
 *  Created on: Feb 20, 2014
 *      Author: yairlinn
 */

#include "i2c_device_driver_virtual_uart.h"

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

register_desc_map_type i2c_device_driver_virtual_uart_register_descriptions;

i2c_device_driver_virtual_uart::i2c_device_driver_virtual_uart() :
		virtual_uart_register_file(), i2c_device_driver()
        {
	i2c_device_driver_virtual_uart_register_descriptions[0x0  ]="PRERlo";
	i2c_device_driver_virtual_uart_register_descriptions[0x1  ]="PRERhi";
	i2c_device_driver_virtual_uart_register_descriptions[0x2  ]="CTR";
	i2c_device_driver_virtual_uart_register_descriptions[0x3  ]="TXR/RXR";
	i2c_device_driver_virtual_uart_register_descriptions[0x4  ]="CR/SR";


		static const unsigned long reg_include_init_array[] = {
				0x0  ,
				0x1  ,
				0x2  ,
				0x3  ,
				0x4
		};
		uart_regfile_single_uart_included_regs_type the_included_regs(reg_include_init_array,reg_include_init_array+sizeof(reg_include_init_array)/sizeof(reg_include_init_array[0]));

		this->set_control_reg_map_desc(i2c_device_driver_virtual_uart_register_descriptions);
		this->set_included_ctrl_regs(the_included_regs);

		dureg(safe_print(std::cout << "i2c_device_driver_virtual_uart set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
}
