/*
 * fmc_eeprom.c
 *
 *  Created on: 2013-04-17
 *      Author: bryerton
 */

#include "fmc_eeprom.h"
#include <drivers/inc/i2c_opencores_regs.h>
#include <drivers/inc/i2c_opencores.h>
#include <unistd.h>

alt_u8 FMC_EEPROM_IsMultiByte(alt_u32 i2c_base, alt_u8 fmc_id) {

	if(FMC_EEPROM_ReadByte(i2c_base, fmc_id, 0, 0, 0) != 0xFF) {
		return 0; // single byte
	}

	if(FMC_EEPROM_ReadByte(i2c_base, fmc_id, 1, 0, 0) != 0xFF) {
		return 1; // double byte
	}

	// 0 if unknown
	return 0;
}

void FMC_EEPROM_WriteByte(alt_u32 i2c_base, alt_u8 fmc_id, alt_u8 multibyte, alt_u16 address, alt_u8 data, alt_u8* checksum ) {

	if(I2C_start(i2c_base, FMC_EEPROM_ADDRESS(fmc_id), I2C_OPENCORES_TXR_WR_MSK) == I2C_ACK) {
		if(multibyte) {
			I2C_write(i2c_base, ((address & 0xFF00) >> 8), 0);
		}
		I2C_write(i2c_base,  (address & 0x00FF), 0);
		I2C_write(i2c_base, data, 1);

		if(checksum) { *checksum += data; }

		usleep(1);

		// ACK Poll
		while(I2C_start(i2c_base, FMC_EEPROM_ADDRESS(fmc_id), I2C_OPENCORES_TXR_WR_MSK) == I2C_NOACK);
	}
}

alt_u8 FMC_EEPROM_ReadByte(alt_u32 i2c_base, alt_u8 fmc_id, alt_u8 multibyte, alt_u16 address, alt_u8* checksum ) {
	alt_u8 data;
	data = 0;

	if(I2C_start(i2c_base, FMC_EEPROM_ADDRESS(fmc_id), I2C_OPENCORES_TXR_WR_MSK) == I2C_ACK) {
		if(multibyte) {
			I2C_write(i2c_base, ((address & 0xFF00) >> 8), 0);
		}
		I2C_write(i2c_base,  (address & 0x00FF), 0);
		I2C_start(i2c_base, FMC_EEPROM_ADDRESS(fmc_id), I2C_OPENCORES_TXR_RD_MSK);
		data = I2C_read(i2c_base, 1);

		if(checksum) { *checksum += data; }
	}

	return data;
}

/*

alt_u8 FMC_EEPROM_ReadBuff(alt_u32 i2c_base, alt_u8 fmc_id, alt_u16 address, alt_u8* data, alt_u8 num_bytes) {
	alt_u8 i;

	// Skip if NULL ptr or nothing to transmit
	if((data == 0) || (num_bytes == 0)) { return 0; }

	// Make sure we don't wrap within the device
	if (num_bytes+address > FMC_EEPROM_SIZE) { num_bytes = FMC_EEPROM_SIZE-address; }

	if(I2C_start(i2c_base, FMC_EEPROM_ADDRESS(fmc_id), I2C_OPENCORES_TXR_WR_MSK) == I2C_ACK) {
		I2C_write(i2c_base, ((address & 0xFF00) >> 8), 0);
		I2C_write(i2c_base,  (address & 0x00FF), 0);
		I2C_start(i2c_base, FMC_EEPROM_ADDRESS(fmc_id), I2C_OPENCORES_TXR_RD_MSK);
		for(i=0; i < num_bytes; ++i ) {
			// Enable stop bit on last byte to send
			data[i] = I2C_read(i2c_base, (i == (num_bytes-1)));
		}
	}

	// return actual number of bytes read
	return num_bytes;
}

alt_u8 FMC_EEPROM_WritePage(alt_u32 i2c_base, alt_u8 fmc_id, alt_u16 address, alt_u8* data, alt_u8 num_bytes) {
	alt_u8 i;

	// Skip if NULL ptr or nothing to transmit
	if((data == 0) || (num_bytes == 0)) { return 0; }

	// Make sure we don't try to send more than the maximum page size
	if(num_bytes > FMC_EEPROM_PAGE_SIZE) { num_bytes = FMC_EEPROM_PAGE_SIZE; }

	// Make sure we don't wrap within the page
	if (num_bytes + (address % FMC_EEPROM_PAGE_SIZE) > FMC_EEPROM_PAGE_SIZE) {
		num_bytes -= (address % FMC_EEPROM_PAGE_SIZE);
	}

	// Make sure we don't wrap within the device
	if (num_bytes+address > FMC_EEPROM_SIZE) {
		num_bytes = FMC_EEPROM_SIZE-address;
	}

	if(I2C_start(i2c_base, FMC_EEPROM_ADDRESS(fmc_id), I2C_OPENCORES_TXR_WR_MSK) == I2C_ACK) {
		I2C_write(i2c_base, ((address & 0xFF00) >> 8), 0);
		I2C_write(i2c_base,  (address & 0x00FF), 0);
		for(i=0; i < num_bytes; ++i ) {
			// Enable stop bit on last byte to send
			I2C_write(i2c_base, data[i], (i == (num_bytes-1)));
		}
	}

	// Ack Poll
	while(I2C_start(i2c_base, FMC_EEPROM_ADDRESS(fmc_id), I2C_OPENCORES_TXR_WR_MSK) == I2C_NOACK);

	// Return actual number of bytes written
	return num_bytes;
}

alt_u8 FMC_EEPROM_ReadCurr(alt_u32 i2c_base, alt_u8 fmc_id) {
	alt_u8 data;

	if(I2C_start(i2c_base, FMC_EEPROM_ADDRESS(fmc_id), I2C_OPENCORES_TXR_RD_MSK) == I2C_ACK) {
		data = I2C_read(i2c_base, 1);
	}

	return data;
}
*/
