/*
 * mod_remote.h
 *
 *  Created on: Mar 27, 2017
 *      Author: admin
 */

// @NOTE: In order to use remote_update, the Altera Device must be configured to REMOTE mode inside Quartus Device Settings

#ifndef MOD_REMOTE_UPDATE_H_
#define MOD_REMOTE_UPDATE_H_

#include <esper/esper.h>
#include <drivers/inc/altera_remote_update_regs.h>
#include <drivers/inc/altera_remote_update.h>

typedef struct {
	altera_remote_update_state* state;
	uint32_t app_page;
	uint8_t wdtimer_source;
	uint8_t nconfig_source;
	uint8_t runconfig_source;
	uint8_t nstatus_source;
	uint8_t crcerror_source;
	uint8_t watchdog_enabled;
	uint32_t page_select;
	uint8_t config_mode;
	char* dev_name;
} tESPERModuleRemoteUpdate;

eESPERError RemoteUpdateModuleHandler(tESPERMID mid, tESPERGID gid, eESPERModuleState state, ESPER_TIMESTAMP ts, void* ctx);
tESPERModuleRemoteUpdate* RemoteUpdateModuleInit(tESPERModuleRemoteUpdate* ctx);

#endif /* MOD_REMOTE_UPDATE_H_ */
