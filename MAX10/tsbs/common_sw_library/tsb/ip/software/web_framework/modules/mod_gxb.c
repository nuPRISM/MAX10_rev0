/*
 * mod_gxb.c
 *
 *  Created on: Apr 3, 2017
 *      Author: admin
 */


#include <assert.h>
#include <system.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "mod_gxb.h"
#include <drivers/inc/gxb_module_regs.h>

static eESPERError Init(tESPERMID mid, tESPERModuleGXB* data);
static eESPERError Start(tESPERMID mid, tESPERModuleGXB* data);
static eESPERError Update(tESPERMID mid, tESPERModuleGXB* data);


tESPERModuleGXB* GXBModuleInit(tESPERModuleGXB* ctx) {
	if(!ctx) return 0;

	return ctx;
}

eESPERError GXBModuleHandler(tESPERMID mid, tESPERGID gid, eESPERModuleState state, ESPER_TIMESTAMP ts, void* ctx) {

	switch(state) {
	case ESPER_MOD_STATE_INIT:
		return Init(mid, (tESPERModuleGXB*)ctx);
	case ESPER_MOD_STATE_START:
		return Start(mid, (tESPERModuleGXB*)ctx);
	case ESPER_MOD_STATE_UPDATE:
		return Update(mid, (tESPERModuleGXB*)ctx);
	case ESPER_MOD_STATE_STOP:
		break;
	}

	return ESPER_ERR_OK;
}


static eESPERError Init(tESPERMID mid, tESPERModuleGXB* ctx) {
	ESPER_CreateVarBool(mid, "loopback_en", 		ESPER_OPTION_WR_RD, 1, &ctx->loopback_en, (uint8_t*)GET_REG_OFFSET(ctx->ctrl_base, GXB_MOD_REG_CTRL_SERIAL_LPBK_EN), 0);
	ESPER_CreateVarBool(mid, "lock_rx_to_dat", 		ESPER_OPTION_WR_RD, 1, &ctx->lock_rx_to_dat, (uint8_t*)GET_REG_OFFSET(ctx->ctrl_base, GXB_MOD_REG_CTRL_LOCK_RX_CLK_TO_DATA), 0);
	ESPER_CreateVarBool(mid, "lock_rx_to_ref", 		ESPER_OPTION_WR_RD, 1, &ctx->lock_rx_to_ref, (uint8_t*)GET_REG_OFFSET(ctx->ctrl_base, GXB_MOD_REG_CTRL_LOCK_RX_CLK_TO_REF), 0);
	ESPER_CreateVarBool(mid, "reset_counters", 		ESPER_OPTION_WR_RD, 1, &ctx->reset_counters, (uint8_t*)GET_REG_OFFSET(ctx->ctrl_base, GXB_MOD_REG_CTRL_RESET_COUNTERS), 0);


	ESPER_CreateVarBool(mid, "pll_locked",		ESPER_OPTION_RD, 1, &ctx->pll_locked, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_PLL_LOCKED), 0);
	ESPER_CreateVarBool(mid, "is_locked_dat",		ESPER_OPTION_RD, 1, &ctx->is_locked_dat, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_IS_RX_LOCKED_TO_DATA), 0);
	ESPER_CreateVarBool(mid, "is_locked_ref",		ESPER_OPTION_RD, 1, &ctx->is_locked_ref, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_IS_RX_LOCKED_TO_REF), 0);
	ESPER_CreateVarBool(mid, "signal_detect",		ESPER_OPTION_RD, 1, &ctx->signal_detect, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_SIGNAL_DETECT), 0);
	ESPER_CreateVarBool(mid, "tx_cal_busy",		ESPER_OPTION_RD, 1, &ctx->tx_cal_busy, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_TX_CAL_BUSY), 0);
	ESPER_CreateVarBool(mid, "rx_cal_busy",		ESPER_OPTION_RD, 1, &ctx->rx_cal_busy, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_RX_CAL_BUSY), 0);
	ESPER_CreateVarBool(mid, "rx_err_detect",		ESPER_OPTION_RD, 1, &ctx->rx_err_detect, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_RX_ERR_DETECT), 0);
	ESPER_CreateVarBool(mid, "rx_err_parity",		ESPER_OPTION_RD, 1, &ctx->rx_err_parity, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_RX_ERR_DISPARITY), 0);
	ESPER_CreateVarBool(mid, "rx_sync_status",		ESPER_OPTION_RD, 1, &ctx->rx_sync_status, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_RX_SYNC_STATUS), 0);
	ESPER_CreateVarBool(mid, "rx_pattern_det",		ESPER_OPTION_RD, 1, &ctx->rx_pattern_det, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_RX_PATTERN_DETECT), 0);

	ESPER_CreateVarUInt32(mid, "freq_tx_core",	ESPER_OPTION_RD, 1, &ctx->freq_tx_core, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_FREQ_TX_CORE), 0);
	ESPER_CreateVarUInt32(mid, "freq_rx_core",	ESPER_OPTION_RD, 1, &ctx->freq_rx_core, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_FREQ_RX_CORE), 0);
	ESPER_CreateVarUInt32(mid, "cnt_pll_lock",	ESPER_OPTION_RD, 1, &ctx->cnt_pll_lock, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_CNT_PLL_LOCKED), 0);
	ESPER_CreateVarUInt32(mid, "cnt_lock_dat",	ESPER_OPTION_RD, 1, &ctx->cnt_lock_dat, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_CNT_IS_LOCKED_TO_DATA), 0);
	ESPER_CreateVarUInt32(mid, "cnt_lock_ref",	ESPER_OPTION_RD, 1, &ctx->cnt_lock_ref, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_CNT_IS_LOCKED_TO_REF), 0);
	ESPER_CreateVarUInt32(mid, "cnt_signal_det",	ESPER_OPTION_RD, 1, &ctx->cnt_signal_det, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_CNT_SIGNAL_DETECT), 0);
	ESPER_CreateVarUInt32(mid, "cnt_rx_err_det",	ESPER_OPTION_RD, 1, &ctx->cnt_rx_err_det, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_CNT_RX_ERR_DETECT), 0);
	ESPER_CreateVarUInt32(mid, "cnt_rx_err_par",	ESPER_OPTION_RD, 1, &ctx->cnt_rx_err_par, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_CNT_RX_ERR_DISPARITY), 0);
	ESPER_CreateVarUInt32(mid, "cnt_rx_sync_stat",	ESPER_OPTION_RD, 1, &ctx->cnt_rx_sync_stat, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_CNT_RX_SYNC_STATUS), 0);
	ESPER_CreateVarUInt32(mid, "cnt_rx_pattern_det",	ESPER_OPTION_RD, 1, &ctx->cnt_rx_pattern_det, (uint8_t*)GET_REG_OFFSET(ctx->stat_base, GXB_MOD_REG_STAT_CNT_RX_PATTERN_DETECT), 0);

	return ESPER_ERR_OK;
}

static eESPERError Start(tESPERMID mid, tESPERModuleGXB* ctx) {

	return ESPER_ERR_OK;
}

static eESPERError Update(tESPERMID mid, tESPERModuleGXB* ctx) {


	return ESPER_ERR_OK;
}


