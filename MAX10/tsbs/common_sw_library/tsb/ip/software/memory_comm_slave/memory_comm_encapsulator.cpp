/*
 * memory_comm_encapsulator.cpp
 *
 *  Created on: Nov 19, 2011
 *      Author: user
 */

#include "basedef.h"
#include "memory_comm_encapsulator.h"
#include "linnux_utils.h"

extern "C" {
#include <ctype.h>
	/* MicroC/OS-II definitions */
#include "includes.h"

	/* Simple Socket Server definitions */
#include "simple_socket_server.h"

	/* Nichestack definitions */

#include "ipport.h"
#include "libport.h"
#include "osport.h"
#include "net.h"
#include "linnux_nichestack_interface.h"


#include "linnux_server_dns_utils.h"
#include "cksum.h"
#include "dns.h"
#include <sys/alt_stdio.h>
#include <xprintf.h>
#include "my_mem_defs.h"
#include "mem.h"
}
#include <stdio.h>
#include "alt_error_handler.hpp"

void memory_comm_encapsulator::set_and_enable_memory_comm_encapsulator(unsigned long the_mem_comm_region_base,
        unsigned long the_mem_region_size_in_bytes,
        unsigned long* the_alive_word_ptr,
        std::string command_buffer_name)
{
	    mem_comm_region_base = the_mem_comm_region_base;
	    mem_region_size_in_bytes = the_mem_region_size_in_bytes;
	    alive_word_ptr = the_alive_word_ptr;
        safe_print(std::cout << std::hex << "command buffer name: " << command_buffer_name << " mem_comm_region_base: " << mem_comm_region_base << "mem_regions_size: " << mem_region_size_in_bytes << " alive_word_ptr " << (unsigned long) alive_word_ptr << std::hex << std::endl);

		set_command_counter(0);
		command_ctr_ptr = (unsigned long *) (mem_comm_region_base+SDR_MEMORY_COMM_OFFSET_COMMAND_COUNTER_OFFSET);
		response_str_length_ptr = (unsigned long *) (mem_comm_region_base+SDR_MEMORY_COMM_OFFSET_COMMAND_LENGTH_OFFSET);
		response_str_ptr = (char *) (mem_comm_region_base+SDR_MEMORY_COMM_OFFSET_START_OF_RESPONSE_STR);
		command_ready_ptr = (unsigned long *) (mem_comm_region_base+SDR_MEMORY_COMM_OFFSET_COMMAND_READY_OFFSET);
		command_request_ptr = (unsigned long *) (mem_comm_region_base+SDR_MEMORY_COMM_OFFSET_COMMAND_REQUEST_OFFSET);
		binary_response_str_ptr = (unsigned long *) (mem_comm_region_base+SDR_MEMORY_COMM_OFFSET_BINARY_COMMAND_RESPONSE_OFFSET);
		command_type_ptr = (unsigned long*) (mem_comm_region_base+SDR_MEMORY_COMM_OFFSET_COMMAND_TYPE);

		*command_type_ptr = 0;
		*command_request_ptr = 0;
		*command_ready_ptr = 1;
		set_command_buffer_name(command_buffer_name);
		enabled = true;
		*alive_word_ptr = ALIVE_WORD_FOR_MEMORY_COMM;

		memory_comm_debug(safe_print(std::cout << std::hex << "command_ctr_ptr =" << (unsigned long) command_ctr_ptr << "\n"));
		memory_comm_debug(safe_print(std::cout << std::hex << "response_str_length_ptr =" << (unsigned long) response_str_length_ptr << "\n"));
		memory_comm_debug(safe_print(std::cout << std::hex << "response_str_ptr =" << (unsigned long) response_str_ptr << "\n"));
		memory_comm_debug(safe_print(std::cout << std::hex << "command_ready_ptr =" << (unsigned long) command_ready_ptr << "\n"));
		memory_comm_debug(safe_print(std::cout << std::hex << "command_request_ptr =" << (unsigned long) command_request_ptr << "\n"));
		memory_comm_debug(safe_print(std::cout << std::hex << "binary_response_str_ptr =" << (unsigned long) binary_response_str_ptr << "\n"));
		memory_comm_debug(safe_print(std::cout << std::hex << "command_type_ptr =" << (unsigned long) command_type_ptr << "\n"));
		memory_comm_debug(safe_print(std::cout << std::hex << "get_command_counter =" << (unsigned long) get_command_counter() << "\n"));
		memory_comm_debug(safe_print(std::cout << std::dec));

//		/set_command_response("Hello World",NULL);

} ;

void memory_comm_encapsulator::set_command_response(std::string the_response, std::vector<unsigned long>* binary_response)
	{
		extern int verbose_jtag_debug_mode;
		int cpu_sr;

		unsigned long number_of_vals_to_send;
		if (!enabled) {
			std::cout << "[memory_comm_encapsulator] - Error: memory_comm_encapsulator command received, but component is not enabled!!!\n";
		}
		if (binary_response != NULL)
				{
			       if (binary_response->size()*4 > mem_region_size_in_bytes) {
			    	   number_of_vals_to_send = mem_region_size_in_bytes/4-1;
                       safe_print(std::cout << "Mem comm error: binary response is larger than" << (unsigned long) (mem_region_size_in_bytes) << " Truncating!");
			       } else
			       {
			    	   number_of_vals_to_send = binary_response->size();
			       }
			       memory_comm_debug(
			            safe_print(std::cout << "Sending binary response" << std::endl);
			       );

					*response_str_length_ptr = (unsigned long)number_of_vals_to_send;
					for (unsigned long i = 0; i < number_of_vals_to_send; i++)
					{
						binary_response_str_ptr[i] = (*binary_response)[i];
					}
					*command_type_ptr = 1;
				} else
				{
					memory_comm_debug(safe_print(std::cout << std::hex << "Mem Comm " << get_command_buffer_name() << " set_command_response: Sending string response (" << the_response << std::dec << ") Command Counter: (" << get_command_counter() << ")" << std::endl;));

					if (the_response.length() > mem_region_size_in_bytes) {
						safe_print(std::cout <<  "Mem comm error: string response ( "<< the_response << "is larger than" << (unsigned long) (mem_region_size_in_bytes) << " Truncating!");
						the_response = the_response.substr(0,mem_region_size_in_bytes-1);
					}

					set_command_counter(get_command_counter()+1);
					sprintf(response_str_ptr,"%s",the_response.c_str());
					*response_str_length_ptr =(unsigned long)(the_response.length());
					*command_type_ptr = 0;
					memory_comm_debug(safe_print(std::cout <<  std::hex <<  "Mem Comm " << get_command_buffer_name() << " set_command_response: Finished Sending string response (" << the_response << std::dec << ") Command Counter: (" << get_command_counter() << ")" << std::endl;));
				}

		*command_ctr_ptr=get_command_counter();
		OS_ENTER_CRITICAL();
		*command_request_ptr = 0;
		*command_ready_ptr = 1;
		OS_EXIT_CRITICAL();
	};

    bool memory_comm_encapsulator::new_command_is_ready() {
    	return ((*command_request_ptr) != 0);
    }

	std::string memory_comm_encapsulator::get_new_command()
		{
		   extern int verbose_jtag_debug_mode;
		   memory_comm_debug(
		    safe_print(std::cout << std::hex << "MemComm: get_new_command: " << get_command_buffer_name()  << " Waiting for command, command_request_ptr=  " << (unsigned long) command_request_ptr << " *command_request_ptr = " << *command_request_ptr << std::dec << ") Command Counter: (" << get_command_counter() << ")" << std::endl;);
		   );

		   wait_for_new_command:
		   while ((!(*command_request_ptr)) || pause_command_acquisition)
		    {
				MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_SHORT_PROCESS_DLY_MS);

		    	/*usleep(1);*/
		    	/*if (verbose_jtag_debug_mode)
		        {
		    		 usleep (1000000);
		         	  safe_print(std::cout << "Waiting for command, command_request_ptr=  " << (unsigned long) command_request_ptr << " *command_request_ptr = " << *command_request_ptr << std::endl << "command: " << std::string(response_str_ptr) <<  std::endl);
		        }*/
            }
		    if (pause_command_acquisition) {
		    	memory_comm_debug(
		    			    safe_print(std::cout << std::hex << "MemComm: get_new_command: detected pause_command_acquisition\n");
		    			   );
		    	goto wait_for_new_command;
		    }
		    *command_request_ptr = 0; //so we don't get the same command twice
		    std::string retstr;
		    retstr = std::string(response_str_ptr);
		    memory_comm_debug(
		       safe_print(std::cout  << "MemComm: get_new_command: " << get_command_buffer_name()  <<"  Got Command of: (" << response_str_ptr << ") Command Counter: (" << get_command_counter() << ")" << std::endl);
		    );
		    return retstr;
		};

memory_comm_encapsulator::~memory_comm_encapsulator() {
	// TODO Auto-generated destructor stub
}



void multi_mem_comm_monitor_task(void *context)
{
    INT8U error_code;

    if (context == NULL) {
    	safe_print(printf( ("Error: multi_mem_comm_monitor_task: context is NULL!\n")));
    	error_code = OSTaskDel(OS_PRIO_SELF);
    	alt_uCOSIIErrorHandler(error_code, 0);
    	while (1) {
   		  /* Correct Program Flow should never get here */
		  MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_LONG_PROCESS_DLY_MS);
    	}
    }

    mem_comm_task_info_class* mem_comm_info_inst = (mem_comm_task_info_class *) context;
    unsigned int i;
    mem_comm_ucos_class_vector_type* mem_comm_ucos_vec_ptr = mem_comm_info_inst->get_mem_com_ucos_vector_ptr();
    unsigned int num_mem_comms = mem_comm_ucos_vec_ptr->size();
	while(1)
	{
		for (i = 0; i < num_mem_comms; i++) {
			if (mem_comm_ucos_vec_ptr->at(i).get_command_q() == NULL) {
				continue;
			}

			if (!mem_comm_ucos_vec_ptr->at(i).get_memcomm_ptr()->new_command_is_ready()) {
				continue;
			}

		      std::string *cmdstr = NULL;
		      std::string  tmpstr;
			  tmpstr = mem_comm_ucos_vec_ptr->at(i).get_memcomm_ptr()->get_new_command();
			  cmdstr = new std::string;
			  *cmdstr = tmpstr;

				error_code = OSQPost(mem_comm_ucos_vec_ptr->at(i).get_command_q(), (void *)cmdstr);
				if (error_code != OS_NO_ERR)
				{
					std::string timestamp_str = get_current_time_and_date_as_string_trimmed();
					printf("[%s] [multi_mem_comm_monitor_task] Error while posting command [%-100s] to memcomm [%s], error code is [%d]\n",timestamp_str.c_str(),cmdstr->c_str(),mem_comm_ucos_vec_ptr->at(i).get_memcomm_ptr()->get_command_buffer_name().c_str(),(int) error_code);
					delete cmdstr;
					cmdstr = NULL;
				}
		}
		MyOSTimeDlyHMSM(0,0,0,mem_comm_info_inst->get_process_sleep_delay_ms());
    }
	printf("We should have never gotten here!\n");
}

mem_comm_task_info_class::mem_comm_task_info_class() {
	this->set_mem_com_ucos_vector_ptr(NULL);
    this->set_process_sleep_delay_ms(LINNUX_DEFAULT_MEDIUM_PROCESS_DLY_MS);
}
