/*
 * adc12eu050_controller.cpp
 *
 *  Created on: Mar 20, 2013
 *      Author: yairlinn
 */

#include "basedef.h"
#include "adc12eu050_controller.h"
#include "linnux_testbench_constants.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

	int adc12eu050_controller::write_reg(alt_u16 regnum, alt_u16  val){
		alt_u16 new_val;
		if ((regnum % 2) != 0) {
			safe_print(std::cout << "Error:  adc12eu050_controller::write_reg: Received regnum " << regnum << " but regnum must be even!\n");
			return 0;
		}
		new_val = ((regnum & 0xFF) << 8) + (val & 0xFF);
		//safe_print(std::cout << "adc write: writing to reg: 0x" << std::hex << regnum << " val: " << new_val << " Slave_num = 0x" << slave_num << std::endl);
		return (spi_master->transmit_16bit(slave_num,new_val));
	};

	int adc12eu050_controller::read_reg(alt_u16 regnum, alt_u16& val){
		alt_u16 new_val;
		if ((regnum % 2) == 0) {
			safe_print(std::cout << "Error:  adc12eu050_controller::read_reg: Received regnum " << regnum << " but regnum must be odd!\n");
			return 0;
		}
		new_val = (regnum & 0xFF) << 8;
		int tx_result = spi_master->transmit_16bit(slave_num,new_val);
		val = spi_master->get_rxdata();
		//safe_print(std::cout << "adc read: spi tx: writing to reg: 0x" << std::hex << regnum << " val: 0x" << new_val << " Slave_num = 0x" << slave_num << " read_val: 0x" << val << std::endl);

        return tx_result;
	};

    void adc12eu050_controller::init(){
    	//write_reg(0,4); //enable open drain.
    	//turn_on_bit(0x18,1); //set common mode to 1.25V
    	sw_reset();
    	write_reg(0x18,0x1E); //set common mode to 1.25V, turn on TX termination, use max output current
    	write_reg(0x10,0x20);  //Low Pattern byte
    	write_reg(0x12,0xF);   //High Pattern byte

#ifdef WAKE_UP_ADCS_IN_PATTERN_MODE
    	write_reg(0x16,0x3);  //wake up in pattern mode
#else
    	write_reg(0x16,0);  //wake up in normal mode
#endif
    	write_reg(0x4,8);     //set saturation to 2.172V
    };

    void adc12eu050_controller::turn_on_bit(alt_u16 regnum, alt_u16 bit){
    	alt_u16 val;
    	read_reg(regnum+1,val);
    	val = val | (((alt_u16)1) << bit);
    	write_reg(regnum,val);
    };
    void adc12eu050_controller::turn_off_bit(alt_u16 regnum, alt_u16 bit){
    	alt_u16 val;
       	read_reg(regnum+1,val);
       	val = val & (~(((alt_u16)1) << bit));
       	write_reg(regnum,val);
    };

    void adc12eu050_controller::sw_reset() {
    	alt_u16 lower_byte;
    	alt_u16 upper_byte;
    	write_reg(0,0); //make sure reset bit is turned off
    	write_reg(0x10,0xBC);  //Low Pattern test byte
        write_reg(0x12,0xA);   //High Pattern test byte
        read_reg((alt_u16) 0x11, lower_byte);  //Low Pattern test byte
        read_reg((alt_u16) 0x13, upper_byte);   //High Pattern test byte

        if ((upper_byte != 0xA) || (lower_byte != 0xBC)) {
        	safe_print(std::cout << "Error: ADC slave# " << slave_num << " adc12eu050_controller::sw_reset did not read expected pattern 0xABC before reset!\n");
        } else {
        	safe_print(std::cout << "ADC slave# " << slave_num << " adc12eu050_controller::sw_reset read expected 0xABC before reset!\n");
        }

    	write_reg(0,8);
    	usleep(10); //make sure reset has occurred

    	read_reg((alt_u16) 0x11, lower_byte);  //Low Pattern test byte
    	read_reg((alt_u16) 0x13, upper_byte);   //High Pattern test byte

    	if ((upper_byte != 0) || (lower_byte != 0)) {
    		safe_print(std::cout << "Error: ADC slave# " << slave_num << " adc12eu050_controller::sw_reset did not read 0 after reset; reset may not have occurred!\n");
    	} else {
    		safe_print(std::cout << "ADC slave# " << slave_num << " adc12eu050_controller::sw_reset has been reset!\n");
    	}

    	write_reg(0,0); //make sure reset bit is turned off
    }



adc12eu050_controller::~adc12eu050_controller() {
	// TODO Auto-generated destructor stub
}
