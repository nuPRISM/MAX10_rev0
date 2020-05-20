/*
 * lmk04816uwire.cpp
 *
 *  Created on: Nov 21, 2016
 *      Author: yairlinn
 */

#include "lmk04816uwire.h"
#include "ucos_ii.h"

lmk04816_uwire::lmk04816_uwire(unsigned long lmk_clk_base, unsigned long lmk_data_base,  unsigned long lmk_leu_base, unsigned long lmk_status_holdover_base)
: lmk_clk(lmk_clk_base), lmk_data(lmk_data_base), lmk_leu(lmk_leu_base), lmk_status_holdover(lmk_status_holdover_base)
{
	lmk_status_holdover.set_bidir_pio_direction_input();
}

void lmk04816_uwire::clk_up()     {lmk_clk.turn_on_bit(0)  ; default_delay();}
void lmk04816_uwire::clk_down()   {lmk_clk.turn_off_bit(0) ; default_delay();}
void lmk04816_uwire::data_up()    {lmk_data.turn_on_bit(0) ; default_delay();}
void lmk04816_uwire::data_down()  {lmk_data.turn_off_bit(0); default_delay();}
void lmk04816_uwire::leu_up()     {lmk_leu.turn_on_bit(0)  ; default_delay();}
void lmk04816_uwire::leu_down()   {lmk_leu.turn_off_bit(0) ; default_delay();}
unsigned long lmk04816_uwire::get_readback_bit() { return (lmk_status_holdover.read() & 0x1); }

unsigned long lmk04816_uwire::read_reg(unsigned long addr) {
	int cpu_sr;
	OS_ENTER_CRITICAL();
//based on LMK04816 datasheet 8.5.3.1
	write_reg(31,(addr & 0b11111) << 16);
	unsigned long read_data = 0;
	for (int i = 0; i < 27; i++) {
			clk_up();
			clk_down();
			read_data = (read_data << 1) + (get_readback_bit() & 0x1);
		}
	read_data = (read_data << 5) + (addr & 0b11111);
    OS_EXIT_CRITICAL();
    return read_data;
}

void lmk04816_uwire::write_reg(unsigned long addr, unsigned long data){
	unsigned long actual_address = (addr & 0b11111);
	unsigned long data_to_write = (data & (~(0b11111))) + actual_address;
	unsigned long temp_data = data_to_write;
	int cpu_sr;
    OS_ENTER_CRITICAL();
	//leu_up();
	leu_down();
	for (int i = 0; i < 32; i++) {
		int bit_to_write = ((temp_data & (1 << 31)) != 0);
		temp_data  = temp_data << 1;
		if (bit_to_write) {
			data_up();
		} else {
			data_down();
		}
		clk_up();
		clk_down();
	}
	leu_up();
	leu_down();
	if ((actual_address >=0) && (actual_address <=5)) {
		//Advanced microwire programming for special case of clk div > 25 or ddly > 12
		write_reg(9,0x55555549); //this is the value of the register as it always should be
	}
    OS_EXIT_CRITICAL();
}

int32_t lmk04816_uwire::lmk04816_setup(std::map<unsigned long,unsigned long> register_address_value_pairs) {
	int32_t             ret = 0;
	 std::map<unsigned long,unsigned long>::iterator iter;
	 for (iter = register_address_value_pairs.begin(); iter != register_address_value_pairs.end(); iter++) {
		 write_reg(iter->first,iter->second);
	  }
    return ret;

}

int32_t lmk04816_uwire::lmk04816_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order) {
	int32_t             ret = 0;
	 for (unsigned int i=0; i < register_address_value_pairs_in_order.size(); i++) {
		 write_reg(register_address_value_pairs_in_order.at(i).first,register_address_value_pairs_in_order.at(i).second);
	  }
    return ret;

}


lmk04816_uwire::~lmk04816_uwire() {

}

