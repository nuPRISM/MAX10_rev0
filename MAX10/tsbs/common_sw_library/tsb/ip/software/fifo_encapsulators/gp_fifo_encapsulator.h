/*
 * gp_fifo_encapsulator.h
 *
 *  Created on: May 19, 2011
 *      Author: linnyair
 */

#ifndef GP_FIFO_ENCAPSULATOR_H_
#define GP_FIFO_ENCAPSULATOR_H_

#include "fifo_access_container.h"
#include "video_dma_up_encapsulator.h"

const unsigned int GP_FIFO_EXT_MEM_DAC_CTRL_ADDR = 14;
const unsigned int GP_FIFO_EXT_MEM_ACTUAL_NUMVALS_CTRL_ADDR = 15;
const unsigned int GP_FIFO_PACKET_IN_PROGRESS_STATUS_ADDR = 17;

const unsigned int GP_FIFO_EXT_MEM_DAC_START_ACQ_BIT_NUM = 0;
const unsigned int GP_FIFO_EXT_MEM_DAC_RESET_BIT_NUM = 1;
class gp_fifo_encapsulator: public FIFO_access_container {
protected:
	 unsigned long gp_fifo_index;
	 unsigned long simult_fifo_capture_reg_addr;
	 vdma::video_dma_up_encapsulator* fifo_0_dma_ptr;
	 vdma::video_dma_up_encapsulator* fifo_1_dma_ptr;
	 unsigned long fifo0_buffer_base_addr;
	 unsigned long fifo1_buffer_base_addr;

public:
		gp_fifo_encapsulator(unsigned long base_addr, unsigned long flag_base_addr, unsigned long control_base_addr, unsigned long fifo_dmask, unsigned long capacity, std::string description_val, unsigned short data_lsb_val=0, unsigned short data_msb_val=31) :
			FIFO_access_container(base_addr, flag_base_addr, control_base_addr, fifo_dmask, capacity, description_val, data_lsb_val, data_msb_val)
		{
		};
		gp_fifo_encapsulator  (uart_register_file* uart_ptr,
		                             unsigned long secondary_uart_num,
		    		                 unsigned long fifo_dmask,
		    		                 unsigned long capacity,
		    		                 std::string   description_val,
		    		                 unsigned long base_addr        ,
		    		                 unsigned long flag_base_addr   ,
		    		                 unsigned long control_base_addr,
		    		                 unsigned long  simult_fifo_capture_reg_addr,
		    		                 unsigned long  gp_fifo_index,
		    		                 unsigned short data_lsb_val=0,
		    		                 unsigned short data_msb_val=31

		    		                 ) :
			                 FIFO_access_container(
			                    uart_ptr,
			                    secondary_uart_num,
			                    fifo_dmask,
			                    capacity,
			                    description_val,
			                    base_addr        ,
			                    flag_base_addr   ,
			                    control_base_addr,
			                    data_lsb_val,
			                    data_msb_val)
			{
			  this->gp_fifo_index = gp_fifo_index;
			  this->simult_fifo_capture_reg_addr = simult_fifo_capture_reg_addr;
			};


		gp_fifo_encapsulator  (uart_register_file* uart_ptr,
			                             unsigned long secondary_uart_num,
			    		                 unsigned long fifo_dmask,
			    		                 unsigned long capacity,
			    		                 std::string   description_val,
			    		                 unsigned long base_addr        ,
			    		                 unsigned long flag_base_addr   ,
			    		                 unsigned long control_base_addr,
			    		                 unsigned long  simult_fifo_capture_reg_addr,
			    		                 unsigned long  gp_fifo_index,
			    		                 bool use_high_speed_wishbone_rw_link,
			    		                 unsigned long status_wishbone_base,
			    		                 unsigned long ctrl_wishbone_base,
			    		                 unsigned short data_lsb_val=0,
			    		                 unsigned short data_msb_val=31,
			    		                 bool uses_ext_memory_instead_of_fifos = false

			    		                 ) :
				                 FIFO_access_container(
				                    uart_ptr,
				                    secondary_uart_num,
				                    fifo_dmask,
				                    capacity,
				                    description_val,
				                    base_addr        ,
				                    flag_base_addr   ,
				                    control_base_addr,
				                    use_high_speed_wishbone_rw_link,
				                    status_wishbone_base,
				                    ctrl_wishbone_base,
				                    data_lsb_val,
				                    data_msb_val,
				                    uses_ext_memory_instead_of_fifos)
				{
				  this->gp_fifo_index = gp_fifo_index;
				  this->simult_fifo_capture_reg_addr = simult_fifo_capture_reg_addr;
				};

        virtual unsigned long get_gp_fifo_index() {
           return gp_fifo_index;
        }
		virtual int complete_fifo_capture(int filehandle, LINNUX_FIFO_DATA_FORMATS data_format, int close_file_on_exit, int num_of_values = -1);
		virtual void complete_FIFO_acquisition_and_print_to_console(LINNUX_FIFO_DATA_FORMATS data_format, int verbose, int num_of_values = -1);
		virtual void complete_fifo_capture_into_string(std::string& total_str, LINNUX_FIFO_DATA_FORMATS data_format, int is_initial, int is_final, int num_of_values = -1);
		virtual void enable_simult_fifo_capture();
		virtual void disable_simult_fifo_capture();
		virtual int acquire_ext_memory_fifo(int num_of_values);
		virtual int transfer_ext_memory_fifo_data(int num_of_values);

	vdma::video_dma_up_encapsulator* get_fifo_0_dma_ptr() const {
		return fifo_0_dma_ptr;
	}

	void set_fifo_0_dma_ptr(vdma::video_dma_up_encapsulator* fifo0DmaPtr) {
		fifo_0_dma_ptr = fifo0DmaPtr;
	}
	void set_fifo_0_direct_buffer_base_address(unsigned int addr);
	void set_fifo_1_direct_buffer_base_address(unsigned int addr);

	vdma::video_dma_up_encapsulator* get_fifo_1_dma_ptr() const {
		return fifo_1_dma_ptr;
	}

	void set_fifo_1_dma_ptr(vdma::video_dma_up_encapsulator* fifo1DmaPtr) {
		fifo_1_dma_ptr = fifo1DmaPtr;
	}

	unsigned long get_fifo0_buffer_base_addr() const {
		return fifo0_buffer_base_addr;
	}

	void set_fifo0_buffer_base_addr(unsigned long fifo0BufferBaseAddr) {
		fifo0_buffer_base_addr = fifo0BufferBaseAddr;
	}

	unsigned long get_fifo1_buffer_base_addr() const {
		return fifo1_buffer_base_addr;
	}

	void set_fifo1_buffer_base_addr(unsigned long fifo1BufferBaseAddr) {
		fifo1_buffer_base_addr = fifo1BufferBaseAddr;
	}
};


int get_gp_fifo_encapsulator_uart_ptrs(gp_fifo_encapsulator*& fifo0_ptr, gp_fifo_encapsulator*& fifo1_ptr,  std::vector<gp_fifo_encapsulator*>& fifo_pointer_vector, uart_register_file* uart_ptr, unsigned int secondary_uart_num);

#endif /* GP_FIFO_ENCAPSULATOR_H_ */
