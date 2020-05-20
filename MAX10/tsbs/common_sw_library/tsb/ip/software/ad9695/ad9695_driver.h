
#ifndef __AD9695_DRIVER__H__
#define __AD9695_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include "debug_macro_definitions.h"
#include "opencores_spi_driver.h"
/******************************************************************************/
/*********************************** ad9695 ***********************************/
/******************************************************************************/
#define ad9695_SPI_CORE_BAUDRATE      6250000
#define ad9695_SPI_CORE_CTRL_SETTINGS 0x0408 // char_len = 8 go_bsy = 0 ass = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1
#define ad9695_HIGHEST_REG_ADDR       0x2000

#ifndef DEBUG_ad9695_DEVICE_DRIVER
#define DEBUG_ad9695_DEVICE_DRIVER (0)
#endif

/* Registers */

#define ad9695_READ                         (1 << 15)
#define ad9695_WRITE                        (0 << 15)
#define ad9695_CNT(x)                       ((((x) & 0x3) - 1) << 13)
#define ad9695_ADDR(x)                      ((x) & 0xFF)

class ad9695_driver  {
protected:
	opencores_spi_driver* spi_driver;
	
public:
	ad9695_driver() {
	};
	int32_t ad9695_setup();
	int32_t ad9695_read(int32_t registerAddress);
	int32_t ad9695_write(int32_t registerAddress, int32_t registerValue);
	int32_t ad9695_transfer(void);


	int32_t ad9695_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);
	int32_t ad9695_soft_reset();
	void ad9695_init();

	void set_cs_active();
	void set_cs_inactive();

	opencores_spi_driver* get_spi_driver() const {
		return spi_driver;
	}

	void set_spi_driver(opencores_spi_driver* spiDriver) {
		spi_driver = spiDriver;
	}

	
};

#endif /* __ad9695_H__ */
