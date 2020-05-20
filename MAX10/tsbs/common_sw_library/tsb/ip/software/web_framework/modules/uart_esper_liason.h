/*
 * uart_esper_liason.h
 *
 *  Created on: May 4, 2017
 *      Author: yairlinn
 */

#ifndef UART_ESPER_LIASON_H_
#define UART_ESPER_LIASON_H_

#include "uart_encapsulator.h"
#include "uart_register_file.h"

#include "uart_vector_config_encapsulator.h"
#include "semaphore_locking_class.h"
#include "linnux_utils.h"
#include <stdio.h>
#include <string>
#include <sstream>
#include <map>
#include <vector>
#include "assert.h"

extern "C" {
#include "esper.h"
}


class uart_esper_liason {
public:
	uart_esper_liason() {
		uart_ptr = NULL;
		control_reg_shadow_buffer    = NULL;
		status_reg_shadow_buffer     = NULL;
		control_reg_shadow_io_buffer = NULL;
		status_reg_shadow_io_buffer  = NULL;
		High_level_ModuleHandler = NULL;
		flags = 0;

	}

	register_desc_inverse_map_type key_to_vid_map;
	uint32_t* control_reg_shadow_buffer;
	uint32_t* status_reg_shadow_buffer;
	uint32_t* control_reg_shadow_io_buffer;
	uint32_t* status_reg_shadow_io_buffer;
	uart_register_file* uart_ptr;
	unsigned long primary_uart_num;
	unsigned long secondary_uart_address;
	register_desc_map_type control_regs_desc;
	register_desc_map_type status_regs_desc;
	register_desc_inverse_map_type control_regs_desc_to_num_map;
	register_desc_inverse_map_type status_regs_desc_to_num_map;
	register_desc_inverse_map_type is_status_reg;
	ModuleHandler High_level_ModuleHandler;
	ESPER_OPTIONS flags;


};




#endif /* UART_ESPER_LIASON_H_ */
