/*
 * seven_segment_encapsulator.cpp
 *
 *  Created on: May 18, 2011
 *      Author: linnyair
 */

#include "seven_segment_encapsulator.h"

seven_segment_encapsulator::seven_segment_encapsulator(unsigned long seven_seg_data_reg_addr_val, unsigned long longseven_seg_data_mask_val, unsigned long num_digits_val, unsigned long initial_value)
{
	seven_seg_data_reg_addr = seven_seg_data_reg_addr_val;
	seven_seg_data_mask = longseven_seg_data_mask_val;
	num_digits = num_digits_val;
	unsigned long regval = read_value_from_reg_keeper_reg(seven_seg_data_reg_addr);
	//write_value_to_reg_keeper_reg(seven_seg_data_reg_addr, (regval & ~(seven_seg_data_mask)) + (initial_value & seven_seg_data_mask));

}

seven_segment_encapsulator::~seven_segment_encapsulator()
{
	// TODO Auto-generated destructor stub
}

void seven_segment_encapsulator::write_as_decimal_number(unsigned long val)
{
	unsigned long max_decimal_val = (unsigned long) pow(10.0, num_digits);
	unsigned long actual_val_to_write;
	if (val >= max_decimal_val)
	{
		actual_val_to_write = 0xA4A4A4A4;
	} else
	{
		actual_val_to_write = 0;
		double digit_divisor = ((double) max_decimal_val) / 10.0;
		//safe_print(std::cout << digit_divisor << " " << val << " " << actual_val_to_write << "\n");
		for (unsigned int i = 0; i < num_digits; i++)
		{
			actual_val_to_write = (actual_val_to_write << 4) + ((unsigned long) (((double) val) / digit_divisor));
			val = (val % ((unsigned long) digit_divisor));
			digit_divisor = digit_divisor / 10.0;
			//safe_print(std::cout << digit_divisor << " " << val << " " << actual_val_to_write << "\n");
		}
	}

	unsigned long regval = read_value_from_reg_keeper_reg(seven_seg_data_reg_addr);
	write_value_to_reg_keeper_reg(seven_seg_data_reg_addr, (regval & ~(seven_seg_data_mask)) + (actual_val_to_write & seven_seg_data_mask));
}
