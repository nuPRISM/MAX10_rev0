/*
 * descriptor_ram_encapsulator.cpp
 *
 *  Created on: May 28, 2015
 *      Author: yairlinn
 */

#include "altera_msgdma_descriptor_regs.h"
#include "altera_msgdma_csr_regs.h"
#include "altera_msgdma_response_regs.h"
#include "io.h"
#include "altera_msgdma.h"
#include "descriptor_ram_encapsulator.h"

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>

namespace descram {

descriptor_ram_encapsulator::descriptor_ram_encapsulator(unsigned long base_addr,
        unsigned long span,
        unsigned long base_address_for_relative_addresses,
        unsigned long per_descriptor_length_in_bytes) {


	this->set_base_addr(base_addr);
	this->set_span(span);
	this->set_base_address_for_relative_addresses(base_address_for_relative_addresses);
	this->set_per_descriptor_length_in_bytes(per_descriptor_length_in_bytes);
	this->set_num_descriptors(span/per_descriptor_length_in_bytes);

}

unsigned long descriptor_ram_encapsulator::get_descriptor_base(unsigned long desc_num) {
   return (this->get_base_addr() + (desc_num*this->get_per_descriptor_length_in_bytes()));
}

void descriptor_ram_encapsulator::write_descriptor(
		unsigned long descriptor_num,
		alt_msgdma_standard_descriptor* descriptor
)
{

	IOWR_ALTERA_MSGDMA_DESCRIPTOR_READ_ADDRESS(this->get_descriptor_base(descriptor_num),
			(alt_u32)descriptor->read_address);
	IOWR_ALTERA_MSGDMA_DESCRIPTOR_WRITE_ADDRESS(this->get_descriptor_base(descriptor_num),
			(	alt_u32)descriptor->write_address);
	IOWR_ALTERA_MSGDMA_DESCRIPTOR_LENGTH(this->get_descriptor_base(descriptor_num),
			descriptor->transfer_length);
	IOWR_ALTERA_MSGDMA_DESCRIPTOR_CONTROL_STANDARD(this->get_descriptor_base(descriptor_num),
			descriptor->control);

}

void descriptor_ram_encapsulator::construct_descriptor(
   		alt_u32 read_address,
   		alt_u32 write_address,
   		alt_u32 length_in_words,
   		alt_u32 control,
   		alt_msgdma_standard_descriptor* descriptor
   ) {
    descriptor->read_address = read_address;
    descriptor->write_address = write_address;
    descriptor->transfer_length = length_in_words*4;
    descriptor->control = control | ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GO_MASK;
}

int descriptor_ram_encapsulator::construct_and_write_descriptor(
		unsigned long descriptor_num,
		alt_u32 read_address,
		alt_u32 write_address,
		alt_u32 length_in_words,
		alt_u32 control) {
	if (descriptor_num >= this->get_num_descriptors()) {
            std::cout << "Error: [descriptor_ram_encapsulator::construct_and_write_descriptor]: descriptor num " << descriptor_num << " out of range!" << std::endl;
            return LINNUX_RETVAL_ERROR;
	}

	construct_descriptor(read_address, write_address, length_in_words, control, &work_descriptor);
	write_descriptor(descriptor_num,&work_descriptor);
	return LINNUX_RETVAL_TRUE;
}

int descriptor_ram_encapsulator::relative_construct_and_write_descriptor(
					unsigned long descriptor_num,
		    		alt_u32 read_address,
		    		alt_u32 write_address,
		    		alt_u32 length_in_words,
		    		alt_u32 control
		    ) {
	return this->construct_and_write_descriptor(descriptor_num,
		this->get_base_address_for_relative_addresses() + read_address,
		write_address,
		length_in_words,
		control);
}


descriptor_ram_encapsulator::~descriptor_ram_encapsulator() {};



} /* namespace descram */
