/*
 * jesd204b_tx_virtual_uart.cpp
 *
 *  Created on: Jan 22, 2018
 *      Author: yairlinn
 */

#include "jesd204b_tx_virtual_uart.h"
#include "generic_driver_encapsulator.h"
#include "virtual_uart_register_file.h"
#include "basedef.h"
#include <sstream>
#include <iostream>
#include <string>
#include <stdio.h>
#include "linnux_utils.h"
#include "basedef.h"
#include <vector>
#include "debug_macro_definitions.h"
#include "jesd204b_tx_and_rx_regs.h"

extern "C" {
#include <xprintf.h>
}

using namespace jesd204b_tx;

#ifndef DEBUG_JESD204B_TX_DEVICE_DRIVER
#define DEBUG_JESD204B_TX_DEVICE_DRIVER (0)
#endif 

#define u(x) do { if (DEBUG_JESD204B_TX_DEVICE_DRIVER) {x;} } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if (DEBUG_JESD204B_TX_DEVICE_DRIVER) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} } while (0)

jesd204b_tx_virtual_uart::jesd204b_tx_virtual_uart(unsigned long the_base_address, std::string name, unsigned int link_index = 0) :
	virtual_uart_register_file(),
	generic_driver_encapsulator( the_base_address, SPAN_JESD204B_TX_BYTES, name) {
    link = link_index;
    default_register_descriptions[0x0  >> 2] = "lane_ctrl_common"    ;
    default_register_descriptions[0x4  >> 2] = "lane_ctrl_0"        ;
    default_register_descriptions[0x8  >> 2] = "lane_ctrl_1"        ;
    default_register_descriptions[0xC  >> 2] = "lane_ctrl_2"        ;
    default_register_descriptions[0x10 >> 2] = "lane_ctrl_3"        ;
    default_register_descriptions[0x14 >> 2] = "lane_ctrl_4"        ;
    default_register_descriptions[0x18 >> 2] = "lane_ctrl_5"        ;
    default_register_descriptions[0x1C >> 2] = "lane_ctrl_6"        ;
    default_register_descriptions[0x20 >> 2] = "lane_ctrl_7"        ;
    default_register_descriptions[0x50 >> 2] = "dll_ctrl"            ;
    default_register_descriptions[0x54 >> 2] = "syncn_sysref_ctrl"   ;
    default_register_descriptions[0x58 >> 2] = "ctrl_reserve"        ;
    default_register_descriptions[0x60 >> 2] = "tx_err"              ;
    default_register_descriptions[0x64 >> 2] = "tx_err_mask"         ;
    default_register_descriptions[0x80 >> 2] = "tx_status0"         ;
    default_register_descriptions[0x84 >> 2] = "tx_status1"         ;
    default_register_descriptions[0x88 >> 2] = "tx_status2"         ;
    default_register_descriptions[0x8C >> 2] = "tx_status3"         ;
    default_register_descriptions[0x90 >> 2] = "ilas_data0"         ;
    default_register_descriptions[0x94 >> 2] = "ilas_data1"         ;
    default_register_descriptions[0x98 >> 2] = "ilas_data2"         ;
    default_register_descriptions[0x9C >> 2] = "ilas_data3"         ;
    default_register_descriptions[0xA0 >> 2] = "ilas_data4"         ;
    default_register_descriptions[0xA4 >> 2] = "ilas_data5"         ;
    default_register_descriptions[0xB0 >> 2] = "ilas_data8"         ;
    default_register_descriptions[0xB4 >> 2] = "ilas_data9"         ;
    default_register_descriptions[0xC0 >> 2] = "ilas_data12"         ;
    default_register_descriptions[0xD0 >> 2] = "tx_test"             ;
    default_register_descriptions[0xD4 >> 2] = "user_test_pattern_a" ;
    default_register_descriptions[0xD8 >> 2] = "user_test_pattern_b" ;
    default_register_descriptions[0xDC >> 2] = "user_test_pattern_c" ;
    default_register_descriptions[0xE0 >> 2] = "user_test_pattern_d" ;
	
	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(default_register_descriptions);

	this->set_control_reg_map_desc(default_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << " set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
}

jesd204b_tx_virtual_uart::~jesd204b_tx_virtual_uart() {
	// TODO Auto-generated destructor stub
}


unsigned long long jesd204b_tx_virtual_uart::read_control_reg(unsigned long address, unsigned long secondary_uart_address, int* errorptr) {
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return 0;
		}
	return read  (address);
}

void jesd204b_tx_virtual_uart::write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address, int* errorptr) {
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return;
		}
	write(address, data);
}



int jesd204b_tx_virtual_uart::IORD_JESD204_TX_STATUS0_REG ()
{
   int val;

   val = this->read_reg_by_byte_offset( ALTERA_JESD204_TX_RX_STATUS0_REG_OFFSET);

   return val;
}

int jesd204b_tx_virtual_uart::IORD_JESD204_TX_SYNCN_SYSREF_CTRL_REG ()
{
   int val;

   val = this->read_reg_by_byte_offset( ALTERA_JESD204_SYNCN_SYSREF_CTRL_REG_OFFSET);

   return val;
}

void jesd204b_tx_virtual_uart::IOWR_JESD204_TX_SYNCN_SYSREF_CTRL_REG ( int val)
{

#if DEBUG_JESD204B_TX_DEVICE_DRIVER
   xprintf ("Writing val 0x%x to TX syncn_sysref_ctrl reg on link %d...\n", val, link);
#endif
   this->write_reg_by_byte_offset( ALTERA_JESD204_SYNCN_SYSREF_CTRL_REG_OFFSET, val);

}

int jesd204b_tx_virtual_uart::IORD_JESD204_TX_DLL_CTRL_REG ()
{
   int val;

   val = this->read_reg_by_byte_offset( ALTERA_JESD204_TX_DLL_CTRL_REG_OFFSET);

   return val;
}

void jesd204b_tx_virtual_uart::IOWR_JESD204_TX_DLL_CTRL_REG ( int val)
{
#if DEBUG_JESD204B_TX_DEVICE_DRIVER
   xprintf ("Writing val 0x%x to TX dll_ctrl reg on link %d...\n", val, link);
#endif
   this->write_reg_by_byte_offset( ALTERA_JESD204_TX_DLL_CTRL_REG_OFFSET, val);

}

int jesd204b_tx_virtual_uart::IORD_JESD204_TX_ILAS_DATA1_REG ()
{
   int val;

   val = this->read_reg_by_byte_offset( ALTERA_JESD204_TX_RX_ILAS_DATA1_REG_OFFSET);

   return val;
}

void jesd204b_tx_virtual_uart::IOWR_JESD204_TX_ILAS_DATA1_REG ( int val)
{

#if DEBUG_JESD204B_TX_DEVICE_DRIVER
   xprintf ("Writing to TX ILAS DATA1 register on link %d...\n", link);
#endif
   this->write_reg_by_byte_offset( ALTERA_JESD204_TX_RX_ILAS_DATA1_REG_OFFSET, val);
}
int jesd204b_tx_virtual_uart::IORD_JESD204_TX_ILAS_DATA2_REG ()
{
   int val;

   val = this->read_reg_by_byte_offset( ALTERA_JESD204_TX_RX_ILAS_DATA2_REG_OFFSET);

   return val;
}

void jesd204b_tx_virtual_uart::IOWR_JESD204_TX_ILAS_DATA2_REG ( int val)
{

#if DEBUG_JESD204B_TX_DEVICE_DRIVER
   xprintf ("Writing to TX ILAS DATA2 register on link %d...\n", link);
#endif
   this->write_reg_by_byte_offset( ALTERA_JESD204_TX_RX_ILAS_DATA2_REG_OFFSET, val);
}


int jesd204b_tx_virtual_uart::IORD_JESD204_TX_ILAS_DATA12_REG ()
{
   int val;

   val = this->read_reg_by_byte_offset( ALTERA_JESD204_TX_RX_ILAS_DATA12_REG_OFFSET);

   return val;
}


void jesd204b_tx_virtual_uart::IOWR_JESD204_TX_ILAS_DATA12_REG ( int val)
{
  #if DEBUG_JESD204B_TX_DEVICE_DRIVER
   xprintf ("Writing to TX ILAS DATA12 register on link %d...\n", link);
#endif
   this->write_reg_by_byte_offset( ALTERA_JESD204_TX_RX_ILAS_DATA12_REG_OFFSET, val);
}


int jesd204b_tx_virtual_uart::IORD_JESD204_TX_GET_L_VAL ()
{
   int val;

   val = IORD_JESD204_TX_ILAS_DATA1_REG() & ALTERA_JESD204_TX_RX_L_VAL_MASK;

   return val;
}

int jesd204b_tx_virtual_uart::IORD_JESD204_TX_GET_F_VAL ()
{
   int val;

   val = (IORD_JESD204_TX_ILAS_DATA1_REG() & ALTERA_JESD204_TX_RX_F_VAL_MASK) >> ALTERA_JESD204_TX_RX_F_VAL_POS;

   return val;
}

int jesd204b_tx_virtual_uart::IORD_JESD204_TX_GET_K_VAL ()
{
   int val;

   val = (IORD_JESD204_TX_ILAS_DATA1_REG() & ALTERA_JESD204_TX_RX_K_VAL_MASK) >> ALTERA_JESD204_TX_RX_K_VAL_POS;

   return val;
}


int jesd204b_tx_virtual_uart::IORD_JESD204_TX_GET_M_VAL ()
{
   int val;

   val = (IORD_JESD204_TX_ILAS_DATA1_REG() & ALTERA_JESD204_TX_RX_M_VAL_MASK) >> ALTERA_JESD204_TX_RX_M_VAL_POS;

   return val;
}


int jesd204b_tx_virtual_uart::IORD_JESD204_TX_GET_N_VAL ()
{
   int val;

   val = (IORD_JESD204_TX_ILAS_DATA2_REG() & ALTERA_JESD204_TX_RX_N_VAL_MASK);

   return val;
}

int jesd204b_tx_virtual_uart::IORD_JESD204_TX_GET_NP_VAL ()
{
   int val;

   val = (IORD_JESD204_TX_ILAS_DATA2_REG() & ALTERA_JESD204_TX_RX_NP_VAL_MASK) >> ALTERA_JESD204_TX_RX_NP_VAL_POS;

   return val;
}

int jesd204b_tx_virtual_uart::IORD_JESD204_TX_GET_S_VAL ()
{
   int val;

   val = (IORD_JESD204_TX_ILAS_DATA2_REG() & ALTERA_JESD204_TX_RX_S_VAL_MASK) >> ALTERA_JESD204_TX_RX_S_VAL_POS;

   return val;
}

int jesd204b_tx_virtual_uart::IORD_JESD204_TX_GET_HD_VAL ()
{
   int val;

   val = (IORD_JESD204_TX_ILAS_DATA2_REG() & ALTERA_JESD204_TX_RX_HD_VAL_MASK) >> ALTERA_JESD204_TX_RX_HD_VAL_POS;

   return val;
}

int jesd204b_tx_virtual_uart::IORD_JESD204_TX_TEST_MODE_REG ()
{
   int val;

   val = this->read_reg_by_byte_offset( ALTERA_JESD204_TX_RX_TEST_MODE_REG_OFFSET);

   return val;
}


void jesd204b_tx_virtual_uart::IOWR_JESD204_TX_TEST_MODE_REG ( int val)
{
#if DEBUG_JESD204B_TX_DEVICE_DRIVER
   xprintf ("Writing to TX test mode register on link %d...\n", link);
#endif
   this->write_reg_by_byte_offset( ALTERA_JESD204_TX_RX_TEST_MODE_REG_OFFSET, val);
}

int jesd204b_tx_virtual_uart::IORD_JESD204_TX_ERR_REG ()
{
   int val;

   val = this->read_reg_by_byte_offset( ALTERA_JESD204_TX_ERR_STATUS_REG_OFFSET);

   return val;
}

void jesd204b_tx_virtual_uart::IOWR_JESD204_TX_ERR_REG ( int val)
{
#if DEBUG_JESD204B_TX_DEVICE_DRIVER
   xprintf ("Writing to TX Error register on link %d...\n", link);
#endif
   this->write_reg_by_byte_offset( ALTERA_JESD204_TX_ERR_STATUS_REG_OFFSET, val);
}

int jesd204b_tx_virtual_uart::IORD_JESD204_TX_ERR_EN_REG ()
{
   int val;

   val = this->read_reg_by_byte_offset( ALTERA_JESD204_TX_ERR_EN_REG_OFFSET);

   return val;
}

void jesd204b_tx_virtual_uart::IOWR_JESD204_TX_ERR_EN_REG ( int val)
{

#if DEBUG_JESD204B_TX_DEVICE_DRIVER
   xprintf ("Writing to TX Error Enable register on link %d...\n", link);
#endif
   this->write_reg_by_byte_offset( ALTERA_JESD204_TX_ERR_EN_REG_OFFSET, val);
}
