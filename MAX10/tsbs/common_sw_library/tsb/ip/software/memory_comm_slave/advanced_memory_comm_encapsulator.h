/*
 * advanced_memory_comm_encapsulator.h
 *
 */

#ifndef ADVANCED_MEMORY_COMM_ENCAPSULATOR_H_
#define ADVANCED_MEMORY_COMM_ENCAPSULATOR_H_

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
#include "memory_comm_encapsulator.h"

class advanced_memory_comm_encapsulator : public memory_comm_encapsulator {
protected:	   
	  unsigned long chunk_size;
	  unsigned long num_values_sent;
	  unsigned long num_needed_responses;
	  long num_remaining_responses;
	  std::string saved_response_buffer;
	  std::vector<unsigned long> saved_response_vector;
	  

	   
	   virtual unsigned long get_chunk_size() {
			return chunk_size;
	   }
public:
	virtual void set_and_enable_memory_comm_encapsulator(
	                                                     unsigned long the_mem_comm_region_base,
			                                             unsigned long the_mem_region_size_in_bytes,
			                                             unsigned long* the_alive_word_ptr,
			                                             std::string command_buffer_name
														 );
													   
	virtual void set_command_response(std::string the_response, std::vector<unsigned long>* binary_response);
	//virtual std::string get_new_command();
    virtual std::string get_partial_command_request();

	  virtual void set_chunk_size(unsigned long chunkSize) {
				chunk_size = chunkSize;
				memory_comm_debug(safe_print(std::cout << " [advanced_memory_comm_encapsulator] " << command_buffer_name << " Set chunk size to " << chunk_size << "\n";));
		   }
	~advanced_memory_comm_encapsulator();
	
};

#endif /* MEMORY_COMM_ENCAPSULATOR_H_ */
