/*
 * ad9253_virtual_uart.h
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#ifndef AD9253_VIRTUAL_UART_H_
#define AD9253_VIRTUAL_UART_H_

#include "virtual_uart_register_file.h"
#include "AD9253_driver.h"

class ad9253_virtual_uart: public virtual_uart_register_file,
		public AD9253_driver
{
public:
	ad9253_virtual_uart();
	virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
    virtual void write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);

};

#endif /* AD9253_VIRTUAL_UART_H_ */
