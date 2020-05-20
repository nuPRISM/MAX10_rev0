/*
 * i2c_device_driver.cpp
 *
 *  Created on: Feb 17, 2014
 *      Author: yairlinn
 */

#include "i2c_device_driver.h"
#include "i2c_opencores_yair_regs.h"
#include "alt_types.h"
#include <string>
#include "i2c_opencores_yair.h"
#include "linnux_utils.h"

const int I2C_OPENCORES_READ_CONST = (1);
const int  I2C_OPENCORES_WRITE_CONST = (0);

void i2c_device_driver::I2C_driver_init(alt_u32 clk, alt_u32 speed) {
    lock();
	I2C_YAIR_init(this->get_base_address(),clk,speed);
	unlock();

}

int i2c_device_driver::I2C_driver_start(alt_u32 add, alt_u32 read) {
	int retval;
	lock();
	retval = I2C_YAIR_start(this->get_base_address(),add,read);
	if (get_default_delay_usec()) {
		low_level_system_usleep(get_default_delay_usec());
	}
	unlock();
	return retval;

}
alt_u32 i2c_device_driver::read_without_locking(alt_u32 last){
	alt_u32 x;
	x = I2C_YAIR_read(this->get_base_address(),last);
	if (get_default_delay_usec()) {
			low_level_system_usleep(get_default_delay_usec());
	}
	return x;
};

alt_u32 i2c_device_driver::write_without_locking(alt_u8 data, alt_u32 last){
	alt_u32 x;
	x = I2C_YAIR_write(this->get_base_address(),data,last);
	if (get_default_delay_usec()) {
			low_level_system_usleep(get_default_delay_usec());
	}
	return x;
};


alt_u32 i2c_device_driver::I2C_driver_read(alt_u32 last) {
	alt_u32 retval;
	lock();
	retval = read_without_locking(last);
	unlock();
	return retval;
}

alt_u32 i2c_device_driver::I2C_driver_write(alt_u8 data, alt_u32 last) {
	alt_u32 retval;
	lock();
    retval = write_without_locking(data,last);
	unlock();
	return retval;

}

alt_u32  i2c_device_driver::I2C_driver_write_vector(std::vector<alt_u8> data_vector) {
	alt_u32 retval;
	retval = 0;
	lock();
	unsigned i;
	for (i = 0; i < data_vector.size(); i++) {
		retval | write_without_locking(data_vector.at(i),(i==data_vector.size()-1));
	}
	unlock();
	return retval;
}


i2c_device_driver::i2c_device_driver() : semaphore_locking_class() {
	default_delay_usec = 0;
	this->set_num_internal_addr_bytes_in_rw(1);
	// TODO Auto-generated constructor stub

}



int i2c_device_driver::i2c_write_bytes(unsigned long base, unsigned long i2c_7bit_addr, int addr, unsigned char* data,int n){

	int i;

	/* Start and write mode */
	I2C_driver_start(i2c_7bit_addr,0);
	if (this->get_num_internal_addr_bytes_in_rw() > 1) {
		/* Address */
			I2C_driver_write((0xFF00 & addr)>>8,0);
	}
	/* Address */
	I2C_driver_write(0xFF & addr,0);

	for(i=0;i<(n-1);i++){
		I2C_driver_write(*data++,0);
	}

	I2C_driver_write(*data,1);

	return 0;
}


int i2c_device_driver::i2c_write_byte(unsigned long base, unsigned long i2c_7bit_addr,int addr, unsigned char data){

	int retval;

	retval = i2c_write_bytes(base,i2c_7bit_addr,addr,&data,1);

	return retval;
}


int i2c_device_driver::i2c_read_bytes(unsigned long base, unsigned long i2c_7bit_addr,int addr, unsigned  char *data,int n){

	int i;

	/* Start and write mode */
	I2C_driver_start(i2c_7bit_addr,I2C_OPENCORES_WRITE_CONST);
	if (this->get_num_internal_addr_bytes_in_rw() > 1) {
			/* Address */
				I2C_driver_write((0xFF00 & addr)>>8,0);
	}
	/* Address */
	I2C_driver_write(0xFF & addr,I2C_OPENCORES_WRITE_CONST);

	/* Start again in read mode */
	I2C_driver_start(i2c_7bit_addr,I2C_OPENCORES_READ_CONST);

		for(i=0;i<(n-1);i++){

			*data++ =  I2C_driver_read(0);  // read the input register and send stop

		}

		*data = I2C_driver_read(1);

		return 0;

}


int i2c_device_driver::i2c_read_byte(unsigned long base, unsigned long i2c_7bit_addr,int addr, unsigned char*data){

	int retval;

	retval = i2c_read_bytes(base,i2c_7bit_addr,addr, data,1);

	return retval;
}


std::string i2c_device_driver::readRandom(unsigned int address, int len, int& retval) {
	char temp[len+1];
    retval = i2c_read_bytes(this->get_base_address(), this->get_i2c_7bit_addr(),address,temp, len);
    std::string retstr;
    retstr = temp;
    return retstr;
}

int i2c_device_driver::writeRandom(unsigned int address, std::string data) {
	int retval = i2c_write_bytes (this->get_base_address(), this->get_i2c_7bit_addr(), address, data.c_str(), data.length());
	return retval;
}


unsigned int i2c_device_driver::readRandom_byte(unsigned int address, int& retval) {
	char temp[2];
    retval = i2c_read_bytes(this->get_base_address(), this->get_i2c_7bit_addr(),address,temp, 1);
    return ((unsigned int) temp[0]);
}

int i2c_device_driver::writeRandom_byte(unsigned int address, unsigned int data) {
	char temp = data & 0xff;
	int retval = i2c_write_bytes (this->get_base_address(), this->get_i2c_7bit_addr(), address, &temp, 1);
	return retval;
}
