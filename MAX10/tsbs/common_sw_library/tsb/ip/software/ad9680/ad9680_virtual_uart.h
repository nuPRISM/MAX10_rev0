/*
 * ad9680_virtual_uart.h
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#ifndef AD9680_VIRTUAL_UART_H_
#define AD9680_VIRTUAL_UART_H_

#include "virtual_uart_register_file.h"
#include "ad9680_driver.h"

class ad9680_virtual_uart: public virtual_uart_register_file,
		public ad9680_driver
{
protected:
  register_desc_map_type default_register_descriptions;

public:
	ad9680_virtual_uart(unsigned long current_chipselect_index = 0);
	virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
    virtual void write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);

};

#endif /* AD9680_VIRTUAL_UART_H_ */
