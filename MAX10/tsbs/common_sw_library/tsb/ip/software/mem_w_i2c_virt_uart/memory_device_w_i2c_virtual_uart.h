/*
 * memory_device_w_i2c_virtual_uart.h
 *
 *  Created on: Feb 1, 2017
 *      Author: yairlinn
 */

#ifndef MEMORY_DEVICE_W_I2C_VIRTUAL_UART_H_
#define MEMORY_DEVICE_W_I2C_VIRTUAL_UART_H_
#include "i2c_device_driver_virtual_uart.h"
#include <virtual_uart_register_file.h>

class memory_device_w_i2c_virtual_uart: public virtual_uart_register_file {
protected:
	i2c_device_driver_virtual_uart* i2c_device_driver_inst;
public:
	memory_device_w_i2c_virtual_uart();
	virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
    virtual void write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);

	void set_i2c_device_driver_inst(i2c_device_driver_virtual_uart* i2cDeviceDriverInst) {
		i2c_device_driver_inst = i2cDeviceDriverInst;
	}

	virtual ~memory_device_w_i2c_virtual_uart();

	i2c_device_driver_virtual_uart* get_i2c_device_driver_inst() {
		return i2c_device_driver_inst;
	}

};

#endif /* MEMORY_DEVICE_W_I2C_VIRTUAL_UART_H_ */
