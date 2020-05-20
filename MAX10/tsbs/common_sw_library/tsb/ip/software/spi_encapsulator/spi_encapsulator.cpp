/*
 * spi_encapsulator.cpp
 *
 *  Created on: Mar 15, 2013
 *      Author: yairlinn
 */

#include "spi_encapsulator.h"
#include "altera_avalon_spi_regs.h"
#include "altera_avalon_spi.h"



int alt_avalon_spi_16bit_command(alt_u32 base, alt_u32 slave,
                           alt_u32 write_length, const alt_u16 * write_data,
                           alt_u32 read_length, alt_u16 * read_data,
                           alt_u32 flags)
{
  const alt_u16 * write_end = write_data + write_length;
  alt_u16 * read_end = read_data + read_length;

  alt_u32 write_zeros = read_length;
  alt_u32 read_ignore = write_length;
  alt_u32 status;

  /* We must not send more than two bytes to the target before it has
   * returned any as otherwise it will overflow. */
  /* Unfortunately the hardware does not seem to work with credits > 1,
   * leave it at 1 for now. */
  alt_32 credits = 1;

  /* Warning: this function is not currently safe if called in a multi-threaded
   * environment, something above must perform locking to make it safe if more
   * than one thread intends to use it.
   */

  IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(base, 1 << slave);

  /* Set the SSO bit (force chipselect) only if the toggle flag is not set */
  if ((flags & ALT_AVALON_SPI_COMMAND_TOGGLE_SS_N) == 0) {
    IOWR_ALTERA_AVALON_SPI_CONTROL(base, ALTERA_AVALON_SPI_CONTROL_SSO_MSK);
  }

  /*
   * Discard any stale data present in the RXDATA register, in case
   * previous communication was interrupted and stale data was left
   * behind.
   */
  IORD_ALTERA_AVALON_SPI_RXDATA(base);

  /* Keep clocking until all the data has been processed. */
  for ( ; ; )
  {

    do
    {
      status = IORD_ALTERA_AVALON_SPI_STATUS(base);
    }
    while (((status & ALTERA_AVALON_SPI_STATUS_TRDY_MSK) == 0 || credits == 0) &&
            (status & ALTERA_AVALON_SPI_STATUS_RRDY_MSK) == 0);

    if ((status & ALTERA_AVALON_SPI_STATUS_TRDY_MSK) != 0 && credits > 0)
    {
      credits--;

      if (write_data < write_end)
        IOWR_ALTERA_AVALON_SPI_TXDATA(base, *write_data++);
      else if (write_zeros > 0)
      {
        write_zeros--;
        IOWR_ALTERA_AVALON_SPI_TXDATA(base, 0);
      }
      else
        credits = -1024;
    };

    if ((status & ALTERA_AVALON_SPI_STATUS_RRDY_MSK) != 0)
    {
      alt_u32 rxdata = IORD_ALTERA_AVALON_SPI_RXDATA(base);

      if (read_ignore > 0)
        read_ignore--;
      else
        *read_data++ = (alt_u8)rxdata;
      credits++;

      if (read_ignore == 0 && read_data == read_end)
        break;
    }

  }

  /* Wait until the interface has finished transmitting */
  do
  {
    status = IORD_ALTERA_AVALON_SPI_STATUS(base);
  }
  while ((status & ALTERA_AVALON_SPI_STATUS_TMT_MSK) == 0);

  /* Clear SSO (release chipselect) unless the caller is going to
   * keep using this chip
   */
  if ((flags & ALT_AVALON_SPI_COMMAND_MERGE) == 0)
    IOWR_ALTERA_AVALON_SPI_CONTROL(base, 0);

  return read_length;
}

spi_encapsulator::spi_encapsulator(unsigned long the_base_address) {
	base_address=the_base_address;
}

unsigned long spi_encapsulator::get_rxdata(){
	return IORD_ALTERA_AVALON_SPI_RXDATA(base_address);
};

unsigned long spi_encapsulator::get_txdata(){
	return IORD_ALTERA_AVALON_SPI_TXDATA(base_address);
};

int spi_encapsulator::transmit_byte(unsigned long slave_num, unsigned char byte_to_write)
{
	alt_u8 dummy;
	return alt_avalon_spi_command(base_address,
			slave_num,
            1, /* write_length */
            (alt_u8 *)&byte_to_write, /* write_data*/
            0, /* read_length*/
            &dummy, /* data*/
            0 /* flags*/
            );
}

int spi_encapsulator::read_byte(unsigned long slave_num, unsigned char& the_read_byte){
	alt_u8 dummy;
		return alt_avalon_spi_command(base_address,
				slave_num,
	            0, /* write_length */
	            (alt_u8 *)&dummy, /* write_data*/
	            1, /* read_length*/
	            (alt_u8 *)&the_read_byte, /* data*/
	            0 /* flags*/
	           );
};

int spi_encapsulator::transmit_16bit(unsigned long slave_num, alt_u16 val) {
	alt_u16 dummy;
	return alt_avalon_spi_16bit_command(base_address,
				slave_num,
	            1, /* write_length */
	            (alt_u16 *)&val, /* write_data*/
	            0, /* read_length*/
	            &dummy, /* data*/
	            0 /* flags*/
	            );
}


int spi_encapsulator::read_16bit(unsigned long slave_num, alt_u16& val) {
	alt_u16 dummy;
	int result = alt_avalon_spi_16bit_command(base_address,
	  slave_num,
	  0, /* write_length */
	  (alt_u16 *)&dummy, /* write_data*/
	  1, /* read_length*/
	  (alt_u16 *)&val, /* data*/
	  0 /* flags*/
	 );
	return result;
}
