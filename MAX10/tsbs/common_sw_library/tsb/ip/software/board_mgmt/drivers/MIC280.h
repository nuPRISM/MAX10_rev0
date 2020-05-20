/*
 * $Id$
 *
 *  Created on: Nov 20, 2012
 *  Created by: Chris Ohlmann
 */

/**
 *  MIC280 Precision IttyBitty Thermal Supervisor
 *
 */

#ifndef MIC280_H_
#define MIC280_H_

#include <alt_types.h>
#include "basedef.h"
#include "jansson.hpp"
#include "json_serializer_class.h"

/* I2C Slave Address based on Part Marking Code */
#define MIC280_ADDR_TA00 	0x48	// MIC280-0BM6 and MIC280-0YM6
#define MIC280_ADDR_TA01 	0x49	// MIC280-1BM6 and MIC280-1YM6
#define MIC280_ADDR_TA02 	0x4A	// MIC280-2BM6 and MIC280-2YM6
#define MIC280_ADDR_TA03 	0x4B	// MIC280-3BM6 and MIC280-3YM6
#define MIC280_ADDR_TA04 	0x4C	// MIC280-4BM6 and MIC280-4YM6
#define MIC280_ADDR_TA05 	0x4D	// MIC280-5BM6 and MIC280-5YM6
#define MIC280_ADDR_TA06 	0x4E	// MIC280-6BM6 and MIC280-6YM6
#define MIC280_ADDR_TA07 	0x4F	// MIC280-7BM6 and MIC280-7YM6

/* SMBus Register Addresses */
#define MIC280_CMD_TEMP0	0x00	//READ-ONLY
#define MIC280_CMD_TEMP1h	0x01	//READ-ONLY
#define MIC280_CMD_STATUS	0x02	//READ-ONLY
#define MIC280_CMD_CONFIG	0x03
#define MIC280_CMD_IMASK	0x04
#define MIC280_CMD_THIGH0	0x05
#define MIC280_CMD_TLOW0	0x06
#define MIC280_CMD_THIGH1h	0x07
#define MIC280_CMD_TLOW1h	0x08
#define MIC280_CMD_LOCK		0x09
#define MIC280_CMD_TEMP1l	0x10	//READ-ONLY
#define MIC280_CMD_THIGH1l	0x13
#define MIC280_CMD_TLOW1l	0x14
#define MIC280_CMD_CRIT1	0x19
#define MIC280_CMD_CRIT0	0x20
#define MIC280_CMD_MFG_ID	0xFE	//READ-ONLY
#define MIC280_CMD_DEV_ID	0xFF	//READ-ONLY

class tMIC2080   : public json_serializer_class {

public:
	alt_u8 manufacturer_id;
	alt_u8 die_revision;

	alt_u8 local_temp;
	alt_u8 local_temp_low_limit;
	alt_u8 local_temp_high_limit;
	alt_u8 local_temp_crit_limit;

	alt_u16 remote_temp;
	alt_u16 remote_temp_low_limit;
	alt_u16 remote_temp_high_limit;
	alt_u8  remote_temp_crit_limit;
	json::Value get_json_object();
};

alt_u8 MIC280_GetID(alt_u32 i2c_base, alt_u8 device_addr);
alt_u8 MIC280_GetRevision(alt_u32 i2c_base, alt_u8 device_addr);

alt_8 MIC280_ReadLocalTemp(alt_u32 i2c_base, alt_u8 device_addr);
alt_16 MIC280_ReadRemoteTemp(alt_u32 i2c_base, alt_u8 device_addr);

#endif /* MIC280_H_ */
