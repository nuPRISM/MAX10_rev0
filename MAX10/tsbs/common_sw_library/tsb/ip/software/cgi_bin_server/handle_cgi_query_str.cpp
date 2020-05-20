/*
 * handle_cgi_query_str.cpp
 *
 *  Created on: Oct 5, 2011
 *      Author: linnyair
 */

#include "handle_cgi_query_str.h"

#include <new>
#include <string>
#include <vector>
#include <deque>
#include <list>
#include <stdexcept>
#include <iostream>
#include <sstream>
#include <cstdlib>
#include <time.h>
#include "linnux_remote_command_container.h"
#include "linnux_remote_command_response_container.h"
#include "linnux_utils.h"
#include "cpp_linnux_dns_tools.h"
#include "cgicc/CgiDefs.h"
#include "cgicc/Cgicc.h"
#include "cgicc/HTTPHTMLHeader.h"
#include "cgicc/HTMLClasses.h"
#include "chan_fatfs/fatfs_linnux_api.h"
#if HAVE_SYS_UTSNAME_H
#  include <sys/utsname.h>
#endif

#if HAVE_SYS_TIME_H
#  include <sys/time.h>
#endif
//#include "styles.h"
#include "url.h"

extern "C" {
#include "my_mem_defs.h"
#include "http.h"
#include "ucos_ii.h"
#include "includes.h"
#include "simple_socket_server.h"
}

#include "smtpfuncs.h"

#include "basedef.h"
#include "linnux_utils.h"
#include "trio/trio.h"
#include "linnux_main.h"

#include "jansson.hpp"
#include "json_serializer_class.h"

#include <jsonp_menu.h>
#include "card_configuration_encapsulator.h"
#include "xprintf.h"

extern card_configuration_encapsulator card_configuration;

extern json::Value motherboard_json_object;
extern json::Value board_mgmt_json_object;
extern json::Value total_json_object;
extern jsonp_menu_mapping_type jsonp_menu_mapStringValues;

using namespace std;
using namespace cgicc;
typedef std::list<linnux_remote_command_container> job_queue_type;
typedef std::list<linnux_remote_command_response_container>
		job_finished_queue_type;

job_queue_type linnux_tcl_job_queue;
job_finished_queue_type completed_command_queue;

unsigned int current_job_index = 1;

std::string execute_tcl_or_ylcmd (std::string cgi_command, std::string query_string);
std::string execute_jsonp_command(std::string cgi_command, std::string query_string);


#define u(x) do { if (CGI_BIN_SERVER_DEBUG) {x;};  fflush(stdout);  std::cout.flush(); } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if (CGI_BIN_SERVER_DEBUG) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););};   fflush(stdout);  } while (0)



std::string convert_string_to_html(std::string the_str) {
	/*CRegexpT<char> newline_fixer("\n");
	CRegexpT<char> lt_fixer("<");
	CRegexpT<char> gt_fixer(">");
	CRegexpT<char> quote_fixer("\"");
	CRegexpT<char> space_fixer(" ");
	char *the_c_str;
	the_c_str = space_fixer.Replace(the_str.c_str(), "&nbsp");
	the_str = the_c_str;
	if (the_c_str != NULL)
		my_mem_free(the_c_str);
	the_c_str = quote_fixer.Replace(the_str.c_str(), "&quot");
	the_str = the_c_str;
	if (the_c_str != NULL)
		my_mem_free(the_c_str);
	the_c_str = lt_fixer.Replace(the_str.c_str(), "&lt");
	the_str = the_c_str;
	if (the_c_str != NULL)
		my_mem_free(the_c_str);
	the_c_str = gt_fixer.Replace(the_str.c_str(), "&gt");
	the_str = the_c_str;
	if (the_c_str != NULL)
		my_mem_free(the_c_str);
	the_c_str = newline_fixer.Replace(the_str.c_str(), "<br>");
	the_str = the_c_str;
	if (the_c_str != NULL)
		my_mem_free(the_c_str);
	return the_str;*/

	str_replace(the_str," ","&nbsp");
	str_replace(the_str,"\"","&quot");
	str_replace(the_str,"<","&lt");
	str_replace(the_str,">","&gt");
	str_replace(the_str,"\n","<br>");
	return (the_str);

}

void push_new_cmd_into_displayed_pending_queue(job_queue_type& q,
		linnux_remote_command_container* cmd_container_ptr) {
	q.push_back(*cmd_container_ptr);
	if (q.size() > LINNUX_MAX_NUM_OF_PENDING_JOBS_TO_SHOW) {
		q.pop_front();
	}
}

std::string format_queue_as_html_table(job_queue_type& q) {
	ostringstream outstr;

	outstr << "<table border=\"1\">";
	outstr << tr() << td() << "Job Number" << td() << td() << "Job Type"
			<< td() << td() << "Command String" << td() << td()
			<< "Submit Time" << td() << tr();
	for (job_queue_type::iterator i = q.begin(); i != q.end(); i++) {
		//outstr << tr() << td() << "("<< i->get_job_index() <<")"<< td() << td() << i->get_command_string() << td() << tr();
		outstr << tr() << td() << "(" << i->get_job_index() << ")" << td()
				<< td()
				<< (i->get_command_type() == LINNUX_IS_A_TCL_COMMAND ? "TCL"
						: "YairL") << td() << td() << i->get_command_string()
				<< td() << td() << i->get_start_time_str() << td() << tr();
	}
	outstr << "</table>";
	return outstr.str();
}

std::string format_completed_command_queue_as_html_table(
		job_finished_queue_type& q) {
	ostringstream outstr;
	std::string cropped_results_string;

	outstr << "<table border=\"1\">";
	outstr << tr() << td() << "Job Number" << td() << td() << "Job Type"
			<< td() << td() << "Command String" << td() << td()
			<< "Submit Time" << td() << td() << "End Time" << td() << td()
			<< "End Timestamp" << td() << td() << "Execution Time Seconds"
			<< td() << td() << "Delta Timestamp" << td() << td()
			<< "Log File Location" << td() << td() << "Results Filename"
			<< td() << td() << "Result String (first "
			<< LINNUX_MAX_NUM_CHARS_IN_HTTP_RESULT_STR << " chars)" << td()
			<< tr();

	for (job_finished_queue_type::iterator i = q.begin(); i != q.end(); i++) {
		std::string temp_results_filename;
		temp_results_filename
				= TrimSpacesFromString(i->get_results_file_name());

		//fix results filename if it is nonnull and does not begin with "/"
		if ((temp_results_filename != "") && (temp_results_filename.at(0)
				!= '/')) {
			temp_results_filename = std::string("/").append(
					temp_results_filename);
		}

		cropped_results_string = (i->get_result_string()).substr(0,
				LINNUX_MAX_NUM_CHARS_IN_HTTP_RESULT_STR);
		cropped_results_string = convert_string_to_html(cropped_results_string);
		outstr << tr() << td() << "(" << i->get_job_index() << ")" << td()
				<< td()
				<< (i->get_command_type() == LINNUX_IS_A_TCL_COMMAND ? "TCL"
						: "YairL") << td() << td() << i->get_command_string()
				<< td() << td() << i->get_start_time_str() << td() << td()
				<< i->get_end_time_str() << td() << td()
				<< i->get_completion_hardware_timestamp() << td() << td()
				<< i->get_completion_time_in_seconds() << td() << td()
				<< i->get_hardware_timestamp_delta() << td() << td()
				<< "<a href=\"http://" << cpp_get_current_linnux_board_hostname()
				<< i->get_log_filename() << "\">" << i->get_log_filename()
				<< "</a>" << td() << td() << "<a href=\"http://"
				<< cpp_get_current_linnux_board_hostname()
				<< temp_results_filename << "\">" << temp_results_filename
				<< "</a>" << td() << td() << tt() << cropped_results_string
				<< tt() << td() << tr();
	}

	outstr << "</table>";
	return outstr.str();
}

void set_and_increment_command_index(
		linnux_remote_command_container *command_to_execute) {
	if (command_to_execute != NULL) {
		//critical so that no other process will change or use the job index between those two lines
		int cpu_sr;
		OS_ENTER_CRITICAL();
		command_to_execute->set_job_index(current_job_index);
		current_job_index++;
		OS_EXIT_CRITICAL();
	} else {
		std::cout
				<< "set_and_increment_command_index command_to_execute = NULL!\n";
	}
}
void update_completed_command_queue() {
	INT8U error_code;
	int cpu_sr;
	static int warned_once = 0;
	linnux_remote_command_response_container *cmd_container_ptr = NULL;
	if (SSSLINNUX_HTTP_TCL_Command_Response_Q == NULL) {
		if (!warned_once) {
			std::cout
					<< "Error: SSSLINNUX_HTTP_TCL_Command_Response_Q queue not initialized"
					<< endl;
			warned_once = 1;
		}
		return;
	}
	cmd_container_ptr = (linnux_remote_command_response_container *) OSQPend(
			SSSLINNUX_HTTP_TCL_Command_Response_Q, 0, &error_code);
	if (cmd_container_ptr == NULL) {
		std::cout
				<< "error: process handle_linnux_response could not get result from queue";
	} else {
/*
           std::cout << "Received completion notice from job: "
				<< cmd_container_ptr->get_job_index() << " Command: "
				<< cmd_container_ptr->get_command_string() << endl;
*/
		INT8U semaphore_err;

		OSSemPend(LINNUX_Job_Completed_Queue_Semaphore,
				LINNUX_DEFAULT_SEMAPHORE_TIMEOUT_IN_TICKS, &semaphore_err);
		if (semaphore_err != OS_NO_ERR) {
			std::cout
					<< "[update_completed_command_queue] Could not get LINNUX_Job_Completed_Queue_Semaphore, Error is: "
					<< semaphore_err << std::endl;
			return;
		}

		completed_command_queue.push_back(*cmd_container_ptr);

		if (completed_command_queue.size()
				> LINNUX_MAX_NUM_OF_COMPLETED_JOBS_TO_SHOW) {
			completed_command_queue.pop_front();
		}

		semaphore_err = OSSemPost(LINNUX_Job_Completed_Queue_Semaphore);
		if (semaphore_err != OS_NO_ERR) {
			std::cout
					<< "[update_completed_command_queue] Could not Post to LINNUX_Job_Completed_Queue_Semaphore, Error is: "
					<< semaphore_err << std::endl;
			return;
		}

		if (cmd_container_ptr->get_send_email_notification()) {
			if (serious_network_event_has_occured) {
				std::cout << "[ "
						<< get_current_time_and_date_as_string_trimmed()
						<< "][update_completed_command_queue]"
						<< " Forgoing email response sending because serious network event is in progress!!!"
						<< std::endl;
			} else {
				std::cout << "detected email notification request for job: "
						<< cmd_container_ptr->get_job_index() << " to email: "
						<< cmd_container_ptr->get_email_address() << std::endl;
				ostringstream email_titlestr;
				ostringstream msgstr;
				unsigned int board_id = card_configuration.get_card_assigned_number();
				email_titlestr << "Linnux board " << board_id
						<< " notification: Job: "
						<< cmd_container_ptr->get_job_index()
						<< " Has completed\n";
				msgstr << "Linnux board " << board_id << " notification: Job: "
						<< cmd_container_ptr->get_job_index()
						<< " Has completed\n";

				//TODO: change strings below to call cpp_get_linnux_board_hostname, to preserve modularity
				msgstr
						<< "==============================================================================================\n";
				msgstr << "Log file location: http://linnux-board" << board_id
						<< ".linnux.ca"
						<< cmd_container_ptr->get_log_filename() << "   \n";
				//		 msgstr << "The result is: " << cmd_container_ptr->get_result_string()<< endl;
				std::string results_filename_tmp;

				if ((results_filename_tmp = TrimSpacesFromString(
						cmd_container_ptr->get_results_file_name())) != "") {
					msgstr << "Results file location: http://linnux-board"
							<< board_id << ".linnux.ca";
					if (results_filename_tmp.at(0) != '/') {
						msgstr << "/";
					}
					msgstr << results_filename_tmp << "  \n";
				}
				msgstr
						<< "==============================================================================================\n";
				ostringstream email_sender_addr;
				email_sender_addr << "linnux-board" << board_id
						<< "@linnux.ca";

				if (send_mail("smtp.linnux.ca",
						email_sender_addr.str().c_str(),
						cmd_container_ptr->get_email_address().c_str(),
						email_titlestr.str().c_str(),
						"yairlinn@gmail.com", msgstr.str().c_str()) != 0) {
					u(safe_print(printf("Message send failed!\n")););
				} else {
					u(safe_print(printf("Message sent successfully!\n")););
				}

				//Now send the all-powerful admin a message showing what's going on
				if (send_mail("smtp.linnux.ca",
						email_sender_addr.str().c_str(),
						"yairlinn@gmail.com",
						email_titlestr.str().c_str(),
						"yairlinn@gmail.com", msgstr.str().c_str()) != 0) {
					u(safe_print(printf("Message to admin send failed!\n")););
				} else {
					u(safe_print(printf("Message to admin sent successfully!\n")););
				}
			}
		}
		delete cmd_container_ptr;
	}
}

void bedrock_handle_linnux_response(void *pd) {
	while (1) {
		update_completed_command_queue();

		MyOSTimeDlyHMSM(0, 0, 0, LINNUX_DEFAULT_MEDIUM_PROCESS_DLY_MS);//delay the task to give a chance to the Ethernet to function;

	}
}

void output_job_queue_tables_to_ostream(ostringstream& output_file_stream) {
	INT8U semaphore_err;

	output_file_stream << "<p style=\"font-size:200%\">";
	output_file_stream << "Testbench Name: "
			<< low_level_get_testbench_description();
	output_file_stream << "</p>";

	output_file_stream << "<p style=\"font-size:200%\">";
	output_file_stream << "Linnux Job Queue (most recent "
			<< LINNUX_MAX_NUM_OF_PENDING_JOBS_TO_SHOW << " pending jobs)";
	output_file_stream << "</p>";
	output_file_stream << "<p style=\"font-size:150%\">";

	OSSemPend(LINNUX_TCL_Job_Queue_Semaphore,
			LINNUX_DEFAULT_SEMAPHORE_TIMEOUT_IN_TICKS, &semaphore_err);
	if (semaphore_err != OS_NO_ERR) {
		std::cout
				<< "[output_job_queue_tables_to_ostream] Could not get LINNUX_TCL_Job_Queue_Semaphore, Error is: "
				<< semaphore_err << std::endl;
		return;
	}

	output_file_stream << format_queue_as_html_table(linnux_tcl_job_queue);

	semaphore_err = OSSemPost(LINNUX_TCL_Job_Queue_Semaphore);
	if (semaphore_err != OS_NO_ERR) {
		std::cout
				<< "[output_job_queue_tables_to_ostream] Could not Post to LINNUX_TCL_Job_Queue_Semaphore, Error is: "
				<< semaphore_err << std::endl;
		return;
	}

	output_file_stream << "</p>";
	output_file_stream << "<p style=\"font-size:200%\">";
	output_file_stream << "Linnux Completed Job Queue (most recent "
			<< LINNUX_MAX_NUM_OF_COMPLETED_JOBS_TO_SHOW << " completed jobs)";
	output_file_stream << "</p>";
	output_file_stream << "<p style=\"font-size:150%\">";

	OSSemPend(LINNUX_Job_Completed_Queue_Semaphore,
			LINNUX_DEFAULT_SEMAPHORE_TIMEOUT_IN_TICKS, &semaphore_err);
	if (semaphore_err != OS_NO_ERR) {
		std::cout
				<< "[output_job_queue_tables_to_ostream] Could not get LINNUX_Job_Completed_Queue_Semaphore, Error is: "
				<< semaphore_err << std::endl;
		return;
	}

	output_file_stream << format_completed_command_queue_as_html_table(
			completed_command_queue);

	semaphore_err = OSSemPost(LINNUX_Job_Completed_Queue_Semaphore);
	if (semaphore_err != OS_NO_ERR) {
		std::cout
				<< "[output_job_queue_tables_to_ostream] Could not Post to LINNUX_Job_Completed_Queue_Semaphore, Error is: "
				<< semaphore_err << std::endl;
		return;
	}

	output_file_stream << "</p>";
}

job_finished_queue_type::iterator pointer_to_job_in_completed_list(
		unsigned int the_job_id, job_finished_queue_type& q, int& found) {
	found = 0;
	for (job_finished_queue_type::iterator i = q.begin(); i != q.end(); i++) {
		if (i->get_job_index() == the_job_id) {
			found = 1;
			return i;
		}
	}

	return q.end();
}

std::string handle_cgi_query_str(std::string query_str_from_http) {
	int cpu_sr;
	string query_str = "http://linnux_board";
	ostringstream output_file_stream;
	ostringstream raw_result_file_stream;
	std::string outstr;
	query_str.append(query_str_from_http);
	INT8U error_code;
	linnux_remote_command_container *command_to_execute = NULL;
	std::string execution_time_str;

	time_t end_time, start_time;
	double total_runtime;
	std::string timestamp_str = get_current_time_and_date_as_string();
	TrimSpaces(timestamp_str);
	u(safe_print(cout << endl << "[" << timestamp_str << "] " << "Found Query String: "
			<< query_str << endl;););
	url u;
	u.parse(query_str.c_str());
	u(safe_print(std::cout << "protocol: [" << u.protocol() << "] host: [" << u.host()
			<< "] path: [" << u.path() << "] Query: [" << u.query() << "] \n";););
	std::string query_string = u.query();
	std::string decoded_query_string = form_urldecode(query_string);
	u(safe_print(std::cout << "Decoded url path:" << decoded_query_string << endl););
	std::string lower_case_path = u.path();
	ConvertToLowerCase(lower_case_path);
	int cgi_bin_pos = lower_case_path.find("cgi-bin/");
	//safe_print(std::cout <<   "cgi_bin_pos = " << cgi_bin_pos << endl);
	std::string cgi_command;
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	//   Here is the CGI-BIN server
	//
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	if (cgi_bin_pos == 1) {
		cgi_command = lower_case_path.substr(9);
		if (cgi_command == "get_tb_name") {
			outstr = TrimSpacesFromString(low_level_get_testbench_description());
			return outstr;
		} else if (cgi_command == "json") {
					if (decoded_query_string == "motherboard"){
								update_json_motherboard_object();
								std::ostringstream ostr;

								ostr << motherboard_json_object;
								outstr = ostr.str();
					} else if (decoded_query_string == "all"){
						update_total_json_object();
						std::ostringstream ostr;
						ostr << total_json_object;
						outstr = ostr.str();
					}
		} else if (cgi_command == "json_regenerate") {
			//outstr = "{ \"Hello\" : \"World\" }";
			if (decoded_query_string == "motherboard"){
			   update_json_motherboard_object();
			   outstr = "OK";
			} else if  (decoded_query_string == "all") {
			  update_total_json_object();
			  outstr = "OK";
			} else {
				std::ostringstream ostr;
				ostr << "Unknown JSON query:  " << decoded_query_string;
				outstr = ostr.str();
			}
			return outstr;
		} else if (cgi_command == "jsonp") {
			outstr = execute_jsonp_command(cgi_command, query_string);
	    } else if (cgi_command == "write_dut_gp_control") {
			std::vector<std::string> argument_str_vector =
					convert_string_to_vector<std::string> (
							decoded_query_string, " ");
			ostringstream new_output_file_stream;

			if (argument_str_vector.size() != 2) {
				new_output_file_stream
						<< "Error: write_dut_gp_control arguments error: ["
						<< decoded_query_string << "]" << std::endl;
				return new_output_file_stream.str();
			}
			//safe_print(std::cout << "arg1: " << conv_hex_string_to_unsigned_long(argument_str_vector.at(0)) << " arg2 " << conv_hex_string_to_unsigned_long(argument_str_vector.at(1)) << std::endl);
			//write_DUT_GP_CONTROL_reg(conv_hex_string_to_unsigned_long(argument_str_vector.at(0)),conv_hex_string_to_unsigned_long(argument_str_vector.at(1)));
			return string("OK");
		} else if (cgi_command == "read_dut_gp_control") {
			std::vector<std::string> argument_str_vector =
					convert_string_to_vector<std::string> (
							decoded_query_string, " ");
			ostringstream new_output_file_stream;
			if (argument_str_vector.size() != 1) {
				new_output_file_stream
						<< "Error: read_dut_gp_control arguments error: ["
						<< decoded_query_string << "]" << std::endl;
				return new_output_file_stream.str();
			}
			//safe_print(std::cout << "arg1: " << conv_hex_string_to_unsigned_long(argument_str_vector.at(0)) << std::endl);
			//new_output_file_stream << read_DUT_GP_CONTROL_reg(conv_hex_string_to_unsigned_long(argument_str_vector.at(0)));
			return new_output_file_stream.str();
		} else if (cgi_command == "read_dut_gp_status") {
			std::vector<std::string> argument_str_vector =
					convert_string_to_vector<std::string> (
							decoded_query_string, " ");
			ostringstream new_output_file_stream;
			if (argument_str_vector.size() != 1) {
				new_output_file_stream
						<< "Error: read_dut_gp_status arguments error: ["
						<< decoded_query_string << "]" << std::endl;
				return new_output_file_stream.str();
			}
			//safe_print(std::cout << "arg1: " << conv_hex_string_to_unsigned_long(argument_str_vector.at(0)) << std::endl);

			//new_output_file_stream << read_DUT_GP_STATUS_reg(conv_hex_string_to_unsigned_long(argument_str_vector.at(0)));
			return new_output_file_stream.str();
		} else if (cgi_command == "showdirectory") {
			//sprintf(outstr,"%s","<html> cgi test\r\n </html>");
			//printf("%s\n",outstr);
			ostringstream output_file_stream;
			output_file_stream << html().set("lang", "en").set("dir", "ltr")
					<< endl;

			output_file_stream << tt() << get_directory_html_string(decoded_query_string) << tt();
			output_file_stream << body() << html();
			//safe_print(std::cout << "Total html produced: " << "[" << output_file_stream.str() << " ]" << endl);
			outstr = output_file_stream.str();
			u(safe_print(std::cout
					<< "handled CGI-BIN request successfully - sending back data"
					<< endl););
		} else if ((cgi_command == "tcl") || (cgi_command == "yairl")) {
			execution_time_str = string(get_current_time_and_date_as_string());
			output_file_stream << title() << "Execution of script ["
					<< decoded_query_string << "]" << " Mode = " << cgi_command
					<< title() << endl;
			output_file_stream << body();
			u(safe_print(std::cout << "Here we would be doing a script for executing: ["
					<< decoded_query_string << "]" << " Mode = " << cgi_command
					<< endl););

			command_to_execute = new linnux_remote_command_container;
			command_to_execute->set_command_string(decoded_query_string);
			if (cgi_command == "tcl") {
				command_to_execute->set_command_type(LINNUX_IS_A_TCL_COMMAND);
			} else {
				command_to_execute->set_command_type(LINNUX_IS_A_YAIRL_COMMAND);
			}
			command_to_execute->set_start_time_str(execution_time_str);
			set_and_increment_command_index(command_to_execute);

			INT8U semaphore_err;
			OSSemPend(LINNUX_TCL_Job_Queue_Semaphore,
					LINNUX_DEFAULT_SEMAPHORE_TIMEOUT_IN_TICKS, &semaphore_err);
			if (semaphore_err != OS_NO_ERR) {
				ostringstream new_output_file_stream;
				new_output_file_stream
						<< "[handle_cgi_query_str ((cgi_command == 'tcl') || (cgi_command == 'yairl'))] Could not get LINNUX_TCL_Job_Queue_Semaphore, Error is: "
						<< semaphore_err << std::endl;
				u(safe_print(std::cout << new_output_file_stream.str()););
				outstr = new_output_file_stream.str();
				return outstr;
			}

			push_new_cmd_into_displayed_pending_queue(linnux_tcl_job_queue,
					command_to_execute);

			semaphore_err = OSSemPost(LINNUX_TCL_Job_Queue_Semaphore);
			if (semaphore_err != OS_NO_ERR) {
				ostringstream new_output_file_stream;
				new_output_file_stream
						<< "[handle_cgi_query_str ((cgi_command == 'tcl') || (cgi_command == 'yairl'))] Could not get LINNUX_TCL_Job_Queue_Semaphore, Error is: "
						<< semaphore_err << std::endl;
				u(safe_print(std::cout << new_output_file_stream.str()););
				outstr = new_output_file_stream.str();
				return outstr;
			}

			if (SSSLINNUX_HTTP_TCL_CommandQ == NULL) {
				output_file_stream << br()
						<< "Error: CGI-BIN handle for TCL: TCL command queue not initialized"
						<< br();
			} else {
				error_code = OSQPost(SSSLINNUX_HTTP_TCL_CommandQ,
						(void *) command_to_execute);
				if (error_code == OS_NO_ERR) {
					output_file_stream << br() << "The TCL command: "
							<< decoded_query_string
							<< " is in the queue for execution!" << br()
							<< endl;
				} else {
					output_file_stream << br() << "Error code:  " << error_code
							<< "while sending the TCL command: "
							<< decoded_query_string << " for execution!"
							<< br() << endl;
					delete command_to_execute;
				}
			}
			output_file_stream << body() << html();
			outstr = output_file_stream.str();
		} else
			if ((cgi_command == "tcl_execute_command") || (cgi_command
				== "yairl_execute_command") || (cgi_command == "ylcmd_raw"))
		{
			outstr =  execute_tcl_or_ylcmd (cgi_command,query_string);
		}  else if (cgi_command == "show_job_queue") {
			output_file_stream << title() << "Linnux Job Queue" << title()
					<< endl;
			output_file_stream << body();
			u(safe_print(std::cout << "printing job queue table" << endl););
			output_job_queue_tables_to_ostream(output_file_stream);
			output_file_stream << body() << html();
			outstr = output_file_stream.str();
		} else if (cgi_command == "erase_jobs") {
			CgiInput cgiinput;
			cgiinput.set_query_string(query_string);
			Cgicc cgi(&cgiinput);
			const_form_iterator jobs_to_erase = cgi.getElement("jobs_to_erase");
			std::string actual_jobs_to_erase = "";

			if (jobs_to_erase != cgi.getElements().end()) {
				actual_jobs_to_erase = TrimSpacesFromString(
						(*jobs_to_erase).getStrippedValue());
				vector<unsigned int> *jobs_to_erase_vector = NULL;
				jobs_to_erase_vector = new vector<unsigned int> ;
				*jobs_to_erase_vector
						= convert_string_to_vector<unsigned int> (
								actual_jobs_to_erase, " ");

				if (SSSLINNUXErasedCommandQ == NULL) {
					output_file_stream << br()
							<< "Error: CGI-BIN handle for Erase Jobs: SSSLINNUXErasedCommandQ queue not initialized"
							<< br();
				} else {
					std::string job_erase_feedback_str =
							convert_vector_to_string<unsigned int> (
									*jobs_to_erase_vector);
					error_code = OSQPost(SSSLINNUXErasedCommandQ,
							(void *) jobs_to_erase_vector);
					if (error_code == OS_NO_ERR) {

						output_file_stream << br()
								<< "Requested To Erase Jobs: ["
								<< job_erase_feedback_str << "] " << br()
								<< std::endl;
						u(safe_print(std::cout << "Requested To Erase Jobs: ["
								<< job_erase_feedback_str << "] " << endl););
					} else {
						output_file_stream << br() << "Error code:  "
								<< error_code
								<< "while sending the Erase jobs request: ["
								<< job_erase_feedback_str << "] to queue!"
								<< br() << endl;
						delete jobs_to_erase_vector;
					}
				}

			} else {
				u(safe_print(std::cout << "Error: could not find jobs to erase!"
						<< std::endl););
				output_file_stream << br()
						<< "Error: could not find jobs to erase!" << br();
			}
			outstr = output_file_stream.str();

		}

		else if (cgi_command == "write_led") {
			std::vector<std::string> argument_str_vector =
					convert_string_to_vector<std::string> (
							decoded_query_string, " ");
			ostringstream new_output_file_stream;
			if (argument_str_vector.size() != 2) {
				new_output_file_stream << "Error: write_led arguments error: ["
						<< decoded_query_string << "]" << std::endl;
				outstr = new_output_file_stream.str();
			} else {
				unsigned long led_type = conv_hex_string_to_unsigned_long(
						argument_str_vector.at(0));
				unsigned long pattern_value = conv_hex_string_to_unsigned_long(
						argument_str_vector.at(1));
				//safe_print(std::cout << "arg1: " << led_type << " arg2 " << pattern_value << std::endl);
				if (led_type) {
					write_red_led_pattern(pattern_value);
				} else {
					write_green_led_pattern(pattern_value);
				}
				outstr = std::string("OK");
			}
		} else if (cgi_command == "read_led") {
			std::vector<std::string> argument_str_vector =
					convert_string_to_vector<std::string> (
							decoded_query_string, " ");
			ostringstream new_output_file_stream;
			if (argument_str_vector.size() != 1) {
				new_output_file_stream << "Error: read_led arguments error: ["
						<< decoded_query_string << "]" << std::endl;
				outstr = new_output_file_stream.str();
			} else {
				unsigned long led_type = conv_hex_string_to_unsigned_long(
						argument_str_vector.at(0));

				//safe_print(std::cout << "arg1: " << led_type << std::endl);
				if (led_type) {
					new_output_file_stream << get_red_led_state();
				} else {
					new_output_file_stream << get_green_led_state();
				}
				outstr = new_output_file_stream.str();
			}
		} else if (cgi_command == "read_switch") {
			std::vector<std::string> argument_str_vector =
					convert_string_to_vector<std::string> (
							decoded_query_string, " ");
			ostringstream new_output_file_stream;
			if (argument_str_vector.size() != 1) {
				new_output_file_stream
						<< "Error: read_switch arguments error: ["
						<< decoded_query_string << "]" << std::endl;
				outstr = new_output_file_stream.str();
			} else {
				unsigned long switch_num = conv_hex_string_to_unsigned_long(
						argument_str_vector.at(0));

				unsigned long curr_mask = 1;
				curr_mask = curr_mask << switch_num;
				new_output_file_stream << ((read_switches() & curr_mask) != 0);
				outstr = new_output_file_stream.str();
			}
		} else {

			output_file_stream << br() << "Unknown CGI command: "
					<< cgi_command << endl;
			outstr = output_file_stream.str();
		}
	} else {
		outstr = "";
	}
	return outstr;
}

std::string post_a_command_to_the_command_queue(std::string actual_tcl_command_to_execute,
		                                        LINNUX_COMAND_TYPES the_command_type,
		                                        std::string results_file_name,
		                                        unsigned int send_email_notification,
		                                        std::string  notif_email_address,
		                                        unsigned int request_to_disable_logging,
		                                        unsigned int& saved_job_index,
		                                        bool& error_has_occured
		                                        )
{
	ostringstream output_file_stream;
	std::string execution_time_str;
	linnux_remote_command_container *command_to_execute = NULL;
    std::string outstr;
	INT8U error_code;
    error_has_occured = false;
	execution_time_str = string(get_current_time_and_date_as_string());

	command_to_execute = new linnux_remote_command_container;
	            			command_to_execute->set_command_string(actual_tcl_command_to_execute);
	            			command_to_execute->set_email_address(notif_email_address);
	            			command_to_execute->set_send_email_notification(send_email_notification);
	            			command_to_execute->set_start_time_str(execution_time_str);
	            			command_to_execute->set_request_disable_logging(request_to_disable_logging);
	            			command_to_execute->set_command_type(the_command_type);
	            			set_and_increment_command_index(command_to_execute);
	            			saved_job_index = command_to_execute->get_job_index();

	            			int results_file_specified = 0;

	            			command_to_execute->set_results_file_name(results_file_name);

	            			INT8U semaphore_err;
	            			OSSemPend(LINNUX_TCL_Job_Queue_Semaphore,
	            					LINNUX_DEFAULT_SEMAPHORE_TIMEOUT_IN_TICKS, &semaphore_err);
	            			if (semaphore_err != OS_NO_ERR) {
	            				ostringstream new_output_file_stream;
	            				new_output_file_stream
	            						<< "[handle_cgi_query_str post_a_command_to_the_command_queue ] Could not get LINNUX_TCL_Job_Queue_Semaphore, File: " << __FILE__ << " Line: " << __LINE__ << " Error is: "
	            						<< semaphore_err << std::endl;
	            				u(safe_print(std::cout << new_output_file_stream.str()););
	            				outstr = new_output_file_stream.str();
	            				error_has_occured = true;
	            				return outstr;
	            			}

	            			push_new_cmd_into_displayed_pending_queue(linnux_tcl_job_queue,
	            					command_to_execute);

	            			semaphore_err = OSSemPost(LINNUX_TCL_Job_Queue_Semaphore);
	            			if (semaphore_err != OS_NO_ERR) {
	            				ostringstream new_output_file_stream;
	            				new_output_file_stream
	            						<< "[handle_cgi_query_str post_a_command_to_the_command_queue] Could not get LINNUX_TCL_Job_Queue_Semaphore, File: " << __FILE__ << " Line: " << __LINE__ << " Error is: "
	            						<< semaphore_err << std::endl;
	            				u(safe_print(std::cout << new_output_file_stream.str()););
	            				outstr = new_output_file_stream.str();
	            				error_has_occured = true;
	            				return outstr;
	            			}

	            			if (SSSLINNUX_HTTP_TCL_CommandQ == NULL) {
	            				output_file_stream << br()
	            						<< "Error: CGI-BIN handle for TCL: TCL command queue not initialized"
	            						<< br();
	            			} else {
	            				error_code = OSQPost(SSSLINNUX_HTTP_TCL_CommandQ,
	            						(void *) command_to_execute);
	            				if (error_code == OS_NO_ERR) {
	            					output_file_stream << br() << "The command is: ["
	            							<< command_to_execute->get_command_string()
	            							<< "] with job index ["
	            							<< command_to_execute->get_job_index()
	            							<< "] with type ["
	            							<< command_to_execute->get_command_type()
	            							<< "] in the queue for execution!" << br() << endl;
	            					u(safe_print(std::cout << "The command is: [" << command_to_execute->get_command_string()
	            							<< "] with job index ["
	            							<< command_to_execute->get_job_index()
	            							<< "] with type ["
	            							<< command_to_execute->get_command_type()
	            							<< "] in the queue for execution!" << endl););
	            				} else {
	            					output_file_stream << br() << "Error code:  " << error_code
	            							<< "while sending the TCL command: "
	            							<< actual_tcl_command_to_execute
	            							<< " for execution!" << br() << endl;
	            					error_has_occured = true;
	            					delete command_to_execute;
	            				}
	            			}
	            			outstr = output_file_stream.str();
	            			return outstr;
}

std::string wait_for_command_result_from_command_queue (
		unsigned long saved_job_index,
		double max_total_runtime,
		linnux_remote_command_response_container& saved_completed_job_record,
		int& found,
		bool& error_has_occured)
{
	time_t end_time, start_time;
	double total_runtime;
    std::string outstr;
	error_has_occured = false;
    job_finished_queue_type::iterator complete_job_iterator;
	found = 0;

	            				time(&start_time);
	            				do {
	            					INT8U semaphore_err;
	            					OSSemPend(LINNUX_Job_Completed_Queue_Semaphore,
	            							LINNUX_DEFAULT_SEMAPHORE_TIMEOUT_IN_TICKS,
	            							&semaphore_err);
	            					if (semaphore_err != OS_NO_ERR) {
	            						ostringstream new_output_file_stream;
	            						new_output_file_stream
	            								<< "[handle_cgi_query_str] Could not get LINNUX_Job_Completed_Queue_Semaphore, Error is: "
	            								<< semaphore_err << std::endl;
	            						u(safe_print(std::cout << new_output_file_stream.str()););
	            						outstr = new_output_file_stream.str();
	            						error_has_occured = true;
	            						return outstr;
	            					}

	            					complete_job_iterator = pointer_to_job_in_completed_list(
	            							saved_job_index, completed_command_queue, found);
	            					if (found) {
	            						saved_completed_job_record = *complete_job_iterator;
	            					}

	            					semaphore_err = OSSemPost(
	            							LINNUX_Job_Completed_Queue_Semaphore);
	            					if (semaphore_err != OS_NO_ERR) {
	            						ostringstream new_output_file_stream;
	            						new_output_file_stream
	            								<< "[handle_cgi_query_str] Could not Post to LINNUX_Job_Completed_Queue_Semaphore, Error is: "
	            								<< semaphore_err << std::endl;
	            						u(safe_print(std::cout << new_output_file_stream.str()););
	            						outstr = new_output_file_stream.str();
	            						error_has_occured = true;
	            						return outstr;
	            					}

//	            					safe_print(std::cout << "Waiting for job " << saved_job_index << "to finish, found = " << found << endl);

	            					time(&end_time);
	            					total_runtime = difftime(end_time, start_time);
	            					if (total_runtime > max_total_runtime) {

	            						ostringstream new_output_file_stream;
	            							            						new_output_file_stream << "Error: Stopped waiting for job after "
	            								<< total_runtime
	            								<< " secs due to watchdog timer limit of "
	            								<< max_total_runtime
	            								<< " secs\n";
	            						u(safe_print(std::cout << new_output_file_stream.str()););
	            						outstr = new_output_file_stream.str();
	            						error_has_occured = true;
	            						return outstr;
	            					}

	            					MyOSTimeDlyHMSM(0, 0, 0, LINNUX_DEFAULT_LONG_PROCESS_DLY_MS);

	            				} while (!found);

	            				outstr = saved_completed_job_record.get_result_string();
	            				u(std::cout << " outstr = (" << outstr << ")" << std::endl);
	            				return outstr;
}


std::string execute_tcl_or_ylcmd (std::string cgi_command, std::string query_string)
{
	ostringstream output_file_stream;
	INT8U error_code;
	ostringstream raw_result_file_stream;
	time_t end_time, start_time;
	LINNUX_COMAND_TYPES the_command_type;
	double total_runtime;
            job_finished_queue_type::iterator complete_job_iterator;
			linnux_remote_command_response_container saved_completed_job_record;
			linnux_remote_command_container *command_to_execute = NULL;
            std::string outstr;
            bool error_has_occured = false;

            			unsigned int saved_job_index;
            			CgiInput cgiinput;
            			cgiinput.set_query_string(query_string);
            			// safe_print(std::cout << "before cgi instantiation" << endl);
            			Cgicc cgi(&cgiinput);
            			// safe_print(std::cout << "after cgi instantiation" << endl);

            			////////////////////////////////////////////////////////////////////////////////
            			//
            			// Get Command Parameters
            			//
            			////////////////////////////////////////////////////////////////////////////////


            			const_form_iterator tcl_command_to_execute = cgi.getElement(
            					"tcl_command");
            			std::string actual_tcl_command_to_execute = "";

            			if (tcl_command_to_execute != cgi.getElements().end()) {
            				actual_tcl_command_to_execute = TrimSpacesFromString(
            						(*tcl_command_to_execute).getStrippedValue());
            			} else {
            				u(safe_print(std::cout << "Error: could not find tcl command to execute!" << std::endl););
            			}

            			int send_email_notification = 0;
            			const_form_iterator send_email_notif_iter = cgi.getElement(
            					"send_email_notif");
            			std::string send_email_notif_str = "";

            			if (send_email_notif_iter != cgi.getElements().end()) {
            				send_email_notif_str
            						= (*send_email_notif_iter).getStrippedValue();
            				send_email_notification = (send_email_notif_str == "on");
            			} else {
            				u(safe_print(std::cout << "Warning: Did Not find Email notification request" << std::endl););
            				send_email_notification = 0;
            			}

            			int request_to_disable_logging = 0;
            			const_form_iterator request_to_disable_logging_iter =
            					cgi.getElement("request_to_disable_logging");
            			std::string request_to_disable_logging_str = "";

            			if (request_to_disable_logging_iter != cgi.getElements().end()) {
            				request_to_disable_logging_str = (*request_to_disable_logging_iter).getStrippedValue();
            				request_to_disable_logging = (request_to_disable_logging_str == "on");
            			} else {
            				request_to_disable_logging = 0;
            			}

            			u(safe_print(std::cout << "request_to_disable_logging = "	<< request_to_disable_logging << std::endl););

            			const_form_iterator email_address_iter = cgi.getElement("notif_email");
            			std::string notif_email_address = "";

            			if (email_address_iter != cgi.getElements().end()) {
            				notif_email_address = TrimSpacesFromString(
            						(*email_address_iter).getStrippedValue());
            			} else {
            				u(safe_print(std::cout << "Warning: Did Not find Email address" << std::endl););
            				notif_email_address = "";
            			}

            			output_file_stream << title()
            					<< "Execution of TCL command received by from query string["
            					<< actual_tcl_command_to_execute << "]" << title() << endl;
            			output_file_stream << body();
            			u(safe_print(std::cout << "Executing Linnux command: ["
            					<< actual_tcl_command_to_execute << "]" << endl););

            			if (cgi_command == "tcl_execute_command") {
            				the_command_type = LINNUX_IS_A_TCL_COMMAND;
            			} else {
            				the_command_type = LINNUX_IS_A_YAIRL_COMMAND;
            			}

            			int results_file_specified = 0;
            			const_form_iterator results_file_name_iter = cgi.getElement("results_file_name");
            			std::string result_file_name = "";

            			if (results_file_name_iter != cgi.getElements().end()) {
            				result_file_name = TrimSpacesFromString((*results_file_name_iter).getStrippedValue());
            				results_file_specified = (result_file_name != "");
            				u(safe_print(std::cout << "Found request for results file name of ["<< result_file_name << "]" << std::endl););
            			} else {
            				u(safe_print(std::cout<< "Warning: Did Not find Results File notification request"<< std::endl););
            				results_file_specified = 0;
            			}
            			////////////////////////////////////////////////////////////////////////////////
            		    //
            		    // End Get Command Parameters
            		    //
            		    ////////////////////////////////////////////////////////////////////////////////


            			////////////////////////////////////////////////////////////////////////////////
            			//
            			// Execute the command
            			//
            			////////////////////////////////////////////////////////////////////////////////

            			output_file_stream <<
            				post_a_command_to_the_command_queue(actual_tcl_command_to_execute,
            						the_command_type,
            						result_file_name,
            						send_email_notification,
            						notif_email_address,
            						request_to_disable_logging,
            						saved_job_index,
            						error_has_occured);

            			output_file_stream << body() << html();


            			////////////////////////////////////////////////////////////////////////////////
            			//
            			// Check to see if to wait for the command and show response
            			//
            			////////////////////////////////////////////////////////////////////////////////

            			if (cgi_command == "ylcmd_raw") {
            				if (!error_has_occured) {
            				int conv_to_html;
            				int conv_to_xml;
            				const_form_iterator conv_to_html_ptr = cgi.getElement(
            						"conv_to_html");
            				std::string conv_to_html_val = "";

            				if (conv_to_html_ptr != cgi.getElements().end()) {
            					conv_to_html_val = TrimSpacesFromString(
            							(*conv_to_html_ptr).getStrippedValue());
            					u(safe_print(std::cout
            							<< "Conversion to html field found requested: value:["
            							<< conv_to_html_val << "]" << std::endl););
            					conv_to_html = (conv_to_html_val == "1");
            					conv_to_xml = (conv_to_html_val == "2");
            				} else {
            					u(safe_print(std::cout << "Conversion to html field not found"
            							<< std::endl););
            					conv_to_html = 0;
            					conv_to_xml = 0;
            				}

            				int found = 0;
            				bool command_wait_error_has_occured = false;
            				wait_for_command_result_from_command_queue (
            						saved_job_index,
            						LINNUX_HTTP_XML_WAIT_FOR_COMMAND_RESULT,
            						saved_completed_job_record,
            						found,
            						command_wait_error_has_occured);
            				/*
            				int found = 0;
            				time(&start_time);
            				do {
            					INT8U semaphore_err;
            					OSSemPend(LINNUX_Job_Completed_Queue_Semaphore,
            							LINNUX_DEFAULT_SEMAPHORE_TIMEOUT_IN_TICKS,
            							&semaphore_err);
            					if (semaphore_err != OS_NO_ERR) {
            						ostringstream new_output_file_stream;
            						new_output_file_stream
            								<< "[handle_cgi_query_str] Could not get LINNUX_Job_Completed_Queue_Semaphore, Error is: "
            								<< semaphore_err << std::endl;
            						safe_print(std::cout << new_output_file_stream.str());
            						outstr = new_output_file_stream.str();
            						return outstr;
            					}

            					complete_job_iterator = pointer_to_job_in_completed_list(
            							saved_job_index, completed_command_queue, found);
            					if (found) {
            						saved_completed_job_record = *complete_job_iterator;
            					}

            					semaphore_err = OSSemPost(
            							LINNUX_Job_Completed_Queue_Semaphore);
            					if (semaphore_err != OS_NO_ERR) {
            						ostringstream new_output_file_stream;
            						new_output_file_stream
            								<< "[handle_cgi_query_str] Could not Post to LINNUX_Job_Completed_Queue_Semaphore, Error is: "
            								<< semaphore_err << std::endl;
            						safe_print(std::cout << new_output_file_stream.str());
            						outstr = new_output_file_stream.str();
            						return outstr;
            					}

            					safe_print(std::cout << "Waiting for job " << saved_job_index << "to finish, found = " << found << endl);

            					time(&end_time);
            					total_runtime = difftime(end_time, start_time);
            					if (total_runtime > LINNUX_HTTP_XML_WAIT_FOR_COMMAND_RESULT) {
            						safe_print(std::cout << "Error: Stopped waiting for job after "
            								<< total_runtime
            								<< " secs due to watchdog timer limit of "
            								<< LINNUX_HTTP_XML_WAIT_FOR_COMMAND_RESULT
            								<< " secs\n");
            						break;
            					}

            					MyOSTimeDlyHMSM(0, 0, 0, LINNUX_DEFAULT_LONG_PROCESS_DLY_MS);

            				} while (!found);

            				*/
            				if (found && !(command_wait_error_has_occured)) {
            					if (conv_to_xml) {
            						raw_result_file_stream
            								<< "<?xml version=\"1.0\"?> <response>\n<request>";
            						raw_result_file_stream << actual_tcl_command_to_execute
            								<< "</request>\n";
            						raw_result_file_stream << "<result>" << "OK"
            								<< "</result>";
            						raw_result_file_stream << "<result-text>"
            								<< convert_string_to_html(
            										saved_completed_job_record.get_result_string())
            								<< "</result-text>\n";
            						raw_result_file_stream << "</response>";
            					} else if (conv_to_html) {
            						raw_result_file_stream << title()
            								<< convert_string_to_html(
            										actual_tcl_command_to_execute)
            								<< title() << endl;
            						raw_result_file_stream << body();
            						raw_result_file_stream << tt()
            								<< convert_string_to_html(
            										saved_completed_job_record.get_result_string())
            								<< tt();
            						raw_result_file_stream << body() << html();
            					} else {
            						raw_result_file_stream
            								<< saved_completed_job_record.get_result_string();
            					}
            					outstr = raw_result_file_stream.str();
            				} else {
            					outstr = "Error, timed out waiting for command!\n";
            				}
            				} else {
            					outstr = output_file_stream.str();
            				}
            			} else {
            				outstr = output_file_stream.str();
            			}
            return outstr;
}


std::string remove_letters_from_string(std::string the_str) {
	/*CRegexpT<char> space_fixer("[:alpha:]");
	char *the_c_str;
	the_c_str = space_fixer.Replace(the_str.c_str(), "");
	the_str = the_c_str;
	if (the_c_str != NULL)
		my_mem_free(the_c_str);
		*/

	str_replace_chars(the_str,"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ","");
	return the_str;
}

std::string convert_ampercent_string_to_comma_delimited(std::string the_str) {
	/*CRegexpT<char> space_fixer("&");
	char *the_c_str;
	the_c_str = space_fixer.Replace(the_str.c_str(), ",");
	the_str = the_c_str;
	if (the_c_str != NULL)
		my_mem_free(the_c_str);
		*/

	str_replace(the_str,"&",",");
	return the_str;
}

std::string convert_string_to_comma_delimited(std::string the_str) {
	/*CRegexpT<char> space_fixer(" ");
	char *the_c_str;
	the_c_str = space_fixer.Replace(the_str.c_str(), ",");
	the_str = the_c_str;
	if (the_c_str != NULL)
		my_mem_free(the_c_str);
		*/
	str_replace(the_str, " ",",");
	return the_str;
}

std::string get_comma_delimited_adc_indices_from_callspectrumhandler_query_string(std::string query_string) {
	std::string cmd_name = "callspechandler";
	size_t first_position_of_adc_string = query_string.find(cmd_name) + cmd_name.length()+1;
	std::string adc_list_str = query_string.substr(first_position_of_adc_string);
	u(std::cout << "adc list = (" << adc_list_str << ")\n");
	std::string str_without_letters = remove_letters_from_string(adc_list_str);
	u(std::cout << "str_without_letters = (" << str_without_letters << ")\n");
	std::string comma_delimmited_str = convert_ampercent_string_to_comma_delimited(str_without_letters);
	u(std::cout << "comma_delimmited_str = (" << comma_delimmited_str << ")\n");
	return comma_delimmited_str;
}
std::string execute_jsonp_command(std::string cgi_command, std::string query_string)

{
	std::string execution_time_str;
	ostringstream output_file_stream;
	INT8U error_code;
	ostringstream raw_result_file_stream;
	time_t end_time, start_time;
	double total_runtime;
	job_finished_queue_type::iterator complete_job_iterator;
	linnux_remote_command_response_container saved_completed_job_record;
	linnux_remote_command_container *command_to_execute = NULL;
	std::string outstr;
	unsigned int saved_job_index;
	CgiInput cgiinput;

	ConvertToLowerCase(query_string);
	cgiinput.set_query_string(query_string);
	execution_time_str = string(get_current_time_and_date_as_string());

	Cgicc cgi(&cgiinput);

	const_form_iterator jsonp_callback = cgi.getElement("cmd");

	std::string actual_jsonp_callback = "";

	if (jsonp_callback != cgi.getElements().end()) {
		actual_jsonp_callback = TrimSpacesFromString((*jsonp_callback).getStrippedValue());
	} else {
		outstr =  "Error: could not find jsonp callback command to execute!";
		return outstr;
	}

	switch (jsonp_menu_mapStringValues[actual_jsonp_callback]) {
	case JSONPGetSpectrumList: outstr = "getSpectrumList({'spectrumlist': ['WADC00', 'WADC01', 'WADC02', 'WADC03', 'WADC04', 'WADC05', 'WADC06', 'WADC07', 'WADC08', 'WADC09', 'WADC10', 'WADC11', 'WADC12', 'WADC13', 'WADC14', 'WADC15']})"; break;
	case JSONPGetCardStatus : {
		                       update_total_json_object();
								std::ostringstream ostr;
                                ostr << total_json_object;
			                   outstr = actual_jsonp_callback + "(" + ostr.str() + ");";
			                   break;
	                          }

	case JSONPCaptureDAC0 : {  unsigned int saved_job_index;
	                      bool error_has_occured;
	                      std::string result_str;

		                  post_a_command_to_the_command_queue(
		                		 "get_fifo_data 3 0 0",
		                		 LINNUX_IS_A_YAIRL_COMMAND,
				                 "",
				                 0,
				                 "",
				                 0,
				                 saved_job_index,
				                 error_has_occured
		                     );

		                  if (!error_has_occured) {

		                              				int found = 0;
		                              				bool command_wait_error_has_occured = false;
		                              				result_str = wait_for_command_result_from_command_queue (
		                              						saved_job_index,
		                              						LINNUX_HTTP_XML_WAIT_FOR_COMMAND_RESULT,
		                              						saved_completed_job_record,
		                              						found,
		                              						command_wait_error_has_occured);
		                              				outstr = actual_jsonp_callback + "({WADC0:[" + convert_string_to_comma_delimited(result_str)+ "]})";

		                  } else {
		                	  outstr = "Error in executing command " + actual_jsonp_callback + "\n";
		                  }
		                  break;
	              }

	case JSONPevCallSpectrumHandler : {
		                               unsigned int saved_job_index;
							           bool error_has_occured = false;
							           std::string result_str;
		                                 std::string comma_delimited_str = get_comma_delimited_adc_indices_from_callspectrumhandler_query_string(query_string);
		                                 post_a_command_to_the_command_queue(
		                                 						 "jsonp_acquire_multiple_adc_fifos " + comma_delimited_str,
		                                 						 LINNUX_IS_A_YAIRL_COMMAND,
		                                 						   "",
		                                 						   0,
		                                 						   "",
		                                 						   0,
		                                 						   saved_job_index,
		                                 						   error_has_occured
		                                 					   );
		                                 					debureg(xprintf((std::string("finished posting aquisition command!")  + get_current_time_and_date_as_string()).c_str()));

		                                 					if (!error_has_occured) {

		                                 												int found = 0;
		                                 												bool command_wait_error_has_occured = false;
		                                 												debureg(xprintf((std::string("waiting for adc aquisition command!")  + get_current_time_and_date_as_string()).c_str()));
		                                 												result_str = wait_for_command_result_from_command_queue (
		                                 														saved_job_index,
		                                 														LINNUX_HTTP_XML_WAIT_FOR_COMMAND_RESULT,
		                                 														saved_completed_job_record,
		                                 														found,
		                                 														command_wait_error_has_occured);
		                                 												outstr = std::string("callSpectrumHandler") + "(" + result_str + ")";
		                                 												debureg(xprintf((std::string("Got response of adc acquisition command!") + get_current_time_and_date_as_string()).c_str()));
		                                 					}  else {
		                                 						  outstr = "Error in executing command " + actual_jsonp_callback + "\n";
		                                 						}

	                                  	break;
	                                 }


	    case JSONPCaptureADCs :  {

	    	   const_form_iterator adclist = cgi.getElement("adclist");

	    		std::string actual_adclist = "";

	    		if (adclist != cgi.getElements().end()) {
	    			actual_adclist = TrimSpacesFromString((*adclist).getStrippedValue());
	    		} else {
	    			outstr =  "Error: could not find  adclist!";
	    			return outstr;
	    		}

	    	        unsigned int saved_job_index;

					bool error_has_occured = false;
					std::string result_str;
					debureg(xprintf((std::string("posting aquisition command!")  + get_current_time_and_date_as_string()).c_str()));

					post_a_command_to_the_command_queue(
						 "jsonp_acquire_multiple_adc_fifos " + actual_adclist,
						 LINNUX_IS_A_YAIRL_COMMAND,
						   "",
						   0,
						   "",
						   0,
						   saved_job_index,
						   error_has_occured
					   );
					debureg(xprintf((std::string("finished posting aquisition command!")  + get_current_time_and_date_as_string()).c_str()));

					if (!error_has_occured) {

												int found = 0;
												bool command_wait_error_has_occured = false;
												debureg(xprintf((std::string("waiting for adc aquisition command!")  + get_current_time_and_date_as_string()).c_str()));
												result_str = wait_for_command_result_from_command_queue (
														saved_job_index,
														LINNUX_HTTP_XML_WAIT_FOR_COMMAND_RESULT,
														saved_completed_job_record,
														found,
														command_wait_error_has_occured);
												outstr = actual_jsonp_callback + "(" + result_str + ")";
												debureg(xprintf((std::string("Got response of adc acquisition command!") + get_current_time_and_date_as_string()).c_str()));
					} else {
					  outstr = "Error in executing command " + actual_jsonp_callback + "\n";
					}
					break;
					}
	default: outstr = "Unrecognized jsonp command " + actual_jsonp_callback + "\n"; break;
	}



	return outstr;
}



