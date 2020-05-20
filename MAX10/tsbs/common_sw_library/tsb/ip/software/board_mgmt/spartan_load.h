/*
 * spartan_load.h
 *
 *  Created on: 2013-05-21
 *      Author: bryerton
 */

#ifndef SPARTAN_LOAD_H_
#define SPARTAN_LOAD_H_

#include <alt_types.h>
#include <sys/alt_flash.h>

#define SPARTAN_ERR_OK		0
#define SPARTAN_ERR_UNKNOWN	1
#define SPARTAN_ERR_CONF	2
#define SPARTAN_ERR_CRC		4

#include <string>
#include <iostream>
#include <sstream>
#include "basedef.h"
#include "jansson.hpp"
#include "json_serializer_class.h"

#include <string>
typedef alt_u8 spartan_err;

class tSpartanInfo : public json_serializer_class {

public:
	char* 	filename;
	char* 	partname;
	//std::string 	filename;
	//std::string 	partname;
	alt_u32 board_id;
	alt_u32 datetime;
	alt_u32 length;
	json::Value get_json_object();
	tSpartanInfo() {
		filename = NULL;
		partname = NULL;
		length = 0;
		datetime = 0;
		board_id = 0;
	}
};

/**
 * Get Spartan Code Information. Includes Filename, Part Number, Datetime, and length of file.
 * @param flash Flash device to read data from
 * @param offset Offset from start of flash device
 * @param info Pointer to allocated struct to fill with flash data
 */
spartan_err Spartan_GetInfo(alt_flash_fd* flash, alt_u32 offset, tSpartanInfo* info);

/**
 * Loads Spartan Code into Xilinx Spartan.
 * @param flash Flash device to read data from
 * @param offset Offset from start of flash device
 * @param spi_base NIOSII SPI address base to use to communicate
 * @param info
 */
spartan_err Spartan_Load(alt_flash_fd* flash, alt_u32 offset, tSpartanInfo* info, alt_u32 spi_base,  alt_u32 slave, alt_u32 io_base_prog_b, alt_u32 io_msk_prog_b, alt_u32 io_base_init_b, alt_u32 io_msk_init_b, alt_u32 io_base_done, alt_u32 io_msk_done, alt_u32 led_base, alt_u32 led_pin, alt_u32 spartan_image_offset);

spartan_err simple_Spartan_Load(alt_flash_fd* flash, alt_u32 offset,alt_u32 length, alt_u32 spi_base, alt_u32 slave, alt_u32 io_base_prog_b, alt_u32 io_msk_prog_b, alt_u32 io_base_init_b, alt_u32 io_msk_init_b, alt_u32 io_base_done, alt_u32 io_msk_done, alt_u32 led_base, alt_u32 led_pin);

#endif /* SPARTAN_LOAD_H_ */
