/*
 * simple_msgdma.cpp
 *
 *  Created on: Apr 29, 2015
 *      Author: yairlinn
 */

#include "simple_msgdma.h"
#include <stdio.h>
#include <iostream>
#include <sstream>
#include <unistd.h>
#include "sys/alt_errno.h"
#include "sys/alt_irq.h"
#include "sys/alt_stdio.h"

namespace simple_msgdma {


simple_msgdma::simple_msgdma(std::string device_name)
{
    this->set_device_name(device_name);
	this->set_device_ptr(this->open());
	control_word = 0;
}

simple_msgdma::simple_msgdma()
{
	control_word = 0;
}

alt_msgdma_dev* simple_msgdma::open()
{
	this->set_device_ptr(alt_msgdma_open (this->get_device_name().c_str()));
  return this->get_device_ptr();
}

bool simple_msgdma::start() {

    	unsigned long control1 = IORD_ALTERA_MSGDMA_CSR_CONTROL(this->get_device_ptr()->csr_base) & (~ALTERA_MSGDMA_CSR_STOP_DESCRIPTORS_MASK);
        IOWR_ALTERA_MSGDMA_CSR_CONTROL(this->get_device_ptr()->csr_base, control1);

    	usleep(NUM_US_TO_WAIT_FOR_CSR_OPERATION);

    	unsigned long status1 = IORD_ALTERA_MSGDMA_CSR_STATUS(this->get_device_ptr()->csr_base);
    	if ((status1 & ALTERA_MSGDMA_CSR_STOP_STATE_MASK) != 0) {
    		std::cout << "Error: simple_msgdma::start for device " << device_name << " did not come out of reset state!" << std::endl;
    		return false;
    	}
    	return true;
 }


bool simple_msgdma::do_sw_reset() {

	unsigned long control1 = IORD_ALTERA_MSGDMA_CSR_CONTROL(this->get_device_ptr()->csr_base) | (ALTERA_MSGDMA_CSR_RESET_MASK);
    IOWR_ALTERA_MSGDMA_CSR_CONTROL(this->get_device_ptr()->csr_base, control1);

	usleep(NUM_US_TO_WAIT_FOR_CSR_OPERATION);

	unsigned long status1 = IORD_ALTERA_MSGDMA_CSR_STATUS(this->get_device_ptr()->csr_base);
	if ((status1 & ALTERA_MSGDMA_CSR_RESET_STATE_MASK) != 0) {
		std::cout << "Error: simple_msgdma::do_sw_reset for device " << device_name << " did not come out of reset state!" << std::endl;
		return false;
	}
	return true;
}


int simple_msgdma::wait_until_not_busy(alt_u32 timeout_us) {
	alt_msgdma_dev* dev = this->get_device_ptr();

	alt_u32 counter = 0; /* reset counter */
	alt_u32 error = 0;
    alt_u32 csr_status = 0;
    alt_u32 control=0;
    alt_irq_context context=0;
    /*
        * When running in a multi threaded environment, obtain the "regs_lock"
        * semaphore. This ensures that accessing registers is thread-safe.
        */
   	ALT_SEM_PEND (dev->regs_lock, 0);

	csr_status = IORD_ALTERA_MSGDMA_CSR_STATUS(dev->csr_base);

    /* Wait for any pending transfers to complete or checking any errors or
    conditions causing descriptor to stop dispatching */
    while (!(csr_status & error) && (csr_status & ALTERA_MSGDMA_CSR_BUSY_MASK))
    {
        usleep(1); /* delay 1us */
        if(timeout_us <= counter) /* time_out if waiting longer than timeout */
        {
            alt_printf("time out after while waiting for any pending"
				" transfer complete\n");

			/*
			* Now that access to the registers is complete, release the registers
			* semaphore so that other threads can access the registers.
			*/
			ALT_SEM_POST (dev->regs_lock);

            return -ETIME;
        }
        counter++;
        csr_status = IORD_ALTERA_MSGDMA_CSR_STATUS(dev->csr_base);
    }


    /*Errors or conditions causing the dispatcher stopping issuing read/write
      commands to masters*/
    if(0 != (csr_status & error))
    {
		/*
		* Now that access to the registers is complete, release the registers
		* semaphore so that other threads can access the registers.
		*/
		ALT_SEM_POST (dev->regs_lock);

        return error;
    }

    /* Stop the msgdma dispatcher from issuing more descriptors to the
    read or write masters  */
    /* stop issuing more descriptors */
    control = IORD_ALTERA_MSGDMA_CSR_CONTROL(dev->csr_base) |
	ALTERA_MSGDMA_CSR_STOP_DESCRIPTORS_MASK;
    /* making sure the read-modify-write below can't be pre-empted */
    context = alt_irq_disable_all();
    IOWR_ALTERA_MSGDMA_CSR_CONTROL(dev->csr_base, control);
    /*
    * Clear any (previous) status register information
    * that might occlude our error checking later.
    */
    IOWR_ALTERA_MSGDMA_CSR_STATUS(
    	dev->csr_base,
		IORD_ALTERA_MSGDMA_CSR_STATUS(dev->csr_base));
    	alt_irq_enable_all(context);

	/*
	* Now that access to the registers is complete, release the registers
	* semaphore so that other threads can access the registers.
	*/
    ALT_SEM_POST (dev->regs_lock);

    return 0;
}

int simple_msgdma::simple_wait_until_not_busy() {
	alt_msgdma_dev* dev = this->get_device_ptr();

	alt_u32 counter = 0; /* reset counter */
	alt_u32 error = 0;
    alt_u32 csr_status = 0;

	csr_status = IORD_ALTERA_MSGDMA_CSR_STATUS(dev->csr_base);

    /* Wait for any pending transfers to complete or checking any errors or
    conditions causing descriptor to stop dispatching */
    while (!(csr_status & error) && (csr_status & ALTERA_MSGDMA_CSR_BUSY_MASK))
    {
        csr_status = IORD_ALTERA_MSGDMA_CSR_STATUS(dev->csr_base);
    }


    /*Errors or conditions causing the dispatcher stopping issuing read/write
      commands to masters*/
    if(0 != (csr_status & error))
    {
		return error;
    }

    return 0;
}




simple_msgdma::~simple_msgdma() {
	// TODO Auto-generated destructor stub
}

simple_msgdma_mm_to_st_encapsulator::simple_msgdma_mm_to_st_encapsulator() : simple_msgdma(){
}

simple_msgdma_mm_to_st_encapsulator::simple_msgdma_mm_to_st_encapsulator(
		std::string device_name) : simple_msgdma(device_name) {
}

int simple_msgdma_mm_to_st_encapsulator::execute(unsigned long addr,
		unsigned long length_in_bytes) {

	if (this->get_device_ptr() == NULL) {
		std::cout << "Error: simple_msgdma_mm_to_st_encapsulator::execute device PTR is NULL for device (" << device_name << ")!" << std::endl;
		return -1;
	}

	alt_msgdma_construct_standard_mm_to_st_descriptor (
			 this->get_device_ptr(),
			 &work_descriptor,
			 (alt_u32 *)addr,
			 length_in_bytes,
			 this->get_control_word()
			);

	return alt_msgdma_standard_descriptor_sync_transfer (
			                                             this->get_device_ptr(),
			                                             &work_descriptor
			                                            );
}

int simple_msgdma_mm_to_st_encapsulator::execute_async(unsigned long addr,
		unsigned long length_in_bytes, bool silent) {

	if (this->get_device_ptr() == NULL) {
		if (!silent) {
		  std::cout << "Error: simple_msgdma_mm_to_st_encapsulator::execute_async device PTR is NULL for device (" << device_name << ")!" << std::endl;
		}
		return -1;
	}

	alt_msgdma_construct_standard_mm_to_st_descriptor (
			 this->get_device_ptr(),
			 &work_descriptor,
			 (alt_u32 *)addr,
			 length_in_bytes,
			 this->get_async_control_word()
			);

	return alt_msgdma_standard_descriptor_async_transfer (
			                                             this->get_device_ptr(),
			                                             &work_descriptor
			                                            );
}

int simple_msgdma_mm_to_st_encapsulator::silent_execute_async(unsigned long addr,
		unsigned long length_in_bytes) {

	if (this->get_device_ptr() == NULL) {
		return -1;
	}

	alt_msgdma_construct_standard_mm_to_st_descriptor (
			 this->get_device_ptr(),
			 &work_descriptor,
			 (alt_u32 *)addr,
			 length_in_bytes,
			 this->get_async_control_word()
			);

	return alt_msgdma_standard_descriptor_async_transfer (
			                                             this->get_device_ptr(),
			                                             &work_descriptor
			                                            );
}

simple_msgdma_mm_to_mm_encapsulator::simple_msgdma_mm_to_mm_encapsulator() : simple_msgdma() {
}

simple_msgdma_mm_to_mm_encapsulator::simple_msgdma_mm_to_mm_encapsulator(
		std::string device_name) : simple_msgdma(device_name) {
}

int simple_msgdma_mm_to_mm_encapsulator::execute(unsigned long source_addr,
		unsigned long dest_addr, unsigned long length_in_bytes) {
	if (this->get_device_ptr() == NULL) {
			std::cout << "Error: simple_msgdma_mm_to_mm_encapsulator::execute device PTR is NULL for device (" << device_name << ")!" << std::endl;
			return -1;
		}

	int retval = alt_msgdma_construct_standard_mm_to_mm_descriptor (
				 this->get_device_ptr(),
				 &work_descriptor,
				 (alt_u32 *)source_addr,
				 (alt_u32 *)dest_addr,
				 length_in_bytes,
				 this->get_control_word()
				);

	if (retval != 0) {
		std::cout << "Error: simple_msgdma_mm_to_mm_encapsulator::execute alt_msgdma_construct_standard_mm_to_mm_descriptor returned error (" << retval << ")!" << std::endl;
					return retval;
	}
		return alt_msgdma_standard_descriptor_sync_transfer (
				                                             this->get_device_ptr(),
				                                             &work_descriptor
				                                            );
}

int simple_msgdma_mm_to_mm_encapsulator::execute_async(unsigned long source_addr,
		unsigned long dest_addr, unsigned long length_in_bytes) {
	if (this->get_device_ptr() == NULL) {
			std::cout << "Error: simple_msgdma_mm_to_mm_encapsulator::execute_async device PTR is NULL for device (" << device_name << ")!" << std::endl;
			return -1;
		}

	alt_msgdma_construct_standard_mm_to_mm_descriptor (
				 this->get_device_ptr(),
				 &work_descriptor,
				 (alt_u32 *)source_addr,
				 (alt_u32 *)dest_addr,
				 length_in_bytes,
				 this->get_async_control_word()
				);

		return alt_msgdma_standard_descriptor_async_transfer (
				                                             this->get_device_ptr(),
				                                             &work_descriptor
				                                            );
	}


} /* namespace msgdma */
