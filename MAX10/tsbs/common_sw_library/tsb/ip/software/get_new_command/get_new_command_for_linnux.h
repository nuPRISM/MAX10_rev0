/*
 * get_new_command_for_linnux.h
 *
 *  Created on: Sep 29, 2011
 *      Author: linnyair
 */

#ifndef GET_NEW_COMMAND_FOR_LINNUX_H_
#define GET_NEW_COMMAND_FOR_LINNUX_H_
#include <string>
#include <iostream>
#include "linnux_remote_command_container.h"
#include "memory_comm_encapsulator.h"

#ifndef LINNUX_DELAY_BETWEEN_COMMAND_GET_DLY_MS
#define LINNUX_DELAY_BETWEEN_COMMAND_GET_DLY_MS (LINNUX_DEFAULT_MINIMAL_PROCESS_DLY_MS)
#endif

linnux_remote_command_container *get_new_command_for_linnux_from_cin_or_ethernet(mem_comm_ucos_class_vector_type* mem_comm_ucos_vector_ptr);
linnux_remote_command_container *get_new_command_for_linnux_control_from_ethernet();
linnux_remote_command_container *get_new_command_for_dut_processor_control_from_ethernet();
linnux_remote_command_container* generic_get_command_from_ethernet(std::string& console_name,
																	OS_EVENT *input_queue,
																	OS_EVENT *feedback_queue,
																	INT16U timeout,
																	LINNUX_COMAND_TYPES command_type,
																	int verbose,
																	unsigned int wait_delay_between_commands = LINNUX_DEFAULT_PROCESS_DLY_MS,
																	unsigned int job_index = 0
																  );
#endif /* GET_NEW_COMMAND_FOR_LINNUX_H_ */
