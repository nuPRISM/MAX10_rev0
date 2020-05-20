/*
 * mod_board.h
 *
 *  Created on: Apr 2, 2017
 *      Author: admin
 */

#ifndef MOD_BOARD_H_
#define MOD_BOARD_H_

#include <unistd.h>
#include <esper.h>

typedef struct {
	uint64_t chipid;
	uint8_t serdes_locked;
	uint8_t serdes_aligned;
	uint8_t adc_pwr_en[2];
	uint8_t reset_counters;
	uint8_t ext_test_pulse;
	uint8_t use_sata_gxb;

	uint32_t freq_clocka;
	uint32_t freq_io;
	uint32_t freq_sca_wr;
	uint32_t freq_sca_rd;
	uint32_t freq_sfp;
	uint32_t freq_sata;
	uint32_t cnt_locked[2];
	uint32_t cnt_aligned[2];
} tESPERModuleBoard;

eESPERError BoardModuleHandler(tESPERMID mid, tESPERGID gid, eESPERModuleState state, ESPER_TIMESTAMP ts, void* ctx);
tESPERModuleBoard* BoardModuleInit(tESPERModuleBoard* ctx);

#endif /* MOD_BOARD_H_ */
