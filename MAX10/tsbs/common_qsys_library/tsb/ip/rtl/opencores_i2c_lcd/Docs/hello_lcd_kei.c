/* these test were created to show how to use the opencores I2C along with a driver found in
 * the opencores_I2C component to talk to various components.
 * This test example uses a littel daughter board from microtronix
 * it has a I2c to parallel chip (PCA9554A) a EEPORM and real time clock.
 * I chose not to impliment the real time clock.
 * But you can see how the calls work
 * There are only 4 functions associalted with the I2C driver
 * I2C start  -  send start bit and address of the chip
 * opencores_lcd_I2C_read - read data
 * opencores_lcd_I2C_write. - write data
 * how and when each of these get used is based on the device you
 * are talking to.
 * See the driver code for details of each function.
 * */

#include <stdio.h>
#include "system.h"
#include "opencores_i2c_lcd.h"
#include <unistd.h>
int main()
{
    int data;
    int i;
    // testing the PCA9554A paralle interface
    // this writes a 5 to the leds and read the position of the dip switches.
// printf(" tesing the PCA9554A interface the\n the LEDS should be at a 5 \n");
 // address 0x38
 // set the fequesncy that you want to run at
 // most devices work at 100Khz  some faster
    opencores_lcd_I2C_init(OPENCORES_I2C_LCD_BASE,ALT_CPU_FREQ,100000);
    opencores_lcd_I2C_init(OPENCORES_I2C_LCD_BASE,ALT_CPU_FREQ,100000);

 clear_lcd();
 set_backlight();
 show_cursor();

 write_char('y');
newline();
 write_char('o');

clear_lcd();

 write_string("ooga-");
newline();
 write_string("booga");
newline();
clear_lcd();

/*
// test write bottom line:
opencores_lcd_I2C_start(OPENCORES_I2C_LCD_BASE,0x28,0);// chip address in write mode
opencores_lcd_I2C_write(OPENCORES_I2C_LCD_BASE, 0x46,0x0); usleep(100); // F
opencores_lcd_I2C_write(OPENCORES_I2C_LCD_BASE, 0x50,0x0); usleep(100); // P
opencores_lcd_I2C_write(OPENCORES_I2C_LCD_BASE, 0x47,0x0); usleep(100); // G
opencores_lcd_I2C_write(OPENCORES_I2C_LCD_BASE, 0x41,0x0); usleep(100); // A
opencores_lcd_I2C_write(OPENCORES_I2C_LCD_BASE, 0x20,0x0); usleep(100); //
opencores_lcd_I2C_write(OPENCORES_I2C_LCD_BASE, 0x44,0x0); usleep(100); // D
opencores_lcd_I2C_write(OPENCORES_I2C_LCD_BASE, 0x65,0x0); usleep(100); // e
opencores_lcd_I2C_write(OPENCORES_I2C_LCD_BASE, 0x76,0x0); usleep(100); // v
opencores_lcd_I2C_write(OPENCORES_I2C_LCD_BASE, 0x6b,0x0); usleep(100); // k
opencores_lcd_I2C_write(OPENCORES_I2C_LCD_BASE, 0x69,0x0); usleep(100); // i
opencores_lcd_I2C_write(OPENCORES_I2C_LCD_BASE, 0x74,0x0); usleep(100); // t
*/


  printf("Hello from Nios II!\n");

  return 0;
}
