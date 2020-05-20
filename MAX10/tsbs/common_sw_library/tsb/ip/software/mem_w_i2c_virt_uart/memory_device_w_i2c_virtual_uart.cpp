/*
 * memory_device_w_i2c_virtual_uart.cpp
 *
 *  Created on: Feb 1, 2017
 *      Author: yairlinn
 */

#include "memory_device_w_i2c_virtual_uart.h"

memory_device_w_i2c_virtual_uart::memory_device_w_i2c_virtual_uart() :
virtual_uart_register_file() {
	// TODO Auto-generated constructor stub

}

memory_device_w_i2c_virtual_uart::~memory_device_w_i2c_virtual_uart() {
	// TODO Auto-generated destructor stub
}

unsigned long long memory_device_w_i2c_virtual_uart::read_control_reg(unsigned long address, unsigned long secondary_uart_address, int* errorptr) {
	int retval;
	unsigned int return_data = this->get_i2c_device_driver_inst()->readRandom_byte(address,retval);
	return ((unsigned long long) (return_data & 0xFF));
}
void memory_device_w_i2c_virtual_uart::write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address, int* errorptr) {
    this->get_i2c_device_driver_inst()->writeRandom_byte(address,data & 0xFF);
}
