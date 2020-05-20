/*
 * terasic_linnux_driver_c.h
 *
 *  Created on: Apr 19, 2011
 *      Author: linnyair
 */

#ifndef TERASIC_LINNUX_DRIVER_C_H_
#define TERASIC_LINNUX_DRIVER_C_H_
#include <system.h>
#include <alt_types.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(__STDC__) || defined(__cplusplus)
	/* ANSI C prototypes */
	extern char* read_from_sd_card_into_c_string(const char*);
	extern char* read_from_sd_card_into_c_string_for_jim(const char*);
	extern int SD_card_init_for_diskio(void);
	extern int SD_read_block_for_diskio(unsigned long  block_number, alt_u8 *buff);
	extern int SD_write_block_for_diskio(unsigned long block_number, const alt_u8 *buff);


#else
	/* K&R style */
	extern char* read_from_sd_card_into_c_string();
	extern char* read_from_sd_card_into_c_string_for_jim();
	extern int SD_card_init_for_diskio();
	extern int SD_read_block_for_diskio(alt_u32 block_number, alt_u8 *buff);
   extern int SD_write_block_for_diskio(alt_u32 block_number, const alt_u8 *buff);


#endif

#ifdef __cplusplus
}
#endif


#endif /* TERASIC_LINNUX_DRIVER_C_H_ */
