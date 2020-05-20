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
unsigned long change_bits_in_32bit_value(unsigned long the_data, unsigned long new_data, unsigned short lsb, unsigned short msb);

#endif /* MISC_UTILS_H_ */
