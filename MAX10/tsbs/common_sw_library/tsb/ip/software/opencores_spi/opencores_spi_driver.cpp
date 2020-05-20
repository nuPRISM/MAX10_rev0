
/**
 * @file
 * Device driver for WB_SPI peripheral.
 *
 */

#include <stdlib.h>
//#include <assert.h>
//#include <time.h>
#include "basedef.h"
#include "opencores_spi_driver.h"
#include "linnux_utils.h"

extern "C" {
#include "xprintf.h"
}

#define SPI_WORD(BASE)      ((volatile unsigned long *)(BASE))

#define SPI_DATA32_READ(BASE)           internal_read_io_32_bits(BASE,0)
#define SPI_DATA32_WRITE(BASE,data)     internal_write_io_32_bits(BASE,0,data)

#define SPI_CTRL_WRITE(BASE,data)     internal_write_io_32_bits(BASE,0x10,data) /**< Control register */
#define SPI_STAT_WRITE(BASE,data)     internal_write_io_32_bits(BASE,0x10,data)   /**< Status register */
#define SPI_CDIV_WRITE(BASE,data)     internal_write_io_32_bits(BASE,0x14,data)  /**< Clock divisor register */
#define SPI_CS_WRITE(BASE,data)     internal_write_io_32_bits(BASE,0x18,data)  /**< Chip Select output pins */

#define SPI_CTRL_READ(BASE)     internal_read_io_32_bits(BASE,0x10) /**< Control register */
#define SPI_STAT_READ(BASE)     internal_read_io_32_bits(BASE,0x10)   /**< Status register */
#define SPI_CDIV_READ(BASE)     internal_read_io_32_bits(BASE,0x14)  /**< Clock divisor register */
#define SPI_CS_READ(BASE)     internal_read_io_32_bits(BASE,0x18)  /**< Chip Select output pins */


#define SPI_CTRL_LSB_FIRST         0x800            /**< Endianess. Use big-endianess for multi-byte writes */
#define SPI_CTRL_INITIATE_TRANSFER 0x100

#define SPI_STAT_BUSY       0x100            /**< Controller busy status flag. Set while a transfer is underway (FSM has left the IDLE state) */
#define DRV_SPI_INSTANCE_CHANNELS_MAX 8
#define DRV_SPI_INSTANCE_COUNT 1
#ifndef DEBUG_OPENCORES_SPI_SOFTWARE
#define DEBUG_OPENCORES_SPI_SOFTWARE (0)
#endif

#define debug_xprintf(...) do { if (DEBUG_OPENCORES_SPI_SOFTWARE) { xprintf(__VA_ARGS__); } } while (0)

unsigned long opencores_spi_driver::internal_read_io_32_bits(unsigned long addr,unsigned long byte_offset) {
	if (this->get_io_rw_interface_ptr() == NULL) {
	    return IORD_32DIRECT(addr,byte_offset);
	} else {
		return this->get_io_rw_interface_ptr()->read(addr+byte_offset/4);
	}
}

void opencores_spi_driver::internal_write_io_32_bits(unsigned long addr, unsigned long byte_offset, unsigned long data) {
	if (this->get_io_rw_interface_ptr() == NULL) {
		    IOWR_32DIRECT(addr,byte_offset,data);
		} else {
			this->get_io_rw_interface_ptr()->write(addr+byte_offset/4,data);
		}
};

void opencores_spi_driver::threadwait()
{
	low_level_system_timestamp();
}

unsigned long opencores_spi_driver::spi_calc_cdiv( unsigned long baudrate )
{
    unsigned long cdiv;
    cdiv = base_clock_rate / (baudrate * 2);
    if (((base_clock_rate / cdiv) >> 1) > baudrate ) cdiv++;
    if ( cdiv == 0 ) cdiv = 1;
    return cdiv - 1;
}

/**
 * @brief    Open an instance of the driver
 *
 * This function initializes the WB_SPI core and its driver.
 * You should call it only once per instantiation.
 *
 * @param  id  valid driver id
 * @return Driver pointer if succesful initialization, NULL otherwise
 */

void opencores_spi_driver::spi_open( unsigned long CTRL_SETTINGS, unsigned baudrate)
{
    
    // Initialize the core: set baudrate
    spi_set_baudrate( baudrate );

    SPI_CTRL_WRITE( baseaddress, CTRL_SETTINGS);
    
}

void opencores_spi_driver::set_cs_word(unsigned cs_word) {
    SPI_CS_WRITE  ( baseaddress,cs_word ); //enable CS
}

unsigned long opencores_spi_driver::get_cs_word() {
	return SPI_CS_READ (baseaddress);
}

/**
 * @brief    Sets the baudrate of the SPI core
 *
 * This function sets the baudrate of the SPI core
 *
 * @param  drv  Driver pointer as returned from spi_open
 * @param   baudrate New baudrate to be used in bps
 *
 * @return Nothing
 */

void opencores_spi_driver::spi_set_baudrate( unsigned long baudrate )
{

    SPI_CDIV_WRITE ( baseaddress, spi_calc_cdiv( baudrate ));
}



/**
 * @brief    Retrieves the actual baudrate of the SPI core
 *
 * This function retrieves the actual baudrate of the SPI core
 *
 * @param  drv  Driver pointer as returned from spi_open
 *
 * @return Actual baudrate used, in bps
 */

unsigned long opencores_spi_driver::spi_get_baudrate( )
{
    return (base_clock_rate / (SPI_CDIV_READ( baseaddress ) + 1)) / 2;
}

/**
 * @brief    Sets the endianess of the SPI core
 *
 * This function switches multibyte actions of the SPI core
 * to little endian or to big endian. This defines which byte
 * in a multibyte transfer is send first and where received
 * bytes are stored in the receiver word. Little endian: shifts
 * out bits 7 to 0 first, big endian shifts bits 7 to 0 last.
 *
 * Note: This only sets the endianness of the transfers over SPI,
 * and is not related to the endianness of the CPU. The endianness
 * is set to big endian by default by the spi_open() routine.
 *
 * @param  drv  Driver pointer as returned from spi_open
 * @param   endianess false: little endian, big endian otherwise
 *
 * @return Nothing
 */

void opencores_spi_driver::spi_set_endianess( bool endianess )
{
    if ( endianess )
    {
        SPI_CTRL_WRITE( baseaddress, SPI_CTRL_READ(baseaddress) & (~SPI_CTRL_LSB_FIRST) );
//        bigendian = 1;
    }
    else
    {
    	SPI_CTRL_WRITE( baseaddress, SPI_CTRL_READ(baseaddress) | SPI_CTRL_LSB_FIRST );

//        bigendian = 0;
    }
}


unsigned long opencores_spi_driver::spi_transfer_byte(unsigned long val)
{

	unsigned long retval;
	val &= 0xFF;
	retval = spi_transceive32(val);
	retval &= 0xFF;
	debug_xprintf("spi_transfer_byte: Tx of byte 0x%x got 0x%x\n",  val, retval);
	return retval;
};

/**
 * @brief    Transmit and receive a word
 *
 * This function transmits one word (four bytes) over SPI, waits
 * for its completion and returns what is sent back by the slave.
 * Use this function if you just want is to receive; make sure you
 * send 0xFFFFFFFF
 *
 * If big endianess is selected, transfer bits 31 down to to 0.
 * If small endianess is selected, bits 7 to 0 are transferred
 * first, than 15 to 8, than 23 to 16 and finally bits 31 to 24.
 *
 * @param  drv  Driver pointer as returned from spi_open
 * @param  val  Value to be send to the slave
 *
 * @return Nothing
 */

unsigned long opencores_spi_driver::spi_transceive32( unsigned long val )
{


	unsigned long long 	start_timestamp;
	unsigned long long 	end_timestamp;
	unsigned long long 	timestamp_difference;
	unsigned long ret = 0;
int cpu_sr;

    OS_ENTER_CRITICAL();

	start_timestamp       = low_level_system_timestamp();

    while( SPI_STAT_READ( baseaddress ) & SPI_STAT_BUSY ) {
    	  threadwait();

    	  end_timestamp=low_level_system_timestamp();
    	  if (start_timestamp > end_timestamp) {
    		  /* in case of some weird timer wrap */ start_timestamp = end_timestamp;
    	  }

    	  timestamp_difference = (end_timestamp - start_timestamp);
    	  if (timestamp_difference > LINNUX_OPENCORES_SPI_TIMEOUT_TICKS) {
    		  OS_EXIT_CRITICAL();
    		  xprintf("Error: timeout in spi_transceive32 checkpoint 1\n");
    		  return 0;
    	  }
    }
    OS_EXIT_CRITICAL();

    SPI_DATA32_WRITE( baseaddress,val);

    unsigned long ctrl = SPI_CTRL_READ ( baseaddress );

    ctrl |= SPI_CTRL_INITIATE_TRANSFER;

    SPI_CTRL_WRITE ( baseaddress,ctrl);

    OS_ENTER_CRITICAL();
    start_timestamp       = low_level_system_timestamp();
    while( SPI_STAT_READ( baseaddress ) & SPI_STAT_BUSY ) {
	  threadwait();

  	  end_timestamp=low_level_system_timestamp();
  	  if (start_timestamp > end_timestamp) {
  		  /* in case of some weird timer wrap */  start_timestamp = end_timestamp;
  	  }

  	  timestamp_difference = (end_timestamp - start_timestamp);
  	  if (timestamp_difference > LINNUX_OPENCORES_SPI_TIMEOUT_TICKS) {
  		  OS_EXIT_CRITICAL();
  		  xprintf("Error: timeout in spi_transceive32 checkpoint 2\n");
  		  return 0;
  	  }
    }
    OS_EXIT_CRITICAL();

    ret = SPI_DATA32_READ( baseaddress );
    return ret;
}

/**
 * @brief    Get a word from the receiver register
 *
 * This function reads the receiver register from the core, which is
 * filled during a previously started 32-bit transfer.
 *
 * @param  drv  Driver pointer as returned from spi_open
 *
 * @return byte as received from the slave
 */

unsigned long opencores_spi_driver::spi_received32( )
{
    return SPI_DATA32_READ( baseaddress );
}

/**
 * @brief   Checks if the SPI core is busy
 *
 * This function checks if the SPI core is busy (i.e.: not idle)
 *
 * @param drv   Driver pointer as returned from spi_open
 *
 * @return false if the core is idle, true if transfer is in progress
 */

bool opencores_spi_driver::spi_busy( )
{
    return ( SPI_STAT_READ( baseaddress ) & SPI_STAT_BUSY ) ? true : false;
}


unsigned long opencores_spi_driver::bedrock_SPI_TransferData( unsigned long cs_word, char txSize, char* txBuf, char rxSize, char* rxBuf, bool sdio_en_control, int byte_to_switch_in)
{
	if (use_activity_indication) {
		if (activity_indicator_encapsulator != NULL) {
			this->activity_indicator_encapsulator->turn_on_bit(0);
		} else {
			   xprintf("Error: opencores_spi_driver::SPI_TransferData(%s) activity_indicator_encapsulator is null but is being used!\n",this->get_description().c_str());
	    }
	}
    this->set_cs_word(cs_word);
    int i = 0;
    char rx_data;
    for  (i = 0; i < txSize; i++) {
    	if (sdio_en_control && this->isuse_sdio_helper()) {
    		if (i < byte_to_switch_in) {
    			if (this->sdio_helper_encapsulator != NULL) {
                  this->sdio_helper_encapsulator->turn_off_bit(0); //low = output enabled
    			} else {
    				 xprintf("Error: opencores_spi_driver::SPI_TransferData(%s) sdio helper is null but is being used!\n",this->get_description().c_str());
    			}
    		} else {
    			if (this->sdio_helper_encapsulator != NULL) {
    			   this->sdio_helper_encapsulator->turn_on_bit(0); //high = output disabled
    			} else {
    			   xprintf("Error: opencores_spi_driver::SPI_TransferData(%s) sdio helper is null but is being used!\n",this->get_description().c_str());
    			}
    		}
    	}
    	if (this->get_debug_tag_word_encapsulator() != NULL) {
    	this->get_debug_tag_word_encapsulator()->write(i+1); //for signal tap triggering
    	} else {
    		xprintf("get_debug_tag_word_encapsulator() returned NULL!!!\n");
    	}
    	rx_data = spi_transceive32( txBuf[i] );
    	debug_xprintf("SPI_TransferData: Tx of byte 0x%x got 0x%x\n",  txBuf[i], rx_data);
    	if (i < rxSize) {
    		rxBuf[i] = rx_data;
    	}



    }
    if (use_activity_indication) {
    	if (activity_indicator_encapsulator != NULL) {
    		this->activity_indicator_encapsulator->turn_off_bit(0);
    	} else {
    		   xprintf("Error: opencores_spi_driver::SPI_TransferData(%s) activity_indicator_encapsulator is null but is being used!\n",this->get_description().c_str());
    	   }
    }
    return 1;
}


unsigned long opencores_spi_driver::SPI_TransferData( unsigned long cs_word, char txSize, char* txBuf, char rxSize, char* rxBuf, bool sdio_en_control, int byte_to_switch_in)
{
	lock();
	bedrock_SPI_TransferData(cs_word,txSize,txBuf,rxSize,rxBuf,sdio_en_control,byte_to_switch_in);
    unlock();
    return 1;
}

