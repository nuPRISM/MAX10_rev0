
#ifndef __AD9249_DRIVER__H__
#define __AD9249_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include "opencores_spi_driver.h"
/******************************************************************************/
/*********************************** ad9249 ***********************************/
/******************************************************************************/
#define ad9249_SPI_CORE_BAUDRATE      (1000000)
#define ad9249_SPI_CORE_CTRL_SETTINGS 0x0408 // char_len = 8 go_bsy = 0 ass = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1
#define ad9249_HIGHEST_REG_ADDR       0x2000

#define DEBUG_ad9249_DEVICE_DRIVER (0)
/* Registers */

#define ad9249_READ                         (1 << 15)
#define ad9249_WRITE                        (0 << 15)
#define ad9249_CNT(x)                       ((((x) & 0x3) - 1) << 13)
#define ad9249_ADDR(x)                      ((x) & 0xFF)

class ad9249_driver  {
protected:
	unsigned long chipselect_index;

	opencores_spi_driver* spi_driver;
	
public:
	ad9249_driver(unsigned long current_chipselect_index = 0) {
	 this->set_chipselect_index(current_chipselect_index);
	};
	int32_t ad9249_setup();
	int32_t ad9249_read(int32_t registerAddress);
	int32_t ad9249_write(int32_t registerAddress, int32_t registerValue);
	int32_t ad9249_transfer(void);


	int32_t ad9249_setup(std::map<unsigned long,unsigned long> register_address_value_pairs);
	int32_t ad9249_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);
	int32_t ad9249_soft_reset();


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

#endif /* __ad9249_H__ */
