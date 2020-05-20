/*
 * packet_diag_virtual_uart.cpp
 *
 *  Created on: Feb 12, 2014
 *      Author: yairlinn
 */

#include "packet_diag_virtual_uart.h"

#include "basedef.h"
#include <sstream>
#include <iostream>
#include <string>
#include <stdio.h>
#include "linnux_utils.h"
#include "basedef.h"
#include "debug_macro_definitions.h"
#include <vector>
extern "C" {
#include <xprintf.h>
}

#ifndef DEBUG_PACKET_DIAG
#define DEBUG_PACKET_DIAG (0)
#endif

#define u(x) do { if (DEBUG_PACKET_DIAG) {x;} } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if (DEBUG_PACKET_DIAG) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} } while (0)

using namespace pdiag;

register_desc_map_type default_packet_diag_device_driver_register_descriptions;

unsigned long long packet_diag_virtual_uart::read_control_reg(unsigned long address,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return 0;
		}
		return this->read(address);
};

void packet_diag_virtual_uart::write_control_reg(unsigned long address,
		unsigned long long data,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	this->write(address,data);
};



packet_diag_virtual_uart::packet_diag_virtual_uart(unsigned long the_base_address, std::string the_name) :
		 packet_diag_encapsulator(the_base_address,the_name)
        {
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_CONTROL_REG                                 ] = "CONTROL"                                  ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_STATUS_REG                                  ] = "STATUS"                                   ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_NUM_OF_PACKETS                              ] = "NUM_OF_PACKETS"                               ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_SOP_2_EOP_CAPTURE_REG                       ] = "SOP_2_EOP_CAPTURE"                        ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_SOP_2_SOP_CAPTURE_REG                       ] = "SOP_2_SOP_CAPTURE"                        ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_SOP_2_EOP_REG                               ] = "SOP_2_EOP"                                ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_SOP_2_SOP_REG                               ] = "SOP_2_SOP"                                ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_VALID_COUNTER_REG                           ] = "VALID_COUNTER"                            ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_VALID_COUNTER_CAPTURE_REG                   ] = "VALID_COUNTER_CAPTURE"                    ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_IN_PACKET_CONTROL                           ] = "IN_PACKET_CONTROL"                            ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_IN_PACKET_DATA                              ] = "IN_PACKET_DATA"                               ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_OUT_PACKET_CONTROL                          ] = "OUT_PACKET_CONTROL"                           ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_OUT_PACKET_DATA                             ] = "OUT_PACKET_DATA"                              ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_FOUND_VALID_PACKET                          ] = "FOUND_VALID_PACKET"                           ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_PACKET_LENGTH_AT_ERROR                      ] = "PACKET_LENGTH_AT_ERROR"                       ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_NUM_PACKET_ERRORS                           ] = "NUM_PACKET_ERRORS"                            ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_PACKET_NUM_AT_ERROR                         ] = "PACKET_NUM_AT_ERROR"                          ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_PACKET_NUM_DELAYS_DUE_TO_READY              ] = "DELAYS_DUE_TO_READY"               ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_PACKET_NUM_DELAYS_DUE_TO_VALID              ] = "DELAYS_DUE_TO_VALID"               ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_PACKET_NUM_DELAYS_DUE_TO_READY_AND_VALID    ] = "DELAYS_DUE_TO_READY_AND_VALID"     ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_S2S_READY_COUNT                             ] = "S2S_READY_COUNT"                              ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_S2S_VALID_COUNT                             ] = "S2S_VALID_COUNT"                              ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_S2S_READY_AND_VALID_COUNT                   ] = "S2S_READY_AND_VALID_CNT"                    ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_S2S_NOT_READY_AND_NOT_VALID_COUNT           ] = "S2S_NOT_READY_AND_NOT_VALID_CNT"            ;
			default_packet_diag_device_driver_register_descriptions[ PACKET_DIAG_NUM_COMPARED_PACKETS_REG_ADDR               ] = "NUM_COMPARED_PACKETS"                         ;

			for (	int i = PACKET_DIAG_COMPARED_PACKET_LENGTH_START; i < PACKET_DIAG_NUM_COMPARED_PACKETS_REG_ADDR; i++) {
				std::ostringstream ostr;
				ostr << "COMPARED_LENGTH_" << ((unsigned int) (i-PACKET_DIAG_COMPARED_PACKET_LENGTH_START));
				default_packet_diag_device_driver_register_descriptions[i] = ostr.str();				
			}
			

	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(default_packet_diag_device_driver_register_descriptions);

	this->set_control_reg_map_desc(default_packet_diag_device_driver_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << "packet_diag_virtual_uart set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
}
