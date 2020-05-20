/*
 * multi_stream_packetizer.h
 *
 *  Created on: Dec 8, 2018
 *      Author: user
 */

#ifndef MULTI_STREAM_PACKETIZER_H_
#define MULTI_STREAM_PACKETIZER_H_

#include <vector>
#include <string>
#include <map>
#include <sstream>
#include "regfile_io_rw_class.h"
#include "video_dma_up_encapsulator.h"
#include <sys/types.h>
#include <stdint.h>

namespace mspkt {

const unsigned long IN_NUM_BITS_STATUS_ADDRESS = 0;
const unsigned long OUT_NUM_BITS_STATUS_ADDRESS = 1;
const unsigned long NUM_WORD_BITS_IN_FIFOS_STATUS_ADDRESS = 2;
const unsigned long PARAMETER_BITS_STATUS_ADDRESS = 3;
const unsigned long NIOS_DACS_STREAM_TO_MEM_CONTROL_REG_ADDRESS = 3;
const unsigned long NIOS_DACS_PACKET_IN_PROGRESS_STATUS_ADDR = 4;

const unsigned long MEM_FILE_INDEX_CONTROL_REG_ADDRESS = 5;
const unsigned long VECTOR_INDEX_CONTROL_REG_ADDRESS = 5;

const unsigned long NIOS_DACS_NUM_OF_SAMPLES_TO_ACQUIRE_CONTROL_REG_ADDRESS = 4;
const unsigned long NIOS_DACS_DECIMATION_RATIO_CONTROL_REG_ADDRESS = 2;
const unsigned long HW_TRIGGER_CONTROL_CONTROL_REG_ADDRESS = 1;
const unsigned long NIOS_DACS_TEST_SIGNAL_PARAMS_STATUS_REG_ADDRESS = 3;
const unsigned long POST_PROCESSING_NUM_STREAMS_STATUS_ADDRESS = 13;
const unsigned long NIOS_DACS_TRIGGER_RESET_BIT_INDEX = 1;

const unsigned long NIOS_DACS_TIME_BETWEEN_TRIGGERS_STATUS_REG_ADDRESS  = 10;

const unsigned long IS_EXTERNAL_MEMORY_NIOS_DAC_MASK = 0x1000000;
const unsigned int  START_ACQ_BIT_NUM = 0;
const unsigned int  NIOS_DACS_PACKET_IN_PROGRESS_BIT_NUM = 0;

const unsigned int  PACKETIZER_VECTOR_INDEX_MSB = 31;
const unsigned int  PACKETIZER_VECTOR_INDEX_LSB = 16;

const unsigned int  PACKETIZER_VECTOR_FIRST_MEMORY_INDEX_LSB = 0;
const unsigned int  PACKETIZER_VECTOR_FIRST_MEMORY_INDEX_MSB = 7;

const unsigned int  PACKETIZER_VECTOR_LAST_MEMORY_INDEX_LSB = 8;
const unsigned int  PACKETIZER_VECTOR_LAST_MEMORY_INDEX_MSB = 15;

const unsigned int  NUM_OF_STREAMS_LSB = 8;
const unsigned int  NUM_OF_STREAMS_MSB = 15;


typedef enum  {
	MSPKT_ERROR = 0,
	MSPKT_OK = 1
} mspkt_response_type;

typedef struct {
	unsigned long base_address;
	unsigned long dma_target_address;
	unsigned long alternate_dma_target_address;
	unsigned long raw_dma_target_address;
	unsigned long raw_alternate_dma_target_address;
} dma_controller_parameters_struct;

class multi_stream_packetizer {
protected:
	std::vector<dma_controller_parameters_struct> dma_controller_parameters;
    std::vector<vdma::video_dma_up_encapsulator*> *dma_controller_vector;
    std::string name;
    unsigned int max_fifo_capacity;
    regfile_io_rw_class* io_rw_interface_ptr;
    unsigned int num_of_active_channels;
    unsigned long controlBase;
    unsigned long statusBase;
    bool use_wishbone_interface;


public:
	multi_stream_packetizer(
			unsigned long controlBase,
			unsigned long statusBase,
            bool use_wishbone_interface,
            regfile_io_rw_class* external_io_rw_interface_ptr,
			std::string the_name,
			std::vector<dma_controller_parameters_struct>& the_dma_controller_parameters,
			unsigned int the_fifo_capacity,
			bool override_external_swap_buffers_now = false,
			bool override_val_for_external_swap_buffers_now = false
			);


	virtual void reset_acquisition_interrupt_positions();
	virtual int stop_fifo_acquire_condition_detected(time_t start_time);

	virtual int acquire_data(int num_of_values);

	virtual void set_packetizer_vector_index_and_memories(unsigned long index, unsigned long first_memory,  unsigned long last_memory);

	virtual unsigned long get_packetizer_vector_index();
	virtual unsigned long get_first_memory_index();
	virtual unsigned long get_last_memory_index();
	virtual void set_packetizer_vector_index(unsigned long val);
	virtual void set_first_memory_index     (unsigned long val);
	virtual void set_last_memory_index      (unsigned long val);
	virtual  mspkt_response_type set_dma_target_address(unsigned int controller_num, unsigned long address);
	virtual  unsigned long get_dma_target_address(unsigned int controller_num, mspkt_response_type& error_val);
	virtual  unsigned long get_num_finished_packets_processed(unsigned int controller_num, mspkt_response_type& error_val);
	virtual  mspkt_response_type get_dma_buffer_addresses_at_init(unsigned int controller_num, unsigned int&  dma_buffer_address, unsigned int& alternate_dma_buffer_address);
	virtual  mspkt_response_type get_raw_dma_buffer_addresses_at_init(unsigned int controller_num, unsigned int&  dma_buffer_address, unsigned int& alternate_dma_buffer_address);
    virtual  std::vector<uint32_t> get_attached_dma_controller_base_addresses();

	virtual  std::vector<vdma::video_dma_up_encapsulator*>* get_dma_controller_vector()  {
	   return dma_controller_vector;
    }

	virtual  std::string& get_name() {
		return name;
	}

	virtual  void set_name(std::string& name) {
		this->name = name;
	}

	virtual  unsigned int get_max_fifo_capacity() const {
		return max_fifo_capacity;
	}

	virtual  void set_max_fifo_capacity(unsigned int maxFifoCapacity) {
		max_fifo_capacity = maxFifoCapacity;
	}

	virtual ~multi_stream_packetizer();

	virtual unsigned int get_num_of_active_channels() const {
		return num_of_active_channels;
	}

	virtual void set_num_of_active_channels(unsigned int num_of_active_channels) {
		if (num_of_active_channels <= this->dma_controller_vector->size()) {
		 this->num_of_active_channels = num_of_active_channels;
		}
	}

	virtual unsigned long get_control_base() const {
		return controlBase;
	}

	virtual void set_control_base(unsigned long control_base) {
		controlBase = control_base;
	}

	virtual regfile_io_rw_class* get_io_rw_interface_ptr() const {
		return io_rw_interface_ptr;
	}

	virtual void set_io_rw_interface_ptr(regfile_io_rw_class* io_rw_interface_ptr) {
		this->io_rw_interface_ptr = io_rw_interface_ptr;
	}

	virtual unsigned long get_status_base() const {
		return statusBase;
	}

	virtual void set_status_base(unsigned long status_base) {
		statusBase = status_base;
	}

	virtual bool is_use_wishbone_interface() const {
		return use_wishbone_interface;
	}

	virtual void set_use_wishbone_interface(bool use_wishbone_interface) {
		this->use_wishbone_interface = use_wishbone_interface;
	}
};

} /* namespace mspkt */

#endif /* MULTI_STREAM_PACKETIZER_H_ */
