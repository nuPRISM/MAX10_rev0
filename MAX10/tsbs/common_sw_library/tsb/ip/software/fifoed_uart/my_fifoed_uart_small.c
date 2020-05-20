#include "my_fifoed_uart_small.h"
#include "fifoed_avalon_uart_regs.h"
#include "fifoed_avalon_uart.h"
 
 
 int fifoed_avalon_uart_read_small (alt_u32 base, char* ptr, int len)
			{
			  unsigned int status;

			  int i=0;
			  do
			  {
			    status = IORD_FIFOED_AVALON_UART_STATUS(base);

			    /* clear any error flags */

			    IOWR_FIFOED_AVALON_UART_STATUS(base, 0);

			    // actually with the new settings you can read up to length. but we will only read until the fifo is empty
			    // if that is not what you what then rewrite this function.


			      if (status & FIFOED_AVALON_UART_CONTROL_RRDY_MSK)
			      {
			        ptr[i] = IORD_FIFOED_AVALON_UART_RXDATA(base);

			 	    i++; // get the next char if needed
				    if( i== len)
					return i;
			      }
			      else  // no chars are ready
			      {

					if( i>0)  // we have gotten something return it
					{
						return i;
					}

			      }
			  }
			  while (i < len);

			  return 0;
			}


int fifoed_avalon_uart_write_small (alt_u32 base, const char* ptr, int len)
{
  unsigned int status;
  int count;

  count = len;

  do
  {
    status = IORD_FIFOED_AVALON_UART_STATUS(base);

    if (status & FIFOED_AVALON_UART_STATUS_TRDY_MSK)
    {
      IOWR_FIFOED_AVALON_UART_TXDATA(base, *ptr++);
      count--;
    }
  }
  while (count);

  return (len - count);
}