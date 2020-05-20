/*
 * telnet_job_record.h
 *
 *  Created on: Dec 13, 2011
 *      Author: linnyair
 */

#ifndef TELNET_JOB_RECORD_H_
#define TELNET_JOB_RECORD_H_


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

#include <string>

class telnet_job_record {
protected:
	   std::string the_command;
	   unsigned int telnet_index;
	   unsigned int telnet_console_index;
	   OS_EVENT *response_queue;
public:
	telnet_job_record();

	OS_EVENT* get_response_queue() const {
		return response_queue;
	}

	void set_response_queue(OS_EVENT* responseQueue) {
		response_queue = responseQueue;
	}
	//virtual ~telnet_job_record();
    unsigned int get_telnet_console_index() const
    {
        return telnet_console_index;
    }

    void set_telnet_console_index(unsigned int telnet_console_index)
    {
        this->telnet_console_index = telnet_console_index;
    }

    unsigned int get_telnet_index() const
    {
        return telnet_index;
    }

    std::string get_the_command() const
    {
        return the_command;
    }

    void set_telnet_index(unsigned int telnet_index)
    {
        this->telnet_index = telnet_index;
    }

    void set_the_command(std::string the_command)
    {
        this->the_command = the_command;
    }

};

#endif /* TELNET_JOB_RECORD_H_ */
