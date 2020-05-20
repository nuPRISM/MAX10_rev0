
#ifndef __AD9680_DRIVER__H__
#define __AD9680_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include "opencores_spi_driver.h"
/******************************************************************************/
/*********************************** ad9680 ***********************************/
/******************************************************************************/
#define ad9680_SPI_CORE_BAUDRATE      5000
#define ad9680_SPI_CORE_CTRL_SETTINGS 0x0408 // char_len = 8 go_bsy = 0 ass = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1
#define ad9680_HIGHEST_REG_ADDR       0x2000
#define ad9680_CHIP_ID_REG_ADDR       (0x004)
#define ad9680_CHIP_ID                (0xC5)
#define DEBUG_ad9680_DEVICE_DRIVER (0)
/* Registers */

#define ad9680_READ                         (1 << 15)
#define ad9680_WRITE                        (0 << 15)
#define ad9680_CNT(x)                       ((((x) & 0x3) - 1) << 13)
#define ad9680_ADDR(x)                      ((x) & 0xFF)

class ad9680_driver  {
protected:
     unsigned long chipselect_index;
	opencores_spi_driver* spi_driver;
	
public:
	ad9680_driver(unsigned long current_chipselect_index = 0) {
	 this->set_chipselect_index(current_chipselect_index);
	};
	int32_t ad9680_setup();
	int32_t ad9680_read(int32_t registerAddress);
	int32_t ad9680_write(int32_t registerAddress, int32_t registerValue);
	int32_t ad9680_transfer(void);


	int32_t ad9680_setup(std::map<unsigned long,unsigned long> register_address_value_pairs);
	int32_t ad9680_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);
	int32_t ad9680_soft_reset();
	bool chip_is_responding();

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

#endif /* __ad9680_H__ */
