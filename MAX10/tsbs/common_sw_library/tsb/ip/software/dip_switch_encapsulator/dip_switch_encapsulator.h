/*
 * dip_switch_encapsulator.h
 *
 *  Created on: Nov 21, 2013
 *      Author: yairlinn
 */

#ifndef DIP_SWITCH_ENCAPSULATOR_H_
#define DIP_SWITCH_ENCAPSULATOR_H_

#include "altera_pio_encapsulator.h"

class dip_switch_encapsulator: public altera_pio_encapsulator {
public:
	dip_switch_encapsulator() : altera_pio_encapsulator() {};
	dip_switch_encapsulator(unsigned long dip_switch_pio_base_address);

};

#endif /* DIP_SWITCH_ENCAPSULATOR_H_ */
