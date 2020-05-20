/*
 * register_keeper_api.h
 *
 *  Created on: Apr 13, 2011
 *      Author: linnyair
 */

#ifndef REGISTER_KEEPER_API_H_
#define REGISTER_KEEPER_API_H_
#include "linnux_testbench_constants.h"

void write_value_to_reg_keeper_reg(unsigned int address, unsigned long data);
unsigned long read_value_from_reg_keeper_reg(unsigned int address);
void write_PCBI_reg(unsigned int address, unsigned long data);
unsigned long read_PCBI_reg(unsigned int address);
void set_large_mux_selector(unsigned long sel);
unsigned long read_large_mux_input_data(unsigned long sel);
unsigned long read_DUT_GP_CONTROL_reg(unsigned long address);
void write_DUT_GP_CONTROL_reg(unsigned long address, unsigned long data);
unsigned long read_DUT_GP_STATUS_reg(unsigned long address);
unsigned long long get_64_bit_value_from_large_mux(unsigned long low_32bit_address);

#endif /* REGISTER_KEEPER_API_H_ */
