/******************************************************************************
* Copyright (c) 2006 Altera Corporation, San Jose, California, USA.           *
* All rights reserved. All use of this software and documentation is          *
* subject to the License Agreement located at the end of this file below.     *
*******************************************************************************
*                                                                             *
* Modified to work with Interniche (Week of 9/22/06) - BjR                    *
*                                                                             *
* File: network_utilities.c                                                   *
*                                                                             *
* This file contains network utilities that work in conjunction with the      *
* NicheStack to bring up a design's IP address (using DHCP if available) and  *
* MAC address.                                                                *
*                                                                             *
* Please refer to file ReadMe.txt for notes on this software example.         *
******************************************************************************/
#include <stdio.h> 
#include <ctype.h>
#include <string.h>
#include <errno.h>

/* Iniche Specific includes. */

#include "ipport.h"
#include "tcpport.h"

#include "alt_types.h"
#include "includes.h"
#include "io.h"

#include "basedef.h"

#include "cpp_to_c_header_interface.h"
#include "cpp_network_utilities.h"


#define IP4_ADDR(ipaddr, a,b,c,d) ipaddr = \
    htonl((((alt_u32)(a & 0xff) << 24) | ((alt_u32)(b & 0xff) << 16) | \
          ((alt_u32)(c & 0xff) << 8) | (alt_u32)(d & 0xff)))

static void assign_char_mac_addr_from_uint_macaddr(unsigned char mac_addr[6], unsigned int uint_macaddr[6]) {
  mac_addr[0] = uint_macaddr[0] & 0xff;
	     mac_addr[1] = uint_macaddr[1] & 0xff;
	     mac_addr[2] = uint_macaddr[2] & 0xff;
	     mac_addr[3] = uint_macaddr[3] & 0xff;
	     mac_addr[4] = uint_macaddr[4] & 0xff;
	     mac_addr[5] = uint_macaddr[5] & 0xff;
}

extern unsigned char board_mac_addr[6];
/*
 * get_board_mac_addr
 *
 * Read the MAC address in a board specific way
 *
 */
error_t get_board_mac_addr(unsigned char mac_addr[6])
{
  return cpp_get_board_mac_addr(mac_addr);
}

/*
* get_mac_addr
*
* Read the MAC address in a board specific way
*
*/
int get_mac_addr(NET net, unsigned char mac_addr[6])
{
	/*static done_this_already = 0;
	error_t err;
	if (!done_this_already) {
		err = get_board_mac_addr(mac_addr);
		done_this_already = 1;
	} else {
		 printf("Warning: get_mac_addr called again; not calling get_board_mac_addr again!\n");
		 mac_addr[0] = board_mac_addr[0];
		 mac_addr[1] = board_mac_addr[1];
		 mac_addr[2] = board_mac_addr[2];
		 mac_addr[3] = board_mac_addr[3];
		 mac_addr[4] = board_mac_addr[4];
		 mac_addr[5] = board_mac_addr[5];
  	     err =   0;
	}


    return (err);
    */
	return (get_board_mac_addr(mac_addr));
}

/*
 * get_ip_addr()
 * 
 * This routine is called by InterNiche to obtain an IP address for the
 * specified network adapter. Like the MAC address, obtaining an IP address is
 * very system-dependant and therefore this function is exported for the
 * developer to control.
 * 
 * In our system, we are either attempting DHCP auto-negotiation of IP address,
 * or we are setting our own static IP, Gateway, and Subnet Mask addresses our
 * self. This routine is where that happens.
 */
int get_ip_addr(alt_iniche_dev *p_dev,
                ip_addr* ipaddr,
                ip_addr* netmask,
                ip_addr* gw,
                int* use_dhcp)
{

	return cpp_get_ip_addr(p_dev,
            ipaddr,
            netmask,
            gw,
            use_dhcp);
}
