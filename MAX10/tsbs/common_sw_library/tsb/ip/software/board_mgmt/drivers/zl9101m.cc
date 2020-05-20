/*
 * $Id$
 *
 *  Created on: Sept 17, 2012
 *  Created by: Chris Ohlmann
 */

/**
 *  Description
 */

#include "zl9101m.h"

extern "C" {
#include <drivers/inc/i2c_opencores_regs.h>
#include <drivers/inc/i2c_opencores.h>
#include "includes.h"
#include "ucos_ii.h"
}

#include <string>
///
//TODO: check if add OS_CRITICAL blocks to avoid timeouts on I2C

void ZL9101M_SendByte(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code) {
	int cpu_sr;
	//OS_ENTER_CRITICAL();
	OSSchedLock();
	if(I2C_start(i2c_base, device_addr, I2C_OPENCORES_TXR_WR_MSK) == I2C_ACK) {
		I2C_write(i2c_base, cmd_code, 1);
		//OS_EXIT_CRITICAL();
		OSSchedUnlock();

	} else {
		//OS_EXIT_CRITICAL();
		OSSchedUnlock();

		safe_print(std::cout << "[ZL9101M_SendByte] Error: Did not receive ACK in write of to base: 0x" << std::hex << i2c_base <<  " Device addr: 0x"  << (unsigned int) device_addr << " Cmd code: 0x" << (unsigned int)  cmd_code << std::dec << std::endl);
	}
}


void ZL9101M_WriteByte(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code, alt_u8 data) {
	int cpu_sr;
	//OS_ENTER_CRITICAL();
	OSSchedLock();
	if(I2C_start(i2c_base, device_addr, I2C_OPENCORES_TXR_WR_MSK) == I2C_ACK) {
		I2C_write(i2c_base, cmd_code, 0);
		I2C_write(i2c_base, data, 1);
		OSSchedUnlock();
		//OS_EXIT_CRITICAL();

	}  else {
		OSSchedUnlock();

		//OS_EXIT_CRITICAL();

		safe_print(std::cout << "[ZL9101M_WriteByte] Error: Did not receive ACK in write of to base: 0x" << std::hex << i2c_base <<  " Device addr: 0x"  << (unsigned int) device_addr << " Cmd code: 0x" << (unsigned int)  cmd_code << std::dec << std::endl);
	}
}


void ZL9101M_WriteWord(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code, alt_u16 data) {
	int cpu_sr;
	//OS_ENTER_CRITICAL();
	OSSchedLock();

	if(I2C_start(i2c_base, device_addr, I2C_OPENCORES_TXR_WR_MSK) == I2C_ACK) {
		I2C_write(i2c_base, cmd_code, 0);
		I2C_write(i2c_base, data & 0x00FF, 0);  // Send Low Byte
		I2C_write(i2c_base, (data & 0xFF00)>>8, 1);  // Send High Byte w/ LAST flag to generate stop
		OSSchedUnlock();

		//OS_EXIT_CRITICAL();
	} else {
		OSSchedUnlock();

		//OS_EXIT_CRITICAL();
		safe_print(std::cout << "[ZL9101M_WriteWord] Error: Did not receive ACK in write of to base: 0x" << std::hex << i2c_base <<  " Device addr: 0x"  << (unsigned int) device_addr << " Cmd code: 0x" << (unsigned int)  cmd_code << std::dec << std::endl);
	}
}
void ZL9101M_WriteDoubleWord(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code, alt_u32 data) {
	int cpu_sr;
	//OS_ENTER_CRITICAL();
	OSSchedLock();

	if(I2C_start(i2c_base, device_addr, I2C_OPENCORES_TXR_WR_MSK) == I2C_ACK) {
		I2C_write(i2c_base, cmd_code, 0);
		I2C_write(i2c_base, 4, 0);
		I2C_write(i2c_base, data & 0x00FF, 0);  // Send Low Byte
		I2C_write(i2c_base, (data & 0xFF00)>>8, 0);
		I2C_write(i2c_base, (data & 0xFF0000)>>16, 0);
		I2C_write(i2c_base, (data & 0xFF000000)>>24, 1);  // Send High Byte w/ LAST flag to generate stop
		//OS_EXIT_CRITICAL();
		OSSchedUnlock();

	} else {
		//OS_EXIT_CRITICAL();
		OSSchedUnlock();

		safe_print(std::cout << "[ZL9101M_WriteDoubleWord] Error: Did not receive ACK in write of to base: 0x" << std::hex << i2c_base <<  " Device addr: 0x"  <<(unsigned int) device_addr << " Cmd code: 0x" << (unsigned int)  cmd_code << std::dec << std::endl);
	}
}


alt_u8 ZL9101M_ReadByte(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code) {
	alt_u8 data = 0;
	int cpu_sr;
	//OS_ENTER_CRITICAL();
	OSSchedLock();

	if(I2C_start(i2c_base, device_addr, I2C_OPENCORES_TXR_WR_MSK) == I2C_ACK) {
		I2C_write(i2c_base, cmd_code, 0);
		I2C_start(i2c_base, device_addr, I2C_OPENCORES_TXR_RD_MSK);
		data = I2C_read(i2c_base, 1);
		OSSchedUnlock();

		//OS_EXIT_CRITICAL();
	} else {
		//OS_EXIT_CRITICAL();
		OSSchedUnlock();

		safe_print(std::cout << "[ZL9101M_ReadByte] Error: Did not receive ACK in write of to base: 0x" << std::hex << i2c_base <<  " Device addr: 0x"  <<(unsigned int) device_addr << " Cmd code: 0x" << (unsigned int)  cmd_code << std::dec << std::endl);
	}

	return data;
}


alt_u16	ZL9101M_ReadWord(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code) {
	alt_u16 data = 0;
	int cpu_sr;
	//OS_ENTER_CRITICAL();
	OSSchedLock();

	if(I2C_start(i2c_base, device_addr, I2C_OPENCORES_TXR_WR_MSK) == I2C_ACK) {
		I2C_write(i2c_base, cmd_code, 0);
		I2C_start(i2c_base, device_addr, I2C_OPENCORES_TXR_RD_MSK);
		data  = I2C_read(i2c_base, 0);
		data |= I2C_read(i2c_base, 1) << 8;
		OSSchedUnlock();

		//OS_EXIT_CRITICAL();
	} else {
		//OS_EXIT_CRITICAL();
		OSSchedUnlock();

		safe_print(std::cout << "[ZL9101M_ReadWord] Error: Did not receive ACK in write of to base: 0x" << std::hex << i2c_base <<  " Device addr: 0x"  <<(unsigned int) device_addr << " Cmd code: 0x" << (unsigned int)  cmd_code << std::dec << std::endl);
	}

	return data;
}


alt_u32	ZL9101M_ReadDoubleWord(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code) {
	alt_u16 data = 0;
	int cpu_sr;
	//OS_ENTER_CRITICAL();
	OSSchedLock();

	if(I2C_start(i2c_base, device_addr, I2C_OPENCORES_TXR_WR_MSK) == I2C_ACK) {
		I2C_write(i2c_base, cmd_code, 0);
		I2C_start(i2c_base, device_addr, I2C_OPENCORES_TXR_RD_MSK);
		data  = I2C_read(i2c_base, 0); //discard first word - should be 4
		data  = I2C_read(i2c_base, 0);
		data |= I2C_read(i2c_base, 0) << 8 ;
		data |= I2C_read(i2c_base, 0) << 16 ;
		data |= I2C_read(i2c_base, 1) << 24;
		OSSchedUnlock();

		//OS_EXIT_CRITICAL();
	} else {
		//OS_EXIT_CRITICAL();
		OSSchedUnlock();

		safe_print(std::cout << "[ZL9101M_ReadDoubleWord] Error: Did not receive ACK in write of to base: 0x" << std::hex << i2c_base <<  " Device addr: 0x"  <<(unsigned int) device_addr << " Cmd code: 0x" << (unsigned int)  cmd_code << std::dec << std::endl);
	}

	return data;
}

void ZL9101M_ReadBlock(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code, std::string& data, alt_u32 data_len) {
	alt_u32 num_bytes;
	alt_u32 n;
	alt_u8  last;

	last = 0;
	int cpu_sr;
	//OS_ENTER_CRITICAL();
	OSSchedLock();

	if(I2C_start(i2c_base, device_addr, I2C_OPENCORES_TXR_WR_MSK) == I2C_ACK) {
		I2C_write(i2c_base, cmd_code, 0);
		I2C_start(i2c_base, device_addr, I2C_OPENCORES_TXR_RD_MSK);
		num_bytes = I2C_read(i2c_base, 0);
		for(n = 0; (n < num_bytes) && (n < data_len); ++n) {
			if((n == num_bytes-1) || (n == data_len-1)) {
				last = 1;
			}
			data.append(1,(char) (I2C_read(i2c_base, last) & 0xFF));
		}
		OSSchedUnlock();

		//OS_EXIT_CRITICAL();
	} else {
		OSSchedUnlock();

		//OS_EXIT_CRITICAL();
		 safe_print(std::cout << "[ZL9101M_ReadBlock] Error: Did not receive ACK in write of to base: 0x" << std::hex << i2c_base <<  " Device addr: 0x"  <<(unsigned int) device_addr << " Cmd code: 0x" << (unsigned int)  cmd_code << std::dec << " data len " << data_len << std::endl);
	}
}

void ZL9101M_WriteBlock(alt_u32 i2c_base, alt_u8 device_addr, alt_u8 cmd_code, char data[], alt_u32 data_len) {
	alt_u32 n;
	alt_u8  last;

	last = 0;
	int cpu_sr;
	OSSchedLock();

	//OS_ENTER_CRITICAL();
	if(I2C_start(i2c_base, device_addr, I2C_OPENCORES_TXR_WR_MSK) == I2C_ACK) {
		I2C_write(i2c_base, cmd_code, 0);
		I2C_write(i2c_base, data_len & 0xFF, 0);
		for(n = 0; (n < data_len); ++n) {
			if(n == data_len-1) { last = 1; }
			I2C_write(i2c_base, data[n] & 0xFF, last);
		}
		OSSchedUnlock();

		//OS_EXIT_CRITICAL();
	} else {
		OSSchedUnlock();

		//OS_EXIT_CRITICAL();
          safe_print(std::cout << "[ZL9101M_WriteBlock] Error: Did not receive ACK in write of to base: 0x" << std::hex << i2c_base << " Device addr: 0x"  << (unsigned int) device_addr << " Cmd code: 0x" << (unsigned int) cmd_code << std::dec << " data len " << data_len << std::endl);

	}
}

// Higher Level Functions

/* ADD EXTRA FUNCTIONS HERE */
