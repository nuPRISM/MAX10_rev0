/******************************************************************************
 * Copyright 2006 Altera Corporation, San Jose, California, USA.             *
 * All rights reserved. All use of this software and documentation is          *
 * subject to the License Agreement located at the end of this file below.     *
 *******************************************************************************                                                                             *
 * Date - October 24, 2006                                                     *
 * Module - simple_socket_server.c                                             *
 *                                                                             *                                                                             *
 ******************************************************************************/

/******************************************************************************
 * Simple Socket Server (SSS) example. 
 * 
 * This example demonstrates the use of MicroC/OS-II running on NIOS II.       
 * In addition it is to serve as a good starting point for designs using       
 * MicroC/OS-II and Altera NicheStack TCP/IP Stack - NIOS II Edition.                                          
 *                                                                             
 * -Known Issues                                                             
 *     None.   
 *      
 * Please refer to the Altera NicheStack Tutorial documentation for details on this 
 * software example, as well as details on how to configure the NicheStack TCP/IP 
 * networking stack and MicroC/OS-II Real-Time Operating System.  
 */

extern "C" {
#include <ctype.h> 

	/* <stdlib.h>: Contains C "rand()" function. */
#include <stdlib.h> 

	/* MicroC/OS-II definitions */
#include "includes.h"

	/* Simple Socket Server definitions */
#include "simple_socket_server.h"                                                                    

	/* Nichestack definitions */
#include "ipport.h"
#include "tcpport.h"

	//#include "../../iniche/src/autoip4/upnp.h"
#include "my_mem_defs.h"
#include "mem.h"
#include "simple_net_services/udp_echo_client.h"
#ifdef UDP_INSERTER_0_BASE
#include "udp_payload_inserter_regs.h"
#include "udp_payload_inserter.h"
#endif
} 
#include "smtpfuncs.h"
#include "ucos_cpp_utils.h"
#include "cpp_linnux_dns_tools.h"
#include "basedef.h"
#include <stdio.h>
#include <string>
#include <sstream>
#include <iostream>
#include <fstream>
#include <vector>
#include <time.h>
/* Error Handler definitions */
#include "alt_error_handler.hpp"
#include "telnet_job_record.h"
#include "linnux_server_dns_utils.h"
/*
#include "linnux_utils.h"
#include "iniche_diag_interface.h"
 */
#include "telnet_quit_command_encapsulator.h"
#include "linnux_utils.h"
#include "telnet_object_process.h"
#include "memory_comm_encapsulator.h"
#include "linnux_remote_command_container.h"
#include "linnux_remote_command_response_container.h"
#include "debug_macro_definitions.h"
#include "cgicc/CgiUtils.h"
#define d(x) do { if (SIMPLE_SOCKET_SERVER_DEBUG) {x; fflush(NULL); std::cout.flush();}} while (0)

/*
 * Global handles (pointers) to our MicroC/OS-II resources. All of resources 
 * beginning with "SSS" are declared and created in this file.
 */

/*
 * This SSSLEDCommandQ MicroC/OS-II message queue will be used to communicate 
 * between the simple socket server task and Nios Development Board LED control 
 * tasks.
 *
 * Handle to our MicroC/OS-II Command Queue and variable definitions related to 
 * the Q for sending commands received on the TCP-IP socket from the 
 * SSSSimpleSocketServerTask to the LEDManagementTask.
 */

extern void my_cin_getline (std::istream& is, std::string& str);

//#define tdbg(args...) do { safe_print(printf(args)); } while (0)
#define tdbg(args...)

/* Definition of Task Stacks for tasks not invoked by TK_NEWTASK 
 * (do not use NicheStack) 
 */




/* This function creates tasks used in this example which do not use sockets.
 * Tasks which use Interniche sockets must be created with TK_NEWTASK.
 */

/*
 * sss_reset_connection()
 * 
 * This routine will, when called, reset our SSSConn struct's members 
 * to a reliable initial state. Note that we set our socket (FD) number to
 * -1 to easily determine whether the connection is in a "reset, ready to go" 
 * state.
 */
void telnet_process_object::sss_reset_connection(SSSConn* conn, int telnet_instance)
{
	conn->fd = -1;
	conn->associated_port_index = 0;
	conn->state = READY;
	conn->non_ewouldblock_errs=0;
	conn->telnet_console_instance=-1;
	telnet_tx_buffer.at(telnet_instance) = "";
	conn->rx_str = "";
	return;
}

int inefficient_string_send(int fd, const std::string& sendstr, size_t len) {
		char* tmpbuf=NULL;
		int retcode;
		tmpbuf = my_mem_strdup(sendstr.c_str()); //2*len for safety, calloc in order to initialize everything to 0
		if (tmpbuf == NULL) {
			if (len != 0)
			{
				safe_print(printf ("Error: [string_send] tmpbuf == NULL and len = %d",(int)len));
			}
		}
		retcode = send(fd, tmpbuf, len, 0);

		if (tmpbuf != NULL) {
			my_mem_free(tmpbuf);
		}

		return retcode;
}
int string_send(int fd, const std::string& sendstr, size_t len)
{
	char tmpbuf[2*SSS_TX_BUF_SIZE];
	int retcode;

	if (len > (SSS_TX_BUF_SIZE-1)) {
		safe_print(printf ("Error: [string_send] len = %d, which is over allowed length of %dd",(int)len,(SSS_TX_BUF_SIZE-1)));
		return (inefficient_string_send(fd,sendstr,len));
	}
	snprintf(tmpbuf,len+2,"%s\0",sendstr.c_str());

	retcode = send(fd, tmpbuf, len, 0);

	return retcode;
}

/*
 * sss_send_menu()
 * 
 * This routine will transmit the menu out to the telent client.
 */
void telnet_process_object::sss_send_menu(SSSConn* conn)
{
	if (welcome_string[conn->associated_port_index] == "")
	{
		//don't send anything;
	}
	else
	{
		std::ostringstream ostr;
		ostr << "Linnux [Board " << get_linnux_board_id() << "] Telnet Terminal\n\r";
		telnet_tx_buffer[conn->telnet_console_instance].append("======================================================================\n\r");
		telnet_tx_buffer[conn->telnet_console_instance].append(ostr.str());
		telnet_tx_buffer[conn->telnet_console_instance].append(welcome_string[conn->associated_port_index]).append("\n\r");
		telnet_tx_buffer[conn->telnet_console_instance].append("======================================================================\n\r");
		string_send(conn->fd, telnet_tx_buffer[conn->telnet_console_instance], telnet_tx_buffer[conn->telnet_console_instance].length());
	}
	return;
}


void telnet_process_object::sss_send_string_to_remote_cout(SSSConn* conn, std::string& tempstr)
{
	int i=0;

	//printf("In sss_send_string_to_remote_cout\n");
	int errornum;
	int actual_errornum;

	time_t end_time, start_time;
	double total_runtime;
#if ENABLE_SIMPLE_SOCKET_SERVER_WATCHDOG
	time(&start_time);
#endif

	unsigned int current_str_index = 0;
	telnet_tx_buffer[conn->telnet_console_instance] = "";

	while (current_str_index < tempstr.length())
	{
		i++;
		telnet_tx_buffer[conn->telnet_console_instance].append(tempstr.substr(current_str_index,MAX_ETHERNET_BUF_MESSAGE_TX_LENGTH_PER_PACKET));

		while ((errornum = (int) string_send(conn->fd, telnet_tx_buffer[conn->telnet_console_instance], telnet_tx_buffer[conn->telnet_console_instance].length())) == -1)
		{
			actual_errornum = t_errno(conn->fd);
			if (actual_errornum != EWOULDBLOCK)
			{
				std::string timestamp_str = get_current_time_and_date_as_string_trimmed();

				safe_print(printf("[%s] [sss_send_string_to_remote_cout] errornum != EWOULDBLOCK== [%d], errornum =[%d] exiting\n",timestamp_str.c_str(),(int)EWOULDBLOCK,(int)actual_errornum));
				conn->non_ewouldblock_errs++;
				if (conn->non_ewouldblock_errs > MAX_NUM_CONN_NON_EWOULDBLOCK_ERRORS) {
					safe_print(printf("[%s] [sss_send_string_to_remote_cout] Closing socket [%d] because a total of [%d] non ewouldblock socket errors occured\n",timestamp_str.c_str(),(int)conn->telnet_console_instance,(int)conn->non_ewouldblock_errs));
					conn->state=CLOSE;
				}
				MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_PROCESS_DLY_MS);
				return;
			} else {
				//  printf("errornum is EWOULDBLOCK= %d, so just waiting\n",(int)EWOULDBLOCK);
				MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_VERY_SHORT_PROCESS_DLY_MS);
			}

			if (put_telnet_in_a_safe_state) {
				std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
				safe_print(printf("[%s] [Telnet] exiting from sss_send_string_to_remote_cout\n",timestamp_str.c_str()));
				return;
			}
#if ENABLE_SIMPLE_SOCKET_SERVER_WATCHDOG
			time(&end_time);
			total_runtime = difftime(end_time, start_time);
			if (total_runtime > LINNUX_TELNET_WATCHDOG_TIME_SEC)
			{
				std::string timestamp_str = get_current_time_and_date_as_string_trimmed();

				safe_print(printf("Error: [%s] Watchdog time of [%d] reached in inner loop for console [%d] in sss_send_string_to_remote_cout - aborting send of string [%-100s]\n",timestamp_str.c_str(),(int) LINNUX_TELNET_WATCHDOG_TIME_SEC,(int) conn->telnet_console_instance,tempstr.c_str()));
				return;
			}
#endif
			MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_VERY_SHORT_PROCESS_DLY_MS);

		}

#if ENABLE_SIMPLE_SOCKET_SERVER_WATCHDOG
		time(&end_time);
		total_runtime = difftime(end_time, start_time);
		if (total_runtime > LINNUX_TELNET_WATCHDOG_TIME_SEC)
		{
			std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
			safe_print(printf("[%s] Error: Watchdog time of [%d] reached in outer loop for console [%d] in sss_send_string_to_remote_cout - aborting send of string [%-100s]\n",timestamp_str.c_str(),(int) LINNUX_TELNET_WATCHDOG_TIME_SEC,(int) conn->telnet_console_instance,tempstr.c_str()));
			return;
		}
#endif
		MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_VERY_SHORT_PROCESS_DLY_MS);
		current_str_index += errornum; //errornum should contain the number of bytes sent
		telnet_tx_buffer[conn->telnet_console_instance] = "";
	}
	return;
}

/*
 * sss_handle_accept()
 * 
 * This routine is called when ever our listening socket has an incoming
 * connection request. Since this example has only data transfer socket, 
 * we just look at it to see whether its in use... if so, we accept the 
 * connection request and call the telent_send_menu() routine to transmit
 * instructions to the user. Otherwise, the connection is already in use; 
 * reject the incoming request by immediately closing the new socket.
 * 
 * We'll also print out the client's IP address.
 */
int telnet_process_object::sss_handle_accept(int listen_socket,int socket_index_num)
{
	int                 socket, len;
	struct sockaddr_in  incoming_addr;
	tdbg("1\n");
	len = sizeof(incoming_addr);
	int i;

	for(i=0; i< conn.size(); i++)
	{
		if (conn.at(i).fd == -1)
		{
			break;
		}
	}

	/*
	 * There are no more connection slots available. Ignore the connection
	 * request for now.
	 */
	if(i == conn.size())
		return 1;

	if (conn.at(i).fd == -1)
	{

		if((socket=accept(listen_socket,(struct sockaddr*)&incoming_addr,&len))<0)
		{
			std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
			/*alt_NetworkErrorHandler(EXPANDED_DIAGNOSIS_CODE,
					"[sss_handle_accept] accept failed");*/
			safe_print(printf("[%s][sss_handle_accept] - Error!\n",timestamp_str.c_str()));
			return 0;
		}
		else
		{
			tdbg("3\n");
			conn.at(i).fd = socket;
			conn.at(i).telnet_console_instance = i;
			conn.at(i).state = IN_PROCESS;
			conn.at(i).associated_port_index = socket_index_num;
			int nonblock = 1;
			int tcp_nodelay = LINNUX_TELNET_USE_TCP_NODELAY;
			int noackdelay = 1;
			int tcp_noackdelay = 1;;

			int errornum;
			if ((errornum = (int) t_setsockopt(conn.at(i).fd, SOL_SOCKET, SO_NONBLOCK, &nonblock,  1))== -1)
			{
				std::string timestamp_str = get_current_time_and_date_as_string_trimmed();

				safe_print(printf("[%s] sss_handle_accept: setsockopt error - socket options for socket [%d], result = [%d] errno = [%d]\n",timestamp_str.c_str(),i, errornum, t_errno(conn.at(i).fd)));
			}
			if ((errornum = (int) t_setsockopt(conn.at(i).fd, IPPROTO_TCP, TCP_NODELAY, &tcp_nodelay,  1))== -1)
			{
				std::string timestamp_str = get_current_time_and_date_as_string_trimmed();

				safe_print(printf("[%s] sss_handle_accept: setsockopt error - socket option TCP_NODELAY = [%d] for socket [%d], result = [%d] errno = [%d]\n",timestamp_str.c_str(),tcp_nodelay,i, errornum, t_errno(conn.at(i).fd)));
			}
			tdbg("5\n");
			/*
			if ((errornum = (int) t_setsockopt(conn.at(i).fd, IPPROTO_TCP, TCP_NOACKDELAY, &tcp_noackdelay,  1))== -1)
			{
				std::string timestamp_str = get_current_time_and_date_as_string_trimmed();

				safe_print(printf("[%s] sss_handle_accept: setsockopt error - socket option TCP_NOACKDELAY = [%d] for socket [%d], result = [%d] errno = [%d]\n",timestamp_str.c_str(),tcp_noackdelay,i, errornum, t_errno(conn.at(i).fd)));
			}
			*/
			if (put_telnet_in_a_safe_state) {
				std::string timestamp_str = get_current_time_and_date_as_string_trimmed();

				safe_print(printf("[%s][Telnet] exiting from sss_handle_accept\n",timestamp_str.c_str()));
				return 0;
			}
			sss_send_menu(&conn.at(i));
			std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
			num_of_open_sockets.at(socket_index_num) = num_of_open_sockets.at(socket_index_num) + 1;
			safe_print(printf("[%s][sss_handle_accept] accepted connection request from %s, to socket number %d (telnet index num %d, num open sockets for this telnet: %d)\n",timestamp_str.c_str(), inet_ntoa(incoming_addr.sin_addr),i,socket_index_num,num_of_open_sockets.at(socket_index_num)));
			tdbg("4\n");
		}
	}
	else
	{
		std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
		safe_print(printf("[%s] [sss_handle_accept] rejected connection request from %s\n",timestamp_str.c_str(), inet_ntoa(incoming_addr.sin_addr)));
	}
	tdbg("2\n");
	return 1;
}

/*
 * sss_exec_command()
 * 
 * This routine is called whenever we have new, valid receive data from our 
 * sss connection. It will parse through the data simply looking for valid
 * commands to the sss server.
 * 
 * Incoming commands to talk to the board LEDs are handled by sending the 
 * MicroC/OS-II SSSLedCommandQ a pointer to the value we received.
 * 
 * If the user wishes to quit, we set the "close" member of our SSSConn
 * struct, which will be looked at back in sss_handle_receive() when it 
 * comes time to see whether to close the connection or not.
 */
void telnet_process_object::sss_exec_command(SSSConn* conn, unsigned int the_telnet_index)
{
	if (telnet_post_queue[conn->associated_port_index] != NULL) {
				std::string cmdstr;
				tdbg("5b\n");
				INT8U error_code;
				telnet_job_record* telnet_job_record_ptr=NULL;

				telnet_job_record_ptr = new telnet_job_record;
				telnet_job_record_ptr->set_the_command(conn->rx_str);
				telnet_job_record_ptr->set_telnet_console_index(the_telnet_index);
				telnet_job_record_ptr->set_telnet_index(telnet_job_index);
				telnet_job_record_ptr->set_response_queue(telnet_pend_queue[conn->associated_port_index]);
				//safe_print(printf("in sss_exec_command, the_telnet_index= %d telnet_job_index = %d cmdstr = [%s]\n",(int)the_telnet_index,(int) telnet_job_index, conn->rx_str.c_str()));

				telnet_job_index++;

				error_code = OSQPost(telnet_post_queue[conn->associated_port_index], (void *)telnet_job_record_ptr);

				if (error_code != OS_NO_ERR) {
					std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
					safe_print(printf("[%s] [sss_exec_command] Error while posting command [%-100s] to ethernet, console is: [%d], error code is [%d]\n",timestamp_str.c_str(),telnet_job_record_ptr->get_the_command().c_str(),(int) (conn->telnet_console_instance), (int) error_code));
					delete telnet_job_record_ptr;
					telnet_job_record_ptr = NULL;
				}

				tdbg("6\n");

				//commented out: we will see commands anyway due to Linnux main cout
				//sss_send_string_to_remote_cout(conn,cmdstr->c_str());

				tdbg("7\n");
	}
	conn->rx_str = ""; //discard the string to make room ready for the next command
	return;
}


int string_recv(int fd, std::string& recvstr)
{
	char tmpbuf[2*SSS_RX_BUF_SIZE];
	int retcode;

	retcode = recv(fd, tmpbuf, SSS_RX_BUF_SIZE-2, 0);
	if (retcode > 0)
	{
		recvstr = std::string("").append(tmpbuf,retcode);
	}

	return retcode;
}

/*
 * sss_handle_receive()
 * 
 * This routine is called whenever there is a sss connection established and
 * the socket assocaited with that connection has incoming data. We will first
 * look for a newline "\n" character to see if the user has entered something 
 * and pressed 'return'. If there is no newline in the buffer, we'll attempt
 * to receive data from the listening socket until there is.
 * 
 * The connection will remain open until the user enters "Q\n" or "q\n", as
 * deterimined by repeatedly calling recv(), and once a newline is found, 
 * calling sss_exec_command(), which will determine whether the quit 
 * command was received.
 * 
 * Finally, each time we receive data we must manage our receive-side buffer.
 * New data is received from the sss socket onto the head of the buffer,
 * and popped off from the beginning of the buffer with the 
 * sss_exec_command() routine. Aside from these, we must move incoming
 * (un-processed) data to buffer start as appropriate and keep track of 
 * associated pointers.
 */



void telnet_process_object::sss_handle_receive(SSSConn* conn, int telnet_instance)
{
	int rx_code = 0;
	std::string::size_type lf_addr;
	std::string commandstr;

	int actual_errornum;

	temp_rx_buf = "";

	tdbg("8\n");
	//safe_print(printf("[sss_handle_receive] processing RX data for connection #%d\n",telnet_instance));


	tdbg("9\n");


	if (conn->state != CLOSE)
	{

		tdbg("10\n");

		/* Find the Carriage return which marks the end of the header */
		//  commandstr = (const char *)conn->rx_buffer;

		if((lf_addr = (conn->rx_str).find_first_of('\n')) != std::string::npos)
		{
			tdbg("11\n");
			//safe_print(printf("before sss_exec_command, telnet_instance - %d, lf_addr = %u, conn->rx_str=[%s]\n",(int) telnet_instance, (unsigned) lf_addr,conn->rx_str.c_str()));
			/* go off and do whatever the user wanted us to do */
			sss_exec_command(conn,telnet_instance);
			tdbg("12\n");
		}
		/* No newline received? Then ask the socket for data */
		else
		{
			tdbg("13\n");
			tdbg("15\n");
			rx_code = string_recv(conn->fd, temp_rx_buf);

			if (rx_code == -1)
			{
				actual_errornum = t_errno(conn->fd);

				if (actual_errornum != EWOULDBLOCK)
				{
					std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
					safe_print(printf("[%s] Telnet console#[%d]: RECV: Error is not EWOULDBLOCK = [%d], result = [%d] errno = [%d]\n",timestamp_str.c_str(), (int) telnet_instance,(int) EWOULDBLOCK,(int) rx_code, (int) actual_errornum));
					conn->non_ewouldblock_errs++;
					if (conn->non_ewouldblock_errs > MAX_NUM_CONN_NON_EWOULDBLOCK_ERRORS) {
						safe_print(printf("[%s][sss_handle_receive] Closing socket [%d] because a total of [%d] non ewouldblock socket errors occured\n",timestamp_str.c_str(), (int)conn->telnet_console_instance,(int)conn->non_ewouldblock_errs));
						conn->state=CLOSE;
					}
				} else {
					//safe_print(printf("."));
				}
			}

			tdbg("18\n");

			if(rx_code > 0)
			{
				tdbg("18a\n");
				(conn->rx_str).append(temp_rx_buf);
			}

			tdbg("18b\n");
			if((lf_addr = (conn->rx_str).find_first_of('\n')) != std::string::npos)
			{
				tdbg("11\n");
				//safe_print(printf("before sss_exec_command (2), telnet_instance - %d, lf_addr = %u, conn->rx_str=[%s]\n",(int) telnet_instance, (unsigned) lf_addr,conn->rx_str.c_str()));
				/* go off and do whatever the user wanted us to do */
				sss_exec_command(conn,telnet_instance);
				tdbg("12\n");
			}
			tdbg("20\n");

		}
		tdbg("21\n");

		tdbg("34\n");
		tdbg("35\n");
	}

	tdbg("36\n");

	//  safe_print(printf("[sss_handle_receive] closing connection\n"));
	//  close(conn->fd);
	//  tdbg("37\n");

	//  sss_reset_connection(conn);
	//  tdbg("38\n");

	return;
}
int telnet_process_object::fast_check_cout_to_telnet_pending(int socket_index_num)
{
	OS_Q_DATA linnux_queue_status;
	linnux_queue_status.OSMsg = NULL;

	OSQQuery(telnet_pend_queue.at(socket_index_num),&linnux_queue_status);

	return (linnux_queue_status.OSMsg != NULL);
}
void telnet_process_object::handle_linnux_cout_to_telnet(int socket_index_num)
{
	INT8U error_code;
	OS_Q_DATA linnux_queue_status;
	telnet_quit_command_encapsulator* stop_request_has_been_received = NULL;
	linnux_queue_status.OSMsg = NULL;
	stop_request_has_been_received = NULL;

	//safe_print(printf("Querying linnux queue\n"));
	OSQQuery(telnet_pend_queue.at(socket_index_num),&linnux_queue_status);
	tdbg("22\n");


	if (linnux_queue_status.OSMsg != NULL){
		sss_handle_linnux_data(socket_index_num);
	}

	tdbg("25\n");


	//Now check for a stop request
	if (command_feedback_queue.at(socket_index_num) != NULL)
	{
		do {
			if (stop_request_has_been_received != NULL) {
				delete stop_request_has_been_received;
				stop_request_has_been_received = NULL;
			}

			tdbg("26\n");
			stop_request_has_been_received =  (telnet_quit_command_encapsulator *) OSQAccept(command_feedback_queue.at(socket_index_num),&error_code);
			tdbg("27\n");

			if (error_code != OS_NO_ERR)
			{
				tdbg("28\n");
				stop_request_has_been_received = NULL;
			} else
			{
				tdbg("29\n");
				std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
				safe_print(std::cout << "[" << timestamp_str << "] Received request to end telnet session: [" << stop_request_has_been_received->get_telnet_console_index() << "] on port: ["  << telnet_port.at(socket_index_num) << "]" <<std::endl);
			}

			/*
			 * When the quit command is received, update our connection state so that
			 * we can exit the while() loop and close the connection
			 */
			tdbg("30\n");

			if (stop_request_has_been_received != NULL)
			{
				/*for (int i=0; i < conn.size(); i++) {
						  tdbg("30a\n");
									conn.at(i).close = 1;
									tdbg("30b\n");
						  }*/

				if (stop_request_has_been_received->get_telnet_console_index() >= MAX_NUM_OF_TELNET_SOCKETS) {
					std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
					safe_print(std::cout << "[" << timestamp_str << "] Error: received stop request for telent console ["<<stop_request_has_been_received->get_telnet_console_index()<<"] while there are only [" << MAX_NUM_OF_TELNET_SOCKETS << " consoles allowed!"<<std::endl);
					continue;
				} else if (conn[stop_request_has_been_received->get_telnet_console_index()].fd == -1) {
					std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
					safe_print(std::cout << "[" << timestamp_str << "] Warning: received stop request for telent console ["<<stop_request_has_been_received->get_telnet_console_index()<<"] but this console is not connected!"<<std::endl);
					continue;
				} else if (conn[stop_request_has_been_received->get_telnet_console_index()].associated_port_index != socket_index_num) {
					std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
					safe_print(std::cout << "[" << timestamp_str << "] Warning: received stop request for telent console ["<<stop_request_has_been_received->get_telnet_console_index()<<"] but while this console is connected, it is not connected to port: " << telnet_port.at(socket_index_num) <<std::endl);
					continue;
				}

				conn[stop_request_has_been_received->get_telnet_console_index()].close = 1;
				conn[stop_request_has_been_received->get_telnet_console_index()].state = CLOSE;
			}
			if (stop_request_has_been_received != NULL) { MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_MINIMAL_PROCESS_DLY_MS); };
			//MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_VERY_SHORT_PROCESS_DLY_MS);
		} while (stop_request_has_been_received != NULL);
	}
	return;
}


void telnet_process_object::sss_handle_linnux_data(int socket_index_num)
{
	INT8U error_code;
	std::string *the_new_str = NULL;
	std::string the_corrected_str;
	linnux_remote_command_response_container *the_returned_response=NULL;
	tdbg("39\n");
	//safe_print(printf("[sss_handle_linnux_data] processing Linnux data\n"));


	if (this->get_each_terminal_is_individual().at(socket_index_num)) {
		the_returned_response =  (linnux_remote_command_response_container *) OSQAccept(telnet_pend_queue.at(socket_index_num),&error_code);
		while ((the_returned_response != NULL) && (error_code == OS_NO_ERR))
		{
			the_corrected_str = the_returned_response->get_result_string();
			if (this->get_url_encode_terminal().at(socket_index_num)) {
			    the_corrected_str = cgicc::form_urlencode(the_corrected_str).append("\r\n");;
			} else {
				str_replace(the_corrected_str,"\n","\r\n");
			}
			//str_replace(the_corrected_str,"\n","\r\n");
			//std::cout << "received reply string: (" << reply_str << ") from syscon Terminal corrected_str = (" << the_corrected_str << ")" << std::endl;

			tdbg("42\n");

			for (int i=0; i < conn.size(); i++) {
				if ((conn.at(i).fd != -1) && (conn.at(i).state != CLOSE) && (conn.at(i).associated_port_index == socket_index_num) && (conn.at(i).telnet_console_instance == the_returned_response->get_telnet_console_index())) {
					sss_send_string_to_remote_cout(&conn.at(i),the_corrected_str);
				}
			}

			//sss_send_string_to_remote_cout(&conn.at(the_returned_response->get_telnet_console_index()),the_corrected_str);

			tdbg("43\n");
			if (the_returned_response != NULL) {
				delete the_returned_response;
				the_returned_response = NULL;
			}

			if (put_telnet_in_a_safe_state) {
				std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
				safe_print(printf("[%s] [Telnet] Exiting from sss_handle_linnux_data\n",timestamp_str.c_str()));
				return;
			}

			the_returned_response =  (linnux_remote_command_response_container *) OSQAccept(telnet_pend_queue.at(socket_index_num),&error_code);
			tdbg("44\n");
			MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_VERY_SHORT_PROCESS_DLY_MS);
		}

		if (the_returned_response != NULL) {
			delete the_returned_response;
			the_returned_response = NULL;
		}

	} else {
		the_new_str = (std::string *) OSQAccept(telnet_pend_queue.at(socket_index_num),&error_code);

		tdbg("40\n");
		while ((the_new_str != NULL) && (error_code == OS_NO_ERR))
		{
			tdbg("41\n");

			/*
			char *the_c_str;
			the_c_str = newline_fixer.Replace(the_new_str->c_str(),"\r\n");
			tdbg("41a\n");
			the_corrected_str = the_c_str;

			if (the_c_str != NULL)
			{
				my_mem_free(the_c_str);
			} else {
				if (the_new_str->length() > 0) {
					safe_print(printf("Warning: Telnet: found non-NULL string [%s] but c_str is NULL!",the_new_str->c_str()));
				}
			}
*/
			the_corrected_str = *the_new_str;
			if (this->get_url_encode_terminal().at(socket_index_num)) {
			    the_corrected_str = cgicc::form_urlencode(the_corrected_str).append("\r\n");;
			} else {
				str_replace(the_corrected_str,"\n","\r\n");
			}
			//std::cout << "received from linnux: (" << *the_new_str << ")  corrected_str = (" << the_corrected_str << ")" << std::endl;
			tdbg("42\n");

			for (int i=0; i < conn.size(); i++) {
				if ((conn.at(i).fd != -1) && (conn.at(i).state != CLOSE) && (conn.at(i).associated_port_index == socket_index_num)) {
					sss_send_string_to_remote_cout(&conn.at(i),the_corrected_str);
				}
			}

			tdbg("43\n");
			if (the_new_str != NULL) {
				delete the_new_str;
				the_new_str = NULL;
			}

			if (put_telnet_in_a_safe_state) {
				std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
				safe_print(printf("[%s] [Telnet] Exiting from sss_handle_linnux_data\n",timestamp_str.c_str()));
				return;
			}

			the_new_str = (std::string *)OSQAccept(telnet_pend_queue.at(socket_index_num),&error_code);
			tdbg("44\n");
			MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_VERY_SHORT_PROCESS_DLY_MS);
		}

		if (the_new_str != NULL) {
			delete the_new_str;
			the_new_str = NULL;
		}
	}
	tdbg("45\n");
	return;
}

/*
 * SSSSimpleSocketServerTask()
 * 
 * This MicroC/OS-II thread spins forever after first establishing a listening
 * socket for our sss connection, binding it, and listening. Once setup,
 * it perpetually waits for incoming data to either the listening socket, or
 * (if a connection is active), the sss data socket. When data arrives, 
 * the approrpriate routine is called to either accept/reject a connection 
 * request, or process incoming data.
 */

void telnet_process_object::SocketServerTask()
{
#if USE_SELECT_IN_SSS_FOR_PORTABILITY
	int max_socket = 0;
#endif
	fd_set readfds;
	int errornum;
	struct  timeval select_timeout;


	tdbg("46\n");
	// Set up DNS servers

	re_init_simple_socket_server:

	telnet_is_in_a_safe_state = 1;
	std::string timestamp_str = get_current_time_and_date_as_string_trimmed();

	safe_print(printf("[%s] [Telnet]Telnet is in a safe state!\n", timestamp_str.c_str()));
	while (put_telnet_in_a_safe_state) {
		MyOSTimeDlyHMSM(0,0,LINNUX_NETWORK_SAFE_STATE_DELAY_IN_SECONDS,0);
	}
	telnet_is_in_a_safe_state = 0;
	timestamp_str = get_current_time_and_date_as_string_trimmed();
	safe_print(printf("[%s] [Telnet]Telnet is functional\n", timestamp_str.c_str()));

	/*
	 * Sockets primer...
	 * The socket() call creates an endpoint for TCP of UDP communication. It
	 * returns a descriptor (similar to a file descriptor) that we call fd_listen,
	 * or, "the socket we're listening on for connection requests" in our sss
	 * server example.
	 *
	 * Traditionally, in the Sockets API, PF_INET and AF_INET is used for the
	 * protocol and address families respectively. However, there is usually only
	 * 1 address per protocol family. Thus PF_INET and AF_INET can be interchanged.
	 * In the case of NicheStack, only the use of AF_INET is supported.
	 * PF_INET is not supported in NicheStack.
	 */
	tdbg("47\n");

	for (int i = 0; i < number_of_telnet_sockets; i++) {

		if ((fd_listen.at(i) = socket(AF_INET, SOCK_STREAM, 0)) < 0)
		{
			alt_NetworkErrorHandler(EXPANDED_DIAGNOSIS_CODE,"[sss_task] Socket creation failed");
		}

		int reuse= 1;
		if ((errornum = (int) t_setsockopt(fd_listen.at(i), SOL_SOCKET, SO_REUSEADDR, &reuse,  1))== -1)
		{
			std::string timestamp_str = get_current_time_and_date_as_string_trimmed();

			safe_print(printf("[%s] [SSSSimpleSocketServerTask] setsockopt() to REUSE failed, error = %d, port_index = %d, port = %d\n", timestamp_str.c_str(), errornum, i, telnet_port.at(i)));
		}

		int nonblock = 1;
		if ((errornum = (int) t_setsockopt(fd_listen.at(i), SOL_SOCKET, SO_NONBLOCK, &nonblock,  1))== -1)
		{
			std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
			safe_print(printf("[%s] [SSSSimpleSocketServerTask] setsockopt() to NONBLOCK failed, error = %d, port_index = %d, port = %d\n", timestamp_str.c_str(), errornum, i, telnet_port.at(i)));
		}

		tdbg("48\n");
		/*
		 * Sockets primer, continued...
		 * Calling bind() associates a socket created with socket() to a particular IP
		 * port and incoming address. In this case we're binding to SSS_PORT and to
		 * INADDR_ANY address (allowing anyone to connect to us. Bind may fail for
		 * various reasons, but the most common is that some other socket is bound to
		 * the port we're requesting.
		 */
		addr.at(i)->sin_family = AF_INET;
		addr.at(i)->sin_port = htons(telnet_port.at(i));
		addr.at(i)->sin_addr.s_addr = INADDR_ANY;

		tdbg("49\n");
		if ((bind(fd_listen.at(i),(struct sockaddr *)addr.at(i),sizeof(struct sockaddr_in))) < 0)
		{
			tdbg("50\n");
			alt_NetworkErrorHandler(EXPANDED_DIAGNOSIS_CODE,"[sss_task] Telnet Socket Bind failed");

		}
		tdbg("51\n");
		/*
		 * Sockets primer, continued...
		 * The listen socket is a socket which is waiting for incoming connections.
		 * This call to listen will block (i.e. not return) until someone tries to
		 * connect to this port.
		 */
		if ((listen(fd_listen.at(i),1)) < 0)
			{
				tdbg("52\n");

				alt_NetworkErrorHandler(EXPANDED_DIAGNOSIS_CODE,"[sss_task] Listen failed");

			}
	}




	tdbg("53\n");
	/* At this point we have successfully created a socket which is listening
	 * on SSS_PORT for connection requests from any remote address.
	 */


	for(i=0; i<conn.size(); i++)
	{

		sss_reset_connection(&conn.at(i), i);

	}

	tdbg("54\n");
	timestamp_str = get_current_time_and_date_as_string_trimmed();
	for (i = 0; i < number_of_telnet_sockets; i++) {
		safe_print(printf("[%s] [sss_task] Simple Socket Server listening on port %d\n", timestamp_str.c_str(), telnet_port.at(i)));
    }

	tdbg("55\n");
	while(1)
	{
		/*
		 * For those not familiar with sockets programming...
		 * The select() call below basically tells the TCPIP stack to return
		 * from this call when any of the events I have expressed an interest
		 * in happen (it blocks until our call to select() is satisfied).
		 *
		 * In the call below we're only interested in either someone trying to
		 * connect to us, or data being available to read on a socket, both of
		 * these are a read event as far as select is called.
		 *
		 * The sockets we're interested in are passed in in the readfds
		 * parameter, the format of the readfds is implementation dependant
		 * Hence there are standard MACROs for setting/reading the values:
		 *
		 *   FD_ZERO  - Zero's out the sockets we're interested in
		 *   FD_SET   - Adds a socket to those we're interested in
		 *   FD_ISSET - Tests whether the chosen socket is set
		 */
		d(time_print("before select loop"));

		for (int current_select_iteration = 0; current_select_iteration < LINNUX_TELNET_SELECT_NUM_ITERATIONS; current_select_iteration++) {
#if USE_SELECT_IN_SSS_FOR_PORTABILITY
			    max_socket = 0;
#endif
		FD_ZERO(&readfds);
				for (int i = 0; i < number_of_telnet_sockets; i++)  {
										if (fast_check_cout_to_telnet_pending(i)) {
											d(time_print("before htd"));
											sss_handle_linnux_data(i);
											d(time_print("after htd"));

										}
									}

				for (int i = 0; i < number_of_telnet_sockets; i++)  {
		    FD_SET(fd_listen.at(i), &readfds);
#if USE_SELECT_IN_SSS_FOR_PORTABILITY

					if (max_socket <= fd_listen.at(i)) {
						max_socket = fd_listen.at(i)+1;
					}
#endif
		}


				for(unsigned int i=0; i<conn.size(); i++)
		{
			if (conn.at(i).fd != -1)
			{
				/* We're interested in reading any of our active sockets */

				FD_SET(conn.at(i).fd, &readfds);
#if USE_SELECT_IN_SSS_FOR_PORTABILITY

				/*
				 * select() must be called with the maximum number of sockets to look
				 * through. This will be the largest socket number + 1 (since we start
				 * at zero).
				 */
				if (max_socket <= conn.at(i).fd)
				{
					max_socket = conn.at(i).fd+1;
				}
#endif
			}
		}

		/*
		 * Set timeout value for select. This must be reset for each select()
		 * call.
		 */


				   select_timeout.tv_sec = 0;
				   select_timeout.tv_usec = LINNUX_TELNET_SELECT_USEC;
			//	   d(time_print("before select"));
#if USE_SELECT_IN_SSS_FOR_PORTABILITY
		select(max_socket, &readfds, NULL, NULL, &select_timeout);
#else
		d(time_print("before isel"));
				   t_select(&readfds, NULL, NULL,TSELECT_TIME_IN_SYSTEM_TICKS);
	    d(time_print("after isel"));
#endif
			//	   d(time_print("after select"));

				   for (int i = 0; i < number_of_telnet_sockets; i++)  {
				   				if (FD_ISSET(fd_listen.at(i), &readfds))
				   				{
				   				  goto handle_listen_event;
				   				}
				   }

				   for(unsigned int i=0; i<conn.size(); i++)
				   		{
				   			if (conn.at(i).fd != -1)
				   			{

				   				if(FD_ISSET(conn.at(i).fd,&readfds))
				   				{
					   				  goto handle_listen_event; //in case listen event AND other event happen; making no assumption about file descriptor order
				   				}
				   			}
				   		}
				    d(time_print("after post isel"));


		}
		d(time_print("after select loop"));
		/*
		 * If fd_listen (the listening socket we originally created in this thread
		 * is "set" in readfds, then we have an incoming connection request.
		 * We'll call a routine to explicitly accept or deny the incoming connection
		 * request.
		 */
handle_listen_event:

		if (put_telnet_in_a_safe_state) {
			goto re_init_simple_socket_server;
		}

		for (int i = 0; i < number_of_telnet_sockets; i++)  {
				if (FD_ISSET(fd_listen.at(i), &readfds))
				{
					if (put_telnet_in_a_safe_state) {
						goto re_init_simple_socket_server;
					}

					if (!sss_handle_accept(fd_listen.at(i), i)) {
						safe_print(printf("sss_handle_accept error. Gonna wait a while and then restart...\n"));
						MyOSTimeDlyHMSM(0,0,LINNUX_NETWORK_RECUPERATION_DELAY_IN_SECONDS,0);
						goto re_init_simple_socket_server;
					}

				}
		}


		/* First process any requests from the telnet sockets */
		for(unsigned int i=0; i<conn.size(); i++)
		{
			if (conn.at(i).fd != -1)
			{

				if(FD_ISSET(conn.at(i).fd,&readfds))
				{
					if (put_telnet_in_a_safe_state) {
						goto re_init_simple_socket_server;
					}
					d(time_print("before recv i = " << i));
					sss_handle_receive(&conn.at(i), i);
					d(time_print("after recv i = " << i));
					MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_VERY_SHORT_PROCESS_DLY_MS);

				}

			}

		}

		d(time_print("before handle_cout"));
		/* now handle any data from Linnux */
		for (int i = 0; i < number_of_telnet_sockets; i++)  {
		    handle_linnux_cout_to_telnet(i);
		}
		d(time_print("after handle_cout"));
		if (tcp_ip_services_to_shutdown &  LINNUX_TCPIP_SHUTDOWN_TELNET)
		{

			safe_print(printf("\n\nTelnet: shutting down all Telnet sockets!\n\n"));

			for(unsigned int i=0; i<conn.size(); i++)
			{
				if (conn.at(i).fd != -1)
				{
					conn.at(i).state = CLOSE;
					//t_shutdown(conn.at(i).fd,2);//shutdown both read and write
				}
			}
			tcp_ip_services_to_shutdown = (tcp_ip_services_to_shutdown & (~LINNUX_TCPIP_SHUTDOWN_TELNET));
		}

		for(unsigned int i=0; i<conn.size(); i++)
		{
			if (conn.at(i).fd != -1)
			{
				if (conn.at(i).state == CLOSE)
				{
					if (put_telnet_in_a_safe_state) {
						goto re_init_simple_socket_server;
					}
					t_shutdown(conn.at(i).fd,2);//shutdown both read and write
					close(conn.at(i).fd);
					num_of_open_sockets.at(conn.at(i).associated_port_index) = num_of_open_sockets.at(conn.at(i).associated_port_index) - 1;
					safe_print(printf("[%s] [sss_task] Shutting down socket %d associated index %d num_open_sockets_of_same %d\n", get_current_time_and_date_as_string_trimmed().c_str(), i,conn.at(i).associated_port_index,num_of_open_sockets.at(conn.at(i).associated_port_index)));
					sss_reset_connection(&conn.at(i),i);
				}
			}
		}

		MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_VERY_SHORT_PROCESS_DLY_MS);
		tdbg("64\n");
	} /* while(1) */
}

void CIN_MONITOR_Task(void *dummy)
{

	while (SSSLINNUXCINCommandQ == NULL)
	{

		MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_LONG_PROCESS_DLY_MS);

	}
	INT8U error_code;
	std::string *cmdstr = NULL;
	std::string  tmpstr;
	tdbg("cin 65\n");
	while(1)
	{
		tdbg("cin 66\n");
		tmpstr = "";
		my_cin_getline(std::cin, tmpstr);
		cmdstr = new std::string;
		*cmdstr = tmpstr;
		/*
		if (cmdstr->find("iniche_diag") == 0) {
			                         argument_str_pos_start = cmdstr->find(" ");
								     if (argument_str_pos_start != std::string::npos)
								     {
									    argument_str = cmdstr->substr(argument_str_pos_start + 1);
								     }
								     TrimSpaces(argument_str);
								     safe_print(printf(("\nExecuting iniche diagnostic command....\n")));
								     do_iniche_diag_command(argument_str);

		} else
		 */
		{
			error_code = OSQPost(SSSLINNUXCINCommandQ, (void *)cmdstr);
			if (error_code != OS_NO_ERR)
			{
				std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
				safe_print(printf("[%s] [CIN_MONITOR_Task] Error while posting command [%-100s] to ethernet, error code is [%d]\n",timestamp_str.c_str(),cmdstr->c_str(),(int) error_code));
				delete cmdstr;
				cmdstr = NULL;
			}

			tdbg("cin 67\n");
		}

		MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_MEDIUM_PROCESS_DLY_MS);

	}

	safe_print(printf( ("We should have never gotten here!\n")));
}



void DEVICE_MONITOR_Task(void *dummy)
{

	INT8U error_code;
	while(1)
	{
    	if (tcl_script_registered_DUT_diag_func) {
		     tcl_DUT_diag_cpp_wrapper_func();
		}
		MyOSTimeDlyHMSM(0,0,DEVICE_MONITOR_SLEEP_TIME_IN_SECS,0);
	}
	safe_print(printf("We should have never gotten here!\n"));
}



//===============================================
//
// UDP Streamer temp location
//

#ifdef UDP_INSERTER_0_BASE


#include "udp_streamer_telnet_interace.h"


//#include "in_utils.h"
#include "xprintf.h"

#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "altera_eth_tse_regs.h"
//#include <sys/alt_timestamp.h>

#include <stdio.h>
#include "basedef.h"

extern "C" {
#include "tcpport.h"
#include "demo_tasks.h"
#include "demo_control.h"
}

extern "C" {
u_long inet_addr(char far * str);

}

#define DEBUG_UDP_STREAM 1

#define dudp(x)  do { if (DEBUG_UDP_STREAM) { xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__);  x; xprintf("\n");} } while (0)

#define error_dudp(x)  do { if (1) { xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__);  x; xprintf("\n");} } while (0)

//
//	This server handler task is passed session requests from the main server
//	task.  This handler dialogs with the remote client to attempt to bring up a
//	hardware UDP stream.  If a stream cannot be initiated for some reason, then
//	this task will close the control session and await the next session request.
//	If a stream is initiated, then the task will wait until the remote client
//	requests a termination of the stream, at which point it will terminate the
//	hardware UDP stream and terminate the control session.
//
int udp_streamer_telnet_interace::start_udp_stream
(
	int	ip_addr_int_0, int ip_addr_int_1, int ip_addr_int_2, int ip_addr_int_3,
    alt_u32 the_dest_ip_port,
    void* aux_data_ptr
)
{
	unsigned long long end_time, start_time;
	unsigned long long total_runtime;

    OS_CPU_SR  cpu_sr = 0;

    if (generator_enable_func_pointer != NULL ) {
    	dudp(xprintf("Executing generator enable func!"));
         (*generator_enable_func_pointer)(aux_data_ptr);
    }
	this->set_the_destination_port(the_dest_ip_port & 0xFFFF); //just in case
    this->set_the_dest_ip((ip_addr_int_3 << 24) | (ip_addr_int_2 << 16) | (ip_addr_int_1 << 8) | (ip_addr_int_0));
    std::ostringstream ostr;
    ostr << ip_addr_int_0 << "." << ip_addr_int_1 <<  "." <<  ip_addr_int_2 <<  "." << ip_addr_int_3;
    this->set_the_dest_ip_str(ostr.str());

	// at this point it is in Network Byte Order (NBO)
	// allocate a local udp socket for our source port
	if(my_socket > 0) {														// we want to bind our UDP source port to a socket with our
		close(my_socket);													// local stack so that it doesn't get reused while we are
		dudp(xprintf("[start_udp_stream] closed previously open my_socket=%d", my_socket));
	}																		// using it, so we allocate ourselves a socket.  But first
	my_socket = socket(PF_INET, SOCK_DGRAM, 0);								// we close any sockets that we may have attempted to use
	dudp(xprintf("[start_udp_stream] my_socket=%d", my_socket));

	if(my_socket == -1) {													// already.  And if we can't allocate a socket, we deny the
		my_socket = 0;														// session request.
		perror("tx_command sht 4");
		return (LINNUX_RETVAL_ERROR);
	}

	// IP SOURCE ADDRESS
	my_src_ip = nets[0]->n_ipaddr;											// we dig our IP address out of the stack variables
	dudp(xprintf("[start_udp_stream] my_src_ip=%x dest_ip = %s\n", my_src_ip,this->get_the_dest_ip_str().c_str()));

	OS_ENTER_CRITICAL();
	// UDP SOURCE PORT
	my_source_port = htons(udp_socket());									// we get the stack to allocate us a UDP port as our source
	OS_EXIT_CRITICAL();
	dudp(xprintf("[start_udp_stream] my_source_port=%u", (unsigned) my_source_port));

	my_addr.sin_family = AF_INET;					// HBO					// and now we want to bind our IP address and UDP port to
	my_addr.sin_port = my_source_port;				// NBO					// the socket that we allocated
	my_addr.sin_addr.s_addr = my_src_ip;			// NBO
	memset(my_addr.sin_zero, '\0', sizeof my_addr.sin_zero);
	result = bind(my_socket, (struct sockaddr *)&my_addr, sizeof my_addr);	// if we can't bind to our socket then we deny the request
	dudp(xprintf("[start_udp_stream] bind result=%d", result));

	if(result == -1) {
		perror("tx_command sht 5");
		return (LINNUX_RETVAL_ERROR);
	}

    total_runtime = 0;

	start_time=os_critical_low_level_system_timestamp();
	alt_u8 b0, b1, b2 ,b3, b4, b5; //use this to avoid using at() within OS_ENTER_CRITICAL

	do {

	    	send_udp_message(this->get_the_dest_ip_str().c_str(), "dummy str", 7 /*well known echo port*/, 0); //send dummy udp packet; let's hope a side effect of this is to update the ARP table

			// lookup the first hop route for this destination
			result = (int)(iproute(the_dest_ip, &first_hop));						// a client on the other side of a router, or many routers,

			dudp(xprintf("iproute result = %d dest_ip = 0x%x first_hop = 0x%x\n",result,the_dest_ip,first_hop));

			if(result == 0) {
				// hop that our packets should be sent to for the
				dudp(xprintf("[start_udp_stream] error: iproute result=%d", result));
				perror("tx_command sht 5.1");
				return (LINNUX_RETVAL_ERROR);
			}

			 end_time=os_critical_low_level_system_timestamp();
			 if (start_time > end_time) {
								 // in case of some weird timer wrap
								 start_time = end_time;
			 }

			 total_runtime = (end_time - start_time);

	} while ((first_hop == 0) && (total_runtime < MAX_ARP_WAIT_FOR_NEW_ENTRY_TO_BE_RECEIVED_IN_IN_64_BIT_COUNTER_TICKS));

	if (total_runtime >= MAX_ARP_WAIT_FOR_NEW_ENTRY_TO_BE_RECEIVED_IN_IN_64_BIT_COUNTER_TICKS)
	{
		error_dudp(xprintf("[start_udp_stream] watchdog condition detected after %x ticks when trying to get iproute!\n",total_runtime));
		return (LINNUX_RETVAL_ERROR);
	}

	arpent = find_oldest_arp(first_hop);									// we want the MAC address for the first hop that our

	OS_ENTER_CRITICAL(); //try to avoid arpent changing

	if (arpent->t_pro_addr == first_hop) {
		// outbound packets should take
		// DEST MAC ADDRESS
		alt_u8 b0, b1, b2 ,b3, b4, b5; //use this to avoid using at() within OS_ENTER_CRITICAL
		b0 = arpent->t_phy_addr[0];
		b1 = arpent->t_phy_addr[1];
		b2 = arpent->t_phy_addr[2];
		b3 = arpent->t_phy_addr[3];
		b4 = arpent->t_phy_addr[4];
		b5 = arpent->t_phy_addr[5];

		OS_EXIT_CRITICAL();

		the_dest_mac.at(0) = b0;
		the_dest_mac.at(1) = b1;
		the_dest_mac.at(2) = b2;
		the_dest_mac.at(3) = b3;
		the_dest_mac.at(4) = b4;
		the_dest_mac.at(5) = b5;




	    dudp(xprintf
	    		("[start_udp_stream] arpent->t_phy_addr=%x:%x:%x:%x:%x:%x   first_hop = 0x%x",
	    				b0,
	    				b1,
	    				b2,
	    				b3,
	    				b4,
	    				b5,
						first_hop
	    			)
	    		);

	} else {																// if we can't locate the first hop MAC address, then we
		OS_EXIT_CRITICAL();

	    xprintf("error: arpent->t_pro_addr = %x first_hop = %x, trying make arp rout\n",arpent->t_pro_addr,first_hop);
//		perror("tx_command sht 6");
//		return (LINNUX_RETVAL_ERROR);
	}



		if (
				(the_dest_mac.at(0) == 0) &&
				(the_dest_mac.at(1) == 0) &&
				(the_dest_mac.at(2) == 0) &&
				(the_dest_mac.at(3) == 0) &&
				(the_dest_mac.at(4) == 0) &&
				(the_dest_mac.at(5) == 0)
			)
		{
			//try sending out udp messages to update ARP
			dudp(xprintf("[start_udp_stream] arpent->t_phy_addr is 0, trying alternate method"));

			total_runtime = 0;

		    start_time=os_critical_low_level_system_timestamp();

		    do {
		   	    end_time=os_critical_low_level_system_timestamp();
		   	    if (start_time > end_time) {
		   	     // in case of some weird timer wrap
		         start_time = end_time;
		   	    }
	 	        total_runtime = (end_time - start_time);

	 	   	    send_udp_message(this->get_the_dest_ip_str().c_str(), "dummy str", 7 /*well known echo port*/, 0); //send dummy udp packet; let's hope a side effect of this is to update the ARP table

	 	   		// lookup the first hop route for this destination
	 	   		result = (int)(iproute(the_dest_ip, &first_hop));						// a client on the other side of a router, or many routers,

	 	   		dudp(xprintf("iproute result = %d dest_ip = 0x%x first_hop = 0x%x\n",result,the_dest_ip,first_hop));


				arpent = find_oldest_arp(first_hop);									// we want the MAC address for the first hop that our

	 	     	OS_ENTER_CRITICAL();

	 			b0 = arpent->t_phy_addr[0];
	 			b1 = arpent->t_phy_addr[1];
	 			b2 = arpent->t_phy_addr[2];
	 			b3 = arpent->t_phy_addr[3];
	 			b4 = arpent->t_phy_addr[4];
	 			b5 = arpent->t_phy_addr[5];

	 			OS_EXIT_CRITICAL();

	 			the_dest_mac.at(0) = b0;
	 			the_dest_mac.at(1) = b1;
	 			the_dest_mac.at(2) = b2;
	 			the_dest_mac.at(3) = b3;
	 			the_dest_mac.at(4) = b4;
	 			the_dest_mac.at(5) = b5;


		    } while ((b0 == 0) &&
					 (b1 == 0) &&
					 (b2 == 0) &&
					 (b3 == 0) &&
					 (b4 == 0) &&
					 (b5 == 0) && (total_runtime < MAX_ARP_WAIT_FOR_NEW_ENTRY_TO_BE_RECEIVED_IN_IN_64_BIT_COUNTER_TICKS));
		 }

		if (total_runtime >= MAX_ARP_WAIT_FOR_NEW_ENTRY_TO_BE_RECEIVED_IN_IN_64_BIT_COUNTER_TICKS)
		{
			error_dudp(xprintf("[start_udp_stream] watchdog condition detected after %x ticks when trying to get nonzero address\n",total_runtime));
			return (LINNUX_RETVAL_ERROR);
		}
		 dudp(xprintf
			    		("[start_udp_stream] destination mac address =%x:%x:%x:%x:%x:%x   first_hop = 0x%x",
			    				the_dest_mac.at(0),
			    				the_dest_mac.at(1),
			    				the_dest_mac.at(2),
			    				the_dest_mac.at(3),
			    				the_dest_mac.at(4),
			    				the_dest_mac.at(5),
								first_hop
			    			)
			    		);

	// SOURCE MAC ADDRESS
	my_src_mac.at(0) = nets[0]->n_mib->ifPhysAddress[0];
	my_src_mac.at(1) = nets[0]->n_mib->ifPhysAddress[1];
	my_src_mac.at(2) = nets[0]->n_mib->ifPhysAddress[2];
	my_src_mac.at(3) = nets[0]->n_mib->ifPhysAddress[3];
	my_src_mac.at(4) = nets[0]->n_mib->ifPhysAddress[4];
	my_src_mac.at(5) = nets[0]->n_mib->ifPhysAddress[5];

	// start the udp payload inserter
	insert_stat.udp_dst    = the_destination_port;								// we fill out this insert_stat struct to pass into the
	insert_stat.udp_src    = my_source_port;											// payload inserter utility function
	insert_stat.ip_dst     = htonl(the_dest_ip);
	insert_stat.ip_src     = htonl(my_src_ip);
	insert_stat.mac_dst_hi = (the_dest_mac.at(0) << 24) | (the_dest_mac.at(1) << 16) | (the_dest_mac.at(2) << 8) | (the_dest_mac.at(3));
	insert_stat.mac_dst_lo = (the_dest_mac.at(4) << 8) | (the_dest_mac.at(5));
	insert_stat.mac_src_hi = (my_src_mac.at(0) << 24) |(my_src_mac.at(1) << 16) | (my_src_mac.at(2) << 8) | (my_src_mac.at(3));
	insert_stat.mac_src_lo = (my_src_mac.at(4) << 8) | (my_src_mac.at(5));
#ifdef UDP_INSERTER_0_BASE

	if( start_udp_payload_inserter((void *)udp_inserter_base, &insert_stat)) {
		perror("tx_command sht 7");
		return (LINNUX_RETVAL_ERROR);
	}
#endif																		// UDP stream his way
	current_state = UDP_STREAMER_IS_STREAMING;
	return (1);
}
int udp_streamer_telnet_interace::stop_udp_stream (void* aux_data_ptr) {
#ifdef UDP_INSERTER_0_BASE
	if( stop_udp_payload_inserter((void *) udp_inserter_base)) {
		perror("error stopping udp inserter");
		return (LINNUX_RETVAL_ERROR);
	}
#endif
	if (generator_disable_func_pointer != NULL ) {
	    	dudp(xprintf("Executing generator disable func!"));
	         (*generator_disable_func_pointer)(aux_data_ptr);
	}

	current_state = UDP_STREAMER_IDLE;
	return (1);

}
#endif

/******************************************************************************
 *                                                                             *
 * License Agreement                                                           *
 *                                                                             *
 * Copyright (c) 2006 Altera Corporation, San Jose, California, USA.           *
 * All rights reserved.                                                        *
 *                                                                             *
 * Permission is hereby granted, free of charge, to any person obtaining a     *
 * copy of this software and associated documentation files (the "Software"),  *
 * to deal in the Software without restriction, including without limitation   *
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
 * and/or sell copies of the Software, and to permit persons to whom the       *
 * Software is furnished to do so, subject to the following conditions:        *
 *                                                                             *
 * The above copyright notice and this permission notice shall be included in  *
 * all copies or substantial portions of the Software.                         *
 *                                                                             *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
 * DEALINGS IN THE SOFTWARE.                                                   *
 *                                                                             *
 * This agreement shall be governed in all respects by the laws of the State   *
 * of California and by the laws of the United States of America.              *
 * Altera does not recommend, suggest or require that this reference design    *
 * file be used in conjunction or combination with any other product.          *
 ******************************************************************************/
