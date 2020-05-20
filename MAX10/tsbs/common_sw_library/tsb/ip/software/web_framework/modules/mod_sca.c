/*
 * mod_sca.c
 *
 *  Created on: Nov 14, 2016
 *      Author: bryerton
 */

#include <assert.h>
#include <system.h>
#include <unistd.h>
#include <drivers/inc/altera_avalon_pio_regs.h>
#include "../AFTER_slowcontrol.h"
#include <esper.h>
#include "mod_sca.h"

static eESPERError Init(tESPERMID mid, tESPERModuleSCA* ctx);
static eESPERError Start(tESPERMID mid, tESPERModuleSCA* ctx);
static eESPERError Update(tESPERMID mid, tESPERModuleSCA* ctx);

static void AFTER_WriteAll(tESPERModuleSCA* ctx);

static const void* Handler(tESPERMID mid, const char* key, eESPERRequest request, uint32_t offset, uint32_t* num_elements, void* ctx);

tESPERModuleSCA* SCAModuleInit(AFTER_write sca_write, AFTER_read sca_read, tESPERModuleSCA* ctx) {
	if(!ctx) return 0;
	if(!sca_write) return 0;
	if(!sca_read) return 0;

	ctx->sca_write = sca_write;
	ctx->sca_read = sca_read;

	return ctx;
}

eESPERError SCAModuleHandler(tESPERMID mid, tESPERGID gid, eESPERModuleState state, ESPER_TIMESTAMP ts, void* ctx) {
	switch(state) {
	case ESPER_MOD_STATE_INIT:
		return Init(mid, (tESPERModuleSCA*)ctx);
	case ESPER_MOD_STATE_START:
		return Start(mid, (tESPERModuleSCA*)ctx);
	case ESPER_MOD_STATE_UPDATE:
		return Update(mid, (tESPERModuleSCA*)ctx);
	case ESPER_MOD_STATE_STOP:
		break;
	}

	return ESPER_ERR_OK;
}

static eESPERError Init(tESPERMID mid, tESPERModuleSCA* ctx) {
	ESPER_CreateVarUInt8(mid, "i_csa", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config1.Icsa, 0, Handler);
	ESPER_CreateVarUInt8(mid, "gain", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config1.Gain, 0, Handler);
	ESPER_CreateVarUInt8(mid, "time", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config1.Time, 0, Handler);
	ESPER_CreateVarUInt8(mid, "test", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config1.Test, 0, Handler);
	ESPER_CreateVarUInt8(mid, "integrator", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config1.Integrator_mode, 0, Handler);
	ESPER_CreateVarUInt8(mid, "pd_read", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config1.power_down_read, 0, Handler);
	ESPER_CreateVarUInt8(mid, "pd_write", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config1.power_down_write, 0, Handler);
	ESPER_CreateVarUInt8(mid, "alt_power", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config1.alternate_power, 0, Handler);
	ESPER_CreateVarUInt8(mid, "debug", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config2.debug, 0, Handler);
	ESPER_CreateVarUInt8(mid, "read_from_0", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config2.read_from_0, 0, Handler);
	ESPER_CreateVarUInt8(mid, "test_digout", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config2.test_digout, 0, Handler);
	ESPER_CreateVarUInt8(mid, "ena_rst_marker", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config2.en_mker_rst, 0, Handler);
	ESPER_CreateVarUInt8(mid, "rst_lv_to_1", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config2.rst_lv_to_1, 0, Handler);
	ESPER_CreateVarUInt8(mid, "boost_pw", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config2.boost_pw, 0, Handler);
	ESPER_CreateVarUInt8(mid, "out_resync", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config2.out_resync, 0, Handler);
	ESPER_CreateVarUInt8(mid, "synchro_inv", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config2.synchro_inv, 0, Handler);
	ESPER_CreateVarUInt8(mid, "force_eout", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config2.force_eout, 0, Handler);
	ESPER_CreateVarUInt8(mid, "cur_ra", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config2.Cur_RA, 0, Handler);
	ESPER_CreateVarUInt8(mid, "cur_buf", 	ESPER_OPTION_WR_RD, 1, &ctx->sca_regmap.config2.Cur_BUF, 0, Handler);

	return ESPER_ERR_OK;
}

static eESPERError Start(tESPERMID mid, tESPERModuleSCA* ctx) {
	uint32_t k;

	AFTER_ReadSettings(ctx->sca_read, &ctx->sca_regmap);

	ctx->sca_regmap.config1.Icsa = 0;
	ctx->sca_regmap.config1.Gain = 0;
	ctx->sca_regmap.config1.Time = 0;
	ctx->sca_regmap.config1.Test = 0;
	ctx->sca_regmap.config1.Integrator_mode = 0;
	ctx->sca_regmap.config1.power_down_read = 0;
	ctx->sca_regmap.config1.power_down_write = 0;
	ctx->sca_regmap.config1.alternate_power = 0;
	AFTER_WriteConfig1(ctx->sca_write, &ctx->sca_regmap.config1);

	ctx->sca_regmap.config2.debug = 0;
	ctx->sca_regmap.config2.read_from_0 = 0;
	ctx->sca_regmap.config2.test_digout = 0;
	ctx->sca_regmap.config2.en_mker_rst = 0;
	ctx->sca_regmap.config2.rst_lv_to_1 = 0;
	ctx->sca_regmap.config2.boost_pw = 0;
	ctx->sca_regmap.config2.out_resync = 0;
	ctx->sca_regmap.config2.synchro_inv = 0;
	ctx->sca_regmap.config2.force_eout = 0;
	ctx->sca_regmap.config2.Cur_RA = 0;
	ctx->sca_regmap.config2.Cur_BUF = 0;
	AFTER_WriteConfig2(ctx->sca_write, &ctx->sca_regmap.config2);

	for(k=0; k<4; k++) {
		ctx->sca_regmap.injection.select_cfpn[k] = 0;
	}

	for(k=0; k<72; k++) {
		ctx->sca_regmap.injection.select_ch[k] = 1;
	}

	AFTER_WriteAll(ctx);

	return ESPER_ERR_OK;
}

static const void* Handler(tESPERMID mid, const char* key, eESPERRequest request, uint32_t offset, uint32_t* num_elements, void* ctx) {
	switch(request) {
	case ESPER_REQUEST_WRITE_POST:
		AFTER_WriteAll((tESPERModuleSCA*)ctx);
		break;
	default:
		break;
	}

	return 0;
}

static void AFTER_WriteAll(tESPERModuleSCA* ctx) {
	AFTER_WriteConfig1(ctx->sca_write, &ctx->sca_regmap.config1);
	AFTER_WriteConfig2(ctx->sca_write, &ctx->sca_regmap.config2);
	AFTER_WriteInjection(ctx->sca_write, &ctx->sca_regmap.injection);
}

static eESPERError Update(tESPERMID mid, tESPERModuleSCA* ctx) {

	return ESPER_ERR_OK;
}

