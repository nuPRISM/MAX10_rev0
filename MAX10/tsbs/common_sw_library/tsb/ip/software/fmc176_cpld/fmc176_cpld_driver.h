
#ifndef __FMC176_CPLD_DRIVER__H__
#define __FMC176_CPLD_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include "debug_macro_definitions.h"
#include "opencores_spi_driver.h"
/******************************************************************************/
/*********************************** fmc176_cpld ***********************************/
/******************************************************************************/
#define FMC176_CPLD_TIME_TO_WAIT_BETWEEN_SETUP_US (50000)

#define fmc176_cpld_SPI_CORE_BAUDRATE             5000
#define fmc176_cpld_SPI_CORE_CTRL_SETTINGS        0x0408 // char_len = 8 go_bsy = 0 ass = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1
#define fmc176_cpld_HIGHEST_REG_ADDR              0x2000
#define FMC176_CPLD_ADDRESS_PREFIX                (0x00)
#ifndef DEBUG_fmc176_cpld_DEVICE_DRIVER
#define DEBUG_fmc176_cpld_DEVICE_DRIVER           (0)
#endif

/* Registers */

#define fmc176_cpld_READ                         (1 << 7)
#define fmc176_cpld_WRITE                        (0 << 7)

class fmc176_cpld_driver  {
protected:
	opencores_spi_driver* spi_driver;

public:
	fmc176_cpld_driver() {};
	int32_t fmc176_cpld_setup();
	int32_t fmc176_cpld_read(int32_t registerAddress);
	int32_t fmc176_cpld_write(int32_t registerAddress, int32_t registerValue);
	int32_t fmc176_cpld_transfer(void);


	int32_t fmc176_cpld_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);
	int32_t fmc176_cpld_soft_reset();


	void set_cs_active();
	void set_cs_inactive();

	opencores_spi_driver* get_spi_driver() const {
		return spi_driver;
	}

	void set_spi_driver(opencores_spi_driver* spiDriver) {
		spi_driver = spiDriver;
	}

};

#endif /* __fmc176_cpld_H__ */
