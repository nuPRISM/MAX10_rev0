
/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include "fmc176_ad9250_driver.h"
#include <cstddef>
#include "xprintf.h"

/******************************************************************************/
/************************ Variables Definitions *******************************/
/******************************************************************************/


/******************************************************************************/
/************************ Functions Definitions *******************************/
/******************************************************************************/

void fmc176_ad9250_driver::set_cs_active() {
		 if (spi_driver != NULL) {
			 spi_driver->set_cs_word(1);
		    } else {
		    	xprintf("Error: set_cs_active: spi_driver is null! \n");
		    }
	}

void fmc176_ad9250_driver::set_cs_inactive() {
		 if (spi_driver != NULL) {
			 spi_driver->set_cs_word(0);
		    } else {
		    	xprintf("Error: set_cs_inactive: spi_driver is null! \n");
		    }
	}


int32_t fmc176_ad9250_driver::fmc176_ad9250_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order) {
	int32_t             ret = 0;
    set_cs_inactive();

	 for (unsigned int i=0; i < register_address_value_pairs_in_order.size(); i++) {
		 fmc176_ad9250_write(register_address_value_pairs_in_order.at(i).first,register_address_value_pairs_in_order.at(i).second);
	  }
    return ret;

}

int32_t fmc176_ad9250_driver::fmc176_ad9250_soft_reset()
{
    int32_t             ret = 0;
    set_cs_inactive();
    fmc176_ad9250_write(0x0,0x3C); //soft reset
    usleep(1000000);
    return ret;
}
void fmc176_ad9250_driver::fmc176_ad9250_init(int enable_test_signal) {
	fmc176_ad9250_write(AD9250_REG_CHIP_PORT_CONF, 0x3C); //software reset
    usleep(100000);
	fmc176_ad9250_write(AD9250_REG_SYSREF_CONTROL, 0x00);
	fmc176_ad9250_write(AD9250_REG_JESD204B_LINK_CNTRL_1, 0x15);
	fmc176_ad9250_write(AD9250_REG_JESD204B_QUICK_CONFIG, 0x22);
	if (this->get_subclass() == 0) {
	    fmc176_ad9250_write(AD9250_REG_SYSREF_CONTROL, 0x10);
	} else {
		fmc176_ad9250_write(AD9250_REG_SYSREF_CONTROL,  0x13);
	}
	fmc176_ad9250_write(0xEE,0x80); //Enable the internal clock delay block for minimum delay.
	fmc176_ad9250_write(AD9250_REG_204B_DID_CONFIG,(this->id_no));
	fmc176_ad9250_write(AD9250_REG_204B_BID_CONFIG,0);
	fmc176_ad9250_write(AD9250_REG_204B_LID_CONFIG_0, (((this->id_no)*2)+0));
	fmc176_ad9250_write(AD9250_REG_204B_LID_CONFIG_1, (((this->id_no)*2)+1));
	fmc176_ad9250_write(AD9250_REG_204B_PARAM_SCRAMBLE_LANES, 0x81);
	fmc176_ad9250_write(AD9250_REG_204B_PARAM_K, 0x1F);
	if (this->get_subclass() == 0) {
	    fmc176_ad9250_write(AD9250_REG_JESD204B_SUBCLASS_NP,0xF); //subclass 0
	} else {
		fmc176_ad9250_write(AD9250_REG_JESD204B_SUBCLASS_NP,0x2F); //subclass 1
	}
	fmc176_ad9250_write(AD9250_REG_TRANSFER, 0x01);
	if (enable_test_signal) {
	     fmc176_ad9250_write(AD9250_REG_TEST_CNTRL, AD9250_TEST_RAMP);
	} else {
		 fmc176_ad9250_write(AD9250_REG_TEST_CNTRL, AD9250_TEST_OFF);
	}
	fmc176_ad9250_write(AD9250_REG_TRANSFER, 0x01);
//	fmc176_ad9250_write(AD9250_REG_OUTPUT_MODE, 0x00);
	usleep(100000);
	fmc176_ad9250_write(AD9250_REG_JESD204B_LINK_CNTRL_1,0x14); //Enable the JESD204B PHY. This begins the CGS phase for establishing a link.
	fmc176_ad9250_write(0xF3,0xFF); //Force an internal FIFO alignment.

	usleep(200000);
	//Internal FIFO clock adjustment
	fmc176_ad9250_write(0xEE,0x81); //Clock adjustment procedure
	fmc176_ad9250_write(0xEF,0x81); //Clock adjustment procedure
	fmc176_ad9250_write(0xEE,0x82); //Clock adjustment procedure
    fmc176_ad9250_write(0xEF,0x82); //Clock adjustment procedure
	fmc176_ad9250_write(0xEE,0x83); //Clock adjustment procedure
	fmc176_ad9250_write(0xEF,0x83); //Clock adjustment procedure
	fmc176_ad9250_write(0xEE,0x84); //Clock adjustment procedure
    fmc176_ad9250_write(0xEF,0x84); //Clock adjustment procedure
	fmc176_ad9250_write(0xEE,0x85); //Clock adjustment procedure
	fmc176_ad9250_write(0xEF,0x85); //Clock adjustment procedure
	fmc176_ad9250_write(0xEE,0x86); //Clock adjustment procedure
    fmc176_ad9250_write(0xEF,0x86); //Clock adjustment procedure
	fmc176_ad9250_write(0xEE,0x87); //Clock adjustment procedure
	fmc176_ad9250_write(0xEF,0x87); //Clock adjustment procedure
	usleep(20000);
	int32_t stat = fmc176_ad9250_read(AD9250_REG_PLL_STATUS);
	xprintf("fmc176_ad9250_init id_no = %u AD9250 PLL/link %s (0x%x).\n", this->id_no, (stat == 0x81) ? "ok" : "errors", (unsigned int) stat);
	fmc176_ad9250_write(AD9250_REG_TRANSFER, 0x01); //transfer anything not transferred

}

bool fmc176_ad9250_driver::chip_is_responding() {
	return (this->fmc176_ad9250_read(AD9250_REG_CHIP_ID) == AD9250_CHIP_ID);
}
/***************************************************************************//**
 * @brief Reads the value of the selected register.
 *
 * @param registerAddress - The address of the register to read.
 *
 * @return registerValue  - The register's value or negative error code.
*******************************************************************************/
int32_t fmc176_ad9250_driver::fmc176_ad9250_read(int32_t registerAddress)
{
    uint32_t regAddress  = 0;
    uint8_t  rxBuffer[4] = {0, 0, 0, 0};
    uint8_t  txBuffer[4] = {0, 0, 0, 0};
    uint32_t regValue    = 0;
    uint8_t  i           = 0;
    int32_t  ret         = 0;

        regAddress = fmc176_ad9250_READ + registerAddress;
        txBuffer[0] = FMC176_AD9250_ADDRESS_PREFIX | this->get_id_no();
        txBuffer[1] = (regAddress & 0xFF00) >> 8;
        txBuffer[2] = regAddress & 0x00FF;
        txBuffer[3] = 0;
        set_cs_active();
        ret         = spi_driver->SPI_TransferData(1,4, (char*)txBuffer, 4, (char*)rxBuffer, 1, 3);
        set_cs_inactive();

        if(ret < 0)
        {
            return ret;
        }
        regValue = rxBuffer[3];
#if DEBUG_fmc176_ad9250_DEVICE_DRIVER
    xprintf("fmc176_ad9250_read: read %x from %x \n",regValue,registerAddress);
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
int32_t fmc176_ad9250_driver::fmc176_ad9250_write(int32_t registerAddress, int32_t registerValue)
{
    uint8_t  i           = 0;
    int32_t  ret         = 0;
    uint16_t regAddress  = 0;
    char     regValue    = 0;
    char     txBuffer[4] = {0, 0, 0, 0};
    
     regAddress = fmc176_ad9250_WRITE + registerAddress;
     regValue =    registerValue;

     txBuffer[0] = FMC176_AD9250_ADDRESS_PREFIX | this->get_id_no();
     txBuffer[1] = (regAddress & 0xFF00) >> 8;
     txBuffer[2] = regAddress & 0x00FF;
     txBuffer[3] = regValue;
     set_cs_active();
     ret =  spi_driver->SPI_TransferData(1,4, (char*)txBuffer, 0, NULL, 1, 100);
     set_cs_inactive();
     if(ret < 0)
     {
    
  	 #if DEBUG_fmc176_ad9250_DEVICE_DRIVER
  	 	xprintf("fmc176_ad9250_write: ABNORMAL: wrote %x to %x ret = %d\n",registerValue,registerAddress, ret);
  	 #endif
    
         return ret;
     }
       

#if DEBUG_fmc176_ad9250_DEVICE_DRIVER
    xprintf("fmc176_ad9250_write: wrote %x to %x ret = %d\n",registerValue,registerAddress, ret);
#endif
    return (ret - 1);
}



