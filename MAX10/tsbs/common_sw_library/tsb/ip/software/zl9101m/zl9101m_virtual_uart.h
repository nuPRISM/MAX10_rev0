/*
 * zl9101m_virtual_uart.h
 *
 *  Created on: Sep 30, 2015
 *      Author: yairlinn
 */

#ifndef ZL9101M_VIRTUAL_UART_H_
#define ZL9101M_VIRTUAL_UART_H_
#include "virtual_uart_register_file.h"

class zl9101m_virtual_uart : public virtual_uart_register_file  {
protected:
	unsigned int pmbus_base;
	typedef enum {rw_byte_type=0, r_byte_type=1, rw_word_type=2, rw_doubleword_type=3, r_word_type=4, send_byte=5, block_type=6, r_block_type =7 } zl9101m_reg_types;
	typedef std::map<unsigned long,zl9101m_reg_types> zl9101m_reg_type_map_type;

	zl9101m_reg_type_map_type reg_type_map;

public:
	zl9101m_virtual_uart();
	zl9101m_virtual_uart(unsigned int pmbusBase);
	virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual unsigned long long read_status_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual void write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual ~zl9101m_virtual_uart();

	std::string read_block(unsigned long address, unsigned long length);

	unsigned int get_pmbus_base() const {
		return pmbus_base;
	}

	void set_pmbus_base(unsigned int pmbusBase) {
		pmbus_base = pmbusBase;
	}
};

#endif /* ZL9101M_VIRTUAL_UART_H_ */
