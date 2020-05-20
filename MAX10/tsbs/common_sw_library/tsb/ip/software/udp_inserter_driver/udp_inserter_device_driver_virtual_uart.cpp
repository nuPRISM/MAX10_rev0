/*
 * udp_inserter_device_driver_virtual_uart.cpp
 *
 *  Created on: Feb 20, 2014
 *      Author: yairlinn
 */

#include "udp_inserter_device_driver_virtual_uart.h"


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

register_desc_map_type default_udp_inserter_device_driver_register_descriptions;

udp_inserter_device_driver_virtual_uart::udp_inserter_device_driver_virtual_uart() :
		virtual_uart_register_file()
        {
	default_udp_inserter_device_driver_register_descriptions[ 0x0 ] = "err/run/go"                                  ;   //({{29{1'b0}}, error_bit, running_bit, go_bit}) :
	default_udp_inserter_device_driver_register_descriptions[ 0x1 ] = "mac_dst(47:16)"                               ;   //(mac_dst[47:16]) :
	default_udp_inserter_device_driver_register_descriptions[ 0x2 ] = "mac_dst(15:0)"                            ;   //({{16{1'b0}}, mac_dst[15:0]}) :
	default_udp_inserter_device_driver_register_descriptions[ 0x3 ] = "mac_src(47:16)"                                 ;   //(mac_src[47:16]) :
	default_udp_inserter_device_driver_register_descriptions[ 0x4 ] = "mac_src(15:0)"                                ;   //({{16{1'b0}}, mac_src[15:0]}) :
	default_udp_inserter_device_driver_register_descriptions[ 0x5 ] = "ip_src_addr"                           ;   //(ip_src_addr) :
	default_udp_inserter_device_driver_register_descriptions[ 0x6 ] = "ip_dst_addr"                          ;   //(ip_dst_addr) :
	default_udp_inserter_device_driver_register_descriptions[ 0x7 ] = "src_port/dst_port"                    ;   //({udp_src_port, udp_dst_port}) :
	default_udp_inserter_device_driver_register_descriptions[ 0x8 ] = "packet_count"                         ;   //(packet_count) :
	default_udp_inserter_device_driver_register_descriptions[ 0x9 ] = "state"                                ;   //(state) :
	default_udp_inserter_device_driver_register_descriptions[ 0xA ] = "pipe_src"                             ;   //{pipe_src0_ready,pipe_src0_valid,pipe_src0_startofpacket,pipe_src0_endofpacket, pipe_src0_empty} :
	default_udp_inserter_device_driver_register_descriptions[ 0xB ] = "aso_src"                              ;   //{aso_src0_ready,aso_src0_valid,aso_src0_startofpacket,aso_src0_endofpacket, aso_src0_empty} :
	default_udp_inserter_device_driver_register_descriptions[ 0xC ] = "asi_snk"                              ; //{asi_snk0_ready,asi_snk0_valid,asi_snk0_startofpacket,asi_snk0_endofpacket, asi_snk0_empty};

		static const unsigned long reg_include_init_array[] = {
				(0x0),
				(0x1),
				(0x2),
				(0x3),
				(0x4),
				(0x5),
				(0x6),
				(0x7),
				(0x8),
				(0x9),
				(0xA),
				(0xB),
				(0xC)

		};
		uart_regfile_single_uart_included_regs_type the_included_regs(reg_include_init_array,reg_include_init_array+sizeof(reg_include_init_array)/sizeof(reg_include_init_array[0]));

		this->set_control_reg_map_desc(default_udp_inserter_device_driver_register_descriptions);
		this->set_included_ctrl_regs(the_included_regs);

		dureg(safe_print(std::cout << "udp_inserter_device_driver_virtual_uart set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
}
