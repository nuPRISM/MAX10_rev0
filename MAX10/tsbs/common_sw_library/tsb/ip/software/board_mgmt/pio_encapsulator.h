/*
 * pio_encapsulator.h
 *
 *  Created on: Jul 11, 2013
 *      Author: yairlinn
 */

#ifndef PIO_ENCAPSULATOR_H_
#define PIO_ENCAPSULATOR_H_

void write_to_gpo_reg(unsigned long regnum, unsigned long val);
unsigned long read_from_gpo_reg(unsigned long regnum);
unsigned long read_from_gpi_reg(unsigned long regnum);
unsigned long set_bit_in_gpo_reg(unsigned short regnum, unsigned short bit_num, unsigned short val);
unsigned long read_from_io(unsigned long absolute_address) ;
void write_to_io(unsigned long absolute_address, unsigned long val);


#endif /* PIO_ENCAPSULATOR_H_ */
