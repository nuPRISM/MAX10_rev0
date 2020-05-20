
#ifndef __ltc2983_DRIVER__H__
#define __ltc2983_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include "opencores_spi_driver.h"
#include <utility>
#include <map>
#include <vector>
#include "configuration_constants_LTC2983.h"
#include "table_coeffs_LTC2983.h"
#include "debug_macro_definitions.h"

/******************************************************************************/
/*********************************** ltc2983 ***********************************/
/******************************************************************************/
#define ltc2983_SPI_CORE_BAUDRATE      500000
#define ltc2983_SPI_CORE_CTRL_SETTINGS 0x0408 // char_len = 8 go_bsy = 0 ass = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1
#define ltc2983_HIGHEST_REG_ADDR       0x400

#ifndef DEBUG_ltc2983_DEVICE_DRIVER
#define DEBUG_ltc2983_DEVICE_DRIVER (0)
#endif

/* Registers */

#define ltc2983_READ                         0x03
#define ltc2983_WRITE                        0x02
#define ltc2983_CNT(x)                       ((((x) & 0x3) - 1) << 13)
#define ltc2983_ADDR(x)                      ((x) & 0xFF)


class ltc2983_driver  {
protected:
	opencores_spi_driver* spi_driver;
	
public:
	ltc2983_driver() {
	};
//	int32_t ltc2983_setup();
	int32_t ltc2983_setup(std::map<unsigned long,unsigned long> register_address_value_pairs);
	int32_t ltc2983_driver::ltc2983_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);
	int32_t ltc2983_read(int32_t registerAddress);
	int32_t ltc2983_write(int32_t registerAddress, int32_t registerValue);
	int32_t ltc2983_transfer(void);
	int32_t ltc2983_soft_reset(void);
	void set_cs_active();
	void set_cs_inactive();
	void assign_channel(int channel_number, long channel_assignment_data);
	void write_custom_table(struct table_coeffs coefficients[64], long start_address, long table_length);
	void write_custom_steinhart_hart(long steinhart_hart_coeffs[6], long start_address);
	void write_single_byte(long start_address, int single_byte);
	void initialize_memory_write(long start_address);
	void write_coefficient(long coeff, int bytes_in_coeff);
	void finish_memory_write();

	void initialize_memory_read(long start_address);
	void finish_memory_read();
	void convert_channel(unsigned int channel_number);
	bool conversion_done();

	float read_temperature_results(int channel_number);
	float read_direct_adc_results(int channel_number);
	void get_raw_results(long base_address, int channel_number, unsigned char results[4]);
	float convert_to_signed_float(unsigned char results[4]);
	float get_temperature(float x);
	float get_direct_adc_reading(float x);
	void print_temperature_result(int channel_number, float temperature_result);
	void print_direct_adc_reading(int channel_number, float direct_adc_reading);
	void print_fault_data(unsigned char fault_byte);
	bool is_number_in_array(int number, int *array, int array_length);

	// -------------- Some raw data result...
	float read_voltage_or_resistance_results(int channel_number);
	float convert_vr_to_signed_float(unsigned char results[4]);
	float get_voltage_or_resistance(float x);
	void print_voltage_or_resistance_result(int channel_number, float voltage_or_resistance_result);
	opencores_spi_driver* get_spi_driver() const {
		return spi_driver;
	}

	void set_spi_driver(opencores_spi_driver* spiDriver) {
		spi_driver = spiDriver;
	}

	
};

#endif /* __ltc2983_H__ */
