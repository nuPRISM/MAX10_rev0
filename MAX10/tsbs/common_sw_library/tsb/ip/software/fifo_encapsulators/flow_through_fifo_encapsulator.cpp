/*
 * flow_through_fifo_encapsulator.cpp
 *
 *  Created on: Jul 8, 2013
 *      Author: yairlinn
 */

#include "flow_through_fifo_encapsulator.h"
#include "linnux_testbench_constants.h"

using namespace std;

void flow_through_fifo_encapsulator::set_up_fifo_for_acquisition(int do_pre_flush)
{
	read_FIFO_flags();
	parse_FIFO_flags();
	print_FIFO_status();
	disable_wrclk();
	disable_flowthrough();
	assert_NIOS_control(NULL);
}

int flow_through_fifo_encapsulator::complete_fifo_aquisition(int do_not_wait_for_FIFO)
{
	int stop_has_been_requested = 0;
	time_t start_time;
	read_FIFO_flags();
	parse_FIFO_flags();
	return (stop_has_been_requested);
}

void flow_through_fifo_encapsulator::print_FIFO_contents(LINNUX_FIFO_DATA_FORMATS data_format, int verbose)
{
	FIFO_access_container::print_FIFO_contents(data_format,verbose);
	release_NIOS_control(NULL);
	//enable_flowthrough();
	//enable_wrclk();
}
