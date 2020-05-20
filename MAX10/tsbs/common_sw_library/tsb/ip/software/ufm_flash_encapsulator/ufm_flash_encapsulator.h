/*
 * ufm_flash_encapsulator.h
 *
 *  Created on: Aug 6, 2016
 *      Author: user
 */

#ifndef UFM_FLASH_ENCAPSULATOR_H_
#define UFM_FLASH_ENCAPSULATOR_H_

#include <system.h>
#include <alt_types.h>
#include <sys/alt_flash.h>
#include "basedef.h"

typedef struct ufm_flash_encapsulator_s {
	unsigned long base_address;
	unsigned long block_size;
	alt_flash_fd * fd;
	unsigned long offset;
	unsigned long region_size;
	unsigned long number_of_blocks;
	char* rw_buffer;
	char* device_name;
	char* description;
} ufm_flash_encapsulator;

void ufm_flash_encapsulator_init(ufm_flash_encapsulator* s,
		unsigned long the_base_address,
		unsigned long offset,
		unsigned long block_size,
		unsigned long  region_size,
		unsigned long  number_of_blocks,
		char* rw_buffer,
		const char* device_name,
		const char* description
		);
int WriteBufferToFlash(ufm_flash_encapsulator* s,int block);
int ReadBufferFromFlash(ufm_flash_encapsulator* s, int block, int silent);
alt_u8 ReadByte(ufm_flash_encapsulator* s, int block, int offset_in_block);
int EraseBlock(ufm_flash_encapsulator* s, int block);


#endif /* UFM_FLASH_ENCAPSULATOR_H_ */
