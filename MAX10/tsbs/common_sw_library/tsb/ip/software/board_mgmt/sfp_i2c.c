/*
 * sfp_i2c.c
 *
 *  Created on: Jul 30, 2013
 *      Author: yairlinn
 */

#include "adc_mcs_basedef.h"
#include <xprintf.h>
#include "rsscanf.h"
#include "misc_str_utils.h"
#include <string.h>
#include "misc_utils.h"

#include "pio_encapsulator.h"
//#include "internal_command_parser.h"
#include <stdlib.h>
#include <string.h>
#include "drv_spi.h"
#include "per_spi.h"
#include "alt_eeprom.h"
#include "sfp_i2c.h"
#include <drivers/inc/i2c_opencores_regs.h>
#include <drivers/inc/i2c_opencores.h>


struct device devices[] = {
    {BOARDMANAGEMENT_0_FMC_I2C_BASE, 0, 0x50, 1,   0x100,   0xA0,   0xA1    },
    {BOARDMANAGEMENT_0_PMBUS_BASE , 6, 0x56, 2,   0x100,   0xAC,   0xAD    }

};

struct device *SFP_MSA_device  = &(devices[0]);
struct device *SFP_REGs_device = &(devices[1]);
struct device *SFP_LEDMAC_device = &(devices[1]);


unsigned long read_from_sfp_reg(unsigned int address) {
	unsigned char buf[2];
	int retval;
	retval = readRandom_using_opencores_i2c(SFP_REGs_device, address, buf, 2);
	if (retval != 0) {
		return 0xEAA;
	}
	unsigned long read_val;
	read_val = ((((unsigned long) buf[0]) << 8) + ((unsigned long) buf[1]))& 0xFFFF;
    return read_val;
}

unsigned long write_sfp_reg(unsigned int address, unsigned int data) {
	unsigned char buf[2];
	int retval;
	buf[1] = ((unsigned char) (data & 0xFF));
	buf[0] = ((unsigned char) ((data >> 8) & 0xFF));
	retval = writeRandom_using_opencores_i2c(SFP_REGs_device, address, buf, 2);

	if (retval != 0) {
		return (0xEAA + ((retval & 0xF) << 12));
	} else {
	   return 0;
	}
}


unsigned long read_from_sfp_msa(unsigned int address) {
	unsigned char buf[1];
	int retval;
	retval = readRandom_using_opencores_i2c(SFP_MSA_device, address, buf, 1);

	if (retval != 0)  {
		return 0xEAA;
	}
	unsigned long read_val;
	read_val = ((unsigned long) buf[0]) & 0xFF;
    return read_val;
}


unsigned long write_sfp_msa(unsigned int address, unsigned int data) {
	unsigned char buf[1];
	int retval;
	buf[0] = ((unsigned char) (data & 0xFF));
	retval = writeRandom_using_opencores_i2c(SFP_MSA_device, address, buf, 1);

	if (retval != 0) {
		return (0xEAA + ((retval & 0xF) << 12));
	} else {
	   return 0;
	}
}

unsigned long read_from_mac_eeprom(unsigned int address) {
	unsigned char buf[1];
	int retval;
	retval = readRandom_using_opencores_i2c(SFP_LEDMAC_device, address, buf, 1);

	if (retval != 0)  {
		return 0xEAA;
	}
	unsigned long read_val;
	read_val = ((unsigned long) buf[0]) & 0xFF;
    return read_val;
}


unsigned long write_mac_eeprom(unsigned int address, unsigned int data) {
	unsigned char buf[1];
	int retval;
	buf[0] = ((unsigned char) (data & 0xFF));
	retval = writeRandom_using_opencores_i2c(SFP_LEDMAC_device, address, buf, 1);

	if (retval != 0) {
		return (0xEAA + ((retval & 0xF) << 12));
	} else {
	   return 0;
	}
}
