/*
 * mdio_communicator.h
 *
 *  Created on: Aug 16, 2013
 *      Author: yairlinn
 */

#ifndef MDIO_COMMUNICATOR_H_
#define MDIO_COMMUNICATOR_H_

#include "basedef.h"
#include "uart_support/uart_encapsulator.h"
#include "uart_support/uart_register_file.h"
#include "uart_support/uart_vector_config_encapsulator.h"
#include "altera_pio_encapsulator.h"
#include "flow_through_fifo_encapsulator.h"
#include "fmc_present_encapsulator.h"
#include <sstream>
#include <string>
#include <stdio.h>

#include <stddef.h>
#include <string>
#include <iostream>

#define DEBUG_MDIO_COMMUNICATOR 1

#define mdio_debug(x) if (DEBUG_MDIO_COMMUNICATOR) { safe_print(std::cout << x); };

class mdio_communicator {
protected:
	uart_register_file* uart_connected_proc;
	bool enabled;
public:
	mdio_communicator() { uart_connected_proc = NULL; enabled = false;};
	void set_uart_proc(uart_register_file* the_uart_connected_proc)  {
		if (the_uart_connected_proc != NULL) {
		  uart_connected_proc = the_uart_connected_proc;
		} else {
		  set_enabled(false);
		  xprintf("Error: mdio_communicator.set_uart_proc: the_uart_connected_proc == NULL\n");
		}
	}
	uart_register_file* get_uart_proc() {
		return uart_connected_proc;
	}
	void mdio_write(unsigned long reg, unsigned long val);
	unsigned long mdio_read(unsigned long reg);
	int get_mac_addr(unsigned int[6]);
	bool is_enabled() const
    {
    return enabled;
    }

    void set_enabled(bool enabled)
    {
    this->enabled = enabled;
    };
};



#endif /* MDIO_COMMUNICATOR_H_ */
