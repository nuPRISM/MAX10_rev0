/*
 * lmk04816_virtual_uart.h
 *
 *  Created on: Nov 21, 2016
 *      Author: yairlinn
 */

#ifndef LMK04816_VIRTUAL_UART_H_
#define LMK04816_VIRTUAL_UART_H_

#include "lmk04816uwire.h"
#include "command_server_virtual_uart.h"

class lmk04816_virtual_uart: public command_server_virtual_uart,
		public lmk04816_uwire {
public:
	lmk04816_virtual_uart(unsigned long lmk_clk_base, unsigned long lmk_data_base,  unsigned long lmk_leu_base, unsigned long lmk_status_holdover_base);
	virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
    virtual void write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual ~lmk04816_virtual_uart();
};

#endif /* LMK04816_VIRTUAL_UART_H_ */
