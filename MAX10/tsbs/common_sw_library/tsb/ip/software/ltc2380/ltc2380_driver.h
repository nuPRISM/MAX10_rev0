
#ifndef __LTC2380_DRIVER__H__
#define __LTC2380_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include <map>
#include <vector>
#include "opencores_spi_driver.h"
/******************************************************************************/
/*********************************** ltc2380 ***********************************/
/******************************************************************************/
#define ltc2380_SPI_CORE_BAUDRATE      (10000000)
#define ltc2380_SPI_CORE_CTRL_SETTINGS 0x0208 // char_len = 8 go_bsy = 0 ass = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1
#define ltc2380_HIGHEST_REG_ADDR       0x1
#define LTC2380_MAX_SPI_TRANSACTION_BYTES       0x10

#define LTC2380_CONV_AUX_OUT_BIT_NUM (0)
#define LTC2380_BUSY_AUX_IN_BIT_NUM  (0)
#define LTC2380_BUSY_WATCHDOG_LIMIT  (1000)
#define DEBUG_ltc2380_DEVICE_DRIVER  (1)
/* Registers */


class ltc2380_driver  {
protected:
	unsigned long chipselect_index;
	opencores_spi_driver* spi_driver;
	int is_busy();
	
public:
	ltc2380_driver(unsigned long current_chipselect_index = 0) {
	 this->set_chipselect_index(current_chipselect_index);
	
	};


	int32_t ltc2380_setup();
	uint64_t ltc2380_read(uint32_t registerAddress);
	uint32_t ltc2380_write(uint32_t registerAddress, uint64_t registerValue);
	int32_t ltc2380_transfer(void);


	int32_t ltc2380_setup(std::map<unsigned long,unsigned long> register_address_value_pairs);
	int32_t ltc2380_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);
	int32_t ltc2380_soft_reset();


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

#endif /* __ltc2380_H__ */
