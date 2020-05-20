/*
 * sfp_i2c.h
 *
 *  Created on: Jul 30, 2013
 *      Author: yairlinn
 */

#ifndef SFP_I2C_H_
#define SFP_I2C_H_

unsigned long read_from_sfp_reg(unsigned int address);
unsigned long read_from_sfp_msa(unsigned int address);
unsigned long write_sfp_reg(unsigned int address, unsigned int data);
unsigned long read_from_mac_eeprom(unsigned int address);
unsigned long write_sfp_msa(unsigned int address, unsigned int data);
unsigned long write_mac_eeprom(unsigned int address, unsigned int data);

#endif /* SFP_I2C_H_ */
