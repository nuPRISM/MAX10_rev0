/*
 * memory_comm_encapsulator.h
 *
 *  Created on: Nov 19, 2011
 *      Author: user
 */

#ifndef DUAL_PORT_MEMORY_COMM_ENCAPSULATOR_H_
#define DUAL_PORT_MEMORY_COMM_ENCAPSULATOR_H_

#include "system.h"
#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <map>
#include <float.h>
#include <vector>
#include <unistd.h>
#include <time.h>
#include "basedef.h"
#include "linnux_utils.h"
#include "dual_port_ram_container.h"
#include "global_stream_defs.hpp"
#define d_dm(x) do {			\
                    if (dual_port_ram_container_DEBUG) {safe_print(std::cout << " File: " << __FILE__ << " Line: " << __LINE__ << " Func: " << __func__ << std::endl); x;}\
                } while (0)

#define SLAVE_MEMORY_COMM_OFFSET_COMMAND_COUNTER_OFFSET                0
#define SLAVE_MEMORY_COMM_OFFSET_COMMAND_LENGTH_OFFSET                 4
#define SLAVE_MEMORY_COMM_OFFSET_COMMAND_REQUEST_OFFSET                8
#define SLAVE_MEMORY_COMM_OFFSET_COMMAND_READY_OFFSET                 12
#define SLAVE_MEMORY_COMM_OFFSET_SLAVE_ALIVE_OFFSET                   16
#define SLAVE_MEMORY_COMM_OFFSET_START_OF_RESPONSE_STR                20
#define SLAVE_MEMORY_COMM_OFFSET_BINARY_COMMAND_RESPONSE_OFFSET       20

class dual_port_memory_comm_encapsulator {
protected:
	   unsigned long command_counter;
       unsigned long response_str_32bit_offset;
       unsigned long command_request_32bit_offset;
       unsigned long command_ready_32bit_offset;
       unsigned long slave_alive_32bit_offset;
       dual_port_ram_container *dut_gp_ram_ptr;
	   unsigned long SLAVE_MEMORY_COMM_REGION_BASE;
	   unsigned long SLAVE_MEMORY_COMM_region_base_offset;
	   unsigned long alive_magic_word;
	   long         max_wait_time_for_response_in_secs;
       unsigned long max_response_str_length_in_32bit_words;

	   void write_to_dut_gp_ram(unsigned long offset, unsigned long data)
	   {
        dut_gp_ram_ptr->write_ram(offset, data);
    }

    unsigned long read_from_dut_gp_ram(unsigned long  offset)
    {
        unsigned long val;
        d_dm(safe_print(printf("[read_from_dut_gp_ram]Reading from offset: %lx\n",offset);));
        val = dut_gp_ram_ptr->read_ram(offset);
        d_dm(safe_print(printf("[read_from_dut_gp_ram]Reading from offset: %lx value of: %lx\n",offset, val);));
        return (val);
    }

    void print_str_to_gp_ram(std::string & the_str, unsigned long  offset)
    {
        std::size_t i;
        unsigned long val_to_write;
        unsigned long current_offset = offset;
        unsigned long len = the_str.length();
        for (i = 0; (i+3) < len; i+=4)
	   	{
	   		val_to_write = (((unsigned long) the_str.at(i+3)) << 24) + (((unsigned long) the_str.at(i+2)) << 16) + (((unsigned long) the_str.at(i+1)) << 8) + ((unsigned long) the_str.at(i));
	   		write_to_dut_gp_ram(current_offset,val_to_write);
	   		d_dm(safe_print(std::cout << "[print_str_to_gp_ram] Wrote val: " << val_to_write << " to address: [" << current_offset << "] " << std::endl;));
	   		current_offset += 1;
	   	}
        val_to_write = 0;
        if(i != len){
            val_to_write = (((i + 3) < len) ? (((unsigned long )((the_str.at(i + 3)))) << 24) : 0) + (((i + 2) < len) ? (((unsigned long )((the_str.at(i + 2)))) << 16) : 0) + (((i + 1) < len) ? (((unsigned long )((the_str.at(i + 1)))) << 8) : 0) + (((i) < len) ? (((unsigned long )((the_str.at(i))))) : 0);
        }
        write_to_dut_gp_ram(current_offset, val_to_write);
        d_dm(safe_print(std::cout << "[print_str_to_gp_ram] Wrote val: " << val_to_write << " to address: [" << current_offset << "] " << std::endl;));
    }

    std::string get_str_from_gp_ram(unsigned long  offset)
    {
        std::string retstr = "";
        unsigned long c1, c2, c3, c4;
        unsigned long val;
        unsigned long current_offset = offset;
        unsigned long max_str_length = this->get_max_response_str_length_in_32bit_words() * 4;
        do  {

	   		val = read_from_dut_gp_ram(current_offset);
	   		d_dm(safe_print(printf("[get_str_from_gp_ram] read value of %lx from addr %lx\n",val,current_offset);));
	   		if ((c1 = (val & 0xFF)) != 0) retstr.push_back      ((char)(c1 & 0xff));
	   		if ((c2 = (val & 0xFF00)) != 0) retstr.push_back    ((char)((c2 >> 8) & 0xff));
	   		if ((c3 = (val & 0xFF0000)) != 0) retstr.push_back  ((char)((c3 >> 16) & 0xff));
	   		if ((c4 = (val & 0xFF000000)) != 0) retstr.push_back((char)((c4 >> 24) & 0xff));
	   		d_dm(safe_print(printf("[get_str_from_gp_ram]c1 = %lx cc1 = %c c2 = %lx cc2 = %c c3 = %lx cc3 = %c c4 = %lx cc4 = %c\n",c1,(char)c1,c2,(char)((c2>>8) & 0xff),c3,(char)((c3>>16)& 0xff),c4,(char)((c4>>24) & 0xff));));
	   		current_offset++;
	   	} while ((retstr.length() < max_str_length) && !((c1 == 0) || (c2 == 0) || (c3 == 0) || (c4 == 0)));
        d_dm(safe_print(std::cout << "[get_str_from_gp_ram]retstr =" << retstr << std::endl));
        return retstr;
    }

    void sprintf_to_ram(std::string str, char *addr, unsigned int maxlen)
    {
        unsigned int i = 0;
        while((i < str.length()) && (i < (maxlen - 1))){
            addr[i] = str.at(i);
            i++;
        }
        addr[i] = '\0';
    }

    std::string sscanf_from_ram(char *addr, int maxlen)
    {
        int i;
        i = 0;
        std::string retstr;
        while((i < maxlen) && (addr[i] != '\0')){
            retstr.push_back(addr[i]);
            i++;
        }
        return retstr;
    }

public:
    dual_port_memory_comm_encapsulator(dual_port_ram_container *the_dut_gp_ram_ptr,
    		unsigned long  the_SLAVE_MEMORY_COMM_region_base_offset,
    		unsigned long  the_alive_magic_word,
    		unsigned long  the_max_response_str_length_in_words,
    		long  the_max_allowed_response_wait_in_secs)
    {
        this->set_alive_magic_word(the_alive_magic_word);
        this->set_max_wait_time_for_response_in_secs(the_max_allowed_response_wait_in_secs);
        this->set_max_response_str_length_in_32bit_words(the_max_response_str_length_in_words);
        SLAVE_MEMORY_COMM_region_base_offset = the_SLAVE_MEMORY_COMM_region_base_offset;
        dut_gp_ram_ptr = the_dut_gp_ram_ptr;
        SLAVE_MEMORY_COMM_REGION_BASE = dut_gp_ram_ptr->get_ram_base_address() + SLAVE_MEMORY_COMM_REGION_BASE_OFFSET;
        set_command_counter(0);
        response_str_32bit_offset = (SLAVE_MEMORY_COMM_region_base_offset + SLAVE_MEMORY_COMM_OFFSET_START_OF_RESPONSE_STR)>>2;
        command_request_32bit_offset = (SLAVE_MEMORY_COMM_region_base_offset + SLAVE_MEMORY_COMM_OFFSET_COMMAND_REQUEST_OFFSET) >> 2;
        command_ready_32bit_offset = (SLAVE_MEMORY_COMM_region_base_offset + SLAVE_MEMORY_COMM_OFFSET_COMMAND_READY_OFFSET) >> 2;
        slave_alive_32bit_offset = (SLAVE_MEMORY_COMM_region_base_offset + SLAVE_MEMORY_COMM_OFFSET_SLAVE_ALIVE_OFFSET) >> 2;
        write_to_dut_gp_ram(command_request_32bit_offset, 0);
        write_to_dut_gp_ram(command_ready_32bit_offset, 1);
    }

    int is_alive()
    {
        unsigned long val = read_from_dut_gp_ram(slave_alive_32bit_offset);
        d_dm(safe_print(std::cout << "dual_port_memory_comm_encapsulator::is_alive read: " << val;));
        return (val == this->get_alive_magic_word());
    }

    unsigned long get_command_counter()
    {
        return command_counter;
    }

    void set_command_counter(unsigned long  x)
    {
        command_counter = x;
    }

    void set_command_only(std::string the_command)
    {
        print_str_to_gp_ram(the_command, response_str_32bit_offset);
        d_dm(safe_print(std::cout << "Set command string to: [" << the_command << "]";));
    }

    std::string get_command_only()
    {
        return (get_str_from_gp_ram(response_str_32bit_offset));
    }

    void set_command(std::string the_command)
    {
        std::string outstr;
        print_str_to_gp_ram(the_command, response_str_32bit_offset);
        outstr = get_str_from_gp_ram(response_str_32bit_offset);
        d_dm(safe_print(std::cout << "wrote command: " << outstr << std::endl;));
        write_to_dut_gp_ram(command_ready_32bit_offset, 0);
        write_to_dut_gp_ram(command_request_32bit_offset, 1);
        d_dm(
				unsigned long tmp1=read_from_dut_gp_ram(command_ready_32bit_offset);
  		        unsigned long tmp2=read_from_dut_gp_ram(command_request_32bit_offset);
		        safe_print(std::cout << "command_ready: " << tmp1 << " Command request:" << tmp2 << std::endl;)
		);
    }

    int get_command_response(std::string & command_str)
    {
        unsigned long start_time = os_critical_low_level_system_timestamp_in_secs();
        unsigned long end_time = start_time;
        unsigned long time_diff = 0;
        if (!this->is_alive()) {
			 safe_print(std::cout << "[dual_port_memory_comm_encapsulator.get_command_response()]Error: slave device is not alive! " << std::endl;);
			 return 0;
		}
        while (read_from_dut_gp_ram(command_ready_32bit_offset) == 0) {
        	 end_time = os_critical_low_level_system_timestamp_in_secs();
        	 if (end_time < start_time) {end_time = start_time;};
        	 time_diff = end_time-start_time;
        			 if((this->get_max_wait_time_for_response_in_secs() > 0) && (time_diff > this->get_max_wait_time_for_response_in_secs())) {
                             safe_print(std::cout << "[dual_port_memory_comm_encapsulator.get_command_response()]Error: Time diff is:" << time_diff << " Secs. Watchdog limit is: " << this->get_max_wait_time_for_response_in_secs() << " Secs. Aborting" << std::endl;);
                             command_str = "";
                             return 0;
        			 }
         }
        command_str = get_str_from_gp_ram(response_str_32bit_offset);
        return (1);
    }

    void set_command_response(std::string the_response, std::vector<unsigned long > *binary_response)
    {
        safe_print(std::cout << "set_command_response is not defined " << std::endl;);
    }

    std::string get_new_command()
    {
        std::string retstr;
        safe_print(std::cout << "dual_port_memory_comm_encapsulator::get_new_command is not defined!\n";);
        return retstr;
    }

    unsigned long get_alive_magic_word() const
    {
        return alive_magic_word;
    }

    long get_max_wait_time_for_response_in_secs() const
    {
        return max_wait_time_for_response_in_secs;
    }

    void set_alive_magic_word(unsigned long  alive_magic_word)
    {
        this->alive_magic_word = alive_magic_word;
    }

    void set_max_wait_time_for_response_in_secs(long  max_wait_time_for_response_in_secs)
    {
        this->max_wait_time_for_response_in_secs = max_wait_time_for_response_in_secs;
    }

    unsigned long get_max_response_str_length_in_32bit_words() const;
    void set_max_response_str_length_in_32bit_words(unsigned long  max_response_str_length_in_32bit_words);
};

int execute_dut_proc_command_and_get_response(dual_port_memory_comm_encapsulator& dut_proc_cmd_communicator, const std::string& the_command, std::string& dut_proc_cmd_response);

#endif /* MEMORY_COMM_ENCAPSULATOR_H_ */
