/*
 * spi_encapsulator.h
 *
 *  Created on: Mar 15, 2013
 *      Author: yairlinn
 */

#ifndef SPI_ENCAPSULATOR_H_
#define SPI_ENCAPSULATOR_H_

#include "alt_types.h"

class spi_encapsulator {
protected:
	unsigned long base_address;

public:
	spi_encapsulator(unsigned long the_base_address);
	unsigned long get_rxdata();
	unsigned long get_txdata();
	int transmit_byte(unsigned long slave_num, unsigned char byte_to_write);
	int read_byte(unsigned long slave_num, unsigned char& the_read_byte);
	int transmit_16bit(unsigned long slave_num, alt_u16 val);
	int read_16bit(unsigned long slave_num, alt_u16& val);

};

#endif /* SPI_ENCAPSULATOR_H_ */
