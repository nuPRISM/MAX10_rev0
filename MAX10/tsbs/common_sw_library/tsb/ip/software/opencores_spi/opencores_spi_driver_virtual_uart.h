/*
 * opencores_spi_driver_virtual_uart.h
 *
 *  Created on: Feb 12, 2014
 *      Author: yairlinn
 */

#ifndef OPENCORES_SPI_DRIVER_VIRTUAL_UART_H_
#define OPENCORES_SPI_DRIVER_VIRTUAL_UART_H_

#include <virtual_uart_register_file.h>

class opencores_spi_driver_virtual_uart: public virtual_uart_register_file {
public:
	opencores_spi_driver_virtual_uart();
};

#endif /* OPENCORES_SPI_DRIVER_VIRTUAL_UART_H_ */
