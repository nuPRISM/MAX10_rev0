/*
 * clock_meas_virtual_uart.h
 *
 *  Created on: Feb 12, 2014
 *      Author: yairlinn
 */

#ifndef CLOCK_MEAS_VIRTUAL_UART_H_
#define CLOCK_MEAS_VIRTUAL_UART_H_
#include "uart_register_file.h"

class clock_meas_virtual_uart {
protected:
	register_desc_map_type default_device_driver_register_descriptions;
	uart_register_file* uart_ptr;
	unsigned long secondary_uart_num;

	static const unsigned long CLOCK_MEASUREMENT_WAIT_TIME_MILLISECONDS = 200;
	static const unsigned long CAPTURE_NOW_CONTROL_REG_ADDRESS = 1;
	static const unsigned long REFCLK_INDEX_STATUS_REG_ADDRESS = 2;
	static const unsigned long CLOCK_CLEAR_WAIT_TIME_MILLISECONDS = 100;
	static const unsigned long MAX_ALLOWED_WAIT_TIME_BETWEEN_CLOCK_MEASUREMENTS_MILLISECONDS = 3000;
	static const unsigned long CLEAR_REGISTERS_NOW_CONTROL_REG_ADDRESS = 0;
	static const unsigned long NUM_OF_REFCLKS_TO_MEASURE_CONTROL_REG_ADDRESS = 1;
	static const unsigned long MEASUREMENT_READY_STATUS_REG_ADDRESS = 3;
	static const unsigned long AUTO_REGISTER_FIRST_STATUS_REG_ADDRESS = 4;
	static const unsigned long NUM_CLOCKS_STATUS_ADDRESS = 0;
	static const unsigned long SCALING_FACTOR_STATUS_ADDRESS = 1;
	static const unsigned long RESET_COUNTERS_CONTROL_ADDRESS = 0;
	static const unsigned long WATCHDOG_TIMER_LIMIT_US_DEFAULT = 20000000;

	unsigned long refclock_num             = 0L;
	unsigned long ref_clock_counter_regnum = 0L;
	double expected_refclock_frequency = 0.0D;
	bool is_first_time_measuring_frequency = true;
	bool measurement_is_in_progress = false;
	unsigned long  num_of_total_measurements = 0;
    unsigned long refclk_mask = 0L;
	double   double_scaling_factor;
    double   frequency_units_Hz = 1e6;
	unsigned  long numOfClocksToShow;
	unsigned long long watchdog_timer_limit_us = WATCHDOG_TIMER_LIMIT_US_DEFAULT;

public:
	 clock_meas_virtual_uart(uart_register_file* the_uart_ptr, unsigned long the_secondary_uart_num);
	 double get_clock_frequency(unsigned long clknum,  double referenceTime_ms);
	 double measure_clock_frequency(unsigned long clknum);
	 unsigned long get_clock_counter_regnum(unsigned long clock_num);
	 bool clock_measurement_is_ready();
	unsigned long get_refclk_regnum();
	
	void initiate_clock_freq_capture() ;
	
	bool lock_measurement_is_ready();

	double get_measured_reference_time_ms();

	std::string get_clock_description(unsigned long clock_num);

	double get_clock_expected_freq(unsigned long clock_num);

	std::string get_clock_group_name(long clock_num);

	double getDouble_scaling_factor() {
		return double_scaling_factor;
	}

	void setDouble_scaling_factor(double double_scaling_factor) {
		this->double_scaling_factor = double_scaling_factor;
	}

	unsigned long long get_watchdog_timer_limit_us()  {
		return watchdog_timer_limit_us;
	}

	void set_watchdog_timer_limit_us(
			unsigned long long watchdog_timer_limit_us) {
		this->watchdog_timer_limit_us = watchdog_timer_limit_us;
	}
};

#endif /* TSE_MAC_DEVICE_DRIVER_VIRTUAL_UART_H_ */
