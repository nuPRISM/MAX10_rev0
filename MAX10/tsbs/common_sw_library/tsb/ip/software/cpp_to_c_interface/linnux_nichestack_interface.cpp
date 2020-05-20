/*
 * linnux_nichestack_interface.cpp
 *
 *  Created on: Sep 28, 2011
 *      Author: linnyair
 */

#include "linnux_nichestack_interface.h"
#include "basedef.h"
#include "linnux_utils.h"
#include "linnux_main.h"
#include "handle_cgi_query_str.h"

extern "C" {
#include "simple_net_services/tcp_echo_server.h"
#include "simple_net_services/tcp_echo_client.h"
#include "simple_net_services/tcp_daytime_server.h"
#include "simple_net_services/udp_daytime_server.h"
#include "simple_net_services/udp_echo_server.h"
#include "simple_net_services/udp_echo_client.h"
}

#include "simple_net_services/tcp_chargen_server.h"
#include "simple_net_services/udp_chargen_server.h"
#include "simple_net_services/tcp_multiple_echo_server.h"

void linnux_main(void *pd)
{
	//try {
       bedrock_linnux_main(pd);
	//} catch (...) {
	//	printf("Caught exception in linnux_main\n");
	//}
}


void linnux_control_main(void *pd)
{
  bedrock_linnux_control_main(pd);
}


void linnux_response_main(void *pd)
{
  bedrock_handle_linnux_response(pd);
}


void linnux_dut_proc_control_main(void *pd)
{
	bedrock_dut_processor_control_main(pd);
}


void tcp_echo_server_main(void *pd)
{
	tcp_echo_server(TCP_ECHO_SERVER_DEFAULT_PORT);
}

void tcp_echo_client_main(void *pd)
{
	tcp_echo_client(TCP_ECHO_CLIENT_SERVER_IP, TCP_ECHO_CLIENT_ECHOSTR, TCP_ECHO_CLIENT_SERVER_PORT);
}


void udp_echo_server_main(void *pd)
{
	udp_echo_server(UDP_ECHO_SERVER_DEFAULT_PORT);
}

void udp_echo_client_main(void *pd)
{
	udp_echo_client(UDP_ECHO_CLIENT_SERVER_IP, UDP_ECHO_CLIENT_ECHOSTR, UDP_ECHO_CLIENT_SERVER_PORT);
}

void tcp_daytime_server_main(void *pd)
{
	tcp_daytime_server(TCP_DAYTIME_SERVER_DEFAULT_PORT);
}


void udp_daytime_server_main(void *pd)
{
	udp_daytime_server(UDP_DAYTIME_SERVER_DEFAULT_PORT);
}



void tcp_chargen_server_main(void *pd)
{
	tcp_chargen_server(TCP_CHARGEN_SERVER_DEFAULT_PORT);
}


void udp_chargen_server_main(void *pd)
{
	udp_chargen_server(UDP_CHARGEN_SERVER_DEFAULT_PORT);
}


void udp_daytime_client_main(void *pd)
{
	udp_echo_client(UDP_ECHO_CLIENT_SERVER_IP, UDP_ECHO_CLIENT_ECHOSTR, UDP_DAYTIME_CLIENT_DEFAULT_PORT);
}


void udp_chargen_client_main(void *pd)
{
	udp_echo_client(UDP_ECHO_CLIENT_SERVER_IP, UDP_ECHO_CLIENT_ECHOSTR, UDP_CHARGEN_CLIENT_DEFAULT_PORT);
}

void tcp_multiple_echo_server_main(void *pd)
{
 tcp_multiple_echo_server(TCP_MULTIPLE_ECHO_SERVER_TIMEOUT_SEC,tcp_mutliple_echo_server_port_list);
}


void c_os_critical_low_level_system_usleep(unsigned long num_us)
{
	os_critical_low_level_system_usleep(num_us);
}

 void c_write_green_led_state_to_leds() {write_green_led_state_to_leds(); } ;
 void c_write_red_led_state_to_leds() { write_red_led_state_to_leds();};
 void c_write_red_led_pattern (unsigned long the_pattern){ write_red_led_pattern(the_pattern);};
 void c_write_green_led_pattern (unsigned long the_pattern) {write_green_led_pattern(the_pattern);};
 unsigned long c_get_green_led_state() { return get_green_led_state(); } ;
 unsigned long c_get_red_led_state() { return get_red_led_state(); };
 unsigned long c_read_switches() { return read_switches(); };

