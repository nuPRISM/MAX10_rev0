/*
 * dual_port_ram_container.cpp
 *
 *  Created on: Apr 13, 2011
 *      Author: linnyair
 */

#include "dual_port_ram_container.h"
#include "basedef.h"
#include "global_stream_defs.hpp"
#include <stdio.h>
//#define dual_port_ram_container_DEBUG
using namespace std;

void dual_port_ram_container::write_ram(unsigned int address, unsigned long data)
{

	//IOWR_ALTERA_AVALON_PIO_DATA(ram_base_address + (address << 2), data);
	unsigned long total_address = ram_base_address + (address << 2);
	*((unsigned long *)total_address) = data;
#if dual_port_ram_container_DEBUG
	 safe_print(std::cout << "[dual_port_ram_container::write_ram] ram_base_address = " << std::hex <<  ram_base_address << " address = " << address << " total_address = " << total_address << " data = " << data << std::dec << std::endl);
#endif

}

unsigned long dual_port_ram_container::read_ram(unsigned int address)
{
	unsigned long val;

	//val = IORD_ALTERA_AVALON_PIO_DATA(ram_base_address + (address << 2));
	unsigned long total_address = ram_base_address + (address << 2);
	val = *((unsigned long *)total_address);

#if dual_port_ram_container_DEBUG
	safe_print(std::cout << "[dual_port_ram_container::read_ram] ram_base_address = " << std::hex <<  ram_base_address << " address = " << address << " total_address = " << total_address << " data = " << val << std::dec << std::endl);
#endif
	return (val);
}

void dual_port_ram_container::test_read_write_ram()
{
	unsigned long read_val;
	out_to_all_streams("Writing pattern to dual port ram...." << ram_name << "\n");
	unsigned short failed_test = 0;
	for (unsigned long i = 0; i < max_ram_locations; i++)
	{
		write_ram(i, i);
	}
	for (unsigned long j = 0; j < max_ram_locations; j++)
	{
		read_val = read_ram(j);
		if (read_val != j)
		{
			out_to_all_streams("error: read " << read_val << " instead of " << j << "\n");
			failed_test = 1;
		}
	}
	if (failed_test)
	{
		out_to_all_streams("FAIL of patram " << ram_name << " R/W \n");
	} else
	{
		out_to_all_streams("PASS of patram " << ram_name << " R/W \n");
	}
	out_to_all_streams("Writing 0 to all dual port ram locations for ram " << ram_name << "...\n");

	for (unsigned long i = 0; i < max_ram_locations; i++)
	{
		write_ram(i, 0);
	}
}

int dual_port_ram_container::load_bit_pattern_from_file_to_dual_port_ram(string filename)
{
	select_terasic_sd_driver();
	unsigned long data_array[2 * MAX_NUM_OF_32BIT_VALUES_IN_PATTERN_RAM]; //(the 2x factor is just in case)
	unsigned long actual_number_of_values_read = 0;
	if (!Fat_Read_SD_File_Into_Long_Array(filename, data_array, actual_number_of_values_read, MAX_NUM_OF_32BIT_VALUES_IN_PATTERN_RAM))
		{
		out_to_all_streams("Error: dual_port_ram_container::load_bit_pattern_from_file_to_dual_port_ram: could not real any values from file: " << filename << ". Exiting without updating dual port RAM\n");
		  return 0;
		}
	out_to_all_streams( "Read " << actual_number_of_values_read << " unsigned long values from SD card:\n");
	for (unsigned long i = 0; i < actual_number_of_values_read; i++)
	{
		out_to_all_streams( hex << data_array[i] << dec << " ");
		if ((i % 8) == 0)
			out_to_all_streams("\n");
	}
	out_to_all_streams("\n");
	if (actual_number_of_values_read != 0)
	{
		out_to_all_streams("Now writing values to ram: [" << get_ram_name() << "]\n");

		for (unsigned long i = 0; i < actual_number_of_values_read; i++)
		{
			write_ram(i, data_array[i]);
		}
		out_to_all_streams("Now verifying values of ram: [" << get_ram_name() << "]\n");
		for (unsigned long i = 0; i < actual_number_of_values_read; i++)
		{
			unsigned long test_val = read_ram(i);
			if (test_val != data_array[i])
				out_to_all_streams("Error: mismatched values at location " << i << " of RAM " << get_ram_name() << " Read " << test_val << " Expected: " << data_array[i]);
		}
		if (min_reg_addr_for_circular_read != UINT_MAX) {
		   //write_value_to_reg_keeper_reg(min_reg_addr_for_circular_read, 0);
		} else {
			out_to_all_streams("Info: No min_reg_addr_for_circular_read register assigned to ram: [" << get_ram_name() << "]\n");
		}
		if (max_reg_addr_for_circular_read != UINT_MAX) {
		   //write_value_to_reg_keeper_reg(max_reg_addr_for_circular_read, actual_number_of_values_read - 1);
		} else {
			out_to_all_streams("Info: No max_reg_addr_for_circular_read register assigned to ram: [" << get_ram_name() << "]\n");
		}

	} else
	{
		out_to_all_streams("Error: did not read any values! Check filename and file!!! \n");
	}
	return 1;
}

