/*
 * uart_encapsulator.h
 *
 *  Created on: Mar 27, 2013
 *      Author: yairlinn
 */

#ifndef UART_ENCAPSULATOR_H_
#define UART_ENCAPSULATOR_H_
#include "system.h"

#include <stdio.h>
#include <iostream>
#include <string>
#include <fcntl.h>
#include <sys/ioctl.h>
#include "basedef.h"
//
//#include "priv/alt_file.h"
extern "C" {
#include "includes.h"
#include "ucos_ii.h"
}

#include "simple_socket_server.h"
#include "dual_port_memory_comm_encapsulator.h"

#define UART_REGFILE_CRC_LENGTH_IN_NIBBLES (4)
typedef enum  { UART_REGULAR_BASIC = 0, UART_REGFILE_ADVANCED = 1 } UART_ENCAPSULATOR_TYPES;
#define uartdebug(x) do { if (UART_REG_DEBUG) {x;} } while (0)


class uart_encapsulator {
protected:
	std::string device_name;
	FILE *fp;
	int fd; //file descriptor
	UART_ENCAPSULATOR_TYPES uart_type;
	bool enabled;
	OS_EVENT *uart_semaphore;
	unsigned max_response_length;
	dual_port_memory_comm_encapsulator *dp_ram_communicator;
	int timeout;
	int _uses_crc;
	int tx_uart_command_count;
	int rx_uart_command_count;

public:
	uart_encapsulator(unsigned the_max_response_length = UART_MAX_RESPONSE_STRING_LENGTH, int the_timeout = 0);
	void set_device_name(const std::string devname);
	std::string get_device_name();
	bool open();

	void set_uart_type(UART_ENCAPSULATOR_TYPES t);
	UART_ENCAPSULATOR_TYPES get_uart_type();
	bool close();

	std::string getstr(int maxchars, int* errorptr = 0);
	int writestr(std::string the_str);

	bool is_enabled();

	void set_enable(bool enable_status);

	virtual ~uart_encapsulator();
	OS_EVENT *get_uart_semaphore() const;
	void set_uart_semaphore(OS_EVENT *uart_semaphore);
	unsigned get_max_response_length() const;
	void set_max_response_length(unsigned  max_response_length);
	dual_port_memory_comm_encapsulator *get_dp_ram_communicator() const;
	void set_dp_ram_communicator(dual_port_memory_comm_encapsulator *dp_ram_communicator);
	int we_are_communicating_through_dp_ram();

	int get_fd() const;

	void set_fd(int fd);

	FILE* get_fp() const;

	void set_fp(FILE* fp);

	int get_timeout() const;

	void set_timeout(int timeout);
	void set_uses_crc(int the_uses_crc) { this->_uses_crc = the_uses_crc; };
	int uses_crc() { return _uses_crc; };
};

#endif /* UART_ENCAPSULATOR_H_ */
