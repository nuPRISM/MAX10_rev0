
#ifndef __SCA_DRIVER__H__
#define __SCA_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include <map>
#include <vector>
#include "opencores_spi_driver.h"
/******************************************************************************/
/*********************************** sca ***********************************/
/******************************************************************************/
#define sca_SPI_CORE_BAUDRATE      (1000000)
#define sca_SPI_CORE_CTRL_SETTINGS 0x0208 // char_len = 8 go_bsy = 0 ass = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1
#define sca_HIGHEST_REG_ADDR       0x6
#define SCA_MAX_SPI_TRANSACTION_BYTES       0x10

#define DEBUG_sca_DEVICE_DRIVER (1)
/* Registers */

#define sca_READ                         (1 << 7)
#define sca_WRITE                        (0 << 7)
#define sca_CNT(x)                       ((((x) & 0x3) - 1) << 13)
#define sca_ADDR(x)                      ((x) & 0xFF)

class sca_register_control_params {	      
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


class sca_driver  {
protected:
	unsigned long chipselect_index;
    std::vector<sca_register_control_params> sca_reg_param;
	opencores_spi_driver* spi_driver;
	
public:
	sca_driver(unsigned long current_chipselect_index = 0) : sca_reg_param(sca_HIGHEST_REG_ADDR) {
	 this->set_chipselect_index(current_chipselect_index);
	 sca_reg_param.at(0).set_num_bytes_to_write (4);
	 sca_reg_param.at(0).set_byte_to_lower_en_at(4);
	 sca_reg_param.at(0).set_byte_to_lower_en_at_read(4);
	 sca_reg_param.at(0).set_bit_to_lower_en_at      (8);
	 sca_reg_param.at(0).set_bit_to_lower_en_at_read (8);
	 sca_reg_param.at(0).set_bit_to_shift_write_on_write(8);
	 sca_reg_param.at(0).set_value_msb(22);
	 sca_reg_param.at(0).set_value_lsb(7);

	 sca_reg_param.at(1).set_num_bytes_to_write  (4);
	 sca_reg_param.at(1).set_byte_to_lower_en_at (4);
	 sca_reg_param.at(1).set_byte_to_lower_en_at_read(4);
	 sca_reg_param.at(1).set_bit_to_lower_en_at (8);
	 sca_reg_param.at(1).set_bit_to_lower_en_at_read(8);
	 sca_reg_param.at(1).set_bit_to_shift_write_on_write(8);
	 sca_reg_param.at(1).set_value_msb(22);
	 sca_reg_param.at(1).set_value_lsb(7);
	 
	 sca_reg_param.at(2).set_num_bytes_to_write (4);
	 sca_reg_param.at(2).set_byte_to_lower_en_at(4);
	 sca_reg_param.at(2).set_byte_to_lower_en_at_read(4);
	 sca_reg_param.at(2).set_bit_to_lower_en_at (8);
	 sca_reg_param.at(2).set_bit_to_lower_en_at_read (8);
	 sca_reg_param.at(2).set_bit_to_shift_write_on_write(8);
	 sca_reg_param.at(2).set_value_msb(22);
	 sca_reg_param.at(2).set_value_lsb(7);
	 
	 sca_reg_param.at(3).set_num_bytes_to_write (6);
	 sca_reg_param.at(3).set_byte_to_lower_en_at(6);
	 sca_reg_param.at(3).set_bit_to_lower_en_at (2);
	 sca_reg_param.at(3).set_byte_to_lower_en_at_read(6);
	 sca_reg_param.at(3).set_bit_to_lower_en_at_read (2);
	 sca_reg_param.at(3).set_bit_to_shift_write_on_write(2);
	 sca_reg_param.at(3).set_value_msb(38);
	 sca_reg_param.at(3).set_value_lsb(1);

	 sca_reg_param.at(4).set_num_bytes_to_write  (6);
	 sca_reg_param.at(4).set_byte_to_lower_en_at (6);
	 sca_reg_param.at(4).set_bit_to_lower_en_at  (2);
	 sca_reg_param.at(4).set_byte_to_lower_en_at_read (6);
	 sca_reg_param.at(4).set_bit_to_lower_en_at_read  (2);
	 sca_reg_param.at(4).set_bit_to_shift_write_on_write(2);
	 sca_reg_param.at(4).set_value_msb(38);
	 sca_reg_param.at(4).set_value_lsb(1);
	};


	int32_t sca_setup();
	uint64_t sca_read(uint32_t registerAddress);
	uint32_t sca_write(uint32_t registerAddress, uint64_t registerValue);
	int32_t sca_transfer(void);


	int32_t sca_setup(std::map<unsigned long,unsigned long> register_address_value_pairs);
	int32_t sca_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);
	int32_t sca_soft_reset();


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

#endif /* __sca_H__ */
