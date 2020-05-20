
#ifndef __AD9523_DRIVER__H__
#define __AD9523_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include "debug_macro_definitions.h"
#include "opencores_spi_driver.h"
#include "ad9523.h"
/******************************************************************************/
/*********************************** ad9523 ***********************************/
/******************************************************************************/
#define ad9523_SPI_CORE_BAUDRATE      6250000
#define ad9523_SPI_CORE_CTRL_SETTINGS 0x0408 // char_len = 8 go_bsy = 0 ass = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1
#define ad9523_HIGHEST_REG_ADDR       0x2000

#ifndef DEBUG_ad9523_DEVICE_DRIVER
#define DEBUG_ad9523_DEVICE_DRIVER (0)
#endif

/* Registers */

#define ad9523_READ                         (1 << 15)
#define ad9523_WRITE                        (0 << 15)
#define ad9523_CNT(x)                       ((((x) & 0x3) - 1) << 13)
#define ad9523_ADDR(x)                      ((x) & 0xFF)
typedef enum {
	ADC_1000MSPS_DAC_1000MSPS = 1,
	ADC_500MSPS_DAC_1000MSPS = 2,
	ADC_500MSPS_DAC_500MSPS = 3,
	ADC_600MSPS_DAC_600MSPS = 4,
	ADC_1000MSPS_DAC_2000MSPS = 5,
	ADC_750MSPS_DAC_1000MSPS = 6
} FMCDAQ2_AD9523_CONFIGURATION_ENUM_TYPE;

class ad9523_driver  {
protected:
     unsigned long chipselect_index;
	opencores_spi_driver* spi_driver;
	struct ad9523_dev *dev;
	struct ad9523_channel_spec	ad9523_channels[8];
	struct ad9523_platform_data	ad9523_pdata;
	struct ad9523_init_param	ad9523_param;

	int32_t ad9523_original_driver_spi_read(uint32_t reg_addr);
	int32_t ad9523_original_driver_spi_write(uint32_t reg_addr, uint32_t reg_data);
	void    fmcdaq2_default_parameters_init();


public:
	ad9523_driver(unsigned long current_chipselect_index = 0) {
        this->set_chipselect_index(current_chipselect_index);
	};
	void    fmcdaq2_set_configuration(FMCDAQ2_AD9523_CONFIGURATION_ENUM_TYPE the_config);

	int32_t ad9523_setup();
	int32_t ad9523_read(int32_t registerAddress);
	int32_t ad9523_write(int32_t registerAddress, int32_t registerValue);
	int32_t ad9523_transfer(void);


	int32_t ad9523_io_update();

	/* Sets the clock provider for selected channel. */
	int32_t ad9523_vco_out_map(uint32_t ch, uint32_t out);

	/* Updates the AD9523 configuration. */
	int32_t ad9523_sync();

	/* Initialize the AD9523 data structure*/
	int32_t ad9523_init_params(struct ad9523_init_param *init_param);

	/* Configure the AD9523. */
	int32_t ad9523_setup(const struct ad9523_init_param *init_param);
	int32_t ad9523_status();
	int32_t ad9523_calibrate();
	int32_t ad9523_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);
	int32_t ad9523_soft_reset();
	void ad9523_init();

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

#endif /* __ad9523_H__ */
