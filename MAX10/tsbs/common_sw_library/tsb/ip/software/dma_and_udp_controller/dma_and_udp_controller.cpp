/*
 * dma_and_udp_controller.cpp
 *
 *  Created on: May 1, 2015
 *      Author: yairlinn
 */
#include "basedef.h"
#include "dma_and_udp_controller.h"
#include "global_stream_defs.hpp"
#include "linnux_utils.h"
#include "semaphore_locking_class.h"

#include <sstream>

extern "C" {
#include "altera_avalon_fifo_regs.h"
#include "altera_avalon_fifo_util.h"
}

#define err_do(x) do { if (ENABLE_DMA_AND_UDP_CONTROLLER_ERROR_REPORTING) { x; } } while (0)
namespace dmaudpctrl {

dma_and_udp_controller::dma_and_udp_controller() : semaphore_locking_class() {
	this->set_msgdma0_ptr(NULL);
	this->set_msgdma_mm_to_mm_0_ptr(NULL);
	this->set_dma_smart_buffers_ptr(NULL);
	this->set_base_address_for_relative_addresses(0);
	this->fifo_coupling_info.set_fifo_out_base(0);
	this->fifo_coupling_info.set_fifo_in_base(0);
	this->fifo_coupling_info.set_fifo_csr_base(0);
	this->fifo_coupling_info.set_encapsulating_dma_to_udp_inst(this);
	this->set_fifo_enabled(0);
}
unsigned long dma_and_udp_controller::get_smart_buf_start_addr(unsigned long  smart_buf_num) {
    alt_u32* current_smart_buf;

	    current_smart_buf = dma_smart_buffers_ptr->get_buffer(smart_buf_num);
		if (current_smart_buf == NULL) {
			err_do(
			  out_to_all_streams("Error: get_smart_buf_payload_start_addr: current smart buf is NULL, index is " << smart_buf_num << "\n");
			);
			return 0;
		}
		return ((unsigned long) (current_smart_buf));
}
unsigned long dma_and_udp_controller::get_smart_buf_payload_start_addr(unsigned long  smart_buf_num) {
        alt_u32* current_smart_buf;
	    current_smart_buf = dma_smart_buffers_ptr->get_buffer(smart_buf_num);
		if (current_smart_buf == NULL) {
			err_do(
			  out_to_all_streams("Error: get_smart_buf_payload_start_addr: current smart buf is NULL, index is " << smart_buf_num << "\n");
			);
			return 0;
		}
		return (((unsigned long) (current_smart_buf)) + (TOTAL_DMA_SMART_BUFFER_PREAMBLE_WORDS)*4);
}
dma_and_udp_controller::dma_and_udp_controller(
		msgdma::msgdma_mm_to_mm_encapsulator* msgdma_mm_to_mm_0_ptr,
		msgdma::msgdma_mm_to_st_encapsulator* msgdma0_ptr,
		smartbuf::smart_buffer_repository*     dma_smart_buffers_ptr,
		unsigned long base_address_for_relative_addresses,
		unsigned long fifo_in_base_address,
	    unsigned long fifo_out_base_address,
	    unsigned long fifo_csr_base_address,
	    OS_EVENT* semaphore_ptr,
	    bool fifo_enabled

)  :  semaphore_locking_class (semaphore_ptr) {
	this->set_msgdma0_ptr(msgdma0_ptr);
	this->set_msgdma_mm_to_mm_0_ptr(msgdma_mm_to_mm_0_ptr);
	this->set_dma_smart_buffers_ptr(dma_smart_buffers_ptr);
	this->set_base_address_for_relative_addresses(base_address_for_relative_addresses);
	this->fifo_coupling_info.set_fifo_out_base(fifo_out_base_address);
	this->fifo_coupling_info.set_fifo_in_base(fifo_in_base_address);
	this->fifo_coupling_info.set_fifo_csr_base(fifo_csr_base_address);
	this->fifo_coupling_info.set_encapsulating_dma_to_udp_inst(this);
	this->set_fifo_enabled(fifo_enabled);
}

dma_and_udp_controller::~dma_and_udp_controller() {
	// TODO Auto-generated destructor stub
}

int dma_and_udp_controller::internal_dma_to_ddr_transfer(
		unsigned long  source_address,
		alt_u32* current_smart_buf,
		unsigned long  length_in_words,
		unsigned long  preamble[],
		unsigned long  preamble_length,
		unsigned long  smart_buf_num,
		bool async_transfer,
		int& async_operation_executed
		) {


   	    unsigned long long current_hw_timestamp;

	    if (current_smart_buf == NULL) {
			return LINNUX_RETVAL_ERROR;
		}

	    current_hw_timestamp = os_critical_low_level_system_timestamp();

	    current_smart_buf[0] = BASE_INITIAL_WORD_FOR_SW_DMA_TRANSATIONS + ((smart_buf_num & 0xFF) << 16) + length_in_words + NUM_WORDS_INDIGINOUS_PREAMBLE + preamble_length;
	    current_smart_buf[1] = source_address;
	    current_smart_buf[2] = (current_hw_timestamp >> 32) & 0xFFFFFFFF;
	    current_smart_buf[3] = current_hw_timestamp & 0xFFFFFFFF;
	    current_smart_buf[5] = 0; //reserved

		for (unsigned int i = 0; i < preamble_length; i++) {
			current_smart_buf[NUM_WORDS_INDIGINOUS_PREAMBLE+i] = preamble[i];
		}
		int retval;

		async_operation_executed = 0;
		INT8U semaphore_err;

		//TODO: add wait loop with timeout to see if there is descriptor space
		if (async_transfer && this->isfifo_enabled()) {
#if SUPPORT_ASYNC_DMA_MM_TO_MM_MODE

			unsigned long fifo_data = ((current_hw_timestamp & 0x00FFFFFF) << 8) + smart_buf_num;

			lock();
			if (altera_avalon_fifo_write_fifo(this->fifo_coupling_info.get_fifo_in_base(),
					this->fifo_coupling_info.get_fifo_csr_base(),
					fifo_data) == ALTERA_AVALON_FIFO_FULL) {
				out_to_all_streams("Error: internal_dma_to_ddr_transfer: altera_avalon_fifo_write_fifo: FIFO is full; doing sync transfer instead of async transfer. smart buf =  "
						<< smart_buf_num << std::hex <<
						"source_address = 0x" << source_address << " timestamp = 0x"<< current_hw_timestamp << std::dec << std::endl);
				retval = msgdma_mm_to_mm_0_ptr->execute((unsigned long)source_address,current_smart_buf+NUM_WORDS_INDIGINOUS_PREAMBLE+preamble_length,length_in_words);
			} else {

			    retval = msgdma_mm_to_mm_0_ptr->execute_async((unsigned long)source_address,current_smart_buf+NUM_WORDS_INDIGINOUS_PREAMBLE+preamble_length,length_in_words);
			    async_operation_executed = 1;
			}
#else
			retval = msgdma_mm_to_mm_0_ptr->execute((unsigned long)source_address,current_smart_buf+NUM_WORDS_INDIGINOUS_PREAMBLE+preamble_length,length_in_words);
#endif
		} else {
			retval = msgdma_mm_to_mm_0_ptr->execute((unsigned long)source_address,current_smart_buf+NUM_WORDS_INDIGINOUS_PREAMBLE+preamble_length,length_in_words);
		}
		current_smart_buf[4] = (alt_u32)((-retval));

		if (async_transfer && this->isfifo_enabled()) {
           unlock();
		}

		err_do(
				if (retval != 0) {
					out_to_all_streams("Error: internal_dma_to_ddr_transfer: got error value of: " << retval << std::endl);
					out_to_all_streams("Error: internal_dma_to_ddr_transfer: got error value of: " << retval << std::hex << " For transfer from smart buffer ptr: 0x" << (unsigned long) current_smart_buf << std::dec << " packet length in words: " << length_in_words << std::endl)
					for (unsigned int i = 0; i < preamble_length+NUM_WORDS_INDIGINOUS_PREAMBLE; i++) {
						out_to_all_streams("Preamble("<< i << ") = " << std::hex << ((unsigned long) (i < NUM_WORDS_INDIGINOUS_PREAMBLE ? current_smart_buf [i] : current_smart_buf[NUM_WORDS_INDIGINOUS_PREAMBLE+i])) <<
													 std::dec << std::endl);
							}
				}
		);

		return retval;

}

int dma_and_udp_controller::internal_dma_to_udp_transfer(
		    alt_u32* current_smart_buf,
    		unsigned long  length_in_words,
    		bool async_transfer
    		){
	if (current_smart_buf == NULL) {
			return LINNUX_RETVAL_ERROR;
	}
	int retval;
	if (async_transfer) {
		retval = msgdma0_ptr->execute_async((unsigned long)current_smart_buf,length_in_words);
	} else {
		retval = msgdma0_ptr->execute((unsigned long)current_smart_buf,length_in_words);
		err_do(
			if (retval != 0) {
					out_to_all_streams("Error: internal_dma_to_udp_transfer: got error value of: " << retval << std::hex << " For transfer from smart buffer ptr: 0x" << (unsigned long) current_smart_buf << std::dec << " length: " << length_in_words << std::endl);
			}
		);
	}

	return retval;
}

int dma_and_udp_controller::isr_safe_async_internal_dma_to_udp_transfer(
		    alt_u32* current_smart_buf,
    		unsigned long  length_in_words
    		){
	if (current_smart_buf == NULL) {
			return LINNUX_RETVAL_ERROR;
	}

	int retval;
	retval = msgdma0_ptr->silent_execute_async((unsigned long)current_smart_buf,length_in_words);

	return retval;
}


std::string dma_and_udp_controller::dma_to_udp_via_ddr_transfer(
		unsigned long  source_address,
		unsigned long  smart_buf_num,
		unsigned long  length_in_words,
		unsigned long  preamble[],
		unsigned long  preamble_length,
		bool async_udp_transfer,
		bool async_mm_transfer
){
    std::ostringstream result_str;
	alt_u32* current_smart_buf;
	int async_operation_executed;
	current_smart_buf = dma_smart_buffers_ptr->get_buffer(smart_buf_num);
	if (current_smart_buf == NULL) {
		err_do(
		  out_to_all_streams("Error: dma_to_udp_via_ddr: current smart buf is NULL, index is " << smart_buf_num << "\n");
		);
		result_str << -1;
		return result_str.str();
	}

	if ((length_in_words+NUM_WORDS_INDIGINOUS_PREAMBLE+preamble_length) > dma_smart_buffers_ptr->get_size_per_buf()) {
		    err_do(
			   out_to_all_streams("Error: dma_to_udp_via_ddr: current smart buf size is " << dma_smart_buffers_ptr->get_size_per_buf() << " but length of transfer including preamble is " << (length_in_words+NUM_WORDS_INDIGINOUS_PREAMBLE+preamble_length) << " words! Transfer would cause buffer overflow, transfer aborted\n");
		    );
			result_str << -1;
			return result_str.str();

	}

	internal_dma_to_ddr_transfer(source_address,current_smart_buf,length_in_words,preamble,preamble_length,smart_buf_num,async_mm_transfer,async_operation_executed);
	if (!async_mm_transfer || (!SUPPORT_ASYNC_DMA_MM_TO_MM_MODE) || (!async_operation_executed)) {
	   internal_dma_to_udp_transfer(current_smart_buf,length_in_words+NUM_WORDS_INDIGINOUS_PREAMBLE+preamble_length,async_udp_transfer);
	} else {
        //async operation will execute on its own, prompted by isr
	}
	result_str << (unsigned long) current_smart_buf;
	return result_str.str();
}


std::string dma_and_udp_controller::dma_to_ddr_transfer(
		unsigned long  source_address,
		unsigned long  smart_buf_num,
		unsigned long  length_in_words,
		unsigned long  preamble[],
		unsigned long  preamble_length,
		bool async_transfer
){
    std::ostringstream result_str;
	alt_u32* current_smart_buf;
	int async_operation_executed;
	current_smart_buf = dma_smart_buffers_ptr->get_buffer(smart_buf_num);

	if (current_smart_buf == NULL) {
		    err_do(
			  out_to_all_streams("Error: dma_to_udp_via_ddr: current smart buf is NULL, index is " << smart_buf_num << "\n");
		    );
			result_str << -1;
			return result_str.str();
	}

	if ((length_in_words+NUM_WORDS_INDIGINOUS_PREAMBLE+preamble_length) > dma_smart_buffers_ptr->get_size_per_buf()) {
			err_do(
					out_to_all_streams("Error: dma_to_udp_via_ddr: current smart buf size is " << dma_smart_buffers_ptr->get_size_per_buf() << " but length of transfer including preamble is " << (length_in_words+NUM_WORDS_INDIGINOUS_PREAMBLE+preamble_length) << " words! Transfer would cause buffer overflow, transfer aborted\n");
		    );
			result_str << -1;
			return result_str.str();

	}

    internal_dma_to_ddr_transfer(source_address,current_smart_buf,length_in_words,preamble,preamble_length,smart_buf_num,async_transfer,async_operation_executed);

	result_str << (unsigned long) current_smart_buf;
	return result_str.str();
}

std::string dma_and_udp_controller::dma_to_udp_transfer(
		unsigned long  smart_buf_num,
		bool async_udp_transfer
	){
    std::ostringstream result_str;
	alt_u32* current_smart_buf;
	unsigned long  length_in_words;

	current_smart_buf = dma_smart_buffers_ptr->get_buffer(smart_buf_num);

	if (current_smart_buf == NULL) {
		err_do(
		out_to_all_streams("Error: dma_to_udp_via_ddr: current smart buf is NULL, index is " << smart_buf_num << "\n");
		);
		result_str << -1;
		return result_str.str();
	}

	length_in_words = current_smart_buf[0] & 0xFFFF;
	internal_dma_to_udp_transfer(current_smart_buf,length_in_words,async_udp_transfer);
	result_str << (unsigned long) current_smart_buf;
	return result_str.str();
}
int dma_and_udp_controller::isr_safe_async_dma_to_udp_transfer(
    		unsigned long  smart_buf_num
    		)
{
   alt_u32* current_smart_buf;
	unsigned long  length_in_words;

	current_smart_buf = dma_smart_buffers_ptr->silent_get_buffer(smart_buf_num);

	if (current_smart_buf == NULL) {
				return LINNUX_RETVAL_ERROR;
	}
	length_in_words = current_smart_buf[0] & 0xFFFF;
    return isr_safe_async_internal_dma_to_udp_transfer(current_smart_buf,length_in_words);
}

std::string dma_and_udp_controller::relative_dma_to_ddr_transfer(
   		unsigned long  relative_source_address,
   		unsigned long  smart_buf_num,
   		unsigned long  length_in_words,
   		unsigned long  preamble[],
   		unsigned long  preamble_length,
   		bool async_transfer
   		) {
	return this->dma_to_ddr_transfer(
			this->get_base_address_for_relative_addresses() + relative_source_address,
			smart_buf_num,
			length_in_words,
			preamble,
			preamble_length,
			async_transfer
		);
}


std::string dma_and_udp_controller::relative_dma_to_udp_via_ddr_transfer(
   		unsigned long  relative_source_address,
   		unsigned long  smart_buf_num,
   		unsigned long  length_in_words,
   		unsigned long  preamble[],
   		unsigned long  preamble_length,
   		bool async_udp_transfer,
		bool async_mm_transfer

   		) {

	return this->dma_to_udp_via_ddr_transfer(
			this->get_base_address_for_relative_addresses() + relative_source_address,
			smart_buf_num,
			length_in_words,
			preamble,
			preamble_length,
			async_udp_transfer,
    		async_mm_transfer
		);
}


} /* namespace dmaudpctrl */
