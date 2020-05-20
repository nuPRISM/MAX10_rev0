
/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include "ltc2380_driver.h"
#include <cstddef>
#include "xprintf.h"
#include "linnux_utils.h"
#include <iostream>
#include "basedef.h"
/******************************************************************************/
/************************ Variables Definitions *******************************/
/******************************************************************************/


/******************************************************************************/
/************************ Functions Definitions *******************************/
/******************************************************************************/

void ltc2380_driver::set_cs_active() {
		 if (spi_driver != NULL) {
			 spi_driver->set_cs_word((1<<(this->get_chipselect_index())));
		    } else {
		    	xprintf("Error: set_cs_active: spi_driver is null! \n");
		    }
	}
void ltc2380_driver::set_cs_inactive() {
		 if (spi_driver != NULL) {
			 spi_driver->set_cs_word(0);
		    } else {
		    	xprintf("Error: set_cs_inactive: spi_driver is null! \n");
		    }
	}


int32_t ltc2380_driver::ltc2380_setup(std::map<unsigned long,unsigned long> register_address_value_pairs) {
	int32_t             ret = 0;
    set_cs_inactive();
	 std::map<unsigned long,unsigned long>::iterator iter;
	 for (iter = register_address_value_pairs.begin(); iter != register_address_value_pairs.end(); iter++) {
		 ltc2380_write(iter->first,iter->second);
	  }
    return ret;

}

int32_t ltc2380_driver::ltc2380_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order) {
	int32_t             ret = 0;
    set_cs_inactive();

	 for (unsigned int i=0; i < register_address_value_pairs_in_order.size(); i++) {
		 ltc2380_write(register_address_value_pairs_in_order.at(i).first,register_address_value_pairs_in_order.at(i).second);
	  }
    return ret;

}

int32_t ltc2380_driver::ltc2380_soft_reset()
{
    int32_t             ret = 0;
    set_cs_inactive();
    return ret;
}

int ltc2380_driver::is_busy()
{
    return (spi_driver->get_aux_in_encapsulator()->read() & (1 << LTC2380_BUSY_AUX_IN_BIT_NUM));
}
/***************************************************************************//**
 * @brief Reads the value of the selected register.
 *
 * @param registerAddress - The address of the register to read.
 *
 * @return registerValue  - The register's value or negative error code.
*******************************************************************************/
uint64_t ltc2380_driver::ltc2380_read(uint32_t registerAddress)
{
    uint32_t regAddress  = 0;
    uint8_t  rxBuffer[LTC2380_MAX_SPI_TRANSACTION_BYTES];
    uint8_t  txBuffer[LTC2380_MAX_SPI_TRANSACTION_BYTES];
    uint64_t regValue    = 0;
    int32_t  ret         = 0;

	if ((registerAddress >= ltc2380_HIGHEST_REG_ADDR) || (registerAddress < 0)) {
     	xprintf("ltc2380_read: registerAddress=%d, out of range returning 0xEAA\n",registerAddress);
		return 0xEAA;
	}
	
	int num_bytes_to_write = 3;
	spi_driver->get_aux_out_encapsulator()->write(1 << LTC2380_CONV_AUX_OUT_BIT_NUM);
	spi_driver->get_aux_out_encapsulator()->write(0 << LTC2380_CONV_AUX_OUT_BIT_NUM);

	int watchdog_counter = 0;
	while ((watchdog_counter < LTC2380_BUSY_WATCHDOG_LIMIT) &&  (this->is_busy())) {
		low_level_system_usleep(1);
	}
	/*
	    //comment this out since we don't care about value of txbuffer
        for (int i = 0; i < num_bytes_to_write; i++) {
        	 txBuffer[i] = 0;
        }
		
  */
        set_cs_active();
        ret         = spi_driver->SPI_TransferData((1<<(this->get_chipselect_index())),num_bytes_to_write, (char*)txBuffer, num_bytes_to_write, (char*)rxBuffer, 1, 100);
        set_cs_inactive();

        if(ret < 0)
        {
			#if DEBUG_ltc2380_DEVICE_DRIVER
				xprintf("ltc2380_read: ret=%d, returning\n",ret);
			#endif
            return ret;
        }

        regValue = 0;
        for (int i = 0; i < num_bytes_to_write; i++) {
        	regValue = (regValue << 8) + ((uint64_t) (rxBuffer[i]));
        }
		
#if DEBUG_ltc2380_DEVICE_DRIVER
	 safe_print(std::cout << std::hex << "ltc2380_read: read 0x" << regValue << " from address 0x" << registerAddress << " ret = 0x" << ret << std::dec << std::endl);
#endif
    return regValue;
}

/***************************************************************************//**
 * @brief Writes a value to the selected register.
 *
 * @param registerAddress - The address of the register to write to.
 * @param registerValue   - The value to write to the register.
 *
 * @return Returns 0 in case of success or negative error code.
*******************************************************************************/
uint32_t ltc2380_driver::ltc2380_write(uint32_t registerAddress, uint64_t registerValue)
{
    
    	 safe_print(std::cout << std::hex << "ltc2380_write: this function is not implemente!!!" << registerValue << " to address: 0x"<< registerAddress << std::dec << std::endl);
  	    
         return 0;
}



