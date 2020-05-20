/*
 * ltc2655_device_driver.cpp
 *
 *  Created on: Feb 17, 2014
 *      Author: yairlinn
 */

#include "ltc2655/ltc2655_device_driver.h"
#include <math.h>
#include <vector>

ltc2655_device_driver::ltc2655_device_driver() {
	// TODO Auto-generated constructor stub

}


// Write the dac_command byte and 16-bit dac_code to the LTC2655.
// The function returns the state of the acknowledge bit after the I2C address write. 0=acknowledge, 1=no acknowledge.
int8_t ltc2655_device_driver::LTC2655_write(uint8_t i2c_address, uint8_t dac_command, uint8_t dac_address, uint16_t dac_code)
{
  int8_t ack;
 std::vector<uint8_t> data_vector;
 /*data_vector.push_back()
  ack = this->i2c_device_driver_inst->I2C_driver_write_vector
		  (i2c_address, dac_command | dac_address, dac_code);*/
  return(ack);
}

// Calculate a LTC2655 DAC code given the desired output voltage and DAC address (0-3)
uint16_t ltc2655_device_driver::LTC2655_voltage_to_code(float dac_voltage, float LTC2655_lsb, int16_t LTC2655_offset)
{
  int32_t dac_code;
  float float_code;
  float_code = dac_voltage / LTC2655_lsb;                                                             //! 1) Calculate the DAC code
  float_code = (float_code > (floor(float_code) + 0.5)) ? ceil(float_code) : floor(float_code);       //! 2) Round
  dac_code = (int32_t)float_code - LTC2655_offset;                                                    //! 3) Subtract offset
  if (dac_code < 0)                                                                                   //! 4) If DAC code < 0, Then DAC code = 0
    dac_code = 0;
  return ((uint16_t)dac_code);                                                                        //! 5) Cast DAC code as uint16_t
}

// Calculate the LTC2655 DAC output voltage given the DAC code and DAC address (0-3)
float ltc2655_device_driver::LTC2655_code_to_voltage(uint16_t dac_code, float LTC2655_lsb, int16_t LTC2655_offset)
{
  float dac_voltage;
  dac_voltage = ((float)(dac_code + LTC2655_offset)* LTC2655_lsb);                                    //! 1) Calculates the dac_voltage
  return (dac_voltage);
}

// Calculate the LTC2655 offset and LSB voltage given two measured voltages and their corresponding codes
void ltc2655_device_driver::LTC2655_calibrate(uint16_t dac_code1, uint16_t dac_code2, float voltage1, float voltage2, float *LTC2655_lsb, int16_t *LTC2655_offset)
{
  float temp_offset;
  *LTC2655_lsb = (voltage2 - voltage1) / ((float) (dac_code2 - dac_code1));                           //! 1) Calculate the LSB
  temp_offset = (voltage1/(*LTC2655_lsb) - (float)dac_code1);                                         //! 2) Calculate the offset
  temp_offset = (temp_offset > (floor(temp_offset) + 0.5)) ? ceil(temp_offset) : floor(temp_offset);  //! 3) Round offset
  *LTC2655_offset = (int16_t)temp_offset;                                                             //! 4) Cast as int16_t
}
