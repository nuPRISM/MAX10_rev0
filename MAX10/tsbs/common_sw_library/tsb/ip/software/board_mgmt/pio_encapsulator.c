/*
 * pio_encapsulator.c
 *
 *  Created on: Jul 11, 2013
 *      Author: yairlinn
 */
#include "adc_mcs_basedef.h"
#include "pio_encapsulator.h"
#include "system.h"
#include "misc_utils.h"

unsigned long gpo_shadow_val[4] = {0,0,0,0};
void set_gpo_shadow_val(unsigned long regnum, unsigned long val)
{


	switch (regnum) {
	case 1:
	case 2:
	case 3:
	case 4: gpo_shadow_val[regnum-1] = val;
	        break;

	default: break; //do nothing, but this is a problem!
	}
}
void write_to_gpo_reg(unsigned long regnum, unsigned long val)
{
	switch (regnum) {
	case 1:
	case 2:
	case 3:
	case 4: IOWR(BOARDMANAGEMENT_0_GPO_BASE_ADDRESS, regnum, val);
	        set_gpo_shadow_val(regnum,val);
	        break;

	default: break; //do nothing, but this is a problem!

	}
}


unsigned long read_from_gpo_reg(unsigned long regnum)
{
	unsigned long retval;
	switch (regnum) {
	case 1:
	case 2:
	case 3:
	case 4: //retval = XIOModule_ReadReg(iomodule.BaseAddress,((regnum - 1) * XGPO_CHAN_OFFSET) + XGPO_DATA_OFFSET); break;
		retval = gpo_shadow_val[regnum-1];
		break;
	default: retval = 0xEAA; break; //do nothing, but this is a problem!

	}
	return retval;
}



unsigned long read_from_gpi_reg(unsigned long regnum)
{
	unsigned long retval;
	switch (regnum) {
	case 1:
	case 2:
	case 3:
	case 4: retval =  IORD(BOARDMANAGEMENT_0_GPI_BASE_ADDRESS,regnum); break;

	default: retval = 0xEAA; break; //do nothing, but this is a problem!

	}
	return retval;
}

unsigned long set_bit_in_gpo_reg(unsigned short regnum, unsigned short bit_num, unsigned short val)
{
	 unsigned long data = read_from_gpo_reg(regnum);
	 unsigned long new_data = set_bit_in_32bit_value(data,bit_num,val);
	 write_to_gpo_reg(regnum,new_data);
	 return new_data;
}

unsigned long read_from_io(unsigned long absolute_address) {
	unsigned long io_offset = absolute_address - START_OF_IO_REGION;
	unsigned long retval = IORD(0,io_offset);
	return retval;
}

void write_to_io(unsigned long absolute_address, unsigned long val) {
	unsigned long io_offset = absolute_address - START_OF_IO_REGION;
	IOWR(0,io_offset, val);
}
