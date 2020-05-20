/*
 * ufm_flash_encapsulator.c
 *
 *  Created on: Aug 6, 2016
 *      Author: user
 */

#include "ufm_flash_encapsulator.h"
#include "xprintf.h"

void ufm_flash_encapsulator_init(ufm_flash_encapsulator* s,
		unsigned long the_base_address,
		unsigned long offset,
		unsigned long block_size,
		unsigned long  region_size,
		unsigned long  number_of_blocks,
		char* rw_buffer,
		const char* device_name,
		const char* description
		) {
	s->base_address = the_base_address;
	s->block_size = block_size;
	s->number_of_blocks = number_of_blocks;
	s->rw_buffer = rw_buffer;
	s->device_name = device_name;
	s->description = description;
	// Open up the flash device so we can write to it
    s->fd = alt_flash_open_dev(s->device_name);
    s->region_size      =  region_size     ;

	if(s->fd == NULL) {
		xprintf("%sUnable to open flash device %s with description %s\n",COMMENT_STR,s->device_name,s->description);
	}
}


int WriteBufferToFlash(ufm_flash_encapsulator* s,
		int block
		)
{
	    int ret_code;
	    unsigned long total_offset = s->offset + (block * s->block_size);
		// Erase the page and write the modified data back to it
		ret_code = alt_write_flash
				(s->fd,
						total_offset,
				s->rw_buffer,
				s->block_size);

		if(ret_code != 0) {
			xprintf("%s Could not write %d bytes of data at offset 0x%x (block = %d), return code is %d\n", COMMENT_STR, s->block_size, total_offset, block, ret_code);
		} else {
			xprintf("%s%d bytes of data written at offset 0x%x (block %d) successfully\n", COMMENT_STR, s->block_size, total_offset, block);
		}

		return ret_code;

}


int ReadBufferFromFlash(ufm_flash_encapsulator* s,
		int block,
		int silent
		)
{
	    int ret_code;
	    unsigned long total_offset = s->offset + (block * s->block_size);

		ret_code = alt_read_flash
				(s->fd,
				s->offset + (block * s->block_size),
				s->rw_buffer,
				s->block_size);

		if (!silent) {
		if(ret_code != 0) {
			xprintf("%s Could not read %d bytes of data at offset 0x%x (block = %d), return code is %d\n", COMMENT_STR, s->block_size, total_offset, block, ret_code);
		} else {
			xprintf("%s%d bytes of data read at offset 0x%x (block = %d) successfully\n", COMMENT_STR, s->block_size, total_offset, block);
		}
		}
		return ret_code;
}

/**
 * Reads a single byte from the specified region and offset.
 *
 * @param	fd		A file descriptor to the internal flash memory
 * @param	region	The sector/region to read from
 * @param	block	The page/block within the sector to read from
 * @param	offset	The byte offset within the page/block to read from
 */
alt_u8 ReadByte(ufm_flash_encapsulator* s, int block, int offset_in_block)
{
	int ret_code = 0;

	// Data that was from flash
	alt_u8 data = 0;

	unsigned long total_offset = s->offset + (block * s->block_size) + offset_in_block;
	// Read a single byte of data
	ret_code = alt_read_flash(s->fd, total_offset, &data, 1);

	// If we failed to read the flash data
	if(ret_code != 0) {
		xprintf("%sCouldn't read data from flash %s at block = %d and offset=0x%x\n",COMMENT_STR,block,total_offset);
	} else {
		xprintf("%sData read at offset 0x%x: %x\n", COMMENT_STR,total_offset, (unsigned long) data);
	}
	return data;
}

/**
 * Erases a single page/block from the specified region.
 *
 * @param	fd		A file descriptor to the internal flash memory
 * @param	region	The sector/region to erase from
 * @param	block	The page/block within the sector to erase
 */
int EraseBlock(ufm_flash_encapsulator* s, int block)
{
	int ret_code = 0;

	// Read a single byte of data
	unsigned long total_offset = s->offset + (block * s->block_size) ;

	ret_code = alt_erase_flash_block(s->fd, total_offset, s->block_size);

	// If we failed to erase the flash data
	if(ret_code != 0) {
		xprintf("%sCouldn't read erase from flash %s at block = %d and total offset=0x%x\n",COMMENT_STR,block,total_offset);
	} else {
		xprintf("%sData erase at offset 0x%x, block = %d failed\n",
				COMMENT_STR,
				total_offset,
				block);
	}
	return ret_code;
}

