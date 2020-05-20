/*
 * i2c_device_driver_virtual_uart.h
 *
 *  Created on: Feb 20, 2014
 *      Author: yairlinn
 */

#ifndef I2C_DEVICE_DRIVER_VIRTUAL_UART_H_
#define I2C_DEVICE_DRIVER_VIRTUAL_UART_H_

#include <virtual_uart_register_file.h>
#include "i2c_device_driver.h"
class i2c_device_driver_virtual_uart: public virtual_uart_register_file, public i2c_device_driver {
public:
	i2c_device_driver_virtual_uart();
};

#endif /* I2C_DEVICE_DRIVER_VIRTUAL_UART_H_ */
