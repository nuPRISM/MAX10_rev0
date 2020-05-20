/*
 * uart_based_pio_encapsulator.h
 *
 *  Created on: Feb 10, 2015
 *      Author: yairlinn
 */

#ifndef UART_BASED_PIO_ENCAPSULATOR_H_
#define UART_BASED_PIO_ENCAPSULATOR_H_

#include "uart_register_file.h"
#include "altera_pio_encapsulator.h"

class uart_based_pio_encapsulator : public altera_pio_encapsulator {
protected:

	   uart_register_file* uart_ptr;
	   unsigned long secondary_uart_num;
public:
	uart_based_pio_encapsulator(unsigned long the_base_address) : altera_pio_encapsulator(the_base_address) {
		uart_ptr = NULL;
	}

	uart_based_pio_encapsulator(unsigned long the_base_address, uart_register_file* uart_ptr, unsigned long secondary_uart_num = 0) : altera_pio_encapsulator(the_base_address) {
		this->uart_ptr = uart_ptr;
		this->secondary_uart_num = secondary_uart_num;
	}
	uart_based_pio_encapsulator() { base_address = 0; };


	virtual ~uart_based_pio_encapsulator();

	uart_register_file*  get_uart_ptr() {
		return uart_ptr;
	}

	void set_uart_ptr(uart_register_file* uartPtr) {
		uart_ptr = uartPtr;
	}

	 virtual unsigned long read();
	 virtual void write(unsigned long data);
};

#endif /* UART_BASED_PIO_ENCAPSULATOR_H_ */
