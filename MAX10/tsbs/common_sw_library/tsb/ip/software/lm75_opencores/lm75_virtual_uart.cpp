/*
 * lm75_virtual_uart.cpp
 *
 *  Created on: Jan 22, 2018
 *      Author: yairlinn
 */

#include "lm75_virtual_uart.h"
extern "C" {
#include "includes.h"
#include "ucos_ii.h"
#include "lm75_opencores.h"
}

lm75_virtual_uart::lm75_virtual_uart() {
	// TODO Auto-generated constructor stub

}

lm75_virtual_uart::~lm75_virtual_uart() {
	// TODO Auto-generated destructor stub
}

unsigned long lm75_virtual_uart::read(unsigned the_reg_num) {
	OSSchedLock();
	  unsigned long retval = lm75_opencores_read_reg(this->get_base_address(), this->get_device_address(), the_reg_num) & 0xFFFF;
	  OSSchedUnlock();
	  return retval;
}

void lm75_virtual_uart::write(unsigned the_reg_num, unsigned long data) {
	OSSchedLock();
	lm75_opencores_write_reg  (this->get_base_address(), this->get_device_address(), the_reg_num, (data & 0xFFFF));
    OSSchedUnlock();
}

unsigned long long lm75_virtual_uart::read_control_reg(unsigned long address, unsigned long secondary_uart_address, int* errorptr) {
	return read  (address);
}

void lm75_virtual_uart::write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address, int* errorptr) {
	write(address, data);
}

int lm75_virtual_uart::read_temp_sensor() {
	OSSchedLock();
	int retval = lm75_opencores_read_temp_sensor (this->get_base_address(), this->get_device_address());
	OSSchedUnlock();
    return retval;
}

float lm75_virtual_uart::get_temp() {
	OSSchedLock();
	float retval = lm75_opencores_get_temp(this->get_base_address(), this->get_device_address());
	OSSchedUnlock();
	return retval;
}

void lm75_virtual_uart::init_i2c() {
    I2C_YAIR_init(this->get_base_address(),this->get_base_clock_speed(),this->get_i2c_speed());
}
