
#ifndef __FMC176_AD9250_DRIVER__H__
#define __FMC176_AD9250_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include "opencores_spi_driver.h"
/******************************************************************************/
/*********************************** fmc176_ad9250 ***********************************/
/******************************************************************************/
#define AD9250_REG_CHIP_PORT_CONF				    0x00
#define AD9250_REG_CHIP_ID				     	    0x01
#define AD9250_REG_POWER_MODE					    0x08
#define AD9250_REG_PLL_STATUS					    0x0A
#define AD9250_REG_TEST_CNTRL					    0x0D
#define AD9250_REG_OUTPUT_MODE					    0x14
#define AD9250_REG_OUTPUT_ADJUST				    0x15
#define AD9250_REG_SYSREF_CONTROL				    0x3A
#define AD9250_REG_JESD204B_QUICK_CONFIG			0x5E
#define AD9250_REG_JESD204B_LINK_CNTRL_1			0x5F
#define AD9250_REG_204B_DID_CONFIG   				0x64
#define AD9250_REG_204B_BID_CONFIG   				0x65
#define AD9250_REG_204B_LID_CONFIG_0				0x66
#define AD9250_REG_204B_LID_CONFIG_1				0x67
#define AD9250_REG_204B_PARAM_SCRAMBLE_LANES		0x6E
#define AD9250_REG_204B_PARAM_K					    0x70
#define AD9250_REG_JESD204B_CONFIGURATION			0x72
#define AD9250_REG_JESD204B_SUBCLASS_NP 			0x73

#define AD9250_REG_JESD204B_LANE_POWER_MODE			0x80
#define AD9250_REG_TRANSFER					        0xFF

#define AD9250_CHIP_ID						        0xB9

#define AD9250_TEST_OFF						        0x00
#define AD9250_TEST_MID_SCALE					    0x01
#define AD9250_TEST_POS_FSCALE					    0x02
#define AD9250_TEST_NEG_FSCALE					    0x03
#define AD9250_TEST_CHECKBOARD					    0x04
#define AD9250_TEST_PNLONG					        0x05
#define AD9250_TEST_ONE2ZERO					    0x07
#define AD9250_TEST_PATTERN					        0x08
#define AD9250_TEST_RAMP					        0x0F


#define fmc176_ad9250_SPI_CORE_BAUDRATE             5000
#define fmc176_ad9250_SPI_CORE_CTRL_SETTINGS        0x0408 // char_len = 8 go_bsy = 0 ass = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1
#define fmc176_ad9250_HIGHEST_REG_ADDR              0x2000
#define FMC176_AD9250_ADDRESS_PREFIX                (0x80)
#ifndef DEBUG_fmc176_ad9250_DEVICE_DRIVER
#define DEBUG_fmc176_ad9250_DEVICE_DRIVER           (0)
#endif

/* Registers */

#define fmc176_ad9250_READ                         (1 << 15)
#define fmc176_ad9250_WRITE                        (0 << 15)

class fmc176_ad9250_driver  {
protected:
	opencores_spi_driver* spi_driver;
	uint8_t id_no;
	uint32_t subclass;
public:
	fmc176_ad9250_driver(uint8_t current_id_no = 0, uint32_t subclass = 0) {
		 this->set_id_no(current_id_no);
		 this->set_subclass(subclass);
	};
	int32_t fmc176_ad9250_setup();
	int32_t fmc176_ad9250_read(int32_t registerAddress);
	int32_t fmc176_ad9250_write(int32_t registerAddress, int32_t registerValue);
	int32_t fmc176_ad9250_transfer(void);


	int32_t fmc176_ad9250_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);
	int32_t fmc176_ad9250_soft_reset();
	bool chip_is_responding();
	void fmc176_ad9250_init(int enable_test_signal);


	void set_cs_active();
	void set_cs_inactive();

	opencores_spi_driver* get_spi_driver() const {
		return spi_driver;
	}

	void set_spi_driver(opencores_spi_driver* spiDriver) {
		spi_driver = spiDriver;
	}

	uint8_t get_id_no() const {
		return id_no;
	}

	void set_id_no(uint8_t id_no) {
		this->id_no = id_no;
	}

	uint32_t get_subclass() const {
		return subclass;
	}

	void set_subclass(uint32_t subclass) {
		this->subclass = subclass;
	}
};

#endif /* __fmc176_ad9250_H__ */
