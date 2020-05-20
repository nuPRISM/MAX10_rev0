/*
 * misc_utils.c
 *
 *  Created on: Apr 11, 2012
 *      Author: linnyair
 */

#include "adc_mcs_basedef.h"
#include "system.h"
#include "misc_str_utils.h"
#include <unistd.h>

int my_log2 (unsigned int val) {
    unsigned int ret = -1;
    while (val != 0) {
        val >>= 1;
        ret++;
    }
    return ret;
}

unsigned long extract_bit_range(unsigned long the_data, unsigned short lsb, unsigned short msb)
{
	the_data = the_data >> lsb;
	the_data = the_data & (~(0xFFFFFFFF << (msb - lsb + 1)));
	return the_data;
}

unsigned long set_bit_in_32bit_value(unsigned long data, unsigned short bit_num, unsigned short val)
{
	unsigned long mask = 0;
	mask = 1 << bit_num;
	if (val == 0)
	{
		return (data & ~mask);
	} else
	{
		return (data | mask);
	}
}
void delay_at_least_us(unsigned num_us)
{
	 if (num_us == 0) {
		 return;
	 }
	float num_clks_per_usec = ((float) MCS_CLOCK_FREQUENCY_HZ)/((float) 1000000.0);

	unsigned i;
	unsigned j;
	for (i = 0; i < num_us; i++ ) {
		for (j = 0; j < ((unsigned int) num_clks_per_usec); j++ ) {
                asm("nop;");
			}
	}
}
