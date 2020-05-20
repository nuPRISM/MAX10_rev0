
#ifndef ___MY_FIFOED_UART_SMALL_H 
#define ___MY_FIFOED_UART_SMALL_H
#include "alt_types.h"

int fifoed_avalon_uart_read_small (alt_u32 base, char* ptr, int len);
int fifoed_avalon_uart_write_small (alt_u32 base, const char* ptr, int len);
#endif