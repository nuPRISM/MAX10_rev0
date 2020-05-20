/*
 * smart_buffer.cpp
 *
 *  Created on: Apr 29, 2015
 *      Author: yairlinn
 */

#include "smart_buffer.h"
#include "basedef.h"
#include <stdio.h>
#include <iostream>
#include <sstream>

extern "C" {
#include "my_mem_defs.h"
#include "mem.h"

}
namespace smartbuf {

		smart_buffer::smart_buffer() {
			this->set_bufptr(NULL);
			// TODO Auto-generated constructor stub

		}

		smart_buffer::smart_buffer(unsigned long size) {
           this->set_size(size);
           this->allocate();
		}

		smart_buffer::~smart_buffer() {
			// TODO Auto-generated destructor stub
			if (this->get_bufptr() != NULL) {
				my_mem_free(this->get_bufptr());
			}
		}

		smart_buffer_repository::smart_buffer_repository() {
			num_bufs = 0;
			size_per_buf = 0;

		}

        void smart_buffer::allocate() {
	       this->set_bufptr((alt_u32 *)my_mem_malloc(this->get_size()*sizeof(alt_u32)+buffer_safety_margin_in_bytes));
         }

        smart_buffer_repository::smart_buffer_repository(unsigned long num_total_bufs,
				 unsigned long num_on_chip_bufs,
				 unsigned long on_chip_mem_base_address,
				 unsigned long size_per_buf_in_words)
		{
        	this->set_num_on_chip_bufs(num_on_chip_bufs);
        	if (num_on_chip_bufs > num_total_bufs) {
        		safe_print(std::cout << "Error: smart_buffer_repository::smart_buffer_repository: num_on_chip_bufs = " << num_on_chip_bufs << " but num_total_bufs = " << num_total_bufs << ". Allocation failed!" << std::endl);
        		return;
        	}
			this->set_num_bufs(num_total_bufs);
			this->set_size_per_buf(size_per_buf_in_words);
			this->buf_vector.resize(num_total_bufs);
			for (unsigned int i = 0; i < num_bufs; i++) {
				this->buf_vector.at(i).set_size(this->get_size_per_buf());
				if (i >= num_on_chip_bufs) {
				       this->buf_vector.at(i).allocate(); //allocate from ddr
				} else {
					this->buf_vector.at(i).set_bufptr((alt_u32 *)(on_chip_mem_base_address+(i*size_per_buf_in_words*4)));
				}
			}
		}

		alt_u32* smart_buffer_repository::get_buffer(unsigned long index) {
			if (index >= this->get_num_bufs()) {
				safe_print(std::cout << "Error: smart_buffer_repository::get_buffer: index = " << index << " num_bufs " << this->get_num_bufs() << std::endl);
				return NULL;
			}
			return this->buf_vector.at(index).get_bufptr();
		}

		alt_u32* smart_buffer_repository::silent_get_buffer(unsigned long index) {
					if (index >= this->get_num_bufs()) {
						return NULL;
					}
					return this->buf_vector.at(index).get_bufptr();
				}

} /* namespace smartbuf */

