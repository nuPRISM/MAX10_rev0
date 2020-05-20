/*
 * adc12eu050_controller.h
 *
 *  Created on: Mar 20, 2013
 *      Author: yairlinn
 */

#ifndef ADC12EU050_CONTROLLER_H_
#define ADC12EU050_CONTROLLER_H_


#include "spi_encapsulator.h"

class adc12eu050_controller {
protected:
	unsigned long slave_num;
	spi_encapsulator* spi_master;
public:
	adc12eu050_controller(spi_encapsulator* the_spi_master){
		spi_master = the_spi_master;
	}
	void set_slave_num(unsigned long the_slave_num){
		slave_num = the_slave_num;
	};
	int write_reg(alt_u16 regnum, alt_u16 val);
	int read_reg(alt_u16 regnum, alt_u16& val);
    void  init();
    void  turn_on_bit(alt_u16 regnum, alt_u16 bit);
    void  turn_off_bit(alt_u16 regnum, alt_u16 bit);
    void sw_reset();
	virtual ~adc12eu050_controller();
};

#endif /* ADC12EU050_CONTROLLER_H_ */
