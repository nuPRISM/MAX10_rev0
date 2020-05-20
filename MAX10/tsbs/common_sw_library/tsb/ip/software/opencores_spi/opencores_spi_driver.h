
/**
 * @file
 * Interface to device driver for WB_SPI peripheral.
 *
 */

#ifndef OPENCORES_SPI_DRIVER_H
#define OPENCORES_SPI_DRIVER_H


#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <string>
#include "io.h"
#include "altera_pio_encapsulator.h"
#include "semaphore_locking_class.h"
#include "abstract_io_read_write_class.h"
#include "uart_based_io_read_write_class.h"
#include "uart_based_pio_encapsulator.h"

extern "C" {
#include "includes.h"
#include "ucos_ii.h"
}

#define OPENCORES_SPI_DEFAULT_CLOCK_RATE_HZ           (50000000)
#define OPENCORES_SPI_DEFAULT_BASE_ADDRESS_OFFSET     (0x0)
#define OPENCORES_SPI_DEFAULT_SDIO_HELPER_OFFSET     (0x8)
#define OPENCORES_SPI_DEFAULT_ACTIVITY_INDICATOR_OFFSET (0x18)
#define OPENCORES_SPI_DEFAULT_DEBUG_TAG_WORD_OFFSET     (0x20)
#define OPENCORES_SPI_DEFAULT_DEBUG_AUX_OUT_OFFSET     (0x24)
#define OPENCORES_SPI_DEFAULT_DEBUG_AUX_IN_OFFSET     (0x28)

class opencores_spi_driver : public semaphore_locking_class
{
protected:
    unsigned long base_clock_rate;
    unsigned long   baseaddress;
	bool use_sdio_helper;
	abstract_io_read_write_class* io_rw_interface_ptr;
	unsigned long spi_calc_cdiv(unsigned long baudrate);
	altera_pio_encapsulator* sdio_helper_encapsulator;
	altera_pio_encapsulator* activity_indicator_encapsulator;
	altera_pio_encapsulator* debug_tag_word_encapsulator;
	altera_pio_encapsulator* aux_out_encapsulator;
	altera_pio_encapsulator* aux_in_encapsulator;

	void threadwait();
	bool spi_busy();
	unsigned long spi_received32();
	void spi_readblock(uint8_t* buf, int bufsize);
	void spi_writeblock(uint8_t* buf, int bufsize);
	std::string description;
	unsigned long internal_read_io_32_bits(unsigned long addr, unsigned long byte_offset);
	void internal_write_io_32_bits(unsigned long addr, unsigned long byte_offset, unsigned long data);
	bool use_activity_indication;
	unsigned long spi_transceive32(unsigned long val);

public:
	unsigned long spi_transfer_byte(unsigned long val);

	void init_base_addr_and_clock_rate(unsigned long the_base_address,
			unsigned long the_base_clock_rate) {
		set_baseaddress(the_base_address);
		set_base_clock_rate(the_base_clock_rate);
		use_activity_indication = false;
		use_sdio_helper = false;
		sdio_helper_encapsulator = NULL;
		activity_indicator_encapsulator = NULL;
	}

	;

	opencores_spi_driver()  : semaphore_locking_class() {
		use_activity_indication = false;
		use_sdio_helper = false;
		sdio_helper_encapsulator = NULL;
		activity_indicator_encapsulator = NULL;

	}

	;

	opencores_spi_driver(unsigned long the_base_address,
			unsigned long the_base_clock_rate, abstract_io_read_write_class*  the_io_rw_interface_ptr = NULL)  : semaphore_locking_class() {
		init_base_addr_and_clock_rate(the_base_address, the_base_clock_rate);
		io_rw_interface_ptr = the_io_rw_interface_ptr;
		use_activity_indication = false;
		use_sdio_helper = false;
		sdio_helper_encapsulator = NULL;
		activity_indicator_encapsulator = NULL;
	}

	opencores_spi_driver(unsigned long the_base_address,
			             unsigned long the_base_clock_rate,
			             uart_register_file* uart_ptr,
			             unsigned long secondary_uart_num,
			             unsigned long sdio_helper_offset,
			             unsigned long CTRL_SETTINGS,
			             unsigned baudrate,
			             bool use_sdio_helper,
			             OS_EVENT* theSemaphorePointer,
			             std::string description,
			             bool use_activity_indication,
			             unsigned long activity_indicator_offset,
			             unsigned long debug_tag_word_offset,
			             unsigned long aux_out_offset,
			             unsigned long aux_in_offset
			             )  : semaphore_locking_class() {
		  init_base_addr_and_clock_rate(the_base_address, the_base_clock_rate);
		  this->set_io_rw_interface_ptr(new uart_based_io_read_write_class(uart_ptr,secondary_uart_num));
		  this->set_use_sdio_helper(use_sdio_helper);
		  if (use_sdio_helper) {
			  this->set_sdio_helper_encapsulator(new uart_based_pio_encapsulator(sdio_helper_offset,uart_ptr,secondary_uart_num));
		  } else {
			  this->set_sdio_helper_encapsulator(NULL);
		  }
		  this->spi_open(CTRL_SETTINGS,baudrate);
		  this->set_the_semaphore_pointer(theSemaphorePointer);
		  this->set_description(description);
		  this->use_activity_indication = use_activity_indication;
		  if (use_activity_indication) {
		 			  this->set_activity_indicator_encapsulator(new uart_based_pio_encapsulator(activity_indicator_offset,uart_ptr,secondary_uart_num));
		 		  } else {
		 			  this->set_activity_indicator_encapsulator(NULL);
		 		  }

		  this->set_debug_tag_word_encapsulator(new uart_based_pio_encapsulator(debug_tag_word_offset,uart_ptr,secondary_uart_num));
		  this->set_aux_out_encapsulator(new uart_based_pio_encapsulator(aux_out_offset,uart_ptr,secondary_uart_num));
		  this->set_aux_in_encapsulator(new uart_based_pio_encapsulator(aux_in_offset,uart_ptr,secondary_uart_num));

	}

	opencores_spi_driver(    uart_register_file* uart_ptr,
				             unsigned long secondary_uart_num,
				             unsigned long CTRL_SETTINGS,
				             unsigned baudrate,
				             OS_EVENT* theSemaphorePointer,
				             std::string description,
				             unsigned long the_base_clock_rate = OPENCORES_SPI_DEFAULT_CLOCK_RATE_HZ,
				             bool use_sdio_helper = true
			             ) :
				        opencores_spi_driver(OPENCORES_SPI_DEFAULT_BASE_ADDRESS_OFFSET,
				        				     the_base_clock_rate,
				        				     uart_ptr,
				        				     secondary_uart_num,
				        				     OPENCORES_SPI_DEFAULT_SDIO_HELPER_OFFSET,
				        				     CTRL_SETTINGS,
				        				     baudrate,
				        				     use_sdio_helper,
				        				     theSemaphorePointer,
				        				     description,
				        				     true,
				        		             OPENCORES_SPI_DEFAULT_ACTIVITY_INDICATOR_OFFSET ,
				        				     OPENCORES_SPI_DEFAULT_DEBUG_TAG_WORD_OFFSET,
				        				     OPENCORES_SPI_DEFAULT_DEBUG_AUX_OUT_OFFSET,
				        				     OPENCORES_SPI_DEFAULT_DEBUG_AUX_IN_OFFSET
				        				     ) {};


	void set_sdio_helper_encapsulator (altera_pio_encapsulator* sdio_helper_encapsulator) {
        this->sdio_helper_encapsulator = sdio_helper_encapsulator;
	}

	altera_pio_encapsulator* get_sdio_helper_encapsulator () {
		return sdio_helper_encapsulator;
	}

	void set_activity_indicator_encapsulator (altera_pio_encapsulator* activity_indicator_encapsulator) {
	        this->activity_indicator_encapsulator = activity_indicator_encapsulator;
	}

	altera_pio_encapsulator* get_activity_indicator_encapsulator () {
			return activity_indicator_encapsulator;
	}

	void set_debug_tag_word_encapsulator (altera_pio_encapsulator* debug_tag_word_encapsulator) {
		        this->debug_tag_word_encapsulator = debug_tag_word_encapsulator;
		}

		altera_pio_encapsulator* get_debug_tag_word_encapsulator () {
				return debug_tag_word_encapsulator;
		}


		void set_aux_out_encapsulator (altera_pio_encapsulator* x) {
			        this->aux_out_encapsulator = x;
			}

			altera_pio_encapsulator* get_aux_out_encapsulator () {
					return aux_out_encapsulator;
			}

			void set_aux_in_encapsulator (altera_pio_encapsulator* x) {
					        this->aux_in_encapsulator = x;
					}

					altera_pio_encapsulator* get_aux_in_encapsulator () {
							return aux_in_encapsulator;
					}
	void set_io_rw_interface_ptr(abstract_io_read_write_class* io_rw_interface_ptr) {
			this->io_rw_interface_ptr = io_rw_interface_ptr;
	}

	abstract_io_read_write_class* get_io_rw_interface_ptr() {
		return io_rw_interface_ptr;
	}

	void spi_open( unsigned long CTRL_SETTINGS, unsigned baudrate);
	void spi_set_baudrate(unsigned long baudrate);
	unsigned long spi_get_baudrate();
	void spi_set_endianess(bool endianess);

	unsigned long bedrock_SPI_TransferData( unsigned long cs_word, char txSize, char* txBuf, char rxSize,
			char* rxBuf,  bool sdio_en_control = 0, int byte_to_switch_in = 100);

	unsigned long SPI_TransferData( unsigned long cs_word, char txSize, char* txBuf, char rxSize,
			char* rxBuf,  bool sdio_en_control = 0, int byte_to_switch_in = 100);


	unsigned long get_sdio_helper_base_address() const {
		return sdio_helper_encapsulator->get_base_address();
	}

	void set_sdio_helper_base_address(unsigned long sdioHelperBaseAddress) {
		sdio_helper_encapsulator->set_base_address(sdioHelperBaseAddress);
	}

	bool isuse_sdio_helper() const {
		return use_sdio_helper;
	}

	void set_use_sdio_helper(bool useSdioHelper) {
		use_sdio_helper = useSdioHelper;
	}

	void set_base_clock_rate(unsigned long baseClockRate) {
		base_clock_rate = baseClockRate;
	}

	void set_baseaddress(unsigned long baseaddress) {
		this->baseaddress = baseaddress;
	}

	void set_cs_word(unsigned cs_word);
	unsigned long get_cs_word();

	std::string get_description() const {
		return description;
	}

	void set_description(std::string description) {
		this->description = description;
	}

	virtual std::string get_semaphore_description() {
		return std::string("(").append(get_description()).append(std::string(" Semaphore)"));
 	}
};

#endif // _SPI_H
