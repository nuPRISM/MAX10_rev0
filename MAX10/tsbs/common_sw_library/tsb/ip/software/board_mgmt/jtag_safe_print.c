/*
 * jtag_safe_print.c
 *
 *  Created on: Sep 9, 2013
 *      Author: yairlinn
 */

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include "system.h"
#include "alt_types.h"
#include "sys/alt_alarm.h"
#include "sys/alt_cache.h"
#include "sys/alt_dev.h"
#include "sys/alt_irq.h"
#include "sys/alt_sys_init.h"
#include "priv/alt_file.h"
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_jtag_uart_regs.h"
#include "altera_avalon_jtag_uart.h"
#include "jtag_safe_print.h"
#include "adc_mcs_basedef.h"

extern FILE* uart_fp;
/*****************************************************************************
*  Function: GenericTimeoutCallback
*
*  Purpose:  This subroutine is a generic timeout callback routine for
*  timeout alarms that get set.  This routine simply increments the alt_u32
*  pointed to by the context pointer and returns 0, which requests no
*  additional alarm time.
*
*****************************************************************************/
alt_u32 GenericTimeoutCallback (void* context)
{
  *((volatile alt_u32 *)(context)) += 0x1;
  return(0);
}

int MyJtagWrite1_efficient(unsigned char c)
{
  static alt_fd *the_fd;
  static altera_avalon_jtag_uart_dev *the_dev;
  static altera_avalon_jtag_uart_state *the_state;
  static unsigned int the_base;
  static is_first_time = 1;

  alt_u32 control;
  alt_u32 wr_fifo_space;
  int ret_val;
  alt_alarm my_jtag_uart_alarm;
  volatile alt_u32 my_jtag_uart_context;

  /*
   * Look thru the device table to find our device block and extract the base
   * address to this STDOUT peripheral.
   *
   * A big assumption here is that the STDOUT peripheral is a JTAG UART.
   */

  if (is_first_time) {
           the_fd = &alt_fd_list[STDOUT_FILENO];
           the_dev = (altera_avalon_jtag_uart_dev *)the_fd->dev;
           the_state = (altera_avalon_jtag_uart_state *)&(the_dev->state);
           the_base = the_state->base;
  }
  // Read the jtag uart control register and grab the write fifo space
  control = IORD_ALTERA_AVALON_JTAG_UART_CONTROL(the_base);
  wr_fifo_space = (control & ALTERA_AVALON_JTAG_UART_CONTROL_WSPACE_MSK)
                  >> ALTERA_AVALON_JTAG_UART_CONTROL_WSPACE_OFST;

  if(wr_fifo_space >= 1)
  {
    // The write fifo has room for our write, so clear the abandoned flag
    // and write the message.
    ret_val = putc((int)c,uart_fp);
  }
  else
  {
	  ret_val = -1;
  }
  return ret_val;
}

/*****************************************************************************
*  Function: MyJtagWrite8
*
*  Purpose:  This subroutine is called by MyJtagWrite, which feeds it 8-byte
*  or less chunks of data to write out the JTAG UART.  Basically, this routine
*  queries the write fifo in the jtag uart to make sure there is room for our
*  data first.  If there's not room, then it waits JTAG_UART_TIMEOUT seconds
*  to see if a host will clear some of the pending data to allow us to write
*  new data to the fifo.  If no host connects within JTAG_UART_TIMEOUT, then
*  the jtag uart is marked abandoned, and the write data is discarded.  Once
*  abandoned, every time a new write call is made to this routine, it checks
*  to see if a host may have emptied the write fifo, if that ever happens,
*  then the jtag uart is reclaimed and the original algorithm prevails.
*
*****************************************************************************/
int MyJtagWrite8(const char *buf, int len)
{
  alt_fd *the_fd;
  altera_avalon_jtag_uart_dev *the_dev;
  altera_avalon_jtag_uart_state *the_state;
  unsigned int the_base;
  alt_u32 control;
  alt_u32 wr_fifo_space;
  int ret_val;
  alt_alarm my_jtag_uart_alarm;
  volatile alt_u32 my_jtag_uart_context;

  /*
   * Look thru the device table to find our device block and extract the base
   * address to this STDOUT peripheral.
   *
   * A big assumption here is that the STDOUT peripheral is a JTAG UART.
   */
  the_fd = &alt_fd_list[STDOUT_FILENO];
  the_dev = (altera_avalon_jtag_uart_dev *)the_fd->dev;
  the_state = (altera_avalon_jtag_uart_state *)&(the_dev->state);
  the_base = the_state->base;

  // Read the jtag uart control register and grab the write fifo space
  control = IORD_ALTERA_AVALON_JTAG_UART_CONTROL(the_base);
  wr_fifo_space = (control & ALTERA_AVALON_JTAG_UART_CONTROL_WSPACE_MSK)
                  >> ALTERA_AVALON_JTAG_UART_CONTROL_WSPACE_OFST;

  if(wr_fifo_space >= len)
  {
    // The write fifo has room for our write, so clear the abandoned flag
    // and write the message.
    ret_val = write(STDOUT_FILENO, buf, len);
  }
#ifdef ABORT_IF_JTAG_FIFO_FULL
  else
  {
	  ret_val = -1;
  }
#else
  else
  {
    // The write fifo does not have room for us. have we previously abandoned
    // the jtag uart?
    if( jtag_uart_state & JTAG_ABANDONED_BIT )
    {
      // We have previously abandoned the jtag uart
      if(control & ALTERA_AVALON_JTAG_UART_CONTROL_AC_MSK)
      {
        // There has been activity from a host so let's clear the abandoned
        // flag, and see if the host will clear the fifo for us.
        jtag_uart_state &= ~JTAG_ABANDONED_BIT;
      }
    }

    // At this point we check to see if the jtag uart is abandoned
    if( jtag_uart_state & JTAG_ABANDONED_BIT )
    {
      // The jtag uart has been abandoned, so just dump the data and return -1
      ret_val = -1;
    }
    else
    {
      // The jtag uart has not been abandoned
      ret_val = -1;

      // Clear the activity bit in the jtag uart control register
      control |= ALTERA_AVALON_JTAG_UART_CONTROL_AC_MSK;
      IOWR_ALTERA_AVALON_JTAG_UART_CONTROL(the_base, control);

      // Set a timeout alarm
      my_jtag_uart_context = 0;
      alt_alarm_start (
                        &my_jtag_uart_alarm,          // alt_alarm* alarm,
                        JTAG_UART_TIMEOUT,            // alt_u32 nticks,
                        GenericTimeoutCallback,  // alt_u32 (*callback) (void* context),
                        (void *)&my_jtag_uart_context // void* context
                      );

      // Now wait until the timeout occurs and abandon the uart, or the host
      // clears the fifo for us.
      while( my_jtag_uart_context == 0 )
      {
        // Get the current control register value
        control = IORD_ALTERA_AVALON_JTAG_UART_CONTROL(the_base);

        if( control & ALTERA_AVALON_JTAG_UART_CONTROL_AC_MSK )
        {
          // We see activity, so stop the timeout alarm
          alt_alarm_stop ( &my_jtag_uart_alarm );
          my_jtag_uart_context = 0;

          // Extract the write fifo space
          wr_fifo_space = (control & ALTERA_AVALON_JTAG_UART_CONTROL_WSPACE_MSK)
                          >> ALTERA_AVALON_JTAG_UART_CONTROL_WSPACE_OFST;

          if(wr_fifo_space >= len)
          {
            // We now have room to perform our write, so do it and get outa here
            ret_val = write(STDOUT_FILENO, buf, len);
            break;
          }
          // There's still not enough room so clear the activity bit
          control |= ALTERA_AVALON_JTAG_UART_CONTROL_AC_MSK;
          IOWR_ALTERA_AVALON_JTAG_UART_CONTROL(the_base, control);

          // And set the timeout alarm again
          alt_alarm_start (
                            &my_jtag_uart_alarm,          // alt_alarm* alarm,
                            JTAG_UART_TIMEOUT,            // alt_u32 nticks,
                            GenericTimeoutCallback,  // alt_u32 (*callback) (void* context),
                            (void *)&my_jtag_uart_context // void* context
                          );

        }
      }

      // If we get here, then we're done waiting, so clear the waiting flag
      jtag_uart_state &= ~JTAG_WAITING_BIT;

      if( my_jtag_uart_context == 1 )
      {
        // We got here because the timeout alarm fired, so set the abandoned flag
        jtag_uart_state |= JTAG_ABANDONED_BIT;
      }
    }
  }
#endif
  return ret_val;
}


/*****************************************************************************
*  Function: MyJtagWrite
*
*  Purpose:  This subroutine is provided so that we can write characters out
*  the JTAG UART without getting into a situation where we are permanently
*  blocked, because there is no host reading from the JTAG UART.  So this
*  routine takes the message that we want to write, and breaks it up into
*  8 byte or less chunks to send to MyJtagWrite8().  MyJtagWrite8()
*  makes sure that we can write to the jtag uart before attempting the write.
*
*****************************************************************************/
int MyJtagWrite(const char *buf, int len)
{
  int ret_val;
  int orig_len = len;

  if(len > 8)
  {
    // Our write message is greater than 8 bytes long, so break it up into
    // 8-byte or less chunks.
    do
    {
      ret_val = MyJtagWrite8( buf, (len > 8)?(8):(len));
      if(ret_val < 0)
      {
        // If an error returns then we're done
        break;
      }
      else
      {
        // No error, decrement our length, and increment the buffer
        len -= ret_val;
        buf += ret_val;
      }
    } while(len > 0);

    // Return the whole length of the buffer transmitted
    ret_val = orig_len;
  }
  else
  {
    // If the write message is less than 8 bytes, just write it.
    ret_val = MyJtagWrite8( buf, len);
  }

  return ret_val;
}


