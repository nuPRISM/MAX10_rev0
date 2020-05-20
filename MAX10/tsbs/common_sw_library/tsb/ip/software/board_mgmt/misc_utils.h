/*
 * misc_utils.h
 *
 *  Created on: Apr 11, 2012
 *      Author: linnyair
 */

#ifndef MISC_UTILS_H_
#define MISC_UTILS_H_

int my_log2 (unsigned int val);
unsigned long extract_bit_range(unsigned long the_data, unsigned short lsb, unsigned short msb);
unsigned long set_bit_in_32bit_value(unsigned long data, unsigned short bit_num, unsigned short val);
void delay_at_least_us(unsigned num_us);

#endif /* MISC_UTILS_H_ */
