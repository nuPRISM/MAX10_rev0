/*
 * mod_udp.c
 *
 *  Created on: Dec 9, 2016
 *      Author: admin
 */

#include <assert.h>
#include <string.h>
#include <i2c_opencores_regs.h>
#include <i2c_opencores.h>
#include <alt_iniche_dev.h>
#include <iniche/src/h/icmp.h>
#include <iniche/src/h/arp.h>
#include "mod_offload.h"

static eESPERError Init(tESPERMID mid, tESPERModuleUDPOffload* ctx);
static eESPERError Start(tESPERMID mid, tESPERModuleUDPOffload* ctx);
static eESPERError Update(tESPERMID mid, tESPERModuleUDPOffload* ctx);

static const void* UDP_Reset(tESPERMID mid, const char* key, eESPERRequest request, uint32_t offset, uint32_t* num_elements, void* ctx);

static struct arptabent *find_arp_entry(ip_addr dest_ip);

tESPERModuleUDPOffload* ModuleUDPOffloadInit(uint32_t udp_base, uint8_t* src_mac, uint32_t defaultIP, uint16_t defaultPort, uint16_t sendPort, tESPERModuleUDPOffload* ctx) {
	if(!ctx) return 0;

	ctx->udp_base = udp_base;
	memcpy(ctx->src_mac, src_mac, sizeof(ctx->src_mac));

	ctx->dst_ip = defaultIP;
	ctx->dst_port = defaultPort;

	ctx->src_port = sendPort;

	return ctx;
}

eESPERError ModuleUDPOffloadHandler(tESPERMID mid, tESPERGID gid, eESPERModuleState state, ESPER_TIMESTAMP ts, void* ctx) {
	switch(state) {
	case ESPER_MOD_STATE_INIT:
		return Init(mid, (tESPERModuleUDPOffload*)ctx);
	case ESPER_MOD_STATE_START:
		return Start(mid, (tESPERModuleUDPOffload*)ctx);
	case ESPER_MOD_STATE_UPDATE:
		return Update(mid, (tESPERModuleUDPOffload*)ctx);
	case ESPER_MOD_STATE_STOP:
		break;
	}

	return ESPER_ERR_OK;
}

static eESPERError Init(tESPERMID mid, tESPERModuleUDPOffload* ctx){
	ESPER_CreateVarUInt32(mid, "dst_ip", 	ESPER_OPTION_WR_RD, 1, &ctx->dst_ip, 0, 0);
	ESPER_CreateVarUInt16(mid, "dst_port", 	ESPER_OPTION_WR_RD, 1, &ctx->dst_port, 0,0);
	ESPER_CreateVarUInt8(mid, "dst_mac", 	ESPER_OPTION_RD, 6, &ctx->dst_mac[0], 0,0);
	ESPER_CreateVarUInt32(mid, "src_ip", 	ESPER_OPTION_RD, 1, &ctx->src_ip, 0,0);
	ESPER_CreateVarUInt16(mid, "src_port", 	ESPER_OPTION_RD, 1, &ctx->src_port, 0,0);
	ESPER_CreateVarUInt32(mid, "src_mask", 	ESPER_OPTION_RD, 1, &ctx->src_mask, 0,0);
	ESPER_CreateVarUInt32(mid, "src_gw", 	ESPER_OPTION_RD, 1, &ctx->src_gw, 0,0);
	ESPER_CreateVarUInt8(mid, "src_mac", 	ESPER_OPTION_RD, 6, &ctx->src_mac[0], 0,0);
	ESPER_CreateVarBool(mid, "dhcp_ena", 	ESPER_OPTION_RD, 1, &ctx->dhcp_ena, 0,0);
	ESPER_CreateVarBool(mid, "enable", 		ESPER_OPTION_WR_RD, 1, &ctx->enable, 0,0);
	ESPER_CreateVarNull(mid, "reset", 		ESPER_OPTION_WR, 1, UDP_Reset);
	ESPER_CreateVarUInt32(mid, "status", 	ESPER_OPTION_RD, 1, &ctx->stats.csr_state, 0, 0);
	ESPER_CreateVarUInt32(mid, "tx_cnt", 	ESPER_OPTION_RD, 1, &ctx->stats.packet_count, 0, 0);

	ESPER_CreateAttrASCII(mid, ESPER_GetVarIdByKey(mid, "dst_ip", 0), "format",	sizeof("ip"), "ip");
	ESPER_CreateAttrASCII(mid, ESPER_GetVarIdByKey(mid, "src_ip", 0), "format",	sizeof("ip"), "ip");
	ESPER_CreateAttrASCII(mid, ESPER_GetVarIdByKey(mid, "dst_mac", 0), "format",	sizeof("mac"), "mac");
	ESPER_CreateAttrASCII(mid, ESPER_GetVarIdByKey(mid, "src_gw", 0), "format",	sizeof("ip"), "ip");
	ESPER_CreateAttrASCII(mid, ESPER_GetVarIdByKey(mid, "src_mac", 0), "format",	sizeof("mac"), "mac");
	ESPER_CreateAttrASCII(mid, ESPER_GetVarIdByKey(mid, "src_mask", 0), "format",	sizeof("ip"), "ip");

	StopFabricUDPStream(ctx->udp_base);
	FABRIC_UDP_STREAM_CLEAR_PACKET_COUNTER(ctx->udp_base);


	return ESPER_ERR_OK;
}

static eESPERError Start(tESPERMID mid, tESPERModuleUDPOffload* ctx) {
	return ESPER_ERR_OK;
}

static eESPERError Update(tESPERMID mid, tESPERModuleUDPOffload* ctx){
	uint32_t n;
	struct arptabent *tp;

	// Get latest IP address information
	ctx->dhcp_ena = ((nets[0]->n_flags & NF_DHCPC) == NF_DHCPC);
	ctx->src_ip = 	htonl(nets[0]->n_ipaddr);
	ctx->src_mask = htonl(nets[0]->snmask);
	ctx->src_gw = htonl(nets[0]->n_defgw);

	if((ctx->src_ip == 0) || (ctx->dst_ip == 0)) {
		ctx->enable = 0;
	}

	if(ctx->enable) {

		GetFabricUDPStreamStats(ctx->udp_base, (tFabricUDPStreamStats*)&ctx->stats);
		//ESPER_WriteVarBool(mid, ESPER_GetVarIdByKey('enable'), ctx->stats.csr_state);


		if(ctx->stats.ip_dst != ctx->dst_ip) {
			icmpEcho(ctx->dst_ip, 0, 0, 1);
			n = 0;
			do {
				usleep(10000);
				tp = find_arp_entry(ctx->dst_ip);
				if(tp) {
					ctx->dst_mac[0] = tp->t_phy_addr[0];
					ctx->dst_mac[1] = tp->t_phy_addr[1];
					ctx->dst_mac[2] = tp->t_phy_addr[2];
					ctx->dst_mac[3] = tp->t_phy_addr[3];
					ctx->dst_mac[4] = tp->t_phy_addr[4];
					ctx->dst_mac[5] = tp->t_phy_addr[5];
				}
				n++;
			} while(( n < 10) && (tp == 0));

			if(tp != 0) {
				ctx->stats.ip_dst = ctx->dst_ip;
				ctx->stats.ip_src = ctx->src_ip;
				ctx->stats.mac_dst_hi = (ctx->dst_mac[0] << 24 ) | (ctx->dst_mac[1] << 16 ) | (ctx->dst_mac[2] << 8 ) | (ctx->dst_mac[3]);
				ctx->stats.mac_dst_lo = (ctx->dst_mac[4] <<  8 ) | (ctx->dst_mac[5]);
				ctx->stats.mac_src_hi = (ctx->src_mac[0] << 24 ) | (ctx->src_mac[1] << 16 ) | (ctx->src_mac[2] << 8 ) | (ctx->src_mac[3]);
				ctx->stats.mac_src_lo = (ctx->src_mac[4] <<  8 ) | (ctx->src_mac[5]);
				ctx->stats.udp_dst = ctx->dst_port;
				ctx->stats.udp_src = ctx->src_port;

				FABRIC_UDP_STREAM_CLEAR_PACKET_COUNTER(ctx->udp_base);
				StartFabricUDPStream(ctx->udp_base, (tFabricUDPStreamStats*)&ctx->stats);
			} else {
				// failed to start, don't keep trying on failure
				ctx->enable = 0;
			}
		}

	} else {
		StopFabricUDPStream(ctx->udp_base);
	}

	return ESPER_ERR_OK;
}

static const void* UDP_Reset(tESPERMID mid, const char* key, eESPERRequest request, uint32_t offset, uint32_t* num_elements, void* ctx) {
	tESPERModuleUDPOffload* udp_ctx = (tESPERModuleUDPOffload*)ctx;

	switch(request) {
	case ESPER_REQUEST_WRITE_POST:

		StopFabricUDPStream(udp_ctx->udp_base);
		if(udp_ctx->enable) {
			StartFabricUDPStream(udp_ctx->udp_base, (tFabricUDPStreamStats*)&udp_ctx->stats);
		} else {
			FABRIC_UDP_STREAM_CLEAR_PACKET_COUNTER(udp_ctx->udp_base);
		}
		break;
	default:
		break;
	}

	return 0;
}

static struct arptabent *find_arp_entry(ip_addr dest_ip) {
	   struct arptabent *tp;
	   struct arptabent *entry  = (struct arptabent *)NULL;

	   for (tp = &arp_table[0]; tp < &arp_table[MAXARPS]; tp++) {
	      if (htonl(tp->t_pro_addr) == htonl(dest_ip)) {
	    	  entry = tp;
	      }
	   }

	   return entry;
	}
