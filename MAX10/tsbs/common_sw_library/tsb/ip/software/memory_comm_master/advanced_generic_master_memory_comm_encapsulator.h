/*
 * memory_comm_encapsulator.h
 *
 *  Created on: Nov 19, 2011
 *      Author: user
 */

#ifndef ADVANCED_GENERIC_MASTER_MEMORY_COMM_ENCAPSULATOR_H_
#define ADVANCED_GENERIC_MASTER_MEMORY_COMM_ENCAPSULATOR_H_

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
#include <math.h>
#include <sstream>
#include "generic_master_memory_comm_encapsulator.h"

#ifndef ADVANCED_GENERIC_MASTER_MEMORY_COMM_DEBUG
#define ADVANCED_GENERIC_MASTER_MEMORY_COMM_DEBUG (0)
#endif

#define debug_adv_mem_comm(x) do {			\
		if (ADVANCED_GENERIC_MASTER_MEMORY_COMM_DEBUG) {std::cout << " File: " << __FILE__ << " Line: " << __LINE__ << " Func: " << __func__ << std::endl; x;\
		std::cout.flush();}\
} while (0)
class advanced_generic_master_memory_comm_encapsulator : public generic_master_memory_comm_encapsulator {
public:

	advanced_generic_master_memory_comm_encapsulator(
			uint32_t  the_SLAVE_MEMORY_COMM_region_base_offset,
			uint32_t  the_max_response_str_length_in_words,
			long  the_max_allowed_response_wait_in_secs,
			uint32_t (*read_ram_func)(uint32_t),
			void (*write_ram_func)(uint32_t, uint32_t),
			std::string (*block_read_ram_str_func)(uint32_t, uint32_t ),
			unsigned int generic_master_polling_interval_us,
			unsigned int generic_master_address_increment_per_word

	) :
				generic_master_memory_comm_encapsulator(
						the_SLAVE_MEMORY_COMM_region_base_offset,
						the_max_response_str_length_in_words,
						the_max_allowed_response_wait_in_secs,
						read_ram_func,
						write_ram_func,
						block_read_ram_str_func,
						generic_master_polling_interval_us,
						generic_master_address_increment_per_word
						) {};
	virtual int get_command_response(std::string& command_str);

};


#endif /* ADVANCED_MEMORY_COMM_ENCAPSULATOR_H_ */
