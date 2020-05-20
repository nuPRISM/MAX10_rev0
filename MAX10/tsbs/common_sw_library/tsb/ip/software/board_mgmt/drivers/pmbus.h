/*
 * pmbus.h
 *
 *  Created on: 2013-06-11
 *      Author: bryerton
 */

#ifndef PMBUS_H_
#define PMBUS_H_

#include <alt_types.h>

#define V_CONV(x) ((alt_u16)((x) * 0x2000))

// Linear Conversions
float LINEAR_CONV_TO_FLOAT(alt_u16 word);
alt_u16 LINEAR_CONV_TO_WORD(float value);

// Literal Conversions
float LITERAL_CONV(alt_u16 word);

#endif /* PMBUS_H_ */
