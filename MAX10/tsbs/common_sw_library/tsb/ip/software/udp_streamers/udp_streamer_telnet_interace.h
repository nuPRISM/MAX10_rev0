/*
 * udp_streamer_telnet_interace.h
 *
 *  Created on: Oct 22, 2013
 *      Author: yairlinn
 */

#ifndef UDP_STREAMER_TELNET_INTERACE_H_
#define UDP_STREAMER_TELNET_INTERACE_H_


	/* MicroC/OS-II definitions */
//#include "includes.h"
//	/* Nichestack definitions */
extern "C" {
#include "ipport.h"
#include "system.h"
#include "tcpport.h"
#include "osport.h"
#include "bsdsock.h"
#include "demo_tasks.h"
#include "demo_control.h"

}


//#include "alt_types.h"

#include <stdio.h>
#include <string>
//#include <sstream>
#include <vector>

typedef int (*upp_packet_generator_control_function)(void * aux_data);

typedef enum {UDP_STREAMER_IDLE, UDP_STREAMER_IS_STREAMING} udp_streamer_states;

class udp_streamer_telnet_interace {
protected:
	int                 my_stream_index;
	int                 result;
	int                 numbytes;
	udp_streamer_states                 current_state;
	ip_addr             my_src_ip;
	std::string         my_src_ip_str;
	alt_u16             my_source_port;
	alt_u16             the_destination_port;
	ip_addr             the_dest_ip;
	std::string         the_dest_ip_str;
	ip_addr             first_hop;
	int                 my_socket;
	struct sockaddr_in  my_addr;
	struct arptabent   *arpent;
	std::vector<alt_u8> the_dest_mac;
	std::vector<alt_u8> my_src_mac;
	UDP_INS_STATS insert_stat;
    alt_u32 udp_inserter_base;
    upp_packet_generator_control_function generator_enable_func_pointer;
    upp_packet_generator_control_function generator_disable_func_pointer;
public:

    udp_streamer_telnet_interace() {
    	the_dest_mac.resize(6,0); //set to 00:00:00:00:00:00
	    my_src_mac.resize(6,0);   //set to 00:00:00:00:00:00
	    my_socket = 0;
	    arpent = NULL;
	    current_state = UDP_STREAMER_IDLE;
	    generator_enable_func_pointer  = NULL;
	    generator_disable_func_pointer = NULL;
    };


	int start_udp_stream(int,int,int,int, alt_u32,void *);
	int stop_udp_stream (void *);

	upp_packet_generator_control_function get_generator_disable_func_pointer() const {
		return generator_disable_func_pointer;
	}

	void set_generator_disable_func_pointer(
			upp_packet_generator_control_function generatorDisableFuncPointer) {
		generator_disable_func_pointer = generatorDisableFuncPointer;
	}

	upp_packet_generator_control_function get_generator_enable_func_pointer() const {
		return generator_enable_func_pointer;
	}

	void set_generator_enable_func_pointer(
			upp_packet_generator_control_function generatorEnableFuncPointer) {
		generator_enable_func_pointer = generatorEnableFuncPointer;
	}

	std::string get_my_src_ip_str() const {
		return my_src_ip_str;
	}

	void set_my_src_ip_str(std::string mySrcIpStr) {
		my_src_ip_str = mySrcIpStr;
	}

	std::string get_the_dest_ip_str() const {
		return the_dest_ip_str;
	}

	void set_the_dest_ip_str(std::string theDestIpStr) {
		the_dest_ip_str = theDestIpStr;
	}

	struct arptabent* get_arpent() const {
		return arpent;
	}

	void set_arpent(struct arptabent* arpent) {
		this->arpent = arpent;
	}

	udp_streamer_states get_current_state() const {
		return current_state;
	}

	void set_current_state(udp_streamer_states currentState) {
		current_state = currentState;
	}

	ip_addr get_first_hop() const {
		return first_hop;
	}

	void set_first_hop(ip_addr firstHop) {
		first_hop = firstHop;
	}

	UDP_INS_STATS get_insert_stat() const {
		return insert_stat;
	}

	void set_insert_stat(UDP_INS_STATS insertStat) {
		insert_stat = insertStat;
	}

	struct sockaddr_in get_my_addr() const {
		return my_addr;
	}

	void set_my_addr(struct sockaddr_in myAddr) {
		my_addr = myAddr;
	}

	int get_my_socket() const {
		return my_socket;
	}

	void set_my_socket(int mySocket) {
		my_socket = mySocket;
	}

	alt_u16 get_my_source_port() const {
		return my_source_port;
	}

	void set_my_source_port(alt_u16 mySourcePort) {
		my_source_port = mySourcePort;
	}

	ip_addr get_my_src_ip() const {
		return my_src_ip;
	}

	void set_my_src_ip(ip_addr mySrcIp) {
		my_src_ip = mySrcIp;
	}

	std::vector<alt_u8> get_my_src_mac() const {
		return my_src_mac;
	}

	void set_my_src_mac(std::vector<alt_u8> mySrcMac) {
		my_src_mac = mySrcMac;
	}

	int get_my_stream_index() const {
		return my_stream_index;
	}

	void set_my_stream_index(int myStreamIndex) {
		my_stream_index = myStreamIndex;
	}

	int get_numbytes() const {
		return numbytes;
	}

	void set_numbytes(int numbytes) {
		this->numbytes = numbytes;
	}

	int get_result() const {
		return result;
	}

	void set_result(int result) {
		this->result = result;
	}

	ip_addr get_the_dest_ip() const {
		return the_dest_ip;
	}

	void set_the_dest_ip(ip_addr theDestIp) {
		the_dest_ip = theDestIp;
	}

	std::vector<alt_u8> get_the_dest_mac() const {
		return the_dest_mac;
	}

	void set_the_dest_mac(std::vector<alt_u8> theDestMac) {
		the_dest_mac = theDestMac;
	}

	alt_u16 get_the_destination_port() const {
		return the_destination_port;
	}

	void set_the_destination_port(alt_u16 theDestinationPort) {
		the_destination_port = theDestinationPort;
	}

	alt_u32 get_udp_inserter_base() const {
		return udp_inserter_base;
	}

	void set_udp_inserter_base(alt_u32 udpInserterBase) {
		udp_inserter_base = udpInserterBase;
	}

};

#endif /* UDP_STREAMER_TELNET_INTERACE_H_ */
