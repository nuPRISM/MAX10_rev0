
/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include "ltc2668_driver.h"
#include <cstddef>
#include "xprintf.h"
#include "linnux_utils.h"
/******************************************************************************/
/************************ Variables Definitions *******************************/
/******************************************************************************/


/******************************************************************************/
/************************ Functions Definitions *******************************/
/******************************************************************************/

void ltc2668_driver::set_cs_active() {
		 if (spi_driver != NULL) {
			 spi_driver->set_cs_word(1);
		    } else {
		    	xprintf("Error: set_cs_active: spi_driver is null! \n");
		    }
	}
void ltc2668_driver::set_cs_inactive() {
		 if (spi_driver != NULL) {
			 spi_driver->set_cs_word(0);
		    } else {
		    	xprintf("Error: set_cs_inactive: spi_driver is null! \n");
		    }
	}


uint32_t ltc2668_driver::ltc2668_setup(std::map<unsigned long,unsigned long> register_address_value_pairs) {
	uint32_t             ret = 0;
    set_cs_inactive();
	 std::map<unsigned long,unsigned long>::iterator iter;
	 for (iter = register_address_value_pairs.begin(); iter != register_address_value_pairs.end(); iter++) {
		 ltc2668_write(iter->first,iter->second);
	  }
    return ret;

}

uint32_t ltc2668_driver::ltc2668_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order) {
	uint32_t             ret = 0;
    set_cs_inactive();

	 for (unsigned int i=0; i < register_address_value_pairs_in_order.size(); i++) {
		 ltc2668_write(register_address_value_pairs_in_order.at(i).first,register_address_value_pairs_in_order.at(i).second);
	  }
    return ret;

}

uint32_t ltc2668_driver::ltc2668_soft_reset(uint16_t span, uint16_t initial_value)
{
    int32_t  ret = 0;
    ltc2668_set_span(span);
    ltc2668_internal_write(LTC2668_CMD_WRITE_N_UPDATE_ALL,0,initial_value);
    for (int i = 0; i < NUM_LTC2668_DACS; i++) {
    	this->set_shadow_reg(i,initial_value);
    }
    return ret;
}

/***************************************************************************//**
 * @brief Reads the value of the selected register.
 *
 * @param registerAddress - The address of the register to read.
 *
 * @return registerValue  - The register's value or negative error code.
*******************************************************************************/
uint32_t ltc2668_driver::ltc2668_read(int32_t registerAddress)
{
    int32_t regValue    = 0;
    regValue =  get_shadow_reg(registerAddress);
#if DEBUG_ltc2668_DEVICE_DRIVER
    xprintf("ltc2668_read: read 0x%x from 0x%x \n",regValue,registerAddress);
#endif
    return regValue;
}

uint32_t ltc2668_driver::ltc2668_internal_write(uint8_t opcode, int32_t registerAddress, uint32_t registerValue)
{
	    uint32_t  ret         = 0;
	    uint8_t regAddress  = 0;
	    uint16_t     regValue    = 0;
	    uint32_t returned_command = 0;
	    uint16_t returnedValue;
	    uint32_t transmitted_command = 0;
	    char     txBuffer[4] = {0, 0, 0, 0};
	    char     rxBuffer[4] = {0, 0, 0, 0};

	     regAddress  = opcode | (registerAddress & 0xF);
	     regValue    = registerValue & 0xFFFF;
	     txBuffer[0] = 0;
	     txBuffer[1] = regAddress;
	     txBuffer[2] = (regValue & 0xFF00) >> 8;
	     txBuffer[3] =  (regValue & 0xFF);
	     transmitted_command = convert_array_of_four_chars_into_unsigned(txBuffer);
	     set_cs_active();
	     //Do two writes so that the returned data matches the writted data
	     spi_driver->SPI_TransferData(1,4,(char*)txBuffer, 4, (char*)rxBuffer, 1, 100);
	     ret =  spi_driver->SPI_TransferData(1,4,(char*)txBuffer, 4, (char*)rxBuffer, 1, 100);
	     returned_command = convert_array_of_four_chars_into_unsigned(rxBuffer);
	     set_cs_inactive();

	     returnedValue = returned_command & 0xFFFF;

	#if DEBUG_ltc2668_DEVICE_DRIVER
		 	xprintf("ltc2668_internal_write: wrote:0x%x Addr:0x%x Opcode: 0x%x Raw command: 0x%x Returned command = 0x%x returned value = 0x%x ret = %d\n",
		 			                        registerValue,registerAddress,opcode, transmitted_command,returned_command,returnedValue, ret);
	#endif
	    return returned_command;
}

/***************************************************************************//**
 * @brief Writes a value to the selected register.
 *
 * @param registerAddress - The address of the register to write to.
 * @param registerValue   - The value to write to the register.
 *
 * @return Returns 0 in case of success or negative error code.
*******************************************************************************/
uint32_t ltc2668_driver::ltc2668_write(int32_t registerAddress, uint32_t registerValue)
{
	uint32_t  ret         = 0;
    ret = ltc2668_internal_write(LTC2668_CMD_WRITE_N_UPDATE_N, registerAddress, registerValue);
    set_shadow_reg(registerAddress,ret & 0xFFFF);
    return ret;
}

void ltc2668_driver::ltc2668_set_span(uint16_t span) {
	uint32_t ret = ltc2668_internal_write(LTC2668_CMD_SPAN_ALL, 0, span & 0x7);
	set_span_reg(ret & 0x7);
    #if DEBUG_ltc2668_DEVICE_DRIVER
		 	xprintf("ltc2668_set_span: wrote 0x%x to span. Returned command = 0x%x returned value = 0x%x\n",span,ret,ret&0x7);
	#endif
}



uint16_t ltc2668_driver::get_shadow_reg(int addr) {
	if ((addr < 0) || (addr >= NUM_LTC2668_DACS)) {
	    xprintf("ltc2668 get_shadow_reg: addr = %d is out of range from 0 to %d\n",addr,NUM_LTC2668_DACS);
		return (0xEAA);
	}

	return shadow_reg[addr];
}

void ltc2668_driver::set_shadow_reg(int addr, uint16_t data) {
	if ((addr < 0) || (addr >= NUM_LTC2668_DACS)) {
		    xprintf("ltc2668 set_shadow_reg: addr = %d is out of range from 0 to %d\n",addr,NUM_LTC2668_DACS);
			return;
		}
	shadow_reg[addr] = data;
}

uint16_t ltc2668_driver::get_span_reg() {
	return span_reg;
}

void ltc2668_driver::set_span_reg(uint16_t data) {
	span_reg = data;
}

uint16_t ltc2668_driver::ltc2668_get_span() {
	return get_span_reg();
}
