/*
 * emif_diag_virtual_uart.h
 *
 *  Created on: Feb 12, 2014
 *      Author: yairlinn
 */

#ifndef EMIF_DIAG_DEVICE_DRIVER_VIRTUAL_UART_H_
#define EMIF_DIAG_DEVICE_DRIVER_VIRTUAL_UART_H_

#include "virtual_uart_register_file.h"

class emif_diag_device_driver_virtual_uart: public virtual_uart_register_file {
public:
	emif_diag_device_driver_virtual_uart();

};

#endif /* EMIF_DIAG_DEVICE_DRIVER_VIRTUAL_UART_H_ */
