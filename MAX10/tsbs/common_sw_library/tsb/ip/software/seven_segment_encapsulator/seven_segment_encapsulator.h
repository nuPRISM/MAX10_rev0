/*
 * seven_segment_encapsulator.h
 *
 *  Created on: May 18, 2011
 *      Author: linnyair
 */

#ifndef SEVEN_SEGMENT_ENCAPSULATOR_H_
#define SEVEN_SEGMENT_ENCAPSULATOR_H_
#include "register_keeper_api.h"
//#include "terasic_linnux_driver.h"
#include "linnux_testbench_constants.h"
#include "register_keeper_api.h"
#include <alt_types.h>
#include <altera_avalon_pio_regs.h>
#include <sys/alt_irq.h>
#include <system.h>
#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <iostream>
#include <fstream>
#include <map>
#include <float.h>
#include <vector>
#include <unistd.h>
#include <time.h>

class seven_segment_encapsulator {
	protected:
		     unsigned long seven_seg_data_reg_addr;
		     unsigned long seven_seg_data_mask;
		     unsigned long num_digits;

	public:
		seven_segment_encapsulator
		       (
		        unsigned long seven_seg_data_reg_addr_val,
				unsigned long longseven_seg_data_mask_val,
				unsigned long num_digits_val,
				unsigned long initial_value
			   );
		void write_as_decimal_number(unsigned long val);
		virtual ~seven_segment_encapsulator();
};

#endif /* SEVEN_SEGMENT_ENCAPSULATOR_H_ */
