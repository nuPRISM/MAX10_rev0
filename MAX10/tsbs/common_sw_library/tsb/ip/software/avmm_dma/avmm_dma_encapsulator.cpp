/*
 * avmm_dma_encapsulator.cpp
 *
 *  Created on: Oct 16, 2018
 *      Author: user
 */

#include "avmm_dma_encapsulator.h"
#include "altera_avalon_dma_regs.h"
#include "sys/alt_dma.h"

namespace avmm_dma {

void avmm_dma_encapsulator::set_read_address(alt_u32 x)  {IOWR_ALTERA_AVALON_DMA_RADDRESS(this->get_base_address(),x);  };
void avmm_dma_encapsulator::set_write_address(alt_u32 x) {IOWR_ALTERA_AVALON_DMA_WADDRESS(this->get_base_address(),x);  };
void avmm_dma_encapsulator::set_len(alt_u32 x)           {IOWR_ALTERA_AVALON_DMA_LENGTH  (this->get_base_address(),x);  };
alt_u32 avmm_dma_encapsulator::get_read_address()  {return IORD_ALTERA_AVALON_DMA_RADDRESS(this->get_base_address());   };
alt_u32 avmm_dma_encapsulator::get_write_address() {return IORD_ALTERA_AVALON_DMA_WADDRESS(this->get_base_address());   };
alt_u32 avmm_dma_encapsulator::get_len()           {return IORD_ALTERA_AVALON_DMA_LENGTH  (this->get_base_address());   };

avmm_dma_encapsulator::avmm_dma_encapsulator(unsigned long the_base_address,
			unsigned long span_in_bytes,
			std::string device_path,
			std::string name) : generic_driver_encapsulator (the_base_address,
					span_in_bytes,
					name)
           {
	this->set_device_path(device_path);


}

avmm_dma_error_type avmm_dma_encapsulator::open() {

		if ((this->txchan = alt_dma_txchan_open(this->get_device_path().c_str())) == NULL)
		{
			return DMA_ERROR_OPENING_TX;
		}

		if ((this->rxchan = alt_dma_rxchan_open(this->get_device_path().c_str())) == NULL)
		{
			return DMA_ERROR_OPENING_RX;
		}
		return DMA_OK;
}

avmm_dma_error_type
    avmm_dma_encapsulator::do_dma_transaction(alt_u32 src,
			alt_u32 dest,
			alt_u32 len,
			avmm_dma_transaction_type transaction_type
			) {

	halt_any_ongoing_dma_transaction();
	clear_done();
	alt_u32 mode;

	switch (transaction_type) {
		case BYTE_TRANSACTION       : mode = ALTERA_AVALON_DMA_CONTROL_BYTE_MSK; break;
		case HALFWORD_TRANSACTION   : mode = ALTERA_AVALON_DMA_CONTROL_HW_MSK; break;
		case WORD_TRANSACTION       : mode = ALTERA_AVALON_DMA_CONTROL_WORD_MSK; break;
		case DOUBLEWORD_TRANSACTION : mode = ALTERA_AVALON_DMA_CONTROL_DWORD_MSK; break;
		case QUADWORD_TRANSACTION   : mode = ALTERA_AVALON_DMA_CONTROL_QWORD_MSK; break;
	}

	this->set_read_address(src);
	this->set_write_address(dest);
	this->set_len(len);

	IOWR_ALTERA_AVALON_DMA_CONTROL
	(
	  this->get_base_address(),
	  mode      |
	  ALTERA_AVALON_DMA_CONTROL_GO_MSK        |
	  ALTERA_AVALON_DMA_CONTROL_LEEN_MSK
	);

	}

	void avmm_dma_encapsulator::halt_any_ongoing_dma_transaction() {
		IOWR_ALTERA_AVALON_DMA_CONTROL (this->get_base_address(), ALTERA_AVALON_DMA_CONTROL_SOFTWARERESET_MSK);
		IOWR_ALTERA_AVALON_DMA_CONTROL (this->get_base_address(), ALTERA_AVALON_DMA_CONTROL_SOFTWARERESET_MSK);
	}


	int avmm_dma_encapsulator::dma_is_busy() {
		return ((IORD_ALTERA_AVALON_DMA_STATUS(this->get_base_address()) & ALTERA_AVALON_DMA_STATUS_BUSY_MSK) != 0);
	}

	int avmm_dma_encapsulator::dma_is_done() {
		return ((IORD_ALTERA_AVALON_DMA_STATUS(this->get_base_address()) & ALTERA_AVALON_DMA_STATUS_DONE_MSK) != 0);
	}


	void avmm_dma_encapsulator::clear_done() {
		IOWR_ALTERA_AVALON_DMA_STATUS(this->get_base_address(),0);
	}


} /* namespace avmm_dma */
