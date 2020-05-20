
/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include "ad9249_driver.h"
#include <cstddef>
#include "xprintf.h"

/******************************************************************************/
/************************ Variables Definitions *******************************/
/******************************************************************************/


/******************************************************************************/
/************************ Functions Definitions *******************************/
/******************************************************************************/

void ad9249_driver::set_cs_active() {
		 if (spi_driver != NULL) {
			 spi_driver->set_cs_word(1);
		    } else {
		    	xprintf("Error: set_cs_active: spi_driver is null! \n");
		    }
	}
void ad9249_driver::set_cs_inactive() {
		 if (spi_driver != NULL) {
			 spi_driver->set_cs_word(0);
		    } else {
		    	xprintf("Error: set_cs_inactive: spi_driver is null! \n");
		    }
	}


int32_t ad9249_driver::ad9249_setup(std::map<unsigned long,unsigned long> register_address_value_pairs) {
	int32_t             ret = 0;
    set_cs_inactive();
	 std::map<unsigned long,unsigned long>::iterator iter;
	 for (iter = register_address_value_pairs.begin(); iter != register_address_value_pairs.end(); iter++) {
		 ad9249_write(iter->first,iter->second);
	  }
    return ret;

}

int32_t ad9249_driver::ad9249_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order) {
	int32_t             ret = 0;
    set_cs_inactive();

	 for (unsigned int i=0; i < register_address_value_pairs_in_order.size(); i++) {
		 ad9249_write(register_address_value_pairs_in_order.at(i).first,register_address_value_pairs_in_order.at(i).second);
	  }
    return ret;

}

int32_t ad9249_driver::ad9249_soft_reset()
{
    int32_t             ret = 0;
    set_cs_inactive();
    ad9249_write(0x0,0x3C); //soft reset, without it apparently spi writes don't work
    usleep(10000);
    ad9249_write(0x0,0x18); //soft reset, without it apparently spi writes don't work
    usleep(1000000);
    return ret;
}

/***************************************************************************//**
 * @brief Reads the value of the selected register.
 *
 * @param registerAddress - The address of the register to read.
 *
 * @return registerValue  - The register's value or negative error code.
*******************************************************************************/
int32_t ad9249_driver::ad9249_read(int32_t registerAddress)
{
    uint32_t regAddress  = 0;
    uint8_t  rxBuffer[3] = {0, 0, 0};
    uint8_t  txBuffer[3] = {0, 0, 0};
    uint32_t regValue    = 0;
    uint8_t  i           = 0;
    int32_t  ret         = 0;

    regAddress = ad9249_READ + registerAddress;
      txBuffer[0] = (regAddress & 0xFF00) >> 8;
        txBuffer[1] = regAddress & 0x00FF;
        txBuffer[2] = 0;
        set_cs_active();
        ret         = spi_driver->SPI_TransferData((1<<(this->get_chipselect_index())),3, (char*)txBuffer, 3, (char*)rxBuffer, 1, 2);
        set_cs_inactive();

        if(ret < 0)
        {
            return ret;
        }
        regValue = rxBuffer[2];
#if DEBUG_ad9249_DEVICE_DRIVER
    xprintf("ad9249_read: read %x from %x \n",regValue,registerAddress);
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
int32_t ad9249_driver::ad9249_write(int32_t registerAddress, int32_t registerValue)
{
    uint8_t  i           = 0;
    int32_t  ret         = 0;
    uint16_t regAddress  = 0;
    char     regValue    = 0;
    char     txBuffer[3] = {0, 0, 0};
    
     regAddress = ad9249_WRITE + registerAddress;
     regValue =    registerValue;
     txBuffer[0] = (regAddress & 0xFF00) >> 8;
     txBuffer[1] = regAddress & 0x00FF;
     txBuffer[2] = regValue;
     set_cs_active();
     ret =  spi_driver->SPI_TransferData((1<<(this->get_chipselect_index())),3, (char*)txBuffer, 0, NULL, 1, 100);
     set_cs_inactive();
     if(ret < 0)
     {
    
  	 #if DEBUG_ad9249_DEVICE_DRIVER
  	 	xprintf("ad9249_write: ABNORMAL: wrote %x to %x ret = %d\n",registerValue,registerAddress, ret);
  	 #endif
    
         return ret;
     }
       

#if DEBUG_ad9249_DEVICE_DRIVER
    xprintf("ad9249_write: wrote %x to %x ret = %d\n",registerValue,registerAddress, ret);
#endif
    return (ret - 1);
}



