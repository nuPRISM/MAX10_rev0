/*
 * adt7420.h
 *
 *  Created on: Jul 22, 2016
 *      Author: user
 */

#ifndef ADT7420_H_
#define ADT7420_H_
#include "alt_2_wire.h"

#define ADT7420_I2C_SETUP_DELAY_US (10)
#define MAX_ADT7420_I2C_ADDRESS (0)
#define MAX_ADT7420_REG_ADDRESS (0x2F)

typedef enum {
 ADT7420_TEMP_SENSOR_REGISTER_ADDRESS = 0,
 ADT7420_STATUS_REG_ADDRESS           = 2,
 ADT7420_CONFIGURATION_REG_ADDRESS    = 3,
 ADT7420_THIGH_REGISTER_ADDRESS       = 4,
 ADT7420_TLOW_REGISTER_ADDRESS        = 6,
 ADT7420_TCRIT_REGISTER_ADDRESS       = 8,
 ADT7420_THYST_REG_ADDRESS            = 0xA,
 ADT7420_ID_REG_ADDRESS               = 0x0B,
 ADT7420_SOFTWARE_RESET_REG_ADDRESS   = 0x2F,
} adt7420_register_map_type; 

int adt7420_reg_write_16_bit (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address, alt_u16 val);
int adt7420_reg_write_8_bit (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address, alt_u8 val);
int  adt7420_reg_read_16_bit (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address);
int  adt7420_reg_read_8_bit (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address);
int  adt7420_read_temp_sensor (alt_two_wire* bus, alt_u8 device_address);
int adt7420_read_reg (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address);
int adt7420_write_reg (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address, alt_u16 data);


#endif /* ADT7420_H_ */
