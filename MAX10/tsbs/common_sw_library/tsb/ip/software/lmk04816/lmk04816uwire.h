/*
 * lmk04816uwire.h
 *
 *  Created on: Nov 21, 2016
 *      Author: yairlinn
 */

#ifndef LMK04816UWIRE_H_
#define LMK04816UWIRE_H_

#include <stdio.h>
#include <iostream>
#include "altera_pio_encapsulator.h"
  #include <unistd.h>
#include <stdint.h>
#include <map>
#include <vector>
#include <string>

#define LMK04816_DEFAULT_DELAY_US          (1)
#define LMK04816_HIGHEST_REG_ADDR       (0x20)

class lmk04816_uwire {
protected:
	altera_pio_encapsulator lmk_clk;
	altera_pio_encapsulator lmk_data;
	altera_pio_encapsulator lmk_leu;
	altera_pio_encapsulator lmk_status_holdover;

	void default_delay() { asm("nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;"); /*usleep(LMK04816_DEFAULT_DELAY_US);*/};

	void clk_up();
	void clk_down();
	void data_up();
	void data_down();
	void leu_down();
	void leu_up();
	unsigned long get_readback_bit();

	void write_reg(unsigned long addr, unsigned long data);
	unsigned long read_reg(unsigned long addr);

public:

	int32_t lmk04816_setup(std::map<unsigned long,unsigned long> register_address_value_pairs);

	int32_t lmk04816_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);

	lmk04816_uwire(unsigned long lmk_clk_base, unsigned long lmk_data_base,  unsigned long lmk_leu_base, unsigned long lmk_status_holdover_base);
	virtual ~lmk04816_uwire();
};

#endif /* LMK04816UWIRE_H_ */
