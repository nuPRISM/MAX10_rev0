/*
 * arria_v_xcvr_reconfig_device_driver_virtual_uart.h
 *
 *  Created on: Feb 20, 2014
 *      Author: yairlinn
 */

#ifndef ARRIA_V_XCVR_RECONFIG_DEVICE_DRIVER_VIRTUAL_UART_H_
#define ARRIA_V_XCVR_RECONFIG_DEVICE_DRIVER_VIRTUAL_UART_H_

#include <virtual_uart_register_file.h>

class arria_v_xcvr_reconfig_device_driver_virtual_uart: public virtual_uart_register_file {
public:
	arria_v_xcvr_reconfig_device_driver_virtual_uart();
};

#endif /* ARRIA_V_XCVR_RECONFIG_DEVICE_DRIVER_VIRTUAL_UART_H_ */
