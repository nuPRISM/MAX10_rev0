/*
 * i2c_device_driver.h
 *
 *  Created on: Feb 17, 2014
 *      Author: yairlinn
 */

#ifndef I2C_DEVICE_DRIVER_H_
#define I2C_DEVICE_DRIVER_H_

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <string>
#include "io.h"
#include "altera_pio_encapsulator.h"
#include "semaphore_locking_class.h"
#include "alt_types.h"
#include <vector>


extern "C" {
#include "includes.h"
#include "ucos_ii.h"
}


#include <semaphore_locking_class.h>

class i2c_device_driver: public semaphore_locking_class {
protected:
	unsigned long base_address;
	unsigned long i2c_7bit_addr;
	unsigned long default_delay_usec;
	int num_internal_addr_bytes_in_rw;

    alt_u32 read_without_locking(alt_u32 last);
    alt_u32 write_without_locking(alt_u8 data, alt_u32 last);
    int i2c_write_bytes(unsigned long base, unsigned long i2c_7bit_addr, int addr, unsigned char* data,int n);
    int i2c_write_byte(unsigned long base, unsigned long i2c_7bit_addr,int addr, unsigned char data);
    int i2c_read_bytes(unsigned long base, unsigned long i2c_7bit_addr,int addr, unsigned  char *data,int n);
    int i2c_read_byte(unsigned long base, unsigned long i2c_7bit_addr,int addr, unsigned char*data);


public:
	void I2C_driver_init    (alt_u32 clk,alt_u32 speed);
	int I2C_driver_start    (alt_u32 add, alt_u32 read);
	alt_u32 I2C_driver_read (alt_u32 last);
	alt_u32 I2C_driver_write(alt_u8 data, alt_u32 last);
	alt_u32 I2C_driver_write_vector(std::vector<alt_u8> data_vector);
	i2c_device_driver();
	 std::string readRandom(unsigned int address, int len, int& retval);
	    int writeRandom(unsigned int address, std::string data);
	    unsigned int readRandom_byte(unsigned int address, int& retval);
	    int writeRandom_byte(unsigned int address, unsigned int data);
	unsigned long get_base_address() const {
		return base_address;
	}

	void set_base_address(unsigned long baseAddress) {
		base_address = baseAddress;
	}

	unsigned long get_i2c_7bit_addr() const {
		return i2c_7bit_addr;
	}

	void set_i2c_7bit_addr(unsigned long i2c7bitAddr) {
		i2c_7bit_addr = i2c7bitAddr;
	}

	unsigned long get_default_delay_usec() const {
		return default_delay_usec;
	}

	void set_default_delay_usec(unsigned long defaultDelayUsec) {
		default_delay_usec = defaultDelayUsec;
	}

	int get_num_internal_addr_bytes_in_rw() const {
		return num_internal_addr_bytes_in_rw;
	}

	void set_num_internal_addr_bytes_in_rw(int numInternalAddrBytesInRw) {
		num_internal_addr_bytes_in_rw = numInternalAddrBytesInRw;
	}
};

#endif /* I2C_DEVICE_DRIVER_H_ */
