
#ifndef __LTC6954_DRIVER__H__
#define __LTC6954_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include "opencores_spi_driver.h"
/******************************************************************************/
/*********************************** ltc6954 ***********************************/
/******************************************************************************/
#define ltc6954_SPI_CORE_BAUDRATE      (1000000)
#define ltc6954_SPI_CORE_CTRL_SETTINGS 0x0408 // char_len = 8 go_bsy = 0 ass = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1
#define ltc6954_HIGHEST_REG_ADDR       0x2000

#define DEBUG_ltc6954_DEVICE_DRIVER (1)
/* Registers */

#define ltc6954_READ                         (1)
#define ltc6954_WRITE                        (0)
#define ltc6954_CNT(x)                       ((((x) & 0x3) - 1) << 13)
#define ltc6954_ADDR(x)                      ((x) & 0xFF)

class ltc6954_driver  {
protected:
	unsigned long chipselect_index;
	unsigned long id_no;
	opencores_spi_driver* spi_driver;
	
public:
	ltc6954_driver(unsigned long current_chipselect_index, unsigned long id_no)  {
	 this->set_chipselect_index(current_chipselect_index);
	 this->set_id_no(id_no);
	};
	int32_t ltc6954_setup();
	int32_t ltc6954_read(int32_t registerAddress);
	int32_t ltc6954_write(int32_t registerAddress, int32_t registerValue);
	int32_t ltc6954_transfer(void);


	int32_t ltc6954_setup(std::map<unsigned long,unsigned long> register_address_value_pairs);
	int32_t ltc6954_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);
	int32_t ltc6954_soft_reset();
    void   ltc6954_init(unsigned long start_in_test_mode);

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

	unsigned long get_id_no() const {
		return id_no;
	}

	void set_id_no(unsigned long id_no) {
		this->id_no = id_no;
	}

};

#endif /* __ltc6954_H__ */
