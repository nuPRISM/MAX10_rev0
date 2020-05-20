/*
 * linnux_remote_command_container.h
 *
 *  Created on: Oct 12, 2011
 *      Author: linnyair
 */

#ifndef LINNUX_REMOTE_COMMAND_CONTAINER_H_
#define LINNUX_REMOTE_COMMAND_CONTAINER_H_


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


#include <new>
#include <string>
#include <vector>
#include <deque>
#include <stdexcept>
#include <iostream>
#include <sstream>
#include <cstdlib>
#include "basedef.h"
#include "linnux_utils.h"
#include "memory_comm_encapsulator.h"

class linnux_remote_command_container {
protected:
	std::string command_string;
	unsigned int job_index;
	unsigned int telnet_console_index;
	unsigned int telnet_job_index;
	LINNUX_COMAND_TYPES command_type;
	unsigned int send_email_notification;
	std::string email_address;
	unsigned int erase_this_command;
	std::string start_time_str;
	std::string results_file_name;
	unsigned int request_disable_logging;
	OS_EVENT *response_queue;
	memory_comm_encapsulator* mem_comm_instance;
public:
	linnux_remote_command_container() {
		set_job_index(0);
		set_command_string("");
		set_command_type(LINNUX_IS_A_YAIRL_COMMAND);
		set_email_address("yairlinn@gmail.com");
		set_send_email_notification(0);
		set_erase_this_command(0);
		set_start_time_str("");
		set_request_disable_logging(0);
		this->set_response_queue(NULL);
		mem_comm_instance = NULL;
	};
	linnux_remote_command_container(const linnux_remote_command_container& x) {
		this->set_job_index(x.get_job_index());
		this->set_command_string(x.get_command_string());
		this->set_command_type(x.get_command_type());
		this->set_send_email_notification(x.get_send_email_notification());
		this->set_email_address(x.get_email_address());
		this->set_erase_this_command(x.get_erase_this_command());
		this->set_start_time_str(x.get_start_time_str());
		this->set_telnet_job_index(x.get_telnet_job_index());
		this->set_telnet_console_index(x.get_telnet_console_index());
		this->set_results_file_name(x.get_results_file_name());
		this->set_request_disable_logging(x.get_request_disable_logging());
		this->set_response_queue(x.get_response_queue());
		this->set_mem_comm_instance(x.get_mem_comm_instance());
	}

    std::string get_results_file_name() const
    {
        return results_file_name;
    }

    void set_mem_comm_instance(memory_comm_encapsulator* mem_comm_instance)
    {
        this->mem_comm_instance = mem_comm_instance;
    }

    memory_comm_encapsulator* get_mem_comm_instance() const
    {
        return mem_comm_instance;
    }

    void set_results_file_name(std::string results_file_name)
    {
        this->results_file_name = results_file_name;
    }

    unsigned int get_telnet_console_index() const
    {
        return telnet_console_index;
    }

    void set_telnet_console_index(unsigned int telnet_console_index)
    {
        this->telnet_console_index = telnet_console_index;
    }

    unsigned int get_telnet_job_index() const
    {
        return telnet_job_index;
    }

    void set_telnet_job_index(unsigned int telnet_job_index)
    {
        this->telnet_job_index = telnet_job_index;
    }

    void set_start_time_str(const std::string x)
    {
        start_time_str = x;
    }

    std::string get_start_time_str() const
    {
        return start_time_str;
    }

    unsigned int get_erase_this_command() const
    {
        return erase_this_command;
    }

    void set_erase_this_command(unsigned int erase_this_command)
    {
        this->erase_this_command = erase_this_command;
    }

    std::string get_email_address() const
    {
        return email_address;
    }

    void set_email_address(std::string email_address)
    {
        this->email_address = email_address;
    }

    unsigned int get_send_email_notification() const
    {
        return send_email_notification;
    }

    void set_send_email_notification(unsigned int send_email_notification)
    {
        this->send_email_notification = send_email_notification;
    }

    LINNUX_COMAND_TYPES get_command_type() const
    {
        return command_type;
    }

    void set_command_type(LINNUX_COMAND_TYPES command_type)
    {
        this->command_type = command_type;
    }

    std::string get_command_string() const
    {
        return command_string;
    }

    unsigned int get_job_index() const
    {
        return job_index;
    }

    void set_command_string(std::string command_string)
    {
        this->command_string = command_string;
    }

    void set_job_index(unsigned int job_index)
    {
        this->job_index = job_index;
    }

    linnux_remote_command_container & operator =(const linnux_remote_command_container & x)
    {
        this->set_job_index(x.get_job_index());
        this->set_command_string(x.get_command_string());
        this->set_command_type(x.get_command_type());
        this->set_send_email_notification(x.get_send_email_notification());
        this->set_email_address(x.get_email_address());
        this->set_erase_this_command(x.get_erase_this_command());
        this->set_start_time_str(x.get_start_time_str());
        this->set_telnet_job_index(x.get_telnet_job_index());
        this->set_telnet_console_index(x.get_telnet_console_index());
        this->set_results_file_name(x.get_results_file_name());
        this->set_request_disable_logging(x.get_request_disable_logging());
        this->set_response_queue(x.get_response_queue());
        this->set_mem_comm_instance(x.get_mem_comm_instance());
        return *this;
    }

    unsigned int get_request_disable_logging() const
    {
        return request_disable_logging;
    }

    void set_request_disable_logging(unsigned int request_disable_logging)
    {
        this->request_disable_logging = request_disable_logging;
    }

	OS_EVENT* get_response_queue() const {
		return response_queue;
	}

	void set_response_queue(OS_EVENT* responseQueue) {
		response_queue = responseQueue;
	}

};

#endif /* LINNUX_REMOTE_COMMAND_CONTAINER_H_ */
