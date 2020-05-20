
#include "alt_types.h"
#include "opencores_i2c_lcd_regs.h"
#include "opencores_i2c_lcd.h"
#include <unistd.h>

// added for new init functions
#include <stdio.h>
#include "system.h"

static alt_u32 opencores_i2c_lcd_base;
void set_opencores_lcd_base(alt_u32 base) {
	opencores_i2c_lcd_base = base;
}
/****************************************************************
int opencores_lcd_I2C_init
            This function inititlizes the prescalor for the scl
            and then enables the core. This must be run before
            any other i2c code is executed
inputs
      base = the base address of the component
      clk = freuqency of the clock driving this component  ( in Hz)
      speed = SCL speed ie 100K, 400K ...            (in Hz)
15-OCT-07 initial release
*****************************************************************/
void opencores_lcd_I2C_init(alt_u32 base,alt_u32 clk,alt_u32 speed)
{
  alt_u32 prescale = (clk/( 5 * speed))-1;
#ifdef  I2C_DEBUG
        printf(" Initializing  I2C at 0x%x, \n\twith clock speed 0x%x \n\tand SCL speed 0x%x \n\tand prescale 0x%x\n",base,clk,speed,prescale);
#endif
  IOWR_OPENCORES_I2C_LCD_CTR(base, 0x00); /* turn off the core*/
  IOWR_OPENCORES_I2C_LCD_CR(base, OPENCORES_I2C_LCD_CR_IACK_MSK); /* clearn any pening IRQ*/
  IOWR_OPENCORES_I2C_LCD_PRERLO(base, (0xff & prescale));  /* load low presacle bit*/
  IOWR_OPENCORES_I2C_LCD_PRERHI(base, (0xff & (prescale>>8)));  /* load upper prescale bit */
  IOWR_OPENCORES_I2C_LCD_CTR(base, OPENCORES_I2C_LCD_CTR_EN_MSK); /* turn on the core*/
  usleep(SLEEP_DELAY); // debug

}

/****************************************************************
int opencores_lcd_I2C_start
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
int opencores_lcd_I2C_start(alt_u32 base, alt_u32 add, alt_u32 read)
{
#ifdef  I2C_DEBUG
        printf(" Start  I2C at 0x%x, \n\twith address 0x%x \n\tand read 0x%x \n\tand prescale 0x%x\n",base,add,read);
#endif

          /* transmit the address shifted by one and the read/write bit*/
  IOWR_OPENCORES_I2C_LCD_TXR(base, ((add<<1) + (0x1 & read)));

          /* set start and write  bits which will start the transaction*/
  IOWR_OPENCORES_I2C_LCD_CR(base, OPENCORES_I2C_LCD_CR_STA_MSK | OPENCORES_I2C_LCD_CR_WR_MSK );

          /* wait for the trnasaction to be over.*/
  while( IORD_OPENCORES_I2C_LCD_SR(base) & OPENCORES_I2C_LCD_SR_TIP_MSK);

         /* now check to see if the address was acknowledged */
   if(IORD_OPENCORES_I2C_LCD_SR(base) & OPENCORES_I2C_LCD_SR_RXNACK_MSK)
   {
#ifdef  I2C_DEBUG
        printf("\tNOACK\n");
#endif
        return (opencores_lcd_I2C_NOACK);
   }
   else
   {
#ifdef  I2C_DEBUG
        printf("\tACK\n");
#endif
       return (opencores_lcd_I2C_ACK);
   }
}


/****************************************************************
int opencores_lcd_I2C_write
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
alt_u32 opencores_lcd_I2C_write(alt_u32 base,alt_u8 data, alt_u32 last)
{
  #ifdef  I2C_DEBUG
        printf(" Read I2C at 0x%x, \n\twith data 0x%x,\n\twith last0x%x\n",base,data,last);
#endif
                 /* transmit the data*/
  IOWR_OPENCORES_I2C_LCD_TXR(base, data);

  if( last)
  {
               /* start a read and no ack and stop bit*/
           IOWR_OPENCORES_I2C_LCD_CR(base, OPENCORES_I2C_LCD_CR_WR_MSK |
               OPENCORES_I2C_LCD_CR_STO_MSK);
  }
  else
  {
          /* start read*/
          IOWR_OPENCORES_I2C_LCD_CR(base, OPENCORES_I2C_LCD_CR_WR_MSK );
  }
           /* wait for the trnasaction to be over.*/
  while( IORD_OPENCORES_I2C_LCD_SR(base) & OPENCORES_I2C_LCD_SR_TIP_MSK);

         /* now check to see if the address was acknowledged */
   if(IORD_OPENCORES_I2C_LCD_SR(base) & OPENCORES_I2C_LCD_SR_RXNACK_MSK)
   {
#ifdef  I2C_DEBUG
        printf("\tNOACK\n");
#endif
        return (opencores_lcd_I2C_NOACK);
   }
   else
   {
#ifdef  I2C_DEBUG
        printf("\tACK\n");
#endif
       return (opencores_lcd_I2C_ACK);
   }

}


/****************************************************************
int opencores_lcd_I2C_read
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
alt_u32 opencores_lcd_I2C_read(alt_u32 base,alt_u32 last)
{
#ifdef  I2C_DEBUG
        printf(" Read I2C at 0x%x, \n\twith last0x%x\n",base,last);
#endif
  if( last)
  {
               /* start a read and no ack and stop bit*/
           IOWR_OPENCORES_I2C_LCD_CR(base, OPENCORES_I2C_LCD_CR_RD_MSK |
               OPENCORES_I2C_LCD_CR_NACK_MSK | OPENCORES_I2C_LCD_CR_STO_MSK);
  }
  else
  {
          /* start read*/
          IOWR_OPENCORES_I2C_LCD_CR(base, OPENCORES_I2C_LCD_CR_RD_MSK );
  }
          /* wait for the trnasaction to be over.*/
  while( IORD_OPENCORES_I2C_LCD_SR(base) & OPENCORES_I2C_LCD_SR_TIP_MSK);

         /* now read the data */
        return (IORD_OPENCORES_I2C_LCD_RXR(base));

}

// clear the LCD
void clear_lcd(){
	opencores_lcd_I2C_start(opencores_i2c_lcd_base,0x28,0);  usleep(SLEEP_DELAY);
	opencores_lcd_I2C_write(opencores_i2c_lcd_base,0xFE,0x0); usleep(SLEEP_DELAY);
	opencores_lcd_I2C_write(opencores_i2c_lcd_base,0x51,0x0); usleep(SLEEP_DELAY);
	opencores_lcd_I2C_write(opencores_i2c_lcd_base,0x51,0x1); usleep(SLEEP_DELAY);
}

// set back light strength at here
void set_backlight(){
	opencores_lcd_I2C_start(opencores_i2c_lcd_base,0x28,0);  usleep(SLEEP_DELAY);
	opencores_lcd_I2C_write(opencores_i2c_lcd_base,0xFE,0x0); usleep(SLEEP_DELAY);
	opencores_lcd_I2C_write(opencores_i2c_lcd_base,0x53,0x0); usleep(SLEEP_DELAY);
	opencores_lcd_I2C_write(opencores_i2c_lcd_base,0x4,0x0); usleep(SLEEP_DELAY);
	opencores_lcd_I2C_write(opencores_i2c_lcd_base,0x4,0x1); usleep(SLEEP_DELAY);
}

void show_cursor(){
	 // show cursor under line
	 opencores_lcd_I2C_start(opencores_i2c_lcd_base,0x28,0);  usleep(SLEEP_DELAY); // chip address in write mode
	 opencores_lcd_I2C_write(opencores_i2c_lcd_base,0xFE,0x0); usleep(SLEEP_DELAY);
	 opencores_lcd_I2C_write(opencores_i2c_lcd_base,0x47,0x0); usleep(SLEEP_DELAY);
	 opencores_lcd_I2C_write(opencores_i2c_lcd_base,0x47,0x1); usleep(SLEEP_DELAY);
}

void newline(){
	// move to 2nd line (newline?)
	opencores_lcd_I2C_start(opencores_i2c_lcd_base,0x28,0); usleep(SLEEP_DELAY);
	opencores_lcd_I2C_write(opencores_i2c_lcd_base,0xFE,0x0); usleep(SLEEP_DELAY);
	opencores_lcd_I2C_write(opencores_i2c_lcd_base,0x45,0x0); usleep(SLEEP_DELAY);
	opencores_lcd_I2C_write(opencores_i2c_lcd_base,0x40,0x0); usleep(SLEEP_DELAY);
	opencores_lcd_I2C_write(opencores_i2c_lcd_base,0x40,0x1); usleep(SLEEP_DELAY);
}

void write_char(unsigned char c){
	opencores_lcd_I2C_start(opencores_i2c_lcd_base,0x28,0);// chip address in write mode
	opencores_lcd_I2C_write(opencores_i2c_lcd_base, c,0x0); usleep(SLEEP_DELAY); //
}

void write_box(void){
	opencores_lcd_I2C_start(opencores_i2c_lcd_base,0x28,0);// chip address in write mode
	opencores_lcd_I2C_write(opencores_i2c_lcd_base,0xFF,0x0); usleep(SLEEP_DELAY); //
}

void write_string(const char* c){
	int i = 0;
	opencores_lcd_I2C_start(opencores_i2c_lcd_base,0x28,0);// chip address in write mode
	usleep(SLEEP_DELAY);
	while(c[i] != 0){
	opencores_lcd_I2C_write(opencores_i2c_lcd_base, c[i],0x0);
	usleep(SLEEP_DELAY);
	i++;
	}
	newline();
}

char* itoa(int val, int base){

	static char buf[32] = {0};

	int i = 30;

	for(; val && i ; --i, val /= base)

		buf[i] = "0123456789abcdef"[val % base];

	return &buf[i+1];

}



