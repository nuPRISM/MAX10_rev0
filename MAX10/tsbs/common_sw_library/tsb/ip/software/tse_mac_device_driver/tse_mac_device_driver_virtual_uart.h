/*
 * tse_mac_device_driver_virtual_uart.h
 *
 *  Created on: Feb 12, 2014
 *      Author: yairlinn
 */

#ifndef TSE_MAC_DEVICE_DRIVER_VIRTUAL_UART_H_
#define TSE_MAC_DEVICE_DRIVER_VIRTUAL_UART_H_

#include "virtual_uart_register_file.h"

class tse_mac_device_driver_virtual_uart: public virtual_uart_register_file {
protected:
	int enable_phy_register_tunneling;
public:
	tse_mac_device_driver_virtual_uart(int the_enable_phy_register_tunneling = 0);

	int isEnablePhyRegisterTunneling() {
		return enable_phy_register_tunneling;
	}

	void setEnablePhyRegisterTunneling(int enablePhyRegisterTunneling) {
		enable_phy_register_tunneling = enablePhyRegisterTunneling;
	}
};

#endif /* TSE_MAC_DEVICE_DRIVER_VIRTUAL_UART_H_ */
