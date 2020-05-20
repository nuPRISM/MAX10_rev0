/*
 * smart_buffer.h
 *
 *  Created on: Apr 29, 2015
 *      Author: yairlinn
 */

#ifndef SMART_BUFFER_H_
#define SMART_BUFFER_H_
#include "basedef.h"
#include "io.h"
#include "priv/alt_busy_sleep.h"
#include "sys/alt_errno.h"
#include "sys/alt_irq.h"
#include "sys/alt_stdio.h"
#include <string>
#include <vector>

namespace smartbuf {

const unsigned int buffer_safety_margin_in_bytes = 100;
class smart_buffer {
protected:
	unsigned long size;
    alt_u32* bufptr;



public:
	smart_buffer();
	smart_buffer(unsigned long size);

	virtual ~smart_buffer();

	void set_bufptr(alt_u32* bufptr) {
			this->bufptr = bufptr;
	}

	alt_u32* get_bufptr() const {
		return bufptr;
	}

	void allocate();


	unsigned long get_size() const {
		return size;
	}

	void set_size(unsigned long size) {
		this->size = size;
	}
};



class smart_buffer_repository {
	protected:
		unsigned long num_bufs;
		unsigned long size_per_buf;
		std::vector<smart_buffer> buf_vector;
		unsigned long num_on_chip_bufs;
		void allocate();

		void set_buf_vector(const std::vector<smart_buffer>& bufVector) {
			buf_vector = bufVector;
		}

	public:
		smart_buffer_repository();
		smart_buffer_repository(unsigned long num_total_bufs,
				 unsigned long num_on_chip_bufs,
				 unsigned long on_chip_mem_base_address,
				 unsigned long size_per_buf_in_words);

		alt_u32* get_buffer(unsigned long index);
		alt_u32* silent_get_buffer(unsigned long index);

		unsigned long get_num_bufs() const {
			return num_bufs;
		}

		void set_num_bufs(unsigned long numBufs) {
			num_bufs = numBufs;
		}

		unsigned long get_size_per_buf() const {
			return size_per_buf;
		}

		void set_size_per_buf(unsigned long sizePerBuf) {
			size_per_buf = sizePerBuf;
		}

		const std::vector<smart_buffer>& get_buf_vector() const {
			return buf_vector;
		}

	unsigned long get_num_on_chip_bufs() const {
		return num_on_chip_bufs;
	}

	void set_num_on_chip_bufs(unsigned long numOnChipBufs) {
		num_on_chip_bufs = numOnChipBufs;
	}
};

} /* namespace smartbuf */

#endif /* SMART_BUFFER_H_ */
