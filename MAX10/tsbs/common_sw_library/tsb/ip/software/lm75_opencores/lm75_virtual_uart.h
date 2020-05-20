/*
 * lm75_virtual_uart.h
 *
 *  Created on: Jan 22, 2018
 *      Author: yairlinn
 */

#ifndef LM75_VIRTUAL_UART_H_
#define LM75_VIRTUAL_UART_H_

#include "generic_driver_encapsulator.h"
#include "virtual_uart_register_file.h"

class lm75_virtual_uart : public virtual_uart_register_file, public generic_driver_encapsulator {
protected:
	static const int num_of_reg_locations = 5;
	static const unsigned int preferred_i2c_speed = 25000;

	unsigned int device_address;
	unsigned int base_clock_speed;
	unsigned int i2c_speed;
public:
	lm75_virtual_uart();
	virtual ~lm75_virtual_uart();
	virtual void init_i2c();
	virtual unsigned long read(unsigned the_reg_num);
	virtual void write(unsigned the_reg_num, unsigned long data);
	virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
    virtual void write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
    virtual int  read_temp_sensor();
    virtual float get_temp();

    virtual unsigned int get_device_address() const {
		return device_address;
	}

    virtual void set_device_address(unsigned int deviceAddress) {
		device_address = deviceAddress;
	}

    int get_num_of_reg_locations() {
		return num_of_reg_locations;
	}

    virtual unsigned int get_base_clock_speed() const {
		return base_clock_speed;
	}

    virtual void set_base_clock_speed(unsigned int baseClockSpeed) {
		base_clock_speed = baseClockSpeed;
	}

    virtual unsigned int get_i2c_speed() const {
		return i2c_speed;
	}

    virtual void set_i2c_speed(unsigned int i2cSpeed) {
		i2c_speed = i2cSpeed;
	}

    unsigned int get_preferred_i2c_speed() {
		return preferred_i2c_speed;
	}
};

#endif /* LM75_VIRTUAL_UART_H_ */
