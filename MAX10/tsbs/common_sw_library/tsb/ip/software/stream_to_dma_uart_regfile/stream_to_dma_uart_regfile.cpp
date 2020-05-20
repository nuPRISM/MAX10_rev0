/*
 * stream_to_dma_uart_regfile.cpp
 *
 *  Created on: Oct 23, 2017
 *      Author: yairlinn
 */

#include "stream_to_dma_uart_regfile.h"

namespace stdma {


void stream_to_dma_uart_regfile::set_dma_stream_length(unsigned long dma_stream_length) {
	uart_ptr->write_control_reg(DMA_WRITE_LENGTH_CONTROL_REG_ADDR,dma_stream_length,get_secondary_uart_num());
}

void stream_to_dma_uart_regfile::set_dma_write_base(unsigned long dma_write_base_address) {
	uart_ptr->write_control_reg(DMA_WRITE_BASE_CONTROL_REG_ADDR,dma_write_base_address,get_secondary_uart_num());
}

int stream_to_dma_uart_regfile::dma_is_finished() {
	return ((uart_ptr->read_status_reg(DMA_FINISHED_STATUS_REG_ADDR,get_secondary_uart_num()) & 0xFFFFFFFF) != 0);
}

unsigned long stream_to_dma_uart_regfile::num_words_received() {
	return  (uart_ptr->read_status_reg(NUM_WORDS_RECEIVED_STATUS_REG_ADDR,get_secondary_uart_num()) & 0xFFFFFFFF);
}

unsigned long stream_to_dma_uart_regfile::get_dma_stream_length() {
	return  (uart_ptr->read_control_reg(DMA_WRITE_LENGTH_CONTROL_REG_ADDR,get_secondary_uart_num()) & 0xFFFFFFFF);
}

unsigned long stream_to_dma_uart_regfile::get_dma_write_base() {
	return  (uart_ptr->read_control_reg(DMA_WRITE_BASE_CONTROL_REG_ADDR,get_secondary_uart_num())  & 0xFFFFFFFF);
}

unsigned long stream_to_dma_uart_regfile::get_dma_count() {
	return (uart_ptr->read_status_reg(CURRENT_WORD_COUNTER_STATUS_REG_ADDR,get_secondary_uart_num()) & 0xFFFFFFFF);
}

unsigned long stream_to_dma_uart_regfile::get_dma_state_machine_state() {
	return (uart_ptr->read_status_reg(DMA_STATE_STATUS_REG_ADDR,get_secondary_uart_num()) & 0xFFFFFFFF);
}
unsigned long stream_to_dma_uart_regfile::get_current_dma_seq_num() {
	return (uart_ptr->read_status_reg(DMA_SEQ_NUM_STATUS_REG_ADDR,get_secondary_uart_num()) & 0xFFFFFFFF);
}

void stream_to_dma_uart_regfile::start_dma_streaming() {
	uart_ptr->write_control_reg(DMA_START_CONTROL_REG_ADDR,1,get_secondary_uart_num());
	uart_ptr->write_control_reg(DMA_START_CONTROL_REG_ADDR,0,get_secondary_uart_num());
}

void stream_to_dma_uart_regfile::force_dma_streaming_stop() {
	uart_ptr->write_control_reg(DMA_START_CONTROL_REG_ADDR,2,get_secondary_uart_num());
	do {} while(get_dma_state_machine_state() != 0); //wait until state machine returns to idle
	uart_ptr->write_control_reg(DMA_START_CONTROL_REG_ADDR,0,get_secondary_uart_num());
}

unsigned long stream_to_dma_uart_regfile::get_actual_dma_result_access_count(unsigned long proposed_count) {
	unsigned long max_available_dma_results = get_dma_count();
	unsigned long actual_dma_length = proposed_count > max_available_dma_results ? max_available_dma_results : proposed_count;
	return actual_dma_length;
}


} /* namespace stdma_uart */
