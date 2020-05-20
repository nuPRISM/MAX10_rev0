/*
 * clock_cleaner_lmk03200.h
 *
 *  Created on: Mar 6, 2014
 *      Author: yairlinn
 */

#ifndef CLOCK_CLEANER_LMK03200_H_
#define CLOCK_CLEANER_LMK03200_H_

class clock_cleaner_lmk03200 {
protected:
	unsigned long pio_in;
	unsigned long pio_out;
	unsigned long spi_base;
public:
	clock_cleaner_lmk03200();
	void LMK03200_Configure(void);
	void LMK03200_Cmd(unsigned long cmd);

	unsigned long get_spi_base() const {
		return spi_base;
	}

	void set_spi_base(unsigned long spiBase) {
		spi_base = spiBase;
	}

	unsigned long get_pio_in_addr() const {
		return pio_in;
	}

	void set_pio_in_addr(unsigned long pioIn) {
		pio_in = pioIn;
	}

	unsigned long get_pio_out_addr() const {
		return pio_out;
	}

	void set_pio_out_addr(unsigned long pioOut) {
		pio_out = pioOut;
	}
};

#endif /* CLOCK_CLEANER_LMK03200_H_ */
