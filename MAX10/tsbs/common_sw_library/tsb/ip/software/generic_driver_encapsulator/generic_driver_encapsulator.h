/*
 * generic_driver_encapsulator.h
 *
 *  Created on: Nov 7, 2015
 *      Author: user
 */

#ifndef GENERIC_DRIVER_ENCAPSULATOR_H_
#define GENERIC_DRIVER_ENCAPSULATOR_H_

#include <string>

class generic_driver_encapsulator {

protected:
	        std::string name;
			unsigned long base_address;
			unsigned long span_in_bytes;
            unsigned long bytes_per_location;
		public:
			generic_driver_encapsulator(unsigned long the_base_address, unsigned long span_in_bytes, std::string name = "undefined", unsigned long bytes_per_location = 4);
			generic_driver_encapsulator() { base_address = 0; span_in_bytes= 0; name = "undefined"; bytes_per_location = 4;};
			virtual ~generic_driver_encapsulator();
			virtual unsigned long read(unsigned the_reg_num);
			virtual void write(unsigned the_reg_num, unsigned long data);
			virtual unsigned long get_span_in_bytes() const;
			virtual void set_span_in_bytes(unsigned long span_in_bytes);
			virtual unsigned long get_base_address() const;
			virtual void set_base_address(unsigned long base_address);
			virtual void turn_on_bit(unsigned the_reg_num, unsigned long bit);
			virtual void turn_off_bit(unsigned the_reg_num, unsigned long bit);
			virtual unsigned long get_bit(unsigned the_reg_num, unsigned long bit);
			virtual void set_bit(unsigned the_reg_num, unsigned long bit, unsigned int val);
            virtual void set_bytes_per_location(unsigned long bytes_per_location);
            virtual unsigned long get_bytes_per_location();
            virtual unsigned long read_reg_by_byte_offset(unsigned long byte_offset);
            virtual void write_reg_by_byte_offset(unsigned long byte_offset, unsigned long data);
	std::string get_name() const {
		return name;
	}

	void set_name(std::string name) {
		this->name = name;
	}
};

#endif /* GENERIC_DRIVER_ENCAPSULATOR_H_ */
