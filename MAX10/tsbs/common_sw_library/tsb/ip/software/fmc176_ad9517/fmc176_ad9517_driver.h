
#ifndef __FMC176_AD9517_DRIVER__H__
#define __FMC176_AD9517_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include "opencores_spi_driver.h"
/******************************************************************************/
/*********************************** fmc176_ad9517 ***********************************/
/******************************************************************************/
#define FMC176_AD9517_TIME_TO_WAIT_BETWEEN_SETUP_US (50000)

#define fmc176_ad9517_SPI_CORE_BAUDRATE             5000
#define fmc176_ad9517_SPI_CORE_CTRL_SETTINGS        0x0408 // char_len = 8 go_bsy = 0 ass = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1
#define fmc176_ad9517_HIGHEST_REG_ADDR              0x2000
#define FMC176_AD9517_ADDRESS_PREFIX                (0x84)
#ifndef DEBUG_fmc176_ad9517_DEVICE_DRIVER
#define DEBUG_fmc176_ad9517_DEVICE_DRIVER           (0)
#endif

/* Registers */

#define fmc176_ad9517_READ                         (1 << 15)
#define fmc176_ad9517_WRITE                        (0 << 15)

class fmc176_ad9517_driver  {
protected:
	opencores_spi_driver* spi_driver;

public:
	fmc176_ad9517_driver() {};
	int32_t fmc176_ad9517_setup();
	int32_t fmc176_ad9517_read(int32_t registerAddress);
	int32_t fmc176_ad9517_write(int32_t registerAddress, int32_t registerValue);
	int32_t fmc176_ad9517_transfer(void);


	int32_t fmc176_ad9517_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);
	int32_t fmc176_ad9517_soft_reset();


	void set_cs_active();
	void set_cs_inactive();

	opencores_spi_driver* get_spi_driver() const {
		return spi_driver;
	}

	void set_spi_driver(opencores_spi_driver* spiDriver) {
		spi_driver = spiDriver;
	}

};

#endif /* __fmc176_ad9517_H__ */
