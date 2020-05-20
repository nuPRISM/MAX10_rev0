/*
 * linnux_remote_command_response_container.h
 *
 *  Created on: Oct 12, 2011
 *      Author: linnyair
 */

#ifndef LINNUX_REMOTE_COMMAND_RESPONSE_CONTAINER_H_
#define LINNUX_REMOTE_COMMAND_RESPONSE_CONTAINER_H_

#include "linnux_remote_command_container.h"
#include <string>

class linnux_remote_command_response_container: public linnux_remote_command_container {
	double completion_time_in_seconds;
	unsigned long long hardware_timestamp_delta;
	unsigned long long completion_hardware_timestamp;
    std::string result_string;
    int error_code;
    std::string log_filename;
    unsigned int command_was_erased;
	std::string end_time_str;

public:
    linnux_remote_command_response_container() : linnux_remote_command_container() {
    	set_error_code(0);
    	set_hardware_timestamp_delta(0);
    	set_result_string("");
    	set_completion_time_in_seconds(0);
    	set_log_filename("");
    };

    linnux_remote_command_response_container (const linnux_remote_command_response_container& x) {
    	this->set_job_index(x.get_job_index());
    	      	this->set_command_string(x.get_command_string());
    	      	this->set_completion_time_in_seconds(x.get_completion_time_in_seconds());
    	      	this->set_hardware_timestamp_delta(x.get_hardware_timestamp_delta());
    	      	this->set_result_string(x.get_result_string());
    	      	this->set_error_code(x.get_error_code());
    	      	this->set_command_type(x.get_command_type());
    	      	this->set_completion_hardware_timestamp(x.get_completion_hardware_timestamp());
    	      	this->set_send_email_notification(x.get_send_email_notification());
    	      	this->set_email_address(x.get_email_address());
    	      	this->set_log_filename(x.get_log_filename());
    	      	this->set_erase_this_command(x.get_erase_this_command());
    	      	this->set_command_was_erased(x.get_command_was_erased());
    	      	this->set_end_time_str(x.get_end_time_str());
    	    	this->set_start_time_str(x.get_start_time_str());
    	    	this->set_telnet_job_index(x.get_telnet_job_index());
    	    	this->set_telnet_console_index(x.get_telnet_console_index());
    	    	this->set_results_file_name(x.get_results_file_name());
    	    	this->set_request_disable_logging(get_request_disable_logging());
    	    	this->set_response_queue(x.get_response_queue());
    	    	this->set_mem_comm_instance(x.get_mem_comm_instance());
    }

	void set_end_time_str(const std::string& x)
	{
		end_time_str = x;
	}
	std::string get_end_time_str() const
	{
			return end_time_str;
	}
    void set_command_was_erased(const unsigned int x)
    {
    	command_was_erased = x;
    }
    unsigned int get_command_was_erased() const
    {
    	return command_was_erased;
    }
    void set_log_filename(std::string log_file_name)
    {
    	this->log_filename = log_file_name;
    }

    std::string get_log_filename() const
    {
        	return log_filename;
    }
    //virtual ~linnux_remote_command_response_container();
    double get_completion_time_in_seconds() const
    {
        return completion_time_in_seconds;
    }

    int get_error_code() const
    {
        return error_code;
    }

    unsigned long long get_hardware_timestamp_delta() const
    {
        return hardware_timestamp_delta;
    }


    unsigned long long get_completion_hardware_timestamp() const
    {
        return completion_hardware_timestamp;
    }

    std::string get_result_string() const
    {
        return result_string;
    }

    void set_completion_time_in_seconds(double completion_time_in_seconds)
    {
        this->completion_time_in_seconds = completion_time_in_seconds;
    }

    void set_error_code(int error_code)
    {
        this->error_code = error_code;
    }

    void set_hardware_timestamp_delta(unsigned long long hardware_timestamp_delta)
    {
        this->hardware_timestamp_delta = hardware_timestamp_delta;
    }


    void set_completion_hardware_timestamp(unsigned long long completion_hardware_timestamp)
    {
        this->completion_hardware_timestamp = completion_hardware_timestamp;
    }
    void set_result_string(const std::string& result_string)
    {
        this->result_string = result_string;
    }

    linnux_remote_command_response_container&
          operator= (const linnux_remote_command_response_container& x)
      {
      	this->set_job_index(x.get_job_index());
      	this->set_command_string(x.get_command_string());
      	this->set_completion_time_in_seconds(x.get_completion_time_in_seconds());
      	this->set_hardware_timestamp_delta(x.get_hardware_timestamp_delta());
      	this->set_result_string(x.get_result_string());
      	this->set_error_code(x.get_error_code());
      	this->set_command_type(x.get_command_type());
      	this->set_completion_hardware_timestamp(x.get_completion_hardware_timestamp());
      	this->set_send_email_notification(x.get_send_email_notification());
      	this->set_email_address(x.get_email_address());
      	this->set_log_filename(x.get_log_filename());
      	this->set_erase_this_command(x.get_erase_this_command());
      	this->set_command_was_erased(x.get_command_was_erased());
      	this->set_end_time_str(x.get_end_time_str());
    	this->set_start_time_str(x.get_start_time_str());
    	this->set_telnet_job_index(x.get_telnet_job_index());
    	this->set_telnet_console_index(x.get_telnet_console_index());
    	this->set_results_file_name(x.get_results_file_name());
    	this->set_request_disable_logging(get_request_disable_logging());
    	this->set_response_queue(x.get_response_queue());
    	this->set_mem_comm_instance(x.get_mem_comm_instance());
      	return *this;
      }


};

#endif /* LINNUX_REMOTE_COMMAND_RESPONSE_CONTAINER_H_ */
