/*
 * memory_comm_encapsulator.h
 *
 *  Created on: Nov 19, 2011
 *      Author: user
 */

#ifndef GENERIC_MASTER_MEMORY_COMM_ENCAPSULATOR_H_
#define GENERIC_MASTER_MEMORY_COMM_ENCAPSULATOR_H_

#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <map>
#include <float.h>
#include <stdint.h>
#include <vector>
#include <unistd.h>
#include <time.h>
#include "basedef.h"
#include "my_usleep.h"

#ifndef GENERIC_MASTER_MEMORY_COMM_DEBUG
#define GENERIC_MASTER_MEMORY_COMM_DEBUG (0)
#endif

#define d_dm(x) do {			\
		if (GENERIC_MASTER_MEMORY_COMM_DEBUG) {std::cout << " File: " << __FILE__ << " Line: " << __LINE__ << " Func: " << __func__ << std::endl; x;\
		std::cout.flush();}\
} while (0)

class generic_master_memory_comm_encapsulator {
protected:
	uint32_t command_counter;
	uint32_t response_str_32bit_offset;
	uint32_t command_request_32bit_offset;
	uint32_t command_ready_32bit_offset;
	uint32_t command_length_offset;
	//   uint32_t slave_alive_32bit_offset;
	uint32_t SLAVE_MEMORY_COMM_REGION_BASE;
	uint32_t SLAVE_MEMORY_COMM_region_base_offset;
	//uint32_t alive_magic_word;
	long         max_wait_time_for_response_in_secs;
	uint32_t max_response_str_length_in_32bit_words;
	uint32_t (*read_ram)(uint32_t address);
	void (*write_ram)(uint32_t address, uint32_t data);
	std::string (*block_read_ram_str)(uint32_t address, uint32_t length);
	void (*block_write_ram)(uint32_t address, std::string data);
	bool use_blt_for_response_reads;
	bool use_blt_for_command_writes;
	unsigned int generic_master_polling_interval_us;
    unsigned int generic_master_address_increment_per_word;
	virtual void write_to_generic_master_ram(uint32_t offset, uint32_t data);
	virtual uint32_t read_from_generic_master_ram(uint32_t  offset);
	virtual void print_str_to_generic_master_ram(std::string the_str, uint32_t  offset);
	virtual std::string get_str_from_generic_master_ram(uint32_t  offset);
	virtual std::string get_str_from_generic_master_ram(uint32_t  offset, uint32_t len);
	virtual std::string blt_get_str_from_generic_master_ram(uint32_t  offset, uint32_t len);


public:
	generic_master_memory_comm_encapsulator(
			uint32_t  the_SLAVE_MEMORY_COMM_region_base_offset,
			//uint32_t  the_alive_magic_word,
			uint32_t  the_max_response_str_length_in_words,
			long  the_max_allowed_response_wait_in_secs,
			uint32_t (*read_ram_func)(uint32_t),
		    void (*write_ram_func)(uint32_t, uint32_t),
			std::string (*block_read_ram_str_func)(uint32_t, uint32_t ),
			unsigned int generic_master_polling_interval_us,
		    unsigned int generic_master_address_increment_per_word
	);

	virtual uint32_t get_command_counter();
	virtual void set_command_counter(uint32_t  x);
	virtual void set_command_only(std::string the_command);
	virtual std::string get_command_only();
	virtual std::string get_command_only(uint32_t  len);
	virtual uint32_t get_mem_comm_ready_semaphore();
	virtual uint32_t get_mem_comm_request_semaphore();
	virtual void set_command(std::string the_command);
	virtual int get_command_response(std::string& command_str);
	virtual void set_command_response(std::string the_response, std::vector<uint32_t > *binary_response);
	virtual std::string get_new_command();
	virtual long get_max_wait_time_for_response_in_secs() const;
	virtual void set_max_wait_time_for_response_in_secs(long  max_wait_time_for_response_in_secs);
	virtual uint32_t get_max_response_str_length_in_32bit_words() const;
	virtual void set_max_response_str_length_in_32bit_words(uint32_t  max_response_str_length_in_32bit_words);

	bool isUseBltForCommandWrites() const {
		return use_blt_for_command_writes;
	}

	void setUseBltForCommandWrites(bool useBltForCommandWrites) {
		use_blt_for_command_writes = useBltForCommandWrites;
	}

	bool isUseBltForResponseReads() const {
		return use_blt_for_response_reads;
	}

	void setUseBltForResponseReads(bool useBltForResponseReads) {
		use_blt_for_response_reads = useBltForResponseReads;
	}

	unsigned int getGenericMasterAddressIncrementPerWord() const
	{
		return generic_master_address_increment_per_word;
	}

	void setGenericMasterAddressIncrementPerWord(unsigned int genericMasterAddressIncrementPerWord)
	{
		generic_master_address_increment_per_word = genericMasterAddressIncrementPerWord;
	}

	unsigned int getGenericMasterPollingIntervalUs() const
	{
		return generic_master_polling_interval_us;
	}

	void setGenericMasterPollingIntervalUs(unsigned int genericMasterPollingIntervalUs)
	{
		generic_master_polling_interval_us = genericMasterPollingIntervalUs;
	}
};


#endif /* MEMORY_COMM_ENCAPSULATOR_H_ */

