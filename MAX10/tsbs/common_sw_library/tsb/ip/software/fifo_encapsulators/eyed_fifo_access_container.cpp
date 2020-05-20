/*
 * EyeD_FIFO_Access_Container.cpp
 *
 *  Created on: Apr 13, 2011
 *      Author: linnyair
 */

#include "eyed_fifo_access_container.h"

using namespace std;
extern int force_eyed_test_mode;

EyeD_FIFO_Access_Container::~EyeD_FIFO_Access_Container()
{
	// TODO Auto-generated destructor stub
}

void EyeD_FIFO_Access_Container::write_eyed_address(unsigned long address, unsigned long val)
{
	IOWR_ALTERA_AVALON_PIO_DATA(eyed_controller_base_address+(address<<2), val); //the <<2 is to counteract what is done in addr_gen module
}

unsigned long EyeD_FIFO_Access_Container::read_eyed_address(unsigned long address)
{
	return (IORD_ALTERA_AVALON_PIO_DATA(eyed_controller_base_address+(address<<2))); //the <<2 is to counteract what is done in addr_gen module
}

void EyeD_FIFO_Access_Container::eyed_init_new_aquire()
{
	//safe_print(cout << "Aquiring EyeD\n");
	write_eyed_address(1, 1);
	write_eyed_address(0, 0);//reset counters, disable count;
	//usleep(10);
	write_eyed_address(1, 0); //stop resetting counters
	//usleep(10);
	write_eyed_address(0, 1);//enable count;
    //usleep(1);
	//safe_print(cout << "Ended Aquiring EyeD\n");
}

void EyeD_FIFO_Access_Container::read_eyed_matrix(matrix<unsigned long>& the_mat, unsigned long num_eyed_samples_per_capture)
{
	static unsigned long y_index;
	//set_total_sample_count(get_total_sample_count()+1); //increase sample count

	for (unsigned long t_index = 0; t_index < num_eyed_samples_per_capture; t_index++)
	{
		y_index = read_value_from_FIFO();
		the_mat(t_index,y_index >> EYED_NUM_BITS_TO_IGNORE_FOR_EYED_PLOT) += 1;
	}
}

void EyeD_FIFO_Access_Container::wait_for_eyed_to_be_ready(double timeout_time)
{
	time_t end_time, start_time;
	double total_runtime;
	time(&start_time);
	unsigned long status_address = 2; //read status address from eyed
	unsigned long count_is_ready = read_eyed_address(status_address) & 0x2; //bit 1 is the all sampled read bit
	while (!count_is_ready)
	{
		time(&end_time);
		total_runtime = difftime(end_time, start_time);
		if (total_runtime > timeout_time)
		{
			safe_print(safe_print(cout << "Error: Stopped waiting for EyeD after " << total_runtime << " secs due to watchdog timer limit of " << timeout_time << " secs\n"));
			return;
		}
		count_is_ready = read_eyed_address(status_address) & 0x2; //bit 1 is the all sampled read bit
	}

}

void EyeD_FIFO_Access_Container::enable_debug()
{
	in_debug_mode = 1;
}

void EyeD_FIFO_Access_Container::disable_debug()
{
	in_debug_mode = 0;
}

void EyeD_FIFO_Access_Container::debug_print_input_fifo_status()
{
	//	unsigned long read_value = read_value_from_reg_keeper_reg(0x129);
	//	if (in_debug_mode)
	//	   printf("Read from (%6lX) value (%8lX)\n",(long unsigned int) 0x129,read_value);
}

std::vector<std::string> EyeD_FIFO_Access_Container::acquire_and_print_eyed_mat(unsigned long num_eyed_symbols, unsigned long num_eyed_samples_per_capture_val, string redirect_filename)
{
	set_num_eyed_samples_per_capture(num_eyed_samples_per_capture_val);
	acquire_eyed_mat(num_eyed_symbols);
	return print_eyed_mat(redirect_filename);
}

vector<string> EyeD_FIFO_Access_Container::print_eyed_mat(string redirect_filename)
{
	int redirect_file_handle;
	vector<string> retvec(3);
	ostringstream result_str;
	ostringstream tcl_result_str;
	ostringstream matlab_result_str;


	safe_print(safe_print(cout << "Formatting EyeD Results.... \n "));
	result_str <<  "eyed = [ \n";
	matlab_result_str << "[ ";
	for (unsigned long t_index = 0; t_index < num_eyed_samples_per_capture; t_index++)
	{
		for (unsigned long y_index = 0; y_index < eyed_num_signal_levels; y_index++)
		{
		   result_str << mat(t_index,y_index) << " ";
		   matlab_result_str << mat(t_index,y_index) << " ";
		   tcl_result_str << mat(t_index,y_index);
		   if (!((t_index == num_eyed_samples_per_capture-1) && (y_index == eyed_num_signal_levels-1))) {
			   tcl_result_str << " ";
		   }
		}
		if (t_index != num_eyed_samples_per_capture - 1)
		{
			result_str << " ;\n";
			matlab_result_str << " ;\n";
		}

	}

	result_str << "\n];\n eyed=eyed'/(max(max(eyed)))*64; figure; image(eyed); colormap(jet); colorbar;";
	matlab_result_str << "\n]\n ";

	int use_redirection = (redirect_filename.length() != 0);

	if (use_redirection)
	{
		redirect_file_handle = linnux_sd_card_file_open_for_write(redirect_filename);
		if (redirect_file_handle < 0)
		{
			safe_print(cout << "Error: could not open file " << redirect_filename << " in EyeD_FIFO_Access_Container::print_eyed_mat - Exiting\n");
			return retvec;
		}
		linnux_sd_card_write_string_to_file(redirect_file_handle, result_str.str());
		linnux_sd_card_fclose(redirect_file_handle);
	}
	retvec[0] = tcl_result_str.str();
	retvec[1] = result_str.str();
	retvec[2] = matlab_result_str.str();
	safe_print(cout << "Finished Formatting EyeD Results. \n ");

	return retvec;
}


void EyeD_FIFO_Access_Container::acquire_eyed_mat(unsigned long num_eyed_symbols)
{

	if (num_eyed_symbols == 0)
	{
		safe_print(std::cout << "Error: EyeD_FIFO_Access_Container::acquire_eyed_mat num_eyed_symbols must be bigger than 0\n");
		return;
	}


	if (force_eyed_test_mode)
	{
		//safe_print(cout << "In eyeD Test Mode: Using all 0 matrix For acquisition!\n");
		//return;
		num_eyed_symbols = 100; //make EyeD Very fast
		safe_print(cout << "In eyeD Test Mode: Using " << num_eyed_symbols << " symbols per EyeD\n");
	}

	unsigned long numiterations, numsymbols_per_iteration, upper_limit_for_fifo_grab;

	unsigned long fifo_locations_available = (unsigned long) (floor (((double) FIFO_CAPACITY) / ((double) num_eyed_samples_per_capture)));
	mat.SetSize(num_eyed_samples_per_capture,eyed_num_signal_levels);
		//initialize matrix to 0
		for (unsigned long t_index = 0; t_index < num_eyed_samples_per_capture; t_index++)
		{
			for (unsigned long y_index = 0; y_index < eyed_num_signal_levels; y_index++)
			{
				mat(t_index,y_index) = 0;
			}
		}


	if (fifo_locations_available >= num_eyed_symbols)
	{
		numiterations = 1;
		numsymbols_per_iteration = num_eyed_symbols;
	} else
	{
		numiterations = ((unsigned long) ((((double) (num_eyed_symbols * num_eyed_samples_per_capture))) / (double) (FIFO_CAPACITY))) + 1;
		numsymbols_per_iteration = (unsigned long) (floor(((double)(num_eyed_symbols))/((double)numiterations)));
	}
	safe_print(cout << "Flushing EyeD FIFO Content\n");
	flush_FIFO_contents();
	safe_print(cout << "Running " << numiterations << " Acquisition iterations of " << numsymbols_per_iteration << " Blocks of " << num_eyed_samples_per_capture << "Samples per block each\n");


	safe_print(cout << "Initiating EyeD Acquisition...\n");
	//set_total_sample_count(0); //reset sample count

	write_value_to_reg_keeper_reg(symbol_count_limit_reg_addr, numsymbols_per_iteration);
    write_value_to_reg_keeper_reg(sample_count_limit_reg_addr, num_eyed_samples_per_capture);
	eyed_init_new_aquire();
	wait_for_eyed_to_be_ready(eyed_timeout_time);

	//make sure FIFO is ready to be read
	rdclk_cycle_FIFO();
	rdclk_cycle_FIFO();
	rdclk_cycle_FIFO();

	// safe_print(cout << 1 << " "; debug_print_input_fifo_status());
	read_eyed_matrix(mat, num_eyed_samples_per_capture); //get initial matrix

	for (unsigned long current_iteration = 0; current_iteration < numiterations; current_iteration++)
	{
		if (current_iteration != 0)
		{
		  flush_FIFO_contents(1); //silent flush of FIFO, in case that the number of samples per block is not a divisor of the FIFO size
		  eyed_init_new_aquire();
		  wait_for_eyed_to_be_ready(eyed_timeout_time);
		  //make sure FIFO is ready to be read
		  rdclk_cycle_FIFO();
		  rdclk_cycle_FIFO();
		  rdclk_cycle_FIFO();

		  upper_limit_for_fifo_grab = numsymbols_per_iteration;

		} else
		{
			upper_limit_for_fifo_grab = numsymbols_per_iteration - 1;
		}
		for (unsigned long i = 0; i < upper_limit_for_fifo_grab; i++)
		{
			read_eyed_matrix(mat, num_eyed_samples_per_capture); //add more points to matrix
		}
	}
	safe_print(cout << "EyeD Acquisition Finished.\n");

}

void EyeD_FIFO_Access_Container::set_EYED_clock_to_jitter_free_clock()
{
	write_value_to_reg_keeper_reg(eyed_trigger_sel_and_seq_det_reg_addr, read_value_from_reg_keeper_reg(eyed_trigger_sel_and_seq_det_reg_addr) | 0x01);
}

void EyeD_FIFO_Access_Container::set_EYED_clock_to_jittered_clock()
{
	write_value_to_reg_keeper_reg(eyed_trigger_sel_and_seq_det_reg_addr, read_value_from_reg_keeper_reg(eyed_trigger_sel_and_seq_det_reg_addr) & (~0x01));
}



float EyeD_FIFO_Access_Container::get_peak_to_peak_value()
{
	vector<unsigned long> sum_vect = get_eye_vertical_projection();
	float upper_limit=0, lower_limit = sum_vect.size()-1;
	//safe_print(cout << "1 Upper: " << upper_limit << " Sumvect.size() " << sum_vect.size() << endl);
	for (int i = 0; i < (int) (sum_vect.size()); i++)
	{
	  if (sum_vect[i] > 0)
	  {
		  lower_limit = (float) i;
		  break;
	  }
	}
	//safe_print(cout << "2 Upper: " << upper_limit << " Sumvect.size() " << sum_vect.size() << endl);
	for (int i = (int) (sum_vect.size()-1); i >=0; i--)
		{
//		  safe_print(cout << "i : " << i << " 2.3 Upper: " << upper_limit << " Sumvect.size() " << sum_vect.size() << endl);
		  if (sum_vect[i] > 0)
		  {
			  upper_limit = (float) i;
//			  safe_print(cout << "i : " << i << " 2.5 Upper: " << upper_limit << " Sumvect.size() " << sum_vect.size() << endl);
			  break;
		  }
		}
	//safe_print(cout << "3 Upper: " << upper_limit << "Sumvect.size() " << sum_vect.size() << endl);

	if (upper_limit < lower_limit) {
		safe_print(cout << "Error: Enhanced_EyeD_class::get_peak_to_peak_value() : upper_limit < lower_limit : upper_limit = " << upper_limit << " lower_limit = " << lower_limit << endl);
		return (1.0/((float) eyed_num_signal_levels)); // return minimum value to avoid returning 0
	}

	//safe_print(cout << "4 Upper: " << upper_limit << "Sumvect.size() " << sum_vect.size() << endl);

    safe_print(cout << "Upper : " << upper_limit << " Lower: " << lower_limit << " Results: " << ((upper_limit-lower_limit+1)/((float) eyed_num_signal_levels)) << endl);
	return ((upper_limit-lower_limit+1.0)/((float) eyed_num_signal_levels));

}

std::vector<unsigned long> EyeD_FIFO_Access_Container::get_eye_vertical_projection()
{
	vector<unsigned long> sum_vect(eyed_num_signal_levels,0);
	for (unsigned int curr_signal_level = 0; curr_signal_level < eyed_num_signal_levels; curr_signal_level++)
	{
		for (unsigned int i = 0; i < num_eyed_samples_per_capture; i++)
		{
			sum_vect[curr_signal_level] += mat(i,curr_signal_level);
		}
	}
	return sum_vect;
}
