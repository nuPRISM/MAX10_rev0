#ifndef MY_JTAG_WRITE_H
#define MY_JTAG_WRITE_H  
  
#define JTAG_UART_TIMEOUT   (alt_ticks_per_second() * 2 ) // 2 seconds
#define JTAG_WAITING_BIT   (1 << 1)
#define JTAG_ABANDONED_BIT (1 << 2)

extern volatile alt_u32 jtag_uart_state;
int MyJtagWrite(const char *buf, int len);
int MyJtagWrite8(const char *buf, int len);

#endif
