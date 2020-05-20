
#include "alt_types.h"
#include "i2c_opencores_yair_regs.h"
#include "i2c_opencores_yair.h"
#ifdef __ucosii__
#include "includes.h"
#include "ucos_ii.h"
#endif

#ifndef __ucosii__
#define OS_EXIT_CRITICAL() do {} while(0)
#define OS_ENTER_CRITICAL() do {} while(0)
#endif

// #define I2C_DEBUG
//int I2C_YAIR_init(alt_u32 base,alt_u32 clk, alt_u32 speed)
//int I2C_YAIR_start(alt_u32 base, alt_u32 add, alt_u32 write);
//alt_u32 I2C_YAIR_read(alt_u32 base);
//int I2C_YAIR_write(alt_u32 base, alt_u8 data);
//int I2C_YAIR_stop(alt_u32 base);

/* these functions are polled only.  */
/* all functions wait until the I2C is done before exiting */


void i2c_opencores_device_encapsulator_init(i2c_opencores_device_encapsulator* s, 	
    alt_u32 base_address,
	alt_u32 device_address,
	const char* name,
	void* additional_info,
	alt_u32 index,
	i2c_opencores_device_encapsulator *next) {
	s->base_address = base_address;
	s->device_address = device_address;
	s->name = name;
	s->additional_info = additional_info;
	s->index = index;
	s->next = next;
}

char* i2c_opencores_device_encapsulator_get_name(i2c_opencores_device_encapsulator* s) {
	return s->name;
}

alt_u32 i2c_opencores_device_encapsulator_get_base_address(i2c_opencores_device_encapsulator* s) {
    return s->base_address;
}

alt_u32  i2c_opencores_device_encapsulator_get_device_address(i2c_opencores_device_encapsulator* s){
    return s->device_address;
}

void i2c_opencores_device_encapsulator_set_additional_info(i2c_opencores_device_encapsulator* s, void* additional_info){
    s->additional_info = additional_info;
}

void* i2c_opencores_device_encapsulator_get_additional_info(i2c_opencores_device_encapsulator* s){
    return s->additional_info;
}

i2c_opencores_device_encapsulator* i2c_opencores_device_encapsulator_get_next(i2c_opencores_device_encapsulator* s) {
	return s->next;
}
	
/****************************************************************
int I2C_YAIR_init
            This function inititlizes the prescalor for the scl
            and then enables the core. This must be run before
            any other i2c code is executed
inputs
      base = the base address of the component
      clk = freuqency of the clock driving this component  ( in Hz)
      speed = SCL speed ie 100K, 400K ...            (in Hz)
15-OCT-07 initial release
*****************************************************************/
 void I2C_YAIR_init(alt_u32 base,alt_u32 clk,alt_u32 speed)
{
  unsigned long long 	start_timestamp;
  unsigned long long 	end_timestamp;
  unsigned long long 	timestamp_difference;
  int cpu_sr;
  OS_ENTER_CRITICAL();

  alt_u32 prescale = (clk/( 5 * speed))-1;
#ifdef  I2C_DEBUG
        OS_EXIT_CRITICAL();
        xprintf(" Initializing  I2C at 0x%x, \n\twith clock speed 0x%x \n\tand SCL speed 0x%x \n\tand prescale 0x%x\n",base,clk,speed,prescale);
        OS_ENTER_CRITICAL();
#endif
  IOWR_I2C_OPENCORES_YAIR_CTR(base, 0x00); /* turn off the core*/

  IOWR_I2C_OPENCORES_YAIR_CR(base, I2C_OPENCORES_YAIR_CR_IACK_MSK); /* clearn any pening IRQ*/

  IOWR_I2C_OPENCORES_YAIR_PRERLO(base, (0xff & prescale));  /* load low presacle bit*/

  IOWR_I2C_OPENCORES_YAIR_PRERHI(base, (0xff & (prescale>>8)));  /* load upper prescale bit */

  IOWR_I2C_OPENCORES_YAIR_CTR(base, I2C_OPENCORES_YAIR_CTR_EN_MSK); /* turn on the core*/

OS_EXIT_CRITICAL();
}

/****************************************************************
int I2C_start
            Sets the start bit and then sends the first byte which
            is the address of the device + the write bit.
inputs
      base = the base address of the component
      add = address of I2C device
      read =  1== read    0== write
return value
       0 if address is acknowledged
       1 if address was not acknowledged
15-OCT-07 initial release
*****************************************************************/
 int I2C_YAIR_start(alt_u32 base, alt_u32 add, alt_u32 read)
{
	unsigned long long 	start_timestamp;
	unsigned long long 	end_timestamp;
	unsigned long long 	timestamp_difference;
	int cpu_sr;

	OS_ENTER_CRITICAL();

#ifdef  I2C_DEBUG
        OS_EXIT_CRITICAL();
        xprintf(" Start  I2C at 0x%x, \n\twith address 0x%x \n\tand read 0x%x \n\t",(unsigned) base,(unsigned) add,(unsigned) read);
        OS_ENTER_CRITICAL();
#endif

          /* transmit the address shifted by one and the read/write bit*/
  IOWR_I2C_OPENCORES_YAIR_TXR(base, ((add<<1) + (0x1 & read)));

          /* set start and write  bits which will start the transaction*/
  IOWR_I2C_OPENCORES_YAIR_CR(base, I2C_OPENCORES_YAIR_CR_STA_MSK | I2C_OPENCORES_YAIR_CR_WR_MSK );

          /* wait for the trnasaction to be over.*/
  while( IORD_I2C_OPENCORES_YAIR_SR(base) & I2C_OPENCORES_YAIR_SR_TIP_MSK);

         /* now check to see if the address was acknowledged */
   if(IORD_I2C_OPENCORES_YAIR_SR(base) & I2C_OPENCORES_YAIR_SR_RXNACK_MSK)
   {
#ifdef  I2C_DEBUG
		OS_EXIT_CRITICAL();
        xprintf("\tNOACK\n");
        OS_ENTER_CRITICAL();
#endif
        OS_EXIT_CRITICAL();
        return (I2C_YAIR_NOACK);
   }
   else
   {
#ifdef  I2C_DEBUG
		OS_EXIT_CRITICAL();
        xprintf("\tACK\n");
        OS_ENTER_CRITICAL();
#endif
       OS_EXIT_CRITICAL();
       return (I2C_YAIR_ACK);
   }
}

/****************************************************************
int I2C_YAIR_read
            assumes that any addressing and start
            has already been done.
            reads one byte of data from the slave.  on the last read
            we don't acknowldge and set the stop bit.
inputs
      base = the base address of the component
      last = on the last read there must not be a ack

return value
       byte read back.
15-OCT-07 initial release
*****************************************************************/
 alt_u32 I2C_YAIR_read(alt_u32 base,alt_u32 last)
{
	unsigned long long 	start_timestamp;
	unsigned long long 	end_timestamp;
	unsigned long long 	timestamp_difference;
	int cpu_sr;
    OS_ENTER_CRITICAL();
#ifdef  I2C_DEBUG
        OS_EXIT_CRITICAL();
        xprintf(" Read I2C at 0x%x, \n\twith last0x%x\n",base,last);
        OS_ENTER_CRITICAL();
#endif
  if( last)
  {
               /* start a read and no ack and stop bit*/
           IOWR_I2C_OPENCORES_YAIR_CR(base, I2C_OPENCORES_YAIR_CR_RD_MSK |
               I2C_OPENCORES_YAIR_CR_NACK_MSK | I2C_OPENCORES_YAIR_CR_STO_MSK);
  }
  else
  {
          /* start read*/
          IOWR_I2C_OPENCORES_YAIR_CR(base, I2C_OPENCORES_YAIR_CR_RD_MSK );
  }
          /* wait for the trnasaction to be over.*/
  while( IORD_I2C_OPENCORES_YAIR_SR(base) & I2C_OPENCORES_YAIR_SR_TIP_MSK);

         /* now read the data */
 alt_u32 the_read_data;     /* now read the data */
  the_read_data =  IORD_I2C_OPENCORES_YAIR_RXR(base);
#ifdef  I2C_DEBUG
        OS_EXIT_CRITICAL();
        xprintf(" \tgot 0x%x\n",the_read_data);
        OS_ENTER_CRITICAL();
#endif
        OS_EXIT_CRITICAL();
        return (the_read_data);       

}

/****************************************************************
int I2C_YAIR_write
            assumes that any addressing and start
            has already been done.
            writes one byte of data from the slave.  
            If last is set the stop bit set.
inputs
      base = the base address of the component
      data = byte to write
      last = on the last read there must not be a ack

return value
       0 if address is acknowledged
       1 if address was not acknowledged
15-OCT-07 initial release
*****************************************************************/
 alt_u32 I2C_YAIR_write(alt_u32 base,alt_u8 data, alt_u32 last)
{

	unsigned long long 	start_timestamp;
	unsigned long long 	end_timestamp;
	unsigned long long 	timestamp_difference;
	int cpu_sr;
    OS_ENTER_CRITICAL();
  #ifdef  I2C_DEBUG
        OS_EXIT_CRITICAL();
        xprintf(" Write I2C at 0x%x, \n\twith data 0x%x,\n\twith last0x%x\n",base,data,last);
        OS_ENTER_CRITICAL();
#endif
                 /* transmit the data*/
  IOWR_I2C_OPENCORES_YAIR_TXR(base, data);

  if( last)
  {
               /* start a read and no ack and stop bit*/
           IOWR_I2C_OPENCORES_YAIR_CR(base, I2C_OPENCORES_YAIR_CR_WR_MSK |
               I2C_OPENCORES_YAIR_CR_STO_MSK);
  }
  else
  {
          /* start read*/
          IOWR_I2C_OPENCORES_YAIR_CR(base, I2C_OPENCORES_YAIR_CR_WR_MSK );
  }
           /* wait for the trnasaction to be over.*/
  while( IORD_I2C_OPENCORES_YAIR_SR(base) & I2C_OPENCORES_YAIR_SR_TIP_MSK);

         /* now check to see if the address was acknowledged */
   if(IORD_I2C_OPENCORES_YAIR_SR(base) & I2C_OPENCORES_YAIR_SR_RXNACK_MSK)
   {
#ifdef  I2C_DEBUG
	    OS_EXIT_CRITICAL();
        xprintf("\tNOACK\n");
        OS_ENTER_CRITICAL();
#endif
        OS_EXIT_CRITICAL();
        return (I2C_YAIR_NOACK);
   }
   else
   {
#ifdef  I2C_DEBUG
        OS_EXIT_CRITICAL();
        xprintf("\tACK\n");
        OS_ENTER_CRITICAL();
#endif
       OS_EXIT_CRITICAL();
       return (I2C_YAIR_ACK);
   }

}
