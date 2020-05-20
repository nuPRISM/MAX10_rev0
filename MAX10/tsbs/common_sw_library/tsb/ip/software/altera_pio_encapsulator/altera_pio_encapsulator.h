/*
 * altera_pio_encapsulator.h
 *
 *  Created on: May 13, 2013
 *      Author: yairlinn
 */

#ifndef ALTERA_PIO_ENCAPSULATOR_H_
#define ALTERA_PIO_ENCAPSULATOR_H_

#include <string>
#include "c_pio_encapsulator.h"
class altera_pio_encapsulator {
protected:
	Altera_PIO_Type pio_type;
	unsigned long base_address;
	std::string name;
public:
	altera_pio_encapsulator() { base_address = 0; };
	altera_pio_encapsulator(unsigned long the_base_address, std::string name = "undefined");
	altera_pio_encapsulator(unsigned long the_base_address,  Altera_PIO_Type pio_type, std::string name = "undefined");
	virtual ~altera_pio_encapsulator();
    virtual Altera_PIO_Type get_pio_type() const;
    virtual void set_pio_type(Altera_PIO_Type pio_type);
    virtual unsigned long read();
    virtual void write(unsigned long data);
    virtual unsigned long get_base_address() const;
    virtual void set_base_address(unsigned long  base_address);
    virtual void turn_on_bit(unsigned long bit);
    virtual void turn_off_bit(unsigned long bit);
    virtual void set_bidir_pio_direction_input();
    virtual void set_bidir_pio_direction_output();
	virtual unsigned long get_bit(unsigned long bit);
	unsigned long extract_bits(short lsb,short msb);

	std::string get_name() const {
		return name;
	}

	void set_name(std::string name) {
		this->name = name;
	}
};

#endif /* ALTERA_PIO_ENCAPSULATOR_H_ */
