/*
 * dp_mem_read.c
 *
 *  Created on: Mar 8, 2012
 *      Author: linnyair
 */

#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "adc_mcs_basedef.h"
#include "sys/alt_stdio.h"
#include "dp_mem_api.h"
#include <xprintf.h>

unsigned long read_32_bits_from_dp_mem(unsigned long address) {
#ifdef BOARDMANAGEMENT_0_DUAL_PORT_MEM_CONTROLLER_QSYS_0_SPAN

	unsigned long word_address = address;
	if (word_address >= BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_REGION_TOTAL_SPAN_IN_32_BIT_WORDS)
	{
		alt_printf("\n[read_from_dp_mem]Error: Address %x out of range\n",address);
		return 0;
	} else {
		unsigned long data = *((unsigned long *)(BOARDMANAGEMENT_0_DUAL_PORT_MEM_CONTROLLER_QSYS_0_BASE + (word_address << 2)));
		//alt_printf("\n[read_from_dp_mem] Address %x total_address = %x data = %x\n",address,(BOARDMANAGEMENT_0_DUAL_PORT_MEM_CONTROLLER_QSYS_0_BASE + (word_address << 2)),data);
		return (data);
	}
#else
	return 0;
#endif
}



void write_32_bits_to_dp_mem(unsigned long address,unsigned long data) {
#ifdef BOARDMANAGEMENT_0_DUAL_PORT_MEM_CONTROLLER_QSYS_0_SPAN

	unsigned long word_address = address;
	if (word_address >= BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_REGION_TOTAL_SPAN_IN_32_BIT_WORDS)
	{
		alt_printf("\n[write_to_dp_mem]Error: Address %x out of range\n",address);
	} else {
		*((unsigned long *)(BOARDMANAGEMENT_0_DUAL_PORT_MEM_CONTROLLER_QSYS_0_BASE + (word_address << 2)))=data;
		//alt_printf("\n[write_to_dp_mem] Address %x total_address = %x data = %x\n",address,(BOARDMANAGEMENT_0_DUAL_PORT_MEM_CONTROLLER_QSYS_0_BASE + (word_address << 2)),data);
	}
#else
	return;
#endif
}
