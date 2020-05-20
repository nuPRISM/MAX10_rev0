/*
 * linnux_server_dns_utils.h
 *
 *  Created on: Nov 17, 2011
 *      Author: linnyair
 */

#ifndef LINNUX_SERVER_DNS_UTILS_H_
#define LINNUX_SERVER_DNS_UTILS_H_
#ifdef __cplusplus
extern "C" {
#endif
#include "basedef.h"

extern unsigned int get_LINNUX_BOARD_IPADDR(int byte_num);
extern unsigned int get_LINNUX_BOARD_GWADDR(int byte_num);
extern unsigned int get_LINNUX_BOARD_MSKADDR(int byte_num);
extern unsigned int get_LINNUX_DNS_ADDR(int dns_num, int byte_num);

#ifdef __cplusplus
}
#endif
#endif /* LINNUX_SERVER_DNS_UTILS_H_ */
