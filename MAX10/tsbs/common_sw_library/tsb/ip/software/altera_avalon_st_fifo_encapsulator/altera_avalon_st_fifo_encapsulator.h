/*
 * altera_avalon_st_fifo_encapsulator.h
 *
 *  Created on: Mar 20, 2016
 *      Author: user
 */

#ifndef altera_avalon_st_fifo_encapsulator_H_
#define altera_avalon_st_fifo_encapsulator_H_

#include "generic_driver_encapsulator.h"
extern "C" {
#include "altera_avalon_fifo_util.h"
}
class altera_avalon_st_fifo_encapsulator: public generic_driver_encapsulator {
protected:
	unsigned int capacity;
public:
	altera_avalon_st_fifo_encapsulator() : generic_driver_encapsulator() {
		this->set_capacity(0);
	};
	altera_avalon_st_fifo_encapsulator(unsigned long the_base_address, unsigned long span_in_bytes, unsigned int capacity, std::string name = "undefined") :
		generic_driver_encapsulator(the_base_address,span_in_bytes,name) {
		this->set_capacity(capacity);
	};

	int init(alt_u32 ienable,
	  alt_u32 emptymark, alt_u32 fullmark);

	int read_status(alt_u32 mask);
	int read_ienable(alt_u32 mask);
	int read_almostfull();
	int read_almostempty();
	int read_event(alt_u32 mask);
	int read_level();

	int clear_event(alt_u32 mask);
	int write_ienable(alt_u32 mask);

	virtual ~altera_avalon_st_fifo_encapsulator();

	unsigned int get_capacity() const {
		return capacity;
	}

	void set_capacity(unsigned int capacity) {
		this->capacity = capacity;
	}
};

#endif /* altera_avalon_st_fifo_encapsulator_H_ */
