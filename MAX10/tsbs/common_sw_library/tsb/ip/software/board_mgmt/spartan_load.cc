/*
 * spartan_load.c
 *
 *  Created on: 2013-05-21
 *      Author: bryerton
 */

#include <altera_avalon_spi.h>
#include <altera_avalon_pio_regs.h>
#include <unistd.h>
#include <system.h>
#include "spartan_load.h"

#define SPARTAN_LOAD_CHUNK_SIZE 512 // May be able to increase this in the future to a larger/faster size
static alt_u8 g_flash_data[SPARTAN_LOAD_CHUNK_SIZE];

spartan_err Spartan_GetInfo(alt_flash_fd* flash, alt_u32 offset, tSpartanInfo* info) {
	spartan_err err_code;

	//err_code = SPARTAN_ERR_UNKNOWN;

	// @TODO: Actually read flash and include additional information if necessary (build number?)
	//info->filename = "6deapSpartanADC.ncd";
	//info->partname = "6slx45fgg484";
	info->board_id = 0xffffffff;
	info->datetime = 0;
	//info->length = 1484404;
	info->length = 0x01FFFF0;
	//err_code = SPARTAN_ERR_OK;

	return SPARTAN_ERR_OK;
}

spartan_err Spartan_Load(alt_flash_fd* flash, alt_u32 offset, tSpartanInfo* info, alt_u32 spi_base, alt_u32 slave, alt_u32 io_base_prog_b, alt_u32 io_msk_prog_b, alt_u32 io_base_init_b, alt_u32 io_msk_init_b, alt_u32 io_base_done, alt_u32 io_msk_done, alt_u32 led_base, alt_u32 led_pin,  alt_u32 spartan_image_offset = 0) {
	spartan_err err_code;

	alt_u32 toggle;
	alt_u32 n;
	alt_u32 chunk_size;

	// Toggle PROGRAM_B to reset device
	IOWR_ALTERA_AVALON_PIO_SET_BITS(io_base_prog_b, io_msk_prog_b);
	usleep(5000);
	IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(io_base_prog_b, io_msk_prog_b);
	usleep(5000);
	IOWR_ALTERA_AVALON_PIO_SET_BITS(io_base_prog_b, io_msk_prog_b);
	usleep(5000);

	err_code = SPARTAN_ERR_OK;

	toggle = 0;

	chunk_size = SPARTAN_LOAD_CHUNK_SIZE;
	for(n = 0; n < info->length; n += chunk_size) {
		// Reduce size of chunk to remaining length if necessary
		if(n + SPARTAN_LOAD_CHUNK_SIZE >= info->length) { chunk_size = info->length - n; }

		int flash_result = alt_read_flash(flash, spartan_image_offset + offset + n, g_flash_data, chunk_size);
		int spi_result = alt_avalon_spi_command(spi_base, slave, chunk_size, g_flash_data, 0, 0, 0);
		//printf("flash_result = %d spi_result = %d data = %x %x %x %x\n",flash_result,spi_result,g_flash_data[0],g_flash_data[1],g_flash_data[2],g_flash_data[3]);

		if(toggle < 50) {
			toggle++;
			IOWR_ALTERA_AVALON_PIO_SET_BITS(led_base, led_pin);
		} else if (toggle < 100) {
			toggle++;
			IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(led_base, led_pin);
		} else {
			toggle = 0;
		}
	}

	// Check Done Pin for success
	if(!(IORD_ALTERA_AVALON_PIO_DATA(io_base_done) & io_msk_done)) {
		err_code |= SPARTAN_ERR_CONF;
	}

	// Check INIT_B Pin for CRC error
	if(!(IORD_ALTERA_AVALON_PIO_DATA(io_base_init_b) & io_msk_init_b)) {
		err_code |= SPARTAN_ERR_CRC;
	}

	if(!err_code) { IOWR_ALTERA_AVALON_PIO_SET_BITS(led_base, led_pin); } else { IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(led_base, led_pin); }

	return err_code;
}



spartan_err simple_Spartan_Load(alt_flash_fd* flash, alt_u32 offset,alt_u32 length, alt_u32 spi_base, alt_u32 slave, alt_u32 io_base_prog_b, alt_u32 io_msk_prog_b, alt_u32 io_base_init_b, alt_u32 io_msk_init_b, alt_u32 io_base_done, alt_u32 io_msk_done, alt_u32 led_base, alt_u32 led_pin) {
	spartan_err err_code;

	alt_u32 toggle;
	alt_u32 n;
	alt_u32 chunk_size;

	// Toggle PROGRAM_B to reset device
	IOWR_ALTERA_AVALON_PIO_SET_BITS(io_base_prog_b, io_msk_prog_b);
	usleep(5000);
	IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(io_base_prog_b, io_msk_prog_b);
	usleep(5000);
	IOWR_ALTERA_AVALON_PIO_SET_BITS(io_base_prog_b, io_msk_prog_b);
	usleep(5000);

	err_code = SPARTAN_ERR_OK;

	toggle = 0;

	chunk_size = SPARTAN_LOAD_CHUNK_SIZE;
	for(n = 0; n < length; n += chunk_size) {
		// Reduce size of chunk to remaining length if necessary
		if(n + SPARTAN_LOAD_CHUNK_SIZE >= length) { chunk_size = length - n; }

		int flash_result = alt_read_flash(flash, offset + n, g_flash_data, chunk_size);
		int spi_result = alt_avalon_spi_command(spi_base, slave, chunk_size, g_flash_data, 0, 0, 0);
			//	printf("flash_result = %d spi_result = %d data = %x %x %x %x\n",flash_result,spi_result,g_flash_data[0],g_flash_data[1],g_flash_data[2],g_flash_data[3]);

		if(toggle < 50) {
			toggle++;
			IOWR_ALTERA_AVALON_PIO_SET_BITS(led_base, led_pin);
		} else if (toggle < 100) {
			toggle++;
			IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(led_base, led_pin);
		} else {
			toggle = 0;
		}
	}

	// Check Done Pin for success
	if(!(IORD_ALTERA_AVALON_PIO_DATA(io_base_done) & io_msk_done)) {
		err_code |= SPARTAN_ERR_CONF;
	}

	// Check INIT_B Pin for CRC error
	if(!(IORD_ALTERA_AVALON_PIO_DATA(io_base_init_b) & io_msk_init_b)) {
		err_code |= SPARTAN_ERR_CRC;
	}

	IOWR_ALTERA_AVALON_PIO_SET_BITS(led_base, led_pin);

	return err_code;
}
