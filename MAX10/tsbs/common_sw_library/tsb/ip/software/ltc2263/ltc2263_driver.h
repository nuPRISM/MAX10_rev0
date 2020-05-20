
#ifndef __LTC2263_DRIVER__H__
#define __LTC2263_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include "opencores_spi_driver.h"
/******************************************************************************/
/*********************************** ltc2263 ***********************************/
/******************************************************************************/
#define ltc2263_SPI_CORE_BAUDRATE      (1000000)
#define ltc2263_SPI_CORE_CTRL_SETTINGS 0x0408 // char_len = 8 go_bsy = 0 ass = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1
#define ltc2263_HIGHEST_REG_ADDR       0x2000

#define DEBUG_ltc2263_DEVICE_DRIVER (1)
/* Registers */

#define ltc2263_READ                         (1 << 7)
#define ltc2263_WRITE                        (0 << 7)
#define ltc2263_CNT(x)                       ((((x) & 0x3) - 1) << 13)
#define ltc2263_ADDR(x)                      ((x) & 0xFF)

class ltc2263_driver  {
protected:
	unsigned long chipselect_index;

	opencores_spi_driver* spi_driver;
	
public:
	ltc2263_driver(unsigned long current_chipselect_index = 0) {
	 this->set_chipselect_index(current_chipselect_index);
	};
	int32_t ltc2263_setup();
	int32_t ltc2263_read(int32_t registerAddress);
	int32_t ltc2263_write(int32_t registerAddress, int32_t registerValue);
	int32_t ltc2263_transfer(void);


	int32_t ltc2263_setup(std::map<unsigned long,unsigned long> register_address_value_pairs);
	int32_t ltc2263_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);
	int32_t ltc2263_soft_reset();


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

#endif /* __ltc2263_H__ */
