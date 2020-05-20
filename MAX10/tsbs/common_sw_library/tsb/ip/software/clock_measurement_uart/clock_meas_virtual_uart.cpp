/*
 * clock_meas_virtual_uart.cpp
 *
 *  Created on: Feb 12, 2014
 *      Author: yairlinn
 */

#include "clock_meas_virtual_uart.h"

#include "basedef.h"
#include <sstream>
#include <iostream>
#include <string>
#include <stdio.h>
#include "linnux_utils.h"
#include "basedef.h"
#include "debug_macro_definitions.h"
#include <vector>
extern "C" {
#include <xprintf.h>
}

#ifndef DEBUG_CLOCK_MEAS_UART
#define DEBUG_CLOCK_MEAS_UART (0)
#endif

#define u(x) do { if (DEBUG_CLOCK_MEAS_UART) {x;} } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if (DEBUG_CLOCK_MEAS_UART) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} } while (0)
	
	unsigned long clock_meas_virtual_uart::get_refclk_regnum() {
		return  this->uart_ptr->read_status_reg(REFCLK_INDEX_STATUS_REG_ADDRESS, this->secondary_uart_num);
	}
	
	void clock_meas_virtual_uart::initiate_clock_freq_capture() {
		this->uart_ptr->write_control_reg(CLEAR_REGISTERS_NOW_CONTROL_REG_ADDRESS, 0, this->secondary_uart_num);
		this->uart_ptr->write_control_reg(CLEAR_REGISTERS_NOW_CONTROL_REG_ADDRESS, 0xFFFFFFFFL, this->secondary_uart_num);
		measurement_is_in_progress = true;
		os_critical_low_level_system_usleep(CLOCK_CLEAR_WAIT_TIME_MILLISECONDS*1000);
		this->uart_ptr->write_control_reg(CLEAR_REGISTERS_NOW_CONTROL_REG_ADDRESS, 0, this->secondary_uart_num);
		os_critical_low_level_system_usleep(CLOCK_CLEAR_WAIT_TIME_MILLISECONDS*1000);
	}
	
	unsigned long clock_meas_virtual_uart::get_clock_counter_regnum(unsigned long clock_num) {
		unsigned long regindex = 2*clock_num+AUTO_REGISTER_FIRST_STATUS_REG_ADDRESS;
		return regindex;
	}


	bool clock_meas_virtual_uart::clock_measurement_is_ready() {
		long current_measurement_status;
		//current_status = this.theUART.readStatus(MEASUREMENT_READY_STATUS_REG_ADDRESS);
		current_measurement_status = this->uart_ptr->read_status_reg(MEASUREMENT_READY_STATUS_REG_ADDRESS,this->secondary_uart_num);
		return ((current_measurement_status & refclk_mask) != 0);
	}

	double clock_meas_virtual_uart::get_clock_frequency(unsigned long clknum,  double referenceTime_ms) {
		unsigned long linkedData =this->uart_ptr->read_status_reg(get_clock_counter_regnum(clknum),this->secondary_uart_num);
		double raw_linked_data = ((double)(linkedData))/(((double) (referenceTime_ms)/1000.0));
		return raw_linked_data;
	}
	double clock_meas_virtual_uart::measure_clock_frequency(unsigned long clknum) {
		unsigned long long 	start_timestamp = os_critical_low_level_system_timestamp();
		unsigned long long 	end_timestamp;
		unsigned long long 	timestamp_difference;
        this->initiate_clock_freq_capture();
        double  time_diff_in_us;
			do {
				end_timestamp = os_critical_low_level_system_timestamp();
				if (end_timestamp < start_timestamp) {
					end_timestamp = start_timestamp; //avoid unlikely errors
				}
				timestamp_difference = end_timestamp - start_timestamp;
				time_diff_in_us = 1000000.0*(((double)timestamp_difference)/((double)NIOS_64_BIT_COUNTER_CLOCK_FREQ_HZ));
				if (time_diff_in_us > this->get_watchdog_timer_limit_us()) {
					break;
				}
			}
			while (!this->clock_measurement_is_ready());

			if (time_diff_in_us > this->get_watchdog_timer_limit_us()) {
				safe_print(alt_printf("Error during measure_clock_frequency, watchdog timer activated!\n"));
			}
			double reftime_ms = this->get_measured_reference_time_ms();
			double measured_freq = get_clock_frequency(clknum,reftime_ms);
			 u(std::cout << "reftime_ms = " << reftime_ms
							   << " measured_freq =" << measured_freq);
			return measured_freq;

	}

	double clock_meas_virtual_uart::get_measured_reference_time_ms() {

		 unsigned long current_reference_count;
	     if (clock_measurement_is_ready()) {
	    	 measurement_is_in_progress = false;
	    	 num_of_total_measurements++;
		     current_reference_count =  this->uart_ptr->read_status_reg(ref_clock_counter_regnum,secondary_uart_num);
	     } else {
	    	 current_reference_count =  this->uart_ptr->read_status_reg(ref_clock_counter_regnum,secondary_uart_num);
	     }
		double calculated_reference_time = 1.0e3*((double)current_reference_count)/((double)expected_refclock_frequency);
		return calculated_reference_time;
	}
	

	std::string clock_meas_virtual_uart::get_clock_description(unsigned long clock_num) {
		unsigned long regindex = get_clock_counter_regnum(clock_num);
		return this->uart_ptr->get_status_desc(regindex,this->secondary_uart_num);
	}

	double clock_meas_virtual_uart::get_clock_expected_freq(unsigned long clock_num) {
		unsigned long regindex = 2*clock_num+1+AUTO_REGISTER_FIRST_STATUS_REG_ADDRESS;
		unsigned long raw_val =  this->uart_ptr->read_status_reg(regindex,secondary_uart_num);
		double actual_val =((double)raw_val) / this->getDouble_scaling_factor();
		return actual_val;		
	}
	
	std::string clock_meas_virtual_uart::get_clock_group_name(long clock_num) {
		std::ostringstream clock_group_name;
		clock_group_name << "clock_" << clock_num <<"_display";
        return clock_group_name.str();
	}

clock_meas_virtual_uart::clock_meas_virtual_uart(uart_register_file* the_uart_ptr, unsigned long the_secondary_uart_num)
        {
	this->uart_ptr = the_uart_ptr;
	this->secondary_uart_num = the_secondary_uart_num;

	double_scaling_factor = this->uart_ptr->read_status_reg(SCALING_FACTOR_STATUS_ADDRESS,secondary_uart_num);
    this->set_watchdog_timer_limit_us(this->WATCHDOG_TIMER_LIMIT_US_DEFAULT);
    refclock_num             = get_refclk_regnum();
   	ref_clock_counter_regnum = get_clock_counter_regnum(refclock_num);
   	refclk_mask = (1 << refclock_num);
   	expected_refclock_frequency = get_clock_expected_freq(refclock_num)*frequency_units_Hz;
   	if (expected_refclock_frequency <= 0.0D) {
   	  expected_refclock_frequency = 1.0D; //should not happen
   	}
   	u(std::cout << "refclock_num = " << refclock_num
   	   << " ref_clock_counter_regnum =" << ref_clock_counter_regnum
   	   << " refclk_mask = " << refclock_num
   	   << " expected_refclock_frequency = " << expected_refclock_frequency << std::endl; std::cout.flush(););
}
