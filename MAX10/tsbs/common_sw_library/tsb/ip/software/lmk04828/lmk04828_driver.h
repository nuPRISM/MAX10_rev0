
#ifndef __lmk04828_DRIVER__H__
#define __lmk04828_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include "opencores_spi_driver.h"
#include <utility>
#include <map>
#include <vector>

/******************************************************************************/
/*********************************** lmk04828 ***********************************/
/******************************************************************************/
#define lmk04828_SPI_CORE_BAUDRATE      5000
#define lmk04828_SPI_CORE_CTRL_SETTINGS 0x0408 // char_len = 8 go_bsy = 0 ass = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1
#define lmk04828_HIGHEST_REG_ADDR       0x2000

#define DEBUG_lmk04828_DEVICE_DRIVER (0)
/* Registers */

#define lmk04828_READ                         (1 << 15)
#define lmk04828_WRITE                        (0 << 15)
#define lmk04828_CNT(x)                       ((((x) & 0x3) - 1) << 13)
#define lmk04828_ADDR(x)                      ((x) & 0xFF)


class lmk04828_driver  {
protected:
	opencores_spi_driver* spi_driver;
	
public:
	lmk04828_driver() {
	};
//	int32_t lmk04828_setup();
	int32_t lmk04828_setup(std::map<unsigned long,unsigned long> register_address_value_pairs);
	int32_t lmk04828_driver::lmk04828_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);
	int32_t lmk04828_read(int32_t registerAddress);
	int32_t lmk04828_write(int32_t registerAddress, int32_t registerValue);
	int32_t lmk04828_transfer(void);
	int32_t lmk04828_soft_reset(void);
	void set_cs_active();
	void set_cs_inactive();

	opencores_spi_driver* get_spi_driver() const {
		return spi_driver;
	}

	void set_spi_driver(opencores_spi_driver* spiDriver) {
		spi_driver = spiDriver;
	}

	
};

#endif /* __lmk04828_H__ */
