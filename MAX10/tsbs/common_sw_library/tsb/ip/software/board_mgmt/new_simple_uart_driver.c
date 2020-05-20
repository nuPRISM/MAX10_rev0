/*
 * new_simple_uart_driver.c
 *
 *  Created on: Jul 12, 2013
 *      Author: yairlinn
 */



#include "adc_mcs_basedef.h"
#include "pio_encapsulator.h"
#include "system.h"

#include "new_simple_uart_driver.h"
#include "misc_utils.h"


int uart_rx_new_data_ready() {
	unsigned long gpi_val = read_from_gpi_reg(SIMPLE_UART_GPI_REG);
	return ((gpi_val & 0x100) != 0);
}

int uart_tx_is_busy() {
	unsigned long gpi_val = read_from_gpi_reg(SIMPLE_UART_GPI_REG);
	return ((gpi_val & 0x200) != 0);
}

void write_char_to_uart(unsigned char c)
{
	set_bit_in_gpo_reg(SIMPLE_UART_GPO_REG,8,0); //make sure new_tx_data bit is off
	unsigned long old_gpo_val = read_from_gpo_reg(SIMPLE_UART_GPO_REG);
    unsigned long new_gpo_val = (old_gpo_val & 0xFFFFFE00) + (0x100 + (((unsigned) (c)) & 0xff)); //put data in place, turn on new_tx_data_bit
    write_to_gpo_reg(SIMPLE_UART_GPO_REG,new_gpo_val);
    while (uart_tx_is_busy()) {
    	//loop while the uart is busy
    }

	set_bit_in_gpo_reg(SIMPLE_UART_GPO_REG,8,0); //make sure new_tx_data bit is off
}

unsigned char get_char_from_uart()
{
  while (!uart_rx_new_data_ready())
  {
  };

  unsigned long read_data = read_from_gpi_reg(SIMPLE_UART_GPI_REG);
  unsigned long raw_received_char = read_data & 0xFF0000;
  unsigned char retval = (unsigned char) (raw_received_char >> 16);
  reset_mcs_new_rx_data();
  return retval;
}

void enable_mcs_uart() {
	set_bit_in_gpo_reg(SIMPLE_UART_GPO_REG,9,1);
}


void reset_mcs_new_rx_data() {
	set_bit_in_gpo_reg(SIMPLE_UART_GPO_REG,10,0);
	set_bit_in_gpo_reg(SIMPLE_UART_GPO_REG,10,1);
	set_bit_in_gpo_reg(SIMPLE_UART_GPO_REG,10,0);
}

void choose_external_uart() {
	set_bit_in_gpo_reg(SIMPLE_UART_GPO_REG,11,1);
}


