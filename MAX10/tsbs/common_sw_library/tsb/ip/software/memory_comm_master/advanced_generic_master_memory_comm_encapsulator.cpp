/*
 * memory_comm_encapsulator.cpp
 *
 *  Created on: Nov 19, 2011
 *      Author: user
 */

#include "advanced_generic_master_memory_comm_encapsulator.h"
#include <stdio.h>
#include <time.h>
#include <iostream>
#include <sstream>
using namespace std;

int advanced_generic_master_memory_comm_encapsulator::get_command_response(std::string& response_str)
{
	std::string raw_respose_str;
	response_str = "";
	unsigned long num_response_chunks_pending;
	std::string num_response_chunks_str;
	do {
		 std::string actual_response_chunk = "";
		 generic_master_memory_comm_encapsulator::get_command_response(raw_respose_str);
		 std::size_t end_of_num_chunks_pending = raw_respose_str.find_first_of(" ");
		 num_response_chunks_str = raw_respose_str.substr(0,end_of_num_chunks_pending);
		 if ((end_of_num_chunks_pending+1) < raw_respose_str.length()) {
			 actual_response_chunk = raw_respose_str.substr(end_of_num_chunks_pending+1,std::string::npos);
			 response_str += actual_response_chunk;
		 }

		 istringstream tmp(num_response_chunks_str);
		 tmp >> num_response_chunks_pending;
		 /*
		 debug_adv_mem_comm(
			std::cout << "raw_respose_str=("<< raw_respose_str
			<<") end_of_num_chunks_pending="<< end_of_num_chunks_pending
			<< " num_response_chunks_str = " <<  num_response_chunks_str
			<< " num_response_chunks_pending = " << num_response_chunks_pending
			<< " actual_response_chunk = " << actual_response_chunk
			<< " response_str = " << response_str << std::endl;
		 );
*/
		 debug_adv_mem_comm(
		 			std::cout << "raw_respose_str=("<< raw_respose_str
		 			<<") end_of_num_chunks_pending="<< end_of_num_chunks_pending
		 			<< " num_response_chunks_str = " <<  num_response_chunks_str
		 			<< " num_response_chunks_pending = " << num_response_chunks_pending
		 			<< " actual_response_chunk = " << actual_response_chunk
		 			<< std::endl;
		 		 );
		 if (num_response_chunks_pending != 0) {
			 set_command(std::string("get_extended_response"));
		 }
	} while (num_response_chunks_pending != 0);

	return (1);
}
