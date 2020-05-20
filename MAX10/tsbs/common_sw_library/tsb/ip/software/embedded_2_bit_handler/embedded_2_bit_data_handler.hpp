/*
 * embedded_2_bit_data_handler.hpp
 *
 *  Created on: Mar 9, 2019
 *      Author: user
 */

#ifndef EMBEDDED_2_BIT_DATA_HANDLER_H_
#define EMBEDDED_2_BIT_DATA_HANDLER_H_
#include  <stdint.h>
#include  <stdio.h>

#ifndef DEBUG_E2BH
#define DEBUG_E2BH (0)
#endif

#define d_e2bh(x) do { if (DEBUG_E2BH) { x; } } while (0)

namespace e2bh {
const uint32_t DELIMITER_BIT_MASK = 0x1;
const uint32_t DATA_BIT_MASK = 0x2;

template <class sample_data_type>
class embedded_2_bit_data_handler {
protected:
	uint32_t num_samples_per_data;
	uint32_t find_start_of_packet(sample_data_type* memptr, uint32_t start_offset, uint32_t memsize);
public:
	embedded_2_bit_data_handler(uint32_t num_samples_per_data);
    uint32_t extract_embedded_bytes(sample_data_type* memptr, uint32_t start_offset, uint32_t memsize, uint8_t extracted_bytes[]);
	virtual ~embedded_2_bit_data_handler();

	uint32_t get_num_samples_per_data() const {
		return num_samples_per_data;
	}

	void set_num_samples_per_data(uint32_t numSamplesPerData) {
		num_samples_per_data = numSamplesPerData;
	}
};

template <class sample_data_type>
embedded_2_bit_data_handler<sample_data_type>::embedded_2_bit_data_handler(uint32_t num_samples_per_data) {
	this->num_samples_per_data = num_samples_per_data;
}

template <class sample_data_type>
embedded_2_bit_data_handler<sample_data_type>::~embedded_2_bit_data_handler() {
	// TODO Auto-generated destructor stub
}



template <class sample_data_type>
uint32_t embedded_2_bit_data_handler<sample_data_type>::find_start_of_packet(sample_data_type* memptr, uint32_t start_offset, uint32_t memsize) {
	uint32_t i = start_offset;
	do {
		if (memptr[i] & DELIMITER_BIT_MASK) {
			break;
		}
		i++;
	} while (i < memsize);
	d_e2bh(std::cout << "find_start_of_packet returning  " << i << std::endl);
	return i;
}

template <class sample_data_type>
uint32_t embedded_2_bit_data_handler<sample_data_type>::extract_embedded_bytes(sample_data_type* memptr, uint32_t start_offset, uint32_t memsize, uint8_t extracted_bytes[]) {
	uint32_t current_offset = 0;
	uint32_t current_byte_count = 0;
	uint32_t sample_count = 0;
	uint32_t current_bit_offset = 0;
	current_offset = find_start_of_packet(memptr, start_offset, memsize);

	if (current_offset >= memsize) {
			return current_offset;
	}

	do {
		uint8_t current_byte = 0;
		uint8_t bit_count = 0;
		do {
			current_bit_offset = current_offset + sample_count;
			if (current_bit_offset >= memsize) {
				d_e2bh(std::cout << "out of bounds  current_bit_offset =  " << current_bit_offset  << std::endl);

				return memsize;
			}
			current_byte = (current_byte << 1) + (((memptr[current_bit_offset] & DATA_BIT_MASK) != 0) ? 1 : 0);
			bit_count++;
			sample_count++;
		} while ((current_offset < memsize) && (bit_count < 8) && (sample_count < this->get_num_samples_per_data()));
		extracted_bytes[current_byte_count] = current_byte;
		d_e2bh(std::cout << "extracted_bytes  = " << current_byte_count << " current_byte = 0x" << std::hex << (unsigned int) current_byte << std::dec <<  " sample_count = " << sample_count << " bit_count = " <<  (unsigned int) bit_count << std::endl);
		current_byte_count++;
	} while ((current_offset + sample_count < memsize)  && (sample_count < this->get_num_samples_per_data()));
	return (current_offset + sample_count);
}


} /* namespace e2bh */

#endif /* EMBEDDED_2_BIT_DATA_HANDLER_H_ */
