/*
 * EyeD_FIFO_Access_Container.h
 *
 *  Created on: Apr 13, 2011
 *      Author: linnyair
 */

#ifndef EYED_FIFO_ACCESS_CONTAINER_H_
#define EYED_FIFO_ACCESS_CONTAINER_H_

#include "fifo_access_container.h"
#include "register_keeper_api.h"
#include "linnux_testbench_constants.h"
#include "matrix.hpp"

class EyeD_FIFO_Access_Container: public FIFO_access_container {
	protected:
		unsigned long eyed_controller_base_address;
		unsigned short in_debug_mode;
		unsigned long symbol_count_limit_reg_addr;
		unsigned long sample_count_limit_reg_addr;
		unsigned long eyed_trigger_sel_and_seq_det_reg_addr;
		unsigned long eyed_trigger_clock_select_mask;
		double eyed_timeout_time;
		unsigned long eyed_max_num_samples_per_block,eyed_num_signal_levels;
		unsigned long num_eyed_samples_per_capture;
    matrix<unsigned long > mat;
    void write_eyed_address(unsigned long  address, unsigned long  val);
    void eyed_init_new_aquire();
    void read_eyed_matrix(matrix<unsigned long > & the_mat, unsigned long  num_eyed_samples_per_capture);
    unsigned long read_eyed_address(unsigned long  address);
    void wait_for_eyed_to_be_ready(double timeout_time);
    unsigned long total_sample_count;
public:
    EyeD_FIFO_Access_Container(unsigned long  base_addr, unsigned long  flag_base_addr, unsigned long  control_base_addr, unsigned long  fifo_dmask, unsigned long  capacity, unsigned long  controller_base_address, unsigned long  symbol_count_limit_reg_addr_val, unsigned long  sample_count_limit_reg_addr_val, double eyed_timeout_time_val, unsigned long  max_samples_per_block_val, unsigned long  num_signal_levels_val, unsigned long  eyed_trigger_sel_and_seq_det_reg_addr_val, unsigned long  eyed_trigger_clock_select_mask_val, std::string description_val)
    :FIFO_access_container(base_addr, flag_base_addr, control_base_addr, fifo_dmask, capacity, description_val), mat(max_samples_per_block_val, num_signal_levels_val)
    {
        in_debug_mode = 0;
        eyed_controller_base_address = controller_base_address;
        symbol_count_limit_reg_addr = symbol_count_limit_reg_addr_val;
        sample_count_limit_reg_addr = sample_count_limit_reg_addr_val;
        eyed_timeout_time = eyed_timeout_time_val;
        eyed_trigger_sel_and_seq_det_reg_addr = eyed_trigger_sel_and_seq_det_reg_addr_val;
        eyed_trigger_clock_select_mask = eyed_trigger_clock_select_mask_val;
        eyed_max_num_samples_per_block = max_samples_per_block_val;
        eyed_num_signal_levels = num_signal_levels_val;
        total_sample_count = 0;
    }

    ;
    virtual ~EyeD_FIFO_Access_Container();
    void set_num_eyed_samples_per_capture(unsigned long  num_eyed_samples_per_capture_val)
    {
        if(num_eyed_samples_per_capture > eyed_max_num_samples_per_block){
            safe_print(std::cout << "EyeD: Error: " << num_eyed_samples_per_capture << " is bigger than maxed allowed samples per block " << eyed_max_num_samples_per_block << std::endl);
            safe_print(std::cout << "Setting number of samples per block to: " << eyed_max_num_samples_per_block << std::endl);
            num_eyed_samples_per_capture_val = eyed_max_num_samples_per_block;
        }
        num_eyed_samples_per_capture = num_eyed_samples_per_capture_val;
    }

    void set_EYED_clock_to_jitter_free_clock();
    void set_EYED_clock_to_jittered_clock();
    void enable_debug();
    void disable_debug();
    void debug_print_input_fifo_status();
    void acquire_eyed_mat(unsigned long  num_eyed_symbols);
    std::vector<std::string> print_eyed_mat(std::string redirect_filename);
    std::vector<std::string> acquire_and_print_eyed_mat(unsigned long  num_eyed_symbols, unsigned long  num_eyed_samples_per_capture_val, std::string redirect_filename);
    float get_peak_to_peak_value();
    std::vector<unsigned long> get_eye_vertical_projection();
    unsigned long get_total_sample_count() const
    {
        return total_sample_count;
    }

    void set_total_sample_count(unsigned long  total_sample_count)
    {
        this->total_sample_count = total_sample_count;
    }

};

#endif /* EYED_FIFO_ACCESS_CONTAINER_H_ */
