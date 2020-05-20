#ifndef __OPENCORES_I2C_LCD_H__
#define __OPENCORES_I2C_LCD_H__

#include "alt_types.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

#define SLEEP_DELAY 444
void set_opencores_lcd_base(alt_u32 base);
void opencores_lcd_I2C_init(alt_u32 base,alt_u32 clk,alt_u32 speed);
int opencores_lcd_I2C_start(alt_u32 base, alt_u32 add, alt_u32 read);
alt_u32 opencores_lcd_I2C_read(alt_u32 base,alt_u32 last);
alt_u32 opencores_lcd_I2C_write(alt_u32 base,alt_u8 data, alt_u32 last);

void clear_lcd();
void set_backlight();
void show_cursor();
void newline();
void write_char(unsigned char c);
void write_string(const char* c);
void write_box(void);

char* itoa(int val, int base);

#define opencores_lcd_I2C_OK (0)
#define opencores_lcd_I2C_ACK (0)
#define opencores_lcd_I2C_NOACK (1)
#define opencores_lcd_I2C_ABITRATION_LOST (2)

#define OPENCORES_I2C_LCD_INSTANCE(name, dev) extern int alt_no_storage
#define OPENCORES_I2C_LCD_INIT(name, dev) while (0)

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __OPENCORES_I2C_LCD_H__ */
