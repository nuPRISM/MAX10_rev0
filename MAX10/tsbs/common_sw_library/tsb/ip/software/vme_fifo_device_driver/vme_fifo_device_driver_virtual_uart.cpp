/*
 * vme_fifo_device_driver_virtual_uart.cpp
 *
 *  Created on: Mar 21, 2014
 *      Author: yairlinn
 */

#include "vme_fifo_device_driver_virtual_uart.h"

#include "basedef.h"
#include <sstream>
#include <iostream>
#include <string>
#include <stdio.h>
#include "linnux_utils.h"
#include "basedef.h"
#include <vector>
extern "C" {
#include <xprintf.h>
}


#define u(x) do { if (UART_REG_DEBUG) {x;} } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if (UART_REG_DEBUG) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} } while (0)

register_desc_map_type default_vme_fifo_device_driver_virtual_uart_descriptions;


vme_fifo_device_driver_virtual_uart::vme_fifo_device_driver_virtual_uart(
		fifo_pio_foundation_vector_type the_fifo_pio_foundation_vector,
					unsigned long fifo_dmask,
					unsigned long capacity,
					std::string description_val,
					assert_nios_control_of_flow_through_fifo_func_ptr the_nios_assert_func,
					release_nios_control_of_flow_through_fifo_func_ptr the_nios_release_func,
					trigger_func_ptr the_trigger_func,
					release_trigger_func_ptr the_release_trigger_func,
					clear_fifos_func_ptr the_clear_fifos_func,
					nios_clear_fifo_func_ptr the_individual_clear_fifo_func
		) :
		virtual_uart_register_file()
        {
         this->set_nios_assert_func(the_nios_assert_func);
         this->set_nios_release_func(the_nios_release_func);
         this->set_trigger_func(the_trigger_func);
         this->set_release_trigger_func(the_release_trigger_func);
         this->set_clear_fifos_func(the_clear_fifos_func);
         this->set_individual_clear_fifo_func(the_individual_clear_fifo_func);

	   fifo_control_encapsulator.resize(the_fifo_pio_foundation_vector.size(),NULL);
	   pio_repository.resize(3*the_fifo_pio_foundation_vector.size());
	   uart_regfile_single_uart_included_regs_type the_included_regs(4*the_fifo_pio_foundation_vector.size(),0);

	   for (unsigned i = 0; i < the_fifo_pio_foundation_vector.size(); i++ ) {
		   pio_repository.at(i*3).set_base_address(the_fifo_pio_foundation_vector.at(i).get_read_data_base());
		   pio_repository.at(i*3+1).set_base_address(the_fifo_pio_foundation_vector.at(i).get_flags_base());
		   pio_repository.at(i*3+2).set_base_address(the_fifo_pio_foundation_vector.at(i).get_control_base());
		   std::ostringstream ostr;
		   ostr << i;
		   default_vme_fifo_device_driver_virtual_uart_descriptions[i*4]   = description_val + "_data_" + ostr.str();
		   default_vme_fifo_device_driver_virtual_uart_descriptions[i*4+1] = description_val+ "_flags_" + ostr.str();
		   default_vme_fifo_device_driver_virtual_uart_descriptions[i*4+2] = description_val+ "_ctrl_" + ostr.str();
		   default_vme_fifo_device_driver_virtual_uart_descriptions[i*4+3] = "dummy_" + ostr.str();
		   the_included_regs.at(i*4) = i*4;
		   the_included_regs.at(i*4+1) = i*4+1;
		   the_included_regs.at(i*4+2) = i*4+2;
		   the_included_regs.at(i*4+3) = i*4+3;
		   fifo_control_encapsulator.at(i) = new flow_through_fifo_encapsulator(the_fifo_pio_foundation_vector.at(i).get_read_data_base(),
				                                                                the_fifo_pio_foundation_vector.at(i).get_flags_base(),
				                                                                the_fifo_pio_foundation_vector.at(i).get_control_base() ,
				                                                                fifo_dmask,
				                                                                capacity,
				                                                                description_val+ "_" + ostr.str(),
                                                                                this->get_nios_assert_func(),
                                                                                this->get_nios_release_func(),
                                                                                this->get_individual_clear_fifo_func()
				                                                                );
	   }

		this->set_control_reg_map_desc(default_vme_fifo_device_driver_virtual_uart_descriptions);
		this->set_included_ctrl_regs(the_included_regs);

		dureg(safe_print(std::cout << "vme_fifo_device_driver_virtual_uart set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
}



unsigned long long vme_fifo_device_driver_virtual_uart::read_control_reg(unsigned long address, unsigned long secondary_uart_address, int* errorptr)
{


    if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return 0;
	}
    if ((address % 4) == 3) {
    	dureg(safe_print(std::cout << "Warning: vme_fifo_device_driver_virtual_uart read from dummy reg" << address<< std::endl););
    	return 0;
    }
    unsigned int current_pio_index =  3*(address>>2) + (address % 4);
    if (current_pio_index >=  pio_repository.size()) {
    	dureg(safe_print(std::cout << "Warning: vme_fifo_device_driver_virtual_uart write, current_pio_index = " << current_pio_index << std::endl););
    	return 0;
    }
    dureg(safe_print(std::cout << "vme_fifo_device_driver_virtual_uart write, current_pio_index = " << current_pio_index << " abs addr = " << pio_repository.at(current_pio_index).get_base_address() << std::endl););
    return pio_repository.at(current_pio_index).read();
};

void vme_fifo_device_driver_virtual_uart::write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address, int* errorptr)
{


	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}

	 if ((address % 4) == 3) {
	    	dureg(safe_print(std::cout << "Warning: vme_fifo_device_driver_virtual_uart write to dummy reg" << address<< " value: " << data << std::endl););
	    	return;
	    }
	    unsigned int current_pio_index =  3*(address>>2) + (address % 4);
	    if (current_pio_index >= pio_repository.size()) {
	    	dureg(safe_print(std::cout << "Warning: vme_fifo_device_driver_virtual_uart write, current_pio_index = " << current_pio_index << std::endl););
	    	return;
	    }
	    dureg(safe_print(std::cout << "vme_fifo_device_driver_virtual_uart write, current_pio_index = " << current_pio_index << " abs addr = " << pio_repository.at(current_pio_index).get_base_address() << " data = " << data << std::endl););
	    pio_repository.at(current_pio_index).write(data);
};

multiple_fifo_response_vector_type vme_fifo_device_driver_virtual_uart::trigger_and_acquire_multiple_fifos(std::vector<unsigned int> fifo_indices) {
	multiple_fifo_response_vector_type aquired_data(0);
	if (fifo_indices.size() == 0) {
		return aquired_data;
	}

	this->trigger(NULL);

	for (unsigned int i = 0; i < fifo_indices.size(); i++) {
	unsigned current_fifo_index =  	fifo_indices.at(i);
	if (current_fifo_index >= this->get_num_of_fifos()) {
		safe_print(std::cout << "Error: vme_fifo_device_driver_virtual_uart::trigger_and_acquire_multiple_fifos invalid fifo index " << current_fifo_index << " Should be between 0 and " << this->get_num_of_fifos() - 1 << "\n";);
	  } else {
			this->get_fifo_ptr(current_fifo_index)->acquire_and_print_contents_to_console(LINNUX_DECIMAL_FORMAT ,  0);
			aquired_data.push_back(this->get_fifo_ptr(current_fifo_index)->get_fifo_last_read_contents());
	  }
	}

	//this->clear_fifos(NULL);
	this->release_trigger(NULL);

	return aquired_data;
}
