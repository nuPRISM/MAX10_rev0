/*
 * Copyright (c) 2013, LINNUX
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * 	  this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * The views and conclusions contained in the software and documentation are those
 * of the authors and should not be interpreted as representing official policies,
 * either expressed or implied, of LINNUX.
 *
 * Author: Bryerton Shaw
 * Created: April 8, 2013
 * SVN: $id$
 */

#include <unistd.h>
#include <string.h>
#include <system.h>
#include <stdio.h>
#include <iostream>
#include <sys/alt_stdio.h>
#include <sys/alt_alarm.h>
#include <sys/alt_flash.h>
#include <altera_avalon_pio_regs.h>
#include <drivers/inc/i2c_opencores_regs.h>
#include <drivers/inc/i2c_opencores.h>
#include "board_management.h"
#include "linnux_utils.h"
extern "C" {
  #include "menu_control.h"

}
// Never have more than one of these FMC templates uncommented at a time.. if at all
//#include "fmc_templates/fmc_deap_nimio.h"
//#include "fmc_templates/fmc_deap_adc.h"
//#include "fmc_templates/fmc_deap_clkgen.h"
//#include "fmc_templates/fmc_loopback.h"


tBoard g_board;


// Use these to access the IPMI information
static alt_u8 FMC0_ReadByte(alt_u32 addr, alt_u8* checksum);
static alt_u8 FMC1_ReadByte(alt_u32 addr, alt_u8* checksum);
static alt_u8 FMC2_ReadByte(alt_u32 addr, alt_u8* checksum);
static void FMC0_WriteByte(alt_u32 addr, alt_u8 data, alt_u8* checksum);
static void FMC1_WriteByte( alt_u32 addr, alt_u8 data, alt_u8* checksum);
static void FMC2_WriteByte(alt_u32 addr, alt_u8 data, alt_u8* checksum);

static alt_u8 FMC0_ReadDoubleByte(alt_u32 addr, alt_u8* checksum);
static alt_u8 FMC1_ReadDoubleByte(alt_u32 addr, alt_u8* checksum);
static alt_u8 FMC2_ReadDoubleByte(alt_u32 addr, alt_u8* checksum);
static void FMC0_WriteDoubleByte(alt_u32 addr, alt_u8 data, alt_u8* checksum);
static void FMC1_WriteDoubleByte(alt_u32 addr, alt_u8 data, alt_u8* checksum);
static void FMC2_WriteDoubleByte(alt_u32 addr, alt_u8 data, alt_u8* checksum);

static char default_public_password[4] = {'\0','\0','\0','\0'}; //{'a','b','c','d'}; //
static char default_private_password[9] = {'\0','\0','\0','\0','\0','\0','\0','\0','\0'}; //{'a','b','c','d'}; //

#define CRC32_POLY 0x04c11db7   /* AUTODIN II, Ethernet, & FDDI */
alt_u32 crc32(alt_u8 *buf, alt_u32 len) {
	static alt_u32 crc32_table[256];
	alt_u32 i;
	alt_u32 j;
	alt_u32 c;
	alt_u8 *p;
	alt_u32 crc;

	if (!crc32_table[1]) {
		for (i = 0; i < 256; ++i) {
			for (c = i << 24, j = 8; j > 0; --j)  {
				c = c & 0x80000000 ? (c << 1) ^ CRC32_POLY : (c << 1);
			}
			crc32_table[i] = c;
		}
	}

	crc = 0xffffffff; /* preload shift register, per CRC-32 spec */

	for (p = buf; len > 0; ++p, --len) {
		crc = (crc << 8) ^ crc32_table[(crc >> 24) ^ *p];
	}

	return ~crc; /* transmit complement, per CRC-32 spec */
}

int board_management_main(int image_index = 0) {
    //std::cout << "Hello world" <<std::endl;
	InitDevices();
	InitFlash();

	alt_u32 spartan_image_offset;
	if (image_index) {
		printf("Using Fallback Spartan Image!\n");
		spartan_image_offset = OFFSET_FOR_SPARTAN_IMAGE_1;
	} else {
		printf("Using Normal Spartan Image!\n");
	    spartan_image_offset = 0;
	}

	InitFMC(spartan_image_offset); //test this
/*
	alt_flash_fd* flash_device = alt_flash_open_dev(BOARDMANAGEMENT_0_FLASH_SPARTAN_NAME);

	spartan_err err_code = simple_Spartan_Load(
			            flash_device,
						FLASH_OFFSET_FMC1,
						0x01FFFF0,
						BOARDMANAGEMENT_0_SPI_FMC_1_BASE,
						0,
						BOARDMANAGEMENT_0_GP_OUT_BASE, PIN_FMC0_CFG_PROGn << 1,
						BOARDMANAGEMENT_0_GP_IN_BASE, PIN_FMC0_CFG_INITn << 1,
						BOARDMANAGEMENT_0_GP_IN_BASE, PIN_FMC0_CFG_DONE << 1,
						BOARDMANAGEMENT_0_USER_LED_BASE, LED_FMC0 << 1);

	std::cout << "Loaded FMC1 with device " << std::hex << (unsigned) flash_device <<  std::dec << " and error: " <<  (unsigned) err_code << std::endl;
	std::cout.flush();
	*/
    ReadPins();
	ReadDevices();
	//menu_control();
	/*low_level_system_usleep(500000);
		//ZL9101M_WriteDoubleWord(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+0,  ZL9101M_CMD_PUBLIC_PASSWORD, 0);
		ZL9101M_WriteBlock(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+0,  ZL9101M_CMD_PUBLIC_PASSWORD, default_public_password, 4);

		char test_str[20] = "hello_world";
		ZL9101M_WriteBlock(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+0,  ZL9101M_CMD_USER_DATA_00, test_str, strlen(test_str));

	    //ZL9101M_SendByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+0, ZL9101M_CMD_RESTORE_USER_ALL);  // Security Level to 1
	    //ZL9101M_SendByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+0, ZL9101M_CMD_STORE_USER_ALL);  // Store Settings in User Flash
		low_level_system_usleep(500000);
*/
	printf("waiting for Xilinx to come online\n");
	low_level_system_usleep(5000000);
	printf("finished waiting for Xilinx to come online\n");
	return 0;
}

int clear_faults_in_regulator(int regulator_num) {
	if ((regulator_num >= NUM_FMC_CARDS) || (regulator_num < 0)) {
        printf("Error: Unable to clear faults in regulator %d since this number is out of range\n", regulator_num);
        return 0;
	}

	ZL9101M_SendByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+regulator_num, ZL9101M_CMD_CLEAR_FAULTS);
	return 1;

}


int get_security_level(int regulator_num) {
	if ((regulator_num >= NUM_FMC_CARDS) || (regulator_num < 0)) {
	        printf("Error: Unable to get security level from regulator %d since this number is out of range\n", regulator_num);
	        return -1;
		}
    int secbyte = ZL9101M_ReadByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+regulator_num, ZL9101M_CMD_SECURITY_LEVEL);
    printf("Security of regulator %d is level is %d\n",regulator_num,secbyte);
    return secbyte;
}

int clear_faults_in_main_board_regulator() {
	ZL9101M_SendByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_3V3, ZL9101M_CMD_CLEAR_FAULTS);
	return 1;

}

void InitDevices(void) {
	alt_u8 n;
	// Initialise I2C interfaces
	I2C_init(BOARDMANAGEMENT_0_FMC_I2C_BASE, BOARD_MANAGEMENT_CLOCK_FREQ, I2C_100_KHZ);
	//I2C_init(BOARDMANAGEMENT_0_PMBUS_BASE, ALT_CPU_CPU_FREQ, I2C_100_KHZ);
	I2C_init(BOARDMANAGEMENT_0_PMBUS_BASE, BOARD_MANAGEMENT_CLOCK_FREQ, BOARD_MGMT_I2C_SPEED_HZ); //reduce speed to help with communications reliability


    // *** RUN THIS CODE ONCE FOR NEW CARRIER BOARDS ***
    // *** POWER MUST BE CYCLED ON THE BOARD FOR THESE CHANGES TO TAKE EFFECT ***
/*IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(BOARDMANAGEMENT_0_GP_OUT_BASE, PIN_FMC0_VADJ_EN | PIN_FMC1_VADJ_EN | PIN_FMC2_VADJ_EN | PIN_FMC0_C2M_PG | PIN_FMC1_C2M_PG | PIN_FMC2_C2M_PG );
    //IOWR_ALTERA_AVALON_PIO_SET_BITS(BOARDMANAGEMENT_0_GP_OUT_BASE, PIN_FMC0_C2M_PG);
    for(n = 0; n < 1; ++n) {
        ZL9101M_WriteByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+n, ZL9101M_CMD_OPERATION, 0x84);
        ZL9101M_WriteByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+n, ZL9101M_CMD_ON_OFF_CONFIG, 0x14);  // Set Enable Pin to Active Low
        low_level_system_usleep(50000);
        ZL9101M_SendByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+n, ZL9101M_CMD_STORE_USER_ALL);  // Store Settings in User Flash
        int cmd_cfg_result;
        cmd_cfg_result = ZL9101M_ReadByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+n, ZL9101M_CMD_ON_OFF_CONFIG);
        printf( " n = %d, ZL9101M_CMD_ON_OFF_CONFIG = %d\n", n, cmd_cfg_result);
    }
*/
	// Disable VADJ
	IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(BOARDMANAGEMENT_0_GP_OUT_BASE, PIN_FMC0_C2M_PG | PIN_FMC1_C2M_PG | PIN_FMC2_C2M_PG );
	IOWR_ALTERA_AVALON_PIO_SET_BITS(BOARDMANAGEMENT_0_GP_OUT_BASE, PIN_FMC0_VADJ_EN | PIN_FMC1_VADJ_EN | PIN_FMC2_VADJ_EN); //comment out this line if programming a new board

	// Prepare Power Supplies
	for(n = 0; n < NUM_FMC_CARDS; ++n) {
		ZL9101M_SendByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+n, ZL9101M_CMD_CLEAR_FAULTS);
	}

	low_level_system_usleep(50000);

	ZL9101M_WriteWord(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+0,  ZL9101M_CMD_VOUT_COMMAND, V_CONV( 250 / 100.0f));
    ZL9101M_SendByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+0, ZL9101M_CMD_STORE_USER_ALL);  // Store Settings in User Flash
    low_level_system_usleep(50000);

	ZL9101M_WriteWord(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+1,  ZL9101M_CMD_VOUT_COMMAND, V_CONV( 330 / 100.0f));
	ZL9101M_SendByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+1, ZL9101M_CMD_STORE_USER_ALL);  // Store Settings in User Flash
	low_level_system_usleep(50000);

	ZL9101M_WriteWord(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+2,  ZL9101M_CMD_VOUT_COMMAND, V_CONV( 250 / 100.0f));
	ZL9101M_SendByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+2, ZL9101M_CMD_STORE_USER_ALL);  // Store Settings in User Flash
	low_level_system_usleep(50000);

	low_level_system_usleep(5000);

	// Disable PROGn
	IOWR_ALTERA_AVALON_PIO_SET_BITS(BOARDMANAGEMENT_0_GP_OUT_BASE, PIN_FMC0_CFG_PROGn | PIN_FMC1_CFG_PROGn | PIN_FMC2_CFG_PROGn );

	// Enable Power Supplies
	IOWR_ALTERA_AVALON_PIO_SET_BITS(BOARDMANAGEMENT_0_GP_OUT_BASE, PIN_FMC0_C2M_PG | PIN_FMC1_C2M_PG | PIN_FMC2_C2M_PG );
    IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(BOARDMANAGEMENT_0_GP_OUT_BASE, PIN_FMC0_VADJ_EN | PIN_FMC1_VADJ_EN | PIN_FMC2_VADJ_EN);
	// Turn off all LEDs to start
	IOWR_ALTERA_AVALON_PIO_DATA(BOARDMANAGEMENT_0_USER_LED_BASE, 0x00);
	////////////////////////////////////
	//// Temporary!!!
	low_level_system_usleep(500000);
	//ZL9101M_WriteDoubleWord(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+0,  ZL9101M_CMD_PUBLIC_PASSWORD, 0);
	//ZL9101M_WriteBlock(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+0,  ZL9101M_CMD_PUBLIC_PASSWORD, default_public_password, 4);
    //ZL9101M_SendByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+0, ZL9101M_CMD_RESTORE_USER_ALL);  // Security Level to 1
    //ZL9101M_SendByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+0, ZL9101M_CMD_STORE_USER_ALL);  // Store Settings in User Flash
	//ZL9101M_WriteBlock(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+0,  ZL9101M_CMD_PRIVATE_PASSWORD, default_private_password,9);
	//printf("After private password, seclevel is %d\n",get_security_level(0));
	//ZL9101M_SendByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+0, ZL9101M_CMD_CLEAR_FAULTS);
	//ZL9101M_SendByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+0,ZL9101M_CMD_RESTORE_USER_ALL);
    //	printf("After restore user all, seclevel is %d\n",get_security_level(0));
	//ZL9101M_WriteByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+n, ZL9101M_CMD_OPERATION, 0x84);
	//ZL9101M_WriteByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+n, ZL9101M_CMD_ON_OFF_CONFIG, 0x14);  // Set Enable Pin to Active Low
	usleep(50000);
	//ZL9101M_SendByte(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+n, ZL9101M_CMD_STORE_USER_ALL);  // Store Settings in User Flash
	//printf("After restore user all, seclevel is %d\n",get_security_level(0));
	//clear_faults_in_regulator(0);
	//printf("After clear all faults, seclevel is %d\n",get_security_level(0));

	low_level_system_usleep(500000);

	//
	////////////////////////////////////////////////////////
	// Perform Initial Read to Populate Settings
	ReadPins();
}

void InitFMC(alt_u32 spartan_image_offset = 0) {
	alt_u8 n;

	// Test FMC byte status
	if(g_board.fmc[0].present) {
		if(!FMC_EEPROM_IsMultiByte(BOARDMANAGEMENT_0_FMC_I2C_BASE, 0)) {
			g_board.fmc[0].ReadByte 	= FMC0_ReadByte;
			g_board.fmc[0].WriteByte 	= FMC0_WriteByte;
		} else {
			g_board.fmc[0].ReadByte 	= FMC0_ReadDoubleByte;
			g_board.fmc[0].WriteByte 	= FMC0_WriteDoubleByte;
		}
	}

	if(g_board.fmc[1].present) {
		if(!FMC_EEPROM_IsMultiByte(BOARDMANAGEMENT_0_FMC_I2C_BASE, 1)) {
			g_board.fmc[1].ReadByte 	= FMC1_ReadByte;
			g_board.fmc[1].WriteByte 	= FMC1_WriteByte;
		} else {
			g_board.fmc[1].ReadByte 	= FMC1_ReadDoubleByte;
			g_board.fmc[1].WriteByte 	= FMC1_WriteDoubleByte;
		}
	}

	if(g_board.fmc[2].present) {
		if(!FMC_EEPROM_IsMultiByte(BOARDMANAGEMENT_0_FMC_I2C_BASE, 2)) {
			g_board.fmc[2].ReadByte 	= FMC2_ReadByte;
			g_board.fmc[2].WriteByte 	= FMC2_WriteByte;
		} else {
			g_board.fmc[2].ReadByte 	= FMC2_ReadDoubleByte;
			g_board.fmc[2].WriteByte 	= FMC2_WriteDoubleByte;
		}
	}

	g_board.spartan[0].flash_idx = FLASH_IDX_SPARTAN;
	g_board.spartan[0].offset 	= FLASH_OFFSET_FMC0;
	g_board.spartan[0].spi_base = BOARDMANAGEMENT_0_SPI_FMC_0_BASE;

	g_board.spartan[1].flash_idx = FLASH_IDX_SPARTAN;
	g_board.spartan[1].offset 	= FLASH_OFFSET_FMC1;
	g_board.spartan[1].spi_base = BOARDMANAGEMENT_0_SPI_FMC_1_BASE;

	g_board.spartan[2].flash_idx = FLASH_IDX_SPARTAN;
	g_board.spartan[2].offset	= FLASH_OFFSET_FMC2;
	g_board.spartan[2].spi_base = BOARDMANAGEMENT_0_SPI_FMC_2_BASE;

	// Uncomment to write FMC info, DO NOT DO SO UNLESS YOU ARE ABSOLUTELY POSITIVE YOU UNDERSTAND THE CONSQUENCES
	//IPMI_WriteInfo(g_board.fmc[0].WriteByte, CreateFRUInfo(CreateFMCDeapNIMIO()));
	//IPMI_WriteInfo(g_board.fmc[1].WriteByte, CreateFRUInfo(CreateFMCDeapClkGen()));
	//IPMI_WriteInfo(g_board.fmc[2].WriteByte, CreateFRUInfo(CreateFMCDeapADC24()));
	spartan_err err_code;
	// Prep FMCs
	for(n=0; n < NUM_FMC_CARDS; ++n) {
		if(g_board.fmc[n].present) {
			// Read Board Info
			GetFMCInfo(g_board.fmc[n].ReadByte, &g_board.fmc[n].info, &g_board.fmc[n].fru_info);

			// Load Spartan Code
			if(Spartan_GetInfo(g_board.flash[g_board.spartan[n].flash_idx].device, g_board.spartan[n].offset, &g_board.spartan[n].info ) == SPARTAN_ERR_OK) {
				// Power on Spartan
                printf("Loading FMC %d\n",(int) n);
				/*
				ZL9101M_WriteWord(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+n,  ZL9101M_CMD_VOUT_COMMAND, V_CONV( g_board.fmc[n].info.p1_vadj.nominal_voltage / 100.0f));
				usleep(50000);
				IOWR_ALTERA_AVALON_PIO_SET_BITS(BOARDMANAGEMENT_0_GP_OUT_BASE, (PIN_FMC0_VADJ_EN << n) | (PIN_FMC0_C2M_PG << n) );
				usleep(5000000);

				// Turn on P2 VADJ as well if necessary, make sure there isn't a mistake (can't turn on n=3 card)
				if((g_board.fmc[n].info.base.module_size == IPMI_FMC_MODULE_SIZE_DOUBLE) && (n < NUM_FMC_CARDS)) {
					ZL9101M_WriteWord(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+(n+1),  ZL9101M_CMD_VOUT_COMMAND, V_CONV( g_board.fmc[n].info.p2_vadj.nominal_voltage / 100.0f));
					usleep(50000);
					IOWR_ALTERA_AVALON_PIO_SET_BITS(BOARDMANAGEMENT_0_GP_OUT_BASE, (PIN_FMC0_VADJ_EN << (n+1)) | (PIN_FMC0_C2M_PG << (n+1)) );
					usleep(5000000);

				}
*/

				// Configure Spartan
			//g_board.spartan[n].info.length=0x01FFFF0;
                err_code = 	Spartan_Load(
					g_board.flash[g_board.spartan[n].flash_idx].device,
					g_board.spartan[n].offset,
					&g_board.spartan[n].info,
					g_board.spartan[n].spi_base,
					0,
					BOARDMANAGEMENT_0_GP_OUT_BASE, PIN_FMC0_CFG_PROGn << n,
					BOARDMANAGEMENT_0_GP_IN_BASE, PIN_FMC0_CFG_INITn << n,
					BOARDMANAGEMENT_0_GP_IN_BASE, PIN_FMC0_CFG_DONE << n,
					BOARDMANAGEMENT_0_USER_LED_BASE, LED_FMC0 << n,
					spartan_image_offset);
                printf("Finished Loading FMC %d, error code  = %d\n", (int) n, (int) err_code);

			}
		}
	}

}

void InitFlash(void) {
	alt_u32 n;

	g_board.flash[FLASH_IDX_STRATIX].name = std::string(BOARDMANAGEMENT_0_FLASH_STRATIX_NAME);
	g_board.flash[FLASH_IDX_SPARTAN].name = std::string(BOARDMANAGEMENT_0_FLASH_SPARTAN_NAME);

	for(n = 0; n < NUM_FLASH_DEVICES; ++n) {
		g_board.flash[n].device = alt_flash_open_dev(g_board.flash[n].name.c_str());
		if(g_board.flash[n].device) {
			alt_get_flash_info(g_board.flash[n].device, &g_board.flash[n].regions, &g_board.flash[n].num_regions);
		} else {
			g_board.flash[n].regions = 0;
			g_board.flash[n].num_regions = 0;
		}
	}

	// Get the Option bits from the 'stratix' flash,
	if(g_board.flash[FLASH_IDX_STRATIX].device) {
		PFL_GetOptionBits(g_board.flash[FLASH_IDX_STRATIX].device, 0, &g_board.pfl);
	}
}

void ReadZL9101M(alt_u32 i2c_base, alt_u8 addr, tZL9101* pm) {
	pm->internal_temp 	= LITERAL_CONV(ZL9101M_ReadWord(i2c_base, addr,  ZL9101M_CMD_READ_TEMPERATURE_1));
	pm->i_out 			= LITERAL_CONV(ZL9101M_ReadWord(i2c_base, addr,  ZL9101M_CMD_READ_IOUT));
	pm->v_out 			= LINEAR_CONV_TO_FLOAT(ZL9101M_ReadWord(i2c_base, addr,  ZL9101M_CMD_READ_VOUT));
	pm->v_out_set 		= LINEAR_CONV_TO_FLOAT(ZL9101M_ReadWord(i2c_base, addr,  ZL9101M_CMD_VOUT_COMMAND));
	pm->v_in  			= LITERAL_CONV(ZL9101M_ReadWord(i2c_base, addr,  ZL9101M_CMD_READ_VIN));
	pm->status 			= ZL9101M_ReadWord(i2c_base, addr,  ZL9101M_CMD_STATUS_WORD);

	// Individual Status
	pm->stat_cml 	= ZL9101M_ReadByte(i2c_base, addr,  ZL9101M_CMD_STATUS_CML);
	pm->stat_vout 	= ZL9101M_ReadByte(i2c_base, addr,  ZL9101M_CMD_STATUS_VOUT);
	pm->stat_iout 	= ZL9101M_ReadByte(i2c_base, addr,  ZL9101M_CMD_STATUS_IOUT);
	pm->stat_input 	= ZL9101M_ReadByte(i2c_base, addr,  ZL9101M_CMD_STATUS_INPUT);
	pm->stat_temp 	= ZL9101M_ReadByte(i2c_base, addr,  ZL9101M_CMD_STATUS_TEMPERATURE);
	pm->stat_mfr 	= ZL9101M_ReadByte(i2c_base, addr,  ZL9101M_CMD_STATUS_MFR);
}

void ReadPins(void) {
	alt_u32 data;

	// Read Input pins
	data = IORD_ALTERA_AVALON_PIO_DATA(BOARDMANAGEMENT_0_GP_IN_BASE);
	if(data & PIN_FMC0_PRESENT) 	{ g_board.fmc[0].present = 0; } else { g_board.fmc[0].present = 1; }
	if(data & PIN_FMC1_PRESENT) 	{ g_board.fmc[1].present = 0; } else { g_board.fmc[1].present = 1; }
	if(data & PIN_FMC2_PRESENT)		{ g_board.fmc[2].present = 0; } else { g_board.fmc[2].present = 1; }

	if(data & PIN_PM_M2C0_PG) 		{ g_board.fmc[0].pwr_good = 0; } else { g_board.fmc[0].pwr_good = 1; }
	if(data & PIN_PM_M2C1_PG) 		{ g_board.fmc[1].pwr_good = 0; } else { g_board.fmc[1].pwr_good = 1; }
	if(data & PIN_PM_M2C2_PG)		{ g_board.fmc[2].pwr_good = 0; } else { g_board.fmc[2].pwr_good = 1; }

	if(data & PIN_PM_0V9_PG) 		{ g_board.pm.pg_0v9 = 1; } else { g_board.pm.pg_0v9 = 0; }
	if(data & PIN_PM_1V1_PG) 		{ g_board.pm.pg_1v1 = 1; } else { g_board.pm.pg_1v1 = 0; }
	if(data & PIN_PM_1V2_PG) 		{ g_board.pm.pg_1v2 = 1; } else { g_board.pm.pg_1v2 = 0; }
	if(data & PIN_PM_1V5_PG) 		{ g_board.pm.pg_1v5 = 1; } else { g_board.pm.pg_1v5 = 0; }
	if(data & PIN_PM_1V8_PG) 		{ g_board.pm.pg_1v8 = 1; } else { g_board.pm.pg_1v8 = 0; }
	if(data & PIN_PM_2V5_PG) 		{ g_board.pm.pg_2v5 = 1; } else { g_board.pm.pg_2v5 = 0; }
	if(data & PIN_PM_3V3_PG) 		{ g_board.pm.v_3v3.pwr_good = 1;    } else { g_board.pm.v_3v3.pwr_good = 0; }
	if(data & PIN_PM_VADJ0_PG) 		{ g_board.pm.v_adj[0].pwr_good = 1; } else { g_board.pm.v_adj[0].pwr_good = 0; }
	if(data & PIN_PM_VADJ1_PG) 		{ g_board.pm.v_adj[1].pwr_good = 1; } else { g_board.pm.v_adj[1].pwr_good = 0; }
	if(data & PIN_PM_VADJ2_PG) 		{ g_board.pm.v_adj[2].pwr_good = 1; } else { g_board.pm.v_adj[2].pwr_good = 0; }

	if(data & PIN_FMC0_CFG_DONE)	{ g_board.fmc[0].configured = 1; IOWR_ALTERA_AVALON_PIO_SET_BITS(BOARDMANAGEMENT_0_USER_LED_BASE, LED_FMC0); } else { g_board.fmc[0].configured = 0; IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(BOARDMANAGEMENT_0_USER_LED_BASE, LED_FMC0); }
	if(data & PIN_FMC1_CFG_DONE)	{ g_board.fmc[1].configured = 1; IOWR_ALTERA_AVALON_PIO_SET_BITS(BOARDMANAGEMENT_0_USER_LED_BASE, LED_FMC1); } else { g_board.fmc[1].configured = 0; IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(BOARDMANAGEMENT_0_USER_LED_BASE, LED_FMC1); }
	if(data & PIN_FMC2_CFG_DONE)	{ g_board.fmc[2].configured = 1; IOWR_ALTERA_AVALON_PIO_SET_BITS(BOARDMANAGEMENT_0_USER_LED_BASE, LED_FMC2); } else { g_board.fmc[2].configured = 0; IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(BOARDMANAGEMENT_0_USER_LED_BASE, LED_FMC2); }

	if(g_board.pm.v_adj[0].pwr_good) { IOWR_ALTERA_AVALON_PIO_SET_BITS(BOARDMANAGEMENT_0_GP_OUT_BASE, PIN_FMC0_C2M_PG); } else { IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(BOARDMANAGEMENT_0_GP_OUT_BASE, PIN_FMC0_C2M_PG); }
	if(g_board.pm.v_adj[1].pwr_good) { IOWR_ALTERA_AVALON_PIO_SET_BITS(BOARDMANAGEMENT_0_GP_OUT_BASE, PIN_FMC1_C2M_PG); } else { IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(BOARDMANAGEMENT_0_GP_OUT_BASE, PIN_FMC1_C2M_PG); }
	if(g_board.pm.v_adj[2].pwr_good) { IOWR_ALTERA_AVALON_PIO_SET_BITS(BOARDMANAGEMENT_0_GP_OUT_BASE, PIN_FMC2_C2M_PG); } else { IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(BOARDMANAGEMENT_0_GP_OUT_BASE, PIN_FMC2_C2M_PG); }

	// Read User DIP pins
	g_board.user_dip = IORD_ALTERA_AVALON_PIO_DATA(BOARDMANAGEMENT_0_USER_DIP_BASE);
}

void ReadDevices(void) {
	static alt_u8 init = 0;
	alt_u32 n;
	alt_16  temp;

	// Read Local Temp
	g_board.temp.board_temp = MIC280_ReadLocalTemp(BOARDMANAGEMENT_0_PMBUS_BASE, MIC280_ADDR_TA06);

	// Convert temperature to float
	temp = MIC280_ReadRemoteTemp(BOARDMANAGEMENT_0_PMBUS_BASE, MIC280_ADDR_TA06); // Just get temp in celsius for nows
	g_board.temp.strat_temp = (temp >> 8) + (temp & 0x00FF) * 0.0625f;

	// Read Power Supply Values for 3v3, and VADJ's
	for(n = 0; n < NUM_FMC_CARDS; ++n) {
		ReadZL9101M(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+n, &g_board.pm.v_adj[n]);
		if(!init) {
			ZL9101M_ReadBlock(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_FMC+n, ZL9101M_CMD_DEVICE_ID, g_board.pm.v_adj[n].device_id, 16);
		}
	}

	if(!init) {
		ZL9101M_ReadBlock(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_3V3, ZL9101M_CMD_DEVICE_ID, g_board.pm.v_3v3.device_id, 16);
		init = 1;
	}


	ReadZL9101M(BOARDMANAGEMENT_0_PMBUS_BASE, ZL9101M_I2C_ADDR_3V3, &g_board.pm.v_3v3);
}



static alt_u8 FMC0_ReadByte(alt_u32 addr, alt_u8* checksum) { return FMC_EEPROM_ReadByte(BOARDMANAGEMENT_0_FMC_I2C_BASE, 0, 0, addr, checksum); }
static alt_u8 FMC1_ReadByte(alt_u32 addr, alt_u8* checksum) { return FMC_EEPROM_ReadByte(BOARDMANAGEMENT_0_FMC_I2C_BASE, 1, 0, addr, checksum); }
static alt_u8 FMC2_ReadByte(alt_u32 addr, alt_u8* checksum) { return FMC_EEPROM_ReadByte(BOARDMANAGEMENT_0_FMC_I2C_BASE, 2, 0, addr, checksum); }
static void FMC0_WriteByte(alt_u32 addr, alt_u8 data, alt_u8* checksum) { FMC_EEPROM_WriteByte(BOARDMANAGEMENT_0_FMC_I2C_BASE, 0, 0, addr, data, checksum); }
static void FMC1_WriteByte(alt_u32 addr, alt_u8 data, alt_u8* checksum) { FMC_EEPROM_WriteByte(BOARDMANAGEMENT_0_FMC_I2C_BASE, 1, 0, addr, data, checksum); }
static void FMC2_WriteByte(alt_u32 addr, alt_u8 data, alt_u8* checksum) { FMC_EEPROM_WriteByte(BOARDMANAGEMENT_0_FMC_I2C_BASE, 2, 0, addr, data, checksum); }

static alt_u8 FMC0_ReadDoubleByte(alt_u32 addr, alt_u8* checksum) { return FMC_EEPROM_ReadByte(BOARDMANAGEMENT_0_FMC_I2C_BASE, 0, 1, addr, checksum); }
static alt_u8 FMC1_ReadDoubleByte(alt_u32 addr, alt_u8* checksum) { return FMC_EEPROM_ReadByte(BOARDMANAGEMENT_0_FMC_I2C_BASE, 1, 1, addr, checksum); }
static alt_u8 FMC2_ReadDoubleByte(alt_u32 addr, alt_u8* checksum) { return FMC_EEPROM_ReadByte(BOARDMANAGEMENT_0_FMC_I2C_BASE, 2, 1, addr, checksum); }
static void FMC0_WriteDoubleByte(alt_u32 addr, alt_u8 data, alt_u8* checksum) { FMC_EEPROM_WriteByte(BOARDMANAGEMENT_0_FMC_I2C_BASE, 0, 1, addr, data, checksum); }
static void FMC1_WriteDoubleByte(alt_u32 addr, alt_u8 data, alt_u8* checksum) { FMC_EEPROM_WriteByte(BOARDMANAGEMENT_0_FMC_I2C_BASE, 1, 1, addr, data, checksum); }
static void FMC2_WriteDoubleByte(alt_u32 addr, alt_u8 data, alt_u8* checksum) { FMC_EEPROM_WriteByte(BOARDMANAGEMENT_0_FMC_I2C_BASE, 2, 1, addr, data, checksum); }

