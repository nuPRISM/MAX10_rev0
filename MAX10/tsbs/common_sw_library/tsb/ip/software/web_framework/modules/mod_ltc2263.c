/*
 * adc32.c
 *
 *  Created on: Nov 14, 2016
 *      Author: bryerton
 */

#include <assert.h>
#include <system.h>
#include <unistd.h>
#include <esper.h>
#include "mod_ltc2263.h"

static void Init(tESPERMID mid, tESPERGID gid, tESPERModuleLTC2263* data);
static void Start(tESPERMID mid, tESPERGID gid, tESPERModuleLTC2263* data);
static void Update(tESPERMID mid, tESPERGID gid, tESPERModuleLTC2263* data);

static const void* Handler(tESPERMID mid, const char* key, eESPERRequest request, uint32_t offset, uint32_t* num_elements, void* ctx);

eESPERError ModuleLTC2263Handler(tESPERMID mid, tESPERGID gid, eESPERModuleState state, ESPER_TIMESTAMP ts, void* ctx) {
	switch(state) {
	case ESPER_MOD_STATE_INIT:
		Init(mid, gid, (tESPERModuleLTC2263*)ctx);
		break;
	case ESPER_MOD_STATE_START:
		Start(mid, gid, (tESPERModuleLTC2263*)ctx);
		break;
	case ESPER_MOD_STATE_UPDATE:
		Update(mid, gid, (tESPERModuleLTC2263*)ctx);
		break;
	case ESPER_MOD_STATE_STOP:
		break;
	}

	return ESPER_ERR_OK;
}

tESPERModuleLTC2263* ModuleLTC2263Init(tESPERModuleLTC2263* ctx) {
	if(!ctx) return 0;
	if(!ctx->spi_write) return 0;
	if(!ctx->spi_read) return 0;

	return ctx;
}

static void Init(tESPERMID mid, tESPERGID gid, tESPERModuleLTC2263* ctx) {


	ESPER_CreateVarBool(mid, "dcs_disable",		ESPER_OPTION_WR_RD, 1, &ctx->regmap.dcs_disable, 0, Handler);
	ESPER_CreateVarBool(mid, "rand_enable", 	ESPER_OPTION_WR_RD, 1, &ctx->regmap.randomizer_en, 0, Handler);
	ESPER_CreateVarUInt8(mid, "data_format", 	ESPER_OPTION_WR_RD, 1, &ctx->regmap.data_format, 0, Handler);
	ESPER_CreateVarUInt8(mid, "sleep_mode", 	ESPER_OPTION_WR_RD, 1, &ctx->regmap.sleep_mode, 0, Handler);
	ESPER_CreateVarUInt8(mid, "lvds_current",	ESPER_OPTION_WR_RD, 1, &ctx->regmap.lvds_current, 0, Handler);
	ESPER_CreateVarBool(mid, "lvds_term",		ESPER_OPTION_WR_RD, 1, &ctx->regmap.lvds_term_en, 0, Handler);
	ESPER_CreateVarBool(mid, "output_disable",	ESPER_OPTION_WR_RD, 1, &ctx->regmap.output_disable, 0, Handler);
	ESPER_CreateVarUInt8(mid, "output_mode",	ESPER_OPTION_WR_RD, 1, &ctx->regmap.output_mode, 0, Handler);
	ESPER_CreateVarBool(mid, "test_enable",		ESPER_OPTION_WR_RD, 1, &ctx->regmap.test_en, 0, Handler);
	ESPER_CreateVarUInt16(mid, "test_pattern",	ESPER_OPTION_WR_RD, 1, &ctx->regmap.test_pattern, 0, Handler);
}

static void Start(tESPERMID mid, tESPERGID gid, tESPERModuleLTC2263* ctx) {
	LTC2263_Reset( ctx->spi_write);
	usleep(100000);
	ctx->regmap.dcs_disable = LTC2263_DUTY_CYCLE_STABILIZER_ON;
	ctx->regmap.randomizer_en = LTC2263_DATA_OUTPUT_RANDOMIZER_ON;
	ctx->regmap.lvds_current = LTC2263_LVDS_CURRENT_3_5;
	ctx->regmap.lvds_term_en	= LTC2263_LVDS_TERMINATION_OFF;
	ctx->regmap.data_format = LTC2263_DATA_FORMAT_TWOS_COMP;
	ctx->regmap.output_disable = LTC2263_DIGITAL_OUTPUT_ENABLED;
	ctx->regmap.output_mode = LTC2263_DIGITAL_OUTPUT_MODE_2LANE_16BIT;
	ctx->regmap.sleep_mode = LTC2263_SLEEP_MODE_NORMAL;
	ctx->regmap.test_en = LTC2263_DIGITAL_TEST_PATTERN_OFF;
	ctx->regmap.test_pattern = 0x0000;

	// If the randomizer is on, this bit must be set to XOR the data in the SERDES
	if(ctx->regmap.randomizer_en == LTC2263_DATA_OUTPUT_RANDOMIZER_ON) {
		*ctx->io_adc_rand_en = 1;
	} else {
		*ctx->io_adc_rand_en = 0;
	}

	LTC2263_WriteSettings( ctx->spi_write, &ctx->regmap );
}

static void Update(tESPERMID mid, tESPERGID gid, tESPERModuleLTC2263* ctx) {

}

static const void* Handler(tESPERMID mid, const char* key, eESPERRequest request, uint32_t offset, uint32_t* num_elements, void* ctx) {
	tESPERModuleLTC2263* adc_ctx = (tESPERModuleLTC2263*)ctx;

	switch(request) {
	case ESPER_REQUEST_WRITE_POST:
		LTC2263_WriteSettings( adc_ctx->spi_write, &adc_ctx->regmap );
		// If the randomizer is on, this bit must be set to XOR the data in the SERDES
		if(adc_ctx->regmap.randomizer_en == LTC2263_DATA_OUTPUT_RANDOMIZER_ON) {
			*adc_ctx->io_adc_rand_en = 1;
		} else {
			*adc_ctx->io_adc_rand_en = 0;
		}
		break;
	default:
		break;
	}

	return 0;
}
