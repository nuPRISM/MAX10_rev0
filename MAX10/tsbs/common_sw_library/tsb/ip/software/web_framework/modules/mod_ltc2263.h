/*
 * mod_ltc2263.h
 *
 *  Created on: Nov 14, 2016
 *      Author: bryerton
 */

#ifndef MOD_LTC2263_H_
#define MOD_LTC2263_H_

#include "../ltc2263.h"

typedef struct {
	ltc2263_write spi_write;
	ltc2263_read spi_read;
	tLTC2263 regmap;
	uint8_t *io_adc_rand_en;
} tESPERModuleLTC2263;

eESPERError ModuleLTC2263Handler(tESPERMID mid, tESPERGID gid, eESPERModuleState state, ESPER_TIMESTAMP ts, void* ctx);
tESPERModuleLTC2263* ModuleLTC2263Init(tESPERModuleLTC2263* ctx);

#endif /* MOD_LTC2263_H_ */
