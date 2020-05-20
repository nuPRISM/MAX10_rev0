/*
 * hw_checksum_accellerator.h
 *
 *  Created on: Jan 20, 2012
 *      Author: linnyair
 */

#ifndef HW_CHECKSUM_ACCELLERATOR_H_
#define HW_CHECKSUM_ACCELLERATOR_H_

#include <stdio.h>
#include <stdlib.h>
#include <alt_types.h>
#include <sys/alt_cache.h>
#include "sys/alt_irq.h"
#include "system.h"
#include "checksum_controller_routines.h"
#include "checksum_controller_regs.h"

#define BUFFER_LENGTH     64*1024   /* buffer size in bytes, do not exceed 64kB to ensure software checksum returns correct result (software checksum based on the internet checksum RFC 1071 which can't handle 32 bit rollover efficiently) */
#define CHECKSUM_INTERRUPT_ENABLE  0         /* set to 0 to use the polled version of the hardware accelerator */
#define HW_CHECKSUM_WATCHDOG_LIMIT  100000
#define CHECKSUM_BASE CONTROLLER_BLOCK_BASE //rename this according to the name showed in system.h
#define CHECKSUM_IRQ CONTROLLER_BLOCK_IRQ

int init_checksum();
unsigned short hw_checksum (void *ptr, unsigned words);
unsigned short sw_checksum(unsigned short * addr, int count);
void set_buf_val(alt_u8* buffer, int length);

#endif /* HW_CHECKSUM_ACCELLERATOR_H_ */
