/*
 * avmm_dma_encapsulator.h
 *
 *  Created on: Oct 16, 2018
 *      Author: user
 */

#ifndef AVMM_DMA_ENCAPSULATOR_H_
#define AVMM_DMA_ENCAPSULATOR_H_

#include "altera_avalon_dma.h"
#include "generic_driver_encapsulator.h"

#include <string>


namespace avmm_dma {

typedef enum {
	BYTE_TRANSACTION,
	HALFWORD_TRANSACTION,
	WORD_TRANSACTION,
	DOUBLEWORD_TRANSACTION,
	QUADWORD_TRANSACTION
} avmm_dma_transaction_type;


typedef enum {
	DMA_OK = 0,
	DMA_ERROR_OPENING_TX = 1,
	DMA_ERROR_OPENING_RX = 2
} avmm_dma_error_type;

class avmm_dma_encapsulator: public generic_driver_encapsulator {
protected:
	std::string device_path;
	alt_dma_txchan txchan;
	alt_dma_rxchan rxchan;


public:
	avmm_dma_encapsulator() : generic_driver_encapsulator() {};
	avmm_dma_encapsulator(unsigned long the_base_address,
			unsigned long span_in_bytes,
			std::string device_path,
			std::string name = "undefined");
	void set_read_address(alt_u32 x);
	void set_write_address(alt_u32 x);
	void set_len(alt_u32 x);
	alt_u32 get_read_address() ;
	alt_u32 get_write_address();
	alt_u32 get_len()          ;
	avmm_dma_error_type open();

	avmm_dma_error_type do_dma_transaction(alt_u32 src, alt_u32 dest, alt_u32 len, avmm_dma_transaction_type transaction_type);

	void halt_any_ongoing_dma_transaction();

	int dma_is_busy();

	int dma_is_done();

	void clear_done();

	const std::string& get_device_path() const {
		return device_path;
	}

	void set_device_path(const std::string& devicePath) {
		device_path = devicePath;
	}

	alt_dma_rxchan get_rxchan() const {
		return rxchan;
	}

	void set_rxchan(alt_dma_rxchan rxchan) {
		this->rxchan = rxchan;
	}

	alt_dma_txchan get_txchan() const {
		return txchan;
	}

	void set_txchan(alt_dma_txchan txchan) {
		this->txchan = txchan;
	}
};

} /* namespace avmm_dma */

#endif /* AVMM_DMA_ENCAPSULATOR_H_ */
