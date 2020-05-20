/*
 * send_to_ethernet_stdout.cpp
 *
 *  Created on: Oct 4, 2011
 *      Author: linnyair
 */

#include "send_to_ethernet_stdout.h"
extern "C" {
#include "ucos_ii.h"
#include "simple_socket_server.h"
}

#include <string>
#include <sstream>
#include "global_stream_defs.hpp"
#include "linnux_utils.h"
#include "telnet_object_process.h"
#include "linnux_utils.h";
#include "linnux_remote_command_container.h"
#include "linnux_remote_command_response_container.h"

using namespace std;
extern telnet_process_object *linnux_main_telnet_inst;
static LINNUX_CONSOLE_STRING_DESCS_TYPE console_string_descs;
static int firsttime = 1;

int monitoring_telnet_available_for_sending() {
	if ((MONITOR_ALL_TELNET_COUT_CommandQ != NULL)   && (linnux_main_telnet_inst->get_num_open_sockets(LINNUX_MONITOR_ALL_TELNET_INDEX) > 0) ){
		if (((OS_Q *)MONITOR_ALL_TELNET_COUT_CommandQ->OSEventPtr)->OSQEntries < ((OS_Q *)MONITOR_ALL_TELNET_COUT_CommandQ->OSEventPtr)->OSQSize) {
			return 1;
		}
	}
	return 0;
}

static void init_linnux_console_string_descs() {
	console_string_descs[LINNUX_IS_A_TCL_COMMAND]=           "TCL      ";
	console_string_descs[LINNUX_IS_A_YAIRL_COMMAND]=         "YAIRL    ";
	console_string_descs[LINNUX_IS_A_CONSOLE_COMMAND]=       "CONSOLE  ";
	console_string_descs[LINNUX_IS_A_SYSCON_COMMAND] =       "SYSCON   ";
	console_string_descs[LINNUX_IS_A_TELNET_SYSCON_COMMAND] ="TELSYSCON";
}
void send_cmd_to_monitoring_telnet_if_available( linnux_remote_command_container* remote_command_container_inst)
{
	if (firsttime) {
		firsttime = 0;
		init_linnux_console_string_descs();
	}

	if (monitoring_telnet_available_for_sending() && (remote_command_container_inst != NULL))	{
		//we have room for a new message
		std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
		ostringstream ostr;
		ostr << "[T:" << (int) remote_command_container_inst->get_command_type() << " (" << console_string_descs[remote_command_container_inst->get_command_type()] << ") CON: " << remote_command_container_inst->get_telnet_console_index() << " CMD][" << timestamp_str << "][" << remote_command_container_inst->get_command_string() << "]" << std::endl;
		post_string_to_monitoring_telnet(ostr);
	}
}

void send_rep_to_monitoring_telnet_if_available( linnux_remote_command_response_container* command_response_record) {
	if (firsttime) {
		firsttime = 0;
		init_linnux_console_string_descs();
	}

	if (monitoring_telnet_available_for_sending() && (command_response_record != NULL)) {
		std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
		ostringstream ostr;
		ostr << "[T:" << command_response_record->get_command_type() << " (" << console_string_descs[command_response_record->get_command_type()] << ") CON: " << command_response_record->get_telnet_console_index() << " REP][" << timestamp_str << "][" << command_response_record->get_result_string() << "]" << std::endl;
		post_string_to_monitoring_telnet(ostr);
	}
}
void post_string_to_monitoring_telnet(std::ostringstream& ostr) {
	int error_code = 0;
	if (monitoring_telnet_available_for_sending())
	{
		//we have room for a new message
		std::string timestamp_str = get_current_time_and_date_as_string();
		TrimSpaces(timestamp_str);
		std::string *cmd_str_to_monitor_all;
		cmd_str_to_monitor_all = new std::string;
		*cmd_str_to_monitor_all =  ostr.str();
		error_code = OSQPost(MONITOR_ALL_TELNET_COUT_CommandQ, (void *) cmd_str_to_monitor_all);
		if (error_code != OS_NO_ERR) {
			delete cmd_str_to_monitor_all;
			cmd_str_to_monitor_all = NULL;
		}
	}
}
int bedrock_send_myostream_to_ethernet_stdout(std::stringstream& myostream, OS_EVENT* post_queue, int send_as_individual, linnux_remote_command_response_container* response_container)
{
	int error_code = 0;

	if ((post_queue != NULL) && (!serious_network_event_has_occured))
	{
		int process_this_string;
		if (myostream.str().length() != 0) {
			process_this_string = 1;
		} else {
			process_this_string = 0;
		}

		if (process_this_string)
		{
			if (monitoring_telnet_available_for_sending()) {
				ostringstream ostr;
				ostr << "[EthStdout][" << post_queue->OSEventName << "] [" << myostream.str() << "]" << std::endl;
				post_string_to_monitoring_telnet(ostr);
			}
			if (send_as_individual && (response_container != NULL)) {
				response_container->set_result_string(myostream.str());
				error_code = OSQPost(post_queue, (void *) response_container);
				if (error_code != OS_NO_ERR) {
#if PRINT_OUT_ERROR_FOR_POST_STRING_TO_ETHERNET_TO_STDOUT
					safe_print(std::cout << "Error while posting string [" << myostream.str() << "to ethernet queue " << string(((char*)post_queue->OSEventName)) << " error is ["<<  (int) error_code << "]" << std::endl);
#endif
				}
			} else {
				string *copy_of_output_str = NULL;
				copy_of_output_str = new string("");
				copy_of_output_str->assign(myostream.str());
				error_code = OSQPost(post_queue, (void *) copy_of_output_str);
				if (error_code != OS_NO_ERR) {
#if PRINT_OUT_ERROR_FOR_POST_STRING_TO_ETHERNET_TO_STDOUT
					safe_print(std::cout << "Error while posting string [" << myostream.str() << "to ethernet queue " << string(((char*)post_queue->OSEventName)) << " error is ["<<  (int) error_code << "]" << std::endl);
#endif

					if (copy_of_output_str != NULL) {
						delete copy_of_output_str;
					}
					copy_of_output_str = NULL;
				}
			}
			MyOSTimeDlyHMSM(0,0,0,SEND_TO_ETHERNET_STDOUT_TIME_TO_SLEEP_MILLISEC);
		} else {
			MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_MINIMAL_PROCESS_DLY_MS);
		}

	} else
	{
		//prevent memory overload before ethernet initialization
		MyOSTimeDlyHMSM(0,0,0,SEND_TO_ETHERNET_STDOUT_TIME_TO_SLEEP_MILLISEC);
	}


	myostream.str("");
	myostream.clear();


	return error_code;
}


int send_myostream_to_ethernet_stdout()
{

	if (OSTCBCur->OSTCBPrio == LINNUX_MAIN_TASK_PRIORITY) {
		return bedrock_send_myostream_to_ethernet_stdout(myostream,SSSLINNUXCOUTCommandQ);
	} else if (OSTCBCur->OSTCBPrio == LINNUX_CONTROL_TASK_PRIORITY)
	{
		return bedrock_send_myostream_to_ethernet_stdout(c_myostream,c_SSSLINNUXCOUTCommandQ);
	} else if (OSTCBCur->OSTCBPrio == LINNUX_DUT_PROCESSOR_TASK_PRIORITY){
		return bedrock_send_myostream_to_ethernet_stdout(dut_proc_myostream,LINNUX_DUT_PROCESSOR_COUT_CommandQ);
	} else {
		return local_send_myostream_to_ethernet_stdout();
	}
	return OS_PRIO_EXIST;
}

int c_send_myostream_to_ethernet_stdout()
{
	return bedrock_send_myostream_to_ethernet_stdout(c_myostream,c_SSSLINNUXCOUTCommandQ);
}

