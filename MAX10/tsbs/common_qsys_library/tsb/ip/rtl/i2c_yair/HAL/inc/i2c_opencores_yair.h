#ifndef __I2C_OPENCORES_YAIR_H__
#define __I2C_OPENCORES_YAIR_H__


#include "alt_types.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

#define  I2C_YAIR_100_KHZ 100000u
#define  I2C_YAIR_400_KHZ 400000u

void    I2C_YAIR_init(alt_u32 base,alt_u32 clk,alt_u32 speed);
int     I2C_YAIR_start(alt_u32 base, alt_u32 add, alt_u32 read);
alt_u32 I2C_YAIR_read(alt_u32 base,alt_u32 last);
alt_u32 I2C_YAIR_write(alt_u32 base,alt_u8 data, alt_u32 last);
#define I2C_YAIR_OK (0)
#define I2C_YAIR_ACK (0)
#define I2C_YAIR_NOACK (1)
#define I2C_YAIR_ABITRATION_LOST (2)

#define I2C_OPENCORES_YAIR_INSTANCE(name, dev) extern int alt_no_storage
#define I2C_OPENCORES_YAIR_INIT(name, dev) while (0)
	
typedef struct i2c_opencores_device_encapsulator_s {
	alt_u32 base_address;
	alt_u32 device_address;
	char* name;
	void* additional_info;
	alt_u32 index;
	struct i2c_opencores_devices_encapsulator_s *next;
} i2c_opencores_device_encapsulator;


void i2c_opencores_device_encapsulator_init(i2c_opencores_device_encapsulator* s, 	
    alt_u32 base_address,
	alt_u32 device_address,
	const char* name,
	void* additional_info,
	alt_u32 index,
	i2c_opencores_device_encapsulator *next
);

char* i2c_opencores_device_encapsulator_get_name(i2c_opencores_device_encapsulator* s);
alt_u32 i2c_opencores_device_encapsulator_get_base_address(i2c_opencores_device_encapsulator* s);
alt_u32 i2c_opencores_device_encapsulator_get_device_address(i2c_opencores_device_encapsulator* s);
void i2c_opencores_device_encapsulator_set_additional_info(i2c_opencores_device_encapsulator* s, void* additional_info);
void* i2c_opencores_device_encapsulator_get_additional_info(i2c_opencores_device_encapsulator* s);
i2c_opencores_device_encapsulator* i2c_opencores_device_encapsulator_get_next(i2c_opencores_device_encapsulator* s);


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __I2C_OPENCORES_YAIR_H__ */
