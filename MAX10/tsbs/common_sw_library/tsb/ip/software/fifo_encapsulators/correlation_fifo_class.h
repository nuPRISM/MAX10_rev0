/*
 * correlation_fifo_class.h
 *
 *  Created on: May 17, 2011
 *      Author: linnyair
 */

#ifndef CORRELATION_FIFO_CLASS_H_
#define CORRELATION_FIFO_CLASS_H_

#include "gp_fifo_encapsulator.h"
#include "basedef.h"

class correlation_fifo_class: public gp_fifo_encapsulator {
	protected:
		unsigned long data_select_reg_addr;
		unsigned long data_select_bit_num;
		unsigned long transpose_symbols_bit_num;
	public:
		void select_corr_fifo_input(unsigned short sel);
		void select_transpose_fifo_input(unsigned short sel);

		correlation_fifo_class(unsigned long base_addr, unsigned long flag_base_addr, unsigned long control_base_addr, unsigned long fifo_dmask, unsigned long capacity,
				unsigned long data_select_reg_addr_val, unsigned long data_select_bit_num_val, unsigned long transpose_symbols_bit_num_val, unsigned short transpose_symbols,
				std::string description_val) :
			gp_fifo_encapsulator(base_addr, flag_base_addr, control_base_addr, fifo_dmask, capacity, description_val)
		{
			data_select_reg_addr = data_select_reg_addr_val;
			data_select_bit_num = data_select_bit_num_val;
			transpose_symbols_bit_num = transpose_symbols_bit_num_val;
			 if (!OMIT_CONTRUCTOR_WRITE_FOR_SDR) {
			 select_transpose_fifo_input(transpose_symbols);
			}
		}
		virtual ~correlation_fifo_class();
};

#endif /* CORRELATION_FIFO_CLASS_H_ */
