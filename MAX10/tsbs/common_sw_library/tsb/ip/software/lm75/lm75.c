/*
 * lm75.c
 *
 *  Created on: Jul 22, 2016
 *      Author: user
 */

#include "lm75.h"

int lm75_reg_write_16_bit (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address, alt_u16 data)
{
    int ret[4];

    alt_u8 actual_device_address = 0b10010000 + ((device_address & 0b111) << 1);
    alt_u8 actual_device_address_with_write = actual_device_address; //write bit indication is 0 (active low)
    alt_u8 actual_register_address = reg_address & 0x3;

    alt_2_wireStart(bus);
    ret[0] = alt_2_wireSendByte(bus,actual_device_address_with_write);
    ret[1] = alt_2_wireSendByte(bus,actual_register_address);
    ret[2] = alt_2_wireSendByte(bus,data >> 8);
    ret[3] = alt_2_wireSendByte(bus,data & 0xFF);
    alt_2_wireStop(bus);
    return ((ret[3] << 3) + (ret[2] << 2) + (ret[1] << 1) + ret[0]);
}

int lm75_reg_write_8_bit (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address, alt_u8 data)
{
    int ret[3];

    alt_u8 actual_device_address = 0b10010000 + ((device_address & 0b111) << 1);
    alt_u8 actual_device_address_with_write = actual_device_address; //write bit indication is 0 (active low)
    alt_u8 actual_register_address = reg_address & 0x3;

    alt_2_wireStart(bus);
    ret[0] = alt_2_wireSendByte(bus,actual_device_address_with_write);
    ret[1] = alt_2_wireSendByte(bus, actual_register_address);
    ret[2] = alt_2_wireSendByte(bus, data & 0xFF);
    alt_2_wireStop(bus);
    return ((ret[2] << 2) + (ret[1] << 1) + ret[0]);
}


int lm75_reg_read_16_bit (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address)
{
    int ret;
    int data;

    alt_u8 actual_device_address = 0b10010000 + ((device_address & 0b111) << 1);
    alt_u8 actual_device_address_with_write = actual_device_address; //write bit indication is 0 (active low)
    alt_u8 actual_device_address_with_read = actual_device_address + 1; //write bit indication is 1 (active low)
    alt_u8 actual_register_address = reg_address & 0x3;

    alt_2_wireStart(bus);
    ret = alt_2_wireSendByte(bus,actual_device_address_with_write);
    ret = alt_2_wireSendByte(bus,actual_register_address);
    alt_2_wireStart(bus);
    ret = alt_2_wireSendByte(bus,actual_device_address_with_read);
    data = alt_2_wireReadByte(bus,SEND_ACK);
    ret = alt_2_wireReadByte(bus,SEND_NACK);
    data = ((data << 8) | ret);
    alt_2_wireStop(bus);
    return data;
}

int lm75_reg_read_8_bit (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address)
{
    int ret;
    int data;

    alt_u8 actual_device_address = 0b10010000 + ((device_address & 0b111) << 1);
    alt_u8 actual_device_address_with_write = actual_device_address; //write bit indication is 0 (active low)
    alt_u8 actual_device_address_with_read = actual_device_address + 1; //write bit indication is 1 (active low)
    alt_u8 actual_register_address = reg_address & 0x3;

    alt_2_wireStart(bus);
    ret = alt_2_wireSendByte(bus,actual_device_address_with_write);
    ret = alt_2_wireSendByte(bus,actual_register_address);
    alt_2_wireStart(bus);
    ret = alt_2_wireSendByte(bus,actual_device_address_with_read);
    data = alt_2_wireReadByte(bus,SEND_NACK);
    alt_2_wireStop(bus);
    return data;
}
int  lm75_read_temp_sensor (alt_two_wire* bus, alt_u8 device_address) {
	return lm75_reg_read_16_bit(bus,device_address,LM75_TEMP_SENSOR_REGISTER_ADDRESS);
}

int lm75_read_reg (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address) {
	switch(reg_address) {
	case LM75_CONFIGURATION_REG_ADDRESS : return lm75_reg_read_8_bit(bus,device_address,reg_address); break;
	case LM75_THYST_REG_ADDRESS :
	case LM75_TEMP_SENSOR_REGISTER_ADDRESS:
	case LM75_TOS_REG_ADDRESS: return lm75_reg_read_16_bit(bus,device_address,reg_address); break;
	default: return 0xEAA;
	}
	return 0xEAA;
}

int lm75_write_reg (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address, alt_u16 data) {
	switch(reg_address) {
	case LM75_CONFIGURATION_REG_ADDRESS : return lm75_reg_write_8_bit(bus,device_address,reg_address,data); break;
	case LM75_THYST_REG_ADDRESS :
	case LM75_TEMP_SENSOR_REGISTER_ADDRESS:
	case LM75_TOS_REG_ADDRESS: return lm75_reg_write_16_bit(bus,device_address,reg_address,data); break;
	default: return 0xEAA;
	}
	return 0xEAA;
}

