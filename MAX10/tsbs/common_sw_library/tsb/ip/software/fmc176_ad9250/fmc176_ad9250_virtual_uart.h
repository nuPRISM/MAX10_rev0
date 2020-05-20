/*
 * fmc176_ad9250_virtual_uart.h
 *
 *  Created on: Feb 7, 2014
 *      Author: yairlinn
 */

#ifndef FMC176_AD9250_VIRTUAL_UART_H_
#define FMC176_AD9250_VIRTUAL_UART_H_

#include "virtual_uart_register_file.h"
#include "fmc176_ad9250_driver.h"

class fmc176_ad9250_virtual_uart: public virtual_uart_register_file,
		public fmc176_ad9250_driver
{
protected:
  register_desc_map_type default_register_descriptions;

public:
	fmc176_ad9250_virtual_uart(uint8_t current_id_no = 0, const uint32_t subclass = 0);
	virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
    virtual void write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);

};

#endif /* AD9250_VIRTUAL_UART_H_ */
