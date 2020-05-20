/*
 * FIFO_access_container.h
 *
 *  Created on: Apr 13, 2011
 *      Author: linnyair
 */

#ifndef FIFO_ACCESS_CONTAINER_H_
#define FIFO_ACCESS_CONTAINER_H_
#include <alt_types.h>
#include <altera_avalon_pio_regs.h>
#include <sys/alt_irq.h>
#include <system.h>
#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <iostream>
#include <fstream>
#include <map>
#include <float.h>
#include <vector>
#include <unistd.h>
#include <time.h>
#include <iosfwd>
#include <iostream>
#include <sstream>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <iostream>
#include <fstream>
#include "chan_fatfs/fatfs_linnux_api.h"
#include "linnux_testbench_constants.h"
#include "interrupt_handling_utils.h"
#include "basedef.h"
#include "linnux_utils.h"
#include "uart_based_io_read_write_class.h"
#include "uart_based_pio_encapsulator.h"
#include "memory_mapped_uart_based_io_read_write_class.h"

#define FIFO_CONTAINER_CLASS_NUM_OF_FIFO_VALUES_TO_SHOW_PER_PRINTED_LINE 20

class FIFO_access_container {
	protected:

		unsigned long FIFO_base_address;
		unsigned long FIFO_flags_base_address;
		unsigned long FIFO_control_base_address;
		unsigned long FIFO_DATA_MASK;
		unsigned long FIFO_CAPACITY;

		unsigned long FIFO_flag_word;
		unsigned short rdempty;
		unsigned short rdfull;
		unsigned short wrempty;
		unsigned short wrfull;
		unsigned long addr_count;
		unsigned long current_FIFO_val;
		unsigned short data_lsb;
		unsigned short data_msb;
		unsigned short do_not_extract_bits;
		std::vector<unsigned long> fifo_last_read_contents;
		uart_based_io_read_write_class* io_rw_interface_ptr;
		uart_register_file* uart_ptr;
		unsigned long secondary_uart_num;
		std::string description;
        bool uses_ext_memory_instead_of_fifos;
        unsigned short num_bits_for_ext_mem_buffer;
        void* ext_mem_buf_ptr;

		virtual unsigned long get_FIFO_control_word();

		virtual void assert_FIFO_rdreq();
		virtual void deassert_FIFO_rdreq();
		virtual void assert_FIFO_rdclk();
		virtual void deassert_FIFO_rdclk();


		virtual void print_FIFO_status();
		virtual int acquire_FIFO();
		virtual int acquire_FIFO_without_waiting_for_it_to_fill();
		virtual int stop_fifo_aquire_condition_detected(time_t);
		virtual std::string get_fifo_val_string(LINNUX_FIFO_DATA_FORMATS data_format);

	public:
		virtual void rdclk_cycle_FIFO();
		virtual void read_FIFO_flags();
		virtual void parse_FIFO_flags();
		int capture_only(int do_acquire_fifo = 1, int num_of_values = -1);
		void acquire_and_capture_only(int do_not_initiate_acquire, int always_complete_acquire = 0, int do_not_wait_for_FIFO = 0, int num_of_values = -1);
		std::vector<unsigned long>* get_ptr_to_contents() { return &fifo_last_read_contents;};

		FIFO_access_container(unsigned long base_addr, unsigned long flag_base_addr, unsigned long control_base_addr, unsigned long fifo_dmask,
				unsigned long capacity, std::string description_val, unsigned short data_lsb_val=0, unsigned short data_msb_val=31,
				uart_based_io_read_write_class* io_rw_interface_ptr = NULL, uart_register_file* uart_ptr = NULL, unsigned long secondary_uart_num = 0, bool uses_ext_memory_instead_of_fifos = false)
		{
			FIFO_base_address = base_addr;
			FIFO_flags_base_address = flag_base_addr;
			FIFO_control_base_address = control_base_addr;
			FIFO_DATA_MASK = fifo_dmask;
			FIFO_CAPACITY = capacity;
			description = description_val;
			if (!uses_ext_memory_instead_of_fifos) {
			fifo_last_read_contents.reserve(FIFO_CAPACITY);
            fifo_last_read_contents = std::vector<unsigned long >(FIFO_CAPACITY, 0);
			}
            data_msb = data_msb_val;
            data_lsb = data_lsb_val;
            do_not_extract_bits = (data_msb == 31) && (data_lsb == 0);
            if ((data_msb-data_lsb) < 7) {
            	set_num_bits_for_ext_mem_buffer(8);
            } else {
                if ((data_msb-data_lsb) < 15) {
                        	set_num_bits_for_ext_mem_buffer(16);
                } else {
                          	set_num_bits_for_ext_mem_buffer(32);
                }
            }
            this->io_rw_interface_ptr = io_rw_interface_ptr;
            this->uart_ptr = uart_ptr;
            this->secondary_uart_num = secondary_uart_num;
            set_uses_ext_memory_instead_of_fifos(uses_ext_memory_instead_of_fifos);
            set_ext_mem_buf_ptr(NULL);
    }

       FIFO_access_container(uart_register_file* uart_ptr,
                             unsigned long secondary_uart_num,
    		                 unsigned long fifo_dmask,
    		                 unsigned long capacity,
    		                 std::string description_val,
    		                 unsigned long base_addr        ,
    		                 unsigned long flag_base_addr   ,
    		                 unsigned long control_base_addr,
    		                 unsigned short data_lsb_val=0,
    		                 unsigned short data_msb_val=31,
    		                 bool uses_ext_memory_instead_of_fifos = false
    		                 ) : FIFO_access_container(base_addr        ,
        			                 flag_base_addr   ,
        			                 control_base_addr,
        			                 fifo_dmask,
        			                 capacity,
        			                 description_val,
        			                 data_lsb_val,
        			                 data_msb_val,
        			                 new uart_based_io_read_write_class(uart_ptr,secondary_uart_num),
        			                 uart_ptr,
        			                 secondary_uart_num,
        			                 uses_ext_memory_instead_of_fifos
        			                )
		{

		}

       FIFO_access_container(uart_register_file* uart_ptr,
                                   unsigned long secondary_uart_num,
          		                 unsigned long fifo_dmask,
          		                 unsigned long capacity,
          		                 std::string description_val,
          		                 unsigned long base_addr        ,
          		                 unsigned long flag_base_addr   ,
          		                 unsigned long control_base_addr,
          		                 bool use_high_speed_wishbone_rw_link,
          		             	 unsigned long status_wishbone_base,
          		             	 unsigned long ctrl_wishbone_base,
          		                 unsigned short data_lsb_val=0,
          		                 unsigned short data_msb_val=31,
        		                 bool uses_ext_memory_instead_of_fifos = false
          		                 ) : FIFO_access_container(base_addr        ,
              			                 flag_base_addr   ,
              			                 control_base_addr,
              			                 fifo_dmask,
              			                 capacity,
              			                 description_val,
              			                 data_lsb_val,
              			                 data_msb_val,
              			                 use_high_speed_wishbone_rw_link ?  new memory_mapped_uart_based_io_read_write_class (ctrl_wishbone_base,status_wishbone_base) :  new uart_based_io_read_write_class(uart_ptr,secondary_uart_num),
              			                 uart_ptr,
              			                 secondary_uart_num,
              			                 uses_ext_memory_instead_of_fifos
              			                )
      		{

      		}

	virtual void enable_FIFO_write();
	virtual void disable_FIFO_write();
    virtual void set_up_fifo_for_acquisition(int do_pre_flush = 1);
    virtual int complete_fifo_aquisition(int do_not_wait_for_FIFO = 0);
    virtual  ~FIFO_access_container();
    virtual unsigned long read_value_from_FIFO();
    virtual void print_FIFO_contents(LINNUX_FIFO_DATA_FORMATS data_format, int verbose, int num_of_values = -1);
    virtual void flush_FIFO_contents(int silent = 1);
    virtual void acquire_and_print_contents_to_console(LINNUX_FIFO_DATA_FORMATS, int, int do_not_initiate_acquire =0,int num_of_values = -1 );
    virtual int capture_and_save_to_file(std::string, LINNUX_FIFO_DATA_FORMATS, int, int do_not_initiate_acquire =0, int num_of_values = -1);
    virtual unsigned int get_wrusedw() { return this->addr_count; };
    virtual std::vector<unsigned long>& get_fifo_last_read_contents()
    {
        return fifo_last_read_contents;
    }

    virtual int capture_and_save_to_string(std::string & total_str, LINNUX_FIFO_DATA_FORMATS data_format, int is_initial, int is_final, int num_of_values = -1);

    virtual unsigned short getData_lsb() const
    {
        return data_lsb;
    }

    virtual unsigned short getData_msb() const
    {
        return data_msb;
    }

    virtual void setData_lsb(unsigned short  data_lsb)
    {
        this->data_lsb = data_lsb;
    }

    virtual void setData_msb(unsigned short  data_msb)
    {
        this->data_msb = data_msb;
    }

    virtual std::string get_description() {return description;}

	void set_io_rw_interface_ptr(uart_based_io_read_write_class* io_rw_interface_ptr) {
			this->io_rw_interface_ptr = io_rw_interface_ptr;
	}

	uart_based_io_read_write_class* get_io_rw_interface_ptr() {
		return io_rw_interface_ptr;
	}

	uart_register_file* get_uart_ptr() {
		return uart_ptr;
	}

	unsigned long get_secondary_uart_num() {
           return secondary_uart_num;
	}
	unsigned long get_fifo_capacity() {
		return FIFO_CAPACITY;
	}

	virtual  bool get_uses_ext_memory_instead_of_fifos() const {
		return uses_ext_memory_instead_of_fifos;
	}

	virtual  void set_uses_ext_memory_instead_of_fifos(
			bool usesExtMemoryInsteadOfFifos) {
		uses_ext_memory_instead_of_fifos = usesExtMemoryInsteadOfFifos;
	}

	virtual  unsigned short get_num_bits_for_ext_mem_buffer() const {
		return num_bits_for_ext_mem_buffer;
	}

	virtual  void set_num_bits_for_ext_mem_buffer(
			unsigned short numBitsForExtMemBuffer) {
		num_bits_for_ext_mem_buffer = numBitsForExtMemBuffer;
	}

	virtual void* get_ext_mem_buf_ptr() const {
		return ext_mem_buf_ptr;
	}

	virtual void set_ext_mem_buf_ptr(void* extMemBufPtr) {
		ext_mem_buf_ptr = extMemBufPtr;
	}
};

#endif /* FIFO_ACCESS_CONTAINER_H_ */
