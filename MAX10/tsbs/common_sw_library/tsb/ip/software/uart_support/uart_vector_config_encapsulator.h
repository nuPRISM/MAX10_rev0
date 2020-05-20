/*
 * uart_vector_config_encapsulator.h
 *
 *  Created on: May 13, 2013
 *      Author: yairlinn
 */

#ifndef UART_VECTOR_CONFIG_ENCAPSULATOR_H_
#define UART_VECTOR_CONFIG_ENCAPSULATOR_H_

#include "altera_pio_encapsulator.h"
#include <string>
#include <stdio.h>
#include <vector>
class uart_vector_config_encapsulator : public altera_pio_encapsulator {
protected:
	unsigned long max_uart_num;
	unsigned long raw_uart_enabled_vector;
	std::vector<bool> virtual_uart_enabled_vector;
	void set_max_uart_num(unsigned long  max_uart_num);
    void set_raw_uart_enabled_vector(unsigned long raw_uart_enabled_vector);


public:

    uart_vector_config_encapsulator() {};
	uart_vector_config_encapsulator(unsigned long max_virtual_uart_num, unsigned long uart_enabled_pio_base_address) : altera_pio_encapsulator(uart_enabled_pio_base_address)
	{
		reload_and_calculate_enabled_word();
		virtual_uart_enabled_vector.resize(max_virtual_uart_num,false);
	};
    void set_virtual_uart_enabled_vector(std::vector<bool> the_virtual_uart_enabled_vector) {
    	virtual_uart_enabled_vector = the_virtual_uart_enabled_vector;
    }

    unsigned long get_raw_uart_enabled_vector() const;

	void reload_and_calculate_enabled_word() {
		unsigned int x;
		x = read();
		set_raw_uart_enabled_vector(x);
		printf("[reload_and_calculate_enabled_word]got 0x%x reread 0x%x\n",(unsigned int)x,(unsigned int)get_raw_uart_enabled_vector());
		unsigned long tmp = get_raw_uart_enabled_vector();
		unsigned long cntr = 0;
		 while (tmp != 0) {
		 	cntr = cntr+1;
		 	tmp = tmp >> 1;
		 }
		 set_max_uart_num(cntr);
	}

	bool is_enabled(unsigned long uart_num) {
		return ((get_raw_uart_enabled_vector() & (((unsigned long) 1) << uart_num)) != 0);
	}

    unsigned int get_max_num_of_virtual_uarts() {
    	return virtual_uart_enabled_vector.size();
    }
	bool virtual_uart_is_enabled(unsigned long uart_num) {
		if (virtual_uart_enabled_vector.size() <= uart_num) {
			return false;
		} else {
		   return (virtual_uart_enabled_vector.at(uart_num));
		}
	}

	void set_virtual_uart_as_enabled(unsigned int uart_num) {
		virtual_uart_enabled_vector.at(uart_num) = true;
	}

	void set_virtual_uart_as_disabled(unsigned int uart_num) {
		virtual_uart_enabled_vector.at(uart_num) = false;
	}

    unsigned long get_max_uart_num() const;
    std::string get_tcl_vector_of_enable_status();
    std::string get_tcl_vector_of_virtual_enable_status();
    std::string get_tcl_vector_of_all_enable_status();

	virtual ~uart_vector_config_encapsulator();

	std::vector<bool> get_virtual_uart_enabled_vector() const
	{
		return virtual_uart_enabled_vector;
	}
};

#endif /* UART_VECTOR_CONFIG_ENCAPSULATOR_H_ */
