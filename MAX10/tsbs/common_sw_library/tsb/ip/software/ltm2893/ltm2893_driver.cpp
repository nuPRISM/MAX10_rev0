
/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include "ltm2893_driver.h"
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

void ltm2893_driver::set_cs_active() {
		 if (spi_driver != NULL) {
			 spi_driver->set_cs_word((1<<(this->get_chipselect_index())));
		    } else {
		    	xprintf("Error: set_cs_active: spi_driver is null! \n");
		    }
	}
void ltm2893_driver::set_cs_inactive() {
		 if (spi_driver != NULL) {
			 spi_driver->set_cs_word(0);
		    } else {
		    	xprintf("Error: set_cs_inactive: spi_driver is null! \n");
		    }
	}


int32_t ltm2893_driver::ltm2893_setup(std::map<unsigned long,unsigned long> register_address_value_pairs) {
	int32_t             ret = 0;
    set_cs_inactive();
	 std::map<unsigned long,unsigned long>::iterator iter;
	 for (iter = register_address_value_pairs.begin(); iter != register_address_value_pairs.end(); iter++) {
		 ltm2893_write(iter->first,iter->second);
	  }
    return ret;

}

int32_t ltm2893_driver::ltm2893_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order) {
	int32_t             ret = 0;
    set_cs_inactive();

	 for (unsigned int i=0; i < register_address_value_pairs_in_order.size(); i++) {
		 ltm2893_write(register_address_value_pairs_in_order.at(i).first,register_address_value_pairs_in_order.at(i).second);
	  }
    return ret;

}

int32_t ltm2893_driver::ltm2893_soft_reset()
{
    int32_t             ret = 0;
    set_cs_inactive();
    return ret;
}

/***************************************************************************//**
 * @brief Reads the value of the selected register.
 *
 * @param registerAddress - The address of the register to read.
 *
 * @return registerValue  - The register's value or negative error code.
*******************************************************************************/
uint64_t ltm2893_driver::ltm2893_read(uint32_t registerAddress)
{
    uint32_t regAddress  = 0;
    uint8_t  rxBuffer[LTM2893_MAX_SPI_TRANSACTION_BYTES];
    uint8_t  txBuffer[LTM2893_MAX_SPI_TRANSACTION_BYTES];
    uint64_t regValue    = 0;
    int32_t  ret         = 0;

	if ((registerAddress >= ltm2893_HIGHEST_REG_ADDR) || (registerAddress < 0)) {
     	xprintf("ltm2893_read: registerAddress=%d, out of range returning 0xEAA\n",registerAddress);
		return 0xEAA;
	}
	
	int num_bytes_to_write = ltm2893_reg_param.at(registerAddress).get_num_bytes_to_write();
	unsigned int byte_to_lower_en_at = ltm2893_reg_param.at(registerAddress).get_byte_to_lower_en_at_read();
	unsigned int bit_to_lower_en_at  = ltm2893_reg_param.at(registerAddress).get_bit_to_lower_en_at_read();
	spi_driver->get_aux_out_encapsulator()->write((1 << 17) + (byte_to_lower_en_at << 8) + bit_to_lower_en_at);
	
    regAddress = ltm2893_READ + registerAddress;
        txBuffer[0]   = regAddress & 0xFF;

        for (int i = 1; i < num_bytes_to_write; i++) {
        	 txBuffer[i] = 0;
        }

        set_cs_active();
        ret         = spi_driver->SPI_TransferData((1<<(this->get_chipselect_index())),num_bytes_to_write, (char*)txBuffer, num_bytes_to_write, (char*)rxBuffer, 1, 100);
        set_cs_inactive();

        if(ret < 0)
        {
			#if DEBUG_ltm2893_DEVICE_DRIVER
				xprintf("ltm2893_read: ret=%d, returning\n",ret);
			#endif
            return ret;
        }

        regValue = 0;
        for (int i = 1; i < num_bytes_to_write; i++) {
        	regValue = (regValue << 8) + ((uint64_t) (rxBuffer[i]));
        }

		uint64_t extracted_reg_value = extract_bit_range_ull(regValue,
				ltm2893_reg_param.at(registerAddress).get_value_lsb(),
				ltm2893_reg_param.at(registerAddress).get_value_msb());

#if DEBUG_ltm2893_DEVICE_DRIVER
	 safe_print(std::cout << std::hex << "ltm2893_read: read 0x" << regValue   << " extracted val 0x" << extracted_reg_value << " from address 0x" << registerAddress << " ret = 0x" << ret << std::dec << std::endl);
#endif
    return extracted_reg_value;
}

/***************************************************************************//**
 * @brief Writes a value to the selected register.
 *
 * @param registerAddress - The address of the register to write to.
 * @param registerValue   - The value to write to the register.
 *
 * @return Returns 0 in case of success or negative error code.
*******************************************************************************/
uint32_t ltm2893_driver::ltm2893_write(uint32_t registerAddress, uint64_t registerValue)
{
    int32_t  ret         = 0;
    uint16_t regAddress  = 0;
    char     txBuffer[LTM2893_MAX_SPI_TRANSACTION_BYTES];
    
	if ((registerAddress >= ltm2893_HIGHEST_REG_ADDR) || (registerAddress < 0)) {
     	xprintf("ltm2893_read: registerAddress=%d, out of range returning 0xEAA\n",registerAddress);
		return 0xEAA;
	}
	
	 int num_bytes_to_write = ltm2893_reg_param.at(registerAddress).get_num_bytes_to_write();
	 unsigned int byte_to_lower_en_at = ltm2893_reg_param.at(registerAddress).get_byte_to_lower_en_at();
     unsigned int bit_to_lower_en_at  = ltm2893_reg_param.at(registerAddress).get_bit_to_lower_en_at();

     regAddress = ltm2893_WRITE + registerAddress;
     txBuffer[0] = regAddress & 0xFF;
     uint64_t temp_registerValue = registerValue <<  ltm2893_reg_param.at(registerAddress).get_bit_to_shift_write_on_write();
     for (int i = num_bytes_to_write-1; i >= 1; i--) {
    	 txBuffer[i] = temp_registerValue & 0xFF;
    	 temp_registerValue = temp_registerValue >> 8;
     }

	 spi_driver->get_aux_out_encapsulator()->write((1 << 17) + (byte_to_lower_en_at << 8) + bit_to_lower_en_at);
     set_cs_active();
     ret =  spi_driver->SPI_TransferData((1<<(this->get_chipselect_index())),num_bytes_to_write, (char*)txBuffer, 0, NULL, 1, 100);
     set_cs_inactive();
     if(ret < 0)
     {
    
  	 #if DEBUG_ltm2893_DEVICE_DRIVER
    	 safe_print(std::cout << std::hex << "ltm2893_write: ABNORMAL wrote 0x" << registerValue << " to address: 0x"<< registerAddress << " ret = 0x" << ret << std::dec << std::endl);
  	 #endif
    
         return ret;
     }
       

#if DEBUG_ltm2893_DEVICE_DRIVER
    safe_print(std::cout << std::hex << "ltm2893_write: wrote 0x" << registerValue << " to address: 0x" << registerAddress << " ret = 0x" << ret << std::dec << std::endl);
#endif
    return (ret - 1);
}



