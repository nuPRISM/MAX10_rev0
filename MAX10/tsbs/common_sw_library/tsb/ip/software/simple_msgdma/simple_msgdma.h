/*
 * simple_msgdma.h
 *
 *  Created on: Apr 29, 2015
 *      Author: yairlinn
 */

#ifndef SIMPLE_MSGDMA_H_
#define SIMPLE_MSGDMA_H_
#include "basedef.h"
#include "altera_msgdma_descriptor_regs.h"
#include "altera_msgdma_csr_regs.h"
#include "altera_msgdma_response_regs.h"
#include "io.h"
#include "altera_msgdma.h"
#include <priv/alt_busy_sleep.h>
#include "sys/alt_errno.h"
#include "sys/alt_irq.h"
#include "sys/alt_stdio.h"
#include <string>

namespace simple_msgdma {

const unsigned int NUM_US_TO_WAIT_FOR_CSR_OPERATION = 100000;

class simple_msgdma {
protected:
	std::string device_name;
	alt_msgdma_dev* device_ptr;
	alt_u32 control_word;
	alt_u32 async_control_word;

public:
	simple_msgdma();
	simple_msgdma(std::string device_name);
	alt_msgdma_dev*  open();
	virtual ~simple_msgdma();
	const std::string& get_device_name() const {
		return device_name;
	}
	int wait_until_not_busy(alt_u32 timeout_us);
	int simple_wait_until_not_busy();

	bool do_sw_reset();
	bool start();

	void set_device_name(const std::string& deviceName) {
		device_name = deviceName;
	}

	alt_msgdma_dev* get_device_ptr() const {
		return device_ptr;
	}

	void set_device_ptr(alt_msgdma_dev* devicePtr) {
		device_ptr = devicePtr;
	}

	alt_u32 get_control_word() const {
		return control_word;
	}

	void set_control_word(alt_u32 controlWord) {
		control_word = controlWord;
	}

	alt_u32 get_async_control_word() const {
		return async_control_word;
	}

	void set_async_control_word(alt_u32 asyncControlWord) {
		async_control_word = asyncControlWord;
	}
};


class simple_msgdma_mm_to_st_encapsulator : public simple_msgdma {
protected:
	alt_msgdma_standard_descriptor work_descriptor;

public:
	simple_msgdma_mm_to_st_encapsulator();
	simple_msgdma_mm_to_st_encapsulator(std::string device_name);

	int execute(unsigned long addr, unsigned long length_in_bytes);
	int execute_async(unsigned long addr, unsigned long length_in_bytes, bool silent = false);
	int silent_execute_async(unsigned long addr, unsigned long length_in_bytes);


};

class simple_msgdma_mm_to_mm_encapsulator : public simple_msgdma {
protected:
	alt_msgdma_standard_descriptor work_descriptor;

public:
	simple_msgdma_mm_to_mm_encapsulator();
	simple_msgdma_mm_to_mm_encapsulator(std::string device_name);

	int execute(unsigned long source_addr, unsigned long dest_addr, unsigned long length_in_bytes);
	int execute_async(unsigned long source_addr, unsigned long dest_addr, unsigned long length_in_bytes);


};

} /* namespace msgdma */

#endif /* simple_msgdma_H_ */
