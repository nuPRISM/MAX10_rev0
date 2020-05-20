/*
 * ltc2655_device_driver.h
 *
 *  Created on: Feb 17, 2014
 *      Author: yairlinn
 */

#ifndef LTC2655_DEVICE_DRIVER_H_
#define LTC2655_DEVICE_DRIVER_H_

#include "i2c_device_driver.h"


//! @name I2C_Addresses
//!@{
// I2C Address Choices:
// To choose an address, comment out all options except the
// configuration on the demo board.

//  Address assignment
// LTC2655 I2C Address                //  AD2       AD1       AD0
#define LTC2655_I2C_ADDRESS 0x10      //  GND       GND       GND
// #define LTC2655_I2C_ADDRESS 0x11    //  GND       GND       Float
// #define LTC2655_I2C_ADDRESS 0x12    //  GND       GND       Vcc
// #define LTC2655_I2C_ADDRESS 0x13    //  GND       Float     GND
// #define LTC2655_I2C_ADDRESS 0x20    //  GND       Float     Float
// #define LTC2655_I2C_ADDRESS 0x21    //  GND       Float     Vcc
// #define LTC2655_I2C_ADDRESS 0x22    //  GND       Vcc       GND
// #define LTC2655_I2C_ADDRESS 0x23    //  GND       Vcc       Float
// #define LTC2655_I2C_ADDRESS 0x30    //  GND       Vcc       Vcc
// #define LTC2655_I2C_ADDRESS 0x31    //  Float     GND       GND
// #define LTC2655_I2C_ADDRESS 0x32    //  Float     GND       Float
// #define LTC2655_I2C_ADDRESS 0x33    //  Float     GND       Vcc
// #define LTC2655_I2C_ADDRESS 0x40    //  Float     Float     GND
// #define LTC2655_I2C_ADDRESS 0x41    //  Float     Float     Float
// #define LTC2655_I2C_ADDRESS 0x42    //  Float     Float     Vcc
// #define LTC2655_I2C_ADDRESS 0x43    //  Float     Vcc       GND
// #define LTC2655_I2C_ADDRESS 0x50    //  Float     Vcc       Float
// #define LTC2655_I2C_ADDRESS 0x51    //  Float     Vcc       Vcc
// #define LTC2655_I2C_ADDRESS 0x52    //  Vcc       GND       GND
// #define LTC2655_I2C_ADDRESS 0x53    //  Vcc       GND       Float
// #define LTC2655_I2C_ADDRESS 0x60    //  Vcc       GND       Vcc
// #define LTC2655_I2C_ADDRESS 0x61    //  Vcc       Float     GND
// #define LTC2655_I2C_ADDRESS 0x62    //  Vcc       Float     Float
// #define LTC2655_I2C_ADDRESS 0x63    //  Vcc       Float     Vcc
// #define LTC2655_I2C_ADDRESS 0x70    //  Vcc       Vcc       GND
// #define LTC2655_I2C_ADDRESS 0x71    //  Vcc       Vcc       Float
// #define LTC2655_I2C_ADDRESS 0x72    //  Vcc       Vcc       Vcc

#define LTC2655_I2C_GLOBAL_ADDRESS  0x73
//! @}

//! @name LTC2655 Command Codes
//! @{
//! OR'd together with the DAC address to form the command byte
#define  LTC2655_CMD_WRITE               0x00   // Write to input register n
#define  LTC2655_CMD_UPDATE              0x10   // Update (power up) DAC register n
#define  LTC2655_CMD_WRITE_UPDATE        0x30   // Write to input register n, update (power up) all
#define  LTC2655_CMD_POWER_DOWN          0x40   // Power down n
#define  LTC2655_CMD_POWER_DOWN_ALL      0x50   // Power down chip (all DACs and reference)
#define  LTC2655_CMD_INTERNAL_REFERENCE  0x60   // Select internal reference (power up reference)
#define  LTC2655_CMD_EXTERNAL_REFERENCE  0x70   // Select external reference (power down internal reference)
#define  LTC2655_CMD_NO_OPERATION        0xF0   // No operation
//! @}

//! @name LTC2655 DAC Addresses
//! @{
//! Which DAC to operate on
#define  LTC2655_DAC_A     0x00
#define  LTC2655_DAC_B     0x01
#define  LTC2655_DAC_C     0x02
#define  LTC2655_DAC_D     0x03
#define  LTC2655_DAC_ALL   0x0F
//! @}

// Command Example - write to DAC address D and update all.
// dac_command = LTC2655_CMD_WRITE_UPDATE | LTC2655_DAC_D;


class ltc2655_device_driver {
protected:
	i2c_device_driver* i2c_device_driver_inst;
public:
	ltc2655_device_driver();


	//! Write a 16-bit dac_code to the LTC2655.
	//! @return ACK bit (0=acknowledge, 1=no acknowledge)
	int8_t  LTC2655_write(uint8_t  i2c_address,                   //!< I2C address of DAC
	                      uint8_t  dac_command,                   //!< Command Nibble, left-justified, lower nibble set to zero
	                      uint8_t  dac_address,                   //!< DAC Address Nibble, right justified, upper nibble set to zero
	                      uint16_t dac_code                       //!< 16-bit DAC code
	                     );

	//! Calculate a LTC2655 DAC code given the desired output voltage
	//! @return The 16-bit code to send to the DAC
	uint16_t LTC2655_voltage_to_code(float dac_voltage,       //!< Voltage to send to DAC
	                                 float LTC2655_lsb,       //!< LSB value
	                                 int16_t LTC2655_offset   //!< Offset
	                                );

	//! Calculate the LTC2655 DAC output voltage given the DAC code, offset, and LSB value
	//! @return Calculated voltage
	float LTC2655_code_to_voltage(uint16_t dac_code,          //!< DAC code
	                              float LTC2655_lsb,          //!< LSB value
	                              int16_t LTC2655_offset      //!< Offset
	                             );

	//! Calculate the LTC2655 offset and LSB voltages given two measured voltages and their corresponding codes
	//! @return Void
	void LTC2655_calibrate(uint16_t dac_code1,                //!< First DAC code
	                       uint16_t dac_code2,                //!< Second DAC code
	                       float voltage1,                    //!< First voltage
	                       float voltage2,                    //!< Second voltage
	                       float *LTC2655_lsb,                //!< Returns resulting LSB
	                       int16_t *LTC2655_offset            //!< Returns resulting Offset
	                      );


	i2c_device_driver* get_i2c_device_driver_inst() const {
		return i2c_device_driver_inst;
	}

	void set_i2c_device_driver_inst(i2c_device_driver* i2cDeviceDriverInst) {
		i2c_device_driver_inst = i2cDeviceDriverInst;
	}
};

#endif /* LTC2655_DEVICE_DRIVER_H_ */
