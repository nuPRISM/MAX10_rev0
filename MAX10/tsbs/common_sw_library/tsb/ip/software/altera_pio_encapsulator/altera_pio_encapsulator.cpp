/*
 * altera_pio_encapsulator.cpp
 *
 *  Created on: May 13, 2013
 *      Author: yairlinn
 */
#include "altera_pio_encapsulator.h"
#include "altera_avalon_pio_regs.h"

altera_pio_encapsulator::altera_pio_encapsulator(unsigned long the_base_address, std::string name)
{
	set_base_address(the_base_address);
	this->set_name(name);
}

altera_pio_encapsulator::altera_pio_encapsulator(unsigned long the_base_address,  Altera_PIO_Type pio_type, std::string name) {
	set_base_address(the_base_address);
	this->set_name(name);
	this->set_pio_type(pio_type);
}


Altera_PIO_Type altera_pio_encapsulator::get_pio_type() const
{
    return pio_type;
}

unsigned long altera_pio_encapsulator::get_base_address() const
{
    return base_address;
}

void altera_pio_encapsulator::write(unsigned long data)
{
	IOWR_32DIRECT(base_address,0,data);
}

unsigned long altera_pio_encapsulator::read()
{
	return IORD_32DIRECT(base_address,0);
}

void altera_pio_encapsulator::set_base_address(unsigned long  base_address)
{
    this->base_address = base_address;
}

void altera_pio_encapsulator::set_pio_type(Altera_PIO_Type pio_type)
{
    this->pio_type = pio_type;
}


void altera_pio_encapsulator::turn_on_bit(unsigned long bit){
	unsigned long  val;
	val = read();
	//safe_print(std::cout << std::hex << "read val = " << val << std::endl);
	val = val | (((unsigned long)1) << bit);
	//safe_print(std::cout << std::hex << "new val = " << val << " bit =  " << bit << " mask = " << (((unsigned long)1) << bit) << std::endl);
	write(val);
	//safe_print(std::cout << std::hex << "confirmed val = " << read() << std::endl);
};

void altera_pio_encapsulator::turn_off_bit(unsigned long bit){
	unsigned long  val;
	val = read();
   	val = val & (~(((unsigned long)1) << bit));
	write(val);
};

unsigned long altera_pio_encapsulator::get_bit(unsigned long bit){
	unsigned long  val;
	val = read();
	//std::cout << std::hex << "read val = " << val << std::endl;
	return ((val & (((unsigned long)1) << bit)) != 0);
}

unsigned long altera_pio_encapsulator::extract_bits(short lsb,short msb){
	unsigned long  val;
	val = read();
	val = val >> lsb;
	val = val & (~(0xFFFFFFFF << (msb - lsb + 1)));
	return val;
}
void altera_pio_encapsulator::set_bidir_pio_direction_input() {
    IOWR_ALTERA_AVALON_PIO_DIRECTION(base_address, ALTERA_AVALON_PIO_DIRECTION_INPUT);

}
void altera_pio_encapsulator::set_bidir_pio_direction_output() {
    IOWR_ALTERA_AVALON_PIO_DIRECTION(base_address, ALTERA_AVALON_PIO_DIRECTION_OUTPUT);

}

altera_pio_encapsulator::~altera_pio_encapsulator() {
	// TODO Auto-generated destructor stub
}
