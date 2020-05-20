/*
 * dip_switch_encapsulator.cpp
 *
 *  Created on: Nov 21, 2013
 *      Author: yairlinn
 */

#include "dip_switch_encapsulator.h"

dip_switch_encapsulator::dip_switch_encapsulator(unsigned long dip_switch_pio_base_address)  : altera_pio_encapsulator(dip_switch_pio_base_address)

{
	this->set_pio_type(ALTERA_PIO_TYPE_INPUT);
	// TODO Auto-generated constructor stub

}

