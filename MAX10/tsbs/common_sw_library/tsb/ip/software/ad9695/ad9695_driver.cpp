
/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include "ad9695_driver.h"
#include <cstddef>
#include "xprintf.h"

/******************************************************************************/
/************************ Variables Definitions *******************************/
/******************************************************************************/


/******************************************************************************/
/************************ Functions Definitions *******************************/
/******************************************************************************/

void ad9695_driver::set_cs_active() {
		 if (spi_driver != NULL) {
			 spi_driver->set_cs_word(1);
		    } else {
		    	xprintf("Error: set_cs_active: spi_driver is null! \n");
		    }
	}
void ad9695_driver::set_cs_inactive() {
		 if (spi_driver != NULL) {
			 spi_driver->set_cs_word(0);
		    } else {
		    	xprintf("Error: set_cs_inactive: spi_driver is null! \n");
		    }
	}


int32_t ad9695_driver::ad9695_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order) {
	int32_t             ret = 0;
    set_cs_inactive();

	 for (unsigned int i=0; i < register_address_value_pairs_in_order.size(); i++) {
		 ad9695_write(register_address_value_pairs_in_order.at(i).first,register_address_value_pairs_in_order.at(i).second);
	  }
    return ret;

}

int32_t ad9695_driver::ad9695_soft_reset()
{
    int32_t             ret = 0;
    set_cs_inactive();
    ad9695_write(0x0,0x81); //soft reset, without it apparently spi writes don't work
    usleep(1000000);
    return ret;
}


void ad9695_driver::ad9695_init()
{
    int32_t             ret = 0;
    set_cs_inactive();
  //  ad9695_write(0x0,0x81); //soft reset, without it apparently spi writes don't work
    /*
   ad9695_write(0x0   ,0x0  );
   ad9695_write(0x1   ,0x0  );
   ad9695_write(0x2   ,0x0  );
   ad9695_write(0x3   ,0x3  );
   ad9695_write(0x4   ,0xDE );
   ad9695_write(0x5   ,0x0  );
   ad9695_write(0x6   ,0x2  );
   ad9695_write(0x8   ,0x3  );
   ad9695_write(0xa   ,0x7  );
   ad9695_write(0xb   ,0x1  );
   ad9695_write(0xc   ,0x56 );
   ad9695_write(0xd   ,0x4  );
   ad9695_write(0xf   ,0x0  );
   ad9695_write(0x3f  ,0x0  );
   ad9695_write(0x40  ,0x3F );
   ad9695_write(0x41  ,0x0  );
   ad9695_write(0x42  ,0xFF );
   ad9695_write(0x108 ,0x0  );
   ad9695_write(0x109 ,0x0  );
   ad9695_write(0x10a ,0x0  );
   ad9695_write(0x10b ,0x0  );
   ad9695_write(0x110 ,0x0  );
   ad9695_write(0x111 ,0x0  );
   ad9695_write(0x112 ,0xC0 );
   ad9695_write(0x113 ,0x0  );
   ad9695_write(0x114 ,0xC0 );
   ad9695_write(0x11a ,0xB  );
   ad9695_write(0x11b ,0x1  );
   ad9695_write(0x11c ,0x93 );
   ad9695_write(0x11e ,0x93 );
   ad9695_write(0x120 ,0x0  );
   ad9695_write(0x121 ,0x0  );
   ad9695_write(0x122 ,0x0  );
   ad9695_write(0x123 ,0x40 );
   ad9695_write(0x128 ,0x48 );
   ad9695_write(0x129 ,0x0  );
   ad9695_write(0x12a ,0x0  );
   ad9695_write(0x1ff ,0x0  );
   ad9695_write(0x200 ,0x0  );
   ad9695_write(0x201 ,0x0  );
   ad9695_write(0x245 ,0x0  );
   ad9695_write(0x247 ,0x0  );
   ad9695_write(0x248 ,0x0  );
   ad9695_write(0x249 ,0x0  );
   ad9695_write(0x24a ,0x0  );
   ad9695_write(0x24b ,0x0  );
   ad9695_write(0x24c ,0x0  );
   ad9695_write(0x26f ,0x0  );
   ad9695_write(0x270 ,0x0  );
   ad9695_write(0x271 ,0x80 );
   ad9695_write(0x272 ,0x0  );
   ad9695_write(0x273 ,0x0  );
   ad9695_write(0x274 ,0x1  );
   ad9695_write(0x275 ,0x0  );
   ad9695_write(0x276 ,0x0  );
   ad9695_write(0x277 ,0x0  );
   ad9695_write(0x278 ,0x0  );
   ad9695_write(0x279 ,0x0  );
   ad9695_write(0x27a ,0x2  );
   ad9695_write(0x550 ,0x4  );
   ad9695_write(0x551 ,0x0  );
   ad9695_write(0x552 ,0x0  );
   ad9695_write(0x553 ,0x0  );
   ad9695_write(0x554 ,0x0  );
   ad9695_write(0x555 ,0x0  );
   ad9695_write(0x556 ,0x0  );
   ad9695_write(0x557 ,0x0  );
   ad9695_write(0x558 ,0x0  );
   ad9695_write(0x559 ,0x0  );
   ad9695_write(0x55a ,0x0  );
   ad9695_write(0x561 ,0x1  );
   ad9695_write(0x562 ,0x0  );
   ad9695_write(0x563 ,0x0  );
   ad9695_write(0x564 ,0x0  );
   ad9695_write(0x56e ,0x10 );
   ad9695_write(0x56f ,0x80 );
   ad9695_write(0x571 ,0x14 );
   ad9695_write(0x572 ,0x0  );
   ad9695_write(0x573 ,0x0  );
   ad9695_write(0x574 ,0x0  );
   ad9695_write(0x578 ,0x0  );
   ad9695_write(0x580 ,0x0  );
   ad9695_write(0x581 ,0x0  );
   ad9695_write(0x583 ,0x0  );
   ad9695_write(0x584 ,0x1  );
   ad9695_write(0x585 ,0x2  );
   ad9695_write(0x586 ,0x3  );
   ad9695_write(0x58b ,0x83 );
   ad9695_write(0x58c ,0x1  );
   ad9695_write(0x58d ,0x1F );
   ad9695_write(0x58e ,0x1  );
   ad9695_write(0x58f ,0xF  );
   ad9695_write(0x590 ,0xF  );
   ad9695_write(0x591 ,0x21 );
   ad9695_write(0x592 ,0x0  );
   ad9695_write(0x5a0 ,0xE3 );
   ad9695_write(0x5a1 ,0xE4 );
   ad9695_write(0x5a2 ,0xE5 );
   ad9695_write(0x5a3 ,0xE6 );
   ad9695_write(0x5b0 ,0xAA );
   ad9695_write(0x5b2 ,0x0  );
   ad9695_write(0x5b3 ,0x11 );
   ad9695_write(0x5b5 ,0x22 );
   ad9695_write(0x5b6 ,0x33 );
   ad9695_write(0x5bf ,0x0  );
   ad9695_write(0x5c0 ,0x11 );
   ad9695_write(0x5c1 ,0x11 );
   ad9695_write(0x5c2 ,0x11 );
   ad9695_write(0x5c3 ,0x11 );
   ad9695_write(0x5c4 ,0x0  );
   ad9695_write(0x5c6 ,0x0  );
   ad9695_write(0x5c8 ,0x0  );
   ad9695_write(0x5ca ,0x0  );
   ad9695_write(0x701 ,0x2  );
   ad9695_write(0x73b ,0xBF );
   ad9695_write(0xdf8 ,0x0  );
   ad9695_write(0xdf9 ,0x0  );
   ad9695_write(0x1222,0x0  );
   ad9695_write(0x1228,0xF  );
   ad9695_write(0x1262,0x0  );
   ad9695_write(0x18a6,0x0  );
   ad9695_write(0x18e3,0x0  );
   ad9695_write(0x18e6,0x0  );
   ad9695_write(0x1908,0x0  );
   ad9695_write(0x1910,0xC  );
   ad9695_write(0x1a4c,0xF  );
   ad9695_write(0x1a4d,0xF  );
   ad9695_write(0x1b03,0x2  );
   ad9695_write(0x1b08,0xC1 );
   ad9695_write(0x1b10,0x0  );

    */
    usleep(1000000);
}

/***************************************************************************//**
 * @brief Reads the value of the selected register.
 *
 * @param registerAddress - The address of the register to read.
 *
 * @return registerValue  - The register's value or negative error code.
*******************************************************************************/
int32_t ad9695_driver::ad9695_read(int32_t registerAddress)
{
    uint32_t regAddress  = 0;
    uint8_t  rxBuffer[3] = {0, 0, 0};
    uint8_t  txBuffer[3] = {0, 0, 0};
    uint32_t regValue    = 0;
    uint8_t  i           = 0;
    int32_t  ret         = 0;

    regAddress = ad9695_READ + registerAddress;
      txBuffer[0] = (regAddress & 0xFF00) >> 8;
        txBuffer[1] = regAddress & 0x00FF;
        txBuffer[2] = 0;
        set_cs_active();
        ret         = spi_driver->SPI_TransferData(1,3, (char*)txBuffer, 3, (char*)rxBuffer, 1, 2);
        set_cs_inactive();

        if(ret < 0)
        {
            return ret;
        }
        regValue = rxBuffer[2];
#if DEBUG_ad9695_DEVICE_DRIVER
    xprintf("ad9695_read: read %x from %x \n",regValue,registerAddress);
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
int32_t ad9695_driver::ad9695_write(int32_t registerAddress, int32_t registerValue)
{
    uint8_t  i           = 0;
    int32_t  ret         = 0;
    uint16_t regAddress  = 0;
    char     regValue    = 0;
    char     txBuffer[3] = {0, 0, 0};
    
     regAddress = ad9695_WRITE + registerAddress;
     regValue =    registerValue;
     txBuffer[0] = (regAddress & 0xFF00) >> 8;
     txBuffer[1] = regAddress & 0x00FF;
     txBuffer[2] = regValue;
     set_cs_active();
     ret =  spi_driver->SPI_TransferData(1,3, (char*)txBuffer, 0, NULL, 1, 100);
     set_cs_inactive();
     if(ret < 0)
     {
    
  	 #if DEBUG_ad9695_DEVICE_DRIVER
  	 	xprintf("ad9695_write: ABNORMAL: wrote %x to %x ret = %d\n",registerValue,registerAddress, ret);
  	 #endif
    
         return ret;
     }
       

#if DEBUG_ad9695_DEVICE_DRIVER
    xprintf("ad9695_write: wrote %x to %x ret = %d\n",registerValue,registerAddress, ret);
#endif
    return (ret - 1);
}



