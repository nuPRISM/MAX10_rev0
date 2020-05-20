
#ifndef __LTC2260_DRIVER__H__
#define __LTC2260_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include "opencores_spi_driver.h"
/******************************************************************************/
/*********************************** ltc2260 ***********************************/
/******************************************************************************/
#define ltc2260_SPI_CORE_BAUDRATE      (1000000)
#define ltc2260_SPI_CORE_CTRL_SETTINGS 0x0408 // char_len = 8 go_bsy = 0 ass = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1
#define ltc2260_HIGHEST_REG_ADDR       0x2000

#define DEBUG_ltc2260_DEVICE_DRIVER (1)
/* Registers */

#define ltc2260_READ                         (1 << 7)
#define ltc2260_WRITE                        (0 << 7)
#define ltc2260_CNT(x)                       ((((x) & 0x3) - 1) << 13)
#define ltc2260_ADDR(x)                      ((x) & 0xFF)

class ltc2260_driver  {
protected:
	unsigned long chipselect_index;

	opencores_spi_driver* spi_driver;
	
public:
	ltc2260_driver(unsigned long current_chipselect_index = 0) {
	 this->set_chipselect_index(current_chipselect_index);
	};
	int32_t ltc2260_setup();
	int32_t ltc2260_read(int32_t registerAddress);
	int32_t ltc2260_write(int32_t registerAddress, int32_t registerValue);
	int32_t ltc2260_transfer(void);


	int32_t ltc2260_setup(std::map<unsigned long,unsigned long> register_address_value_pairs);
	int32_t ltc2260_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);
	int32_t ltc2260_soft_reset();


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

#endif /* __ltc2260_H__ */
