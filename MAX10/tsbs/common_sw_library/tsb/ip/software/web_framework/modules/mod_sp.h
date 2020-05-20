/*
 * mod_sp.h
 *
 *  Created on: Nov 14, 2016
 *      Author: bryerton
 */

#ifndef MOD_SP_H_
#define MOD_SP_H_

#include <esper.h>

typedef struct {
	uint32_t sp_ctrl_base;
	uint32_t sp_stat_base;

	uint8_t force_run;
	uint8_t force_rst;
	uint8_t trig_out;
	uint8_t hold_ena;
	uint32_t trig_delay;
	uint8_t ext_trig_ena;
	uint8_t ext_trig_inv;
	uint8_t sfp_trig_ena;
	uint8_t test_pulse_ena[4];
	uint32_t test_pulse_dly[4];

	uint8_t run_status;
	uint8_t hold_status;
	uint64_t ts_run;
	uint64_t ts_start;
	uint64_t ts_trig;
	uint32_t trig_accepted;
	uint32_t trig_dropped;

	uint32_t trig_cnt_int;
	uint32_t trig_cnt_ext;
	uint32_t trig_cnt_sfp;

	int16_t* sca_ddr_reserved_region;
	int16_t* sca_copied_region;
} tESPERModuleSP;

tESPERModuleSP* ModuleSPInit(uint32_t sp_ctrl_base, uint32_t sp_stat_base, tESPERModuleSP* ctx);
eESPERError ModuleSPHandler(tESPERMID mid, tESPERGID gid, eESPERModuleState state, ESPER_TIMESTAMP ts, void* ctx);

#endif /* MOD_SP_H_ */
