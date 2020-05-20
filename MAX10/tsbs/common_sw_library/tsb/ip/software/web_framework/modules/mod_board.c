/*
 * mod_board.c
 *
 *  Created on: Apr 2, 2017
 *      Author: admin
 */

#include <assert.h>
#include <system.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "mod_board.h"
#include <drivers/inc/board_regs.h>

static eESPERError Init(tESPERMID mid, tESPERModuleBoard* data);
static eESPERError Start(tESPERMID mid, tESPERModuleBoard* data);
static eESPERError Update(tESPERMID mid, tESPERModuleBoard* data);

static const void* ADCPwrHandle(tESPERMID mid, const char* key, eESPERRequest request, uint32_t offset, uint32_t* num_elements, void* ctx);


tESPERModuleBoard* BoardModuleInit(tESPERModuleBoard* ctx) {
	if(!ctx) return 0;

	return ctx;
}

eESPERError BoardModuleHandler(tESPERMID mid, tESPERGID gid, eESPERModuleState state, ESPER_TIMESTAMP ts, void* ctx) {

	switch(state) {
	case ESPER_MOD_STATE_INIT:
		return Init(mid, (tESPERModuleBoard*)ctx);
	case ESPER_MOD_STATE_START:
		return Start(mid, (tESPERModuleBoard*)ctx);
	case ESPER_MOD_STATE_UPDATE:
		return Update(mid, (tESPERModuleBoard*)ctx);
	case ESPER_MOD_STATE_STOP:
		break;
	}

	return ESPER_ERR_OK;
}

static eESPERError Init(tESPERMID mid, tESPERModuleBoard* ctx) {
	ESPER_CreateVarBool(mid, "adc_pwr_en", 			ESPER_OPTION_WR_RD, 2, &ctx->adc_pwr_en[0], (uint8_t*)GET_REG_OFFSET(BOARD_CONTROL_BASE, BOARD_REG_CTRL_ADC_PWR_EN), ADCPwrHandle);
	ESPER_CreateVarBool(mid, "ext_test_pulse", 		ESPER_OPTION_WR_RD, 1, &ctx->ext_test_pulse, (uint8_t*)GET_REG_OFFSET(BOARD_CONTROL_BASE, BOARD_REG_CTRL_EXT_TEST_PULSE), 0);
	ESPER_CreateVarBool(mid, "reset_counters", 		ESPER_OPTION_WR_RD, 1, &ctx->reset_counters, (uint8_t*)GET_REG_OFFSET(BOARD_CONTROL_BASE, BOARD_REG_CTRL_RESET_COUNTERS), 0);
	ESPER_CreateVarBool(mid, "use_sata_gxb", 		ESPER_OPTION_WR_RD, 1, &ctx->use_sata_gxb, (uint8_t*)GET_REG_OFFSET(BOARD_CONTROL_BASE, BOARD_REG_CTRL_USE_SATA_GXB), 0);

	ESPER_CreateVarBool(mid, "serdes_locked",		ESPER_OPTION_RD, 1, &ctx->serdes_locked, (uint8_t*)GET_REG_OFFSET(BOARD_STATUS_BASE, BOARD_REG_STAT_ADC_LOCKED), 0);
	ESPER_CreateVarUInt32(mid, "cnt_locked",		ESPER_OPTION_RD, 2, &ctx->cnt_locked[0], (uint8_t*)GET_REG_OFFSET(BOARD_STATUS_BASE, BOARD_REG_STAT_ADC_LOCKED_CNT0), 0);
	ESPER_CreateVarBool(mid, "serdes_aligned",		ESPER_OPTION_RD, 1, &ctx->serdes_aligned, (uint8_t*)GET_REG_OFFSET(BOARD_STATUS_BASE, BOARD_REG_STAT_ADC_ALIGNED), 0);
	ESPER_CreateVarUInt32(mid, "cnt_aligned",		ESPER_OPTION_RD, 2, &ctx->cnt_aligned[0], (uint8_t*)GET_REG_OFFSET(BOARD_STATUS_BASE, BOARD_REG_STAT_ADC_ALIGNED_CNT0), 0);
	ESPER_CreateVarUInt64(mid, "chip_id", 			ESPER_OPTION_RD, 1, &ctx->chipid, (uint8_t*)GET_REG_OFFSET(BOARD_STATUS_BASE, BOARD_REG_STAT_CHIPID_LO), 0);


	ESPER_CreateVarUInt32(mid, "freq_clocka",		ESPER_OPTION_RD, 1, &ctx->freq_clocka, (uint8_t*)GET_REG_OFFSET(BOARD_STATUS_BASE, BOARD_REG_STAT_CLOCK_CLEANER), 0);
	ESPER_CreateVarUInt32(mid, "freq_io",			ESPER_OPTION_RD, 1, &ctx->freq_io, (uint8_t*)GET_REG_OFFSET(BOARD_STATUS_BASE, BOARD_REG_STAT_CLOCK_IO), 0);
	ESPER_CreateVarUInt32(mid, "freq_sca_wr",		ESPER_OPTION_RD, 1, &ctx->freq_sca_wr, (uint8_t*)GET_REG_OFFSET(BOARD_STATUS_BASE, BOARD_REG_STAT_CLOCK_SCA_WR), 0);
	ESPER_CreateVarUInt32(mid, "freq_sca_rd",		ESPER_OPTION_RD, 1, &ctx->freq_sca_rd, (uint8_t*)GET_REG_OFFSET(BOARD_STATUS_BASE, BOARD_REG_STAT_CLOCK_SCA_RD), 0);
	ESPER_CreateVarUInt32(mid, "freq_sfp",			ESPER_OPTION_RD, 1, &ctx->freq_sfp, (uint8_t*)GET_REG_OFFSET(BOARD_STATUS_BASE, BOARD_REG_STAT_CLOCK_RCVD_ETH), 0);
	ESPER_CreateVarUInt32(mid, "freq_sata",			ESPER_OPTION_RD, 1, &ctx->freq_sata, (uint8_t*)GET_REG_OFFSET(BOARD_STATUS_BASE, BOARD_REG_STAT_CLOCK_RCVD_XCVR), 0);

	return ESPER_ERR_OK;
}

static eESPERError Start(tESPERMID mid, tESPERModuleBoard* ctx) {
	// Turn on both to start
	ESPER_WriteVarBool(mid, ESPER_GetVarIdByKey(mid, "adc_pwr_en", 0), 0, 1);
	ESPER_WriteVarBool(mid, ESPER_GetVarIdByKey(mid, "adc_pwr_en", 0), 1, 1);

	return ESPER_ERR_OK;
}

static eESPERError Update(tESPERMID mid, tESPERModuleBoard* ctx) {


	return ESPER_ERR_OK;
}

static const void* ADCPwrHandle(tESPERMID mid, const char* key, eESPERRequest request, uint32_t offset, uint32_t* num_elements, void* ctx) {
	switch(request) {
	case ESPER_REQUEST_WRITE_POST:
		// Reset SERDES
		*(uint8_t*)GET_REG_OFFSET(BOARD_CONTROL_BASE, BOARD_REG_CTRL_SERDES_RST) = 1;
		*(uint8_t*)GET_REG_OFFSET(BOARD_CONTROL_BASE, BOARD_REG_CTRL_SERDES_RST) = 0;
		break;
	default:
		break;
	}

	return 0;
}
