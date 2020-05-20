/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "altera_avalon_timer_regs.h"
#include "altera_avalon_timer.h"
#include "sys/alt_irq.h"
#include "alt_types.h"
#include "sys/alt_stdio.h"
#include "xprintf.h"
#include "rsscanf.h"
#include "altera_avalon_jtag_uart_regs.h"
#include "altera_avalon_uart_regs.h"
#include "os/alt_syscall.h"

/* function prototypes*/
unsigned char bootloader_chan_getc();
void bootloader_chan_putc(unsigned char);
void config_xdev();
void handle_timer_interrupt(void*);
void timer_isr_setup();
int clear_jtag_buffer();
void uart_tx(unsigned int, char*);
void uart_rx(unsigned int, char*);


/* global variables */
volatile alt_u32 timer_flag = 0;
char input[256] = "";

int main()
{
  /*initialize*/
  config_xdev();
  timer_isr_setup();
  clear_jtag_buffer();

  /*init code*/
  xprintf("xhi:");
  xgets(input, sizeof input);
  xprintf("\n %s \n", input);
  xprintf("done");

  /*main loop variables*/
  char msg_in[256] = "";
  /*main loop*/
  while(1){
//	*msg_in = "";
	usleep(1000000);
    xprintf("xhi\n");
    uart_tx(0,"hello");
    uart_rx(0, msg_in);
    xprintf("%s\n", msg_in);
  }
  return 0;
}

/*functions*/
void timer_isr_setup(){
	void * timer_flag_ptr;
	timer_flag_ptr = (void*)&timer_flag;
	alt_ic_isr_register(TIMER_0_IRQ_INTERRUPT_CONTROLLER_ID,
			  	  	  	  TIMER_0_IRQ,
			  	  	  	  handle_timer_interrupt,
						  timer_flag_ptr,
						  0x00);
}

void handle_timer_interrupt(void* context)
{
	volatile alt_u32 * timer_flag_ptr;
	timer_flag_ptr = (volatile alt_u32*) context;
	*timer_flag_ptr = *timer_flag_ptr + 1;
	IOWR_ALTERA_AVALON_TIMER_STATUS(TIMER_0_BASE, 0x00);
}

unsigned char bootloader_chan_getc() {
     int c;
     c = alt_getchar();
     if (c > 0) {
         return ((char) c);
     } else {
         return 0;
     }
}

void bootloader_chan_putc(unsigned char c) {
     alt_putchar((int)c);
}

void config_xdev(){
	xdev_in(bootloader_chan_getc);
	xdev_out(bootloader_chan_putc);
	return;
}

int clear_jtag_buffer(){
	while(((alt_u32)IORD_ALTERA_AVALON_JTAG_UART_DATA(JTAG_UART_0_BASE) & ALTERA_AVALON_JTAG_UART_DATA_RAVAIL_MSK)!=0);
	return (alt_u32)IORD_ALTERA_AVALON_JTAG_UART_DATA(JTAG_UART_0_BASE) & ALTERA_AVALON_JTAG_UART_DATA_RAVAIL_MSK;
}

void uart_tx(unsigned int uart_id, char* str){
	alt_u32 sys_uart_id;

	switch(uart_id){
		case 0:
			sys_uart_id = 0x0;
			break;
		default:
			sys_uart_id = 0x0;
	}

	for(alt_u32 i = 0; i < strlen(str) ; i++){
		while(!(IORD_ALTERA_AVALON_UART_STATUS(UART_0_BASE) & ALTERA_AVALON_UART_STATUS_TRDY_MSK));
		IOWR_ALTERA_AVALON_UART_TXDATA(UART_0_BASE, str[i]);
	}
}

void uart_rx(unsigned int uart_id, char* str){
	alt_u32 sys_uart_id;

	switch(uart_id){
		case 0:
			sys_uart_id = 0x0;
			break;
		default:
			sys_uart_id = 0x0;
	}

	alt_u32 i = 0;
	while((IORD_ALTERA_AVALON_UART_STATUS(UART_0_BASE) & ALTERA_AVALON_UART_STATUS_RRDY_MSK)){
		str[i] = IORD_ALTERA_AVALON_UART_RXDATA(UART_0_BASE);
		i++;
		xprintf("%s  :  %d\n",str[i],i);
	}
//	str[i] = "\n";
}
