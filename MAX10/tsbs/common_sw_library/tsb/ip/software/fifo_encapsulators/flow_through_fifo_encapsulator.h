/*
 * flow_through_fifo_encapsulator.h
 *
 *  Created on: Jul 8, 2013
 *      Author: yairlinn
 */

#ifndef FLOW_THROUGH_FIFO_ENCAPSULATOR_H_
#define FLOW_THROUGH_FIFO_ENCAPSULATOR_H_

#include "gp_fifo_encapsulator.h"
#include "uart_register_file.h"
#include "assert.h"
#include <stdio.h>


typedef void* (*assert_nios_control_of_flow_through_fifo_func_ptr)(void *);
typedef void* (*release_nios_control_of_flow_through_fifo_func_ptr)(void *);
typedef void* (*nios_clear_fifo_func_ptr)(void *);


class flow_through_fifo_encapsulator: public gp_fifo_encapsulator {
protected:
	assert_nios_control_of_flow_through_fifo_func_ptr nios_assert_func;
	release_nios_control_of_flow_through_fifo_func_ptr nios_release_func;
	nios_clear_fifo_func_ptr nios_clear_fifo_func;
public:

	flow_through_fifo_encapsulator(unsigned long base_addr, unsigned long flag_base_addr, unsigned long control_base_addr, unsigned long fifo_dmask, unsigned long capacity, std::string description_val,
			assert_nios_control_of_flow_through_fifo_func_ptr the_nios_assert_func = NULL,
			release_nios_control_of_flow_through_fifo_func_ptr the_nios_release_func = NULL,
			nios_clear_fifo_func_ptr the_clear_fifo_func = NULL,
			unsigned short data_lsb_val=0, unsigned short data_msb_val=31) :
		gp_fifo_encapsulator(base_addr, flag_base_addr, control_base_addr, fifo_dmask, capacity, description_val, data_lsb_val, data_msb_val)
	{
		nios_assert_func = the_nios_assert_func;
		nios_release_func = the_nios_release_func;
		nios_clear_fifo_func = the_clear_fifo_func;
	};


	virtual void set_up_fifo_for_acquisition(int do_pre_flush = 1);
    virtual int complete_fifo_aquisition(int do_not_wait_for_FIFO = 0);
    virtual void print_FIFO_contents(LINNUX_FIFO_DATA_FORMATS, int);

	nios_clear_fifo_func_ptr get_nios_clear_fifo_func() const {
		return nios_clear_fifo_func;
	}

	void set_nios_clear_fifo_func(nios_clear_fifo_func_ptr niosClearFifoFunc) {
		nios_clear_fifo_func = niosClearFifoFunc;
	}

	assert_nios_control_of_flow_through_fifo_func_ptr get_nios_assert_func() const {
		return nios_assert_func;
	}

	void set_nios_assert_func(
			assert_nios_control_of_flow_through_fifo_func_ptr niosAssertFunc) {
		nios_assert_func = niosAssertFunc;
	}

	release_nios_control_of_flow_through_fifo_func_ptr get_nios_release_func() const {
		return nios_release_func;
	}

	void set_nios_release_func(
			release_nios_control_of_flow_through_fifo_func_ptr niosReleaseFunc) {
		nios_release_func = niosReleaseFunc;
	}

    virtual void* assert_NIOS_control(void *data) { if (nios_assert_func != NULL) { return ((*nios_assert_func)(data)); } else {return NULL;} };
    virtual void* release_NIOS_control(void  *data) { if (nios_release_func != NULL) { return ((*nios_release_func)(data)); } else {return NULL;} };
    virtual void* clear_fifo(void  *data) { if (nios_clear_fifo_func != NULL) { return ((*nios_clear_fifo_func)(data)); } else {return NULL;} };


	virtual void enable_flowthrough()
	{
		IOWR_ALTERA_AVALON_PIO_DATA(FIFO_control_base_address, get_FIFO_control_word() | 0x80);
	};
	virtual void disable_flowthrough()
	{
		IOWR_ALTERA_AVALON_PIO_DATA(FIFO_control_base_address, get_FIFO_control_word() & (~0x80));
	};

	virtual void disable_wrclk()
	{
		IOWR_ALTERA_AVALON_PIO_DATA(FIFO_control_base_address, get_FIFO_control_word() | 0x40);
	};
	virtual void enable_wrclk()
	{
		IOWR_ALTERA_AVALON_PIO_DATA(FIFO_control_base_address, get_FIFO_control_word() & (~0x40));
	};
};

#endif /* FLOW_THROUGH_FIFO_ENCAPSULATOR_H_ */
