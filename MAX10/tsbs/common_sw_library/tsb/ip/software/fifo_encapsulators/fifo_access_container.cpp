/*
 * FIFO_access_container.cpp
 *
 *  Created on: Apr 13, 2011
 *      Author: linnyair
 */

#include "fifo_access_container.h"
#define u(x) do { if (DEBUG_FIFO_AND_GP_FIFO_ACQUISITION) { x; } } while(0)
using namespace std;
extern volatile int button_irq_edge_capture;

FIFO_access_container::~FIFO_access_container()
{
	// TODO Auto-generated destructor stub
}

void FIFO_access_container::FIFO_access_container::read_FIFO_flags()
{
	if (uart_ptr == NULL) {
	  FIFO_flag_word = IORD_ALTERA_AVALON_PIO_DATA(FIFO_flags_base_address);
	} else {
	  FIFO_flag_word = this->get_io_rw_interface_ptr()->read_status(FIFO_flags_base_address);
	}
}

unsigned long FIFO_access_container::get_FIFO_control_word()
{
	if (uart_ptr == NULL) {
	   return (IORD_ALTERA_AVALON_PIO_DATA(FIFO_control_base_address));
	} else {
		 return (this->get_io_rw_interface_ptr()->read(FIFO_control_base_address));
	}
}

void FIFO_access_container::enable_FIFO_write()
{
	if (uart_ptr == NULL) {
	   IOWR_ALTERA_AVALON_PIO_DATA(FIFO_control_base_address, get_FIFO_control_word() | 0x1);
	} else {
		this->get_io_rw_interface_ptr()->write(FIFO_control_base_address, get_FIFO_control_word() | 0x1);
	}
}
void FIFO_access_container::disable_FIFO_write()
{
	if (uart_ptr == NULL) {
	  IOWR_ALTERA_AVALON_PIO_DATA(FIFO_control_base_address, get_FIFO_control_word() & (~0x1));
	} else {
	  this->get_io_rw_interface_ptr()->write(FIFO_control_base_address, get_FIFO_control_word() & (~0x1));
	}
}

void FIFO_access_container::assert_FIFO_rdreq()
{
	if (uart_ptr == NULL) {
	  IOWR_ALTERA_AVALON_PIO_DATA(FIFO_control_base_address, get_FIFO_control_word() | 0x2);
	} else {
		this->get_io_rw_interface_ptr()->write(FIFO_control_base_address, get_FIFO_control_word() | 0x2);
	}
}

void FIFO_access_container::deassert_FIFO_rdreq()
{
	if (uart_ptr == NULL) {
	  IOWR_ALTERA_AVALON_PIO_DATA(FIFO_control_base_address, get_FIFO_control_word() & (~0x2));
	} else {
	  this->get_io_rw_interface_ptr()->write(FIFO_control_base_address, get_FIFO_control_word() & (~0x2));
	}
}

void FIFO_access_container::assert_FIFO_rdclk()
{
	if (uart_ptr == NULL) {
	   IOWR_ALTERA_AVALON_PIO_DATA(FIFO_control_base_address, get_FIFO_control_word() | 0x10);
	} else {
	   this->get_io_rw_interface_ptr()->write(FIFO_control_base_address, get_FIFO_control_word() | 0x10);
	}
}

void FIFO_access_container::deassert_FIFO_rdclk()
{
	if (uart_ptr == NULL) {
	   IOWR_ALTERA_AVALON_PIO_DATA(FIFO_control_base_address, get_FIFO_control_word() & (~0x10));
	} else {
		this->get_io_rw_interface_ptr()->write(FIFO_control_base_address, get_FIFO_control_word() & (~0x10));
	}
}

void FIFO_access_container::parse_FIFO_flags()
{
	addr_count = FIFO_flag_word & 0xFFFF;
	rdempty = ((FIFO_flag_word & 0x10000000) != 0);
	rdfull = ((FIFO_flag_word & 0x01000000) != 0);
	wrempty = ((FIFO_flag_word & 0x00100000) != 0);
	wrfull = ((FIFO_flag_word & 0x00010000) != 0);
}

void FIFO_access_container::print_FIFO_status()
{
	u(safe_print(cout << "Fifo [" << description << "] Flags: rdempty: " << rdempty << " rdfull: " << rdfull << " wrempty: " << wrempty << " wrfull :" << wrfull << " addr_count: " << addr_count << "\n"););
}

void FIFO_access_container::rdclk_cycle_FIFO()
{
	deassert_FIFO_rdclk();
	assert_FIFO_rdclk();
	deassert_FIFO_rdclk();
}

unsigned long FIFO_access_container::read_value_from_FIFO()
{
	assert_FIFO_rdreq();
	assert_FIFO_rdclk();
	deassert_FIFO_rdclk();
	deassert_FIFO_rdreq();
	unsigned long raw_data;

	if (uart_ptr == NULL) {
	   raw_data = IORD_ALTERA_AVALON_PIO_DATA(FIFO_base_address) & FIFO_DATA_MASK;
	} else {
	   raw_data = this->get_io_rw_interface_ptr()->read_status(FIFO_base_address) & FIFO_DATA_MASK;
	}

	unsigned long actual_data;

	if (do_not_extract_bits)
		actual_data = raw_data;
	else
		actual_data = extract_bit_range(raw_data,data_lsb,data_msb);

	return (actual_data);
}

string FIFO_access_container::get_fifo_val_string(LINNUX_FIFO_DATA_FORMATS data_format)
{
	unsigned short num_binary_digits = data_msb - data_lsb + 1;
	char current_str[256];
	switch (data_format)
			{
				case LINNUX_HEX_FORMAT: sprintf(current_str,"%.8lX ", current_FIFO_val); break;
				case LINNUX_BINARY_FORMAT: sprintf(current_str,"%s ", dec2bin(current_FIFO_val,num_binary_digits).c_str()); break;
				case LINNUX_DECIMAL_FORMAT:
				default: sprintf(current_str,"%lu ", current_FIFO_val);
		    }
	return (string(current_str));
}
void FIFO_access_container::print_FIFO_contents(LINNUX_FIFO_DATA_FORMATS data_format, int verbose, int num_of_values)
{
	unsigned int num_of_values_to_read = (num_of_values == -1) ? FIFO_CAPACITY : num_of_values;
	fifo_last_read_contents = std::vector<unsigned long>(num_of_values_to_read, 0); //clear FIFO

	//Three rdclks; necessary from datasheet
	rdclk_cycle_FIFO();
	rdclk_cycle_FIFO();
	rdclk_cycle_FIFO();

	read_FIFO_flags();
	parse_FIFO_flags();
	if (verbose) {
		safe_print(cout << "Printing contents of FIFO in Matlab friendly manner as unsigned data... \n" << description << " = [ ");
	}
	unsigned long watchdog_timer = 0;

	while ((!rdempty) && (watchdog_timer < num_of_values_to_read))
	{
		if ((watchdog_timer != 0) && ((watchdog_timer % FIFO_CONTAINER_CLASS_NUM_OF_FIFO_VALUES_TO_SHOW_PER_PRINTED_LINE) == 0))
		{
			if (verbose){
				safe_print(cout << " ... \n");
			    cout.flush();
			}
		}
		current_FIFO_val = read_value_from_FIFO();
		fifo_last_read_contents.at(watchdog_timer) = current_FIFO_val;
		watchdog_timer++;
		// safe_print(cout << "FIFO vector size: " << fifo_last_read_contents.size() << " max size: " << fifo_last_read_contents.max_size() << "\n");
		read_FIFO_flags();
		parse_FIFO_flags();
		if (verbose)
		{
			safe_print(cout << get_fifo_val_string(data_format));
			 cout.flush();
		}
	}
	if (verbose) {
		safe_print(cout << "\n];\n");
		 cout.flush();
	}

	fifo_last_read_contents.resize((watchdog_timer > 0) ? watchdog_timer :0,0);
	if (verbose) {
	 safe_print(cout << "Read a total of : " << watchdog_timer << " values\n");
	 cout.flush();
	}
}

void FIFO_access_container::flush_FIFO_contents(int silent)
{
	//Three rdclks; necessary from datasheet
	rdclk_cycle_FIFO();
	rdclk_cycle_FIFO();
	rdclk_cycle_FIFO();
	unsigned long watchdog_timer = 0;
	read_FIFO_flags();
	parse_FIFO_flags();
	while ((!rdempty) && (watchdog_timer < FIFO_CAPACITY))
	{
		watchdog_timer++;
		current_FIFO_val = read_value_from_FIFO();
		read_FIFO_flags();
		parse_FIFO_flags();
	}

    if (watchdog_timer>0)
    {
    	if ((!silent) || DEBUG_FIFO_AND_GP_FIFO_ACQUISITION)
    	{
	      safe_print(cout << "Fifo: " << description << ", Flushed a total of : " << watchdog_timer << " values\n");
    	}
    }
}

int FIFO_access_container::stop_fifo_aquire_condition_detected(time_t start_time)
{
	time_t end_time;
	unsigned long user_stop_request = get_interrupt_positions(STOP_FIFO_FILL_REQUEST_MASK);
	time(&end_time);
	double total_runtime = difftime(end_time, start_time);

	if ((total_runtime > FIFO_FILL_REQUEST_TIMEOUT_TIME_IN_SECS) || user_stop_request)
	{
		safe_print(std::cout << "\n**************************************************************\n");
		safe_print(std::cout << "In FIFO: " << description << endl);
		safe_print(std::cout << "Error: Stopped waiting for FIFO Fill after " << total_runtime << " secs due to ");
		if (user_stop_request)
		{
			safe_print(std::cout << " User Stop Request via Button\n");
			reset_interrupt_positions(STOP_FIFO_FILL_REQUEST_MASK);
		} else
		{
			safe_print(std::cout << "watchdog timer limit of " << FIFO_FILL_REQUEST_TIMEOUT_TIME_IN_SECS << " secs\n");
		}
		return 1;
	} else
	{
		return 0;
	}
}

void FIFO_access_container::set_up_fifo_for_acquisition(int do_pre_flush)
{
	if (do_pre_flush) {
	  flush_FIFO_contents();
	}

	read_FIFO_flags();
	parse_FIFO_flags();
	print_FIFO_status();
	enable_FIFO_write();
}
int FIFO_access_container::complete_fifo_aquisition(int do_not_wait_for_FIFO)
{
	int stop_has_been_requested = 0;
	time_t start_time;
	time(&start_time);
	reset_interrupt_positions(STOP_FIFO_FILL_REQUEST_MASK);
	if (do_not_wait_for_FIFO) {
		read_FIFO_flags();
		parse_FIFO_flags();
	} else {
		while (!wrfull)
		{
			stop_has_been_requested = stop_fifo_aquire_condition_detected(start_time);
			if (stop_has_been_requested)
			{
				break;
			}
			read_FIFO_flags();
			parse_FIFO_flags();
		}
	}
	disable_FIFO_write();
	return (stop_has_been_requested);
}

int FIFO_access_container::acquire_FIFO()
{
	set_up_fifo_for_acquisition();
	return (complete_fifo_aquisition());
}


int FIFO_access_container::acquire_FIFO_without_waiting_for_it_to_fill()
{
	set_up_fifo_for_acquisition();
	return (complete_fifo_aquisition(1));
}


void FIFO_access_container::acquire_and_print_contents_to_console(LINNUX_FIFO_DATA_FORMATS data_format,
		int verbose,
		int do_not_initiate_acquire,
		int num_of_values)
{
	u(safe_print(std::cout << "FIFO_access_container::acquire_and_print_contents_to_console: [" << this->get_description() <<  "] do_not_initiate_acquire = " << do_not_initiate_acquire << " num_of_values = "  << num_of_values << std::endl););
	int stop_has_been_requested = do_not_initiate_acquire ?  complete_fifo_aquisition() : acquire_FIFO();
	u(safe_print(std::cout << "FIFO_access_container::acquire_and_print_contents_to_console: [" << this->get_description() <<  "] stop has been requested = " << stop_has_been_requested << std::endl););

	if (stop_has_been_requested)
	{
		return;
	}
	read_FIFO_flags();
	parse_FIFO_flags();
	print_FIFO_status();

	print_FIFO_contents(data_format, verbose, num_of_values);

	read_FIFO_flags();
	parse_FIFO_flags();
	print_FIFO_status();
}


void FIFO_access_container::acquire_and_capture_only(int do_not_initiate_acquire, int always_complete_acquire, int do_not_wait_for_FIFO, int num_of_values)
{
	u(safe_print(std::cout << "FIFO_access_container::acquire_and_capture_only: [" << this->get_description() <<  "] do_not_initiate_acquire = " << do_not_initiate_acquire << std::endl););
	int stop_has_been_requested = do_not_initiate_acquire ?  complete_fifo_aquisition(do_not_wait_for_FIFO) : acquire_FIFO();
	u(safe_print(std::cout << "FIFO_access_container::acquire_and_capture_only: [" << this->get_description() <<  "] stop has been requested = " << stop_has_been_requested << std::endl););

	if (stop_has_been_requested && (!always_complete_acquire))
	{
		return;
	}
	read_FIFO_flags();
	parse_FIFO_flags();
	print_FIFO_status();

	capture_only(0,num_of_values);

	read_FIFO_flags();
	parse_FIFO_flags();
	print_FIFO_status();
}

int FIFO_access_container::capture_and_save_to_file(string filename, LINNUX_FIFO_DATA_FORMATS data_format, int close_file_on_exit, int do_not_initiate_acquire, int num_of_values)
{
	unsigned int num_of_values_to_read = (num_of_values == -1) ? FIFO_CAPACITY : num_of_values;
	fifo_last_read_contents = std::vector<unsigned long>(num_of_values_to_read, 0); //clear FIFO

	char current_str[256];
	string current_value_str;
	int write_successful = 0;
	int filehandle = linnux_sd_card_file_open_for_write(filename);
	if (filehandle < 0)
	{
		safe_print(cout << "Error: bad filehandle in FIFO_access_container::capture_and_save_Input_FIFO\n");
		return (filehandle);
	}

	int stop_has_been_requested = do_not_initiate_acquire ?  complete_fifo_aquisition() : acquire_FIFO();
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
		u(
		if ((watchdog_timer % 1000) == 0){
			safe_print(cout << "Printing value: " << watchdog_timer << endl);
		}
		);
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
	return (filehandle);
}



int FIFO_access_container::capture_and_save_to_string(string& total_str, LINNUX_FIFO_DATA_FORMATS data_format, int is_initial, int is_final, int num_of_values)
{
	unsigned int num_of_values_to_read = (num_of_values == -1) ? FIFO_CAPACITY : num_of_values;
	fifo_last_read_contents = std::vector<unsigned long>(num_of_values_to_read, 0); //clear FIFO

	char current_str[256];
	string tempstr;
	ostringstream out_str;
	out_str << total_str;

	int stop_has_been_requested = acquire_FIFO();
	if (stop_has_been_requested)
	{
		return LINNUX_RETVAL_ERROR;
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
	return (0);
}



int FIFO_access_container::capture_only(int do_acquire_fifo, int num_of_values)
{
	unsigned int num_of_values_to_read = (num_of_values == -1) ? FIFO_CAPACITY : num_of_values;
	fifo_last_read_contents = std::vector<unsigned long>(num_of_values_to_read, 0); //clear FIFO

	if (do_acquire_fifo) {
			int stop_has_been_requested = acquire_FIFO();
			if (stop_has_been_requested)
			{
				return LINNUX_RETVAL_ERROR;
			}
	}
	//Three rdclks; necessary from datasheet
	rdclk_cycle_FIFO();
	rdclk_cycle_FIFO();
	rdclk_cycle_FIFO();

	read_FIFO_flags();
	parse_FIFO_flags();
	//safe_print(cout << "Printing contents of input FIFO in Matlab friendly manner as unsigned data... \n[ ");

	unsigned long watchdog_timer = 0;
	while ((!rdempty) && (watchdog_timer < num_of_values_to_read))
	{

		current_FIFO_val = read_value_from_FIFO();
		fifo_last_read_contents.at(watchdog_timer) = current_FIFO_val;
		watchdog_timer++;

		read_FIFO_flags();
		parse_FIFO_flags();
	}
	return (0);
}
