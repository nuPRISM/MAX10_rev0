/*
 * send_to_ethernet_stdout.h
 *
 *  Created on: Oct 4, 2011
 *      Author: linnyair
 */

#ifndef SEND_TO_ETHERNET_STDOUT_H_
#define SEND_TO_ETHERNET_STDOUT_H_
#include "basedef.h"
#include <string>
#include <sstream>
#include "ucos_ii.h"
#include "linnux_utils.h";
#include "linnux_remote_command_container.h"
#include "linnux_remote_command_response_container.h"

#ifndef SEND_TO_ETHERNET_STDOUT_TIME_TO_SLEEP_MILLISEC
#define SEND_TO_ETHERNET_STDOUT_TIME_TO_SLEEP_MILLISEC LINNUX_DEFAULT_SHORT_PROCESS_DLY_MS
#endif

int send_myostream_to_ethernet_stdout();
int c_send_myostream_to_ethernet_stdout();
void post_string_to_monitoring_telnet(std::ostringstream& ostr);
int monitoring_telnet_available_for_sending();
extern int local_send_myostream_to_ethernet_stdout();
int bedrock_send_myostream_to_ethernet_stdout(std::stringstream& myostream, OS_EVENT* post_queue, int send_as_individual = 0, linnux_remote_command_response_container* response_container = NULL);
void send_cmd_to_monitoring_telnet_if_available( linnux_remote_command_container* remote_command_container_inst);
void send_rep_to_monitoring_telnet_if_available( linnux_remote_command_response_container* command_response_record);

#endif /* SEND_TO_ETHERNET_STDOUT_H_ */
