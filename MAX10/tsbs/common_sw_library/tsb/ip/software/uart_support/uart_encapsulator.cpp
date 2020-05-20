/*
 * uart_encapsulator.cpp
 *
 *  Created on: Mar 27, 2013
 *      Author: yairlinn
 */

#include "uart_encapsulator.h"
#include "crc16_ccitt.h"
#include "stdlib.h"

	uart_encapsulator::uart_encapsulator(unsigned the_max_response_length, int the_timeout) {
		device_name = "";
		fp = NULL;
		fd = -1;
		set_enable(false);
		uart_semaphore = NULL;
		max_response_length = the_max_response_length;
		dp_ram_communicator = NULL;
		timeout = the_timeout;
		tx_uart_command_count = 0;
		rx_uart_command_count = 0;
		_uses_crc = 0;

	}
	void uart_encapsulator::set_device_name(const std::string devname){
		device_name = devname;
	};

	std::string uart_encapsulator::get_device_name() { return device_name;};
	bool uart_encapsulator::open() {
		if (!we_are_communicating_through_dp_ram()) {
			fp = fopen (device_name.c_str(), "r+");

			if (fp == NULL) {
				safe_print(std::cout << "=========================\nError in opening UART: " << device_name << "\n=========================\n");

				return (fp != NULL);

			} else {
				set_fd(fileno(fp));
#if ENABLE_UART_REGFILE_IOCTL
				uartdebug(safe_print(std::cout << "Seting Timeout on:" << device_name << "to:" << timeout << std::endl));
				if (ioctl(get_fd(),1,(void *)&timeout) == 0) {
					uartdebug(safe_print(std::cout << "Set Timeout on:" << device_name << "to:" << timeout << std::endl));
				} else {
					uartdebug(safe_print(std::cout << "Error setting Timeout on:" << device_name << "to:" << timeout << std::endl));
				}
#endif
				return (true);
			}
		} else {
			safe_print(std::cout << "=========================\nError in opening UART: " << device_name << " Is configured for use with memory communicator! =========================\n");
			return (false);
		}
	}

	void uart_encapsulator::set_uart_type(UART_ENCAPSULATOR_TYPES t)
	{
		uart_type = t;
	}

	UART_ENCAPSULATOR_TYPES uart_encapsulator::get_uart_type()
	{
		return uart_type;
	}

	bool uart_encapsulator::close()
	{
		if (!we_are_communicating_through_dp_ram()) {
			if (fp) {
				fclose(fp);
				fp = NULL;
				fd = -1;
				return true;
			} else {
				safe_print(std::cout << "=========================\nError in closing UART: " << device_name << "\nDevice is alread closed\n=========================\n");
				return false;
			}
		}else {
			safe_print(std::cout << "=========================\nError in closing UART: " << device_name << " Is configured for use with memory communicator! =========================\n");
			return false;
		}
	}

	bool uart_encapsulator::is_enabled()
	{
		return enabled;
	}

	void uart_encapsulator::set_enable(bool enable_status)
	{
		enabled = enable_status;
	};

	int uart_encapsulator::get_fd() const {
		return fd;
	}

	void uart_encapsulator::set_fd(int fd) {
		this->fd = fd;
	}

	FILE* uart_encapsulator::get_fp() const {
		return fp;
	}

	void uart_encapsulator::set_fp(FILE* fp) {
		this->fp = fp;
	}

	int uart_encapsulator::get_timeout() const {
		return timeout;
	}

	void uart_encapsulator::set_timeout(int timeout) {
		int error_code;
		this->timeout = timeout;
#if ENABLE_UART_REGFILE_IOCTL
		if (get_fd() != -1)
		{
			error_code = ioctl(get_fd(),1,(void *)&timeout);
			if (error_code == 0) {
				uartdebug(safe_print(std::cout << "Set Timeout on:" << device_name << "to:" << timeout << std::endl));
			} else {
				safe_print(std::cout << "Error setting Timeout on:" << device_name << "to:" << timeout << " error is: " << error_code << std::endl);
			}
		} else {
			safe_print(std::cout << "Error setting Timeout on:" << device_name << "to:" << timeout << " get_fd = " << get_fd() << std::endl);
		}
#endif
	}


OS_EVENT *uart_encapsulator::get_uart_semaphore() const
{
    return uart_semaphore;
}

void uart_encapsulator::set_uart_semaphore(OS_EVENT *uart_semaphore)
{
    this->uart_semaphore = uart_semaphore;
}

uart_encapsulator::~uart_encapsulator() {
	// TODO Auto-generated destructor stub
}

unsigned uart_encapsulator::get_max_response_length() const
{
    return max_response_length;
}

void uart_encapsulator::set_max_response_length(unsigned  max_response_length)
{
    this->max_response_length = max_response_length;
}

dual_port_memory_comm_encapsulator *uart_encapsulator::get_dp_ram_communicator() const
{
    return dp_ram_communicator;
}

void uart_encapsulator::set_dp_ram_communicator(dual_port_memory_comm_encapsulator *dp_ram_communicator)
{
    this->dp_ram_communicator = dp_ram_communicator;
}

int uart_encapsulator::we_are_communicating_through_dp_ram(){
	return (get_dp_ram_communicator() != NULL);
}

std::string uart_encapsulator::getstr(int maxchars, int* errorptr)
	{
	std::string result_str;
	int fgets_successful = 1;

		if (errorptr != NULL) {
			*errorptr = 0; //set initial error to 0, OK
		}

		if (!we_are_communicating_through_dp_ram()) {
			uartdebug(safe_print(std::cout << "In getstr, not memory comm " << device_name << std::endl));
			if ((fp == NULL) || (!is_enabled())) {
				safe_print(std::cout << "Error!!!! uart_encapsulator::getstr Tried to get string from device: " << device_name << " pointer: " << ((unsigned int) fp) << "Enable Status:" << is_enabled() << " but device is not open or enabled!!!\n");
				return "";
			}
			else {
				char str[maxchars+1];
				INT8U semaphore_err;
				if (uart_semaphore != NULL) {
					uartdebug(safe_print(std::cout << "In getstr, trying to get semaphore " << device_name << std::endl));
					OSSemPend(uart_semaphore,	0, &semaphore_err);
					if (semaphore_err != OS_NO_ERR) {
						safe_print(std::cout << "UART: " << get_device_name() << " [uart_encapsulator getstr] Could not get Semaphore, Error is: "	<< semaphore_err << std::endl);
						return "";
					}
				}

				 char* found_tunnel_str = NULL;

#ifdef STDOUT_TUNNEL_MAGIC_STR
				do {
					fgets_successful = (fgets(str,maxchars-1,fp) != NULL);
  				    if (!fgets_successful)
					   {
						   safe_print(std::cout <<" [uart_encapsulator::getstr] Error in fgets while reading UART: " << get_device_name() << std::endl);
						   if (errorptr != NULL) {
							   *errorptr = errno;
						   	}
						   str[0] ='\0';
						   break;
					   }

				   found_tunnel_str = strstr(str,STDOUT_TUNNEL_MAGIC_STR);
				   if (found_tunnel_str) {
					safe_print(std::cout <<" Got Tunneled string from UART: " << get_device_name() << ": (" << std::string(str) << ")" << std::endl);
				   }
				} while (found_tunnel_str);



#else
				fgets_successful = (fgets(str,maxchars-1,fp) != NULL);
				 if (!fgets_successful)
				 {
				   safe_print(std::cout <<" [uart_encapsulator::getstr] Error in fgets while reading UART: " << get_device_name() << std::endl);
				   if (errorptr != NULL) {
				   			*errorptr = errno;
				   	}
				   str[0] ='\0';
				 }
#endif

			    result_str = std::string(str);
			    if (fgets_successful) {
							unsigned int received_crc;
							unsigned int calculated_crc;

							if (this->uses_crc()) {
								if (result_str.length() < UART_REGFILE_CRC_LENGTH_IN_NIBBLES) {
									*errorptr = EBADMSG;
									uartdebug(safe_print(std::cout << "[uart_encapsulator getstr]  UART: " << get_device_name() << " CRC length error, str = (" << std::string(str) << ")" << std::endl));
								} else {
									std::string crc_str = result_str.substr(0,UART_REGFILE_CRC_LENGTH_IN_NIBBLES);
									received_crc = strtoul(crc_str.c_str(),NULL,16);
									result_str.erase(0,UART_REGFILE_CRC_LENGTH_IN_NIBBLES);
									size_t last_data_byte;
									last_data_byte = result_str.find_last_not_of("\r\n");
									size_t length_of_crc_string;
									if (last_data_byte < result_str.length()) {
										length_of_crc_string = (last_data_byte + 1);
									} else {
										length_of_crc_string = 0;
									}
									calculated_crc = crc16_ccitt(result_str.c_str(),length_of_crc_string);

									if (ENABLE_CRC_CURRUPTION_FOR_UART_REGFILE_TEST) {
										rx_uart_command_count++;
										if ((rx_uart_command_count % RX_CRC_CORRUPTION_COMMAND_COUNT_INTERVAL) == 0) {
											calculated_crc = (calculated_crc+1) & 0xFFFF;
										}
									 }

									 if (calculated_crc != received_crc) {
										*errorptr = EBADMSG;
										safe_print(std::cout << "UART: " << get_device_name() << " [uart_encapsulator getstr] CRC error, recv CRC = 0x" << std::hex << received_crc << " calc. CRC = 0x" << calculated_crc << std::dec << " last_data_byte = " << last_data_byte << " length_of_crc_string = " << length_of_crc_string << "\nresult_str = (" << result_str << ")\n used for crc calc = (" << result_str.substr(0,length_of_crc_string) << ")\n str = (" << std::string(str) << ")" << std::endl);
									 }

								}
							}
			    }

				if (uart_semaphore != NULL) {

					semaphore_err = OSSemPost(uart_semaphore);

					if (semaphore_err != OS_NO_ERR) {
						safe_print(std::cout << "UART: " << get_device_name() << " [uart_encapsulator getstr] Could not post to DUT_PROC_UART_COMM_Semaphore, Error is: "	<< semaphore_err << std::endl);
						return result_str;
					}
				}

				uartdebug(safe_print(std::cout << "Getstr from UART:" << device_name << "str: (" << str << ")\n actual str returned (" << result_str << ") " << std::endl));
				return result_str;
			}
		} else {
			uartdebug(safe_print(std::cout << "In getstr, is memory comm " << device_name << std::endl));
			int cmd_result;
			std::string cmd_response;
			cmd_result = dp_ram_communicator->get_command_response(cmd_response);
			uartdebug(safe_print(std::cout << "Getstr from Mem Comm UART:" << device_name << "str: (" << cmd_response << ") cmd_result = (" << cmd_result << ") " << std::endl));
			return cmd_response;
		}
	}

	int uart_encapsulator::writestr(std::string the_str)
	{
		if (!we_are_communicating_through_dp_ram()) {
#if USE_NONBLOCKING_UART_FGETS
			if ((fd == -1) || (!is_enabled())) {
							safe_print(std::cout << "Error!!!! Tried to print " << the_str << " To device: " << device_name << " file descriptor: " << fd << "Enable Status:" << is_enabled() << " but device is not open or enabled!!!\n");
							return (RETURN_VAL_ERROR);
						}
#else
			if ((fp == NULL) || (!is_enabled())) {
				safe_print(std::cout << "Error!!!! Tried to print " << the_str << " To device: " << device_name << " pointer: " << ((unsigned int) fp) << "Enable Status:" << is_enabled() << " but device is not open or enabled!!!\n");
				return (RETURN_VAL_ERROR);
			}
#endif
			else {

#if USE_NONBLOCKING_UART_FGETS
				uartdebug(safe_print(std::cout << "Sent UART:" << device_name << "str: (" << the_str << ")" << " To device: " << device_name << " file descriptor: " << fd <<  std::endl));
#else
				uartdebug(safe_print(std::cout << "Sent UART:" << device_name << "str: (" << the_str << ")" << " To device: " << device_name << " pointer: " << ((unsigned int) fp) <<  std::endl));
#endif
				INT8U semaphore_err;

				if (uart_semaphore != NULL) {
					OSSemPend(uart_semaphore,	0, &semaphore_err);
					if (semaphore_err != OS_NO_ERR) {
						safe_print(std::cout << "UART: " << get_device_name() << " [uart_encapsulator getstr] Could not get DUT_PROC_UART_COMM_Semaphore, Error is: "	<< semaphore_err << std::endl);
						return (RETURN_VAL_ERROR);
					}
				}


				unsigned int the_crc;
				if (this->uses_crc()) {
					the_str.append(" ");
					the_crc = crc16_ccitt(the_str.c_str(),the_str.length());
						if (ENABLE_CRC_CURRUPTION_FOR_UART_REGFILE_TEST) {
							tx_uart_command_count++;
							if ((tx_uart_command_count % TX_CRC_CORRUPTION_COMMAND_COUNT_INTERVAL) == 0) {
                              the_crc = (the_crc+1) & 0xFFFF;
							}
						}


				}
				int retval;
#if USE_NONBLOCKING_UART_FGETS
				retval=nonblocking_fprintf(the_str.append("\n"));
#else

				if (this->uses_crc())
				{
					retval=fprintf(fp,"%s%x\n",the_str.c_str(),the_crc);
				} else {
					retval=fprintf(fp,"%s\n",the_str.c_str());
				}
#endif
				if (uart_semaphore != NULL) {
					semaphore_err = OSSemPost(uart_semaphore);

					if (semaphore_err != OS_NO_ERR) {
						safe_print(std::cout << "UART: " << get_device_name() << " [uart_encapsulator getstr] Could not post to DUT_PROC_UART_COMM_Semaphore, Error is: "	<< semaphore_err << std::endl);
						return (RETURN_VAL_ERROR);
					}
				}

				uartdebug(safe_print(std::cout << "Finished Sending String" << std::endl));

				return retval;
			}
		} else {
			dp_ram_communicator->set_command(the_str);
			uartdebug(safe_print(std::cout << "Sent UART:" << device_name << "str: (" << the_str << ")" << " To device: " << device_name << " Mem Comm pointer: " << ((unsigned int) dp_ram_communicator) <<  std::endl));
			return the_str.length();
		}
	}
