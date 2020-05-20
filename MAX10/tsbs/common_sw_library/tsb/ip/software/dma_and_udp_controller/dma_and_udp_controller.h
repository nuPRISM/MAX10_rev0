/*
 * dma_and_udp_controller.h
 *
 *  Created on: May 1, 2015
 *      Author: yairlinn
 */

#ifndef DMA_AND_UDP_CONTROLLER_H_
#define DMA_AND_UDP_CONTROLLER_H_
#include "smart_buffer.h"
#include "msgdma_encapsulator.h"
#include <string>
#include "basedef.h"
#include "semaphore_locking_class.h"


namespace dmaudpctrl {

class dma_and_udp_controller;

class dma_and_fifo_coupling_enapsulator {


protected:
	msgdma::msgdma_mm_to_st_encapsulator* msgma_to_st_out_ptr;
	dmaudpctrl::dma_and_udp_controller* encapsulating_dma_to_udp_inst;
	unsigned long fifo_in_base;
	unsigned long fifo_out_base;
	unsigned long fifo_csr_base;

public:
	unsigned long get_fifo_out_base() const {
		return fifo_out_base;
	}

	void set_fifo_out_base(unsigned long fifoOutBase) {
		fifo_out_base = fifoOutBase;
	}

	msgdma::msgdma_mm_to_st_encapsulator* get_msgma_to_st_out_ptr() const {
		return msgma_to_st_out_ptr;
	}

	void set_msgma_to_st_out_ptr(
			msgdma::msgdma_mm_to_st_encapsulator* msgmaToStOutPtr) {
		msgma_to_st_out_ptr = msgmaToStOutPtr;
	}

	unsigned long get_fifo_csr_base() const {
		return fifo_csr_base;
	}

	void set_fifo_csr_base(unsigned long fifoCsrBase) {
		fifo_csr_base = fifoCsrBase;
	}

	unsigned long get_fifo_in_base() const {
		return fifo_in_base;
	}

	void set_fifo_in_base(unsigned long fifoInBase) {
		fifo_in_base = fifoInBase;
	}

	dmaudpctrl::dma_and_udp_controller* get_encapsulating_dma_to_udp_inst() {
		return encapsulating_dma_to_udp_inst;
	}

	void set_encapsulating_dma_to_udp_inst(
			 dmaudpctrl::dma_and_udp_controller* encapsulatingDmaToUdpInst) {
		encapsulating_dma_to_udp_inst = encapsulatingDmaToUdpInst;
	}
};

class enhanced_dma_and_fifo_coupling_enapsulator : public dma_and_fifo_coupling_enapsulator {

protected:
	const static unsigned long long default_timestamp_concordance_mask = 0xFFFFFF;
	unsigned long current_smart_buf;
	unsigned long long timestamp;
	unsigned long long timestamp_concordance_mask;

public:

	enhanced_dma_and_fifo_coupling_enapsulator() {
		current_smart_buf = 0;
		timestamp = 0;
		timestamp_concordance_mask = default_timestamp_concordance_mask;
	}

	unsigned long get_current_smart_buf() const {
		return current_smart_buf;
	}

	void set_current_smart_buf(unsigned long currentSmartBuf) {
		current_smart_buf = currentSmartBuf;
	}

	unsigned long long get_timestamp() const {
		return timestamp;
	}

	void set_timestamp(unsigned long long timestamp) {
		this->timestamp = timestamp;
	}

	unsigned long long get_default_timestamp_concordance_mask()  {
		return default_timestamp_concordance_mask;
	}

	unsigned long long get_timestamp_concordance_mask() const {
		return timestamp_concordance_mask;
	}

	void set_timestamp_concordance_mask(
			unsigned long long timestampConcordanceMask) {
		timestamp_concordance_mask = timestampConcordanceMask;
	}
};

class dma_and_udp_controller : public semaphore_locking_class {
protected:
	const static unsigned int NUM_WORDS_INDIGINOUS_PREAMBLE = TOTAL_DMA_SMART_BUFFER_PREAMBLE_WORDS-DMA_SMART_BUFFER_PREAMBLE_WORDS;
	unsigned long base_address_for_relative_addresses;
	msgdma::msgdma_mm_to_st_encapsulator* msgdma0_ptr;
	msgdma::msgdma_mm_to_mm_encapsulator* msgdma_mm_to_mm_0_ptr;
	smartbuf::smart_buffer_repository* dma_smart_buffers_ptr;
	bool fifo_enabled;

    int internal_dma_to_ddr_transfer(
    		unsigned long  source_address,
    		alt_u32* current_smart_buf,
    		unsigned long  length_in_words,
    		unsigned long  preamble[],
    		unsigned long  preamble_length,
    		unsigned long  smart_buf_num,
    		bool async_transfer,
    		int& async_operation_executed
    		);

    int internal_dma_to_udp_transfer(
    		    alt_u32* current_smart_buf,
        		unsigned long  length_in_words,
        		bool async_transfer
        	);

    int isr_safe_async_internal_dma_to_udp_transfer(
     		    alt_u32* current_smart_buf,
         		unsigned long  length_in_words);

    dma_and_fifo_coupling_enapsulator fifo_coupling_info;
public:
	dma_and_udp_controller();
	dma_and_udp_controller(msgdma::msgdma_mm_to_mm_encapsulator* msgdma_mm_to_mm_0_ptr,
			msgdma::msgdma_mm_to_st_encapsulator* msgdma0_ptr,
			smartbuf::smart_buffer_repository* dma_smart_buffers_ptr,
			unsigned long base_address_for_relative_addresses,
			unsigned long fifo_in_base_address = 0,
			unsigned long fifo_out_base_address= 0,
		    unsigned long fifo_csr_base_address = 0,
		    OS_EVENT* semaphore_ptr = NULL,
		    bool fifo_enabled = 0
    );

	unsigned long get_smart_buf_payload_start_addr(unsigned long smart_buf_num);
	unsigned long get_smart_buf_start_addr(unsigned long smart_buf_num);

	std::string dma_to_udp_transfer(

	    		unsigned long  smart_buf_num,
	    		bool async_udp_transfer = false
	    		);
	int isr_safe_async_dma_to_udp_transfer(
	    		unsigned long  smart_buf_num
	    		);
    std::string dma_to_ddr_transfer(
    		unsigned long  source_address,
    		unsigned long  smart_buf_num,
    		unsigned long  length_in_words,
    		unsigned long  preamble[],
    		unsigned long  preamble_length,
    		bool async_transfer = false
    		);

    std::string relative_dma_to_ddr_transfer(
      		unsigned long  relative_source_address,
      		unsigned long  smart_buf_num,
      		unsigned long  length_in_words,
      		unsigned long  preamble[],
      		unsigned long  preamble_length,
      		bool async_transfer = false
      		);

    std::string dma_to_udp_via_ddr_transfer(
    		unsigned long  source_address,
    		unsigned long  smart_buf_num,
    		unsigned long  length_in_words,
    		unsigned long  preamble[],
    		unsigned long  preamble_length,
    		bool async_udp_transfer = false,
    		bool async_mm_transfer = false
    		);


    std::string relative_dma_to_udp_via_ddr_transfer(
      		unsigned long  relative_source_address,
      		unsigned long  smart_buf_num,
      		unsigned long  length_in_words,
      		unsigned long  preamble[],
      		unsigned long  preamble_length,
    		bool async_udp_transfer = false,
    		bool async_mm_transfer = false

      		);

	virtual ~dma_and_udp_controller();

	const smartbuf::smart_buffer_repository* get_dma_smart_buffers_ptr() const {
		return dma_smart_buffers_ptr;
	}

	void set_dma_smart_buffers_ptr(
			smartbuf::smart_buffer_repository* dmaSmartBuffersPtr) {
		dma_smart_buffers_ptr = dmaSmartBuffersPtr;
	}

	const msgdma::msgdma_mm_to_mm_encapsulator* get_msgdma_mm_to_mm_0_ptr() const {
		return msgdma_mm_to_mm_0_ptr;
	}

	void set_msgdma_mm_to_mm_0_ptr(
			msgdma::msgdma_mm_to_mm_encapsulator* msgdmaMmToMm0Ptr) {
		msgdma_mm_to_mm_0_ptr = msgdmaMmToMm0Ptr;
	}

	const msgdma::msgdma_mm_to_st_encapsulator* get_msgdma0_ptr() const {
		return msgdma0_ptr;
	}

	void set_msgdma0_ptr(
			msgdma::msgdma_mm_to_st_encapsulator* msgdma0Ptr) {
		msgdma0_ptr = msgdma0Ptr;
		this->fifo_coupling_info.set_msgma_to_st_out_ptr(msgdma0_ptr);
	}

	unsigned long get_base_address_for_relative_addresses() const {
		return base_address_for_relative_addresses;
	}

	void set_base_address_for_relative_addresses(
			unsigned long baseAddressForRelativeAddresses) {
		base_address_for_relative_addresses = baseAddressForRelativeAddresses;
	}

	const dma_and_fifo_coupling_enapsulator& get_fifo_coupling_info() const {
		return fifo_coupling_info;
	}

	void set_fifo_coupling_info(
			const dma_and_fifo_coupling_enapsulator& fifoCouplingInfo) {
		fifo_coupling_info = fifoCouplingInfo;
	}

    dma_and_fifo_coupling_enapsulator* get_fifo_coupling_info_ptr() const {
		return &fifo_coupling_info;
	}

	bool isfifo_enabled() const {
		return fifo_enabled;
	}

	void set_fifo_enabled(bool fifoEnabled) {
		fifo_enabled = fifoEnabled;
	}
};


} /* namespace dmaudpctrl */

#endif /* DMA_AND_UDP_CONTROLLER_H_ */
