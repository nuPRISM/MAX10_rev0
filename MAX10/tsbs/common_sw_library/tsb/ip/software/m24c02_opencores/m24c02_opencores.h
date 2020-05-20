
#ifndef M24C02_OPENCORES_H_
#define M24C02_OPENCORES_H_
#include "i2c_opencores_yair.h"

int     m24c02_opencores_reg_write_8_bit   (alt_u32 base, alt_u8 E2E1E0, alt_u32 reg_address, alt_u8 data);
alt_u8  m24c02_opencores_reg_read_8_bit    (alt_u32 base, alt_u8 E2E1E0, alt_u32 reg_address) ;


#endif /* M24M02_H_ */
