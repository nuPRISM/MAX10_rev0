/*
 * adt7420.c
 *
 *  Created on: Jul 22, 2016
 *      Author: user
 */

#include "adt7420.h"

int adt7420_reg_write_16_bit (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address, alt_u16 data)
{
    int ret[4];

    alt_u8 actual_device_address = 0b10010000 + ((device_address & 0b011) << 1);
    alt_u8 actual_device_address_with_write = actual_device_address; //write bit indication is 0 (active low)
    alt_u8 actual_register_address = reg_address;

    alt_2_wireStart(bus);
    ret[0] = alt_2_wireSendByte(bus,actual_device_address_with_write);
    ret[1] = alt_2_wireSendByte(bus,actual_register_address);
    ret[2] = alt_2_wireSendByte(bus,data >> 8);
    ret[3] = alt_2_wireSendByte(bus,data & 0xFF);
    alt_2_wireStop(bus);
    return ((ret[3] << 3) + (ret[2] << 2) + (ret[1] << 1) + ret[0]);
}

int adt7420_reg_write_8_bit (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address, alt_u8 data)
{
    int ret[3];

    alt_u8 actual_device_address = 0b10010000 + ((device_address & 0b011) << 1);
    alt_u8 actual_device_address_with_write = actual_device_address; //write bit indication is 0 (active low)
    alt_u8 actual_register_address = reg_address;

    alt_2_wireStart(bus);
    ret[0] = alt_2_wireSendByte(bus,actual_device_address_with_write);
    ret[1] = alt_2_wireSendByte(bus, actual_register_address);
    ret[2] = alt_2_wireSendByte(bus, data & 0xFF);
    alt_2_wireStop(bus);
    return ((ret[2] << 2) + (ret[1] << 1) + ret[0]);
}


int adt7420_reg_read_16_bit (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address)
{
    int ret;
    int data;

    alt_u8 actual_device_address = 0b10010000 + ((device_address & 0b011) << 1);
    alt_u8 actual_device_address_with_write = actual_device_address; //write bit indication is 0 (active low)
    alt_u8 actual_device_address_with_read = actual_device_address + 1; //write bit indication is 1 (active low)
    alt_u8 actual_register_address = reg_address;

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

int adt7420_reg_read_8_bit (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address)
{
    int ret;
    int data;

    alt_u8 actual_device_address = 0b10010000 + ((device_address & 0b011) << 1);
    alt_u8 actual_device_address_with_write = actual_device_address; //write bit indication is 0 (active low)
    alt_u8 actual_device_address_with_read = actual_device_address + 1; //write bit indication is 1 (active low)
    alt_u8 actual_register_address = reg_address;

    alt_2_wireStart(bus);
    ret = alt_2_wireSendByte(bus,actual_device_address_with_write);
    ret = alt_2_wireSendByte(bus,actual_register_address);
    alt_2_wireStart(bus);
    ret = alt_2_wireSendByte(bus,actual_device_address_with_read);
    data = alt_2_wireReadByte(bus,SEND_NACK);
    alt_2_wireStop(bus);
    return data;
}
int  adt7420_read_temp_sensor (alt_two_wire* bus, alt_u8 device_address) {
	return adt7420_reg_read_16_bit(bus,device_address,ADT7420_TEMP_SENSOR_REGISTER_ADDRESS);
}

int adt7420_read_reg (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address) {
	switch(reg_address) {
	case ADT7420_STATUS_REG_ADDRESS :
	case ADT7420_THYST_REG_ADDRESS :
	case ADT7420_ID_REG_ADDRESS :
	case ADT7420_SOFTWARE_RESET_REG_ADDRESS :
	case ADT7420_CONFIGURATION_REG_ADDRESS : return adt7420_reg_read_8_bit(bus,device_address,reg_address); break;
	case ADT7420_TCRIT_REGISTER_ADDRESS :
	case ADT7420_TLOW_REGISTER_ADDRESS :
	case ADT7420_TEMP_SENSOR_REGISTER_ADDRESS:
	case ADT7420_THIGH_REGISTER_ADDRESS: return adt7420_reg_read_16_bit(bus,device_address,reg_address); break;
	default: return 0xEAA;
	}
	return 0xEAA;
}

int adt7420_write_reg (alt_two_wire* bus, alt_u8 device_address, alt_u8 reg_address, alt_u16 data) {
	switch(reg_address) {
	case ADT7420_STATUS_REG_ADDRESS :
	case ADT7420_THYST_REG_ADDRESS :
	case ADT7420_ID_REG_ADDRESS :
	case ADT7420_SOFTWARE_RESET_REG_ADDRESS :
	case ADT7420_CONFIGURATION_REG_ADDRESS:   return adt7420_reg_write_8_bit(bus,device_address,reg_address,data); break;
	case ADT7420_TCRIT_REGISTER_ADDRESS :
	case ADT7420_TLOW_REGISTER_ADDRESS :
	case ADT7420_TEMP_SENSOR_REGISTER_ADDRESS:
	case ADT7420_THIGH_REGISTER_ADDRESS:  return adt7420_reg_write_16_bit(bus,device_address,reg_address,data); break;
	default: return 0xEAA;
	}
	return 0xEAA;
}

