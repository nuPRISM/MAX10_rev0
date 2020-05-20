/*
 * correlation_fifo_class.cpp
 *
 *  Created on: May 17, 2011
 *      Author: linnyair
 */

#include "correlation_fifo_class.h"
#include "register_keeper_api.h"
#include "linnux_utils.h"

correlation_fifo_class::~correlation_fifo_class()
{
	// TODO Auto-generated destructor stub
}
void correlation_fifo_class::select_corr_fifo_input(unsigned short sel)
{
	unsigned long regval;
	regval = read_value_from_reg_keeper_reg(data_select_reg_addr);

	if (sel)
	{
		regval = set_bit_in_32bit_reg(regval, data_select_bit_num, 1);
	} else
	{
		regval = set_bit_in_32bit_reg(regval, data_select_bit_num, 0);
	}

	write_value_to_reg_keeper_reg(data_select_reg_addr, regval);
}

void correlation_fifo_class::select_transpose_fifo_input(unsigned short sel)
{
	unsigned long regval;
	regval = read_value_from_reg_keeper_reg(data_select_reg_addr);

	if (sel)
	{
		regval = set_bit_in_32bit_reg(regval, transpose_symbols_bit_num, 1);
	} else
	{
		regval = set_bit_in_32bit_reg(regval, transpose_symbols_bit_num, 0);
	}

	write_value_to_reg_keeper_reg(data_select_reg_addr, regval);
}
