/*
 * telnet_object_process.h
 *
 *  Created on: Mar 15, 2012
 *      Author: linnyair
 */

#ifndef TELNET_OBJECT_PROCESS_H_
#define TELNET_OBJECT_PROCESS_H_


extern "C" {
	/* MicroC/OS-II definitions */
#include "includes.h"
	/* Nichestack definitions */
#include "ipport.h"
#include "tcpport.h"
}

#include <stdio.h>
#include <string>
//#include <sstream>
#include <vector>
#include "telnet_job_record.h"
#include "telnet_quit_command_encapsulator.h"
#include "basedef.h"
#define TELNET_OBJECT_MAX_WELCOME_STRING_LENGTH 100
/*
 * Here we structure to manage sss communication for a single connection
 */
typedef struct SSS_SOCKET
{
	SOCKET_STATE state;
	int       fd;
	int       associated_port_index;
	int       close;
	int       non_ewouldblock_errs;
	int       telnet_console_instance;
	std::string rx_str;
} SSSConn;


class telnet_process_object {
protected:
	int telnet_is_in_a_safe_state;
    int number_of_telnet_sockets;
	std::vector<std::string> telnet_tx_buffer;
	std::vector<SSSConn> conn;
	std::vector<int> telnet_port;
	std::vector<OS_EVENT *> telnet_post_queue;
	std::vector<OS_EVENT *> telnet_pend_queue;
	std::vector<OS_EVENT *> command_feedback_queue;
	std::vector<int> num_of_open_sockets;
	std::vector<std::string> welcome_string;
	unsigned int telnet_job_index;
	std::string temp_rx_buf;
    
	std::vector<int> fd_listen;
	std::vector<struct sockaddr_in*> addr;
	std::vector<int> each_terminal_is_individual;
	std::vector<int>         url_encode_terminal;


public:
	telnet_process_object(	std::vector<OS_EVENT *> the_telnet_post_queue,
	std::vector<OS_EVENT *> the_telnet_pend_queue,
	std::vector<OS_EVENT *> the_command_feedback_queue, std::vector<int> the_telnet_port,
	std::vector<std::string> the_welcome_string, std::vector<int> is_individual_terminal_type, std::vector<int> the_url_encode_terminal) : telnet_tx_buffer(MAX_NUM_OF_TELNET_SOCKETS), conn(MAX_NUM_OF_TELNET_SOCKETS) {
		    number_of_telnet_sockets = the_telnet_port.size();
		    if ((the_telnet_pend_queue.size() != number_of_telnet_sockets)
		        || (the_command_feedback_queue.size() != number_of_telnet_sockets)
		        || (the_telnet_post_queue.size() != number_of_telnet_sockets)
		        || (the_welcome_string.size() != number_of_telnet_sockets)
		        || (the_url_encode_terminal.size() != number_of_telnet_sockets))
		        {
		    	  safe_print(printf("telnet_process_object: Error: object number passed does not match!!!\n"));
		    	  while (1) {};
		        }
		    welcome_string = the_welcome_string;
		    set_telnet_post_queue(the_telnet_post_queue);
		    set_telnet_pend_queue(the_telnet_pend_queue);
		    set_command_feedback_queue(the_command_feedback_queue);
		    set_url_encode_terminal(the_url_encode_terminal);
		    set_telnet_port(the_telnet_port);
			telnet_is_in_a_safe_state = 0;
			telnet_port = the_telnet_port;
			telnet_job_index = 1;
            temp_rx_buf = "";
            addr.resize(number_of_telnet_sockets,NULL);
            fd_listen.resize(number_of_telnet_sockets,0);
            num_of_open_sockets.resize(number_of_telnet_sockets,0);
            for (int i = 0; i < number_of_telnet_sockets; i++) {
    		   addr.at(i) = new struct sockaddr_in;
    	    }
            set_each_terminal_is_individual(is_individual_terminal_type);
    }


    void sss_reset_connection(SSSConn *conn, int telnet_instance);
    void sss_send_menu(SSSConn *conn);
    void sss_send_string_to_remote_cout(SSSConn *conn, std::string& tempstr);
    int sss_handle_accept(int,int);
    void sss_exec_command(SSSConn *conn, unsigned int the_telnet_index);
    void sss_handle_linnux_data(int socket_index_num);
    void sss_handle_receive(SSSConn *conn, int telnet_instance);
    void handle_linnux_cout_to_telnet(int socket_index_num);
    int fast_check_cout_to_telnet_pending(int socket_index_num);
    void SocketServerTask();


    std::vector<int>& get_each_terminal_is_individual() {
		return each_terminal_is_individual;
	}

    std::vector<int>& get_url_encode_terminal() {
		return url_encode_terminal;
	}

    void set_url_encode_terminal(
    			std::vector<int> the_url_encode_terminal) {
    	url_encode_terminal = the_url_encode_terminal;
    	}
	void set_each_terminal_is_individual(
			std::vector<int> eachTerminalIsIndividual) {
		each_terminal_is_individual = eachTerminalIsIndividual;
	}

	std::vector<OS_EVENT*> getTelnet_pend_queue() const
    {
        return telnet_pend_queue;
    }

    std::vector<int> getTelnet_port() const
    {
        return telnet_port;
    }

    std::vector<OS_EVENT*> getTelnet_post_queue() const
    {
        return telnet_post_queue;
    }

    void set_telnet_pend_queue(std::vector<OS_EVENT*> telnet_pend_queue)
    {
        this->telnet_pend_queue = telnet_pend_queue;
    }

    void set_telnet_port(std::vector<int> telnet_port)
    {
        this->telnet_port = telnet_port;
    }

    void set_telnet_post_queue(std::vector<OS_EVENT*> telnet_post_queue)
    {
        this->telnet_post_queue = telnet_post_queue;
    }

    std::vector<std::string> get_welcome_string() const
    {
        return welcome_string;
    }

    void set_welcome_string(std::vector<std::string> welcome_string)
    {
        this->welcome_string = welcome_string;
    }

    std::vector<OS_EVENT*> get_command_feedback_queue() const
    {
        return command_feedback_queue;
    }

    int get_telnet_is_in_a_safe_state() const
    {
        return telnet_is_in_a_safe_state;
    }

    void set_command_feedback_queue(std::vector<OS_EVENT*> command_feedback_queue)
    {
        this->command_feedback_queue = command_feedback_queue;
    }

    void set_telnet_is_in_a_safe_state(int telnet_is_in_a_safe_state)
    {
        this->telnet_is_in_a_safe_state = telnet_is_in_a_safe_state;
    }

    int get_num_open_sockets(int socket_index) {
    	return num_of_open_sockets.at(socket_index);
    }
};

#endif /* TELNET_OBJECT_PROCESS_H_ */
