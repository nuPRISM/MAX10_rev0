/*
 * $Id$
 *
 *  Created on: Nov 20, 2012
 *  Created by: Chris Ohlmann
 */

/**
 *  Description
 */

#include "mic280.h"
#include <drivers/inc/i2c_opencores_regs.h>
#include <drivers/inc/i2c_opencores.h>

//static void MIC280_WriteByte(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code, alt_u8 data);
static alt_u8 MIC280_ReadByte(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code);
static alt_u16 MIC280_ReadWord(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code);

alt_u8 MIC280_GetID(alt_u32 i2c_base, alt_u8 device_addr) {
	return MIC280_ReadByte(i2c_base, device_addr, MIC280_CMD_MFG_ID);
}

alt_u8 MIC280_GetRevision(alt_u32 i2c_base, alt_u8 device_addr) {
	return MIC280_ReadByte(i2c_base, device_addr, MIC280_CMD_DEV_ID);
}

alt_8 MIC280_ReadLocalTemp(alt_u32 i2c_base, alt_u8 device_addr) {
	return MIC280_ReadByte(i2c_base, device_addr, MIC280_CMD_TEMP0);
}

alt_16 MIC280_ReadRemoteTemp(alt_u32 i2c_base, alt_u8 device_addr) {
	return MIC280_ReadWord(i2c_base, device_addr, MIC280_CMD_TEMP1h);
}

/*
static void MIC280_WriteByte(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code, alt_u8 data){
	if(I2C_start(i2c_base, device_addr, OPENCORES_I2C_TXR_WR_MSK) == I2C_ACK) {
		I2C_write(i2c_base, cmd_code, 0);
		I2C_write(i2c_base, data, 1);
	}
}
*/

static alt_u8 MIC280_ReadByte(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code){
	alt_u8 data = 0;

	if(I2C_start(i2c_base, device_addr, I2C_OPENCORES_TXR_WR_MSK) == I2C_ACK) {
		I2C_write(i2c_base, cmd_code, 0);
		I2C_start(i2c_base, device_addr, I2C_OPENCORES_TXR_RD_MSK);
		data = I2C_read(i2c_base, 1);
	}

	return data;
}


static alt_u16	MIC280_ReadWord(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code){
	alt_u16 data = 0;

	if(I2C_start(i2c_base, device_addr, I2C_OPENCORES_TXR_WR_MSK) == I2C_ACK) {
		I2C_write(i2c_base, cmd_code, 0);
		I2C_start(i2c_base, device_addr, I2C_OPENCORES_TXR_RD_MSK);
		data  = I2C_read(i2c_base, 0) << 8;
		data |= I2C_read(i2c_base, 1);
	}

	return data;
}
