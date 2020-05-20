/*
 * mod_cc.c
 *
 *  Created on: Nov 14, 2016
 *      Author: bryerton
 */

#include <assert.h>
#include <system.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <drivers/inc/altera_avalon_spi.h>
#include <drivers/inc/altera_avalon_spi_regs.h>
#include <drivers/inc/altera_avalon_pio_regs.h>
#include "mod_lmk04816.h"

static eESPERError Init(tESPERMID mid, tESPERModuleLMK04816* data);
static eESPERError Start(tESPERMID mid, tESPERModuleLMK04816* data);
static eESPERError Update(tESPERMID mid, tESPERModuleLMK04816* data);

tESPERModuleLMK04816* LMK04816ModuleInit(tESPERModuleLMK04816* ctx) {
	if(!ctx) return 0;
	if(!ctx->uwire_write) return 0;
	if(!ctx->uwire_read) return 0;

	return ctx;
}

eESPERError LMK04816ModuleHandler(tESPERMID mid, tESPERGID gid, eESPERModuleState state, ESPER_TIMESTAMP ts, void* ctx) {

	switch(state) {
	case ESPER_MOD_STATE_INIT:
		return Init(mid, (tESPERModuleLMK04816*)ctx);
	case ESPER_MOD_STATE_START:
		return Start(mid, (tESPERModuleLMK04816*)ctx);
	case ESPER_MOD_STATE_UPDATE:
		return Update(mid, (tESPERModuleLMK04816*)ctx);
	case ESPER_MOD_STATE_STOP:
		break;
	}

	return ESPER_ERR_OK;
}

static eESPERError Init(tESPERMID mid, tESPERModuleLMK04816* ctx) {
	ESPER_CreateVarBool(mid, "plls_locked", ESPER_OPTION_RD, 1, &ctx->plls_locked, ctx->lmk_stat_ld, 0);
	ESPER_CreateVarBool(mid, "holdover_on",	ESPER_OPTION_RD, 1, &ctx->holdover_on, ctx->lmk_stat_hold, 0);
	ESPER_CreateVarBool(mid, "sfp_sel", 	ESPER_OPTION_RD, 1, &ctx->clk1_los, ctx->lmk_stat_clkin1, 0);
	ESPER_CreateVarBool(mid, "sata_sel",	ESPER_OPTION_RD, 1, &ctx->clk2_los, ctx->lmk_sync_clkin2, 0);
	return ESPER_ERR_OK;
}

static eESPERError Start(tESPERMID mid, tESPERModuleLMK04816* ctx) {

	return ESPER_ERR_OK;
}

static eESPERError Update(tESPERMID mid, tESPERModuleLMK04816* ctx) {

	return ESPER_ERR_OK;
}
