/*
 * led_encapsulator.h
 *
 *  Created on: Aug 26, 2013
 *      Author: yairlinn
 */

#ifndef LED_ENCAPSULATOR_H_
#define LED_ENCAPSULATOR_H_
#include <stdio.h>
#include "altera_pio_encapsulator.h"

class led_encapsulator : public altera_pio_encapsulator
{

public:
	led_encapsulator(unsigned long the_base_address) : altera_pio_encapsulator(the_base_address)
	{
		//safe_print(std::cout << "Set up LEDs with base address of: " << std::hex << base_address << std::dec << std::endl);
	}
};

#endif /* LED_ENCAPSULATOR_H_ */
