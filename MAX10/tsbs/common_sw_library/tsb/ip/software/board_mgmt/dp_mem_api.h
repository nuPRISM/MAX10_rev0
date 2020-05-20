/*
 * dp_mem_read.h
 *
 *  Created on: Mar 8, 2012
 *      Author: linnyair
 */

#ifndef DP_MEM_READ_H_
#define DP_MEM_READ_H_

extern unsigned long read_32_bits_from_dp_mem(unsigned long);
extern void write_32_bits_to_dp_mem(unsigned long address,unsigned long data);

#endif /* DP_MEM_READ_H_ */
