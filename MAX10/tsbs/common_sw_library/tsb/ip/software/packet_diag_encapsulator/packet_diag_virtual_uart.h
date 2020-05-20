/*
 * packet_diag_virtual_uart.h
 *
 *  Created on: Feb 12, 2014
 *      Author: yairlinn
 */

#ifndef PACKET_DIAG_VIRTUAL_UART_H_
#define PACKET_DIAG_VIRTUAL_UART_H_
#include "packet_diag_encapsulator.h"
#include "virtual_uart_register_file.h"

class packet_diag_virtual_uart: public virtual_uart_register_file, public pdiag::packet_diag_encapsulator {
protected:
	int enable_phy_register_tunneling;
public:
	packet_diag_virtual_uart(unsigned long the_base_address, std::string the_name = "undefined");
	virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
    virtual void write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);


};

#endif /* TSE_MAC_DEVICE_DRIVER_VIRTUAL_UART_H_ */
