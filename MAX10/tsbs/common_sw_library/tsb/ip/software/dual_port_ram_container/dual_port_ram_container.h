/*
 * dual_port_ram_container.h
 *
 *  Created on: Apr 13, 2011
 *      Author: linnyair
 */

#ifndef DUAL_PORT_RAM_CONTAINER_H_
#define DUAL_PORT_RAM_CONTAINER_H_

#include <alt_types.h>
#include <altera_avalon_pio_regs.h>
#include <sys/alt_irq.h>
#include <system.h>
#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <iostream>
#include <fstream>
#include <map>
#include <float.h>
#include <vector>
#include <unistd.h>
#include <time.h>
#include "linnux_testbench_constants.h"
#include "chan_fatfs/terasic_linnux_driver.h"
#include "chan_fatfs/fatfs_linnux_api.h"

class dual_port_ram_container {
	protected:
		std::string ram_name;
		unsigned long max_ram_locations;
		unsigned long ram_base_address;
		unsigned long min_reg_addr_for_circular_read;
		unsigned long max_reg_addr_for_circular_read;
	public:

		dual_port_ram_container(std::string ram_nam_val, unsigned long max_ram_locations_val, unsigned long ram_base_address_val, unsigned long min_reg_addr, unsigned long max_reg_addr)
		{
			ram_name = ram_nam_val;
			max_ram_locations = max_ram_locations_val;
			ram_base_address = ram_base_address_val;
			min_reg_addr_for_circular_read = min_reg_addr;
			max_reg_addr_for_circular_read = max_reg_addr;
		}
		void set_addrs_for_circular_read()
		{
		}

		void write_ram(unsigned int address, unsigned long data);

		unsigned long read_ram(unsigned int address);

		void test_read_write_ram();

		int load_bit_pattern_from_file_to_dual_port_ram(std::string filename);

    unsigned long get_max_ram_locations() const
    {
        return max_ram_locations;
    }

    unsigned long get_ram_base_address() const
    {
        return ram_base_address;
    }

    void setMax_ram_locations(unsigned long  max_ram_locations)
    {
        this->max_ram_locations = max_ram_locations;
    }

    void setRam_base_address(unsigned long  ram_base_address)
    {
        this->ram_base_address = ram_base_address;
    }

    unsigned long getMax_reg_addr_for_circular_read() const
    {
        return max_reg_addr_for_circular_read;
    }

    std::string get_ram_name() const
    {
        return ram_name;
    }

    void setMax_reg_addr_for_circular_read(unsigned long  max_reg_addr_for_circular_read)
    {
        this->max_reg_addr_for_circular_read = max_reg_addr_for_circular_read;
    }

    void set_ram_name(std::string ram_name)
    {
        this->ram_name = ram_name;
    }

    /*virtual ~dual_port_ram_container()
		{
		}
		;*/
};

#endif /* DUAL_PORT_RAM_CONTAINER_H_ */
