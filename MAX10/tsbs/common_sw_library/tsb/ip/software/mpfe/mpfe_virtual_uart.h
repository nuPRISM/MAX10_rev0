/*
 * mpfe_virtual_uart.h
 *
 *  Created on: Nov 20, 2014
 *      Author: yairlinn
 */

#ifndef MPFE_VIRTUAL_UART_H_
#define MPFE_VIRTUAL_UART_H_

#include <virtual_uart_register_file.h>

class mpfe_virtual_uart: public virtual_uart_register_file {
protected:
	unsigned int per_slave_offset(unsigned int slave_num);
public:
	mpfe_virtual_uart(unsigned int numslaves);
};

#endif /* MPFE_VIRTUAL_UART_H_ */
