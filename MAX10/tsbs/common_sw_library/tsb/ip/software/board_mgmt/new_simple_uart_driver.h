/*
 * new_simple_uart_driver.h
 *
 *  Created on: Jul 12, 2013
 *      Author: yairlinn
 */

#ifndef NEW_SIMPLE_UART_DRIVER_H_
#define NEW_SIMPLE_UART_DRIVER_H_

#define SIMPLE_UART_GPO_REG 4
#define SIMPLE_UART_GPI_REG 4

void write_char_to_uart(unsigned char c);
unsigned char get_char_from_uart();
void enable_mcs_uart();
void reset_mcs_new_rx_data();
void choose_external_uart();

#endif /* NEW_SIMPLE_UART_DRIVER_H_ */
