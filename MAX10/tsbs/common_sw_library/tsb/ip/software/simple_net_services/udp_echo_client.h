/*
 * udp_echo_client.h
 *
 *  Created on: Aug 12, 2012
 *      Author: user
 */

#ifndef UDP_ECHO_CLIENT_H_
#define UDP_ECHO_CLIENT_H_


int udp_echo_client(const char *servIP, const char* echoString, int echoServPort);
int send_udp_message(const char *servIP, const char* echoString, int echoServPort, int check_for_reply);


#endif /* TCP_ECHO_CLIENT_H_ */
