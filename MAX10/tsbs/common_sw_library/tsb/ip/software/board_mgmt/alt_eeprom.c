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
#include <drivers/inc/i2c_opencores_regs.h>
#include <drivers/inc/i2c_opencores.h>

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  I2C OpenCores Support
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////


int i2c_write_bytes(unsigned long base, unsigned long i2c_7bit_addr, int addr, unsigned char* data,int n){

	int i;

	/* Start and write mode */
	I2C_start(base,i2c_7bit_addr,0);

	/* Address */
		I2C_write(base,0xFF & addr,0);

	for(i=0;i<(n-1);i++){
		I2C_write(base,*data++,0);
	}

	I2C_write(base,*data,1);

	return 0;
}


int i2c_write_byte(unsigned long base, unsigned long i2c_7bit_addr,int addr, unsigned char data){

	int retval;

	retval = i2c_write_bytes(base,i2c_7bit_addr,addr,&data,1);

	return retval;
}


int i2c_read_bytes(unsigned long base, unsigned long i2c_7bit_addr,int addr, unsigned  char *data,int n){

	int i;

	/* Start and write mode */
	I2C_start(base,i2c_7bit_addr,I2C_OPENCORES_WRITE_CONST);

	/* Address */
		I2C_write(base,0xFF & addr,I2C_OPENCORES_WRITE_CONST);

	/* Start again in read mode */
		I2C_start(base,i2c_7bit_addr,I2C_OPENCORES_READ_CONST);

		for(i=0;i<(n-1);i++){

			*data++ =  I2C_read(base,0);  // read the input register and send stop

		}

		*data = I2C_read(base,1);

		return 0;

}


int i2c_read_byte(unsigned long base, unsigned long i2c_7bit_addr,int addr, unsigned char*data){

	int retval;

	retval = i2c_read_bytes(base,i2c_7bit_addr,addr, data,1);

	return retval;
}


int readRandom_using_opencores_i2c(struct device *device, unsigned int address, unsigned char *buf, int len) {
    return (i2c_read_bytes(device->BaseAdress, device->i2c_7bit_address, address, buf, len));
}

int writeRandom_using_opencores_i2c(struct device *device, unsigned int address, unsigned char *buf, int len) {
	return(i2c_write_bytes (device->BaseAdress, device->i2c_7bit_address, address, buf, len));
}

