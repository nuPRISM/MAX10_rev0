// --------------------------------------------------------------------
// Copyright (c) 2007 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------

#ifndef SD_CARD_DRIVER_H_
#define SD_CARD_DRIVER_H_

#include "../terasic_lib/terasic_includes.h"
#include "alt_types.h"  // alt_u32
#include "io.h"
#include "basedef.h"
#include <time.h>

//#define xSD_4BIT_MODE

#ifdef USE_SD_1BIT_MODE
#ifdef USE_DE2115_TYPE_SD_CONTROL
		// direction control
extern int sd_test_command();
extern int sd_test_data();
		#define SD_CMD_IN  do {IOWR_ALTERA_AVALON_PIO_DIRECTION(SD_CMD_BASE,ALTERA_AVALON_PIO_DIRECTION_INPUT);  IOWR_ALTERA_AVALON_PIO_DIRECTION(SD_CMD_BASE,ALTERA_AVALON_PIO_DIRECTION_INPUT); IOWR_ALTERA_AVALON_PIO_DIRECTION(SD_CMD_BASE,ALTERA_AVALON_PIO_DIRECTION_INPUT);      sd_card_sleep_for_fast_nios; } while(0)
		#define SD_CMD_OUT do { IOWR_ALTERA_AVALON_PIO_DIRECTION(SD_CMD_BASE,ALTERA_AVALON_PIO_DIRECTION_OUTPUT);  IOWR_ALTERA_AVALON_PIO_DIRECTION(SD_CMD_BASE,ALTERA_AVALON_PIO_DIRECTION_OUTPUT);  IOWR_ALTERA_AVALON_PIO_DIRECTION(SD_CMD_BASE,ALTERA_AVALON_PIO_DIRECTION_OUTPUT);  sd_card_sleep_for_fast_nios; } while(0)
		#define SD_DAT_IN  do { IOWR_ALTERA_AVALON_PIO_DIRECTION(SD_DAT_BASE,ALTERA_AVALON_PIO_DIRECTION_INPUT);  IOWR_ALTERA_AVALON_PIO_DIRECTION(SD_DAT_BASE,ALTERA_AVALON_PIO_DIRECTION_INPUT); IOWR_ALTERA_AVALON_PIO_DIRECTION(SD_DAT_BASE,ALTERA_AVALON_PIO_DIRECTION_INPUT);    sd_card_sleep_for_fast_nios; } while(0)
		#define SD_DAT_OUT do { IOWR_ALTERA_AVALON_PIO_DIRECTION(SD_DAT_BASE,ALTERA_AVALON_PIO_DIRECTION_OUTPUT); IOWR_ALTERA_AVALON_PIO_DIRECTION(SD_DAT_BASE,ALTERA_AVALON_PIO_DIRECTION_OUTPUT);  IOWR_ALTERA_AVALON_PIO_DIRECTION(SD_DAT_BASE,ALTERA_AVALON_PIO_DIRECTION_OUTPUT);  sd_card_sleep_for_fast_nios; } while(0)
		//  SD Card Output High/Low
		#define SD_CMD_LOW  do { IOWR_ALTERA_AVALON_PIO_DATA(SD_CMD_BASE, 0);  IOWR_ALTERA_AVALON_PIO_DATA(SD_CMD_BASE, 0); IOWR_ALTERA_AVALON_PIO_DATA(SD_CMD_BASE, 0);   sd_card_sleep_for_fast_nios; } while (0)
		#define SD_CMD_HIGH do { IOWR_ALTERA_AVALON_PIO_DATA(SD_CMD_BASE, 1);   IOWR_ALTERA_AVALON_PIO_DATA(SD_CMD_BASE, 1); IOWR_ALTERA_AVALON_PIO_DATA(SD_CMD_BASE, 1); sd_card_sleep_for_fast_nios; } while (0)
		#define SD_CLK_LOW  do { IOWR_ALTERA_AVALON_PIO_DATA(SD_CLK_BASE, 0); IOWR_ALTERA_AVALON_PIO_DATA(SD_CLK_BASE, 0); IOWR_ALTERA_AVALON_PIO_DATA(SD_CLK_BASE, 0);      sd_card_sleep_for_fast_nios; } while (0)
		#define SD_CLK_HIGH do { IOWR_ALTERA_AVALON_PIO_DATA(SD_CLK_BASE, 1);  IOWR_ALTERA_AVALON_PIO_DATA(SD_CLK_BASE, 1); IOWR_ALTERA_AVALON_PIO_DATA(SD_CLK_BASE, 1);     sd_card_sleep_for_fast_nios; } while (0)
		#define SD_DAT_LOW  do { IOWR_ALTERA_AVALON_PIO_DATA(SD_DAT_BASE, 8);  IOWR_ALTERA_AVALON_PIO_DATA(SD_DAT_BASE, 8); IOWR_ALTERA_AVALON_PIO_DATA(SD_DAT_BASE, 8); sd_card_sleep_for_fast_nios; } while (0)
		#define SD_DAT_HIGH do { IOWR_ALTERA_AVALON_PIO_DATA(SD_DAT_BASE, 9); IOWR_ALTERA_AVALON_PIO_DATA(SD_DAT_BASE, 9);  IOWR_ALTERA_AVALON_PIO_DATA(SD_DAT_BASE, 9);  sd_card_sleep_for_fast_nios; } while (0)
		//#define SD_DAT_WRITE(data4) IOWR_ALTERA_AVALON_PIO_DATA(SD_DAT_BASE, data4); IOWR_ALTERA_AVALON_PIO_DATA(SD_DAT_VAL_BASE, data4)
		//  SD Card Input Read
		//#define SD_TEST_CMD do {SD_CMD_IN; IORD_ALTERA_AVALON_PIO_DATA(SD_CMD_BASE); } while (0)
		//#define SD_TEST_DAT do {SD_DAT_IN; IORD_ALTERA_AVALON_PIO_DATA(SD_DAT_BASE); } while (0)

		#define SD_TEST_CMD sd_test_command()
		#define SD_TEST_DAT sd_test_data()
#else
		// direction control
		#define SD_CMD_IN  do { IOWR_ALTERA_AVALON_PIO_DATA(SD_CMD_OE_BASE, 0); sd_card_sleep_for_fast_nios; } while(0)
		#define SD_CMD_OUT do { IOWR_ALTERA_AVALON_PIO_DATA(SD_CMD_OE_BASE, 1); sd_card_sleep_for_fast_nios; } while(0)
		#define SD_DAT_IN  do { IOWR_ALTERA_AVALON_PIO_DATA(SD_DAT_OE_BASE, 0); sd_card_sleep_for_fast_nios; } while(0)
		#define SD_DAT_OUT do { IOWR_ALTERA_AVALON_PIO_DATA(SD_DAT_OE_BASE, 1); sd_card_sleep_for_fast_nios; } while(0)
		//  SD Card Output High/Low
		#define SD_CMD_LOW  do { IOWR_ALTERA_AVALON_PIO_DATA(SD_CMD_VAL_BASE, 0);   sd_card_sleep_for_fast_nios; } while (0)
		#define SD_CMD_HIGH do { IOWR_ALTERA_AVALON_PIO_DATA(SD_CMD_VAL_BASE, 1);   sd_card_sleep_for_fast_nios; } while (0)
		#define SD_CLK_LOW  do { IOWR_ALTERA_AVALON_PIO_DATA(SD_CLK_BASE, 0);       sd_card_sleep_for_fast_nios; } while (0)
		#define SD_CLK_HIGH do { IOWR_ALTERA_AVALON_PIO_DATA(SD_CLK_BASE, 1);       sd_card_sleep_for_fast_nios; } while (0)
		#define SD_DAT_LOW  do { IOWR_ALTERA_AVALON_PIO_DATA(SD_DAT_VAL_BASE, 0);   sd_card_sleep_for_fast_nios; } while (0)
		#define SD_DAT_HIGH do { IOWR_ALTERA_AVALON_PIO_DATA(SD_DAT_VAL_BASE, 1);   sd_card_sleep_for_fast_nios; } while (0)
		//#define SD_DAT_WRITE(data4) IOWR_ALTERA_AVALON_PIO_DATA(SD_DAT_BASE, data4); IOWR_ALTERA_AVALON_PIO_DATA(SD_DAT_VAL_BASE, data4)
		//  SD Card Input Read
		#define SD_TEST_CMD  IORD_ALTERA_AVALON_PIO_DATA(SD_CMD_INPORT_BASE)
		#define SD_TEST_DAT  IORD_ALTERA_AVALON_PIO_DATA(SD_DAT_INPORT_BASE)
#endif
#else

        //dummy definitions to allow for compilation

        #define SD_CMD_IN  do { sd_card_sleep_for_fast_nios; } while(0)
		#define SD_CMD_OUT do { sd_card_sleep_for_fast_nios; } while(0)
		#define SD_DAT_IN  do { sd_card_sleep_for_fast_nios; } while(0)
		#define SD_DAT_OUT do { sd_card_sleep_for_fast_nios; } while(0)
		//  SD Card Output High/Low
		#define SD_CMD_LOW  do { sd_card_sleep_for_fast_nios; } while (0)
		#define SD_CMD_HIGH do { sd_card_sleep_for_fast_nios; } while (0)
		#define SD_CLK_LOW  do { sd_card_sleep_for_fast_nios; } while (0)
		#define SD_CLK_HIGH do { sd_card_sleep_for_fast_nios; } while (0)
		#define SD_DAT_LOW  do { sd_card_sleep_for_fast_nios; } while (0)
		#define SD_DAT_HIGH do { sd_card_sleep_for_fast_nios; } while (0)
		//#define SD_DAT_WRITE(data4) IOWR_ALTERA_AVALON_PIO_DATA(SD_DAT_BASE, data4); IOWR_ALTERA_AVALON_PIO_DATA(SD_DAT_VAL_BASE, data4)
		//  SD Card Input Read
		#define SD_TEST_CMD 0
		#define SD_TEST_DAT 0

#endif

terasic_bool SD_card_init(void);
terasic_bool SD_read_block(alt_u32 block_number, alt_u8 *buff); // richard add, return 0: success
terasic_bool SD_GetCSD(alt_u8 szCSD[], alt_u8 len);
terasic_bool SD_GetCID(alt_u8 szCID[], alt_u8 len);




#endif /*SD_CARD_DRIVER_H_*/
