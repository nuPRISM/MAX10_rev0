/*
 * vme_fifo_device_driver_virtual_uart.h
 *
 *  Created on: Mar 21, 2014
 *      Author: yairlinn
 */

#ifndef VME_FIFO_DEVICE_DRIVER_VIRTUAL_UART_H_
#define VME_FIFO_DEVICE_DRIVER_VIRTUAL_UART_H_

#include <virtual_uart_register_file.h>
#include "altera_pio_encapsulator.h"
#include "flow_through_fifo_encapsulator.h"
#include <vector>
#include "assert.h"
#include <stdio.h>
class fifo_pio_foundation {
protected:
	unsigned long read_data_base;
	unsigned long flags_base;
	unsigned long control_base;

public:
	unsigned long get_control_base() const {
		return control_base;
	}

	void set_control_base(unsigned long controlBase) {
		control_base = controlBase;
	}

	unsigned long get_flags_base() const {
		return flags_base;
	}

	void set_flags_base(unsigned long flagsBase) {
		flags_base = flagsBase;
	}

	unsigned long get_read_data_base() const {
		return read_data_base;
	}

	void set_read_data_base(unsigned long readDataBase) {
		read_data_base = readDataBase;
	}

	fifo_pio_foundation() {
		      read_data_base= 0;
		      flags_base = 0;
	          control_base = 0;
	}

	fifo_pio_foundation(unsigned long readDataBase, unsigned long flagsBase, unsigned long controlBase) {
		set_read_data_base(readDataBase);
		set_flags_base(flagsBase);
		set_control_base(controlBase);
		}
};


typedef void* (*trigger_func_ptr)(void *);
typedef void* (*release_trigger_func_ptr)(void *);
typedef void* (*clear_fifos_func_ptr)(void *);

typedef std::vector<flow_through_fifo_encapsulator*> flow_through_fifo_pointer_vector_type;
typedef std::vector<fifo_pio_foundation> fifo_pio_foundation_vector_type;
typedef std::vector<std::vector<unsigned long> > multiple_fifo_response_vector_type;

class vme_fifo_device_driver_virtual_uart: public virtual_uart_register_file {
protected:
	std::vector<altera_pio_encapsulator> pio_repository;
	flow_through_fifo_pointer_vector_type fifo_control_encapsulator;
	fifo_pio_foundation_vector_type fifo_pio_foundation_vector;
	assert_nios_control_of_flow_through_fifo_func_ptr nios_assert_func;
    release_nios_control_of_flow_through_fifo_func_ptr nios_release_func;
	trigger_func_ptr trigger_func;
	release_trigger_func_ptr release_trigger_func;
	clear_fifos_func_ptr clear_fifos_func;
	nios_clear_fifo_func_ptr individual_clear_fifo_func;

public:
	vme_fifo_device_driver_virtual_uart(
			fifo_pio_foundation_vector_type the_fifo_pio_foundation_vector,
			unsigned long fifo_dmask,
			unsigned long capacity,
			std::string description_val,
			assert_nios_control_of_flow_through_fifo_func_ptr the_nios_assert_func = NULL,
			release_nios_control_of_flow_through_fifo_func_ptr the_nios_release_func = NULL,
			trigger_func_ptr the_trigger_func = NULL,
			release_trigger_func_ptr the_release_trigger_func = NULL,
			clear_fifos_func_ptr the_clear_fifos_func = NULL,
			nios_clear_fifo_func_ptr the_individual_clear_fifo_func = NULL
		 );


	virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual void write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);

	clear_fifos_func_ptr get_clear_fifos_func() const {
		return clear_fifos_func;
	}

	void set_clear_fifos_func(clear_fifos_func_ptr clearFifosFunc) {
		clear_fifos_func = clearFifosFunc;
	}

	flow_through_fifo_encapsulator* get_fifo_ptr(unsigned int fifo_index) {
		if (fifo_index >= fifo_control_encapsulator.size()) {
			std::cout << "Error: vme_fifo_device_driver_virtual_uart::get_fifo_ptr: fifo index " << fifo_index << "out of range of 0 to " <<  fifo_control_encapsulator.size() -1 << std::endl;
			std::cout.flush();
			assert(0);
		}
		return fifo_control_encapsulator.at(fifo_index);
	}

	unsigned int get_num_of_fifos() {
		return fifo_control_encapsulator.size();
	}

	flow_through_fifo_pointer_vector_type get_fifo_control_encapsulator() const {
		return fifo_control_encapsulator;
	}

	void set_fifo_control_encapsulator(
			flow_through_fifo_pointer_vector_type fifoControlEncapsulator) {
		fifo_control_encapsulator = fifoControlEncapsulator;
	}

	fifo_pio_foundation_vector_type get_fifo_pio_foundation_vector() const {
		return fifo_pio_foundation_vector;
	}

	void set_fifo_pio_foundation_vector(
			fifo_pio_foundation_vector_type fifoPioFoundationVector) {
		fifo_pio_foundation_vector = fifoPioFoundationVector;
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

	std::vector<altera_pio_encapsulator> get_pio_repository() const {
		return pio_repository;
	}

	void set_pio_repository(
			std::vector<altera_pio_encapsulator> pioRepository) {
		pio_repository = pioRepository;
	}

	release_trigger_func_ptr get_release_trigger_func() const {
		return release_trigger_func;
	}

	void set_release_trigger_func(release_trigger_func_ptr releaseTriggerFunc) {
		release_trigger_func = releaseTriggerFunc;
	}

	trigger_func_ptr get_trigger_func() const {
		return trigger_func;
	}

	void set_trigger_func(trigger_func_ptr triggerFunc) {
		trigger_func = triggerFunc;
	}
	virtual void* trigger(void* data) { if (trigger_func != NULL) { return (*trigger_func)(data); } else { return NULL; } };
	virtual void* release_trigger(void* data) { if (release_trigger_func != NULL) { return (*release_trigger_func)(data); }  else { return NULL; } };
	virtual void* clear_fifos(void* data) { if (clear_fifos_func != NULL) { return (*clear_fifos_func)(data); } else { return NULL; } };
	virtual multiple_fifo_response_vector_type trigger_and_acquire_multiple_fifos(std::vector<unsigned int> fifo_indices);

	nios_clear_fifo_func_ptr get_individual_clear_fifo_func() const {
		return individual_clear_fifo_func;
	}

	void set_individual_clear_fifo_func(
			nios_clear_fifo_func_ptr individualClearFifoFunc) {
		individual_clear_fifo_func = individualClearFifoFunc;
	}

};

#endif /* VME_FIFO_DEVICE_DRIVER_VIRTUAL_UART_H_ */
