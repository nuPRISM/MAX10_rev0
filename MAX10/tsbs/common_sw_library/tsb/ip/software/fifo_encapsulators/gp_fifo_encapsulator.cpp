/*
 * gp_fifo_encapsulator.cpp
 *
 *  Created on:

 May 19, 2011
 *      Author: linnyair
 */

#include "gp_fifo_encapsulator.h"
#include "debug_macro_definitions.h"
#include "uart_register_file.h"
#include <vector>
#include <stdint.h>
#include "multi_stream_packetizer.h"

using namespace std;
using namespace mspkt;
#define fifo_u(x) do { if (DEBUG_FIFO_AND_GP_FIFO_ACQUISITION) { x; } } while(0)


int gp_fifo_encapsulator::complete_fifo_capture(int filehandle, LINNUX_FIFO_DATA_FORMATS data_format, int close_file_on_exit, int num_of_values)
{
	unsigned int num_of_values_to_read = (num_of_values == -1) ? FIFO_CAPACITY : num_of_values;
	fifo_last_read_contents = std::vector<unsigned long>(num_of_values_to_read, 0); //clear FIFO

	char current_str[256];
	int write_successful = 0;
	string current_value_str;
	if (filehandle < 0)
	{
		safe_print(cout << "Error: bad filehandle in FIFO_access_container::capture_and_save_Input_FIFO\n");
		return LINNUX_RETVAL_ERROR;
	}

	int stop_has_been_requested = complete_fifo_aquisition();
	if (stop_has_been_requested)
	{
		linnux_sd_card_fclose(filehandle);
		return LINNUX_RETVAL_ERROR;
	}
	//Three rdclks; necessary from datasheet
	rdclk_cycle_FIFO();
	rdclk_cycle_FIFO();
	rdclk_cycle_FIFO();

	read_FIFO_flags();
	parse_FIFO_flags();
	//safe_print(cout << "Printing contents of input FIFO in Matlab friendly manner as unsigned data... \n[ ");

	sprintf(current_str, "\n%s = [\n", description.c_str());
	write_successful = linnux_sd_card_write_string_to_file(filehandle, current_str);
	if (!write_successful) {
								linnux_sd_card_fclose(filehandle);
								return LINNUX_RETVAL_ERROR;
							}
	unsigned long watchdog_timer = 0;
	while ((!rdempty) && (watchdog_timer < num_of_values_to_read))
	{
		if ((watchdog_timer != 0) && ((watchdog_timer % FIFO_CONTAINER_CLASS_NUM_OF_FIFO_VALUES_TO_SHOW_PER_PRINTED_LINE) == 0))
		{
			write_successful = linnux_sd_card_write_string_to_file(filehandle, " ... \n");
			if (!write_successful) {
							linnux_sd_card_fclose(filehandle);
							return LINNUX_RETVAL_ERROR;
						}
		}
		current_FIFO_val = read_value_from_FIFO();
		fifo_last_read_contents.at(watchdog_timer) = current_FIFO_val;
		watchdog_timer++;

		read_FIFO_flags();
		parse_FIFO_flags();
		current_value_str = get_fifo_val_string(data_format);
		write_successful = linnux_sd_card_write_string_to_file(filehandle, current_value_str);
		if (!write_successful) {
						linnux_sd_card_fclose(filehandle);
						return LINNUX_RETVAL_ERROR;
					}
	}
	write_successful = linnux_sd_card_write_string_to_file(filehandle, "\n];\n");
	if (!write_successful) {
							linnux_sd_card_fclose(filehandle);
							return LINNUX_RETVAL_ERROR;
						}
	if (close_file_on_exit)
		linnux_sd_card_fclose(filehandle);
	return (1);
}

void gp_fifo_encapsulator::complete_FIFO_acquisition_and_print_to_console(LINNUX_FIFO_DATA_FORMATS data_format, int verbose, int num_of_values)
{
	/*int stop_has_been_requested = complete_fifo_aquisition();
	if (stop_has_been_requested)
	{
		return;
	}
	read_FIFO_flags();
	parse_FIFO_flags();
	print_FIFO_status();

	print_FIFO_contents(data_format, verbose);

	read_FIFO_flags();
	parse_FIFO_flags();
	print_FIFO_status();*/
	acquire_and_print_contents_to_console(data_format, verbose,1,num_of_values);
}

void gp_fifo_encapsulator::complete_fifo_capture_into_string(string& total_str, LINNUX_FIFO_DATA_FORMATS data_format, int is_initial, int is_final, int num_of_values)
{
	char current_str[256];
	unsigned int num_of_values_to_read = (num_of_values == -1) ? FIFO_CAPACITY : num_of_values;
	fifo_last_read_contents = std::vector<unsigned long>(num_of_values_to_read, 0); //clear FIFO

	string tempstr;
	ostringstream out_str;
	out_str << total_str;

	int stop_has_been_requested = complete_fifo_aquisition();
	if (stop_has_been_requested)
	{
		return;
	}

	//Three rdclks; necessary from datasheet
	rdclk_cycle_FIFO();
	rdclk_cycle_FIFO();
	rdclk_cycle_FIFO();

	read_FIFO_flags();
	parse_FIFO_flags();
	//safe_print(cout << "Printing contents of input FIFO in Matlab friendly manner as unsigned data... \n[ ");
	if (is_initial)
		{
		  sprintf(current_str, "\n%s = [\n", description.c_str());
		  tempstr = current_str;
		  out_str << tempstr;
		}

	unsigned long watchdog_timer = 0;
	while ((!rdempty) && (watchdog_timer < num_of_values_to_read))
	{
		if ((watchdog_timer != 0) && ((watchdog_timer % FIFO_CONTAINER_CLASS_NUM_OF_FIFO_VALUES_TO_SHOW_PER_PRINTED_LINE) == 0))
		{
			out_str << string(" ... \n");
		}
		current_FIFO_val = read_value_from_FIFO();
		fifo_last_read_contents.at(watchdog_timer) = current_FIFO_val;
		watchdog_timer++;

		read_FIFO_flags();
		parse_FIFO_flags();
        out_str << get_fifo_val_string(data_format);
	}
	if (is_final)
	{
		out_str << string("\n];\n");
	}
	total_str = out_str.str();
}

void gp_fifo_encapsulator::set_fifo_0_direct_buffer_base_address(unsigned int addr) {
	get_fifo_0_dma_ptr()->set_direct_buffer_address(addr);
}

void gp_fifo_encapsulator::set_fifo_1_direct_buffer_base_address(unsigned int addr) {
	get_fifo_1_dma_ptr()->set_direct_buffer_address(addr);
}


int gp_fifo_encapsulator::acquire_ext_memory_fifo( int num_of_values) {
	int stop_has_been_requested = 0;
	get_fifo_0_dma_ptr()->set_enable(vdma::VIDEO_DMA_IS_DISABLED);
	get_fifo_1_dma_ptr()->set_enable(vdma::VIDEO_DMA_IS_DISABLED);

	//get_fifo_0_dma_ptr()->set_back_buffer_address(this->get_fifo0_buffer_base_addr());
	//get_fifo_1_dma_ptr()->set_back_buffer_address(this->get_fifo1_buffer_base_addr());
	//get_fifo_0_dma_ptr()->set_buf_addr_ctrl_status(vdma::VIDEO_DMA_IS_INTERNALLY_CONTROLLED);
	//get_fifo_1_dma_ptr()->set_buf_addr_ctrl_status(vdma::VIDEO_DMA_IS_INTERNALLY_CONTROLLED);
	//get_fifo_0_dma_ptr()->set_up_for_swap();
	//get_fifo_0_dma_ptr()->set_up_for_swap();
	/*
	get_fifo_0_dma_ptr()->set_buf_addr_ctrl_status(vdma::VIDEO_DMA_IS_EXTERNALLY_CONTROLLED);
	get_fifo_1_dma_ptr()->set_buf_addr_ctrl_status(vdma::VIDEO_DMA_IS_EXTERNALLY_CONTROLLED);
	get_fifo_0_dma_ptr()->set_up_for_swap();
	get_fifo_1_dma_ptr()->set_up_for_swap();
	get_fifo_0_dma_ptr()->set_enable(vdma::VIDEO_DMA_IS_ENABLED);
	get_fifo_1_dma_ptr()->set_enable(vdma::VIDEO_DMA_IS_ENABLED);
	*/

	get_fifo_0_dma_ptr()->set_use_direct_buffer_adddress(true);
	get_fifo_1_dma_ptr()->set_use_direct_buffer_adddress(true);
	get_fifo_0_dma_ptr()->set_up_for_swap();
	get_fifo_1_dma_ptr()->set_up_for_swap();
	get_fifo_0_dma_ptr()->set_enable(vdma::VIDEO_DMA_IS_ENABLED);
	get_fifo_1_dma_ptr()->set_enable(vdma::VIDEO_DMA_IS_ENABLED);

	unsigned long num_of_values_to_read = ((num_of_values == -1) || (num_of_values > FIFO_CAPACITY)) ? FIFO_CAPACITY : num_of_values;
	if (uart_ptr->get_user_type(this->get_secondary_uart_num()) == MULTI_STREAM_PACKETIZER_UART_REGFILE) {
	      uart_ptr->write_control_reg(NIOS_DACS_NUM_OF_SAMPLES_TO_ACQUIRE_CONTROL_REG_ADDRESS,num_of_values_to_read,this->get_secondary_uart_num(),NULL);
	      uart_ptr->turn_on_bit(NIOS_DACS_STREAM_TO_MEM_CONTROL_REG_ADDRESS,GP_FIFO_EXT_MEM_DAC_START_ACQ_BIT_NUM,this->get_secondary_uart_num(),NULL);
	      uart_ptr->turn_off_bit(NIOS_DACS_STREAM_TO_MEM_CONTROL_REG_ADDRESS,GP_FIFO_EXT_MEM_DAC_START_ACQ_BIT_NUM,this->get_secondary_uart_num(),NULL);
	} else {
	uart_ptr->write_control_reg(GP_FIFO_EXT_MEM_ACTUAL_NUMVALS_CTRL_ADDR,num_of_values_to_read,this->get_secondary_uart_num(),NULL);
	uart_ptr->turn_on_bit(GP_FIFO_EXT_MEM_DAC_CTRL_ADDR,GP_FIFO_EXT_MEM_DAC_START_ACQ_BIT_NUM,this->get_secondary_uart_num(),NULL);
	uart_ptr->turn_off_bit(GP_FIFO_EXT_MEM_DAC_CTRL_ADDR,GP_FIFO_EXT_MEM_DAC_START_ACQ_BIT_NUM,this->get_secondary_uart_num(),NULL);
	}
	time_t start_time;
    time(&start_time);
	reset_interrupt_positions(STOP_FIFO_FILL_REQUEST_MASK);

	int finished_acq = 0;
	do {
		stop_has_been_requested = stop_fifo_aquire_condition_detected(start_time);
		if (stop_has_been_requested)
		{
			break;
		}
		if (uart_ptr->get_user_type(this->get_secondary_uart_num()) == MULTI_STREAM_PACKETIZER_UART_REGFILE) {
			 finished_acq = ((uart_ptr->read_status_reg(NIOS_DACS_PACKET_IN_PROGRESS_STATUS_ADDR,this->get_secondary_uart_num(),NULL) == 0) &&
							        (!(get_fifo_0_dma_ptr()->is_currently_processing_frame())) &&
							        (!(get_fifo_1_dma_ptr()->is_currently_processing_frame())));
		} else {
		finished_acq = ((uart_ptr->read_status_reg(GP_FIFO_PACKET_IN_PROGRESS_STATUS_ADDR,this->get_secondary_uart_num(),NULL) == 0) &&
				        (!(get_fifo_0_dma_ptr()->is_currently_processing_frame())) &&
				        (!(get_fifo_1_dma_ptr()->is_currently_processing_frame())));
		}
	} while (!finished_acq);

	return (stop_has_been_requested);
}


int gp_fifo_encapsulator::transfer_ext_memory_fifo_data( int num_of_values) {
	unsigned long num_of_values_to_read = (num_of_values == -1) ? FIFO_CAPACITY : num_of_values;

unsigned long this_fifo_base_address = this->get_gp_fifo_index() ?  this->get_fifo1_buffer_base_addr() : this->get_fifo0_buffer_base_addr();
uint32_t* uint32_ptr = (uint32_t *) this_fifo_base_address;
uint16_t* uint16_ptr = (uint16_t *) this_fifo_base_address;
uint8_t * uint8_ptr  = (uint8_t  *) this_fifo_base_address;
  for (int i = 0; i < num_of_values_to_read; i++) {
    if (get_num_bits_for_ext_mem_buffer() == 32)
    {
        fifo_last_read_contents.at(i) =  (unsigned long) (*(uint32_ptr++));
    }

    if (get_num_bits_for_ext_mem_buffer() == 16)
    {
         fifo_last_read_contents.at(i) = (unsigned long) ((*(uint16_ptr++))&0xFFFF);
    }

    if (get_num_bits_for_ext_mem_buffer() == 8)
    {
         fifo_last_read_contents.at(i) = (unsigned long) ((*(uint8_ptr++))&0xFF);
    }
  }
}


void gp_fifo_encapsulator::enable_simult_fifo_capture()
{
	this->get_io_rw_interface_ptr()->write(simult_fifo_capture_reg_addr,1);
}
void gp_fifo_encapsulator::disable_simult_fifo_capture()
{
	this->get_io_rw_interface_ptr()->write(simult_fifo_capture_reg_addr,0);
}

int get_gp_fifo_encapsulator_uart_ptrs(gp_fifo_encapsulator*& fifo0_ptr, gp_fifo_encapsulator*& fifo1_ptr,  std::vector<gp_fifo_encapsulator*>& fifo_pointer_vector, uart_register_file* uart_ptr, unsigned int secondary_uart_num)
{


													 fifo0_ptr = (gp_fifo_encapsulator*) NULL;
													 fifo1_ptr = (gp_fifo_encapsulator*) NULL;


													for (unsigned i = 0; i < fifo_pointer_vector.size(); i++) {
														if (fifo_pointer_vector.at(i) == NULL) {
															continue;
														}

														fifo_u(
																safe_print(std::cout << " i = " << i << " uart_ptr = " << uart_ptr
																<< " fifo_pointer_vector.at(i)->get_uart_ptr() = " << fifo_pointer_vector.at(i)->get_uart_ptr()
																<< " fifo_pointer_vector.at(i)->get_secondary_uart_num() = " << fifo_pointer_vector.at(i)->get_secondary_uart_num()
															    << " fifo_pointer_vector.at(i)->get_gp_fifo_index() " << fifo_pointer_vector.at(i)->get_gp_fifo_index() << std::endl;);
																std::cout.flush();
                                                        );

														if ((fifo_pointer_vector.at(i)->get_uart_ptr() == uart_ptr) && (fifo_pointer_vector.at(i)->get_secondary_uart_num() == secondary_uart_num) && (fifo_pointer_vector.at(i)->get_gp_fifo_index() == 0))  {
															fifo0_ptr = fifo_pointer_vector.at(i);
														} else
														{
															if ((fifo_pointer_vector.at(i)->get_uart_ptr() == uart_ptr) && (fifo_pointer_vector.at(i)->get_secondary_uart_num() == secondary_uart_num) && (fifo_pointer_vector.at(i)->get_gp_fifo_index() == 1))  {
															   fifo1_ptr = fifo_pointer_vector.at(i);
															}
														}
														if ((fifo0_ptr != (gp_fifo_encapsulator*) NULL) && (fifo1_ptr != (gp_fifo_encapsulator*) NULL)) {
															break;
														}
													}

													return ((fifo0_ptr != (gp_fifo_encapsulator*) NULL) && (fifo1_ptr != (gp_fifo_encapsulator*) NULL));

}
