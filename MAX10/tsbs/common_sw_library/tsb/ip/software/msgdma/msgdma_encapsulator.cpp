/*
 * msgdma_encapsulator.cpp
 *
 *  Created on: Apr 29, 2015
 *      Author: yairlinn
 */

#include "msgdma_encapsulator.h"
#include <stdio.h>
#include <iostream>
#include <sstream>
#include <ostream>
#include "linnux_utils.h"

namespace msgdma {


msgdma_encapsulator::msgdma_encapsulator(std::string device_name)
{
    this->set_device_name(device_name);
	this->set_device_ptr(this->open());
}

msgdma_encapsulator::msgdma_encapsulator()
{
	control_word = 0;
}

alt_msgdma_dev* msgdma_encapsulator::open()
{
	this->set_device_ptr(alt_msgdma_open (this->get_device_name().c_str()));
  return this->get_device_ptr();
}

bool msgdma_encapsulator::start() {

    	unsigned long control1 = IORD_ALTERA_MSGDMA_CSR_CONTROL(this->get_device_ptr()->csr_base) & (~ALTERA_MSGDMA_CSR_STOP_DESCRIPTORS_MASK);
        IOWR_ALTERA_MSGDMA_CSR_CONTROL(this->get_device_ptr()->csr_base, control1);

    	low_level_system_usleep(NUM_US_TO_WAIT_FOR_CSR_OPERATION);

    	unsigned long status1 = IORD_ALTERA_MSGDMA_CSR_STATUS(this->get_device_ptr()->csr_base);
    	if ((status1 & ALTERA_MSGDMA_CSR_STOP_STATE_MASK) != 0) {
    		safe_print(std::cout << "Error: msgdma_encapsulator::do_sw_reset for device " << device_name << " did not come out of reset state!" << std::endl);
    		return false;
    	}
    	return true;
 }


bool msgdma_encapsulator::do_sw_reset() {

	unsigned long control1 = IORD_ALTERA_MSGDMA_CSR_CONTROL(this->get_device_ptr()->csr_base) | (ALTERA_MSGDMA_CSR_RESET_MASK);
    IOWR_ALTERA_MSGDMA_CSR_CONTROL(this->get_device_ptr()->csr_base, control1);

	low_level_system_usleep(NUM_US_TO_WAIT_FOR_CSR_OPERATION);

	unsigned long status1 = IORD_ALTERA_MSGDMA_CSR_STATUS(this->get_device_ptr()->csr_base);
	if ((status1 & ALTERA_MSGDMA_CSR_RESET_STATE_MASK) != 0) {
		safe_print(std::cout << "Error: msgdma_encapsulator::do_sw_reset for device " << device_name << " did not come out of reset state!" << std::endl);
		return false;
	}
	return true;
}


msgdma_encapsulator::~msgdma_encapsulator() {
	// TODO Auto-generated destructor stub
}

msgdma_mm_to_st_encapsulator::msgdma_mm_to_st_encapsulator() : msgdma_encapsulator(){
}

msgdma_mm_to_st_encapsulator::msgdma_mm_to_st_encapsulator(
		std::string device_name) : msgdma_encapsulator(device_name) {
}

int msgdma_mm_to_st_encapsulator::execute(unsigned long addr,
		unsigned long length_in_words) {

	if (this->get_device_ptr() == NULL) {
		safe_print(std::cout << "Error: msgdma_mm_to_st_encapsulator::execute device PTR is NULL for device (" << device_name << ")!" << std::endl);
		return LINNUX_RETVAL_ERROR;
	}

	alt_msgdma_construct_standard_mm_to_st_descriptor (
			 this->get_device_ptr(),
			 &work_descriptor,
			 (alt_u32 *)addr,
			 length_in_words*4,
			 this->get_control_word()
			);

	return alt_msgdma_standard_descriptor_sync_transfer (
			                                             this->get_device_ptr(),
			                                             &work_descriptor
			                                            );
}

int msgdma_mm_to_st_encapsulator::execute_async(unsigned long addr,
		unsigned long length_in_words, bool silent) {

	if (this->get_device_ptr() == NULL) {
		if (!silent) {
		  safe_print(std::cout << "Error: msgdma_mm_to_st_encapsulator::execute_async device PTR is NULL for device (" << device_name << ")!" << std::endl);
		}
		return LINNUX_RETVAL_ERROR;
	}

	alt_msgdma_construct_standard_mm_to_st_descriptor (
			 this->get_device_ptr(),
			 &work_descriptor,
			 (alt_u32 *)addr,
			 length_in_words*4,
			 this->get_async_control_word()
			);

	return alt_msgdma_standard_descriptor_async_transfer (
			                                             this->get_device_ptr(),
			                                             &work_descriptor
			                                            );
}

int msgdma_mm_to_st_encapsulator::silent_execute_async(unsigned long addr,
		unsigned long length_in_words) {

	if (this->get_device_ptr() == NULL) {
		return LINNUX_RETVAL_ERROR;
	}

	alt_msgdma_construct_standard_mm_to_st_descriptor (
			 this->get_device_ptr(),
			 &work_descriptor,
			 (alt_u32 *)addr,
			 length_in_words*4,
			 this->get_async_control_word()
			);

	return alt_msgdma_standard_descriptor_async_transfer (
			                                             this->get_device_ptr(),
			                                             &work_descriptor
			                                            );
}

msgdma_mm_to_mm_encapsulator::msgdma_mm_to_mm_encapsulator() : msgdma_encapsulator() {
}

msgdma_mm_to_mm_encapsulator::msgdma_mm_to_mm_encapsulator(
		std::string device_name) : msgdma_encapsulator(device_name) {
}

int msgdma_mm_to_mm_encapsulator::execute(unsigned long source_addr,
		unsigned long dest_addr, unsigned long length_in_words) {
	if (this->get_device_ptr() == NULL) {
			safe_print(std::cout << "Error: msgdma_mm_to_mm_encapsulator::execute device PTR is NULL for device (" << device_name << ")!" << std::endl);
			return LINNUX_RETVAL_ERROR;
		}

	alt_msgdma_construct_standard_mm_to_mm_descriptor (
				 this->get_device_ptr(),
				 &work_descriptor,
				 (alt_u32 *)source_addr,
				 (alt_u32 *)dest_addr,
				 length_in_words*4,
				 this->get_control_word()
				);

		return alt_msgdma_standard_descriptor_sync_transfer (
				                                             this->get_device_ptr(),
				                                             &work_descriptor
				                                            );
	}
int msgdma_mm_to_mm_encapsulator::execute_async(unsigned long source_addr,
		unsigned long dest_addr, unsigned long length_in_words) {
	if (this->get_device_ptr() == NULL) {
			safe_print(std::cout << "Error: msgdma_mm_to_mm_encapsulator::execute_async device PTR is NULL for device (" << device_name << ")!" << std::endl);
			return LINNUX_RETVAL_ERROR;
		}

	alt_msgdma_construct_standard_mm_to_mm_descriptor (
				 this->get_device_ptr(),
				 &work_descriptor,
				 (alt_u32 *)source_addr,
				 (alt_u32 *)dest_addr,
				 length_in_words*4,
				 this->get_async_control_word()
				);

		return alt_msgdma_standard_descriptor_async_transfer (
				                                             this->get_device_ptr(),
				                                             &work_descriptor
				                                            );
	}


} /* namespace msgdma */
