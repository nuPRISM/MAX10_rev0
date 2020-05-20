/*
 * lm75.h
 *
 *  Created on: Jul 22, 2016
 *      Author: user
 */

#ifndef LM75_OPENCORES_H_
#define LM75_OPENCORES_H_
#include "i2c_opencores_yair.h"

#define LM75_OPENCORES_TEMP_SENSOR_REGISTER_ADDRESS (0)
#define LM75_OPENCORES_CONFIGURATION_REG_ADDRESS    (1)
#define LM75_OPENCORES_THYST_REG_ADDRESS            (2)
#define LM75_OPENCORES_TOS_REG_ADDRESS              (3)
#define LM75_OPENCORES_TIDLE_REG_ADDRESS            (4)

int  lm75_opencores_reg_write_16_bit (alt_u32 base, alt_u8 device_address, alt_u8 reg_address, alt_u16 val);
int  lm75_opencores_reg_write_8_bit  (alt_u32 base, alt_u8 device_address, alt_u8 reg_address, alt_u8 val);
int  lm75_opencores_reg_read_16_bit  (alt_u32 base, alt_u8 device_address, alt_u8 reg_address);
int  lm75_opencores_reg_read_8_bit   (alt_u32 base, alt_u8 device_address, alt_u8 reg_address);
int  lm75_opencores_read_temp_sensor (alt_u32 base, alt_u8 device_address);
int  lm75_opencores_read_reg         (alt_u32 base, alt_u8 device_address, alt_u8 reg_address);
int  lm75_opencores_write_reg        (alt_u32 base, alt_u8 device_address, alt_u8 reg_address, alt_u16 data);
void lm75_opencores_get_lm75_temp_parts(unsigned int raw, unsigned int *whole, unsigned int * frac);
float lm75_opencores_get_temp (alt_u32 base, alt_u8 device_address);

#endif /* LM75_H_ */
