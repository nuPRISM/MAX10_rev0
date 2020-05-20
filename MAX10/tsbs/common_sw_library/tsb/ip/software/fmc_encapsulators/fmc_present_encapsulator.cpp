/*
 * fmc_present_encapsulator.cpp
 *
 *  Created on: Jul 16, 2013
 *      Author: yairlinn
 */

#include "fmc_present_encapsulator.h"
#include <sstream>
#include <iostream>
#include <string>
#include <stdio.h>
#include "linnux_utils.h"

void fmc_present_encapsulator::calculate_fmc_enabled(){
	set_raw_fmc_present_vector(read());
			fmc_enabled.reserve(3);
			fmc_enabled.resize(3);
			fmc_enabled.at(0) = ((get_raw_fmc_present_vector() & 0x3) == 0x2);
			fmc_enabled.at(1) = ((get_raw_fmc_present_vector() & 0xC) == 0x8);
			fmc_enabled.at(2) = ((get_raw_fmc_present_vector() & 0x30) == 0x20);
			safe_print(std::cout << std::hex << " raw: " << get_raw_fmc_present_vector()<< " p0: " << fmc_enabled.at(0) << " p1: " << fmc_enabled.at(1) << " p2: " << fmc_enabled.at(2) << std::dec <<  std::endl);

};

fmc_present_encapsulator::fmc_present_encapsulator(unsigned long fmc_present_pio_base_address)
    : altera_pio_encapsulator(fmc_present_pio_base_address)
	{
    	calculate_fmc_enabled();
	};

unsigned long fmc_present_encapsulator::get_raw_fmc_present_vector() const
{
   return raw_fmc_present_vector;
}

void fmc_present_encapsulator::set_raw_fmc_present_vector(unsigned long  raw_fmc_present_vector)
{
    this->raw_fmc_present_vector = raw_fmc_present_vector;
}


std::string fmc_present_encapsulator::get_tcl_vector_of_fmc_present_status() {
    std::ostringstream ostr;

    for (unsigned  i = 0; i < 3; i++) {
    	if (this->is_enabled(i)) {
    		ostr << "1 ";
    	} else {
    		ostr << "0 ";
    	}
    }
    return TrimSpacesFromString(ostr.str());
};
