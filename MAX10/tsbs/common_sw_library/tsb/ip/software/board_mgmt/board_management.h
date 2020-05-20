/*
 * boardmanagement.h
 *
 *  Created on: 2013-04-17
 *      Author: bryerton
 */

#ifndef BOARDMANAGEMENT_H_
#define BOARDMANAGEMENT_H_

extern "C" {
#include <alt_types.h>
#include "drivers/fmc_eeprom.h"
#include "drivers/pmbus.h"
}

#include "basedef.h"
#include "api/ipmi/ipmi.h"
#include "drivers/mic280.h"
#include "fmc.h"
#include "spartan_load.h"
#include "drivers/pfl.h"
#include "drivers/zl9101m.h"

#include <string>
#include <iostream>
#include <sstream>

#include "jansson.hpp"
#include "json_serializer_class.h"

// Input Pins
#define PIN_FMC0_CFG_DONE		0x00000001
#define PIN_FMC1_CFG_DONE		0x00000002
#define PIN_FMC2_CFG_DONE		0x00000004
#define PIN_FMC0_CFG_INITn		0x00000008
#define PIN_FMC1_CFG_INITn		0x00000010
#define PIN_FMC2_CFG_INITn		0x00000020
#define PIN_FMC0_PRESENT		0x00000040
#define PIN_FMC1_PRESENT		0x00000080
#define PIN_FMC2_PRESENT		0x00000100
#define PIN_PM_M2C0_PG			0x00000200
#define PIN_PM_M2C1_PG			0x00000400
#define PIN_PM_M2C2_PG			0x00000800
#define PIN_PM_VADJ0_PG			0x00001000
#define PIN_PM_VADJ1_PG			0x00002000
#define PIN_PM_VADJ2_PG			0x00004000
#define PIN_PM_0V9_PG			0x00008000
#define PIN_PM_1V1_PG			0x00010000
#define PIN_PM_1V2_PG			0x00020000
#define PIN_PM_1V5_PG			0x00040000
#define PIN_PM_1V8_PG			0x00080000
#define PIN_PM_2V5_PG			0x00100000
#define PIN_PM_3V3_PG			0x00200000


// Output Pins
#define PIN_FMC0_VADJ_EN		0x0001
#define PIN_FMC1_VADJ_EN		0x0002
#define PIN_FMC2_VADJ_EN		0x0004
#define PIN_FMC0_C2M_PG			0x0008
#define PIN_FMC1_C2M_PG			0x0010
#define PIN_FMC2_C2M_PG			0x0020
#define PIN_FMC0_CFG_PROGn		0x0040
#define PIN_FMC1_CFG_PROGn		0x0080
#define PIN_FMC2_CFG_PROGn		0x0100

// General Board Definitions
#define NUM_FMC_CARDS 			3
#define NUM_SPARTANS			3
#define NUM_FLASH_DEVICES 		2

#define LED_FMC0				0x01
#define LED_FMC1				0x02
#define LED_FMC2				0x04
#define LED_ACTIVITY			0x08

#define FLASH_IDX_STRATIX		0
#define FLASH_IDX_SPARTAN		1

#define FLASH_OFFSET_FMC0		0x00000000
#define FLASH_OFFSET_FMC1		0x00200000
#define FLASH_OFFSET_FMC2		0x00400000

#define OFFSET_FOR_SPARTAN_IMAGE_1		0x00600000

#define ZL9101M_I2C_ADDR_FMC	0x20 // 0x20 + n, where n = [0,2] for the 3 FMC Power supplies
#define ZL9101M_I2C_ADDR_3V3	0x31

#define DEFAULT_SPARTAN_FLASH_IMAGE_LENGTH (0x01FFFF0)
class tPM : public json_serializer_class {

public:
	alt_u8 pg_2v5;
	alt_u8 pg_1v8;
	alt_u8 pg_1v5;
	alt_u8 pg_1v2;
	alt_u8 pg_1v1;
	alt_u8 pg_0v9;
	tZL9101 v_adj[NUM_FMC_CARDS];
	tZL9101 v_3v3;
	json::Value get_json_object();
};

//void tPM_print(tPM* p, char* outstr);
//int tPM_print(tPM* p, char* outstr) {
//	int num_chars = 0;
//	num_chars += xsprintf(outstr,"pg_2v5=%x pg_1v8=%x pg_1v5=%x pg_1v2=%x pg_1v1=%x pg_0v9=%x",p->pg_2v5,p->pg_1v8,p->pg_1v5,p->pg_1v2,p->pg_1v1,p->pg_0v9);
//
//}

class tFlash : public json_serializer_class {

public:
	alt_flash_fd* 	device;
	flash_region* 	regions;
	int 			num_regions;
	std::string			name;
	//char*			name;
	json::Value get_json_object();
    tFlash () {
    	name = "";
    	regions = NULL;
    	device = NULL;
    	num_regions = 0;
    }
};

//void tFlash_print(tFlash* p, char* outstr);

class tSpartan : public json_serializer_class {

public:
	alt_u32		 flash_idx; // Which flash Device to use
	alt_u32		 offset; 	// Offset in flash Device
	alt_u32		 spi_base;	// Which SPI to use
	tSpartanInfo info;
	json::Value get_json_object();
};

//void tSpartan_print(tSpartan* p, char* outstr);

class tTemp : public json_serializer_class {

public:
	float board_temp; // Board (MIC280) temperature
	float strat_temp; // Stratix Temperature
	json::Value get_json_object();
} ;

//void tBoard_print(tTemp* p, char* outstr);

// Board Management Struct
class  tBoard : public json_serializer_class {

public:
	tSpartan	spartan[NUM_SPARTANS];
	tFlash 		flash[NUM_FLASH_DEVICES];
	tFMC 		fmc[NUM_FMC_CARDS];
	tPFL 		pfl;
	tPM	 		pm;
	tTemp		temp;
	alt_u32		user_dip;
	json::Value get_json_object();
} ;

void ReadPins(void);
void ReadDevices(void);
extern tBoard g_board;
int board_management_main(int);

void InitDevices(void);
void InitFlash(void);
void InitFMC(alt_u32);
void InitVME(void);

void ReadPins(void);
void ReadDevices(void);
void UpdateRegisters(void);

void VME_ProcessMessages(void);

void VMP_WriteVar(alt_u32 msg_info, alt_u32 msg_len);
void VMP_WriteStratix(alt_u32 msg_info, alt_u32 msg_len);
void VMP_WriteFMC(alt_u32 msg_info, alt_u32 msg_len);
void VMP_WriteNIOS(alt_u32 msg_info, alt_u32 msg_len);

void VMP_ReadVar(alt_u32 msg_info, alt_u32 msg_len);
void VMP_ReadStratix(alt_u32 msg_info, alt_u32 msg_len);
void VMP_ReadFMC(alt_u32 msg_info, alt_u32 msg_len);
void VMP_ReadNIOS(alt_u32 msg_info, alt_u32 msg_len);

void VMP_ReloadSpartan(alt_u32 msg_info, alt_u32 msg_len);
int clear_faults_in_regulator(int regulator_num);
int clear_faults_in_main_board_regulator();

extern tBoard g_board;
#endif /* BOARDMANAGEMENT_H_ */
