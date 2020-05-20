
#ifndef __LTM2893_DRIVER__H__
#define __LTM2893_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include <map>
#include <vector>
#include "opencores_spi_driver.h"
/******************************************************************************/
/*********************************** ltm2893 ***********************************/
/******************************************************************************/
#define ltm2893_SPI_CORE_BAUDRATE      (1000000)
#define ltm2893_SPI_CORE_CTRL_SETTINGS 0x0208 // char_len = 8 go_bsy = 0 ass = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1
#define ltm2893_HIGHEST_REG_ADDR       0x6
#define LTM2893_MAX_SPI_TRANSACTION_BYTES       0x10

#define DEBUG_ltm2893_DEVICE_DRIVER (1)
/* Registers */

#define ltm2893_READ                         (1 << 7)
#define ltm2893_WRITE                        (0 << 7)
#define ltm2893_CNT(x)                       ((((x) & 0x3) - 1) << 13)
#define ltm2893_ADDR(x)                      ((x) & 0xFF)

class ltm2893_register_control_params {	      
public:
	     unsigned long num_bytes_to_write;
		 unsigned long byte_to_lower_en_at;
		 unsigned long bit_to_lower_en_at;
		 unsigned long byte_to_lower_en_at_read;
		 unsigned long bit_to_lower_en_at_read;
		 unsigned long bit_to_shift_write_on_write;
		 unsigned long value_msb;
		 unsigned long value_lsb;


unsigned long get_bit_to_lower_en_at() const {
		return bit_to_lower_en_at;
	}

	void set_bit_to_lower_en_at(unsigned long bitToLowerEnAt) {
		bit_to_lower_en_at = bitToLowerEnAt;
	}

	unsigned long get_byte_to_lower_en_at() const {
		return byte_to_lower_en_at;
	}

	void set_byte_to_lower_en_at(unsigned long byteToLowerEnAt) {
		byte_to_lower_en_at = byteToLowerEnAt;
	}

	unsigned long get_num_bytes_to_write() const {
		return num_bytes_to_write;
	}

	void set_num_bytes_to_write(unsigned long numBytesToWrite) {
		num_bytes_to_write = numBytesToWrite;
	}

	unsigned long get_value_lsb() const {
		return value_lsb;
	}

	void set_value_lsb(unsigned long valueLsb) {
		value_lsb = valueLsb;
	}

	unsigned long get_value_msb() const {
		return value_msb;
	}

	void set_value_msb(unsigned long valueMsb) {
		value_msb = valueMsb;
	}

	unsigned long get_bit_to_lower_en_at_read() const {
		return bit_to_lower_en_at_read;
	}

	void set_bit_to_lower_en_at_read(unsigned long bitToLowerEnAtRead) {
		bit_to_lower_en_at_read = bitToLowerEnAtRead;
	}

	unsigned long get_byte_to_lower_en_at_read() const {
		return byte_to_lower_en_at_read;
	}

	void set_byte_to_lower_en_at_read(unsigned long byteToLowerEnAtRead) {
		byte_to_lower_en_at_read = byteToLowerEnAtRead;
	}

	unsigned long get_bit_to_shift_write_on_write() const {
		return bit_to_shift_write_on_write;
	}

	void set_bit_to_shift_write_on_write(unsigned long bitToShiftWriteOnWrite) {
		bit_to_shift_write_on_write = bitToShiftWriteOnWrite;
	}
};


class ltm2893_driver  {
protected:
	unsigned long chipselect_index;
    std::vector<ltm2893_register_control_params> ltm2893_reg_param;
	opencores_spi_driver* spi_driver;
	
public:
	ltm2893_driver(unsigned long current_chipselect_index = 0) : ltm2893_reg_param(ltm2893_HIGHEST_REG_ADDR) {
	 this->set_chipselect_index(current_chipselect_index);
	
	};


	int32_t ltm2893_setup();
	uint64_t ltm2893_read(uint32_t registerAddress);
	uint32_t ltm2893_write(uint32_t registerAddress, uint64_t registerValue);
	int32_t ltm2893_transfer(void);


	int32_t ltm2893_setup(std::map<unsigned long,unsigned long> register_address_value_pairs);
	int32_t ltm2893_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);
	int32_t ltm2893_soft_reset();


	void set_cs_active();
	void set_cs_inactive();

	opencores_spi_driver* get_spi_driver() const {
		return spi_driver;
	}

	void set_spi_driver(opencores_spi_driver* spiDriver) {
		spi_driver = spiDriver;
	}
    
	unsigned long get_chipselect_index() const {
		return chipselect_index;
	}
	
	void set_chipselect_index(unsigned long chipselectIndex) {
		chipselect_index = chipselectIndex;
	}
};

#endif /* __ltm2893_H__ */
