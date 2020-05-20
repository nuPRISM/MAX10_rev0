/*
 * lmk04828_virtual_uart.h
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#ifndef lmk04828_VIRTUAL_UART_H_
#define lmk04828_VIRTUAL_UART_H_

#include "virtual_uart_register_file.h"
#include "lmk04828_driver.h"

class lmk04828_virtual_uart: public virtual_uart_register_file,
		public lmk04828_driver
{
public:
	lmk04828_virtual_uart();
	virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
    virtual void write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);

};

#endif /* lmk04828_VIRTUAL_UART_H_ */
