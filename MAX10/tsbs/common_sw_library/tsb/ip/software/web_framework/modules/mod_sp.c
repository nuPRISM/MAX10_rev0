/*
 * mod_sp.c
 *
 *  Created on: Nov 14, 2016
 *      Author: bryerton
 */

#include <sys/types.h>
#include <alt_iniche_dev.h>
#include "io.h"
#include <assert.h>
#include <system.h>
#include <unistd.h>
#include <string.h>
#include <drivers/inc/altera_avalon_pio_regs.h>
#include <drivers/inc/sigproc_regs.h>
#include "mod_sp.h"
#include <stdlib.h>

// Hack to remove error, thanks altera
u_long inet_addr(char FAR * str);

static eESPERError Init(tESPERMID mid, tESPERModuleSP* ctx);
static eESPERError Start(tESPERMID mid, tESPERModuleSP* ctx);
static eESPERError Update(tESPERMID mid, tESPERModuleSP* ctx);

tESPERModuleSP* ModuleSPInit(uint32_t sp_ctrl_base, uint32_t sp_stat_base, tESPERModuleSP* ctx) {
	if(!ctx) return 0;

	ctx->sp_ctrl_base = sp_ctrl_base;
	ctx->sp_stat_base = sp_stat_base;
	ctx->hold_ena = 1;

	// Put DDR capture into reset
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_SCA_BASE, (1 << 30));

	ctx->sca_ddr_reserved_region = calloc(511*76, 8);
	ctx->sca_copied_region 		 = calloc(511*76, 8);

	ctx->sca_ddr_reserved_region = (int16_t*)((uint32_t)ctx->sca_ddr_reserved_region | 0x80000000);
	ctx->sca_copied_region = (int16_t*)((uint32_t)ctx->sca_copied_region | 0x80000000);

	if(ctx->sca_ddr_reserved_region) {
		// Enable DDR data capture
		IOWR_ALTERA_AVALON_PIO_DATA(PIO_SCA_BASE, (1 << 31) | ((uint32_t)ctx->sca_ddr_reserved_region));
	}

	return ctx;
}

eESPERError ModuleSPHandler(tESPERMID mid, tESPERGID gid, eESPERModuleState state, ESPER_TIMESTAMP ts, void* ctx) {
	switch(state) {
	case ESPER_MOD_STATE_INIT:
		return Init(mid, (tESPERModuleSP*)ctx);
	case ESPER_MOD_STATE_START:
		return Start(mid, (tESPERModuleSP*)ctx);
	case ESPER_MOD_STATE_UPDATE:
		return Update(mid, (tESPERModuleSP*)ctx);
	case ESPER_MOD_STATE_STOP:
		break;
	}

	return ESPER_ERR_OK;
}

static eESPERError Init(tESPERMID mid, tESPERModuleSP* ctx) {
	ESPER_CreateVarBool(mid, "force_run",  		ESPER_OPTION_WR_RD, 1, &ctx->force_run, (uint8_t*)GET_REG_OFFSET(ctx->sp_ctrl_base, SIGPROC_REG_CTRL_FORCE_RUN), 0);
	ESPER_CreateVarBool(mid, "force_rst",  		ESPER_OPTION_WR_RD, 1, &ctx->force_rst, (uint8_t*)GET_REG_OFFSET(ctx->sp_ctrl_base, SIGPROC_REG_CTRL_FORCE_RESET), 0);
	ESPER_CreateVarBool(mid, "trig_out",  		ESPER_OPTION_WR_RD, 1, &ctx->trig_out, (uint8_t*)GET_REG_OFFSET(ctx->sp_ctrl_base, SIGPROC_REG_CTRL_TRIG_OUT), 0);
	ESPER_CreateVarUInt32(mid, "trig_delay",	ESPER_OPTION_WR_RD, 1, &ctx->trig_delay, (uint32_t*)GET_REG_OFFSET(ctx->sp_ctrl_base, SIGPROC_REG_CTRL_TRIG_DELAY), 0);
	ESPER_CreateVarBool(mid, "ext_trig_ena",	ESPER_OPTION_WR_RD, 1, &ctx->ext_trig_ena, (uint8_t*)GET_REG_OFFSET(ctx->sp_ctrl_base, SIGPROC_REG_CTRL_EXT_TRIG_ENA), 0);
	ESPER_CreateVarBool(mid, "ext_trig_inv",	ESPER_OPTION_WR_RD, 1, &ctx->ext_trig_inv, (uint8_t*)GET_REG_OFFSET(ctx->sp_ctrl_base, SIGPROC_REG_CTRL_EXT_TRIG_INV), 0);
	ESPER_CreateVarBool(mid, "sfp_trig_ena",	ESPER_OPTION_WR_RD, 1, &ctx->sfp_trig_ena, (uint8_t*)GET_REG_OFFSET(ctx->sp_ctrl_base, SIGPROC_REG_CTRL_SFP_TRIG_ENA), 0);
	ESPER_CreateVarBool(mid, "test_pulse_ena",	ESPER_OPTION_WR_RD, 4, &ctx->test_pulse_ena[0], (uint8_t*)GET_REG_OFFSET(ctx->sp_ctrl_base, SIGPROC_REG_CTRL_TEST_PULSE_ENA), 0);
	ESPER_CreateVarUInt32(mid, "test_pulse_dly",ESPER_OPTION_WR_RD, 4, &ctx->test_pulse_dly[0], (uint32_t*)GET_REG_OFFSET(ctx->sp_ctrl_base, SIGPROC_REG_CTRL_TEST_PULSE_DLY0), 0);

	ESPER_CreateVarBool(mid, "run_status",  	ESPER_OPTION_RD, 1, &ctx->run_status, (uint8_t*)GET_REG_OFFSET(ctx->sp_stat_base, SIGPROC_REG_STAT_RUN),0);
	ESPER_CreateVarUInt64(mid, "ts_run", 		ESPER_OPTION_RD, 1, &ctx->ts_run, (uint64_t*)GET_REG_OFFSET(ctx->sp_stat_base, SIGPROC_REG_STAT_TS_RUN_LO), 0);
	ESPER_CreateVarUInt64(mid, "ts_start", 		ESPER_OPTION_RD, 1, &ctx->ts_start, (uint64_t*)GET_REG_OFFSET(ctx->sp_stat_base, SIGPROC_REG_STAT_TS_START_LO), 0);
	ESPER_CreateVarUInt64(mid, "ts_trig", 		ESPER_OPTION_RD, 1, &ctx->ts_trig, (uint64_t*)GET_REG_OFFSET(ctx->sp_stat_base, SIGPROC_REG_STAT_TS_TRIG_LO), 0);
	ESPER_CreateVarUInt32(mid, "trig_accepted", ESPER_OPTION_RD, 1, &ctx->trig_accepted, (uint32_t*)GET_REG_OFFSET(ctx->sp_stat_base, SIGPROC_REG_STAT_CNT_ACCEPTED), 0);
	ESPER_CreateVarUInt32(mid, "trig_dropped", 	ESPER_OPTION_RD, 1, &ctx->trig_dropped, (uint32_t*)GET_REG_OFFSET(ctx->sp_stat_base, SIGPROC_REG_STAT_CNT_DROPPED), 0);

	ESPER_CreateVarUInt32(mid, "trig_cnt_ext", 	ESPER_OPTION_RD, 1, &ctx->trig_cnt_ext, (uint32_t*)GET_REG_OFFSET(ctx->sp_stat_base, SIGPROC_REG_STAT_CNT_TRIG_EXT), 0);
	ESPER_CreateVarUInt32(mid, "trig_cnt_int", 	ESPER_OPTION_RD, 1, &ctx->trig_cnt_int, (uint32_t*)GET_REG_OFFSET(ctx->sp_stat_base, SIGPROC_REG_STAT_CNT_TRIG_INT), 0);
	ESPER_CreateVarUInt32(mid, "trig_cnt_sfp", 	ESPER_OPTION_RD, 1, &ctx->trig_cnt_sfp, (uint32_t*)GET_REG_OFFSET(ctx->sp_stat_base, SIGPROC_REG_STAT_CNT_TRIG_SFP), 0);

	ESPER_CreateVarSInt16(mid, "waveform", 		ESPER_OPTION_RD | ESPER_OPTION_HIDDEN, (511*76*4), ctx->sca_copied_region, 0, 0);

	return ESPER_ERR_OK;
}

static eESPERError Start(tESPERMID mid, tESPERModuleSP* ctx) {
	IOWR_ALTERA_AVALON_PIO_SET_BITS(PIO_OUT_BASE, (9) << 6);

	ESPER_WriteVarBool(mid, ESPER_GetVarIdByKey(mid, "force_rst", 0), 0, 1);

	*(uint8_t*)GET_REG_OFFSET(ctx->sp_ctrl_base, SIGPROC_REG_CTRL_HOLD_ENA) = 0;

	ESPER_WriteVarBool(mid, ESPER_GetVarIdByKey(mid, "ext_trig_ena", 0), 0, 1);
	ESPER_WriteVarBool(mid, ESPER_GetVarIdByKey(mid, "ext_trig_inv", 0), 0, 0);
	ESPER_WriteVarBool(mid, ESPER_GetVarIdByKey(mid, "sfp_trig_ena", 0), 0, 0);

	ESPER_WriteVarUInt32(mid, ESPER_GetVarIdByKey(mid, "test_pulse_dly", 0), 0, 0);
	ESPER_WriteVarUInt32(mid, ESPER_GetVarIdByKey(mid, "test_pulse_dly", 0), 1, 0);
	ESPER_WriteVarUInt32(mid, ESPER_GetVarIdByKey(mid, "test_pulse_dly", 0), 2, 0);
	ESPER_WriteVarUInt32(mid, ESPER_GetVarIdByKey(mid, "test_pulse_dly", 0), 3, 0);


	ESPER_WriteVarBool(mid, ESPER_GetVarIdByKey(mid, "test_pulse_ena", 0), 0, 0);
	ESPER_WriteVarBool(mid, ESPER_GetVarIdByKey(mid, "test_pulse_ena", 0), 1, 0);
	ESPER_WriteVarBool(mid, ESPER_GetVarIdByKey(mid, "test_pulse_ena", 0), 2, 0);
	ESPER_WriteVarBool(mid, ESPER_GetVarIdByKey(mid, "test_pulse_ena", 0), 3, 0);

	ESPER_WriteVarUInt32(mid, ESPER_GetVarIdByKey(mid, "trig_delay", 0), 0, 312);

	*(uint8_t*)GET_REG_OFFSET(ctx->sp_ctrl_base, SIGPROC_REG_CTRL_HOLD_ENA) = 1;

	ESPER_WriteVarBool(mid, ESPER_GetVarIdByKey(mid, "force_rst", 0), 0, 0);

	ESPER_WriteVarBool(mid, ESPER_GetVarIdByKey(mid, "force_run", 0), 0, 1);


	return ESPER_ERR_OK;
}

static eESPERError Update(tESPERMID mid, tESPERModuleSP* ctx) {

	static int udp_sock;
	static struct sockaddr_in dest;
	static char* msgbuff;
	static unsigned int msg_len;
	static unsigned int buf_len;
	static unsigned int cnt;
	unsigned int n;
	uint64_t data64;

	if(!udp_sock) {
		udp_sock = socket(AF_INET, SOCK_DGRAM, 0); // UDP socket

		dest.sin_family = AF_INET;
		dest.sin_port = htons(50006);
		dest.sin_addr.s_addr = inet_addr("192.168.1.1");
//		dest.sin_port = htons(50005);
//		dest.sin_addr.s_addr = inet_addr("192.168.1.147");

		msgbuff = calloc(1472, 1); // max UDP packet size
	}

	// check to see if we've captured a new waveform

	if(*(uint8_t*)GET_REG_OFFSET(ctx->sp_ctrl_base, SIGPROC_REG_CTRL_HOLD_ENA) != 0) {
		if(*(uint8_t*)GET_REG_OFFSET(ctx->sp_stat_base, SIGPROC_REG_STAT_HOLD)) {

			memcpy(ctx->sca_copied_region, (char*)ctx->sca_ddr_reserved_region, (511*76*8));
			ESPER_TouchVar(mid, ESPER_GetVarIdByKey(mid, "waveform", 0));

			cnt++;
/*
			uint32_t sent_data = 0;
			uint32_t total_data = 76*2*4*511; // 76 columns, 2 bytes each, 4 scas, 511 rows

			// UDP out message here, for testing purposes only, should be using offloader!
			// Header (First) packet
			n = 0;
			msg_len = 0;
			buf_len = 76*2*4;
			msgbuff[msg_len++] = (cnt >>  0) & 0xFF;
			msgbuff[msg_len++] = (cnt >>  8) & 0xFF;
			msgbuff[msg_len++] = (cnt >> 16) & 0xFF;
			msgbuff[msg_len++] = (cnt >> 24) & 0xFF;
			msgbuff[msg_len++] = (n   >>  0) & 0xFF;
			msgbuff[msg_len++] = (n   >>  8) & 0xFF;
			msgbuff[msg_len++] = (511 >>  0) & 0xFF;
			msgbuff[msg_len++] = (511 >>  8) & 0xFF;
			msgbuff[msg_len++] = (buf_len >>  0) & 0xFF;
			msgbuff[msg_len++] = (buf_len >>  8) & 0xFF;


			data64 = ESPER_ReadVarUInt64(mid, ESPER_GetVarIdByKey(mid, "ts_start", 0), 0);
			msgbuff[msg_len++]  = (data64 >>  0) & 0xFF;
			msgbuff[msg_len++]  = (data64 >>  8) & 0xFF;
			msgbuff[msg_len++] = (data64 >> 16) & 0xFF;
			msgbuff[msg_len++] = (data64 >> 24) & 0xFF;
			msgbuff[msg_len++] = (data64 >> 32) & 0xFF;
			msgbuff[msg_len++] = (data64 >> 40) & 0xFF;
			msgbuff[msg_len++] = (data64 >> 48) & 0xFF;
			msgbuff[msg_len++] = (data64 >> 56) & 0xFF;

			data64 = ESPER_ReadVarUInt64(mid, ESPER_GetVarIdByKey(mid, "ts_trig", 0), 0);
			msgbuff[msg_len++]  = (data64 >>  0) & 0xFF;
			msgbuff[msg_len++]  = (data64 >>  8) & 0xFF;
			msgbuff[msg_len++] = (data64 >> 16) & 0xFF;
			msgbuff[msg_len++] = (data64 >> 24) & 0xFF;
			msgbuff[msg_len++] = (data64 >> 32) & 0xFF;
			msgbuff[msg_len++] = (data64 >> 40) & 0xFF;
			msgbuff[msg_len++] = (data64 >> 48) & 0xFF;
			msgbuff[msg_len++] = (data64 >> 56) & 0xFF;

			memcpy(&msgbuff[msg_len], (char*)&ctx->sca_ddr_reserved_region[0], buf_len);
			msg_len += buf_len;
			sendto(udp_sock, msgbuff, msg_len, 0,  (struct sockaddr*)&dest, sizeof(dest));
			sent_data += buf_len;
			usleep(1000);

			// Remainder of Event Data
			while(sent_data < total_data) {
				n++;
				msg_len = 0;
				buf_len = 76*2*4*2; // we can fit two rows in at a time
				msgbuff[msg_len++] = (cnt >>  0) & 0xFF;
				msgbuff[msg_len++] = (cnt >>  8) & 0xFF;
				msgbuff[msg_len++] = (cnt >> 16) & 0xFF;
				msgbuff[msg_len++] = (cnt >> 24) & 0xFF;
				msgbuff[msg_len++] = (n   >>  0) & 0xFF;
				msgbuff[msg_len++] = (n   >>  8) & 0xFF;
				msgbuff[msg_len++] = (511 >>  0) & 0xFF;
				msgbuff[msg_len++] = (511 >>  8) & 0xFF;
				msgbuff[msg_len++] = (buf_len >>  0) & 0xFF;
				msgbuff[msg_len++] = (buf_len >>  8) & 0xFF;

				memcpy(&msgbuff[msg_len], (char*)(ctx->sca_ddr_reserved_region) + sent_data, buf_len);
				msg_len += buf_len;
				sendto(udp_sock, msgbuff, msg_len, 0,  (struct sockaddr*)&dest, sizeof(dest));

				sent_data += buf_len;
				usleep(1000);
			}
*/
			// briefly release hold
			*(uint8_t*)GET_REG_OFFSET(ctx->sp_ctrl_base, SIGPROC_REG_CTRL_HOLD_ENA) = 0;
			*(uint8_t*)GET_REG_OFFSET(ctx->sp_ctrl_base, SIGPROC_REG_CTRL_HOLD_ENA) = 1;
		}
	}

	return ESPER_ERR_OK;
}
