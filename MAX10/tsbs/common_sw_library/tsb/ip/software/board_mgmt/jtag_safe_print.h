/*
 * jtag_safe_print.h
 *
 *  Created on: Sep 9, 2013
 *      Author: yairlinn
 */

#ifndef JTAG_SAFE_PRINT_H_
#define JTAG_SAFE_PRINT_H_

# define JTAGPRINT(name) MyJtagWrite(name, sizeof(name)-1)
# define JTAG_UART_TIMEOUT   ( alt_ticks_per_second() * 2 ) // 2 seconds
# define JTAG_WAITING_BIT   (1 << 1)
# define JTAG_ABANDONED_BIT (1 << 2)

  // Stores the transmit state of the JTAG_UART
  volatile alt_u32 jtag_uart_state;

int MyJtagWrite(const char *buf, int len);
int MyJtagWrite1_efficient(unsigned char c);

#endif /* JTAG_SAFE_PRINT_H_ */
