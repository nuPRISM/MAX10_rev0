/*
 * mod_sca.h
 *
 *  Created on: Nov 14, 2016
 *      Author: bryerton
 */

#ifndef MOD_SCA_H_
#define MOD_SCA_H_

#include "../AFTER_slowcontrol.h"

typedef struct {
	AFTER_write sca_write;
	AFTER_read  sca_read;
	tAFTER_Registers sca_regmap;
} tESPERModuleSCA;

tESPERModuleSCA* SCAModuleInit(AFTER_write sca_write, AFTER_read sca_read, tESPERModuleSCA* ctx);
eESPERError SCAModuleHandler(tESPERMID mid, tESPERGID gid, eESPERModuleState state, ESPER_TIMESTAMP ts, void* ctx);


#endif /* MOD_SCA_H_ */
