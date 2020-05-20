/*
 * m24m02_opencores.c
 *
 *  Created on: Jul 22, 2016
 *      Author: user
 */

#include "m24m02_opencores.h"

static void get_device_addresses(alt_u8* actual_device_address, alt_u8* addr_h, alt_u8* addr_l, alt_u8 E2_pin, alt_u32 reg_address) {
	E2_pin = E2_pin & 0x1;
	*actual_device_address = (E2_pin ? 0b1010100 : 0b1010000) + ((reg_address & 0x30000) >> 16);
    *addr_h = (reg_address & 0xFF00) >> 8;
	*addr_l = (reg_address & 0xFF);	
}

int m24m02_opencores_reg_write_8_bit  (alt_u32 base, alt_u8 E2_pin, alt_u32 reg_address, alt_u8 data)
{
	int ret[3];
	alt_u8 actual_device_address, addr_h, addr_l;
	
    get_device_addresses(&actual_device_address, &addr_h, &addr_l,E2_pin,reg_address);
	
    I2C_YAIR_start(base,actual_device_address,0);
    ret[0] = I2C_YAIR_write(base, addr_h,0);
    ret[1] = I2C_YAIR_write(base, addr_l,0);
    ret[2] = I2C_YAIR_write(base, data & 0xFF,1);
    return ((ret[2] << 2) + (ret[1] << 1) + ret[0]);
}



alt_u8 m24m02_opencores_reg_read_8_bit (alt_u32 base, alt_u8 E2_pin, alt_u32 reg_address)
{
    int ret;
    int data;

    alt_u8 actual_device_address, addr_h, addr_l;
	
    get_device_addresses(&actual_device_address, &addr_h, &addr_l,E2_pin,reg_address);
	
    I2C_YAIR_start(base,actual_device_address,0);
    ret = I2C_YAIR_write(base,addr_h,0);
    ret = I2C_YAIR_write(base,addr_l,0);
    I2C_YAIR_start(base,actual_device_address,1);
    data = I2C_YAIR_read(base,1);
    return data;
}

