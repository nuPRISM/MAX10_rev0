/*
 * pfl.c
 *
 *  Created on: 2013-05-21
 *      Author: bryerton
 */

#include "pfl.h"


void PFL_GetOptionBits(alt_flash_fd* flash, alt_u32 offset, tPFL* pfl) {
	alt_u32 n;
	alt_u8 data[4];

	// Read Option bits
	for(n = 0; n < PFL_NUM_PAGES; ++n) {
		alt_read_flash(flash, offset + (n * 4), data, 4);
		pfl->page_addr[n].valid_n = data[0] & 0x01;
		pfl->page_addr[n].start = ((data[1] << 8) | (data[0] & 0xF7)) << 12;
		pfl->page_addr[n].end 	= ((data[3] << 8) | (data[2] & 0xF7)) << 12;
	}

	alt_read_flash(flash, offset + PFL_ADDR_VERSION, &pfl->pof_version, 1);
}
