/*
 * mod_cc.h
 *
 *  Created on: Nov 14, 2016
 *      Author: bryerton
 */

#ifndef MOD_CC_H_
#define MOD_CC_H_

#include <unistd.h>
#include <esper.h>
#include "../lmk04816.h"

typedef struct {
	lmk04816_write uwire_write;
	lmk04816_read  uwire_read;

	uint8_t plls_locked;
	uint8_t holdover_on;
	uint8_t clk2_los;
	uint8_t clk1_los;

	uint8_t *lmk_stat_ld;
	uint8_t *lmk_stat_hold;
	uint8_t *lmk_sync_clkin2;
	uint8_t *lmk_stat_clkin1;

	tLMK04816_Registers regmap;
} tESPERModuleLMK04816;

eESPERError LMK04816ModuleHandler(tESPERMID mid, tESPERGID gid, eESPERModuleState state, ESPER_TIMESTAMP ts, void* ctx);
tESPERModuleLMK04816* LMK04816ModuleInit(tESPERModuleLMK04816* ctx);

#endif /* MOD_CC_H_ */
