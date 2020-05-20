/*
 * sfp.h
 *
 *  Created on: Dec 9, 2016
 *      Author: admin
 */

#ifndef MOD_SFP_H_
#define MOD_SFP_H_

#include <esper.h>

typedef struct {
	uint8_t transceiver_type;
	uint8_t transceiver_type_ext;
	uint8_t  connector;
	uint8_t encoding;
	uint8_t nominal_bitrate;
	uint8_t rate_id;
	char	vendor_name[16];
	char 	vendor_oui[3];
	char	vendor_part[16];
	char 	vendor_rev[4];
	uint16_t laser_wavelen;
	char	vendor_serial[16];
	char	date_code[8];
} tESPERModuleSFP;

tESPERModuleSFP* ModuleSFPInit(tESPERModuleSFP* ctx);
eESPERError ModuleSFPHandler(tESPERMID mid, tESPERGID gid, eESPERModuleState state, ESPER_TIMESTAMP ts, void* ctx);

#endif /* MOD_SFP_H_ */
