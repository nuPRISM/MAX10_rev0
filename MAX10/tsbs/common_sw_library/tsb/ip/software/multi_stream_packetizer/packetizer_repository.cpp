/*
 * packetizer_repository.cpp
 *
 *  Created on: Jul 6, 2019
 *      Author: user
 */

#include "packetizer_repository.h"
using namespace mspkt;

packetizer_repository_class::packetizer_repository_class(packetizer_control_info_t* the_packetizer_control_info_repository, uint32_t the_num_packetizers) {
	packetizer_control_info_repository = the_packetizer_control_info_repository;
	num_packetizers = the_num_packetizers;
}

packetizer_repository_class::~packetizer_repository_class() {
	// TODO Auto-generated destructor stub
}


int packetizer_repository_class::packetizer_is_using_ddr(uint32_t packetizer_index) {
	return packetizer_control_info_repository[packetizer_index].using_DDR_for_this_packetizer;
}

uint32_t packetizer_repository_class::get_on_chip_acq_mem_base_address_in_wave_capture_view(uint32_t packetizer_index, uint32_t packetizer_memory_index, uint32_t is_alternate) {
    return packetizer_control_info_repository[packetizer_index].on_chip_acq_mem_dma_controller_address_translation_func[packetizer_memory_index](is_alternate);
}

uint32_t packetizer_repository_class::get_ddr_base_as_viewed_from_packetizer(uint32_t packetizer_index, uint32_t channel_index) {
	uint32_t retval;
    retval = packetizer_control_info_repository[packetizer_index].ddr_dma_controller_address_translation_func[channel_index](get_ddr_bank_as_viewed_from_packetizer(packetizer_index,channel_index));
	return retval;
}

uint32_t packetizer_repository_class::get_ddr_bank_as_viewed_from_packetizer(uint32_t packetizer_index, uint32_t channel_index) {
	uint32_t retval;
    retval = packetizer_control_info_repository[packetizer_index].ddr_bank[channel_index];
	return retval;
}
uint32_t packetizer_repository_class::translate_wave_capture_on_chip_base_address_to_nios_view(uint32_t packetizer_index, uint32_t packetizer_memory_index, unsigned long addr, mspkt_response_type& error_val) {
	error_val = MSPKT_ERROR;
	uint32_t retval = 0;
	if (packetizer_control_info_repository[packetizer_index].on_chip_acq_mem_dma_controller_address_translation_func[packetizer_memory_index](0) == addr) {
		error_val = MSPKT_OK;
		retval = packetizer_control_info_repository[packetizer_index].waveform_capture_on_chip_memories[packetizer_memory_index];
	}

	if (packetizer_control_info_repository[packetizer_index].on_chip_acq_mem_dma_controller_address_translation_func[packetizer_memory_index](1) == addr) {
		error_val = MSPKT_OK;
		retval = packetizer_control_info_repository[packetizer_index].waveform_capture_alternate_on_chip_memories[packetizer_memory_index];
	}

    return retval;
}

bool packetizer_repository_class::wave_capture_on_chip_base_address_is_alternate(uint32_t packetizer_index, uint32_t packetizer_memory_index, unsigned long addr, mspkt::mspkt_response_type& error_val) {
	    error_val = MSPKT_ERROR;
		bool retval = false;
		if (packetizer_control_info_repository[packetizer_index].on_chip_acq_mem_dma_controller_address_translation_func[packetizer_memory_index](0) == addr) {
			error_val = MSPKT_OK;
			retval = false;
		}

		if (packetizer_control_info_repository[packetizer_index].on_chip_acq_mem_dma_controller_address_translation_func[packetizer_memory_index](1) == addr) {
			error_val = MSPKT_OK;
			retval = true;
		}
	    return retval;
}


uint32_t packetizer_repository_class::get_alternate_on_chip_mem_base_address_in_nios_view(uint32_t packetizer_index,uint32_t packetizer_memory_index) {
    return packetizer_control_info_repository[packetizer_index].waveform_capture_alternate_on_chip_memories[packetizer_memory_index];
}


uint32_t packetizer_repository_class::get_on_chip_mem_base_address_in_nios_view(uint32_t packetizer_index,uint32_t packetizer_memory_index) {
    return packetizer_control_info_repository[packetizer_index].waveform_capture_on_chip_memories[packetizer_memory_index];
}


std::string packetizer_repository_class::get_packetizer_name(uint32_t packetizer_index){
	return std::string(packetizer_control_info_repository[packetizer_index].name);
}

std::string packetizer_repository_class::get_packetizer_uart_name(uint32_t packetizer_index){
	return std::string(packetizer_control_info_repository[packetizer_index].uart_name);
}
std::string packetizer_repository_class::get_post_processing_uart_name(uint32_t packetizer_index){
	if (packetizer_control_info_repository[packetizer_index].post_processing_uart_name != NULL) {
	return std::string(packetizer_control_info_repository[packetizer_index].post_processing_uart_name);
	} else
	{
		return std::string("");
	}
}
uint32_t packetizer_repository_class::get_packetizer_dma_controller_base_address(uint32_t packetizer_index,uint32_t packetizer_memory_index){
	return packetizer_control_info_repository[packetizer_index].waveform_capture_controller_base_addresses[packetizer_memory_index];
}

uint32_t packetizer_repository_class::get_num_of_active_streams(uint32_t packetizer_index){
	return packetizer_control_info_repository[packetizer_index].num_of_active_packetizer_streams;
}

