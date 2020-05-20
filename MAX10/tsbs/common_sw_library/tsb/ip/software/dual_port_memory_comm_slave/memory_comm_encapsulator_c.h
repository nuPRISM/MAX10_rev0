/*
 * memory_comm_encapsulator.h
 *
 *  Created on: Nov 19, 2011
 *      Author: user
 */

#ifndef MEMORY_COMM_ENCAPSULATOR_H_
#define MEMORY_COMM_ENCAPSULATOR_H_
#include <system.h>
#include "adc_mcs_basedef.h"


#define BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_REGION_BASE                   (BOARDMANAGEMENT_0_DUAL_PORT_MEM_CONTROLLER_QSYS_0_BASE + BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_REGION_BASE_OFFSET_IN_BYTES)
#define BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_OFFSET_COMMAND_COUNTER_OFFSET                0
#define BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_OFFSET_COMMAND_LENGTH_OFFSET                 4
#define BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_OFFSET_COMMAND_REQUEST_OFFSET                8
#define BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_OFFSET_COMMAND_READY_OFFSET                 12
#define BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_OFFSET_SLAVE_ALIVE_OFFSET                   16
#define BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_OFFSET_START_OF_RESPONSE_STR                20
#define BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_OFFSET_BINARY_COMMAND_RESPONSE_OFFSET       20

void init_memory_comm_encapsulator();
unsigned long mem_comm_get_command_counter();
void mem_comm_set_command_counter(unsigned long x);
void mem_comm_set_command_response(char* the_response); //note: the_response may be modified in the function
void mem_comm_get_new_command(char* buff, unsigned int maxlen);

#endif /* MEMORY_COMM_ENCAPSULATOR_H_ */
