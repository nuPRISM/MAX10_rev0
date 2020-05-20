/*
 * linnux_server_dns_utils.cpp
 *
 *  Created on: Nov 17, 2011
 *      Author: linnyair
 */

#include "basedef.h"
#include "linnux_server_dns_utils.h"
#include <stdio.h>
extern "C" {
#include <ipport.h>
#include "tcpport.h"
#include <dns.h>

}
using namespace std;

unsigned int get_ip_byte(unsigned int ip, int the_byte)
{
	unsigned int outbyte;

	switch (the_byte) {
	case 0 : outbyte = ip&0xff; break;
	case 1 : outbyte = ((ip>>8)&0xff); break;
	case 2 : outbyte = ((ip>>16)&0xff); break;
	case 3 : outbyte = (ip>>24); break;
    }

    return outbyte;
}
unsigned int get_LINNUX_BOARD_IPADDR(int byte_num)
{

	unsigned long current_ip = nets[0]->n_ipaddr;
	unsigned int retval;
	switch (byte_num) {
	case 0:
	case 1:
	case 2:
	case 3: retval =  get_ip_byte(current_ip,byte_num);  break;
	default: safe_print(printf("[get_LINNUX_BOARD_IPADDR]: invalid parameter: %d\n",byte_num)); retval = 0xff; break;
	}
	return retval;
}



unsigned int get_LINNUX_BOARD_GWADDR(int byte_num)
{
	unsigned long default_gateway = nets[0]->n_defgw;
	unsigned int retval;
	switch (byte_num) {
	case 0:
	case 1:
	case 2:
	case 3: retval =  get_ip_byte(default_gateway,byte_num);  break;
	default: safe_print(printf("[get_LINNUX_BOARD_GWADDR]: invalid parameter: %d\n",byte_num)); retval = 0xff; break;
	}
	return retval;
}




unsigned int get_LINNUX_BOARD_MSKADDR(int byte_num)
{
	unsigned long current_mask = nets[0]->snmask;
	unsigned int retval;
	switch (byte_num) {
	case 0:
	case 1:
	case 2:
	case 3: retval =  get_ip_byte(current_mask,byte_num);  break;
	default: safe_print(printf("[get_LINNUX_BOARD_MSKADDR]: invalid parameter: %d\n",byte_num)); retval = 0xff; break;
	}
	return retval;
}



unsigned int get_LINNUX_DNS_ADDR(int dns_num, int byte_num)
{
	unsigned int retval;

	if ((dns_num >= MAXDNSSERVERS) || (dns_num < 0))
	{
		safe_print(printf("[get_LINNUX_DNS_ADDR]: invalid dns_num parameter: %d\n",dns_num)); retval = 0xff;
	} else {
		    unsigned long current_dns = dns_servers[dns_num];
			switch (byte_num) {
			case 0:
			case 1:
			case 2:
			case 3: retval =  get_ip_byte(current_dns,byte_num);  break;
			default: safe_print(printf("[get_LINNUX_BOARD_MSKADDR]: invalid byte_num: %d\n",byte_num)); retval = 0xff; break;
			}
	}
	return retval;
}



