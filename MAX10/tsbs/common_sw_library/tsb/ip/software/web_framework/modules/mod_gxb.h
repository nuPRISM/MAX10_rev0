/*
 * mod_gxb.h
 *
 *  Created on: Apr 3, 2017
 *      Author: admin
 */

#ifndef MOD_GXB_H_
#define MOD_GXB_H_

#include <unistd.h>
#include <esper.h>

typedef struct {
	uint32_t ctrl_base;
	uint32_t stat_base;

	uint8_t loopback_en;
	uint8_t lock_rx_to_dat;
	uint8_t lock_rx_to_ref;
	uint8_t reset_counters;

	uint8_t pll_locked;
	uint8_t is_locked_dat;
	uint8_t is_locked_ref;
	uint8_t signal_detect;
	uint8_t tx_cal_busy;
	uint8_t rx_cal_busy;
	uint8_t rx_err_detect;
	uint8_t rx_err_parity;
	uint8_t rx_sync_status;
	uint8_t rx_pattern_det;

	uint32_t freq_tx_core;
	uint32_t freq_rx_core;

	uint32_t cnt_pll_lock;
	uint32_t cnt_lock_dat;
	uint32_t cnt_lock_ref;
	uint32_t cnt_signal_det;
	uint32_t cnt_rx_err_det;
	uint32_t cnt_rx_err_par;
	uint32_t cnt_rx_sync_stat;
	uint32_t cnt_rx_pattern_det;
} tESPERModuleGXB;

eESPERError GXBModuleHandler(tESPERMID mid, tESPERGID gid, eESPERModuleState state, ESPER_TIMESTAMP ts, void* ctx);
tESPERModuleGXB* GXBModuleInit(tESPERModuleGXB* ctx);

#endif /* MOD_GXB_H_ */
