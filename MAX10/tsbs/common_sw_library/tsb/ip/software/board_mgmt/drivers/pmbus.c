/*
 * pmbus.c
 *
 *  Created on: 2013-06-11
 *      Author: bryerton
 */

#include "pmbus.h"
#include <math.h>

float LINEAR_CONV_TO_FLOAT(alt_u16 word) {
	return (float)(((alt_16)(word)) * (0.0001220703125f));
}

alt_u16 LINEAR_CONV_TO_WORD(float value) {
	return (alt_u16)(value * 8192);
}

float LITERAL_CONV(alt_u16 word) {
	alt_8 n;
	alt_16 x;

	x = (word & 0x07FF); // lower 11 bit signed integer
	n = (word & 0xF800) >> 11; // upper 5 bit signed integer

	if(x & 0x0400) { x |= 0xF800; } // sign extend if necessary
	if(n & 0x10)   { n |= 0xE0;   } // sign extend if necessary

	return (float)(x * pow(2,n));
}

