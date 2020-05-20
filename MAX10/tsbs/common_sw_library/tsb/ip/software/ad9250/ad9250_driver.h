
#ifndef __AD9250_DRIVER__H__
#define __AD9250_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include "opencores_spi_driver.h"
/******************************************************************************/
/*********************************** ad9250 ***********************************/
/******************************************************************************/
#define ad9250_SPI_CORE_BAUDRATE      5000
#define ad9250_SPI_CORE_CTRL_SETTINGS 0x0408 // char_len = 8 go_bsy = 0 ass = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1
#define ad9250_HIGHEST_REG_ADDR       0x2000

#ifndef DEBUG_ad9250_DEVICE_DRIVER
#define DEBUG_ad9250_DEVICE_DRIVER (0)
#endif

/* Registers */

#define ad9250_READ                         (1 << 15)
#define ad9250_WRITE                        (0 << 15)
#define ad9250_CNT(x)                       ((((x) & 0x3) - 1) << 13)
#define ad9250_ADDR(x)                      ((x) & 0xFF)

class ad9250_driver  {
protected:
	opencores_spi_driver* spi_driver;
	
public:
	ad9250_driver() {
	};
	int32_t ad9250_setup();
	int32_t ad9250_read(int32_t registerAddress);
	int32_t ad9250_write(int32_t registerAddress, int32_t registerValue);
	int32_t ad9250_transfer(void);


	int32_t ad9250_setup(std::map<unsigned long,unsigned long> register_address_value_pairs);
	int32_t ad9250_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);
	int32_t ad9250_soft_reset();


	void set_cs_active();
	void set_cs_inactive();

	opencores_spi_driver* get_spi_driver() const {
		return spi_driver;
	}

	void set_spi_driver(opencores_spi_driver* spiDriver) {
		spi_driver = spiDriver;
	}

	
};

#endif /* __ad9250_H__ */
