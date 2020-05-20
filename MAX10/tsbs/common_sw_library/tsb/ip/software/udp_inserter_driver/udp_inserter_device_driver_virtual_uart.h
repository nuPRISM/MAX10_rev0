/*
 * udp_inserter_device_driver_virtual_uart.h
 *
 *  Created on: Feb 20, 2014
 *      Author: yairlinn
 */

#ifndef UDP_INSERTER_DEVICE_DRIVER_VIRTUAL_UART_H_
#define UDP_INSERTER_DEVICE_DRIVER_VIRTUAL_UART_H_

#include <virtual_uart_register_file.h>

class udp_inserter_device_driver_virtual_uart: public virtual_uart_register_file {
public:
	udp_inserter_device_driver_virtual_uart();
};

#endif /* UDP_INSERTER_DEVICE_DRIVER_VIRTUAL_UART_H_ */
