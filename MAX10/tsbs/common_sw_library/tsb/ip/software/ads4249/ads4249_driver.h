
#ifndef __ADS4249_DRIVER__H__
#define __ADS4249_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include <map>
#include <vector>
#include "opencores_spi_driver.h"
#include "debug_macro_definitions.h"
/******************************************************************************/
/*********************************** ads4249 ***********************************/
/******************************************************************************/
#define ads4249_SPI_CORE_BAUDRATE      (100000)
#define ads4249_SPI_CORE_CTRL_SETTINGS 0x0208 // char_len = 8 go_bsy = 0 ass = 0 tx_nex = 0 rx_neg = 1 lsb = 0 ass = 0
#define ads4249_HIGHEST_REG_ADDR       0x100
#define ADS4249_MAX_SPI_TRANSACTION_BYTES       0x10

#define ADS4249_CONV_AUX_OUT_BIT_NUM (0)
#define ADS4249_BUSY_AUX_IN_BIT_NUM  (0)

#ifndef DEBUG_ads4249_DEVICE_DRIVER
#define DEBUG_ads4249_DEVICE_DRIVER  (0)
#endif
/* Registers */


class ads4249_driver  {
protected:
	unsigned long chipselect_index;
	opencores_spi_driver* spi_driver;
	int is_busy();
	uint32_t enable_readout();
	uint32_t disable_readout();
public:
	ads4249_driver(unsigned long current_chipselect_index = 0) {
	 this->set_chipselect_index(current_chipselect_index);
	
	};


	int32_t ads4249_setup();
	uint64_t ads4249_read(uint32_t registerAddress);
	uint32_t ads4249_write(uint32_t registerAddress, uint64_t registerValue);
	int32_t ads4249_transfer(void);


	int32_t ads4249_setup(std::map<unsigned long,unsigned long> register_address_value_pairs);
	int32_t ads4249_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);
	int32_t ads4249_soft_reset();


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

#endif /* __ads4249_H__ */
