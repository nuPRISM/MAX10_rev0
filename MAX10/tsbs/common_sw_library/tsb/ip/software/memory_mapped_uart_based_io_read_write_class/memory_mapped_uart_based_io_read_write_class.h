/*
 * memory_mapped_uart_based_io_read_write_class.h
 *
 *  Created on: Feb 27, 2015
 *      Author: yairlinn
 */

#ifndef MEMORY_MAPPED_UART_BASED_IO_READ_WRITE_CLASS_H_
#define MEMORY_MAPPED_UART_BASED_IO_READ_WRITE_CLASS_H_
#include "abstract_io_read_write_class.h"
#include "uart_based_io_read_write_class.h"
#include <io.h>


class memory_mapped_uart_based_io_read_write_class : public uart_based_io_read_write_class  {
protected:
	unsigned long status_base;
	unsigned long control_base;
public:

	memory_mapped_uart_based_io_read_write_class() {};
	memory_mapped_uart_based_io_read_write_class(unsigned long controlBase,
			unsigned long statusBase) {
		this->set_control_base(controlBase);
		this->set_status_base(statusBase);

	}
    virtual ~memory_mapped_uart_based_io_read_write_class();

	unsigned long get_control_base() const {
		return control_base;
	}

	void set_control_base(unsigned long controlBase) {
		control_base = controlBase;
	}

	unsigned long get_status_base() const {
		return status_base;
	}

	void set_status_base(unsigned long statusBase) {
		status_base = statusBase;
	}

	  virtual unsigned long read(unsigned long addr) ;
	   virtual void write (unsigned long addr, unsigned long data);

	   virtual unsigned long read_status(unsigned long addr);


};

#endif /* MEMORY_MAPPED_UART_BASED_IO_READ_WRITE_CLASS_H_ */
