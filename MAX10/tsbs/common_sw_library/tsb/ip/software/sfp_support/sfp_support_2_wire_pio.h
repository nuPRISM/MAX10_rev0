/*
 * sfp_support_2_wire_pio.h
 *
 *  Created on: May 30, 2014
 *      Author: yairlinn
 */

#ifndef SFP_SUPPORT_2_WIRE_PIO_H_
#define SFP_SUPPORT_2_WIRE_PIO_H_

void sfp_reg_write_alt_2_wire (void *additional_data,int address, int data);
int  sfp_reg_read_alt_2_wire (void *additional_data,int address);

#endif /* SFP_SUPPORT_2_WIRE_PIO_H_ */
