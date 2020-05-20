/*
 * lm75.h
 *
 *  Created on: Jul 22, 2016
 *      Author: user
 */

#ifndef LM75_H_
#define LM75_H_
#include "alt_2_wire.h"

#define LM75_TEMP_SENSOR_REGISTER_ADDRESS (0)
#define LM75_CONFIGURATION_REG_ADDRESS    (1)
#define LM75_THYST_REG_ADDRESS            (2)
#define LM75_TOS_REG_ADDRESS              (3)

int lm75_reg_write_16_bit (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address, alt_u16 val);
int lm75_reg_write_8_bit (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address, alt_u8 val);
int  lm75_reg_read_16_bit (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address);
int  lm75_reg_read_8_bit (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address);
int  lm75_read_temp_sensor (alt_two_wire* bus, alt_u8 device_address);
int lm75_read_reg (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address);
int lm75_write_reg (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address, alt_u16 data);


#endif /* LM75_H_ */
