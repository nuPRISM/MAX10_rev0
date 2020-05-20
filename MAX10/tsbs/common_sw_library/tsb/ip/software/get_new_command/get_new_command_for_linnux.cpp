/*
 * get_new_command_for_linnux.cpp
 *
 *  Created on: Sep 29, 2011
 *      Author: linnyair
 */

extern "C" {
#include "ucos_ii.h"
#include "simple_socket_server.h"
/* MicroC/OS-II definitions */
#include "includes.h"
#include "http.h"
/* Nichestack definitions */
//#include "ipport.h"
//#include "tcpport.h"
}
#include "alt_error_handler.hpp"
#include "basedef.h"
#include "get_new_command_for_linnux.h"
#include "linnux_remote_command_container.h"
#include "telnet_job_record.h"
#include <string>
#include <set>
#include <vector>
#include <iostream>
#include "linnux_utils.h"
#include "telnet_quit_command_encapsulator.h"
#include "memory_comm_encapsulator.h"

extern int verbose_jtag_debug_mode;

linnux_remote_command_container* get_new_command_for_linnux_from_cin_or_ethernet(mem_comm_ucos_class_vector_type* mem_comm_ucos_vector_ptr)
{
	std::string command_string_received_from_a_queue;
	telnet_job_record* telnet_job_record_ptr = (telnet_job_record*) NULL;
	telnet_quit_command_encapsulator* telnet_quit_command_encapsulator_ptr=(telnet_quit_command_encapsulator*) NULL;
	unsigned int telnet_job_index=0;
	unsigned int telnet_console_index=0;
	std::string trimmed_original_str;
	INT8U error_code;
	linnux_remote_command_container* input_command_record = NULL;
	int we_have_a_new_command = 0;
	std::string *strptr = (std::string *)NULL;
	linnux_remote_command_container *cmd_container_ptr = (linnux_remote_command_container *)NULL;
	std::vector<unsigned int> *jobs_to_erase_vec_ptr = (std::vector<unsigned int> *)NULL;
	std::vector<unsigned int> jobs_to_erase_vec;
	static std::set<unsigned int> set_of_jobs_to_erase;
	std::set<unsigned int>::iterator job_erase_set_iterator;
	unsigned int the_job_index_received;
	unsigned int is_system_console_command = 0;
	unsigned int is_telnet_system_console_command = 0;
	OS_EVENT* telnet_respose_queue = NULL;
	memory_comm_encapsulator* the_memory_comm_encapsulator_inst_ptr = NULL;
	int first_queue = -1; //value of -1 will be increased to 0 on first iteration of queue polling loop
	const int max_queue_index = 5;
	int last_queue = max_queue_index;
	int start_over_round_robin = 1;
    static unsigned int current_memcomm_index = 0;
    mem_comm_ucos_class current_mem_comm_ucos_element;

	while (!(we_have_a_new_command))
	{
		the_job_index_received = 0;
		is_system_console_command = 0;
		is_telnet_system_console_command = 0;
		the_memory_comm_encapsulator_inst_ptr = NULL;

		if (SSSLINNUXErasedCommandQ != NULL)
		{
			jobs_to_erase_vec_ptr = (std::vector<unsigned int> *)OSQAccept(SSSLINNUXErasedCommandQ,&error_code);
			if (error_code == OS_NO_ERR)
			{
				jobs_to_erase_vec = *jobs_to_erase_vec_ptr;
				delete jobs_to_erase_vec_ptr;
				for (std::vector<unsigned int>::iterator i = jobs_to_erase_vec.begin(); i != jobs_to_erase_vec.end(); i++)
				{
					set_of_jobs_to_erase.insert(*i);
				}
				if (verbose_jtag_debug_mode) {
					safe_print(std::cout << " Linnux Received request to erase jobs: " << convert_vector_to_string<unsigned int>(jobs_to_erase_vec) << "] with error code: " <<    ((int) error_code) << std::endl);
				}
			}
		}

		start_over_round_robin = 1; //make sure first iteration is always made
		while (((first_queue != last_queue) && (command_string_received_from_a_queue == "")) || start_over_round_robin) {
			start_over_round_robin = 0; //make sure we don't go into an infinite loop
            //implement simple round robin scheme
			first_queue++;
			if (first_queue > max_queue_index) {
				first_queue = 0;
			}
			switch (first_queue) {
			case 0 :

				if ((mem_comm_ucos_vector_ptr != NULL) && (mem_comm_ucos_vector_ptr->size() > 0)) {
					if (current_memcomm_index >= mem_comm_ucos_vector_ptr->size()) {
						current_memcomm_index = 0;
					}

					current_mem_comm_ucos_element = mem_comm_ucos_vector_ptr->at(current_memcomm_index);
					unsigned int used_index = current_memcomm_index;
					current_memcomm_index++;
					if (current_mem_comm_ucos_element.get_command_q() != NULL)
					{
						strptr = (std::string *)OSQAccept(current_mem_comm_ucos_element.get_command_q(),&error_code);
						if (error_code == OS_NO_ERR)
						{
							command_string_received_from_a_queue = *strptr;
							the_memory_comm_encapsulator_inst_ptr = current_mem_comm_ucos_element.get_memcomm_ptr();
							the_job_index_received = 0;
							is_system_console_command = used_index;
							is_telnet_system_console_command = 0;
							if (verbose_jtag_debug_mode) {
								safe_print(std::cout << " the string received from MemComm Queue index ("  << used_index << ") is address: [" << ((int) strptr) << "] with error code " <<  ((int) error_code) << std::endl);
							};

							memory_comm_debug(
									safe_print(std::cout <<  " Command source: " << the_memory_comm_encapsulator_inst_ptr->get_command_buffer_name() <<
											" Command counter: " << the_memory_comm_encapsulator_inst_ptr->get_command_counter()
											<<std::endl)
							);
						}
					}
				}
				continue;

			case 1:

				continue;

			case 2:

				if (SSSLINNUXCINCommandQ != NULL)
				{
					strptr = (std::string *)OSQAccept(SSSLINNUXCINCommandQ,&error_code);
					if (error_code == OS_NO_ERR)
					{
						command_string_received_from_a_queue = *strptr;
						the_job_index_received = 0;
						is_system_console_command = 0;
						is_telnet_system_console_command = 0;
						if (verbose_jtag_debug_mode) {
							safe_print(std::cout << " the string received from CIN Queue is address: [" << ((int) strptr) << "] with error code " <<  ((int) error_code) << std::endl);
						}
					}
					//alt_uCOSIIErrorHandler(error_code, 0);
				}
				continue;

			case 3:

				if (SSSLINNUX_TELNET_SYSCON_CommandQ != NULL)
				{
					telnet_job_record_ptr = (telnet_job_record* )OSQAccept(SSSLINNUX_TELNET_SYSCON_CommandQ,&error_code);
					if (error_code == OS_NO_ERR)
					{
						strptr = new std::string;
						*strptr = telnet_job_record_ptr->get_the_command(); //keep this line for backward compatibility
						telnet_job_index = telnet_job_record_ptr->get_telnet_index();
						telnet_console_index = telnet_job_record_ptr->get_telnet_console_index();
						telnet_respose_queue = telnet_job_record_ptr->get_response_queue();
						command_string_received_from_a_queue = *strptr;
						the_job_index_received = 0;
						is_system_console_command = 0;
						is_telnet_system_console_command = 1;
						if (verbose_jtag_debug_mode) {
							safe_print(std::cout << " the string received from Telnet Syscon Queue is address: [" << ((int) strptr) << "] with error code " <<  ((int) error_code) << std::endl);
						}
					}
					//alt_uCOSIIErrorHandler(error_code, 0);
				}
				continue;

			case 4:
				if (SSSLINNUX_TELNET_CIN_CommandQ != NULL)
				{
					telnet_job_record_ptr = (telnet_job_record* )OSQAccept(SSSLINNUX_TELNET_CIN_CommandQ,&error_code);
					if (error_code == OS_NO_ERR)
					{
						strptr = new std::string;
						*strptr = telnet_job_record_ptr->get_the_command(); //keep this line for backward compatibility
						telnet_job_index = telnet_job_record_ptr->get_telnet_index();
						telnet_console_index = telnet_job_record_ptr->get_telnet_console_index();
						telnet_respose_queue = telnet_job_record_ptr->get_response_queue();
						command_string_received_from_a_queue = *strptr;
						the_job_index_received = 0;
						is_system_console_command = 0;
						is_telnet_system_console_command = 0;
						if (verbose_jtag_debug_mode) {
							safe_print(std::cout << " the string received from Ethernet Queue is address: [" << ((int) strptr) << "] with error code " <<  ((int) error_code) << std::endl);
						}
					}
					//alt_uCOSIIErrorHandler(error_code, 0);
				}
				continue;


			case 5:
				if (SSSLINNUX_HTTP_TCL_CommandQ != NULL)
				{
					cmd_container_ptr = (linnux_remote_command_container *)OSQAccept(SSSLINNUX_HTTP_TCL_CommandQ,&error_code);

					if (error_code == OS_NO_ERR)
					{
						if (verbose_jtag_debug_mode) {
							safe_print(std::cout << " the string received from TCL/YLCMD Queue is : [" << ((int) cmd_container_ptr) << "] with error code " <<  ((int) error_code) << std::endl);
						}

						command_string_received_from_a_queue = cmd_container_ptr->get_command_string();

						if (verbose_jtag_debug_mode) {
							safe_print(std::cout << "Received command from TCL/YLCMD Queue: [" << command_string_received_from_a_queue << "]"  << "with job number: " << cmd_container_ptr->get_job_index() << std::endl);
						}

						cmd_container_ptr->set_command_string(command_string_received_from_a_queue);
						//alt_uCOSIIErrorHandler(error_code, 0);
						the_job_index_received = cmd_container_ptr->get_job_index();
						is_system_console_command = 0;
						is_telnet_system_console_command = 0;

					}
				}
				continue;
			}
		}

		//continue round robin implementation - update last_queue in a circular fashion
		last_queue = first_queue; //whoever was the command source is now the last queue to be visited
        //////////////////////////////////////////////////////////


		if (command_string_received_from_a_queue != "")
		{
			we_have_a_new_command = 1;
			input_command_record = new linnux_remote_command_container;
			if (the_job_index_received != 0)
			{
				*input_command_record = *cmd_container_ptr;
			} else
			{
				if (is_system_console_command) {
					input_command_record->set_command_string(command_string_received_from_a_queue);
					input_command_record->set_command_type(LINNUX_IS_A_SYSCON_COMMAND);
					input_command_record->set_mem_comm_instance(the_memory_comm_encapsulator_inst_ptr);
					input_command_record->set_telnet_console_index(is_system_console_command);
				} else {
					input_command_record->set_command_string(command_string_received_from_a_queue);
					input_command_record->set_job_index(0);
					input_command_record->set_telnet_job_index(telnet_job_index);
					input_command_record->set_telnet_console_index(telnet_console_index);
					input_command_record->set_response_queue(telnet_respose_queue);
					if (is_telnet_system_console_command) {
						input_command_record->set_command_type(LINNUX_IS_A_TELNET_SYSCON_COMMAND);
					} else {
						input_command_record->set_command_type(LINNUX_IS_A_CONSOLE_COMMAND);
					}
				}
			}

			trimmed_original_str = TrimSpacesFromString(command_string_received_from_a_queue);
			std::string timestamp_str = get_current_time_and_date_as_string();
			TrimSpaces(timestamp_str);

			if (verbose_jtag_debug_mode) {
				safe_print(std::cout << "[ " << timestamp_str << " ] Linnux received string from Ethernet or CIN [" << trimmed_original_str << "]" << std::endl);
			}

			std::string command_name = trimmed_original_str.substr(0,trimmed_original_str.find_first_of(" \n\r\t"));
			ConvertToLowerCase(command_name);
			if (verbose_jtag_debug_mode) {
				safe_print(std::cout << "Found command: [" << command_name << "]");
			}

			if ((command_name == "telnet_quit") || (command_name == "kill_all_telnet") || (command_name == "kill_telnet")) {


				std::vector<unsigned int> telnet_quit_request_vec;

				telnet_quit_request_vec.clear(); //make double sure nothing is in here;

				if (command_name == "kill_all_telnet") {
					for (int i=0; i < MAX_NUM_OF_TELNET_SOCKETS; i++) {
						telnet_quit_request_vec.push_back(i);
					}
				} else if ((command_name == "telnet_quit") && (input_command_record->get_command_type() == LINNUX_IS_A_CONSOLE_COMMAND)) {
					telnet_quit_request_vec.push_back(telnet_console_index);
				} else if (command_name == "kill_telnet") {
					std::string argument_list = trimmed_original_str.substr(trimmed_original_str.find_first_of(" \n\r\t"),trimmed_original_str.length());
					safe_print(std::cout << "Argument list: ["<<argument_list<<"]"<< std::endl);
					telnet_quit_request_vec = convert_string_to_vector<unsigned int>(argument_list,"(, )");

				}

				for (unsigned int i = 0; i < telnet_quit_request_vec.size(); i++) {
					if (telnet_quit_request_vec.at(i) >= MAX_NUM_OF_TELNET_SOCKETS) {
						safe_print(std::cout << "Error: encountered illegal value: [" << telnet_quit_request_vec.at(i) << "], value #[" << i << "] in telnet kill request" <<std::endl);
					} else {
						if (SSSLINNUXCommandFeedbackQ != NULL) {
							telnet_quit_command_encapsulator_ptr = new telnet_quit_command_encapsulator;
							telnet_quit_command_encapsulator_ptr->set_telnet_console_index(telnet_quit_request_vec.at(i));
							safe_print(std::cout << "Posting Telnet Quit Request to close console #" << telnet_quit_request_vec.at(i) << std::endl);
							error_code = OSQPost(SSSLINNUXCommandFeedbackQ, (void *) telnet_quit_command_encapsulator_ptr);
							if (error_code != OS_NO_ERR)
							{

								safe_print(std::cout << "[get_new_command_for_linnux_from_cin_or_ethernet] Error while posting quit command to console: [" << telnet_quit_command_encapsulator_ptr->get_telnet_console_index() <<"] to ethernet, error code is [ " << error_code << std::endl);
								if (telnet_quit_command_encapsulator_ptr != NULL)
								{
									delete telnet_quit_command_encapsulator_ptr;
									telnet_quit_command_encapsulator_ptr = NULL;
								}
							}
						}
					}
				}
			}
		}


		MyOSTimeDlyHMSM(0,0,0,LINNUX_DELAY_BETWEEN_COMMAND_GET_DLY_MS);//delay the task to give a chance to the Ethernet to function

		if (strptr != NULL)
		{
			delete strptr;
			strptr = (std::string *)NULL;
		}

		if (cmd_container_ptr != NULL)
		{
			delete cmd_container_ptr;
			cmd_container_ptr = (linnux_remote_command_container *) NULL;
		}

		if (telnet_job_record_ptr != NULL) {
			delete telnet_job_record_ptr;
			telnet_job_record_ptr = (telnet_job_record*) NULL;
		}

		if (jobs_to_erase_vec_ptr != NULL) {
			delete jobs_to_erase_vec_ptr;
			jobs_to_erase_vec_ptr = (std::vector<unsigned int> *)NULL;
		}

		command_string_received_from_a_queue = ""; //reset string, wait for new command
		if (we_have_a_new_command && ((job_erase_set_iterator = set_of_jobs_to_erase.find(input_command_record->get_job_index())) != set_of_jobs_to_erase.end()))
		{
			//this job should be erased
			//we_have_a_new_command = 0;
			set_of_jobs_to_erase.erase(job_erase_set_iterator);
			safe_print(std::cout << "Erased job " << input_command_record->get_job_index() << " as per user request " << std::endl);
			input_command_record->set_erase_this_command(1);
		}
	}
	return input_command_record;
}

linnux_remote_command_container* get_new_command_for_linnux_control_from_ethernet()
{
	std::string command_string_received_from_a_queue;
	telnet_job_record* telnet_job_record_ptr = (telnet_job_record*) NULL;
	telnet_quit_command_encapsulator* telnet_quit_command_encapsulator_ptr=(telnet_quit_command_encapsulator*) NULL;
	unsigned int telnet_job_index=0;
	unsigned int telnet_console_index=0;
	std::string trimmed_original_str;
	INT8U error_code;
	linnux_remote_command_container* input_command_record=NULL;
	int we_have_a_new_command = 0;
	unsigned int the_job_index_received;

	while (!(we_have_a_new_command))
	{
		the_job_index_received = 0;
		command_string_received_from_a_queue = "";
		if (c_SSSLINNUX_TELNET_CIN_CommandQ != NULL)
		{
			//telnet_job_record_ptr = (telnet_job_record* )OSQAccept(c_SSSLINNUX_TELNET_CIN_CommandQ,&error_code);
			telnet_job_record_ptr = (telnet_job_record* )OSQPend(c_SSSLINNUX_TELNET_CIN_CommandQ,LINNUX_CONTROL_GET_COMMAND_PEND_TIMEOUT_IN_TICKS,&error_code);
			if (error_code == OS_NO_ERR)
			{
				if (telnet_job_record_ptr == NULL) {
					safe_print(std::cout<< "[get_new_command_for_linnux_control_from_ethernet] telnet_job_record_ptr == NULL" << std::endl);
				} else {
					command_string_received_from_a_queue = telnet_job_record_ptr->get_the_command(); //keep this line for backward compatibility
					telnet_job_index = telnet_job_record_ptr->get_telnet_index();
					telnet_console_index = telnet_job_record_ptr->get_telnet_console_index();
					the_job_index_received = 0;
					safe_print(std::cout << " [get_new_command_for_linnux_control_from_ethernet] the string received from Ethernet Queue is address: [" << command_string_received_from_a_queue << "] with error code " <<  ((int) error_code) << std::endl);
				}
			}
		}

		if (command_string_received_from_a_queue != "")
		{
			we_have_a_new_command = 1;
			trimmed_original_str = TrimSpacesFromString(command_string_received_from_a_queue);
			input_command_record = new linnux_remote_command_container;
			input_command_record->set_command_string(trimmed_original_str);
			input_command_record->set_job_index(0);
			input_command_record->set_telnet_job_index(telnet_job_index);
			input_command_record->set_telnet_console_index(telnet_console_index);
			input_command_record->set_command_type(LINNUX_IS_A_CONSOLE_COMMAND);

			std::string timestamp_str = get_current_time_and_date_as_string();
			//std::string timestamp_str = "Dummy Date To flush out bug";
			TrimSpaces(timestamp_str);

			safe_print(std::cout << "[ " << timestamp_str << " ] Linnux received string from Ethernet or CIN [" << trimmed_original_str << "]" << std::endl);
			std::string command_name = trimmed_original_str.substr(0,trimmed_original_str.find_first_of(" \n\r\t"));
			ConvertToLowerCase(command_name);

			safe_print(std::cout << "Found command: [" << command_name << "]");
			if ((command_name == "telnet_quit") || (command_name == "kill_all_telnet") || (command_name == "kill_telnet")) {
				std::vector<unsigned int> telnet_quit_request_vec;
				telnet_quit_request_vec.clear(); //make double sure nothing is in here;
				if (command_name == "kill_all_telnet") {
					for (int i=0; i < MAX_NUM_OF_TELNET_SOCKETS; i++) {
						telnet_quit_request_vec.push_back(i);
					}
				} else if ((command_name == "telnet_quit") && (input_command_record->get_command_type() == LINNUX_IS_A_CONSOLE_COMMAND)) {
					telnet_quit_request_vec.push_back(telnet_console_index);
				} else if (command_name == "kill_telnet") {
					std::string argument_list = trimmed_original_str.substr(trimmed_original_str.find_first_of(" \n\r\t"),trimmed_original_str.length());
					safe_print(std::cout << "Argument list: ["<<argument_list<<"]"<< std::endl);
					telnet_quit_request_vec = convert_string_to_vector<unsigned int>(argument_list,"(, )");
				}

				for (unsigned int i = 0; i < telnet_quit_request_vec.size(); i++) {
					if (telnet_quit_request_vec.at(i) >= MAX_NUM_OF_TELNET_SOCKETS) {
						safe_print(std::cout << "Error: encountered illegal value: [" << telnet_quit_request_vec.at(i) << "], value #[" << i << "] in telnet kill request" <<std::endl);
					} else {
						if (c_SSSLINNUXCommandFeedbackQ != NULL) {
							telnet_quit_command_encapsulator_ptr = new telnet_quit_command_encapsulator;
							telnet_quit_command_encapsulator_ptr->set_telnet_console_index(telnet_quit_request_vec.at(i));
							safe_print(std::cout << "Posting Telnet Quit Request to close console #" << telnet_quit_request_vec.at(i) << std::endl);
							error_code = OSQPost(c_SSSLINNUXCommandFeedbackQ, (void *) telnet_quit_command_encapsulator_ptr);
							if (error_code != OS_NO_ERR)
							{

								safe_print(std::cout << "[get_new_command_for_linnux_control_from_ethernet] Error while posting quit command to console: [" << telnet_quit_command_encapsulator_ptr->get_telnet_console_index() <<"] to ethernet, error code is [ " << error_code << std::endl);
								if (telnet_quit_command_encapsulator_ptr != NULL)
								{
									delete telnet_quit_command_encapsulator_ptr;
									telnet_quit_command_encapsulator_ptr = NULL;
								}
							}
						}
					}
				}
			}
		}


		MyOSTimeDlyHMSM(0,0,0,LINNUX_DELAY_BETWEEN_COMMAND_GET_DLY_MS);//delay the task to give a chance to the Ethernet to function

		if (telnet_job_record_ptr != NULL) {
			delete telnet_job_record_ptr;
			telnet_job_record_ptr = (telnet_job_record*) NULL;
		}

		command_string_received_from_a_queue = ""; //reset string, wait for new command
	}
	return input_command_record;
}


linnux_remote_command_container* get_new_command_for_dut_processor_control_from_ethernet()
{
	std::string command_string_received_from_a_queue;
	telnet_job_record* telnet_job_record_ptr = (telnet_job_record*) NULL;
	telnet_quit_command_encapsulator* telnet_quit_command_encapsulator_ptr=(telnet_quit_command_encapsulator*) NULL;
	unsigned int telnet_job_index=0;
	unsigned int telnet_console_index=0;
	std::string trimmed_original_str;
	INT8U error_code;
	linnux_remote_command_container* input_command_record=NULL;
	int we_have_a_new_command = 0;
	unsigned int the_job_index_received;

	while (!(we_have_a_new_command))
	{
		the_job_index_received = 0;
		command_string_received_from_a_queue = "";
		if (LINNUX_DUT_PROCESSOR_CIN_CommandQ != NULL)
		{
			telnet_job_record_ptr = (telnet_job_record* )OSQPend(LINNUX_DUT_PROCESSOR_CIN_CommandQ,LINNUX_CONTROL_GET_COMMAND_PEND_TIMEOUT_IN_TICKS,&error_code);
			if (error_code == OS_NO_ERR)
			{
				if (telnet_job_record_ptr == NULL) {
					safe_print(std::cout<< "[get_new_command_for_dut_processor_control_from_ethernet] telnet_job_record_ptr == NULL" << std::endl);
				} else {
					command_string_received_from_a_queue = telnet_job_record_ptr->get_the_command(); //keep this line for backward compatibility
					telnet_job_index = telnet_job_record_ptr->get_telnet_index();
					telnet_console_index = telnet_job_record_ptr->get_telnet_console_index();
					the_job_index_received = 0;
					safe_print(std::cout << " [get_new_command_for_dut_processor_control_from_ethernet] the string received from Ethernet Queue is address: [" << command_string_received_from_a_queue << "] with error code " <<  ((int) error_code) << std::endl);
				}
			}
		}

		if (command_string_received_from_a_queue != "")
		{
			we_have_a_new_command = 1;
			trimmed_original_str = TrimSpacesFromString(command_string_received_from_a_queue);
			input_command_record = new linnux_remote_command_container;
			input_command_record->set_command_string(trimmed_original_str);
			input_command_record->set_job_index(0);
			input_command_record->set_telnet_job_index(telnet_job_index);
			input_command_record->set_telnet_console_index(telnet_console_index);
			input_command_record->set_command_type(LINNUX_IS_A_CONSOLE_COMMAND);

			std::string timestamp_str = get_current_time_and_date_as_string();
			//std::string timestamp_str = "Dummy Date To flush out bug";
			TrimSpaces(timestamp_str);

			safe_print(std::cout << "[ " << timestamp_str << " ] Linnux received string from Ethernet or CIN [" << trimmed_original_str << "]" << std::endl);
			std::string command_name = trimmed_original_str.substr(0,trimmed_original_str.find_first_of(" \n\r\t"));
			ConvertToLowerCase(command_name);

			safe_print(std::cout << "Found command: [" << command_name << "]");
			if ((command_name == "telnet_quit") || (command_name == "kill_all_telnet") || (command_name == "kill_telnet")) {
				std::vector<unsigned int> telnet_quit_request_vec;
				telnet_quit_request_vec.clear(); //make double sure nothing is in here;
				if (command_name == "kill_all_telnet") {
					for (int i=0; i < MAX_NUM_OF_TELNET_SOCKETS; i++) {
						telnet_quit_request_vec.push_back(i);
					}
				} else if ((command_name == "telnet_quit") && (input_command_record->get_command_type() == LINNUX_IS_A_CONSOLE_COMMAND)) {
					telnet_quit_request_vec.push_back(telnet_console_index);
				} else if (command_name == "kill_telnet") {
					std::string argument_list = trimmed_original_str.substr(trimmed_original_str.find_first_of(" \n\r\t"),trimmed_original_str.length());
					safe_print(std::cout << "Argument list: ["<<argument_list<<"]"<< std::endl);
					telnet_quit_request_vec = convert_string_to_vector<unsigned int>(argument_list,"(, )");
				}

				for (unsigned int i = 0; i < telnet_quit_request_vec.size(); i++) {
					if (telnet_quit_request_vec.at(i) >= MAX_NUM_OF_TELNET_SOCKETS) {
						safe_print(std::cout << "Error: encountered illegal value: [" << telnet_quit_request_vec.at(i) << "], value #[" << i << "] in telnet kill request" <<std::endl);
					} else {
						if (c_SSSLINNUXCommandFeedbackQ != NULL) {
							telnet_quit_command_encapsulator_ptr = new telnet_quit_command_encapsulator;
							telnet_quit_command_encapsulator_ptr->set_telnet_console_index(telnet_quit_request_vec.at(i));
							safe_print(std::cout << "Posting Telnet Quit Request to close console #" << telnet_quit_request_vec.at(i) << std::endl);
							error_code = OSQPost(LINNUX_DUT_PROCESSOR_CommandFeedbackQ, (void *) telnet_quit_command_encapsulator_ptr);
							if (error_code != OS_NO_ERR)
							{

								safe_print(std::cout << "[get_new_command_for_dut_processor_control_from_ethernet] Error while posting quit command to console: [" << telnet_quit_command_encapsulator_ptr->get_telnet_console_index() <<"] to ethernet, error code is [ " << error_code << std::endl);
								if (telnet_quit_command_encapsulator_ptr != NULL)
								{
									delete telnet_quit_command_encapsulator_ptr;
									telnet_quit_command_encapsulator_ptr = NULL;
								}
							}
						}
					}
				}
			}
		}


		MyOSTimeDlyHMSM(0,0,0,LINNUX_DELAY_BETWEEN_COMMAND_GET_DLY_MS);//delay the task to give a chance to the Ethernet to function

		if (telnet_job_record_ptr != NULL) {
			delete telnet_job_record_ptr;
			telnet_job_record_ptr = (telnet_job_record*) NULL;
		}

		command_string_received_from_a_queue = ""; //reset string, wait for new command
	}
	return input_command_record;
}

linnux_remote_command_container* generic_get_command_from_ethernet
       (std::string& console_name,
		OS_EVENT *input_queue,
		OS_EVENT *feedback_queue,
		INT16U timeout,
		LINNUX_COMAND_TYPES command_type,
		int verbose,
		unsigned int wait_delay_between_commands,
		unsigned int job_index
	)
{
	std::string command_string_received_from_a_queue;
	std::ostringstream info_str;
	if (verbose) { info_str << "[ generic_get_command_from_ethernet for " << console_name << "]";};
	telnet_job_record* telnet_job_record_ptr = (telnet_job_record*) NULL;
	telnet_quit_command_encapsulator* telnet_quit_command_encapsulator_ptr=(telnet_quit_command_encapsulator*) NULL;
	unsigned int telnet_job_index=0;
	unsigned int telnet_console_index=0;
	std::string trimmed_original_str;
	INT8U error_code;
	linnux_remote_command_container* input_command_record=NULL;
	int we_have_a_new_command = 0;

	while (!(we_have_a_new_command))
	{
		command_string_received_from_a_queue = "";
		if (input_queue != NULL)
		{
			telnet_job_record_ptr = (telnet_job_record* )OSQPend(input_queue,timeout,&error_code);
			if (error_code == OS_NO_ERR)
			{
				if (telnet_job_record_ptr == NULL) {
					if (verbose) { safe_print(std::cout<< info_str.str() << " telnet_job_record_ptr == NULL" << std::endl); }
				} else {
					command_string_received_from_a_queue = telnet_job_record_ptr->get_the_command(); //keep this line for backward compatibility
					telnet_job_index = telnet_job_record_ptr->get_telnet_index();
					telnet_console_index = telnet_job_record_ptr->get_telnet_console_index();
					if (verbose) { safe_print(std::cout <<  info_str.str() << " the string received from Ethernet Queue is address: [" << command_string_received_from_a_queue << "] with error code " <<  ((int) error_code) << std::endl); }
				}
			}
		}

		if (command_string_received_from_a_queue != "")
		{
			we_have_a_new_command = 1;
			trimmed_original_str = TrimSpacesFromString(command_string_received_from_a_queue);
			input_command_record = new linnux_remote_command_container;
			input_command_record->set_command_string(trimmed_original_str);
			input_command_record->set_job_index(0);
			input_command_record->set_telnet_job_index(telnet_job_index);
			input_command_record->set_telnet_console_index(telnet_console_index);
			input_command_record->set_command_type(command_type);

			if (verbose) {
				std::string timestamp_str = get_current_time_and_date_as_string();
				TrimSpaces(timestamp_str);
				safe_print(std::cout << info_str.str() << " [ " << timestamp_str << " ] received string [" << trimmed_original_str << "]" << std::endl);
			}

			std::string command_name = trimmed_original_str.substr(0,trimmed_original_str.find_first_of(" \n\r\t"));
			ConvertToLowerCase(command_name);

			if (verbose) { safe_print(std::cout << info_str.str() << " Found command: [" << command_name << "]"); }
			if ((command_name == "telnet_quit") || (command_name == "kill_all_telnet") || (command_name == "kill_telnet")) {
				std::vector<unsigned int> telnet_quit_request_vec;
				telnet_quit_request_vec.clear(); //make double sure nothing is in here;
				if (command_name == "kill_all_telnet") {
					for (int i=0; i < MAX_NUM_OF_TELNET_SOCKETS; i++) {
						telnet_quit_request_vec.push_back(i);
					}
				} else if ((command_name == "telnet_quit") && (input_command_record->get_command_type() == LINNUX_IS_A_CONSOLE_COMMAND)) {
					telnet_quit_request_vec.push_back(telnet_console_index);
				} else if (command_name == "kill_telnet") {
					std::string argument_list = trimmed_original_str.substr(trimmed_original_str.find_first_of(" \n\r\t"),trimmed_original_str.length());
					safe_print(std::cout << "Argument list: ["<<argument_list<<"]"<< std::endl);
					telnet_quit_request_vec = convert_string_to_vector<unsigned int>(argument_list,"(, )");
				}

				for (unsigned int i = 0; i < telnet_quit_request_vec.size(); i++) {
					if (telnet_quit_request_vec.at(i) >= MAX_NUM_OF_TELNET_SOCKETS) {
					    safe_print(std::cout << info_str.str() << " Error: encountered illegal value: [" << telnet_quit_request_vec.at(i) << "], value #[" << i << "] in telnet kill request" <<std::endl);
					} else {
						if (feedback_queue != NULL) {
							telnet_quit_command_encapsulator_ptr = new telnet_quit_command_encapsulator;
							telnet_quit_command_encapsulator_ptr->set_telnet_console_index(telnet_quit_request_vec.at(i));
							if (verbose) { safe_print(std::cout << "Posting Telnet Quit Request to close console #" << telnet_quit_request_vec.at(i) << std::endl); }
							error_code = OSQPost(feedback_queue, (void *) telnet_quit_command_encapsulator_ptr);
							if (error_code != OS_NO_ERR)
							{
								safe_print(std::cout << info_str.str() << "  Error while posting quit command to console: [" << telnet_quit_command_encapsulator_ptr->get_telnet_console_index() <<"] to ethernet, error code is [ " << error_code << "]" << std::endl);
								if (telnet_quit_command_encapsulator_ptr != NULL)
								{
									delete telnet_quit_command_encapsulator_ptr;
									telnet_quit_command_encapsulator_ptr = NULL;
								}
							}
						}
					}
				}
			}
		}


		OSTimeDlyHMSM(0,0,0,wait_delay_between_commands);//delay the task to give a chance to the Ethernet to function

		if (telnet_job_record_ptr != NULL) {
			delete telnet_job_record_ptr;
			telnet_job_record_ptr = (telnet_job_record*) NULL;
		}

		command_string_received_from_a_queue = ""; //reset string, wait for new command
	}
	return input_command_record;
}


