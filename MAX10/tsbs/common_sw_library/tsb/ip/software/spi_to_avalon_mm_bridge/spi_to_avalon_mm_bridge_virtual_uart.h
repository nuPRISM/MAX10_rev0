/*
 * spi_to_avalon_mm_bridge_virtual_uart.h
 *
 *  Created on: Jul 16, 2014
 *      Author: yairlinn
 */

#ifndef SPI_TO_AVALON_MM_BRIDGE_VIRTUAL_UART_H_
#define SPI_TO_AVALON_MM_BRIDGE_VIRTUAL_UART_H_
#include "virtual_uart_register_file.h"

class spi_to_avalon_mm_bridge_virtual_uart : public virtual_uart_register_file {

protected:
	unsigned int read_32_bits_from_mapped_space(unsigned int absolute_address);
	void write_32_bits_to_mapped_space(unsigned int absolute_address, unsigned int data);
	unsigned int read_8_bits_from_mapped_space(unsigned int absolute_address);
	void write_8_bits_to_mapped_space(unsigned int absolute_address, unsigned int data);
	unsigned int spi_base_addr;

public:
	spi_to_avalon_mm_bridge_virtual_uart();
	virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual void write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	unsigned int get_spi_base_addr() const {
		return spi_base_addr;
	}

	void set_spi_base_addr(unsigned int spiBaseAddr) {
		spi_base_addr = spiBaseAddr;
	}
};

#endif /* SPI_TO_AVALON_MM_BRIDGE_VIRTUAL_UART_H_ */
