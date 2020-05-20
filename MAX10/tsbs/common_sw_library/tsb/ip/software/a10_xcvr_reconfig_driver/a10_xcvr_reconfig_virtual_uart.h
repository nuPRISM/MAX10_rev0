/*
 * a10_xcvr_reconfig_virtual_uart.h
 *
 *  Created on: Feb 20, 2014
 *      Author: yairlinn
 */

#ifndef A10_XCVR_RECONFIG_VIRTUAL_UART_H_
#define A10_XCVR_RECONFIG_VIRTUAL_UART_H_

#include <virtual_uart_register_file.h>

class a10_xcvr_reconfig_virtual_uart: public virtual_uart_register_file {
public:
	a10_xcvr_reconfig_virtual_uart();
};

#endif /* A10_XCVR_RECONFIG_VIRTUAL_UART_H_ */
