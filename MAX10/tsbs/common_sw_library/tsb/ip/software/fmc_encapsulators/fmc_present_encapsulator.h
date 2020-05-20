/*
 * fmc_present_encapsulator.h
 *
 *  Created on: Jul 16, 2013
 *      Author: yairlinn
 */

#ifndef FMC_PRESENT_ENCAPSULATOR_H_
#define FMC_PRESENT_ENCAPSULATOR_H_

#include "altera_pio_encapsulator.h"
#include <vector>
#include <stdio.h>
#include <string>
class fmc_present_encapsulator: public altera_pio_encapsulator {
protected:
	std::vector<bool> fmc_enabled;
	unsigned long raw_fmc_present_vector;
    void set_raw_fmc_present_vector(unsigned long raw_fmc_present_vector);


public:
    unsigned long get_raw_fmc_present_vector() const;

    fmc_present_encapsulator(unsigned long fmc_present_pio_base_address);
    void calculate_fmc_enabled();
	bool is_enabled(unsigned long fmc_num) {
		return (fmc_enabled.at(fmc_num));
	}

    std::string get_tcl_vector_of_fmc_present_status();


};
#endif /* FMC_PRESENT_ENCAPSULATOR_H_ */
