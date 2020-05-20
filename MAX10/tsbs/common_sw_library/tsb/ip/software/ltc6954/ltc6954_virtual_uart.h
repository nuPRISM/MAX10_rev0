/*
 * ltc6954_virtual_uart.h
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#ifndef LTC6954_VIRTUAL_UART_H_
#define LTC6954_VIRTUAL_UART_H_

#include "virtual_uart_register_file.h"
#include "ltc6954_driver.h"

class ltc6954_virtual_uart: public virtual_uart_register_file,
		public ltc6954_driver
{
protected:
  register_desc_map_type default_register_descriptions;

public:
	ltc6954_virtual_uart(unsigned long chipselect, unsigned long id_no);
	virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
    virtual void write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);

};

#endif /* LTC6954_VIRTUAL_UART_H_ */
