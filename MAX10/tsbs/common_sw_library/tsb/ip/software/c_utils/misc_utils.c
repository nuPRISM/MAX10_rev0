
#include "misc_str_utils.h"
#include "misc_utils.h"
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

unsigned long change_bits_in_32bit_value(unsigned long the_data, unsigned long new_data, unsigned short lsb, unsigned short msb)
{
    //the_data = the_data & ~((~(~(0xFFFFFFFF << (msb - lsb + 1)))) << lsb); //
    unsigned long  low_data_bits = extract_bit_range(the_data,0,lsb);
    unsigned long  new_data_bits = extract_bit_range(new_data,lsb,msb);
	unsigned long  high_data_bits = extract_bit_range(the_data,msb,31);
    unsigned long composed_data = 0;
	if (lsb != 0) {
		composed_data = low_data_bits;
	}
	composed_data += (new_data_bits << lsb);
	if (msb != 31) {
		composed_data += (high_data_bits << msb);
	}
	return composed_data;
}


