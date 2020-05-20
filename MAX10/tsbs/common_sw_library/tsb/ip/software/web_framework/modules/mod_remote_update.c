/*
 * mod_remote.c
 *
 *  Created on: Mar 27, 2017
 *      Author: admin
 */

#include <string.h>
#include "mod_remote_update.h"

static void Init(tESPERMID mid, tESPERModuleRemoteUpdate* data);
static void Start(tESPERMID mid, tESPERModuleRemoteUpdate* data);
static void Update(tESPERMID mid, tESPERModuleRemoteUpdate* data);

static const void* Reconfig(tESPERMID mid, const char* key, eESPERRequest request, uint32_t offset, uint32_t* num_elements, void* ctx);

eESPERError RemoteUpdateModuleHandler(tESPERMID mid, tESPERGID gid, eESPERModuleState state, ESPER_TIMESTAMP ts, void* ctx) {
	switch(state) {
	case ESPER_MOD_STATE_INIT:
		Init(mid, (tESPERModuleRemoteUpdate*)ctx);
		break;
	case ESPER_MOD_STATE_START:
		Start(mid, (tESPERModuleRemoteUpdate*)ctx);
		break;
	case ESPER_MOD_STATE_UPDATE:
		Update(mid, (tESPERModuleRemoteUpdate*)ctx);
		break;
	case ESPER_MOD_STATE_STOP:
		break;
	}

	return ESPER_ERR_OK;
}

tESPERModuleRemoteUpdate* RemoteUpdateModuleInit(tESPERModuleRemoteUpdate* ctx) {
	uint32_t reg;

	if(!ctx) return 0;

	ctx->state = altera_remote_update_open(ctx->dev_name);

	reg = IORD_ALTERA_RU_RECONFIG_TRIGGER_CONDITIONS(ctx->state->base);
	ctx->wdtimer_source 	= ((reg & (1 << 4)) != 0) ? 1 : 0;
	ctx->nconfig_source 	= ((reg & (1 << 3)) != 0) ? 1 : 0;
	ctx->runconfig_source 	= ((reg & (1 << 2)) != 0) ? 1 : 0;
	ctx->nstatus_source 	= ((reg & (1 << 1)) != 0) ? 1 : 0;
	ctx->crcerror_source 	= ((reg & (1 << 0)) != 0) ? 1 : 0;

	reg = IORD_ALTERA_RU_WATCHDOG_ENABLE(ctx->state->base);
	ctx->watchdog_enabled 	= ((reg & ALTERA_RU_WATCHDOG_ENABLE_MASK) != 0) ? 1 : 0;

	reg = IORD_ALTERA_RU_CONFIG_MODE(ctx->state->base);
	ctx->config_mode 		= reg & ALTERA_RU_RECONFIG_MODE_MASK;

	reg = IORD_ALTERA_RU_PAGE_SELECT(ctx->state->base);
	ctx->page_select 		= reg;

	return ctx;
}

static void Init(tESPERMID mid,  tESPERModuleRemoteUpdate* ctx) {

	ESPER_CreateVarBool(mid, "wdtimer_src",	ESPER_OPTION_RD, 1, &ctx->wdtimer_source, 0, 0);
	ESPER_CreateVarBool(mid, "nconfig_src",	ESPER_OPTION_RD, 1, &ctx->nconfig_source, 0, 0);
	ESPER_CreateVarBool(mid, "runconfig_src",ESPER_OPTION_RD, 1, &ctx->runconfig_source, 0, 0);
	ESPER_CreateVarBool(mid, "nstatus_src",	ESPER_OPTION_RD, 1, &ctx->nstatus_source, 0, 0);
	ESPER_CreateVarBool(mid, "crcerror_src",	ESPER_OPTION_RD, 1, &ctx->crcerror_source, 0, 0);
	ESPER_CreateVarBool(mid, "watchdog_ena",ESPER_OPTION_RD, 1, &ctx->watchdog_enabled, 0, 0);
	ESPER_CreateVarBool(mid, "application", 	ESPER_OPTION_RD, 1, &ctx->config_mode, 0, 0);
	ESPER_CreateVarUInt32(mid, "page_select", ESPER_OPTION_RD, 1, &ctx->page_select, 0, 0);
	ESPER_CreateVarUInt32(mid, "app_page", 		ESPER_OPTION_RD, 1, &ctx->app_page, 0, 0);
	ESPER_CreateVarNull(mid, "reconfig", ESPER_OPTION_WR, 1, Reconfig);
}

static void Start(tESPERMID mid, tESPERModuleRemoteUpdate* ctx) {

}

static void Update(tESPERMID mid, tESPERModuleRemoteUpdate* ctx) {
	// If the watchdog was enabled by the remote upgrade ip, toggle it!
	if(ctx->watchdog_enabled) {
		IOWR_ALTERA_RU_RESET_TIMER(ctx->state->base, 1);
	}
}

static const void* Reconfig(tESPERMID mid, const char* key, eESPERRequest request, uint32_t offset, uint32_t* num_elements, void* ctx) {
	tESPERModuleRemoteUpdate* remote_ctx = (tESPERModuleRemoteUpdate*)ctx;

	switch(request) {
	case ESPER_REQUEST_WRITE_POST:
		altera_remote_update_trigger_reconfig(remote_ctx->state, 1, remote_ctx->app_page, 0);
		break;
	default:
		break;
	}

	return 0;
}
