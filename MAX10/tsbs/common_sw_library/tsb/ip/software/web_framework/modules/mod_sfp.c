/*
 * mod_sfp.c
 *
 *  Created on: Dec 9, 2016
 *      Author: admin
 */

#include <assert.h>
#include <i2c_opencores_regs.h>
#include <i2c_opencores.h>
#include "mod_sfp.h"

static eESPERError Init(tESPERMID mid, tESPERModuleSFP* ctx);
static eESPERError Start(tESPERMID mid, tESPERModuleSFP* ctx);
static eESPERError Update(tESPERMID mid, tESPERModuleSFP* ctx);

tESPERModuleSFP* ModuleSFPInit(tESPERModuleSFP* ctx) {
	if(!ctx) return 0;

	return ctx;
}

eESPERError ModuleSFPHandler(tESPERMID mid, tESPERGID gid, eESPERModuleState state, ESPER_TIMESTAMP ts, void* ctx) {
	switch(state) {
	case ESPER_MOD_STATE_INIT:
		return Init(mid, (tESPERModuleSFP*)ctx);
	case ESPER_MOD_STATE_START:
		return Start(mid, (tESPERModuleSFP*)ctx);
	case ESPER_MOD_STATE_UPDATE:
		return Update(mid, (tESPERModuleSFP*)ctx);
	case ESPER_MOD_STATE_STOP:
		break;
	}

	return ESPER_ERR_OK;
}

static eESPERError Init(tESPERMID mid, tESPERModuleSFP* ctx){
	ESPER_CreateVarUInt8(mid, "serial_xcvr", 	ESPER_OPTION_RD, 1, &ctx->transceiver_type, 0, 0);
	ESPER_CreateVarUInt8(mid, "serial_xcvr_ext", ESPER_OPTION_RD, 1, &ctx->transceiver_type_ext, 0, 0);
	ESPER_CreateVarUInt8(mid, "conn_type", 		ESPER_OPTION_RD, 1, &ctx->connector, 0, 0);

	return ESPER_ERR_OK;
}

static eESPERError Start(tESPERMID mid, tESPERModuleSFP* ctx) {
	return ESPER_ERR_OK;
}

static eESPERError Update(tESPERMID mid, tESPERModuleSFP* ctx){
	/*
	alt_u8 oui[3];

	ctx->vendor_name		[SFP_ReadBuff(i2c_base, 0xA0 >> 1, SFP_REG_VENDOR,	(alt_u8*)sfp_info->vendor_nm, 16, 1)] = '\0';

	// Convert OUI into HEX string for easy identification
	SFP_ReadBuff(i2c_base, 0xA0 >> 1, SFP_REG_OUI, oui, 3, 0);
	sprintf(sfp_info->vendor_oui, "%02X%02X%02X", oui[0], oui[1], oui[2] );

	sfp_info->vendor_oui	[7] = '\0';
	sfp_info->vendor_pn		[SFP_ReadBuff(i2c_base, 0xA0 >> 1, SFP_REG_PN, 		(alt_u8*)sfp_info->vendor_pn, 16, 1)] = '\0';
	sfp_info->vendor_rev	[SFP_ReadBuff(i2c_base, 0xA0 >> 1, SFP_REG_REV, 	(alt_u8*)sfp_info->vendor_rev, 4, 1)] = '\0';
	sfp_info->vendor_sn		[SFP_ReadBuff(i2c_base, 0xA0 >> 1, SFP_REG_SN, 		(alt_u8*)sfp_info->vendor_sn, 16, 1)] = '\0';

	// This byte informs on the type of SFP connector, 7h for LC (basically our standard fiber connector), 22h for RJ45
	SFP_ReadBuff(i2c_base, 0xA0 >> 1, SFP_REG_CONN, &sfp_info->vendor_conn, 1, 0);
	 */
	return ESPER_ERR_OK;
}



/*
alt_u8 SFP_ReadByte(alt_u32 i2c_base, alt_u8 address, alt_u8 reg) {
	alt_u8 data = 0;

	if(I2C_start(i2c_base, address, I2C_OPENCORES_TXR_WR_MSK) == I2C_ACK) {
		I2C_write(i2c_base,  reg, 0);
		I2C_start(i2c_base, address, I2C_OPENCORES_TXR_RD_MSK);
		data = I2C_read(i2c_base, 1);
	}

	return data;
}

alt_u8 SFP_WriteByte(alt_u32 i2c_base, alt_u8 address, alt_u8 reg, alt_u8 value) {
	if(I2C_start(i2c_base, address, I2C_OPENCORES_TXR_WR_MSK) == I2C_ACK) {
		I2C_write(i2c_base, reg, 0);
		I2C_write(i2c_base, value, 1);
	}
	return 0;
}

alt_u8 SFP_ReadBuff(alt_u32 i2c_base, alt_u8 address, alt_u8 reg, alt_u8* data, alt_u8 num_bytes, alt_u8 isString) {
	alt_u8 i;
	alt_u8 n;
	unsigned char c;

	// Skip if NULL ptr or nothing to transmit
	if((data == 0) || (num_bytes == 0)) { return 0; }

	n = 0;

	if(I2C_start(i2c_base, address, I2C_OPENCORES_TXR_WR_MSK) == I2C_ACK) {
		I2C_write(i2c_base,  reg, 0);
		I2C_start(i2c_base, address, I2C_OPENCORES_TXR_RD_MSK);
		for(i=0; i < num_bytes; ++i ) {
			// Enable stop bit on last byte to send
			c = I2C_read(i2c_base, (i == (num_bytes-1)));
			if((isString && isprint(c) && !isspace(c)) || !isString) {
				data[n++] = c;
			}
		}
	}

	// return actual number of bytes read
	return n;
}
*/
