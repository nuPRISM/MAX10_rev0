/*
 * memory_comm_encapsulator.h
 *
 *  Created on: Nov 19, 2011
 *      Author: user
 */

#ifndef MEMORY_COMM_ENCAPSULATOR_H_
#define MEMORY_COMM_ENCAPSULATOR_H_

extern "C" {
#include "ucos_ii.h"
//#include "simple_socket_server.h"
	/* MicroC/OS-II definitions */
#include "includes.h"

	/* Nichestack definitions */
	//#include "ipport.h"
	//#include "tcpport.h"
}
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



#define SDR_MEMORY_COMM_OFFSET_COMMAND_COUNTER_OFFSET                0
#define SDR_MEMORY_COMM_OFFSET_COMMAND_LENGTH_OFFSET                 4
#define SDR_MEMORY_COMM_OFFSET_COMMAND_REQUEST_OFFSET                8
#define SDR_MEMORY_COMM_OFFSET_COMMAND_READY_OFFSET                 12
#define SDR_MEMORY_COMM_OFFSET_COMMAND_TYPE                         16
#define SDR_MEMORY_COMM_OFFSET_START_OF_RESPONSE_STR                20
#define SDR_MEMORY_COMM_OFFSET_BINARY_COMMAND_RESPONSE_OFFSET       20

#define memory_comm_debug(x) do { if (MEMORY_COMM_DEBUG) { x; }; std::cout.flush(); } while (0)

class memory_comm_encapsulator {
protected:
	   unsigned long mem_comm_region_base;
	   unsigned long mem_region_size_in_bytes;
	   unsigned long* alive_word_ptr;
	   std::string command_buffer_name;
	   unsigned long command_counter;
       char *response_str_ptr;
       unsigned long *response_str_length_ptr;
       unsigned long *command_ctr_ptr;
       unsigned long *command_ready_ptr;
       unsigned long *command_request_ptr;
       unsigned long *binary_response_str_ptr;
       unsigned long *command_type_ptr;
       bool enabled;
       bool pause_command_acquisition;
   	bool use_url_encode_decode;

public:
	memory_comm_encapsulator() {enabled = false;pause_command_acquisition = false; 	use_url_encode_decode = false;};

	virtual void set_and_enable_memory_comm_encapsulator(unsigned long the_mem_comm_region_base,
			                                           unsigned long the_mem_region_size_in_bytes,
			                                           unsigned long* the_alive_word_ptr,
			                                           std::string command_buffer_name);
	virtual ~memory_comm_encapsulator();
	virtual unsigned long get_command_counter() { return command_counter;};
	virtual void set_command_counter(unsigned long x) { command_counter = x; };
	virtual std::string get_command_buffer_name() {
		return command_buffer_name;
	}
	virtual void set_command_buffer_name(std::string the_command_buffer_name) {
			command_buffer_name = the_command_buffer_name;
			memory_comm_debug(std::cout << "Set command buffer name to: " << command_buffer_name << std::endl;);
		}
	virtual void set_command_response(std::string the_response, std::vector<unsigned long>* binary_response);

	virtual std::string get_new_command();
	virtual bool new_command_is_ready();
	virtual bool get_use_url_encode_decode() {
		return use_url_encode_decode;
	}

	virtual void set_use_url_encode_decode(bool useUrlEncodeDecode) {
		use_url_encode_decode = useUrlEncodeDecode;
	}



};

class mem_comm_ucos_class {
protected:
	memory_comm_encapsulator* memcomm_ptr;
	OS_EVENT *commandQ;
public:
	mem_comm_ucos_class() {
		memcomm_ptr = NULL;
		commandQ = NULL;
	}
	virtual OS_EVENT* get_command_q() const {
		return commandQ;
	}

	virtual void set_command_q(OS_EVENT* command_q) {
		commandQ = command_q;
	}

	virtual memory_comm_encapsulator* get_memcomm_ptr() const {
		return memcomm_ptr;
	}

	virtual void set_memcomm_ptr(memory_comm_encapsulator* memcomm_ptr) {
		this->memcomm_ptr = memcomm_ptr;
	}


};

typedef std::vector<mem_comm_ucos_class> mem_comm_ucos_class_vector_type;

class mem_comm_task_info_class {
protected:
	mem_comm_ucos_class_vector_type* mem_com_ucos_vector_ptr;
	unsigned int process_sleep_delay_ms;

public:
	mem_comm_task_info_class();

	mem_comm_ucos_class_vector_type* get_mem_com_ucos_vector_ptr() const {
		return mem_com_ucos_vector_ptr;
	}

	void set_mem_com_ucos_vector_ptr(mem_comm_ucos_class_vector_type* memComUcosVectorPtr) {
		mem_com_ucos_vector_ptr = memComUcosVectorPtr;
	}

	unsigned int get_process_sleep_delay_ms() const {
		return process_sleep_delay_ms;
	}

	void set_process_sleep_delay_ms(unsigned int processSleepDelayMs) {
		process_sleep_delay_ms = processSleepDelayMs;
	}
};

void multi_mem_comm_monitor_task(void *context);

#endif /* MEMORY_COMM_ENCAPSULATOR_H_ */
