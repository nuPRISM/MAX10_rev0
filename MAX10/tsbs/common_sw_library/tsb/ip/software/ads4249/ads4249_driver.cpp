
/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include "ads4249_driver.h"
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

void ads4249_driver::set_cs_active() {
		 if (spi_driver != NULL) {
			 spi_driver->set_cs_word((1<<(this->get_chipselect_index())));
		    } else {
		    	xprintf("Error: set_cs_active: spi_driver is null! \n");
		    }
	}
void ads4249_driver::set_cs_inactive() {
		 if (spi_driver != NULL) {
			 spi_driver->set_cs_word(0);
		    } else {
		    	xprintf("Error: set_cs_inactive: spi_driver is null! \n");
		    }
	}


int32_t ads4249_driver::ads4249_setup(std::map<unsigned long,unsigned long> register_address_value_pairs) {
	int32_t             ret = 0;
    set_cs_inactive();
	 std::map<unsigned long,unsigned long>::iterator iter;
	 for (iter = register_address_value_pairs.begin(); iter != register_address_value_pairs.end(); iter++) {
		 ads4249_write(iter->first,iter->second);
	  }
    return ret;

}

int32_t ads4249_driver::ads4249_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order) {
	int32_t             ret = 0;
    set_cs_inactive();

	 for (unsigned int i=0; i < register_address_value_pairs_in_order.size(); i++) {
		 ads4249_write(register_address_value_pairs_in_order.at(i).first,register_address_value_pairs_in_order.at(i).second);
	  }
    return ret;

}

int32_t ads4249_driver::ads4249_soft_reset()
{
    int32_t ret = 0;
    set_cs_inactive();
    ads4249_write(0,2);
//    low_level_system_usleep(1);
    ads4249_write(0,0);
//   low_level_system_usleep(1);
    return ret;
}

/***************************************************************************//**
 * @brief Reads the value of the selected register.
 *
 * @param registerAddress - The address of the register to read.
 *
 * @return registerValue  - The register's value or negative error code.
*******************************************************************************/
uint64_t ads4249_driver::ads4249_read(uint32_t registerAddress)
{
	    uint32_t regAddress  = 0;
	    uint8_t  rxBuffer[2] = {0, 0};
	    uint8_t  txBuffer[2] = {0, 0};
	    uint32_t regValue    = 0;
	    uint8_t  i           = 0;
	    int32_t  ret         = 0;

	    enable_readout();
	    regAddress = registerAddress;
	    txBuffer[0]   = regAddress & 0xFF;
	    txBuffer[1] = regAddress & 0xFF;
	    set_cs_active();
	    ret         = spi_driver->SPI_TransferData((1<<(this->get_chipselect_index())),2, (char*)txBuffer, 2, (char*)rxBuffer, 1, 100);
	    set_cs_inactive();
	    disable_readout();
        if(ret < 0)
        {
			#if DEBUG_ads4249_DEVICE_DRIVER
					xprintf("ads4249_read: ret=%d, returning\n",ret);
				#endif
            return ret;
        }
        regValue = rxBuffer[1];
	#if DEBUG_ads4249_DEVICE_DRIVER
	    xprintf("ads4249_read: read %x from %x \n",regValue,registerAddress);
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
uint32_t ads4249_driver::ads4249_write(uint32_t registerAddress, uint64_t registerValue)
{
    
	uint8_t  i           = 0;
	    int32_t  ret         = 0;
	    uint16_t regAddress  = 0;
	    char     regValue    = 0;
	    char     txBuffer[2] = {0, 0};

	     regAddress =  registerAddress;
	     regValue =    registerValue;
	     txBuffer[0] = regAddress & 0xFF;
	     txBuffer[1] = registerValue & 0xFF;
	     set_cs_active();
	     ret =  spi_driver->SPI_TransferData((1<<(this->get_chipselect_index())),2, (char*)txBuffer, 0, NULL, 1, 100);
	     set_cs_inactive();
	     if(ret < 0)
	     {

	  	 #if DEBUG_ads4249_DEVICE_DRIVER
	  	 	xprintf("ads4249_write: ABNORMAL: wrote %x to %x ret = %d\n",registerValue,registerAddress, ret);
	  	 #endif

	         return ret;
	     }


	#if DEBUG_ads4249_DEVICE_DRIVER
	    xprintf("ads4249_write: wrote %x to %x ret = %d\n",registerValue,registerAddress, ret);
	#endif
	    return (ret - 1);
}

uint32_t ads4249_driver::enable_readout() {
	return ads4249_write(0,1);
}


uint32_t ads4249_driver::disable_readout() {
	return ads4249_write(0,0);
}

