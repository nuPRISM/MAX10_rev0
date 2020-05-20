
/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include "ltc2983_driver.h"
#include <cstddef>
#include "xprintf.h"
#include <map>
#include <vector>
#include <utility>
#include "configuration_constants_LTC2983.h"
#include "table_coeffs_LTC2983.h"
#define highByte(x) (((x) & 0xFF00) >> 8)
#define lowByte(x) ((x) & 0xff) 

/******************************************************************************/
/************************ Variables Definitions *******************************/
/******************************************************************************/


/******************************************************************************/
/************************ Functions Definitions *******************************/
/******************************************************************************/

void ltc2983_driver::set_cs_active() {
		 if (spi_driver != NULL) {
			 spi_driver->set_cs_word(1);
		    } else {
		    	xprintf("Error: set_cs_active: spi_driver is null! \n");
		    }
	}
void ltc2983_driver::set_cs_inactive() {
		 if (spi_driver != NULL) {
			 spi_driver->set_cs_word(0);
		    } else {
		    	xprintf("Error: set_cs_inactive: spi_driver is null! \n");
		    }
	}
int32_t ltc2983_driver::ltc2983_setup(std::map<unsigned long,unsigned long> register_address_value_pairs) {
	int32_t             ret = 0;
    set_cs_inactive();
	 std::map<unsigned long,unsigned long>::iterator iter;
	 for (iter = register_address_value_pairs.begin(); iter != register_address_value_pairs.end(); iter++) {
		 ltc2983_write(iter->first,iter->second);
	  }
    return ret;

}

int32_t ltc2983_driver::ltc2983_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order) {
	int32_t             ret = 0;
    set_cs_inactive();

	 for (unsigned int i=0; i < register_address_value_pairs_in_order.size(); i++) {
		 ltc2983_write(register_address_value_pairs_in_order.at(i).first,register_address_value_pairs_in_order.at(i).second);
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
int32_t ltc2983_driver::ltc2983_read(int32_t registerAddress)
{
    uint8_t  rxBuffer[4] = {0, 0, 0, 0};
    uint8_t  txBuffer[4] = {0, 0, 0, 0};
    uint32_t regValue    = 0;
    uint8_t  i           = 0;
    int32_t  ret         = 0;

	    txBuffer[0] = ltc2983_READ;
        txBuffer[1] = (registerAddress & 0xFF00) >> 8;
        txBuffer[2] = registerAddress & 0x00FF;
        txBuffer[3] = 0;
        set_cs_active();
        ret         = spi_driver->SPI_TransferData(1,4, (char*)txBuffer, 4, (char*)rxBuffer, 1, 3);
        set_cs_inactive();

        if(ret < 0)
        {
            return ret;
        }
        regValue = rxBuffer[3];
#if DEBUG_ltc2983_DEVICE_DRIVER
    xprintf("ltc2983_read: read %x from %x \n",regValue,registerAddress);
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
int32_t ltc2983_driver::ltc2983_write(int32_t registerAddress, int32_t registerValue)
{
    uint8_t  i           = 4;
    int32_t  ret         = 4;
    char     txBuffer[4] = {0, 0, 0, 0};
    
	 txBuffer[0] = ltc2983_WRITE;
     txBuffer[1] = (registerAddress & 0xFF00) >> 8;
     txBuffer[2] = registerAddress & 0x00FF;
     txBuffer[3] = registerValue & 0xFF;
     set_cs_active();
     ret =  spi_driver->SPI_TransferData(1,4, (char*)txBuffer, 0, NULL, 1, 100);
     set_cs_inactive();
     if(ret < 0)
     {
    
  	 #if DEBUG_ltc2983_DEVICE_DRIVER
  	 	xprintf("ltc2983_write: ABNORMAL: wrote %x to %x ret = %d\n",registerValue,registerAddress, ret);
  	 #endif
    
         return ret;
     }
       

#if DEBUG_ltc2983_DEVICE_DRIVER
    xprintf("ltc2983_write: wrote %x to %x ret = %d\n",registerValue,registerAddress, ret);
#endif
    return ret;
}

/***************************************************************************//**
 * @brief Resets all registers to their default values.
 *
 * @return Returns negative error code or 0 in case of success.
*******************************************************************************/
int32_t ltc2983_driver::ltc2983_soft_reset(void)
{
	
    int32_t ret     = 0;
	/*
    ltc2983_write(0x0,0x80);
    usleep(100000); //because why not
    */
    return ret;
}

// -----------------------------------------------------------------
//                  Memory write functions
// -----------------------------------------------------------------
void ltc2983_driver::assign_channel(int channel_number, long channel_assignment_data)
{
  int bytes_per_coeff = 4;
  long start_address = 0x200+4*(channel_number-1);

  initialize_memory_write(start_address);
  write_coefficient(channel_assignment_data, bytes_per_coeff);
  finish_memory_write();
}

void ltc2983_driver::write_custom_table(struct table_coeffs coefficients[64], long start_address, long table_length)
{
  int bytes_per_coeff = 3;

  initialize_memory_write(start_address);
  for (int i=0; i< table_length; i++)
  {
    // write_table multiplies i by 6 and adds 250 to start address
    write_coefficient(coefficients[i].measurement, bytes_per_coeff);
    write_coefficient(coefficients[i].temperature, bytes_per_coeff);
  }
  finish_memory_write();
}

void ltc2983_driver::write_custom_steinhart_hart(long steinhart_hart_coeffs[6], long start_address)
{
  int bytes_per_coeff = 4;

  initialize_memory_write(start_address);
  for (int i = 0; i < 6; i++)
  {
    write_coefficient(steinhart_hart_coeffs[i], bytes_per_coeff);
  }
  finish_memory_write();
}

void ltc2983_driver::write_single_byte(long start_address, int single_byte)
{
  initialize_memory_write(start_address);
  spi_driver->spi_transfer_byte(single_byte);
  finish_memory_write();
}

void ltc2983_driver::initialize_memory_write(long start_address)
{
  set_cs_active();
  spi_driver->spi_transfer_byte(0x02); // instruction Byte Write
  spi_driver->spi_transfer_byte(highByte(start_address)); // Address MSB Byte
  spi_driver->spi_transfer_byte(lowByte (start_address)); // Address LSB Byte
}

void ltc2983_driver::write_coefficient(long coeff, int bytes_per_coeff)
{
  int data_byte;
  for (int i = bytes_per_coeff - 1; i >= 0; i--)
  {
    data_byte = coeff >> (i*8);
    spi_driver->spi_transfer_byte(data_byte);
  }
}

void ltc2983_driver::finish_memory_write()
{
       set_cs_inactive();

}



// -----------------------------------------------------------------
//                  Memory read functions
// -----------------------------------------------------------------
void ltc2983_driver::initialize_memory_read(long start_address)
{
  set_cs_active();
  spi_driver->spi_transfer_byte(0x03); // instruction Byte read
  spi_driver->spi_transfer_byte(highByte(start_address)); // Address MSB Byte
  spi_driver->spi_transfer_byte(lowByte(start_address)); // Address LSB Byte
}

void ltc2983_driver::finish_memory_read()
{
     set_cs_inactive();
}

// -----------------------------------------------------------------
//          Channel conversion
// -----------------------------------------------------------------
void ltc2983_driver::convert_channel(unsigned int channel_number)
{
  // initiate a new conversion
  initialize_memory_write(0);
  spi_driver->spi_transfer_byte(0b10000000 | channel_number); // start a conversion
  finish_memory_write();

  while (conversion_done()==0); // wait for conversion to complete
}

bool ltc2983_driver::conversion_done()
{
  initialize_memory_read(0);
  char data=spi_driver->spi_transfer_byte(0x00);
  finish_memory_read();
  return(data & 0b01000000);
}

// -----------------------------------------------------------------
//          Getting temperature results
// -----------------------------------------------------------------

float ltc2983_driver::read_temperature_results(int channel_number)
{
  unsigned char raw_results[4];
  get_raw_results(READ_CH_BASE, channel_number, raw_results);
  float signed_float = convert_to_signed_float(raw_results);
  float temperature_result = get_temperature(signed_float);
 // print_temperature_result(channel_number, temperature_result);
 // print_fault_data(raw_results[3]);
  return (temperature_result);
}

float ltc2983_driver::read_direct_adc_results(int channel_number)
{
  unsigned char raw_results[4];
  get_raw_results(READ_CH_BASE, channel_number, raw_results);
  float signed_float = convert_to_signed_float(raw_results);
  float direct_adc_reading = get_direct_adc_reading(signed_float);
  //print_direct_adc_reading(channel_number, direct_adc_reading);
  //print_fault_data(raw_results[3]);
  return (direct_adc_reading);
}

void ltc2983_driver::get_raw_results(long base_address, int channel_number, unsigned char results[4])
{
  long address = base_address+4*(channel_number-1);
  initialize_memory_read(address);

  results[3]=spi_driver->spi_transfer_byte(0x00); // fault data
  results[2]=spi_driver->spi_transfer_byte(0x00); // MSB result byte
  results[1]=spi_driver->spi_transfer_byte(0x00); // 2nd result byte
  results[0]=spi_driver->spi_transfer_byte(0x00); // LSB result byte

  finish_memory_read();
}

float ltc2983_driver::convert_to_signed_float(unsigned char results[4])
{
  // Get the last 24 bits of the results (the first 8 bits are status bits)
  long x = 0L;
  x= x | ((unsigned long) results[2]<<16)
     | ((unsigned long) results[1]<<8)
     | ((unsigned long) results[0]);

  // Convert a 24-bit two's complement number into a 32-bit two's complement number
  bool sign;
  if ((results[2]&0b10000000)==128) sign=true;
  else sign=false;
  if (sign) x=x | 0xFF000000;

  return float(x);
}

float ltc2983_driver::get_temperature(float x)
{
  // The temperature format is (14, 10) so we divide by 2^10
  return x/1024;
}

float ltc2983_driver::get_direct_adc_reading(float x)
{
  // The direct ADC format is (3, 21) so we divide by 2^21
  return x/2097152;
}

/*
// Translate the fault byte into usable fault data and print it out
void ltc2983_driver::print_fault_data(unsigned char fault_byte)
{
  Serial.print("  FAULT DATA=");
  Serial.println(fault_byte,BIN);

  if ((fault_byte&SENSOR_HARD_FAILURE)>0) Serial.println("*SENSOR HARD FALURE*");
  if ((fault_byte&ADC_HARD_FAILURE)>0) Serial.println("*ADC_HARD_FAILURE*");
  if ((fault_byte&CJ_HARD_FAILURE)>0) Serial.println("*CJ_HARD_FAILURE*");
  if ((fault_byte&CJ_SOFT_FAILURE)>0) Serial.println("*CJ_SOFT_FAILURE*");
  if ((fault_byte&SENSOR_ABOVE)>0) Serial.println("*SENSOR_ABOVE*");
  if ((fault_byte&SENSOR_BELOW)>0) Serial.println("*SENSOR_BELOW*");
  if ((fault_byte&ADC_RANGE_ERROR)>0) Serial.println("*ADC_RANGE_ERROR*");
  if ((fault_byte&VALID)!=1) Serial.println("!!!!!!! INVALID READING !!!!!!!!!");
  if (fault_byte==0b11111111) Serial.println("&&&&&&&&&& CONFIGURATION ERROR &&&&&&&&&&&&");
  Serial.println(" ");
}
*/
// -----------------------------------------------------------------
//    Getting raw results -
//    voltage (for thermocouples), resistance (for RTDs/thermistors)
// -----------------------------------------------------------------

float ltc2983_driver::read_voltage_or_resistance_results(int channel_number)
{
  unsigned char raw_results[4];
  get_raw_results(VOUT_CH_BASE, channel_number, raw_results);
  float signed_float = convert_vr_to_signed_float(raw_results);
  float voltage_or_resistance_result = get_voltage_or_resistance(signed_float);
  //print_voltage_or_resistance_result(channel_number, voltage_or_resistance_result);
  return (voltage_or_resistance_result);
}

float ltc2983_driver::convert_vr_to_signed_float(unsigned char results[4])
{
  long x = 0L;
  x= x | ((unsigned long) results[3]<<24)
     | ((unsigned long) results[2]<<16)
     | ((unsigned long) results[1]<<8)
     | ((unsigned long) results[0]);
  return float(x);
}

float ltc2983_driver::get_voltage_or_resistance(float x)
{
  // The format is (14, 10) so we divide by 2^10
  return x/1024;
}


// -----------------------------------------------------------------

// Find out if a number is an element in an array
bool ltc2983_driver::is_number_in_array(int number, int *array, int array_length)
{
  int i;
  bool found = false;
  for (i=0; i< array_length; i++)
  {
    if (number == array[i])
    {
      found = true;
    }
  }
  return found;
}

