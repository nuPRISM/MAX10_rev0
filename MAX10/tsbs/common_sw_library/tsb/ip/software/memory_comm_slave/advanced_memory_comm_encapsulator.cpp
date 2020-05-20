/*
 * advanced_memory_comm_encapsulator.cpp
 *
 */

#include "basedef.h"
#include "advanced_memory_comm_encapsulator.h"
#include "linnux_utils.h"

extern "C" {
#include <ctype.h>
	/* MicroC/OS-II definitions */
#include "includes.h"

	/* Nichestack definitions */

#include "ipport.h"
#include "libport.h"
#include "osport.h"
#include "net.h"
#include "linnux_nichestack_interface.h"

#include "cksum.h"
#include "dns.h"
#include <sys/alt_stdio.h>
#include <xprintf.h>
#include "my_mem_defs.h"
#include "mem.h"
}
#include <stdio.h>
#include <math.h>
#include <sstream>


#define advanced_memory_comm_debug(x) do { if (ADVANCED_MEMORY_COMM_DEBUG || verbose_jtag_debug_mode) { x; } } while (0)
#define MIN(x,y) (((x) > (y)) ? (y) : (x))

void advanced_memory_comm_encapsulator::set_and_enable_memory_comm_encapsulator(unsigned long the_mem_comm_region_base,
        unsigned long the_mem_region_size_in_bytes,
        unsigned long* the_alive_word_ptr,
        const std::string command_buffer_name)
{
	    memory_comm_encapsulator::set_and_enable_memory_comm_encapsulator(
																			the_mem_comm_region_base,
																			the_mem_region_size_in_bytes,
																			the_alive_word_ptr,
																			command_buffer_name
																		  );

		unsigned long chunkSize = 	MIN(
		                                ((unsigned long)(((double)(the_mem_region_size_in_bytes - SDR_MEMORY_COMM_OFFSET_START_OF_RESPONSE_STR))*0.9)),														  
                                        ((unsigned long)(((double)(the_mem_region_size_in_bytes - SDR_MEMORY_COMM_OFFSET_BINARY_COMMAND_RESPONSE_OFFSET))*0.9))
										);
	    set_chunk_size(chunkSize);
		num_values_sent = 0;
		num_remaining_responses = 0;
		saved_response_buffer = "";
	    saved_response_vector.clear();
} ;

void advanced_memory_comm_encapsulator::set_command_response(std::string the_response, std::vector<unsigned long>* binary_response)
	{
		extern int verbose_jtag_debug_mode;
		int cpu_sr;
		unsigned long number_of_vals_to_send;
		std::string the_command;

		if (!enabled) {
							std::cout << "[advanced_memory_comm_encapsulator] - Error: advanced_memory_comm_encapsulator command received, but component is not enabled!!!\n";
							return;
		}
						
        if (binary_response != NULL) {
		  //binary responses do not support multi-chunk for now
		  memory_comm_encapsulator::set_command_response(the_response, binary_response);
		  return;
		}

        if (the_response.length() < get_chunk_size()) {
        	num_remaining_responses = 0;
        } else
        if ((the_response.length() % get_chunk_size()) == 0) {
		   num_remaining_responses = the_response.length()/get_chunk_size() - 1;
        } else {
        	num_remaining_responses = the_response.length()/get_chunk_size();
		}
		memory_comm_debug(safe_print(std::cout << "Advanced Mem Comm " << get_command_buffer_name() << " the_response.length=" << the_response.length() << std::dec << " get_chunk_size()=" << get_chunk_size() << " num_remaining_responses = " << num_remaining_responses << std::endl;));
        num_values_sent =  0;

		if (num_remaining_responses == 0){
			    std::ostringstream ostr;

				memory_comm_debug(safe_print(std::cout << std::hex << "Advanced Mem Comm " << get_command_buffer_name() << " set_command_response: Sending string response (" << the_response << std::dec << ") Command Counter: (" << get_command_counter() << ")" << std::endl;));

				if (the_response.length() > get_chunk_size()) {
					memory_comm_debug(safe_print(std::cout <<  "Advanced Mem comm " << get_command_buffer_name() << " string response length " << the_response.length() << " is larger than " << (unsigned long) (mem_region_size_in_bytes) << " Truncating!\n"));
					num_values_sent = number_of_vals_to_send = get_chunk_size();
					ostr << num_remaining_responses << " " << the_response.substr(0,num_values_sent);
					
				} else {
				    ostr << std::string("0 ") << the_response;				
				}	
                memory_comm_encapsulator::set_command_response(ostr.str(),NULL);														
				memory_comm_debug(safe_print(std::cout <<  "Advanced Mem Comm " << get_command_buffer_name() << "num_remaining_responses = " << num_remaining_responses << " num values sent = " << num_values_sent << " number_of_vals_to_send = " << number_of_vals_to_send << " chunk = (" << ostr.str() << "\n"));
		} else {
			      pause_command_acquisition = true; //disable mem_comm_task's call of get_command
		          do {
		      		std::ostringstream ostr;
		            memory_comm_debug(safe_print(std::cout <<  "num_remaining_responses = " << num_remaining_responses << "\n"));
					std::string current_str = the_response.substr(0,get_chunk_size()); //if there is less that chunk_size in the string, substr will only copy until end of string
					number_of_vals_to_send = current_str.length();
					ostr << num_remaining_responses << " " << the_response.substr(num_values_sent,number_of_vals_to_send);
					num_values_sent += number_of_vals_to_send;
					num_remaining_responses -= 1;

					memory_comm_debug(safe_print(std::cout
							<<  "num_remaining_responses = " << num_remaining_responses
							<< " num values sent = " << num_values_sent
							<< " number_of_vals_to_send = " << number_of_vals_to_send
							<< " chunk = (" << ostr.str() << ")\n"));
					memory_comm_encapsulator::set_command_response(ostr.str(),NULL);		
					if (num_remaining_responses != -1) {
						the_command = this->get_partial_command_request();
						strtolower(the_command);
						TrimSpaces(the_command);
						memory_comm_debug(safe_print(std::cout <<  "Advanced Mem Comm " << get_command_buffer_name() << " got " << the_command << ")\n"));

						if (the_command != std::string("get_extended_response")) {
							memory_comm_debug(safe_print(std::cout <<  "Advanced Mem Comm " << get_command_buffer_name() << " Expected command: get_extended_response but got " << the_command << "). Command ignored! Extended response chunk will be returned.\n"));
						}
					}
					memory_comm_debug(safe_print(std::cout
											<<  "After newcommand: num_remaining_responses = " << num_remaining_responses
											<< " num values sent = " << num_values_sent
											<< " number_of_vals_to_send = " << number_of_vals_to_send
											<< " chunk = (" << ostr.str() << ")\n"));
				} 	while (num_remaining_responses != -1);
		          pause_command_acquisition = false;
		}  
	};

    std::string advanced_memory_comm_encapsulator::get_partial_command_request()
	{
	   extern int verbose_jtag_debug_mode;
	   memory_comm_debug(
	    safe_print(std::cout << std::hex << "Advanced MemComm: get_new_command(1): " << get_command_buffer_name()  << " Waiting for command, command_request_ptr=  " << (unsigned long) command_request_ptr << " *command_request_ptr = " << *command_request_ptr << std::dec << ") Command Counter: (" << get_command_counter() << ")" << std::endl;);
	   );

	    while (!(*command_request_ptr))
	    {
			MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_VERY_SHORT_PROCESS_DLY_MS);

	    	/*usleep(1);*/
	    	/*if (verbose_jtag_debug_mode)
	        {
	    		 usleep (1000000);
	         	  safe_print(std::cout << "Waiting for command, command_request_ptr=  " << (unsigned long) command_request_ptr << " *command_request_ptr = " << *command_request_ptr << std::endl << "command: " << std::string(response_str_ptr) <<  std::endl);
	        }*/
        }
	    *command_request_ptr = 0; //so we don't get the same command twice
	    std::string the_command;
	    the_command = std::string(response_str_ptr);

	    memory_comm_debug(
	       safe_print(std::cout  << "Advanced MemComm: get_new_command(2): " << get_command_buffer_name()  <<"  Got Command of: (" << the_command << ") Command Counter: (" << get_command_counter() << ")" << std::endl);
	    );

	    return the_command;
	};

//	std::string advanced_memory_comm_encapsulator::get_new_command()
//		{
//		   extern int verbose_jtag_debug_mode;
//		   memory_comm_debug(
//		    safe_print(std::cout << std::hex << "Advanced MemComm: get_new_command(1): " << get_command_buffer_name()  << " Waiting for command, command_request_ptr=  " << (unsigned long) command_request_ptr << " *command_request_ptr = " << *command_request_ptr << std::dec << ") Command Counter: (" << get_command_counter() << ")" << std::endl;);
//		   );
//
//		    while (!(*command_request_ptr))
//		    {
//				MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_SHORT_PROCESS_DLY_MS);
//
//		    	/*usleep(1);*/
//		    	/*if (verbose_jtag_debug_mode)
//		        {
//		    		 usleep (1000000);
//		         	  safe_print(std::cout << "Waiting for command, command_request_ptr=  " << (unsigned long) command_request_ptr << " *command_request_ptr = " << *command_request_ptr << std::endl << "command: " << std::string(response_str_ptr) <<  std::endl);
//		        }*/
//            }
//		    *command_request_ptr = 0; //so we don't get the same command twice
//		    std::string the_command;
//		    the_command = std::string(response_str_ptr);
//
//		    memory_comm_debug(
//		       safe_print(std::cout  << "Advanced MemComm: get_new_command(2): " << get_command_buffer_name()  <<"  Got Command of: (" << the_command << ") Command Counter: (" << get_command_counter() << ")" << std::endl);
//		    );
//
//		    return the_command;
//		};

	advanced_memory_comm_encapsulator::~advanced_memory_comm_encapsulator() {
	// TODO Auto-generated destructor stub
}
