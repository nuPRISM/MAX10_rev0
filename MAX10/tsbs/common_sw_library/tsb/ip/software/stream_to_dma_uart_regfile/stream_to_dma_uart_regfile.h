/*
 * stream_to_dma_uart_regfile.h
 *
 *  Created on: Oct 23, 2017
 *      Author: yairlinn
 */

#ifndef STREAM_TO_DMA_UART_REGFILE_H_
#define STREAM_TO_DMA_UART_REGFILE_H_

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
#include <iosfwd>
#include <iostream>
#include <sstream>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <iostream>
#include <fstream>
#include "chan_fatfs/fatfs_linnux_api.h"
#include "linnux_testbench_constants.h"
#include "interrupt_handling_utils.h"
#include "basedef.h"
#include "linnux_utils.h"
#include "uart_based_io_read_write_class.h"
#include "uart_based_pio_encapsulator.h"

namespace stdma {

typedef enum {
 DMA_WRITE_BASE_CONTROL_REG_ADDR = 0,
 DMA_WRITE_LENGTH_CONTROL_REG_ADDR = 1,
 DMA_START_CONTROL_REG_ADDR = 2,
 WRITE_WAIT_CYCLES_CONTROL_REG_ADDR = 3
} STREAM_TO_DMA_UART_CONTROL_REGS_ADDRESSES;

typedef enum {
	DMA_FINISHED_STATUS_REG_ADDR = 0,
	DMA_STATE_STATUS_REG_ADDR = 1,
	AVMM_STATE_STATUS_REG_ADDR = 2,
	CURRENT_WORD_COUNTER_STATUS_REG_ADDR = 3,
	NUM_WORDS_RECEIVED_STATUS_REG_ADDR = 4,
	DMA_SEQ_NUM_STATUS_REG_ADDR = 5
} STREAM_TO_DMA_UART_STATUS_REGS_ADDRESSES;

class stream_to_dma_uart_regfile  {
protected:
	uart_register_file* uart_ptr;
	unsigned long secondary_uart_num;	
	unsigned long max_allowed_words;
	unsigned long word_length_in_bytes;


	void set_max_allowed_words(unsigned long maxAllowedWords) {
		max_allowed_words = maxAllowedWords;
	}

public:
	stream_to_dma_uart_regfile() { uart_ptr = NULL; set_max_allowed_words(1); set_word_length_in_bytes(1);} ;

	virtual ~stream_to_dma_uart_regfile() {} ;

	void  set_dma_stream_length(unsigned long dma_stream_length);

	void  set_dma_write_base(unsigned long dma_write_base_address);

	unsigned long num_words_received();

	unsigned long get_dma_stream_length();

	unsigned long get_dma_write_base();

	unsigned long get_dma_count();

	int dma_is_finished();

	unsigned long get_actual_dma_result_access_count(unsigned long proposed_count);

	unsigned long num_words_receive();

	unsigned long curr_word_counter();

	unsigned long get_dma_state_machine_state();

	void start_dma_streaming();

	void force_dma_streaming_stop();

	unsigned long get_secondary_uart_num() {
		return secondary_uart_num;
	}

	void set_secondary_uart_num(unsigned long secondaryUartNum) {
		secondary_uart_num = secondaryUartNum;
	}

	const uart_register_file* get_uart_ptr() {
		return uart_ptr;
	}

	void set_uart_ptr(uart_register_file* uartPtr) {
		uart_ptr = uartPtr;
	}

	unsigned long get_word_length_in_bytes() const {
		return word_length_in_bytes;
	}

	void set_word_length_in_bytes(unsigned long wordLengthInBytes) {
		word_length_in_bytes = wordLengthInBytes;
	}

	unsigned long get_max_allowed_words() const {
		return max_allowed_words;
	}

	unsigned long get_current_dma_seq_num();

	void set_max_available_bytes(unsigned long numbytes) {
		this->set_max_allowed_words(numbytes/this->get_word_length_in_bytes());
	}
};

} /* namespace stdma_uart */

#endif /* STREAM_TO_DMA_UART_REGFILE_H_ */
