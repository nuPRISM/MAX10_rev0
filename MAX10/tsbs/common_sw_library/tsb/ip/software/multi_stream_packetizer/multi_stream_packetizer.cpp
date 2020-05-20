/*
 * multi_stream_packetizer.cpp
 *
 *  Created on: Dec 8, 2018
 *      Author: user
 */

#include "multi_stream_packetizer.h"
#include "time.h"
namespace mspkt {

multi_stream_packetizer::~multi_stream_packetizer() {
	// TODO Auto-generated destructor stub
}


multi_stream_packetizer::multi_stream_packetizer(
			unsigned long controlBase,
			unsigned long statusBase,
            bool use_wishbone_interface,
            regfile_io_rw_class* external_io_rw_interface_ptr,
			std::string the_name,
			std::vector<dma_controller_parameters_struct>& the_dma_controller_parameters,
			unsigned int the_fifo_capacity,
			bool override_external_swap_buffers_now,
			bool override_val_for_external_swap_buffers_now
			) {
	this->set_control_base(controlBase);
	this->set_status_base(statusBase);

	       dma_controller_parameters = the_dma_controller_parameters;
	       this->set_name(the_name);
	       this->set_max_fifo_capacity(the_fifo_capacity);
	       dma_controller_vector = new std::vector<vdma::video_dma_up_encapsulator*>(dma_controller_parameters.size(),NULL);
		   for (unsigned int i = 0; i < dma_controller_parameters.size(); i++ ) {
			   std::ostringstream current_name;
			   current_name << this->get_name() << "_dma_ctrl_" << i;
			   dma_controller_vector->at(i) = new vdma::video_dma_up_encapsulator(dma_controller_parameters.at(i).base_address,current_name.str());
			   dma_controller_vector->at(i)->set_direct_buffer_address(dma_controller_parameters.at(i).dma_target_address);
			   dma_controller_vector->at(i)->set_avmm_swap_buffer_now(override_val_for_external_swap_buffers_now);
			   dma_controller_vector->at(i)->set_override_swap_buffer_now(override_external_swap_buffers_now);
		   }

		   if (use_wishbone_interface) {
			   io_rw_interface_ptr =  new regfile_io_rw_class (controlBase,statusBase);
		   } else {
			   io_rw_interface_ptr =  external_io_rw_interface_ptr;
		   }

		   this->set_num_of_active_channels(this->dma_controller_parameters.size());

};

void multi_stream_packetizer::set_packetizer_vector_index_and_memories(unsigned long index, unsigned long first_memory,  unsigned long last_memory){
	this->set_packetizer_vector_index(index);
	this->set_first_memory_index(first_memory);
	this->set_last_memory_index(last_memory);
}

unsigned long multi_stream_packetizer::get_first_memory_index() {
	return this->io_rw_interface_ptr->extract_bits(MEM_FILE_INDEX_CONTROL_REG_ADDRESS,PACKETIZER_VECTOR_FIRST_MEMORY_INDEX_LSB,PACKETIZER_VECTOR_FIRST_MEMORY_INDEX_MSB);
}

unsigned long multi_stream_packetizer::get_last_memory_index() {
	return this->io_rw_interface_ptr->extract_bits(MEM_FILE_INDEX_CONTROL_REG_ADDRESS,PACKETIZER_VECTOR_LAST_MEMORY_INDEX_LSB,PACKETIZER_VECTOR_LAST_MEMORY_INDEX_MSB);
}

std::vector<uint32_t> multi_stream_packetizer::get_attached_dma_controller_base_addresses() {
	std::vector<uint32_t> outvec;
	for (unsigned int i=0; i < this->dma_controller_parameters.size(); i++) {
		outvec.push_back(dma_controller_parameters.at(i).base_address);
	}
	return outvec;
}


unsigned long multi_stream_packetizer::get_packetizer_vector_index() {
	return this->io_rw_interface_ptr->extract_bits(VECTOR_INDEX_CONTROL_REG_ADDRESS,PACKETIZER_VECTOR_INDEX_LSB,PACKETIZER_VECTOR_INDEX_MSB);
}

void multi_stream_packetizer::set_packetizer_vector_index(unsigned long val) {
	this->io_rw_interface_ptr->replace_bit_range(VECTOR_INDEX_CONTROL_REG_ADDRESS,PACKETIZER_VECTOR_INDEX_LSB,PACKETIZER_VECTOR_INDEX_MSB,val);
}
void multi_stream_packetizer::set_first_memory_index     (unsigned long val) {
	this->io_rw_interface_ptr->replace_bit_range(MEM_FILE_INDEX_CONTROL_REG_ADDRESS,PACKETIZER_VECTOR_FIRST_MEMORY_INDEX_LSB,PACKETIZER_VECTOR_FIRST_MEMORY_INDEX_MSB,val);
}
void multi_stream_packetizer::set_last_memory_index      (unsigned long val) {
	this->io_rw_interface_ptr->replace_bit_range(MEM_FILE_INDEX_CONTROL_REG_ADDRESS,PACKETIZER_VECTOR_LAST_MEMORY_INDEX_LSB,PACKETIZER_VECTOR_LAST_MEMORY_INDEX_MSB,val);
}





int multi_stream_packetizer::acquire_data(int num_of_values) {

	int stop_has_been_requested = 0;
    for (unsigned int i = 0; i <  this->get_num_of_active_channels(); i++) {
    	dma_controller_vector->at(i)->set_enable(vdma::VIDEO_DMA_IS_DISABLED);
    	dma_controller_vector->at(i)->set_use_direct_buffer_adddress(true);
    	dma_controller_vector->at(i)->set_up_for_swap();
    }
    for (unsigned int i = 0; i <  this->get_num_of_active_channels(); i++) {
        dma_controller_vector->at(i)->set_enable(vdma::VIDEO_DMA_IS_ENABLED);
    }

	unsigned long num_of_values_to_read = ((num_of_values == -1) || (num_of_values > this->get_max_fifo_capacity())) ? this->get_max_fifo_capacity() : num_of_values;

    this->io_rw_interface_ptr->write(NIOS_DACS_NUM_OF_SAMPLES_TO_ACQUIRE_CONTROL_REG_ADDRESS,num_of_values_to_read);
    this->io_rw_interface_ptr->turn_on_bit(NIOS_DACS_STREAM_TO_MEM_CONTROL_REG_ADDRESS,START_ACQ_BIT_NUM);
    this->io_rw_interface_ptr->turn_off_bit(NIOS_DACS_STREAM_TO_MEM_CONTROL_REG_ADDRESS,START_ACQ_BIT_NUM);

	time_t start_time;
    time(&start_time);
    reset_acquisition_interrupt_positions();


	int acquisition_still_in_progress = 1;

	do {

		stop_has_been_requested = stop_fifo_acquire_condition_detected(start_time);

		if (stop_has_been_requested)
		{
			break;
		}

		acquisition_still_in_progress = this->io_rw_interface_ptr->get_status_bit(NIOS_DACS_PACKET_IN_PROGRESS_STATUS_ADDR,NIOS_DACS_PACKET_IN_PROGRESS_BIT_NUM);
		for  (unsigned int i = 0; i <  this->get_num_of_active_channels(); i++) {
			acquisition_still_in_progress |= dma_controller_vector->at(i)->is_currently_processing_frame();
		}

	} while (acquisition_still_in_progress);

    return (stop_has_been_requested);
}

mspkt_response_type multi_stream_packetizer::set_dma_target_address(unsigned int controller_num, unsigned long address) {
	if (controller_num >= this->dma_controller_vector->size()) {
		return MSPKT_ERROR;
	}
	this->dma_controller_vector->at(controller_num)->set_direct_buffer_address(address);
	return MSPKT_OK;
}

unsigned long multi_stream_packetizer::get_dma_target_address(unsigned int controller_num, mspkt_response_type& error_val) {
	if (controller_num >= this->dma_controller_vector->size()) {
		    error_val = MSPKT_ERROR;
			return 0;
	}
	error_val = MSPKT_OK;
	return this->dma_controller_vector->at(controller_num)->get_direct_buffer_address();
}

mspkt_response_type multi_stream_packetizer::get_dma_buffer_addresses_at_init(unsigned int controller_num,unsigned int&  dma_buffer_address, unsigned int& alternate_dma_buffer_address) {
	if (controller_num >= this->dma_controller_vector->size()) {
			return MSPKT_ERROR;
	}
	dma_buffer_address = this->dma_controller_parameters.at(controller_num).dma_target_address;
	alternate_dma_buffer_address = this->dma_controller_parameters.at(controller_num).alternate_dma_target_address;
	return MSPKT_OK;
}
mspkt_response_type multi_stream_packetizer::get_raw_dma_buffer_addresses_at_init(unsigned int controller_num,unsigned int&  dma_buffer_address, unsigned int& alternate_dma_buffer_address) {
	if (controller_num >= this->dma_controller_vector->size()) {
			return MSPKT_ERROR;
	}
	dma_buffer_address = this->dma_controller_parameters.at(controller_num).raw_dma_target_address;
	alternate_dma_buffer_address = this->dma_controller_parameters.at(controller_num).raw_alternate_dma_target_address;
	return MSPKT_OK;
}
unsigned long multi_stream_packetizer::get_num_finished_packets_processed(unsigned int controller_num, mspkt_response_type& error_val) {
	if (controller_num >= this->dma_controller_vector->size()) {
		    error_val = MSPKT_ERROR;
			return 0;
	}
	error_val = MSPKT_OK;
	return this->dma_controller_vector->at(controller_num)->get_num_finished_packets_processed();
}


void multi_stream_packetizer::reset_acquisition_interrupt_positions() {

};

int multi_stream_packetizer::stop_fifo_acquire_condition_detected(time_t start_time){
	return 0;
}

} /* namespace mspkt */
