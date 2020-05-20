/*
 * uart_based_pio_encapsulator.cpp
 *
 *  Created on: Feb 10, 2015
 *      Author: yairlinn
 */

#include "uart_based_pio_encapsulator.h"


uart_based_pio_encapsulator::~uart_based_pio_encapsulator() {
	// TODO Auto-generated destructor stub
}

unsigned long uart_based_pio_encapsulator::read() {
	return ((unsigned long) (uart_ptr->read_control_reg(base_address,secondary_uart_num,NULL)));
}

void uart_based_pio_encapsulator::write(unsigned long data){
	uart_ptr->write_control_reg(base_address,data,secondary_uart_num,NULL);;
}
