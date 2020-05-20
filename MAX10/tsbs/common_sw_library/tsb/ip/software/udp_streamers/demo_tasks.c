#include "demo_tasks.h"
#include "demo_control.h"

/* Nichestack definitions */
#include "ipport.h"
#include "libport.h"
#include "osport.h"
#include "bsdsock.h"

#include "system.h"
#include "basedef.h"
#include "xprintf.h"
#define DEBUG_UDP_STREAM 1

extern int do_not_start_prbs_generator_0;

#define dudp(x)  do { if (DEBUG_UDP_STREAM) { xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__);  x; xprintf("\n");} } while (0)
//
//	Arrange our base addresses into arrays so we can easily extract them by
//	channel association.
//


void *inserter_bases[4] = {
#ifdef UDP_INSERTER_0_BASE
		(void *)UDP_INSERTER_0_BASE,
		(void *)UDP_INSERTER_1_BASE,
		(void *)UDP_INSERTER_2_BASE,
		(void *)UDP_INSERTER_3_BASE
#else
		 0,0,0,0
#endif
};

//
//	This function is a utility called by the client and server tasks to send
//	a TCP message to the remote device.  It basically mimics the functionality
//	of send(), however, it will wait for all of the send data to be sent prior
//	to returning.  If send() returns an error, then we simply return that error
//	as well.
//	
int tx_command(int fd, char *buffer, int length, int flags) {
	int result;
	int total_sent = 0;
    dudp(xprintf("[tx_command] sending fd = (%d)  buffer = (%s) length = (%d) flags = (%x)", fd, buffer, length, flags));

	while(total_sent < length) {
		result = send(fd, buffer + total_sent, length - total_sent, flags);
		if (result == -1) {
			perror("tx_command");
			return(-1);
		}
		total_sent += result;
	}
	
	return(total_sent);
}

//
//	This function is a utility called by the client and server tasks to receive
//	a TCP message from the remote device.  It basically mimics the
//	functionality of recv(), however, it will not return until it receives an
//	entire command from the remote server or client.  Complete commands are
//	simply delimited with <>, so for every < that is received, we assume that
//	it represents the begining of a command and we flush any previously
//	accumulated data, after we have a < then we wait until we see a > to close
//	the command.  If recv() ever returns an error to us, the we simply return
//	that error to our caller.
//	
static int rx_response(int fd, char *buffer, int length, int flags) {
	int result;
	int buffer_level = 0;
	int saw_start = 0;
	int saw_end = 0;
	
	while((!saw_start) || (!saw_end)) {
		buffer[buffer_level] = '\0';
		result = recv(fd, buffer + buffer_level, 1, flags);
		if (result == -1) {
			perror("rx_response");
			return(-1);
		}
		if(result == 0) {
			return(0);
		}
		if(buffer[buffer_level] != '\0') {
			if(buffer[buffer_level] == '<') {			// if we see a command start delimiter
				saw_start = 1;							// we set the start state
				saw_end = 0;							// we clear the end state
				buffer[0] = '<';						// we put the command start delimiter at location ZERO
				buffer_level = 1;						// and we set the buffer level to ONE
			} else if(buffer[buffer_level] == '>') {	// if we see a command end delimiter
				saw_end = 1;							// we set the end state
				buffer_level++;							// and we increment the buffer level
			} else {
				buffer_level++;							// otherwise we just increment the buffer level
			}
			if(buffer_level == length) {				// if we hit the buffer limit, we purge everything
				saw_start = 0;							// we clear the start state
				saw_end = 0;							// we clear the end state
				buffer_level = 0;						// and we reset the buffer level
			}
		}
	}
	buffer[buffer_level] = '\0';	// terminate the response string
    dudp(xprintf("[rx_response] buffer_level = (%d) sending fd = (%d)  buffer = (%s) length = (%d) flags = (%x)", buffer_level, fd, buffer, length, flags));
	return(buffer_level);
}

/* 
 * Declarations for creating a task with TK_NEWTASK.  
 * All tasks which use NicheStack (those that use sockets) must be created this way.
 * TK_OBJECT macro creates the static task object used by NicheStack during operation.
 * TK_ENTRY macro corresponds to the entry point, or defined function name, of the task.
 * inet_taskinfo is the structure used by TK_NEWTASK to create the task.
 */

//
// BEGIN SERVER CODE
//

TK_ENTRY(stream_server_task);							// entry point for our main server task
TK_OBJECT(to_stream_server_task);
struct inet_taskinfo the_stream_server_task = {			// main server task structure
      &to_stream_server_task,
      "stream server",
      stream_server_task,
      STREAM_SERVER_TASK_PRIORITY,
      UDP_STREAM_APP_STACK_SIZE,
};

volatile struct sockaddr_in server_session_addr[4];		// these arrays will act as channel
volatile int server_session_fd[4] = { 0 };				// allocation queues for our server

OS_EVENT *server_handler_Mbox;							// this mailbox will synchronize server handler tasks

TK_ENTRY(server_handler_task);							// entry point for our server handler tasks

TK_OBJECT(to_server_handler_task_0);
struct inet_taskinfo the_server_handler_task_0 = {		// server handler task 0
      &to_server_handler_task_0,
      "server handler 0",
      server_handler_task,
      SERVER_HANDLER_TASK_0_PRIORITY,
      UDP_STREAM_APP_STACK_SIZE,
};

TK_OBJECT(to_server_handler_task_1);
struct inet_taskinfo the_server_handler_task_1 = {		// server handler task 1
      &to_server_handler_task_1,
      "server handler 1",
      server_handler_task,
      SERVER_HANDLER_TASK_1_PRIORITY,
      UDP_STREAM_APP_STACK_SIZE,
};

TK_OBJECT(to_server_handler_task_2);
struct inet_taskinfo the_server_handler_task_2 = {		// server handler task 2
      &to_server_handler_task_2,
      "server handler 2",
      server_handler_task,
      SERVER_HANDLER_TASK_2_PRIORITY,
      UDP_STREAM_APP_STACK_SIZE,
};

TK_OBJECT(to_server_handler_task_3);
struct inet_taskinfo the_server_handler_task_3 = {		// server handler task 3
      &to_server_handler_task_3,
      "server handler 3",
      server_handler_task,
      SERVER_HANDLER_TASK_3_PRIORITY,
      UDP_STREAM_APP_STACK_SIZE,
};

//
//	This main server task is contacted by a remote client requesting a hardware
//	UDP stream session.  If this task has an available stream channel, it will
//	hand the stream request off to a server handler task to setup the stream
//	for the remote client.  Once this tasks hands off the request, or denys the
//	request because it is already totally allocated, it will continue to wait
//	for remote requests.
//
void stream_server_task(void *task_data) {

	int public_listen_fd;
	int public_connect_fd;
	struct sockaddr_in my_public_addr;
	struct sockaddr_in their_public_addr;
	int sin_size;
	ip_addr my_ip_addr;
	int result;
	int session_index;
	alt_u8 os_error;
	
	//
	// start up handler tasks
	//
	server_handler_Mbox = OSMboxCreate((void*)(0));
	TK_NEWTASK(&the_server_handler_task_0);
	TK_NEWTASK(&the_server_handler_task_1);
	TK_NEWTASK(&the_server_handler_task_2);
	TK_NEWTASK(&the_server_handler_task_3);
    dudp(xprintf("[stream_server_task] created server tasks\n"));
	//
	// setup the server listener
	//
	
	// first make sure that there's only one network interface for us to use
	if(ifNumber != 1) {
		printf("expected 1 network interfaces...\n");
		while(1);
	}
		
	// extract our IP address for this interface
	my_ip_addr = nets[0]->n_ipaddr;
	dudp(xprintf("[stream_server_task] my_ip_addr = (%x)\n", my_ip_addr));
	
	// open a TCP socket for listening
	public_listen_fd = socket(PF_INET, SOCK_STREAM, 0);
	if (public_listen_fd == -1) {
		perror("socket");
		while(1);
	}
	dudp(xprintf("[stream_server_task] public_listen_fd = (%d)\n", public_listen_fd));

	// configure our public address and port information for the socket
	my_public_addr.sin_family = AF_INET;						// HBO
	my_public_addr.sin_port = htons(STREAM_SERVER_PUBLIC_PORT);	// NBO
	my_public_addr.sin_addr.s_addr = my_ip_addr;				// NBO - public network address
	memset(my_public_addr.sin_zero, '\0', sizeof my_public_addr.sin_zero);
	dudp(xprintf("[stream_server_task] my_public_addr.sin_family = (%u) my_public_addr.sin_port = (%u) my_public_addr.sin_addr.s_addr = (%u)\n", my_public_addr.sin_family,my_public_addr.sin_port,my_public_addr.sin_addr.s_addr));

	// bind this address and port to the TCP socket
	result = bind(public_listen_fd, (struct sockaddr *)&my_public_addr, sizeof my_public_addr);
	dudp(xprintf("[stream_server_task] bind result = (%d)", result));

	if (result == -1) {
		perror("bind public");
		while(1);
	}
	
	// open the socket for listening
	result = listen(public_listen_fd, 4);
	dudp(xprintf("[stream_server_task] listen result = (%d)", result));
	if (result == -1) {
		perror("listen public");
		while(1);
	}

	while(1) {
		
		// accept connections to our server socket
		sin_size = sizeof their_public_addr;
		public_connect_fd = accept(public_listen_fd, (struct sockaddr *)&their_public_addr, &sin_size);
		dudp(xprintf("[stream_server_task] accept public_connect_fd = (%d)", public_connect_fd));
		if (public_connect_fd == -1) {
			perror("accept");
			continue;
		}
		
		// locate an open channel to assign to this session
		for(session_index = 0 ; session_index < 4 ; session_index++) {
			if(!(server_session_fd[session_index])) {
				server_session_fd[session_index] = public_connect_fd;
				server_session_addr[session_index] = their_public_addr;
				// assign this session to the next handler task
				os_error = OSMboxPost(server_handler_Mbox, (void *)(session_index + 1));
				if(os_error != OS_NO_ERR) {
					xprintf("[stream_server_task] OS ERROR on MBOX post %d\n", os_error);
				}
				break;
			}
		}
		
		// if there were no open channels then signal busy to this session and close it
		if(session_index == 4) {
			dudp(xprintf("[stream_server_task]session_index == 4, closing"));

			result = tx_command(public_connect_fd, BUSY_STR, BUSY_STR_SIZE, 0);
			if (result == -1)
				perror("tx_command sst");
			
			close(public_connect_fd);
		}
	}
}

//
//	This server handler task is passed session requests from the main server
//	task.  This handler dialogs with the remote client to attempt to bring up a
//	hardware UDP stream.  If a stream cannot be initiated for some reason, then
//	this task will close the control session and await the next session request.
//	If a stream is initiated, then the task will wait until the remote client
//	requests a termination of the stream, at which point it will terminate the
//	hardware UDP stream and terminate the control session.
//	

void server_handler_task(void *task_data) {
	/*
	int my_stream_index;
	alt_u8 Mbox_error;
	int my_fd;
	int result;
	char response_buf[32];
	int numbytes;
	int current_state;
	alt_u32 requested_port;
	alt_u32 requested_stream;
	alt_u32 requested_packet_length;
	alt_u16 my_source_port;
	alt_u16 the_destination_port;
	int my_socket = 0;
	struct sockaddr_in my_addr;
	struct arptabent *arpent;
	ip_addr the_dest_ip;
	ip_addr first_hop;
	ip_addr my_src_ip;
	alt_u8 the_dest_mac[6];
	alt_u8 my_src_mac[6];
	UDP_INS_STATS insert_stat;
    OS_CPU_SR  cpu_sr = 0;

	while(1) {
		// wait for the next session to be handed to us
		my_stream_index = (int)(OSMboxPend(server_handler_Mbox, 0, &Mbox_error));
		dudp(xprintf("[server_handler_task] my_stream_index = (%d)", my_stream_index));
		if(my_stream_index == 0) {
			printf("Mbox pointer was null, index %d\n", my_stream_index);
			continue;
		}
		// get the FD for the socket handling this TCP session
		// the stream index can be decremented and used as the array index
		my_stream_index -= 1;
		my_fd = server_session_fd[my_stream_index];
		
		// send the BEGIN string to the other end so they know we've accepted the session
		result = tx_command(my_fd, BEGIN_STR, BEGIN_STR_SIZE, 0);
		dudp(xprintf("[server_handler_task] tx_command BEGIN result=%d", result));

		if (result == -1) {
			// if we get a failure on the send, we give up and close the socket
			perror("tx_command sht 1");
		} else {
			// if we still have an open socket then we start off in the BEGIN state
			current_state = BEGIN_STATE;
			do {
				// wait for something to come over from the other side
				numbytes = rx_response(my_fd, response_buf, 32, 0);
				dudp(xprintf("[server_handler_task] rx_response numbytes=%d", numbytes));
				if(numbytes == -1) {
					// if we get an error, print this out and we're done
					perror("rx_response sht");
				}
				if(numbytes > 0) {
					// make sure that we have a terminated string
					response_buf[numbytes] = '\0';
					if(current_state == BEGIN_STATE) {												// BEGIN STATE
						if(strncmp(response_buf, RELEASE_STR, RELEASE_STR_SIZE) == 0) {				// first check to see if remote client wants to terminate
							result = tx_command(my_fd, END_STR, END_STR_SIZE, 0);					// the session request
							dudp(xprintf("[server_handler_task] tx_response numbytes=%d", result));

							if (result == -1)
								perror("tx_command sht 2");
							numbytes = 0;
							continue;
						} else if(strncmp(response_buf, REQUEST_STR, REQUEST_STR_SIZE) == 0) {		// in the begin state we expect to see a REQEUST string 
							// convert the requested destination UDP port							// from the remote client
							char *start_of_stream_index = NULL;
							requested_port = strtoul(response_buf + REQUEST_STR_SIZE, &start_of_stream_index, 16);	// the request string should have the remote client's UDP
							dudp(xprintf("[server_handler_task] requested_port=%u", requested_port));

							if(requested_port > 0xFFFF) {											// port for us to send to as our destination UDP port
								result = tx_command(my_fd, HUH_STR, HUH_STR_SIZE, 0);				// the UDP port must be a 16-bit value or else we have a
								if (result == -1)													// problem, and we reply with a HUH string
									perror("tx_command sht 3");
								continue;
							}
							// UDP DEST PORT
							the_destination_port = requested_port & 0xFFFF;							// well save this off as our UDP dest port for this session

							if ((start_of_stream_index == NULL) || (*start_of_stream_index==NULL))  {
								result = tx_command(my_fd, HUH_STR, HUH_STR_SIZE, 0);				// the UDP port must be a 16-bit value or else we have a
																if (result == -1)													// problem, and we reply with a HUH string
																	perror("strm index not fnd ");
																continue;
							}
							requested_stream = strtoul(start_of_stream_index+1, NULL, 16);	          // look for stream index
							dudp(xprintf("[requested_stream] requested_stream=%u", requested_stream));

							if(requested_stream > NUM_UDP_STREAMING_STREAMS) {											// port for us to send to as our destination UDP port
								result = tx_command(my_fd, HUH_STR, HUH_STR_SIZE, 0);				// the UDP port must be a 16-bit value or else we have a
								if (result == -1)													// problem, and we reply with a HUH string
									perror("req stream too big");
								continue;
							}

							// at this point it is in Network Byte Order (NBO)
							// allocate a local udp socket for our source port
							if(my_socket > 0) {														// we want to bind our UDP source port to a socket with our
								close(my_socket);													// local stack so that it doesn't get reused while we are
							}																		// using it, so we allocate ourselves a socket.  But first
							my_socket = socket(PF_INET, SOCK_DGRAM, 0);								// we close any sockets that we may have attempted to use
							dudp(xprintf("[server_handler_task] my_socket=%d", my_socket));

							if(my_socket == -1) {													// already.  And if we can't allocate a socket, we deny the
								my_socket = 0;														// session request.
								result = tx_command(my_fd, DENY_STR, DENY_STR_SIZE, 0);
								if (result == -1)
									perror("tx_command sht 4");
								continue;
							}
	
							// IP SOURCE ADDRESS
							my_src_ip = nets[0]->n_ipaddr;											// we dig our IP address out of the stack variables
							dudp(xprintf("[server_handler_task] my_src_ip=%u", my_src_ip));

						    OS_ENTER_CRITICAL();
							// UDP SOURCE PORT
							my_source_port = htons(udp_socket());									// we get the stack to allocate us a UDP port as our source
						    OS_EXIT_CRITICAL();
							dudp(xprintf("[server_handler_task] my_source_port=%u", (unsigned) my_source_port));

							my_addr.sin_family = AF_INET;					// HBO					// and now we want to bind our IP address and UDP port to
							my_addr.sin_port = my_source_port;				// NBO					// the socket that we allocated
							my_addr.sin_addr.s_addr = my_src_ip;			// NBO
							memset(my_addr.sin_zero, '\0', sizeof my_addr.sin_zero);
							result = bind(my_socket, (struct sockaddr *)&my_addr, sizeof my_addr);	// if we can't bind to our socket then we deny the request
							dudp(xprintf("[server_handler_task] bind result=%d", result));

							if(result == -1) {
								result = tx_command(my_fd, DENY_STR, DENY_STR_SIZE, 0);
								if (result == -1)
									perror("tx_command sht 5");
								continue;
							}
							
							//
							// get the destination mac address
							//
							// IP DEST ADDRESS														// we get the destination IP address out of the session
							the_dest_ip = server_session_addr[my_stream_index].sin_addr.s_addr;		// request information passed into us.
							dudp(xprintf("[server_handler_task] the_dest_ip=%u", the_dest_ip));

							// lookup the first hop route for this destination
						    OS_ENTER_CRITICAL();													// since we could be in a routed network sending data to
							result = (int)(iproute(the_dest_ip, &first_hop));						// a client on the other side of a router, or many routers,
						    OS_EXIT_CRITICAL();														// we ask the stack to give us the IP address of the first
						    dudp(xprintf("[server_handler_task] iproute result=%d", result));
							if(result == 0) {														// hop that our packets should be sent to for the 
								result = tx_command(my_fd, DENY_STR, DENY_STR_SIZE, 0);				// destination IP address that we are sending to.
								if (result == -1)
									perror("tx_command sht 5.1");
								continue;
							}
							
							// get the MAC address from the arp table
						    OS_ENTER_CRITICAL();
							arpent = find_oldest_arp(first_hop);									// we want the MAC address for the first hop that our

							if (arpent->t_pro_addr == first_hop) {									// outbound packets should take
								// DEST MAC ADDRESS
								memmove(&the_dest_mac, arpent->t_phy_addr, 6);
							    dudp(xprintf
							    		("[server_handler_task] arpent->t_phy_addr=%x:%x:%x:%x:%x:%x",
							    				arpent->t_phy_addr[0],
							    				arpent->t_phy_addr[1],
							    				arpent->t_phy_addr[2],
							    				arpent->t_phy_addr[3],
							    				arpent->t_phy_addr[4],
							    				arpent->t_phy_addr[5]));

							} else {																// if we can't locate the first hop MAC address, then we
							    OS_EXIT_CRITICAL();													// deny the request
								result = tx_command(my_fd, DENY_STR, DENY_STR_SIZE, 0);
								if (result == -1)
									perror("tx_command sht 6");
								continue;
							}
						    OS_EXIT_CRITICAL();
							
							// SOURCE MAC ADDRESS
							memmove(&my_src_mac, nets[0]->n_mib->ifPhysAddress, 6);					// we dig our own MAC address out of the stack variables
	
							my_source_port = htons(my_source_port);									// we need the IP addresses and UDP ports in Network Byte
							the_dest_ip = htonl(the_dest_ip);										// order for the UDP Payload Insertion peripheral.
							my_src_ip = htonl(my_src_ip);
	
							// start the udp payload inserter
							insert_stat.udp_dst = the_destination_port;								// we fill out this insert_stat struct to pass into the 
							insert_stat.udp_src = my_source_port;									// payload inserter utility function
							insert_stat.ip_dst = the_dest_ip;
							insert_stat.ip_src = my_src_ip;
							insert_stat.mac_dst_hi = (the_dest_mac[0] << 24) | (the_dest_mac[1] << 16) | (the_dest_mac[2] << 8) | (the_dest_mac[3]);
							insert_stat.mac_dst_lo = (the_dest_mac[4] << 8) | (the_dest_mac[5]);
							insert_stat.mac_src_hi = (my_src_mac[0] << 24) | (my_src_mac[1] << 16) | (my_src_mac[2] << 8) | (my_src_mac[3]);
							insert_stat.mac_src_lo = (my_src_mac[4] << 8) | (my_src_mac[5]);
							
							if(start_udp_payload_inserter(inserter_bases[my_stream_index], &insert_stat)) {
								result = tx_command(my_fd, DENY_STR, DENY_STR_SIZE, 0);				// if we can't start the payload inserter we deny
								if (result == -1)
									perror("tx_command sht 7");
								continue;
							}
							result = tx_command(my_fd, ACCEPT_STR, ACCEPT_STR_SIZE, 0);				// if we get to this point we're good to go so we send an
							if (result == -1)														// ACCEPT string to the client, indicating that we've set
								perror("tx_command sht 8");											// everything up on our end, and we're ready to send a
																									// UDP stream his way
							current_state = ESTABLISHED_STATE;
							continue;
						} else {
							result = tx_command(my_fd, HUH_STR, HUH_STR_SIZE, 0);					// if we don't see a REQUEST string we respond with HUH
							if (result == -1)
								perror("tx_command sht 9");
							continue;
						}
					} else if(current_state == ESTABLISHED_STATE) {									// ESTABLISHED STATE
						if(strncmp(response_buf, RELEASE_STR, RELEASE_STR_SIZE) == 0) {				// first check to see if remote client wants to terminate
							if(stop_udp_payload_inserter(inserter_bases[my_stream_index])) {		// the session request
								printf("error stopping inserter\n");
							}
							result = tx_command(my_fd, END_STR, END_STR_SIZE, 0);
							if (result == -1)
								perror("tx_command sht 10");
							numbytes = 0;
							continue;
						} else if(strncmp(response_buf, START_STR, START_STR_SIZE) == 0) {			// in the established state we expect to see a START string
							// convert the requested packet length									// from the remote client, with a packet length in it
							requested_packet_length = strtoul(response_buf + START_STR_SIZE, NULL, 16);
							if(requested_packet_length > 1472) {									// the packet length can be from 0 to 1472 or we have a
								result = tx_command(my_fd, DENY_STR, DENY_STR_SIZE, 0);				// problem and we deny the request
								if (result == -1)
									perror("tx_command sht 11");
								continue;
							}
	                      if (!do_not_start_prbs_generator_0) {
								if(start_packet_generator(generator_bases[my_stream_index], (alt_u16)requested_packet_length, 0x33557799)) {
									result = tx_command(my_fd, DENY_STR, DENY_STR_SIZE, 0);				// if we have any trouble starting the packet generator
									if (result == -1)													// we deny the request
										perror("tx_command sht 12");
									continue;
								}
	                         } else {
	                        	 printf("PRBS 0 not started due to user request!\n");
	                         }
							result = tx_command(my_fd, START_ACK_STR, START_ACK_STR_SIZE, 0);		// if everything went OK with our stream startup, then we
							if (result == -1)														// reply back with a START_ACK string
								perror("tx_command sht 13");
	
							current_state = START_STATE;
							continue;
						} else {
							result = tx_command(my_fd, HUH_STR, HUH_STR_SIZE, 0);					// if we didn't see a START string then we reply with HUH
							if (result == -1)
								perror("tx_command sht 14");
						}
					} else if(current_state == START_STATE) {										// START STATE
						if(strncmp(response_buf, RELEASE_STR, RELEASE_STR_SIZE) == 0) {				// first check to see if remote client wants to terminate
							if(stop_packet_generator(generator_bases[my_stream_index])) {			// the session.  If it does, we will disable the packet
								printf("error stopping inserter\n");								//  generator and wait for it to indicate that it is stopped
							}
							wait_until_packet_generator_stops_running(generator_bases[my_stream_index]);
							if(stop_udp_payload_inserter(inserter_bases[my_stream_index])) {
								printf("error stopping inserter\n");
							}
							result = tx_command(my_fd, END_STR, END_STR_SIZE, 0);					// our response is the END string
							if (result == -1)
								perror("tx_command sht 15");
							numbytes = 0;
							continue;
						} else if(strncmp(response_buf, STOP_STR, STOP_STR_SIZE) == 0) {			// in the start state, we expect to see a STOP string
							if(stop_packet_generator(generator_bases[my_stream_index])) {			// whenever the client wants to halt the UDP stream
								printf("error stopping inserter\n");								// at which point we will disable the packet generator and
							}																		// wait for it to indicate that it is stopped
							wait_until_packet_generator_stops_running(generator_bases[my_stream_index]);
							result = tx_command(my_fd, STOP_STR, STOP_STR_SIZE, 0);					// our response is the STOP string
							if (result == -1)
								perror("tx_command sht 16");
							continue;
						} else {																	// if we didn't see a STOP string we reply with HUH
							result = tx_command(my_fd, HUH_STR, HUH_STR_SIZE, 0);
							if (result == -1)
								perror("tx_command sht 17");
						}
					}
				} else {																			// if the response we got was ZERO bytes, then the socket
					if(current_state == ESTABLISHED_STATE) {										// has probably been closed, so we tear down everything
						if(stop_udp_payload_inserter(inserter_bases[my_stream_index])) {			// that we've built up to this point, from the established
							printf("error stopping inserter\n");									// state, that simply means stopping the packet inserter
						}
						result = tx_command(my_fd, END_STR, END_STR_SIZE, 0);						// and then we respond with END
						if (result == -1)
							perror("tx_command sht 18");
						continue;
					}
					else if(current_state == START_STATE) {											// in the start state, we first stop the packet generator
						if(stop_packet_generator(generator_bases[my_stream_index])) {				// and wait for it to indicate that it is stopped
							printf("error stopping inserter\n");
						}
						wait_until_packet_generator_stops_running(generator_bases[my_stream_index]);
						if(stop_udp_payload_inserter(inserter_bases[my_stream_index])) {			// and then we stop the packet inserter
							printf("error stopping inserter\n");
						}
						result = tx_command(my_fd, END_STR, END_STR_SIZE, 0);						// and then we respond with END
						if (result == -1)
							perror("tx_command sht 19");
						continue;
					}
				}
			} while(numbytes > 0);																	// we keep listening to this socket as long as we see data
		}
	
		close(my_fd);																				// when we're done, we close our TCP socket
		
		if(my_socket) {																				// and if we allocated a UDP socket, we close that as well
			close(my_socket);
			my_socket = 0;
		}
		
		server_session_fd[my_stream_index] = 0;														// and we release the channel back to the main server task
	}
	*/
}

//
// BEGIN CLIENT CODE
//

OS_EVENT *stream_client_Mbox;							// these two mailboxes are used to synchronize
OS_EVENT *client_request_Mbox;							// the applications with the main client task

TK_ENTRY(stream_client_task);							// entry point for our main client task
TK_OBJECT(to_stream_client_task);
struct inet_taskinfo the_stream_client_task = {			// main client task structure
      &to_stream_client_task,
      "stream client",
      stream_client_task,
      STREAM_CLIENT_TASK_PRIORITY,
      UDP_STREAM_APP_STACK_SIZE,
};

volatile client_request client_session[4];				// these arrays will act as channel
volatile int client_session_fd[4] = { 0 };				// allocation queues for our client

OS_EVENT *client_handler_Mbox;							// this mailbox will synchronize our client handler tasks

TK_ENTRY(client_handler_task);							// entry point for our client handler tasks

TK_OBJECT(to_client_handler_task_0);					// client handler task 0
struct inet_taskinfo the_client_handler_task_0 = {
      &to_client_handler_task_0,
      "client handler 0",
      client_handler_task,
      CLIENT_HANDLER_TASK_0_PRIORITY,
      UDP_STREAM_APP_STACK_SIZE,
};

TK_OBJECT(to_client_handler_task_1);					// client handler task 1
struct inet_taskinfo the_client_handler_task_1 = {
      &to_client_handler_task_1,
      "client handler 1",
      client_handler_task,
      CLIENT_HANDLER_TASK_1_PRIORITY,
      UDP_STREAM_APP_STACK_SIZE,
};

TK_OBJECT(to_client_handler_task_2);					// client handler task 2
struct inet_taskinfo the_client_handler_task_2 = {
      &to_client_handler_task_2,
      "client handler 2",
      client_handler_task,
      CLIENT_HANDLER_TASK_2_PRIORITY,
      UDP_STREAM_APP_STACK_SIZE,
};

TK_OBJECT(to_client_handler_task_3);					// client handler task 3
struct inet_taskinfo the_client_handler_task_3 = {
      &to_client_handler_task_3,
      "client handler 3",
      client_handler_task,
      CLIENT_HANDLER_TASK_3_PRIORITY,
      UDP_STREAM_APP_STACK_SIZE,
};

//
//	This main client task is sent requests from local applications to initiate
//	a hardware UDP stream from a remote server.  If this task has an available
//	stream channel, it will hand the request off to a client handler task to
//	initiate the stream from the remote server.  Once this task hands off the
//	request, or denys the request because it is already totally allocated, it
//	will continue to wait for local application requests.
//	
void stream_client_task(void *task_data) {

	int public_connect_fd;
	int session_index;
	alt_u8 os_error;
	volatile client_request the_client_request;
	volatile client_request *client_request_ptr;

	// start up handler tasks
	client_request_Mbox = OSMboxCreate((void*)(0));
	stream_client_Mbox = OSMboxCreate((void*)(0));
	client_handler_Mbox = OSMboxCreate((void*)(0));
	TK_NEWTASK(&the_client_handler_task_0);
	TK_NEWTASK(&the_client_handler_task_1);
	TK_NEWTASK(&the_client_handler_task_2);
	TK_NEWTASK(&the_client_handler_task_3);

	while(1) {
		// make the client_request mailbox available to a request
		os_error = OSMboxPost(client_request_Mbox, (void *)(&the_client_request));
		if(os_error != OS_NO_ERR) {
			printf("OS ERROR on MBOX post for client_request %d\n", os_error);
		}
		
		// wait for a request to be posted
		client_request_ptr = (client_request *)(OSMboxPend(stream_client_Mbox, 0, &os_error));

		if(client_request_ptr == 0) {
			printf("Mbox pointer was null, index\n");
			continue;
		}

		// make sure requestors are using our pointer and not something bogus
		if(client_request_ptr != &the_client_request) {
			printf("Mbox pointer does not equal the_client_request\n");
			continue;
		}
		
		// make sure the packet length is within the allowable range
		if(client_request_ptr->packet_length > 1472) {
			ns_printf((void*)&(client_request_ptr->pio), "\nPacket Length cannot exceed 1472, stream not opened...\n");
			continue;
		}
		
		// assign this request to the next available channel handler
		for(session_index = 0 ; session_index < 4 ; session_index++) {
			if(!(client_session_fd[session_index])) {						// if we found a free handler
				public_connect_fd = socket(PF_INET, SOCK_STREAM, 0);		// allocate a TCP socket for the channel handler
				if (public_connect_fd == -1) {								// and if we can't get one we're stuck
					perror("socket");
					while(1);
				}
				client_session_fd[session_index] = public_connect_fd;
				client_session[session_index] = *client_request_ptr;
				// assign the request to the handler
				os_error = OSMboxPost(client_handler_Mbox, (void *)(session_index + 1));
				if(os_error != OS_NO_ERR) {
					printf("OS ERROR on MBOX post %d\n", os_error);
				}
				break;
			}
		}
		
		// if there were no available channel handlers, then we discard the request
		if(session_index == 4) {
			ns_printf((void*)&(client_request_ptr->pio), "\nAll RX channels currently used, cannot start a new stream...\n");
		}
	}
}

//	
//	This client handler task is passed sesssion requests from the main client
//	task.  This handler dialogs with the remote server to attempt to bring up a
//	hardware UDP stream.  If a stream cannot be initiated for some reason, then
//	this task will close the control session and await the next request.  If a
//	stream is initiated, then the task will wait until the remote server sends
//	a termination acknowledgement, at which point this task will termiate the
//	local UDP hardware stream and terminate the control session.
//	
//	Note that once this client handler has established the stream, it waits for
//	the server to send a termination acknowledgement.  It is assumed that some
//	application on this device will send a termination request to the server to
//	request the stream termination.  This task does not manage that termination
//	request.
//

void client_handler_task(void *task_data) {
/*
	struct sockaddr_in their_public_addr;
	int my_stream_index;
	alt_u8 Mbox_error;
	int my_fd;
	int result;
	char response_buf[32];
	int numbytes;
	alt_u16 my_source_port;
	int my_socket = 0;
	struct sockaddr_in my_addr;
	ip_addr my_src_ip;
    OS_CPU_SR  cpu_sr = 0;

	while(1) {
		// wait for the next request to be handed to us
		my_stream_index = (int)(OSMboxPend(client_handler_Mbox, 0, &Mbox_error));
		if(my_stream_index == 0) {
			printf("Mbox pointer was null, index %d\n", my_stream_index);
			continue;
		}
		
		// get our socket FD for this channel
		// we can decrement the stream index and use that as the array index
		my_stream_index -= 1;
		my_fd = client_session_fd[my_stream_index];

		// build the remote address structure
		their_public_addr.sin_family = AF_INET;													// HBO
		their_public_addr.sin_port = htons(STREAM_SERVER_PUBLIC_PORT);							// NBO
		their_public_addr.sin_addr.s_addr = htonl(client_session[my_stream_index].ip_address);	// NBO
		memset(their_public_addr.sin_zero, '\0', sizeof their_public_addr.sin_zero);
		
		// connect with the remote server
		result = connect(my_fd, (struct sockaddr *)&their_public_addr, sizeof their_public_addr);
		if (result == -1) {
			ns_printf((void*)&(client_session[my_stream_index].pio), "\nCould not connect to remote host, stream not started...\n");
			close(my_fd);
			client_session_fd[my_stream_index] = 0;
			continue;
		}

		// wait for the opening dialog response from the server
		numbytes = rx_response(my_fd, response_buf, 32, 0);
		if((numbytes == -1) || (numbytes == 0)) {
			ns_printf((void*)&(client_session[my_stream_index].pio), "\nError receiving from server, stream not started...\n");
			close(my_fd);
			client_session_fd[my_stream_index] = 0;
			continue;
		}
		// if we don't get the BEGIN string then shut everything down and close the socket
		if(strncmp(response_buf, BEGIN_STR, BEGIN_STR_SIZE) != 0) {
			result = tx_command(my_fd, RELEASE_STR, RELEASE_STR_SIZE, 0);
			if (result == -1)
				perror("c-tx_command 1");
			ns_printf((void*)&(client_session[my_stream_index].pio), "\nDid not receive proper protocol from server, stream not started...\n");
			close(my_fd);
			client_session_fd[my_stream_index] = 0;
			continue;
		}
		
		//
		// send request to server to receive on a udp port that we allocate
		//
		
		// start by allocating a UDP socket															// we allocate a local socket and bind a UDP port to it so
		my_socket = socket(PF_INET, SOCK_DGRAM, 0);													// that nothing else on this device will attempt to use
		if (my_socket == -1) {																		// this port for anything else while we're using it
			result = tx_command(my_fd, RELEASE_STR, RELEASE_STR_SIZE, 0);
			if (result == -1)
				perror("c-tx_command 2");
			ns_printf((void*)&(client_session[my_stream_index].pio), "\nCould not allocate a local UDP socket, stream not started...\n");
			close(my_fd);
			client_session_fd[my_stream_index] = 0;
			continue;
		}
		// IP SOURCE ADDRESS
		my_src_ip = nets[0]->n_ipaddr;																// we dig our IP address out of the stack variables
		
		OS_ENTER_CRITICAL();
		// UDP SOURCE PORT
		my_source_port = htons(udp_socket());														// we have the stack allocate us a UDP port number to use
	    OS_EXIT_CRITICAL();

		my_addr.sin_family = AF_INET;					// HBO
		my_addr.sin_port = my_source_port;				// NBO
		my_addr.sin_addr.s_addr = my_src_ip;			// NBO
		memset(my_addr.sin_zero, '\0', sizeof my_addr.sin_zero);
		
		result = bind(my_socket, (struct sockaddr *)&my_addr, sizeof my_addr);						// we bind our UDP port to our socket
		if(result == -1) {
			result = tx_command(my_fd, RELEASE_STR, RELEASE_STR_SIZE, 0);							// if this doesn't work we signal RELEASE to the server
			if (result == -1)
				perror("c-tx_command 3");
			ns_printf((void*)&(client_session[my_stream_index].pio), "\nCould not bind the local UDP socket, stream not started...\n");
			close(my_fd);
			close(my_socket);
			client_session_fd[my_stream_index] = 0;
			continue;
		}
								
		sprintf(response_buf, "%s0x%04X >", REQUEST_STR, ntohs(my_source_port));					// now we send our request to the server with our newly
		result = tx_command(my_fd, response_buf, strlen(response_buf), 0);							// allocated UDP port number
		if (result == -1) {
			result = tx_command(my_fd, RELEASE_STR, RELEASE_STR_SIZE, 0);
			if (result == -1)
				perror("c-tx_command 4");
			ns_printf((void*)&(client_session[my_stream_index].pio), "\nError while sending to remote server, stream not started...\n");
			close(my_fd);
			close(my_socket);
			client_session_fd[my_stream_index] = 0;
			continue;
		}
		
		numbytes = rx_response(my_fd, response_buf, 32, 0);
		if((numbytes == -1) || (numbytes == 0)) {													// make sure we don't have socket problems
			result = tx_command(my_fd, RELEASE_STR, RELEASE_STR_SIZE, 0);
			if (result == -1)
				perror("c-tx_command 5");
			ns_printf((void*)&(client_session[my_stream_index].pio), "\nError while sending to remote server, stream not started...\n");
			close(my_fd);
			close(my_socket);
			client_session_fd[my_stream_index] = 0;
			continue;
		}
		if(strncmp(response_buf, ACCEPT_STR, ACCEPT_STR_SIZE) != 0) {								// we expect to see the ACCEPT response from the server
			result = tx_command(my_fd, RELEASE_STR, RELEASE_STR_SIZE, 0);
			if (result == -1)
				perror("c-tx_command 6");
			ns_printf((void*)&(client_session[my_stream_index].pio), "\nError while sending to remote server, stream not started...\n");
			close(my_fd);
			close(my_socket);
			client_session_fd[my_stream_index] = 0;
			continue;
		}
		
		// setup our receive hardware before we request the stream to start
		// enable the checker
		result = start_packet_checker(checker_bases[my_stream_index]);								// configure our local hardware to receive the stream
		if(result) {																				// that we've requested by starting the packet checker
			result = tx_command(my_fd, RELEASE_STR, RELEASE_STR_SIZE, 0);
			if (result == -1)
				perror("c-tx_command 7");
			ns_printf((void*)&(client_session[my_stream_index].pio), "\nError while starting local packet checker, stream not started...\n");
			close(my_fd);
			close(my_socket);
			client_session_fd[my_stream_index] = 0;
			continue;
		}
		
		result = clear_udp_payload_extractor_counter (extractor_bases[my_stream_index]);			// clear the extractor status
		if(result) {
			stop_packet_checker(checker_bases[my_stream_index]);
			result = tx_command(my_fd, RELEASE_STR, RELEASE_STR_SIZE, 0);
			if (result == -1)
				perror("c-tx_command 8");
			ns_printf((void*)&(client_session[my_stream_index].pio), "\nError while clearing payload extractor counter, stream not started...\n");
			close(my_fd);
			close(my_socket);
			client_session_fd[my_stream_index] = 0;
			continue;
		}
																									// map our UDP port number into the hardware mapper
		result = map_udp_port_to_channel((void*)(UDP_MAPPER_BASE), (alt_u32)my_stream_index, ntohs(my_source_port));
		if(result) {
			stop_packet_checker(checker_bases[my_stream_index]);
			result = tx_command(my_fd, RELEASE_STR, RELEASE_STR_SIZE, 0);
			if (result == -1)
				perror("c-tx_command 9");
			ns_printf((void*)&(client_session[my_stream_index].pio), "\nError while mapping local udp into hardware, stream not started...\n");
			close(my_fd);
			close(my_socket);
			client_session_fd[my_stream_index] = 0;
			continue;
		}
																									// and send our start request to the server with the packet
		// send start and packet length																// length that the request contained
		sprintf(response_buf, "%s0x%04X >", START_STR, (unsigned int)(client_session[my_stream_index].packet_length));
		result = tx_command(my_fd, response_buf, strlen(response_buf), 0);
		if (result == -1) {
			result = tx_command(my_fd, RELEASE_STR, RELEASE_STR_SIZE, 0);
			if (result == -1)
				perror("c-tx_command 10");
			ns_printf((void*)&(client_session[my_stream_index].pio), "\nError while sending to remote server, stream not started...\n");
			close(my_fd);
			close(my_socket);
			client_session_fd[my_stream_index] = 0;
			continue;
		}
		
		numbytes = rx_response(my_fd, response_buf, 32, 0);											// make sure we don't have socket issues
		if((numbytes == -1) || (numbytes == 0)) {
			result = tx_command(my_fd, RELEASE_STR, RELEASE_STR_SIZE, 0);							// or else we release the session
			if (result == -1)
				perror("c-tx_command 11");
			
			// wait for end response to ensure stream has stopped transmitting
			numbytes = rx_response(my_fd, response_buf, 32, 0);
			// we should check the response but not much we can do about it

			disable_udp_port_to_channel_mapping((void*)(UDP_MAPPER_BASE), (alt_u32)my_stream_index);//and we undo all the hardware setup that we've done
			stop_packet_checker(checker_bases[my_stream_index]);
			
			ns_printf((void*)&(client_session[my_stream_index].pio), "\nError while sending to remote server, stream not started...\n");
			close(my_fd);
			close(my_socket);
			client_session_fd[my_stream_index] = 0;
			continue;
		}
		if(strncmp(response_buf, START_ACK_STR, START_ACK_STR_SIZE) != 0) {							// we expect to see a START_ACK response
			result = tx_command(my_fd, RELEASE_STR, RELEASE_STR_SIZE, 0);							// or else we release the session
			if (result == -1)
				perror("c-tx_command 12");
			
			// wait for end response to ensure stream has stopped transmitting
			numbytes = rx_response(my_fd, response_buf, 32, 0);
			// we should check the response but not much we can do about it

			disable_udp_port_to_channel_mapping((void*)(UDP_MAPPER_BASE), (alt_u32)my_stream_index);// and we undo all the hardware setup that we've done
			stop_packet_checker(checker_bases[my_stream_index]);
			
			ns_printf((void*)&(client_session[my_stream_index].pio), "\nError while sending to remote server, stream not started...\n");
			close(my_fd);
			close(my_socket);
			client_session_fd[my_stream_index] = 0;
			continue;
		}
		
		ns_printf((void*)&(client_session[my_stream_index].pio), "\nStream started on channel %d...\n", my_stream_index);
	
		while(1) {																					// now we simply wait for the stream termination ack from
			// wait for end response to ensure stream has stopped transmitting						// the server, or the control socket to close
			numbytes = rx_response(my_fd, response_buf, 32, 0);
			if((numbytes == -1) || (numbytes == 0)) {
				disable_udp_port_to_channel_mapping((void*)(UDP_MAPPER_BASE), (alt_u32)my_stream_index);
				stop_packet_checker(checker_bases[my_stream_index]);
				
				ns_printf((void*)&(client_session[my_stream_index].pio), "\nStream %d has been shut down uncleanly...\n", my_stream_index);
				close(my_fd);
				close(my_socket);
				client_session_fd[my_stream_index] = 0;
				break;
			} else if(strncmp(response_buf, END_STR, END_STR_SIZE) == 0) {
				disable_udp_port_to_channel_mapping((void*)(UDP_MAPPER_BASE), (alt_u32)my_stream_index);
				stop_packet_checker(checker_bases[my_stream_index]);
				
				ns_printf((void*)&(client_session[my_stream_index].pio), "\nStream %d has been shut down cleanly...\n", my_stream_index);
				close(my_fd);
				close(my_socket);
				client_session_fd[my_stream_index] = 0;
				break;
			}
		}
	}
	*/
}

