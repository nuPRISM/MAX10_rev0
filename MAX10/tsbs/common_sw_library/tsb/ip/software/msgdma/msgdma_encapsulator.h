/*
 * msgdma_encapsulator.h
 *
 *  Created on: Apr 29, 2015
 *      Author: yairlinn
 */

#ifndef MSGDMA_ENCAPSULATOR_H_
#define MSGDMA_ENCAPSULATOR_H_
#include "basedef.h"
#include "altera_msgdma_descriptor_regs.h"
#include "altera_msgdma_csr_regs.h"
#include "altera_msgdma_response_regs.h"
#include "io.h"
#include "altera_msgdma.h"
#include "priv/alt_busy_sleep.h"
#include "sys/alt_errno.h"
#include "sys/alt_irq.h"
#include "sys/alt_stdio.h"
#include <string>

namespace msgdma {

const unsigned int NUM_US_TO_WAIT_FOR_CSR_OPERATION = 100000;

class msgdma_encapsulator {
protected:
	std::string device_name;
	alt_msgdma_dev* device_ptr;
	alt_u32 control_word;
	alt_u32 async_control_word;

public:
	msgdma_encapsulator();
	msgdma_encapsulator(std::string device_name);
	alt_msgdma_dev*  open();
	virtual ~msgdma_encapsulator();
	const std::string& get_device_name() const {
		return device_name;
	}

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


class msgdma_mm_to_st_encapsulator : public msgdma_encapsulator {
protected:
	alt_msgdma_standard_descriptor work_descriptor;

public:
	msgdma_mm_to_st_encapsulator();
	msgdma_mm_to_st_encapsulator(std::string device_name);

	int execute(unsigned long addr, unsigned long length_in_words);
	int execute_async(unsigned long addr, unsigned long length_in_words, bool silent = false);
	int silent_execute_async(unsigned long addr, unsigned long length_in_words);


};

class msgdma_mm_to_mm_encapsulator : public msgdma_encapsulator {
protected:
	alt_msgdma_standard_descriptor work_descriptor;

public:
	msgdma_mm_to_mm_encapsulator();
	msgdma_mm_to_mm_encapsulator(std::string device_name);

	int execute(unsigned long source_addr, unsigned long dest_addr, unsigned long length_in_words);
	int execute_async(unsigned long source_addr, unsigned long dest_addr, unsigned long length_in_words);


};

} /* namespace msgdma */

#endif /* MSGDMA_ENCAPSULATOR_H_ */
