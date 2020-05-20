/*
 * fmc176_cpld_virtual_uart.h
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#ifndef FMC176_CPLD_VIRTUAL_UART_H_
#define FMC176_CPLD_VIRTUAL_UART_H_

#include "virtual_uart_register_file.h"
#include "debug_macro_definitions.h"
#include "fmc176_cpld_driver.h"

class fmc176_cpld_virtual_uart: public virtual_uart_register_file,
		public fmc176_cpld_driver
{
protected:
  register_desc_map_type default_register_descriptions;

public:
	fmc176_cpld_virtual_uart();
	virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
    virtual void write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);

};

#endif /* CPLD_VIRTUAL_UART_H_ */
