/*
 * video_dma_up_virtual_uart.cpp
 *
 *  Created on: Feb 12, 2014
 *      Author: yairlinn
 */

#include "video_dma_up_virtual_uart.h"

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

#ifndef DEBUG_VIDEO_DMA_UP
#define DEBUG_VIDEO_DMA_UP (0)
#endif

#define u(x) do { if (DEBUG_VIDEO_DMA_UP) {x;} } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if (DEBUG_VIDEO_DMA_UP) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} } while (0)

using namespace vdma;

register_desc_map_type default_video_dma_up_device_driver_register_descriptions;

unsigned long long video_dma_up_virtual_uart::read_control_reg(unsigned long address,
		unsigned long secondary_uart_address,
		int* errorptr)
{
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return 0;
		}
		return this->read(address);
};

void video_dma_up_virtual_uart::write_control_reg(unsigned long address,
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



video_dma_up_virtual_uart::video_dma_up_virtual_uart(unsigned long the_base_address, std::string the_name) :
		 video_dma_up_encapsulator(the_base_address,the_name)
        {
	default_video_dma_up_device_driver_register_descriptions[ 0 ] = "BUFFER_ADDR"                    ;
	default_video_dma_up_device_driver_register_descriptions[ 1 ] = "BACKBUFFER_ADDR"                ;
	default_video_dma_up_device_driver_register_descriptions[ 2 ] = "RESOLUTION"                     ;
	default_video_dma_up_device_driver_register_descriptions[ 3 ] = "CTRL_AND_STATUS"                ;
	default_video_dma_up_device_driver_register_descriptions[ 4 ] = "PACKETS_PROCESSED"              ;
	default_video_dma_up_device_driver_register_descriptions[ 5 ] = "NUM_SWAPS"                      ;
	default_video_dma_up_device_driver_register_descriptions[ 6 ] = "REPEATED_PACKETS"               ;
	default_video_dma_up_device_driver_register_descriptions[ 7 ] = "LAST_BUF_ADDRESS"               ;
	default_video_dma_up_device_driver_register_descriptions[ 8 ] = "WATCHDOG_EVENTS"                ;
	default_video_dma_up_device_driver_register_descriptions[ 9 ] = "DISCARD_EVENTS"                 ;
	default_video_dma_up_device_driver_register_descriptions[ 10] = "OUT_OF_BAND_DATA"               ;
	default_video_dma_up_device_driver_register_descriptions[ 11] = "PIXELS_IN_FRAME"                ;
	default_video_dma_up_device_driver_register_descriptions[ 12] = "FINISHED_PACKETS_PROCESSED"     ;
	default_video_dma_up_device_driver_register_descriptions[ 13] = "WATCHDOG_LIMIT"                 ;
	default_video_dma_up_device_driver_register_descriptions[ 14] = "WATCHDOG_LIMIT_UPPER_BITS"      ;
	default_video_dma_up_device_driver_register_descriptions[ 15] = "DIRECT_BUFFER_ADDRESS"          ;
	default_video_dma_up_device_driver_register_descriptions[ 16] = "BITS_PER_PIXEL"                 ;
	default_video_dma_up_device_driver_register_descriptions[ 17] = "PARALLELIZATION_RATIO"          ;
	default_video_dma_up_device_driver_register_descriptions[ 18] = "SWAP_SYMBOL_CONTROL"            ;
	default_video_dma_up_device_driver_register_descriptions[ 19] = "FSM_STATE"            ;

	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(default_video_dma_up_device_driver_register_descriptions);

	this->set_control_reg_map_desc(default_video_dma_up_device_driver_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << "video_dma_up_virtual_uart set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
}
