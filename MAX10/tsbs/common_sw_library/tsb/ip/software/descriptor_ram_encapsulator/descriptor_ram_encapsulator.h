/*
 * descriptor_ram_encapsulator.h
 *
 *  Created on: May 28, 2015
 *      Author: yairlinn
 */

#ifndef DESCRIPTOR_RAM_ENCAPSULATOR_H_
#define DESCRIPTOR_RAM_ENCAPSULATOR_H_
#include "basedef.h"
#include "altera_msgdma_descriptor_regs.h"
#include "altera_msgdma_csr_regs.h"
#include "altera_msgdma_response_regs.h"
#include "io.h"
#include "altera_msgdma.h"
#include "priv/alt_busy_sleep.h"
#include "sys/alt_errno.h"
#include "sys/alt_irq.h"
#include "sys/alt_stdio.h"
#include <string>

namespace descram {

class descriptor_ram_encapsulator {
protected:
	alt_msgdma_standard_descriptor work_descriptor;
	unsigned long base_address_for_relative_addresses;

	unsigned long base_addr, span,  num_descriptors;
	unsigned long per_descriptor_length_in_bytes;
	unsigned long get_descriptor_base(unsigned long desc_num);
	void write_descriptor(
		unsigned long descriptor_num,
		alt_msgdma_standard_descriptor* descriptor
		);
    void construct_descriptor(
    		alt_u32 read_address,
    		alt_u32 write_address,
    		alt_u32 length_in_words,
    		alt_u32 control,
       		alt_msgdma_standard_descriptor* descriptor

    );



public:
	descriptor_ram_encapsulator(unsigned long base_addr,
			                    unsigned long span,
			                    unsigned long base_address_for_relative_addresses,
			                    unsigned long per_descriptor_length_in_bytes = 16);

	 int construct_and_write_descriptor(
				unsigned long descriptor_num,
	    		alt_u32 read_address,
	    		alt_u32 write_address,
	    		alt_u32 length_in_words,
	    		alt_u32 control
	    );

	 int relative_construct_and_write_descriptor(
					unsigned long descriptor_num,
		    		alt_u32 read_address,
		    		alt_u32 write_address,
		    		alt_u32 length_in_words,
		    		alt_u32 control
		    );
	virtual ~descriptor_ram_encapsulator();

	unsigned long get_base_addr() const {
		return base_addr;
	}

	void set_base_addr(unsigned long baseAddr) {
		base_addr = baseAddr;
	}

	unsigned long get_num_descriptors() const {
		return num_descriptors;
	}

	void set_num_descriptors(unsigned long numDescriptors) {
		num_descriptors = numDescriptors;
	}

	unsigned long get_span() const {
		return span;
	}

	void set_span(unsigned long span) {
		this->span = span;
	}

	unsigned long get_per_descriptor_length_in_bytes() const {
		return per_descriptor_length_in_bytes;
	}

	void set_per_descriptor_length_in_bytes(
			unsigned long perDescriptorLengthInBytes) {
		per_descriptor_length_in_bytes = perDescriptorLengthInBytes;
	}

	unsigned long get_base_address_for_relative_addresses() const {
		return base_address_for_relative_addresses;
	}

	void set_base_address_for_relative_addresses(
			unsigned long baseAddressForRelativeAddresses) {
		base_address_for_relative_addresses = baseAddressForRelativeAddresses;
	}
};

} /* namespace descram */

#endif /* DESCRIPTOR_RAM_ENCAPSULATOR_H_ */
