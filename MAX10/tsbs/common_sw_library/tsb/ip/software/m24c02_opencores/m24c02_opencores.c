/*
 * m24c02_opencores.c
 *
 *  Created on: Jul 22, 2016
 *      Author: user
 */

#include "m24c02_opencores.h"

static void get_device_addresses(alt_u8* actual_device_address, alt_u8* addr, alt_u8 E2E1E0, alt_u32 reg_address) {
	*actual_device_address =  0b1010000 | (E2E1E0 & 0x7);
	*addr = (reg_address & 0xFF);	
}

int m24c02_opencores_reg_write_8_bit  (alt_u32 base, alt_u8 E2E1E0, alt_u32 reg_address, alt_u8 data)
{
	int ret[3];
	alt_u8 actual_device_address, addr;
	
    get_device_addresses(&actual_device_address, &addr, E2E1E0,reg_address);
	
    I2C_YAIR_start(base,actual_device_address,0);
    ret[0] = I2C_YAIR_write(base, addr,0);
    ret[1] = I2C_YAIR_write(base, data & 0xFF,1);
    return ((ret[1] << 1) + ret[0]);
}



alt_u8 m24c02_opencores_reg_read_8_bit (alt_u32 base, alt_u8 E2E1E0, alt_u32 reg_address)
{
    int ret;
    int data;

    alt_u8 actual_device_address, addr;
	
    get_device_addresses(&actual_device_address, &addr, E2E1E0,reg_address);
	
    I2C_YAIR_start(base,actual_device_address,0);
    ret = I2C_YAIR_write(base,addr,0);
    ret = I2C_YAIR_write(base,addr,0); //datasheet says send byte address twice
    I2C_YAIR_start(base,actual_device_address,1);
    data = I2C_YAIR_read(base,1);
    return data;
}

