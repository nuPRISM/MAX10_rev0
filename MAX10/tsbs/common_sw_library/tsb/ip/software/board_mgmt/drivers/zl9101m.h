/*
 * $Id$
 *
 *  Created on: Setp 17, 2012
 *  Created by: Chris Ohlmann
 */

/**
 *  ZL9101M Digital DC/DC PMBus 12A Power Module
 *
 */

#ifndef ZL9101M_H_
#define ZL9101M_H_

#include <alt_types.h>

#define ZL9101M_ERR_I2C_READ 0
#define ZL9101M_ERR_DATA_INVALID 1

#include <string>
#include <iostream>
#include <sstream>

#include "basedef.h"
#include "jansson.hpp"
#include "json_serializer_class.h"

/* PMBUS Commands (ie.Register Addresses) */
#define ZL9101M_CMD_OPERATION				0x01
#define ZL9101M_CMD_ON_OFF_CONFIG			0x02
#define ZL9101M_CMD_CLEAR_FAULTS			0x03
#define ZL9101M_CMD_STORE_DEFAULTS_ALL		0x11
#define ZL9101M_CMD_RESTORE_DEFAULTS_ALL	0x12
#define ZL9101M_CMD_STORE_USER_ALL			0x15
#define ZL9101M_CMD_RESTORE_USER_ALL		0x16
#define ZL9101M_CMD_VOUT_MODE				0x20
#define ZL9101M_CMD_VOUT_COMMAND			0x21
#define ZL9101M_CMD_VOUT_TRIM				0x22
#define ZL9101M_CMD_VOUT_CAL_OFFSET			0x23
#define ZL9101M_CMD_VOUT_MAX				0x24
#define ZL9101M_CMD_VOUT_MARGIN_HIGH		0x25
#define ZL9101M_CMD_VOUT_MARGIN_LOW			0x26
#define ZL9101M_CMD_VOUT_TRANSITION_RATE	0x27
#define ZL9101M_CMD_VOUT_DROOP				0x28
#define ZL9101M_CMD_MAX_DUTY				0x32
#define ZL9101M_CMD_FREQUENCY_SWITCH		0x33
#define ZL9101M_CMD_INTERLEAVE				0x37
#define ZL9101M_CMD_IOUT_CAL_GAIN			0x38
#define ZL9101M_CMD_IOUT_CAL_OFFSET			0x39
#define ZL9101M_CMD_VOUT_OV_FAULT_LIMIT		0x40
#define ZL9101M_CMD_VOUT_OV_FAULT_RESPONSE	0x41
#define ZL9101M_CMD_VOUT_UV_FAULT_LIMIT		0x44
#define ZL9101M_CMD_VOUT_UV_FAULT_RESPONSE	0x45
#define ZL9101M_CMD_IOUT_OC_FAULT_LIMIT		0x46
#define ZL9101M_CMD_IOUT_UC_FAULT_LIMIT		0x4B
#define ZL9101M_CMD_OT_FAULT_LIMIT			0x4F
#define ZL9101M_CMD_OT_FAULT_RESPONSE		0x50
#define ZL9101M_CMD_OT_WARN_LIMIT			0x51
#define ZL9101M_CMD_UT_WARN_LIMIT			0x52
#define ZL9101M_CMD_UT_FAULT_LIMIT			0x53
#define ZL9101M_CMD_UT_FAULT_RESPONSE		0x54
#define ZL9101M_CMD_VIN_OV_FAULT_LIMIT		0x55
#define ZL9101M_CMD_VIN_OV_FAULT_RESPONSE	0x56
#define ZL9101M_CMD_VIN_OV_WARN_LIMIT		0x57
#define ZL9101M_CMD_VIN_UV_WARN_LIMIT		0x58
#define ZL9101M_CMD_VIN_UV_FAULT_LIMIT		0x59
#define ZL9101M_CMD_VIN_UV_FAULT_RESPONSE	0x5A
#define ZL9101M_CMD_POWER_GOOD_ON			0x5E
#define ZL9101M_CMD_TON_DELAY				0x60
#define ZL9101M_CMD_TON_RISE				0x61
#define ZL9101M_CMD_TOFF_DELAY				0x64
#define ZL9101M_CMD_TOFF_FALL				0x65
#define ZL9101M_CMD_STATUS_BYTE				0x78
#define ZL9101M_CMD_STATUS_WORD				0x79
#define ZL9101M_CMD_STATUS_VOUT				0x7A
#define ZL9101M_CMD_STATUS_IOUT				0x7B
#define ZL9101M_CMD_STATUS_INPUT			0x7C
#define ZL9101M_CMD_STATUS_TEMPERATURE		0x7D
#define ZL9101M_CMD_STATUS_CML				0x7E
#define ZL9101M_CMD_STATUS_MFR				0x80
#define ZL9101M_CMD_READ_VIN				0x88
#define ZL9101M_CMD_READ_VOUT				0x8B
#define ZL9101M_CMD_READ_IOUT				0x8C
#define ZL9101M_CMD_READ_TEMPERATURE_1		0x8D
#define ZL9101M_CMD_READ_TEMPERATURE_2		0x8E
#define ZL9101M_CMD_READ_DUTY_CYCLE			0x94
#define ZL9101M_CMD_READ_FREQUENCY			0x95
#define ZL9101M_CMD_PMBUS_REVISION			0x98
#define ZL9101M_CMD_MFR_ID					0x99
#define ZL9101M_CMD_MFR_MODEL				0x9A
#define ZL9101M_CMD_MFR_REVISION			0x9B
#define ZL9101M_CMD_MFR_LOCATION			0x9C
#define ZL9101M_CMD_MFR_DATE				0x9D
#define ZL9101M_CMD_MFR_SERIAL				0x9E
#define ZL9101M_CMD_AUTO_COMP_CONFIG		0xBC
#define ZL9101M_CMD_AUTO_COMP_CONTROL		0xBD
#define ZL9101M_CMD_IOUT_OMEGA_OFFSET		0xBE
#define ZL9101M_CMD_DEADTIME_MAX			0xBF
#define ZL9101M_CMD_USER_DATA_00			0xB0
#define ZL9101M_CMD_MFR_CONFIG				0xD0
#define ZL9101M_CMD_USER_CONFIG				0xD1
#define ZL9101M_CMD_ISHARE_CONFIG			0xD2
#define ZL9101M_CMD_DDC_CONFIG				0xD3
#define ZL9101M_CMD_POWER_GOOD_DELAY		0xD4
#define ZL9101M_CMD_PID_TAPS				0xD5
#define ZL9101M_CMD_INDUCTOR				0xD6
#define ZL9101M_CMD_NLR_CONFIG				0xD7
#define ZL9101M_CMD_OVUV_CONFIG				0xD8
#define ZL9101M_CMD_XTEMP_SCALE				0xD9
#define ZL9101M_CMD_XTEMP_OFFSET			0xDA
#define ZL9101M_CMD_TEMPCO_CONFIG			0xDC
#define ZL9101M_CMD_DEADTIME				0xDD
#define ZL9101M_CMD_DEADTIME_CONFIG			0xDE
#define ZL9101M_CMD_SEQUENCE				0xE0
#define ZL9101M_CMD_TRACK_CONFIG			0xE1
#define ZL9101M_CMD_DDC_GROUP				0xE2
#define ZL9101M_CMD_DEVICE_ID				0xE4
#define ZL9101M_CMD_MFR_IOUT_OC_FAULT_RESPONSE	0xE5
#define ZL9101M_CMD_MFR_IOUT_UC_FAULT_RESPONSE	0xE6
#define ZL9101M_CMD_IOUT_AVG_OC_FAULT_LIMIT		0xE7
#define ZL9101M_CMD_IOUT_AVG_UC_FAULT_LIMIT		0xE8
#define ZL9101M_CMD_MISC_CONFIG				0xE9
#define ZL9101M_CMD_SNAPSHOT				0xEA
#define ZL9101M_CMD_BLANK_PARAMS			0xEB
#define ZL9101M_CMD_PHASE_CONTROL			0xF0
#define ZL9101M_CMD_PID_TAPS_ADAPT			0xF2
#define ZL9101M_CMD_PID_TAPS_CALC			0xF2
#define ZL9101M_CMD_SNAPSHOT_CONTROL		0xF3
#define ZL9101M_CMD_RESTORE_FACTORY			0xF4
#define ZL9101M_CMD_MFR_VMON_OV_FAULT_LIMIT		0xF5
#define ZL9101M_CMD_MFR_VMON_UV_FAULT_LIMIT		0xF6
#define ZL9101M_CMD_MFR_READ_VMON				0xF7
#define ZL9101M_CMD_VMON_OV_FAULT_RESPONSE		0xF8
#define ZL9101M_CMD_VMON_UV_FAULT_RESPONSE		0xF9
#define ZL9101M_CMD_SECURITY_LEVEL			0xFA
#define ZL9101M_CMD_PRIVATE_PASSWORD		0xFB
#define ZL9101M_CMD_PUBLIC_PASSWORD			0xFC
#define ZL9101M_CMD_UNPROTECT				0xFD

class tZL9101  : public json_serializer_class {

public:
	alt_u8  pwr_good;
	std::string device_id;
	float internal_temp;
	float v_in;
	float v_out;
	float v_out_set;
	float i_out;
	alt_u16 status;
	alt_u8 stat_vout;	// Vout fault or warning
	alt_u8 stat_iout;	// Iout fault or warning
	alt_u8 stat_input;	// Input fault or warning
	alt_u8 stat_mfr;	// Manufacturer Specific
	alt_u8 stat_cml;	// Comm, Logic, Memory event
	alt_u8 stat_temp; 	// Temperature
	json::Value get_json_object();
	tZL9101() {

	}
} ;

//int tZL9101_print(tZL9101* p, char* outstr) {
//	int num_chars = 0;
//	num_chars += xsprintf(outstr,"pwr_good=%x device_id=%x internal_temp=%x pg_1v2=%x pg_1v1=%x pg_0v9=%x",p->pg_2v5,p->pg_1v8,p->pg_1v5,p->pg_1v2,p->pg_1v1,p->pg_0v9);
//	return numchars;
//}

void 		ZL9101M_SendByte(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code);
void 		ZL9101M_WriteByte(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code, alt_u8 data);
void 		ZL9101M_WriteWord(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code, alt_u16 data);
void        ZL9101M_WriteDoubleWord(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code, alt_u32 data);
void        ZL9101M_WriteBlock(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code, char data[], alt_u32 data_len);

alt_u8		ZL9101M_ReadByte(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code);
alt_u16 	ZL9101M_ReadWord(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code);
alt_u32	    ZL9101M_ReadDoubleWord(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code);
void 		ZL9101M_ReadBlock(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code, std::string& data, alt_u32 data_len);

#endif /* ZL9101M_H_ */
