/*
 * lm75_opencores.c
 *
 *  Created on: Jul 22, 2016
 *      Author: user
 */

#include "lm75_opencores.h"

int lm75_opencores_reg_write_16_bit (alt_u32 base, alt_u8 device_address, alt_u8 reg_address, alt_u16 data)
{
    int ret[4];

    alt_u8 actual_device_address = 0b1001000 + (device_address & 0b111) ;
    alt_u8 actual_register_address = reg_address & 0x7;

    I2C_YAIR_start(base,actual_device_address,0);
    ret[1] = I2C_YAIR_write(base,actual_register_address,0);
    ret[2] = I2C_YAIR_write(base,data >> 8,0);
    ret[3] = I2C_YAIR_write(base,data & 0xFF,1);
    return ((ret[3] << 3) + (ret[2] << 2) + (ret[1] << 1) + ret[0]);
}

int lm75_opencores_reg_write_8_bit (alt_u32 base, alt_u8 device_address, alt_u8 reg_address, alt_u8 data)
{
    int ret[3];

    alt_u8 actual_device_address = 0b1001000 + (device_address & 0b111) ;
    alt_u8 actual_register_address = reg_address & 0x7;

    I2C_YAIR_start(base,actual_device_address,0);
    ret[1] = I2C_YAIR_write(base, actual_register_address,0);
    ret[2] = I2C_YAIR_write(base, data & 0xFF,1);
    return ((ret[2] << 2) + (ret[1] << 1) + ret[0]);
}


int lm75_opencores_reg_read_16_bit (alt_u32 base, alt_u8 device_address, alt_u8 reg_address)
{
    int ret;
    int data, data_h, data_l;

    alt_u8 actual_device_address = 0b1001000 + (device_address & 0b111) ;
    alt_u8 actual_register_address = reg_address & 0x7;

    I2C_YAIR_start(base,actual_device_address,0);
    ret = I2C_YAIR_write(base,actual_register_address,0);
    I2C_YAIR_start(base,actual_device_address,1);
    data_h = I2C_YAIR_read(base,0);
    data_l = I2C_YAIR_read(base,1);
    data = ((data_h << 8) | data_l);
    return data;
}

int lm75_opencores_reg_read_8_bit (alt_u32 base, alt_u8 device_address, alt_u8 reg_address)
{
    int ret;
    int data;

    alt_u8 actual_device_address = 0b1001000 + (device_address & 0b111) ;
    alt_u8 actual_register_address = reg_address & 0x7;

    I2C_YAIR_start(base,actual_device_address,0);
    ret = I2C_YAIR_write(base,actual_register_address,0);
    I2C_YAIR_start(base,actual_device_address,1);
    data = I2C_YAIR_read(base,1);
    return data;
}
int  lm75_opencores_read_temp_sensor (alt_u32 base, alt_u8 device_address) {
	return (lm75_opencores_reg_read_16_bit(base,device_address,LM75_OPENCORES_TEMP_SENSOR_REGISTER_ADDRESS) & 0xFFFF);
}

int lm75_opencores_read_reg (alt_u32 base, alt_u8 device_address, alt_u8 reg_address) {
	switch(reg_address) {
	case LM75_OPENCORES_CONFIGURATION_REG_ADDRESS:
	case LM75_OPENCORES_TIDLE_REG_ADDRESS : return lm75_opencores_reg_read_8_bit(base,device_address,reg_address); break;

	case LM75_OPENCORES_THYST_REG_ADDRESS :
	case LM75_OPENCORES_TEMP_SENSOR_REGISTER_ADDRESS:
	case LM75_OPENCORES_TOS_REG_ADDRESS: return lm75_opencores_reg_read_16_bit(base,device_address,reg_address); break;
	default: return 0xEAA;
	}
	return 0xEAA;
}

int lm75_opencores_write_reg (alt_u32 base, alt_u8 device_address, alt_u8 reg_address, alt_u16 data) {
	switch(reg_address) {
	case LM75_OPENCORES_CONFIGURATION_REG_ADDRESS:
	case LM75_OPENCORES_TIDLE_REG_ADDRESS: return lm75_opencores_reg_write_8_bit(base,device_address,reg_address,data); break;
	case LM75_OPENCORES_THYST_REG_ADDRESS :
	case LM75_OPENCORES_TEMP_SENSOR_REGISTER_ADDRESS:
	case LM75_OPENCORES_TOS_REG_ADDRESS: return lm75_opencores_reg_write_16_bit(base,device_address,reg_address,data); break;
	default: return 0xEAA;
	}
	return 0xEAA;
}

void lm75_opencores_get_lm75_temp_parts(unsigned int raw, unsigned int *whole, unsigned int * frac) {
	*whole = (raw >> 8) & 0xFF;
	*frac = ((raw & 0xFF)>>5);
}

float lm75_opencores_get_temp(alt_u32 base, alt_u8 device_address) {

  unsigned int temp = lm75_opencores_read_temp_sensor(
				 base,
				 device_address
                 );

  unsigned int whole_temp,frac_temp;
  lm75_opencores_get_lm75_temp_parts(temp,&whole_temp,&frac_temp);
  float actual_temp = (whole_temp & 0x80) ?    ((((~whole_temp) << 3) +  (~frac_temp)) + 1)*0.125 : (((whole_temp << 3) +  frac_temp)*0.125);
  return actual_temp;
}


