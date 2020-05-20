/*
 * mod_udp.h
 *
 *  Created on: Dec 9, 2016
 *      Author: admin
 */

#ifndef MOD_UDP_H_
#define MOD_UDP_H_

#include <esper.h>
#include <drivers/inc/fabric_udp_stream_regs.h>
#include <drivers/inc/fabric_udp_stream.h>

typedef struct {
	uint32_t src_ip;
	uint32_t dst_ip;
	uint16_t dst_port;
	uint16_t src_port;
	uint32_t src_mask;
	uint32_t src_gw;
	uint8_t  dst_mac[6];
	uint8_t  src_mac[6];
	uint8_t enable;
	uint8_t dhcp_ena;
	uint8_t  status;
	uint32_t udp_base;
	tFabricUDPStreamStats stats;
} tESPERModuleUDPOffload;

tESPERModuleUDPOffload* ModuleUDPOffloadInit(uint32_t udp_base, uint8_t* src_mac,  uint32_t defaultIP, uint16_t defaultPort, uint16_t sendPort, tESPERModuleUDPOffload* ctx);
eESPERError ModuleUDPOffloadHandler(tESPERMID mid, tESPERGID gid, eESPERModuleState state, ESPER_TIMESTAMP ts, void* ctx);

#endif /* MOD_UDP_H_ */
