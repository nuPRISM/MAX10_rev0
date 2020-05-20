/*
 * memory_comm_encapsulator.cpp
 *
 *  Created on: Nov 19, 2011
 *      Author: user
 */

#include "generic_master_memory_comm_encapsulator.h"
#include <stdio.h>
#include <time.h>

#define SLAVE_MEMORY_COMM_OFFSET_COMMAND_COUNTER_OFFSET               ( 0)
#define SLAVE_MEMORY_COMM_OFFSET_COMMAND_LENGTH_OFFSET                ( 4)
#define SLAVE_MEMORY_COMM_OFFSET_COMMAND_REQUEST_OFFSET               ( 8)
#define SLAVE_MEMORY_COMM_OFFSET_COMMAND_READY_OFFSET                 (12)
#define SLAVE_MEMORY_COMM_OFFSET_SLAVE_ALIVE_OFFSET                   (16)
#define SLAVE_MEMORY_COMM_OFFSET_START_OF_RESPONSE_STR                (20)
#define SLAVE_MEMORY_COMM_OFFSET_BINARY_COMMAND_RESPONSE_OFFSET       (20)

	generic_master_memory_comm_encapsulator::generic_master_memory_comm_encapsulator(
			uint32_t  the_SLAVE_MEMORY_COMM_region_base_offset,
			//uint32_t  the_alive_magic_word,
			uint32_t  the_max_response_str_length_in_words,
			long  the_max_allowed_response_wait_in_secs,
			uint32_t (*read_ram_func)(uint32_t),
		    void (*write_ram_func)(uint32_t, uint32_t),
			std::string (*block_read_ram_str_func)(uint32_t, uint32_t ),
    		unsigned int generic_master_polling_interval_us,
    		unsigned int generic_master_address_increment_per_word
			)
{
		//this->set_alive_magic_word(the_alive_magic_word);
		use_blt_for_response_reads = false;
		use_blt_for_command_writes = false;
		this->block_read_ram_str = block_read_ram_str_func;
		this->write_ram=write_ram_func;
		this->read_ram=read_ram_func;
		this->set_max_wait_time_for_response_in_secs(the_max_allowed_response_wait_in_secs);
		this->set_max_response_str_length_in_32bit_words(the_max_response_str_length_in_words);
		SLAVE_MEMORY_COMM_region_base_offset = the_SLAVE_MEMORY_COMM_region_base_offset;
		set_command_counter(0);
		response_str_32bit_offset = (SLAVE_MEMORY_COMM_region_base_offset + SLAVE_MEMORY_COMM_OFFSET_START_OF_RESPONSE_STR);
		command_request_32bit_offset = (SLAVE_MEMORY_COMM_region_base_offset + SLAVE_MEMORY_COMM_OFFSET_COMMAND_REQUEST_OFFSET);
		command_ready_32bit_offset = (SLAVE_MEMORY_COMM_region_base_offset + SLAVE_MEMORY_COMM_OFFSET_COMMAND_READY_OFFSET);
		command_length_offset = (SLAVE_MEMORY_COMM_region_base_offset + SLAVE_MEMORY_COMM_OFFSET_COMMAND_LENGTH_OFFSET);
		this->generic_master_polling_interval_us = generic_master_polling_interval_us;
        this->generic_master_address_increment_per_word = generic_master_address_increment_per_word;





		//      slave_alive_32bit_offset = (SLAVE_MEMORY_COMM_region_base_offset + SLAVE_MEMORY_COMM_OFFSET_SLAVE_ALIVE_OFFSET);
		// write_to_generic_master_ram(command_request_32bit_offset, 0);
		//  write_to_generic_master_ram(command_ready_32bit_offset, 1);
}

	uint32_t generic_master_memory_comm_encapsulator::get_command_counter()
	{
		return command_counter;
	}

	void generic_master_memory_comm_encapsulator::set_command_counter(uint32_t  x)
	{
		command_counter = x;
	}

	void generic_master_memory_comm_encapsulator::set_command_only(std::string the_command)
	{
		print_str_to_generic_master_ram(the_command, response_str_32bit_offset);
		d_dm(std::cout << "Set command string to: [" << the_command << "]";);
	}

	std::string generic_master_memory_comm_encapsulator::get_command_only()
	{
		return (get_str_from_generic_master_ram(response_str_32bit_offset));
	}

	std::string generic_master_memory_comm_encapsulator::get_command_only(uint32_t  len)
	{
		return (get_str_from_generic_master_ram(response_str_32bit_offset,len));
	}

	uint32_t generic_master_memory_comm_encapsulator::get_mem_comm_ready_semaphore() {
		uint32_t val = read_from_generic_master_ram(command_ready_32bit_offset);
		d_dm(printf("get_sdr_ready_semaphore = %u",val));
		return val;
	}

	uint32_t generic_master_memory_comm_encapsulator::get_mem_comm_request_semaphore() {
		uint32_t val = read_from_generic_master_ram(command_request_32bit_offset);
		d_dm(printf("get_sdr_request_semaphore = %u",val));
		return val;
	}

	void generic_master_memory_comm_encapsulator::set_command(std::string the_command)
	{
		std::string outstr;
		while (!get_mem_comm_ready_semaphore()) {
			my_usleep(this->getGenericMasterPollingIntervalUs());
		}

		print_str_to_generic_master_ram(the_command, response_str_32bit_offset);

		d_dm(
		    outstr = get_str_from_generic_master_ram(response_str_32bit_offset,the_command.length());
		    std::cout << "wrote command: " << outstr << std::endl;
		);

		write_to_generic_master_ram(command_ready_32bit_offset, 0);
		write_to_generic_master_ram(command_request_32bit_offset, 1);

		d_dm(
				uint32_t tmp1=read_from_generic_master_ram(command_ready_32bit_offset);
		        uint32_t tmp2=read_from_generic_master_ram(command_request_32bit_offset);
		        std::cout << "command_ready: " << tmp1 << " Command request:" << tmp2 << std::endl;
		);

	}

	int generic_master_memory_comm_encapsulator::get_command_response(std::string& command_str)
	{
		/*
	uint32_t start_time = os_critical_low_level_system_timestamp_in_secs();
        uint32_t end_time = start_time;
        uint32_t time_diff = 0;
		 */

		/*  if (!this->is_alive()) {
			 std::cout << "[generic_master_memory_comm_encapsulator.get_command_response()]Error: slave device is not alive! " << std::endl;
			 return 0;
		}
		 */
		while (!get_mem_comm_ready_semaphore()) {
			my_usleep(this->getGenericMasterPollingIntervalUs());
			/*
	         end_time = os_critical_low_level_system_timestamp_in_secs();
        	 if (end_time < start_time) {end_time = start_time;};
        	 time_diff = end_time-start_time;
        			 if((this->get_max_wait_time_for_response_in_secs() > 0) && (time_diff > this->get_max_wait_time_for_response_in_secs())) {
                             std::cout << "[generic_master_memory_comm_encapsulator.get_command_response()]Error: Time diff is:" << time_diff << " Secs. Watchdog limit is: " << this->get_max_wait_time_for_response_in_secs() << " Secs. Aborting" << std::endl;
                             command_str = "";
                             return 0;

        			 }
			 */
		}
		command_str = get_str_from_generic_master_ram(response_str_32bit_offset);
		return (1);
	}

	void generic_master_memory_comm_encapsulator::set_command_response(std::string the_response, std::vector<uint32_t > *binary_response)
	{
		std::cout << "set_command_response is not defined " << std::endl;
	}

	std::string generic_master_memory_comm_encapsulator::get_new_command()
	{
		std::string retstr;
		std::cout << "generic_master_memory_comm_encapsulator::get_new_command is not defined!\n";
		return retstr;
	}

	/* uint32_t get_alive_magic_word() const
    {
        return alive_magic_word;
    }
	 */
	long generic_master_memory_comm_encapsulator::get_max_wait_time_for_response_in_secs() const
	{
		return max_wait_time_for_response_in_secs;
	}
	/*
    void set_alive_magic_word(uint32_t  alive_magic_word)
    {
        this->alive_magic_word = alive_magic_word;
    }
	 */
	void generic_master_memory_comm_encapsulator::set_max_wait_time_for_response_in_secs(long  max_wait_time_for_response_in_secs)
	{
		this->max_wait_time_for_response_in_secs = max_wait_time_for_response_in_secs;
	}

    void generic_master_memory_comm_encapsulator::write_to_generic_master_ram(uint32_t offset, uint32_t data)
	{
		write_ram(offset, data);
	}

	uint32_t generic_master_memory_comm_encapsulator::read_from_generic_master_ram(uint32_t  offset)
	{
		uint32_t val;
		d_dm(printf("[read_from_generic_master_ram]Reading from offset: %x\n",offset););
		val = read_ram(offset);
		d_dm(printf("[read_from_generic_master_ram]Reading from offset: %x value of: %x\n",offset, val););
		return (val);
	}

	void generic_master_memory_comm_encapsulator::print_str_to_generic_master_ram(std::string the_str, uint32_t  offset)
	{
		std::size_t i;
		uint32_t verify_read;
		uint32_t val_to_write;
		uint32_t current_offset = offset;
		uint32_t len = the_str.length();
		if (len%4 != 0) {
			the_str.append((4-len%4),'\0');
		}
		len = the_str.length(); //let's try this again
		for (i = 0; (i+3) < len; i+=4)
		{
			val_to_write = (((uint32_t) the_str.at(i+3)) << 24) + (((uint32_t) the_str.at(i+2)) << 16) + (((uint32_t) the_str.at(i+1)) << 8) + ((uint32_t) the_str.at(i));
			write_to_generic_master_ram(current_offset,val_to_write);
			d_dm(   std::cout << "[print_str_to_generic_master_ram] Wrote val: " << val_to_write << " to address: [" << current_offset << "] " << std::endl;
			d_dm(
			   verify_read = read_from_generic_master_ram(current_offset);
			   std::cout << "[print_str_to_generic_master_ram] verify_read: " << verify_read << std::endl;);
			);
			current_offset += this->getGenericMasterAddressIncrementPerWord();
		}
		val_to_write = 0;
		write_to_generic_master_ram(current_offset, val_to_write);
		d_dm(std::cout << "[print_str_to_generic_master_ram] Wrote val: " << val_to_write << " to address: [" << current_offset << "] " << std::endl;
		d_dm(
				verify_read = read_from_generic_master_ram(current_offset);
		        std::cout << "[print_str_to_generic_master_ram] verify_read: " << verify_read << std::endl;);
		);

	}

	std::string generic_master_memory_comm_encapsulator::blt_get_str_from_generic_master_ram(uint32_t offset, uint32_t len) {
		return block_read_ram_str(offset,len);
	}


	std::string generic_master_memory_comm_encapsulator::get_str_from_generic_master_ram(uint32_t  offset)
	{
		std::string retstr = "";
		uint32_t c1, c2, c3, c4;
		uint32_t val;
		uint32_t current_offset = offset;
		uint32_t expected_command_length;
		expected_command_length = read_from_generic_master_ram(command_length_offset);
		d_dm(printf("[get_str_from_generic_master_ram] expected command length is: %x from addr %x\n",expected_command_length,command_length_offset));

		if (this->isUseBltForResponseReads()) {
			retstr = blt_get_str_from_generic_master_ram(offset, expected_command_length);
			//std::cout << "[get_str_from_generic_master_ram]retstr (via blt) =" << retstr << " Expected length: " << expected_command_length << " Actual Length: " << retstr.length() << std::endl;
		} else {
				while (retstr.length() < expected_command_length)
				{
					val = read_from_generic_master_ram(current_offset);
					d_dm(printf("[get_str_from_generic_master_ram] read value of %x from addr %x\n",val,current_offset););
					if ((c1 = (val & 0xFF)) != 0) retstr.push_back      ((char)(c1 & 0xff));
					if ((retstr.length() < expected_command_length)) {
						if ((c2 = (val & 0xFF00)) != 0) retstr.push_back    ((char)((c2 >> 8) & 0xff));
					}
					if ((retstr.length() < expected_command_length)) {
						if ((c3 = (val & 0xFF0000)) != 0) retstr.push_back  ((char)((c3 >> 16) & 0xff));
					}
					if ((retstr.length() < expected_command_length)) {
						if ((c4 = (val & 0xFF000000)) != 0) retstr.push_back((char)((c4 >> 24) & 0xff));
					}
					d_dm(printf("[get_str_from_generic_master_ram]c1 = %x cc1 = %c c2 = %x cc2 = %c c3 = %x cc3 = %c c4 = %x cc4 = %c\n",c1,(char)c1,c2,(char)((c2>>8) & 0xff),c3,(char)((c3>>16)& 0xff),c4,(char)((c4>>24) & 0xff)););
					current_offset += this->getGenericMasterAddressIncrementPerWord();
				}
				d_dm(std::cout << "[get_str_from_generic_master_ram]retstr =" << retstr << std::endl;);
				d_dm(std::cout << "[get_str_from_generic_master_ram] check via blt_get_str_from_generic_master_ram: " << blt_get_str_from_generic_master_ram(offset, expected_command_length) << std::endl);
		}
		return retstr;
	}

	std::string generic_master_memory_comm_encapsulator::get_str_from_generic_master_ram(uint32_t  offset, uint32_t len)
	{
		std::string retstr = "";
		uint32_t c1, c2, c3, c4;
		uint32_t val;
		uint32_t current_offset = offset;
		while (retstr.length() < len)
		{
			val = read_from_generic_master_ram(current_offset);
			d_dm(printf("[get_str_from_generic_master_ram] read value of %x from addr %x\n",val,current_offset););
			if ((c1 = (val & 0xFF)) != 0) retstr.push_back      ((char)(c1 & 0xff));
			if ((retstr.length() < len)) {
				if ((c2 = (val & 0xFF00)) != 0) retstr.push_back    ((char)((c2 >> 8) & 0xff));
			}
			if ((retstr.length() < len)) {
				if ((c3 = (val & 0xFF0000)) != 0) retstr.push_back  ((char)((c3 >> 16) & 0xff));
			}
			if ((retstr.length() < len)) {
				if ((c4 = (val & 0xFF000000)) != 0) retstr.push_back((char)((c4 >> 24) & 0xff));
			}
			d_dm(printf("[get_str_from_generic_master_ram]c1 = %x cc1 = %c c2 = %x cc2 = %c c3 = %x cc3 = %c c4 = %x cc4 = %c\n",c1,(char)c1,c2,(char)((c2>>8) & 0xff),c3,(char)((c3>>16)& 0xff),c4,(char)((c4>>24) & 0xff)););
			current_offset += this->getGenericMasterAddressIncrementPerWord();
		}
		d_dm(
			  std::cout << "[get_str_from_generic_master_ram]retstr =" << retstr << std::endl;
		);
		return retstr;
	}

uint32_t generic_master_memory_comm_encapsulator::get_max_response_str_length_in_32bit_words() const
{
    return max_response_str_length_in_32bit_words;
}

void generic_master_memory_comm_encapsulator::set_max_response_str_length_in_32bit_words(uint32_t  max_response_str_length_in_32bit_words)
{
    this->max_response_str_length_in_32bit_words = max_response_str_length_in_32bit_words;
}




