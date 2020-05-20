/*
 * fmc.h
 *
 *  Created on: 2013-05-16
 *      Author: bryerton
 */

#ifndef FMC_H_
#define FMC_H_

#include <alt_types.h>

#include "api/ipmi/ipmi.h"
#include <string>
#include <iostream>
#include <sstream>
#include "basedef.h"

#include "jansson.hpp"
#include "json_serializer_class.h"

#define MAX_IPMI_STRING_LENGTH 100
#define BOARDMANAGEMENT_0_IPMI_RECORD_TYPE_FMC_BASE		0xFA

#define IPMI_FMC_MODULE_SIZE_SINGLE		0x00
#define IPMI_FMC_MODULE_SIZE_DOUBLE		0x01

#define IPMI_FMC_CONN_SIZE_LPC			0x00	// 160 pin
#define IPMI_FMC_CONN_SIZE_HPC			0x01	// 400 pin (3xVME)
#define IPMI_FMC_CONN_SIZE_NONE			0x03	// For use with P2

class tIPMI_FMC_BASE  : public json_serializer_class {

public:

	alt_u8 subtype 		: 4; 	// 0 for main def. type
	alt_u8 version 		: 4; 	// 0 for current version
	alt_u8 module_size 	: 2; 	// 0b00 single width, 0b01 - double width
	alt_u8 p1_conn_size : 2; 	// 0b00 = LPC, 0b01 = HPC
	alt_u8 p2_conn_size : 2; 	// 0b00 = LPC, 0b01 = HPC, 0b11 = not fitted
	alt_u8 reserved		: 2; 	// 0b00
	alt_u8 p1_bank_a_num_sig;	// Number needed
	alt_u8 p1_bank_b_num_sig;	// Number needed
	alt_u8 p2_bank_a_num_sig;	// Number needed
	alt_u8 p2_bank_b_num_sig;	// Number needed
	alt_u8 p1_gbt_num_sig : 4;	// Number needed
	alt_u8 p2_gbt_num_sig : 4;	// Number needed
	alt_u8 max_clock_for_tck;	// clock in MHz
    json::Value get_json_object();
} ;

class tFMCInfo  : public json_serializer_class {

public:
	tIPMI_FMC_BASE	base; // Required - FMC Base Definition
	tIPMI_BIA board_info; // Required - Board Info Area

	// Arranged in 'output' order from 0 - 12
	tIPMI_DC_LOAD p1_vadj;
	tIPMI_DC_LOAD p1_3p3v;
	tIPMI_DC_LOAD p1_12p0v;
	tIPMI_DC_OUTPUT p1_vio_b_m2c; // P1 -  VADJ(0), 3P3V(1), 12P0V(2), P2 - VADJ(6), 3P3V(7), 12P0V(8)
	tIPMI_DC_OUTPUT p1_vref_a_m2c;
	tIPMI_DC_OUTPUT p1_vref_b_m2c;

	tIPMI_DC_LOAD p2_vadj;
	tIPMI_DC_LOAD p2_3p3v;
	tIPMI_DC_LOAD p2_12p0v;
	tIPMI_DC_OUTPUT p2_vio_b_m2c;
	tIPMI_DC_OUTPUT p2_vref_a_m2c;
	tIPMI_DC_OUTPUT p2_vref_b_m2c;
	json::Value get_json_object();
};

class tFMC  : public json_serializer_class {

public:
	alt_u8 present;	// FMC Present?
	alt_u8 pwr_good;		// Power Good?
	alt_u8 configured;
	alt_u16 vadj;
	pfnReadByte ReadByte;
	pfnWriteByte WriteByte;
	tFMCInfo info; // FMC specific FRU info (mapped to FRU memory)
	tIPMI_FRU_INFO fru_info; // Memory containing all of the found FRU information
	json::Value get_json_object();
};

void GetFMCInfo(pfnReadByte ReadByte, tFMCInfo* fmc_info, tIPMI_FRU_INFO* fru_info);
tIPMI_FRU_INFO* CreateFRUInfo(tFMCInfo* fmc_info);

#endif /* FMC_H_ */
