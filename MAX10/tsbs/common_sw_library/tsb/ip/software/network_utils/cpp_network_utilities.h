/*
 * cpp_network_utilities.h
 *
 *  Created on: Dec 3, 2013
 *      Author: yairlinn
 */

#ifndef CPP_NETWORK_UTILITIES_H_
#define CPP_NETWORK_UTILITIES_H_

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <errno.h>

/* Iniche Specific includes. */

#include <alt_iniche_dev.h>
#include "ipport.h"
#include "tcpport.h"
#include "alt_types.h"
#include "includes.h"
#include "io.h"
#include "basedef.h"
#include "cpp_to_c_header_interface.h"

error_t cpp_get_board_mac_addr(unsigned char mac_addr[6]);

int cpp_get_ip_addr (
		        alt_iniche_dev *p_dev,
                ip_addr* ipaddr,
                ip_addr* netmask,
                ip_addr* gw,
                int* use_dhcp
               );

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* CPP_NETWORK_UTILITIES_H_ */
