/*
 * mpfe_virtual_uart.cpp
 *
 *  Created on: Nov 20, 2014
 *      Author: yairlinn
 */

#include "mpfe_virtual_uart.h"

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

using namespace std;
#define u(x) do { if (UART_REG_DEBUG) {x;} } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if (UART_REG_DEBUG) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} } while (0)

register_desc_map_type default_mpfe_inserter_device_driver_register_descriptions;
unsigned int mpfe_virtual_uart::per_slave_offset(unsigned int slave_num) {
	return (0x10+(0x8*slave_num));
}

mpfe_virtual_uart::mpfe_virtual_uart(unsigned int numslaves) :
		virtual_uart_register_file()
        {

	   uart_regfile_single_uart_included_regs_type the_included_regs(0);
	   default_mpfe_inserter_device_driver_register_descriptions[ 0x0 ] = "clr_counters";
	   default_mpfe_inserter_device_driver_register_descriptions[ 0x1 ] = "master_wait_cnt";
	   default_mpfe_inserter_device_driver_register_descriptions[ 0x2 ] = "master_read_cnt";
	   default_mpfe_inserter_device_driver_register_descriptions[ 0x3 ] = "master_write_cnt";
	   the_included_regs.push_back(0);
	   the_included_regs.push_back(1);
	   the_included_regs.push_back(2);
	   the_included_regs.push_back(3);

		for (unsigned int i = 0; i < numslaves; i++) {
			unsigned int current_slave_base_addr = per_slave_offset(i);
			ostringstream tmpstr1;
			ostringstream tmpstr2;
			ostringstream tmpstr3;
			ostringstream tmpstr4;
			ostringstream tmpstr5;

			tmpstr1 << "slv_grant_cnt_" << i;
			tmpstr2 << "slv_write_cnt_" << i;
			tmpstr3 << "slv_read_cnt_" << i;
			tmpstr4 << "slv_worst_wait_" << i;
			tmpstr5 << "slv_total_wait_" << i;
			default_mpfe_inserter_device_driver_register_descriptions[ current_slave_base_addr+0x0 ] = tmpstr1.str()                                 ;
			default_mpfe_inserter_device_driver_register_descriptions[ current_slave_base_addr+0x1 ] = tmpstr2.str()                       ;
			default_mpfe_inserter_device_driver_register_descriptions[ current_slave_base_addr+0x2 ] = tmpstr3.str()                           ;
			default_mpfe_inserter_device_driver_register_descriptions[ current_slave_base_addr+0x3 ] = tmpstr4.str()                                 ;   //(mac_src[47:16]) :
			default_mpfe_inserter_device_driver_register_descriptions[ current_slave_base_addr+0x4 ] = tmpstr5.str()                                ;   //({{16{1'b0}}, mac_src[15:0]}) :
			the_included_regs.push_back(current_slave_base_addr+0x0);
			the_included_regs.push_back(current_slave_base_addr+0x1);
			the_included_regs.push_back(current_slave_base_addr+0x2);
			the_included_regs.push_back(current_slave_base_addr+0x3);
			the_included_regs.push_back(current_slave_base_addr+0x4);
		}


		this->set_control_reg_map_desc(default_mpfe_inserter_device_driver_register_descriptions);
		this->set_included_ctrl_regs(the_included_regs);

		dureg(safe_print(std::cout << "mpfe_virtual_uart set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
}

