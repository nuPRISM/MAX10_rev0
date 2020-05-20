
#ifndef __LTC2668_DRIVER__H__
#define __LTC2668_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include "opencores_spi_driver.h"
/******************************************************************************/
/*********************************** ltc2668 ***********************************/
/******************************************************************************/
#define ltc2668_SPI_CORE_BAUDRATE      (4000000)
#define ltc2668_SPI_CORE_CTRL_SETTINGS 0x0408 // char_len = 8 go_bsy = 0 ass = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1
#define ltc2668_HIGHEST_REG_ADDR       0x10
#define DEBUG_ltc2668_DEVICE_DRIVER (0)
/* Registers */

#define ltc2668_READ                         (1 << 15)
#define ltc2668_WRITE                        (3 << 4)
#define ltc2668_CNT(x)                       ((((x) & 0x3) - 1) << 13)
#define ltc2668_ADDR(x)                      ((x) & 0xFF)
#define NUM_LTC2668_DACS                      (16)


//! @name LTC2668 Command Codes
//! OR'd together with the DAC address to form the command byte
#define  LTC2668_CMD_WRITE_N              0x00  //!< Write to input register n
#define  LTC2668_CMD_UPDATE_N             0x10  //!< Update (power up) DAC register n
#define  LTC2668_CMD_WRITE_N_UPDATE_ALL   0x20  //!< Write to input register n, update (power-up) all
#define  LTC2668_CMD_WRITE_N_UPDATE_N     0x30  //!< Write to input register n, update (power-up)
#define  LTC2668_CMD_POWER_DOWN_N         0x40  //!< Power down n
#define  LTC2668_CMD_POWER_DOWN_ALL       0x50  //!< Power down chip (all DAC's, MUX and reference)

#define  LTC2668_CMD_SPAN                 0x60  //!< Write span to dac n
#define  LTC2668_CMD_CONFIG               0x70  //!< Configure reference / toggle
#define  LTC2668_CMD_WRITE_ALL            0x80  //!< Write to all input registers
#define  LTC2668_CMD_UPDATE_ALL           0x90  //!< Update all DACs
#define  LTC2668_CMD_WRITE_ALL_UPDATE_ALL 0xA0  //!< Write to all input reg, update all DACs
#define  LTC2668_CMD_MUX                  0xB0  //!< Select MUX channel (controlled by 5 LSbs in data word)
#define  LTC2668_CMD_TOGGLE_SEL           0xC0  //!< Select which DACs can be toggled (via toggle pin or global toggle bit)
#define  LTC2668_CMD_GLOBAL_TOGGLE        0xD0  //!< Software toggle control via global toggle bit
#define  LTC2668_CMD_SPAN_ALL             0xE0  //!< Set span for all DACs
#define  LTC2668_CMD_NO_OPERATION         0xF0  //!< No operation
//! @}

//! @name LTC2668 Span Codes
//! @{
//! Descriptions are valid for a 2.5V reference.
//! These can also be interpreted as 0 to 2*Vref, 0 to 4*Vref, etc.
//! when an external reference other than 2.5V is used.
#define  LTC2668_SPAN_0_TO_5V             0x0000
#define  LTC2668_SPAN_0_TO_10V            0x0001
#define  LTC2668_SPAN_PLUS_MINUS_5V       0x0002
#define  LTC2668_SPAN_PLUS_MINUS_10V      0x0003
#define  LTC2668_SPAN_PLUS_MINUS_2V5      0x0004
//! @}

//! @name LTC2668 Minimums and Maximums for each Span
//! @{
//! Lookup tables for minimum and maximum outputs for a given span
const float LTC2668_MIN_OUTPUT[5] = {0.0, 0.0, -5.0, -10.0, -2.5};
const float LTC2668_MAX_OUTPUT[5] = {5.0, 10.0, 5.0, 10.0, 2.5};
//! @}

//! @name LTC2668 Configuration options
//! @{
//! Used in conjunction with LTC2668_CMD_CONFIG command
#define  LTC2668_REF_DISABLE              0x0001  //! Disable internal reference to save power when using an ext. ref.
#define  LTC2668_THERMAL_SHUTDOWN         0x0002  //! Disable thermal shutdown (NOT recommended)
//! @}

//! @name LTC2668 MUX enable
//! @{
//! Used in conjunction with LTC2668_CMD_MUX command
#define  LTC2668_MUX_DISABLE              0x0000  //! Disable MUX
#define  LTC2668_MUX_ENABLE               0x0010  //! Enable MUX, OR with MUX channel to be monitored
//! @}

//! @name LTC2668 Global Toggle
//! @{
//! Used in conjunction with LTC2668_CMD_GLOBAL_TOGGLE command, affects DACs whose
//! Toggle Select bits have been set to 1
#define  LTC2668_TOGGLE_REG_A              0x0000  //! Update DAC with register A
#define  LTC2668_TOGGLE_REG_B              0x0010  //! Update DAC with register B
//! @}

#define LT2668_INITIAL_VALUE      (0xb333) //for 0 differential voltage
#define LTC2668_INITIAL_SPAN  (LTC2668_SPAN_PLUS_MINUS_2V5)


class ltc2668_driver  {
protected:
	opencores_spi_driver* spi_driver;
	uint16_t shadow_reg[NUM_LTC2668_DACS];
	uint16_t span_reg;
	uint16_t get_shadow_reg(int addr);
		void set_shadow_reg(int addr, uint16_t data);
	uint16_t get_span_reg();
	void set_span_reg(uint16_t data);
	uint32_t ltc2668_internal_write(uint8_t opcode, int32_t registerAddress, uint32_t registerValue);


public:
	ltc2668_driver() {
	};
	uint32_t ltc2668_setup();
	void ltc2668_set_span(uint16_t span);
	uint16_t ltc2668_get_span();

	uint32_t ltc2668_read(int32_t registerAddress);
	uint32_t ltc2668_write(int32_t registerAddress, uint32_t registerValue);
	uint32_t ltc2668_transfer(void);


	uint32_t ltc2668_setup(std::map<unsigned long,unsigned long> register_address_value_pairs);
	uint32_t ltc2668_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order);
	uint32_t ltc2668_soft_reset(uint16_t span = LTC2668_INITIAL_SPAN, uint16_t initial_value =  LT2668_INITIAL_VALUE);


	void set_cs_active();
	void set_cs_inactive();

	opencores_spi_driver* get_spi_driver() const {
		return spi_driver;
	}

	void set_spi_driver(opencores_spi_driver* spiDriver) {
		spi_driver = spiDriver;
	}

	

};

#endif /* __ltc2668_H__ */
