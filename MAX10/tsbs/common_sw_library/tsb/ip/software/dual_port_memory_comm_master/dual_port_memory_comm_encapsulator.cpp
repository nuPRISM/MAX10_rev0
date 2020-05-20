/*
 * memory_comm_encapsulator.cpp
 *
 *  Created on: Nov 19, 2011
 *      Author: user
 */

#include "dual_port_memory_comm_encapsulator.h"
#include "simple_socket_server.h"
#include "ucos_ii.h"
#include <stdio.h>


int execute_dut_proc_command_and_get_response(dual_port_memory_comm_encapsulator& dut_proc_cmd_communicator, const std::string& the_command, std::string& dut_proc_cmd_response) {
     int dut_proc_cmd_result;

     INT8U semaphore_err;
     dut_proc_cmd_response = "";

     OSSemPend(DUT_PROC_MEM_COMM_Semaphore,LINNUX_DUT_PROC_MEM_COMM_Semaphore_DEFAULT_WAIT_IN_TICKS,&semaphore_err);

     if (semaphore_err != OS_NO_ERR) {
     	safe_print(std::cout << "[execute_dut_proc_command_and_get_response] Could not get DUT_PROC_MEM_COMM_Semaphore, Error is: " << semaphore_err << std::endl;);
     	return 0;
     }

	 dut_proc_cmd_communicator.set_command(the_command);
	 safe_print(std::cout << "Getting DUT Proc Response ..."<< std::endl;);
	 dut_proc_cmd_result = dut_proc_cmd_communicator.get_command_response(dut_proc_cmd_response);

	 semaphore_err = OSSemPost(DUT_PROC_MEM_COMM_Semaphore);

	 if (semaphore_err != OS_NO_ERR) {
		safe_print(std::cout << "[execute_dut_proc_command_and_get_response] Could not Post to DUT_PROC_MEM_COMM_Semaphore, Error is: " << semaphore_err << std::endl;);
		dut_proc_cmd_response = "";
		return 0;
	 }

     return dut_proc_cmd_result;
}

unsigned long dual_port_memory_comm_encapsulator::get_max_response_str_length_in_32bit_words() const
{
    return max_response_str_length_in_32bit_words;
}

void dual_port_memory_comm_encapsulator::set_max_response_str_length_in_32bit_words(unsigned long  max_response_str_length_in_32bit_words)
{
    this->max_response_str_length_in_32bit_words = max_response_str_length_in_32bit_words;
}




/*
memory_comm_encapsulator::~memory_comm_encapsulator() {
	// TODO Auto-generated destructor stub
}
*/
