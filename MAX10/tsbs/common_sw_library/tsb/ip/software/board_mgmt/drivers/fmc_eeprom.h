/*
 * fmc_eeprom.h
 *
 *  Created on: 2013-04-17
 *      Author: bryerton
 */

#ifndef FMC_EEPROM_H_
#define FMC_EEPROM_H_

#include <alt_types.h>

#define BOARDMANAGEMENT_0_FMC_EEPROM_BASE_ADDRESS (0x50) // 0xA0 >> 1
#define FMC_EEPROM_ADDRESS(x) (BOARDMANAGEMENT_0_FMC_EEPROM_BASE_ADDRESS | ((x) & 0x3))
#define FMC_EEPROM_SIZE 256
#define FMC_EEPROM_PAGE_SIZE 16

alt_u8 FMC_EEPROM_IsMultiByte(alt_u32 i2c_base, alt_u8 fmc_id);

void FMC_EEPROM_WriteByte(alt_u32 i2c_base, alt_u8 fmc_id, alt_u8 multibyte, alt_u16 address, alt_u8 data, alt_u8* checksum);
alt_u8 FMC_EEPROM_ReadByte(alt_u32 i2c_base, alt_u8 fmc_id, alt_u8 multibyte, alt_u16 address, alt_u8* checksum);
/*
alt_u8 FMC_EEPROM_WritePage(alt_u32 i2c_base, alt_u8 fmc_id, alt_u16 address, alt_u8* data, alt_u8 num_bytes);
alt_u8 FMC_EEPROM_ReadBuff(alt_u32 i2c_base, alt_u8 fmc_id, alt_u16 address, alt_u8* data, alt_u8 num_bytes);
alt_u8 FMC_EEPROM_ReadCurr(alt_u32 i2c_base, alt_u8 fmc_id);
*/
#endif /* FMC_EEPROM_H_ */
