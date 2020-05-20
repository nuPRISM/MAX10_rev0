/*
 * tcp_multiple_echo_server.h
 *
 *  Created on: Aug 19, 2012
 *      Author: user
 */

#ifndef TCP_MULTIPLE_ECHO_SERVER_H_
#define TCP_MULTIPLE_ECHO_SERVER_H_

#include <vector>
int tcp_multiple_echo_server(long timeout, std::vector<unsigned> port_list);
extern std::vector<unsigned> tcp_mutliple_echo_server_port_list;

#endif /* TCP_MULTIPLE_ECHO_SERVER_H_ */
