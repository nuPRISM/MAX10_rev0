/*
 * packetizer_repository.h
 *
 *  Created on: Jul 6, 2019
 *      Author: user
 */

#ifndef PACKETIZER_REPOSITORY_CLASS_H_
#define PACKETIZER_REPOSITORY_CLASS_H_
#include <stdint.h>
#include <string>
#include "multi_stream_packetizer.h"

#ifndef MAX_NUM_MEMORIES_PER_PACKETIZER
#define MAX_NUM_MEMORIES_PER_PACKETIZER (8)
#endif


typedef uint32_t (*dma_controller_address_translation_func) (uint32_t);

typedef struct {
	 const char * name;
	 const char * uart_name;
	 const char * post_processing_uart_name;
	 const uint32_t num_of_active_packetizer_streams;
	 const uint32_t num_of_packetizer_streams_instantiated;
	 const uint32_t on_chip_memories_available;
	 uint32_t waveform_capture_controller_base_addresses[MAX_NUM_MEMORIES_PER_PACKETIZER];
	 uint32_t waveform_capture_on_chip_memories[MAX_NUM_MEMORIES_PER_PACKETIZER];
	 uint32_t waveform_capture_alternate_on_chip_memories[MAX_NUM_MEMORIES_PER_PACKETIZER];
 	 dma_controller_address_translation_func ddr_dma_controller_address_translation_func[MAX_NUM_MEMORIES_PER_PACKETIZER];
	 uint32_t ddr_bank[MAX_NUM_MEMORIES_PER_PACKETIZER];
	 dma_controller_address_translation_func on_chip_acq_mem_dma_controller_address_translation_func[MAX_NUM_MEMORIES_PER_PACKETIZER];
	 int    using_DDR_for_this_packetizer;
	 uint32_t default_fft_numsamples;
} packetizer_control_info_t;


class packetizer_repository_class {
protected:
	uint32_t num_packetizers;
	packetizer_control_info_t* packetizer_control_info_repository;
public:

	packetizer_repository_class(packetizer_control_info_t* the_packetizer_control_info_repository, uint32_t num_packetizers);
	uint32_t get_on_chip_acq_mem_base_address_in_wave_capture_view(uint32_t packetizer_index, uint32_t packetizer_memory_index, uint32_t is_alternate);
	uint32_t get_ddr_base_as_viewed_from_packetizer(uint32_t packetizer_index, uint32_t channel_index);
	uint32_t get_ddr_bank_as_viewed_from_packetizer(uint32_t packetizer_index, uint32_t channel_index);
	uint32_t translate_wave_capture_on_chip_base_address_to_nios_view(uint32_t packetizer_index, uint32_t packetizer_memory_index, unsigned long addr, mspkt::mspkt_response_type& error_val);
	bool     wave_capture_on_chip_base_address_is_alternate(uint32_t packetizer_index, uint32_t packetizer_memory_index, unsigned long addr, mspkt::mspkt_response_type& error_val);
    int packetizer_is_using_ddr(uint32_t packetizer_index);
    uint32_t get_alternate_on_chip_mem_base_address_in_nios_view(uint32_t packetizer_index,uint32_t packetizer_memory_index);
    uint32_t get_on_chip_mem_base_address_in_nios_view(uint32_t packetizer_index,uint32_t packetizer_memory_index);
    std::string get_packetizer_name(uint32_t packetizer_index);
    std::string get_packetizer_uart_name(uint32_t packetizer_index);
    std::string get_post_processing_uart_name(uint32_t packetizer_index);
    uint32_t get_packetizer_dma_controller_base_address(uint32_t packetizer_index,uint32_t packetizer_memory_index);
    uint32_t get_num_of_active_streams(uint32_t packetizer_index);

	virtual ~packetizer_repository_class();
};

#endif /* SRC_LOCAL_PACKETIZER_REPOSITORY_H_ */
