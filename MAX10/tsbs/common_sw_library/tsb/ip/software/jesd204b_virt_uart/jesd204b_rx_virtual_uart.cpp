/*
 * jesd204b_rx_virtual_uart.cpp
 *
 *  Created on: Jan 22, 2018
 *      Author: yairlinn
 */

#include "jesd204b_rx_virtual_uart.h"
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

using namespace jesd204b_rx;

#ifndef DEBUG_JESD204B_RX_DEVICE_DRIVER
#define DEBUG_JESD204B_RX_DEVICE_DRIVER (0)
#endif 

#define u(x) do { if (DEBUG_JESD204B_RX_DEVICE_DRIVER) {x;} } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if (DEBUG_JESD204B_RX_DEVICE_DRIVER) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} } while (0)

jesd204b_rx_virtual_uart::jesd204b_rx_virtual_uart(unsigned long the_base_address, std::string name, unsigned int link_index) :
	virtual_uart_register_file(),
	generic_driver_encapsulator( the_base_address, SPAN_JESD204B_RX_BYTES, name) {
	link = link_index;
    default_register_descriptions[0x0  >> 2]  = "lane_ctrl_common"    ;
    default_register_descriptions[0x0  >> 2]  = "lane_ctrl_common"     ;
    default_register_descriptions[0x4  >> 2]  = "lane_ctrl_0"          ;
    default_register_descriptions[0x8  >> 2]  = "lane_ctrl_1"          ;
    default_register_descriptions[0xC  >> 2]  = "lane_ctrl_2"          ;
    default_register_descriptions[0x10 >> 2]  = "lane_ctrl_3"          ;
    default_register_descriptions[0x14 >> 2]  = "lane_ctrl_4"          ;
    default_register_descriptions[0x18 >> 2]  = "lane_ctrl_5"          ;
    default_register_descriptions[0x1C >> 2]  = "lane_ctrl_6"          ;
    default_register_descriptions[0x20 >> 2]  = "lane_ctrl_7"          ;
    default_register_descriptions[0x50 >> 2]  = "dll_ctrl"             ;
    default_register_descriptions[0x54 >> 2]  = "syncn_sysref_ctrl"    ;
    default_register_descriptions[0x58 >> 2]  = "ctrl_reserve"         ;
    default_register_descriptions[0x60 >> 2]  = "rx_err0"              ;
    default_register_descriptions[0x64 >> 2]  = "rx_err1"              ;
    default_register_descriptions[0x74 >> 2]  = "rx_err_en"            ;
    default_register_descriptions[0x78 >> 2]  = "rx_err_link_reinit"   ;
    default_register_descriptions[0x80 >> 2]  = "rx_status0"           ;
    default_register_descriptions[0x84 >> 2]  = "rx_status1"           ;
    default_register_descriptions[0x88 >> 2]  = "rx_status2"           ;
    default_register_descriptions[0x8C >> 2]  = "rx_status3"           ;
    default_register_descriptions[0x94 >> 2]  = "ilas_data1"           ;
    default_register_descriptions[0x98 >> 2]  = "ilas_data2"           ;
    default_register_descriptions[0xA0 >> 2]  = "ilas_octet0"          ;
    default_register_descriptions[0xA4 >> 2]  = "ilas_octet1"          ;
    default_register_descriptions[0xA8 >> 2]  = "ilas_octet2"          ;
    default_register_descriptions[0xAC >> 2]  = "ilas_octet3"          ;
    default_register_descriptions[0xC0 >> 2]  = "ilas_data12"          ;
    default_register_descriptions[0xD0 >> 2]  = "rx_test"              ;
    default_register_descriptions[0xF0 >> 2]  = "rx_status4"           ;
    default_register_descriptions[0xF4 >> 2]  = "rx_status5"           ;
    default_register_descriptions[0xF8 >> 2]  = "rx_status6"           ;
    default_register_descriptions[0xFC >> 2]  = "rx_status7"           ;
	
	uart_regfile_single_uart_included_regs_type the_included_regs = get_all_map_keys<register_desc_map_type>(default_register_descriptions);

	this->set_control_reg_map_desc(default_register_descriptions);
	this->set_included_ctrl_regs(the_included_regs);

	dureg(safe_print(std::cout << " set included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
}


jesd204b_rx_virtual_uart::~jesd204b_rx_virtual_uart() {
	// TODO Auto-generated destructor stub
}


unsigned long long jesd204b_rx_virtual_uart::read_control_reg(unsigned long address, unsigned long secondary_uart_address, int* errorptr) {
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return 0;
		}
	return read  (address);
}

void jesd204b_rx_virtual_uart::write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address, int* errorptr) {
	 if (!is_valid_secondary_uart(secondary_uart_address)) {
			dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
			return;
		}
	write(address, data);
}

int jesd204b_rx_virtual_uart::IORD_JESD204_RX_STATUS0_REG()
{
   int val;

   val =  this->read_reg_by_byte_offset(ALTERA_JESD204_TX_RX_STATUS0_REG_OFFSET);

   return val;
}

int jesd204b_rx_virtual_uart::IORD_JESD204_RX_SYNCN_SYSREF_CTRL_REG ()
{
   int val;

   val = this->read_reg_by_byte_offset(ALTERA_JESD204_SYNCN_SYSREF_CTRL_REG_OFFSET);

   return val;
}





void jesd204b_rx_virtual_uart::IOWR_JESD204_RX_SYNCN_SYSREF_CTRL_REG ( int val)
{

#if DEBUG_JESD204B_RX_DEVICE_DRIVER
   xprintf ("Writing val 0x%x to RX syncn_sysref_ctrl reg on link %d...\n", val, link);
#endif
   this->write_reg_by_byte_offset(ALTERA_JESD204_SYNCN_SYSREF_CTRL_REG_OFFSET,val);
}

void jesd204b_rx_virtual_uart::reinit_link()
{
   int val;
   val = IORD_JESD204_RX_SYNCN_SYSREF_CTRL_REG () | ALTERA_JESD204_SYNCN_SYSREF_CTRL_REG_REINIT_MASK;
   IOWR_JESD204_RX_SYNCN_SYSREF_CTRL_REG(val);
}

int jesd204b_rx_virtual_uart::IORD_JESD204_RX_ILAS_DATA1_REG ()
{
   int val;

   val = this->read_reg_by_byte_offset( ALTERA_JESD204_TX_RX_ILAS_DATA1_REG_OFFSET);

   return val;
}

void jesd204b_rx_virtual_uart::IOWR_JESD204_RX_ILAS_DATA1_REG ( int val)
{
   int base;

#if DEBUG_JESD204B_RX_DEVICE_DRIVER
   xprintf ("Writing to RX ILAS DATA1 register on link %d...\n", link);
#endif
   this->write_reg_by_byte_offset( ALTERA_JESD204_TX_RX_ILAS_DATA1_REG_OFFSET, val);
}

int jesd204b_rx_virtual_uart::IORD_JESD204_RX_ILAS_DATA2_REG ()
{
   int val;

   val = this->read_reg_by_byte_offset( ALTERA_JESD204_TX_RX_ILAS_DATA2_REG_OFFSET);

   return val;
}

void jesd204b_rx_virtual_uart::IOWR_JESD204_RX_ILAS_DATA2_REG ( int val)
{

#if DEBUG_JESD204B_RX_DEVICE_DRIVER
   xprintf ("Writing to RX ILAS DATA2 register on link %d...\n", link);
#endif
   this->write_reg_by_byte_offset( ALTERA_JESD204_TX_RX_ILAS_DATA2_REG_OFFSET, val);
}

int jesd204b_rx_virtual_uart::IORD_JESD204_RX_ILAS_DATA12_REG ()
{
   int val;

   val = this->read_reg_by_byte_offset( ALTERA_JESD204_TX_RX_ILAS_DATA12_REG_OFFSET);

   return val;
}

void jesd204b_rx_virtual_uart::IOWR_JESD204_RX_ILAS_DATA12_REG ( int val)
{
   #if DEBUG_JESD204B_RX_DEVICE_DRIVER
   xprintf ("Writing to RX ILAS DATA12 register on link %d...\n", link);
#endif
   this->write_reg_by_byte_offset( ALTERA_JESD204_TX_RX_ILAS_DATA12_REG_OFFSET, val);
}

int jesd204b_rx_virtual_uart::IORD_JESD204_RX_GET_L_VAL ()
{
   int val;

   val = this->IORD_JESD204_RX_ILAS_DATA1_REG() & ALTERA_JESD204_TX_RX_L_VAL_MASK;

   return val;
}

int jesd204b_rx_virtual_uart::IORD_JESD204_RX_GET_F_VAL ()
{
   int val;

   val = (this->IORD_JESD204_RX_ILAS_DATA1_REG() & ALTERA_JESD204_TX_RX_F_VAL_MASK) >> ALTERA_JESD204_TX_RX_F_VAL_POS;

   return val;
}

int jesd204b_rx_virtual_uart::IORD_JESD204_RX_GET_K_VAL ()
{
   int val;

   val = (this->IORD_JESD204_RX_ILAS_DATA1_REG() & ALTERA_JESD204_TX_RX_K_VAL_MASK) >> ALTERA_JESD204_TX_RX_K_VAL_POS;

   return val;
}

int jesd204b_rx_virtual_uart::IORD_JESD204_RX_GET_M_VAL ()
{
   int val;

   val = (this->IORD_JESD204_RX_ILAS_DATA1_REG() & ALTERA_JESD204_TX_RX_M_VAL_MASK) >> ALTERA_JESD204_TX_RX_M_VAL_POS;

   return val;
}

int jesd204b_rx_virtual_uart::IORD_JESD204_RX_GET_N_VAL ()
{
   int val;

   val = (this->IORD_JESD204_RX_ILAS_DATA2_REG() & ALTERA_JESD204_TX_RX_N_VAL_MASK);

   return val;
}


int jesd204b_rx_virtual_uart::IORD_JESD204_RX_GET_NP_VAL ()
{
   int val;

   val = (this->IORD_JESD204_RX_ILAS_DATA2_REG() & ALTERA_JESD204_TX_RX_NP_VAL_MASK) >> ALTERA_JESD204_TX_RX_NP_VAL_POS;

   return val;
}


int jesd204b_rx_virtual_uart::IORD_JESD204_RX_GET_S_VAL ()
{
   int val;

   val = (this->IORD_JESD204_RX_ILAS_DATA2_REG() & ALTERA_JESD204_TX_RX_S_VAL_MASK) >> ALTERA_JESD204_TX_RX_S_VAL_POS;

   return val;
}


int jesd204b_rx_virtual_uart::IORD_JESD204_RX_GET_HD_VAL ()
{
   int val;

   val = (this->IORD_JESD204_RX_ILAS_DATA2_REG() & ALTERA_JESD204_TX_RX_HD_VAL_MASK) >> ALTERA_JESD204_TX_RX_HD_VAL_POS;

   return val;
}



int jesd204b_rx_virtual_uart::IORD_JESD204_RX_TEST_MODE_REG ()
{
   int val;

   val = this->read_reg_by_byte_offset( ALTERA_JESD204_TX_RX_TEST_MODE_REG_OFFSET);

   return val;
}

void jesd204b_rx_virtual_uart::IOWR_JESD204_RX_TEST_MODE_REG ( int val)
{

#if DEBUG_JESD204B_RX_DEVICE_DRIVER
   xprintf ("Writing to RX test mode register on link %d...\n", link);
#endif
   write_reg_by_byte_offset( ALTERA_JESD204_TX_RX_TEST_MODE_REG_OFFSET, val);
}

int jesd204b_rx_virtual_uart::IORD_JESD204_RX_ERR0_REG ()
{
   int val;
   int base;

   val = this->read_reg_by_byte_offset( ALTERA_JESD204_RX_ERR_STATUS_0_REG_OFFSET);

   return val;
}

void jesd204b_rx_virtual_uart::IOWR_JESD204_RX_ERR0_REG ( int val)
{

#if DEBUG_JESD204B_RX_DEVICE_DRIVER
   xprintf ("Writing to RX Error 0 register on link %d...\n", link);
#endif
   write_reg_by_byte_offset( ALTERA_JESD204_RX_ERR_STATUS_0_REG_OFFSET, val);
}

int jesd204b_rx_virtual_uart::IORD_JESD204_RX_ERR1_REG ()
{
   int val;

   val = this->read_reg_by_byte_offset( ALTERA_JESD204_RX_ERR_STATUS_1_REG_OFFSET);

   return val;
}

void jesd204b_rx_virtual_uart::IOWR_JESD204_RX_ERR1_REG ( int val)
{
#if DEBUG_JESD204B_RX_DEVICE_DRIVER
   xprintf ("Writing to RX Error 1 register on link %d...\n", link);
#endif
   write_reg_by_byte_offset( ALTERA_JESD204_RX_ERR_STATUS_1_REG_OFFSET, val);
}


int jesd204b_rx_virtual_uart::IORD_JESD204_RX_ERR_EN_REG ()
{
   int val;

   val = this->read_reg_by_byte_offset( ALTERA_JESD204_RX_ERR_EN_REG_OFFSET);

   return val;
}

void jesd204b_rx_virtual_uart::IOWR_JESD204_RX_ERR_EN_REG ( int val)
{
#if DEBUG_JESD204B_RX_DEVICE_DRIVER
   xprintf ("Writing to RX Error Enable register on link %d...\n", link);
#endif
   write_reg_by_byte_offset( ALTERA_JESD204_RX_ERR_EN_REG_OFFSET, val);
}

/*
int jesd204b_rx_virtual_uart::IORD_RESET_SEQUENCER_STATUS_REG ()
{
   int val;

   val = read_reg_by_byte_offset(ALTERA_RESET_SEQUENCER_STATUS_REG_OFFSET);

   return val;
}

int jesd204b_rx_virtual_uart::IORD_RESET_SEQUENCER_RESET_ACTIVE ()
{
   int val;

   val = IORD_RESET_SEQUENCER_STATUS_REG();

#if DEBUG_JESD204B_RX_DEVICE_DRIVER
   xprintf ("Checking reset active val for link %d...\n", link);
#endif

   if((val & ALTERA_RESET_SEQUENCER_RESET_ACTIVE_MASK) == ALTERA_RESET_SEQUENCER_RESET_ACTIVE_ASSERT)
      return 1;
   else
      return 0;
}

void jesd204b_rx_virtual_uart::IOWR_RESET_SEQUENCER_INIT_RESET_SEQ ()
{
   IOWR_32DIRECT(, ALTERA_RESET_SEQUENCER_CONTROL_REG_OFFSET, 0x1);
#if DEBUG_JESD204B_RX_DEVICE_DRIVER
   xprintf ("Executing complete reset sequencing on link %d...\n", link);
#endif
}

void jesd204b_rx_virtual_uart::IOWR_RESET_SEQUENCER_FORCE_RESET ( int val)
{
   int base;

   base = CALC_BASE_ADDRESS_LINK(JESD204B_IP_INST_JESD204B_SUBSYSTEM_0_RESET_SEQ_BASE, link);
#if DEBUG_JESD204B_RX_DEVICE_DRIVER
   xprintf ("Executing forced reset...\n");
#endif
   IOWR_32DIRECT(base, ALTERA_RESET_SEQUENCER_SW_DIRECT_CONTROLLED_RESETS_OFFSET, val);
}

*/


/*
int jesd204b_rx_virtual_uart::IORD_JESD204_RX_LANE_CTRL_REG ( int offset)
{
   int val;
   int base;

   base = CALC_BASE_ADDRESS_LINK(JESD204B_IP_INST_JESD204B_SUBSYSTEM_0_JESD204B_JESD204_RX_AVS_BASE, link);

   val = this->read_reg_by_byte_offset( offset);

   return val;
}


void jesd204b_rx_virtual_uart::IOWR_JESD204_RX_LANE_CTRL_REG ( int offset, int val)
{
   int base;

   base = CALC_BASE_ADDRESS_LINK(JESD204B_IP_INST_JESD204B_SUBSYSTEM_0_JESD204B_JESD204_RX_AVS_BASE, link);
#if DEBUG_JESD204B_RX_DEVICE_DRIVER
   xprintf ("Writing to RX Lane Control register at offset 0x%x on link %d...\n", offset, link);
#endif
   write_reg_by_byte_offset( offset, val);
}


int jesd204b_rx_virtual_uart::IORD_PIO_CONTROL_REG (void)
{
   int val;

   val = IORD_32DIRECT(JESD204B_IP_INST_PIO_CONTROL_BASE, 0x0);

   return val;
}

void jesd204b_rx_virtual_uart::IOWR_PIO_CONTROL_REG (int val)
{
#if DEBUG_JESD204B_RX_DEVICE_DRIVER
   xprintf ("Writing value: 0x0%x to PIO Control...\n", val);
#endif
   IOWR_32DIRECT(JESD204B_IP_INST_PIO_CONTROL_BASE, 0x0, val);
}

int jesd204b_rx_virtual_uart::IORD_PIO_STATUS_REG (void)
{
   int val;

   val = IORD_32DIRECT(JESD204B_IP_INST_PIO_STATUS_BASE, 0x0);

   return val;
}
*/

/*
int jesd204b_rx_virtual_uart::IORD_XCVR_NATIVE_A10_REG ( int offset)
{
   int val;
   int base;

   base = CALC_BASE_ADDRESS_LINK(JESD204B_IP_INST_JESD204B_SUBSYSTEM_0_JESD204B_RECONFIG_AVMM_BASE, link);

   val = IORD_32DIRECT(base, offset);

   return val;
}

void jesd204b_rx_virtual_uart::IOWR_XCVR_NATIVE_A10_REG ( int offset, int val)
{
   int base;

   base = CALC_BASE_ADDRESS_LINK(JESD204B_IP_INST_JESD204B_SUBSYSTEM_0_JESD204B_RECONFIG_AVMM_BASE, link);
#if DEBUG_JESD204B_RX_DEVICE_DRIVER
   xprintf ("Writing value 0x%2x to A10 XCVR native PHY register on link %d...\n", val, link);
#endif
   IOWR_32DIRECT(base, offset, val);
}

int jesd204b_rx_virtual_uart::IORD_XCVR_ATX_PLL_A10_REG ( int instance, int offset)
{
   int val;
   int base;

   base = CALC_BASE_ADDRESS_XCVR_PLL( CALC_BASE_ADDRESS_LINK( JESD204B_IP_INST_JESD204B_SUBSYSTEM_0_XCVR_ATX_PLL_A10_0_BASE, link ), instance );

   val = IORD_32DIRECT(base, offset);

   return val;
}

void jesd204b_rx_virtual_uart::IOWR_XCVR_ATX_PLL_A10_REG ( int instance, int offset, int val)
{
   int base;

   base = CALC_BASE_ADDRESS_XCVR_PLL( CALC_BASE_ADDRESS_LINK( JESD204B_IP_INST_JESD204B_SUBSYSTEM_0_XCVR_ATX_PLL_A10_0_BASE, link ), instance );
#if DEBUG_JESD204B_RX_DEVICE_DRIVER
   xprintf ("Writing value 0x%2x to A10 XCVR PLL register on link %d...\n", val, link);
#endif
   IOWR_32DIRECT(base, offset, val);
}

int jesd204b_rx_virtual_uart::IORD_CORE_PLL_RECONFIG_C0_COUNTER_REG (void)
{
	return IORD(JESD204B_IP_INST_CORE_PLL_RECONFIG_BASE, ALTERA_CORE_PLL_RECONFIG_C0_COUNTER_OFFSET);
}

int jesd204b_rx_virtual_uart::IORD_CORE_PLL_RECONFIG_C1_COUNTER_REG (void)
{
	return IORD(JESD204B_IP_INST_CORE_PLL_RECONFIG_BASE, ALTERA_CORE_PLL_RECONFIG_C1_COUNTER_OFFSET);
}

void jesd204b_rx_virtual_uart::IOWR_CORE_PLL_RECONFIG_C0_COUNTER_REG (int val)
{
#if DEBUG_JESD204B_RX_DEVICE_DRIVER
   xprintf ("Writing value 0x%x to core PLL reconfig C0 counter register...\n", val);
#endif
   IOWR(JESD204B_IP_INST_CORE_PLL_RECONFIG_BASE, ALTERA_CORE_PLL_RECONFIG_C0_COUNTER_OFFSET, val);
}

void jesd204b_rx_virtual_uart::IOWR_CORE_PLL_RECONFIG_C1_COUNTER_REG (int val)
{
#if DEBUG_JESD204B_RX_DEVICE_DRIVER
   xprintf ("Writing value 0x%x to core PLL reconfig C1 counter register...\n", val);
#endif
   IOWR(JESD204B_IP_INST_CORE_PLL_RECONFIG_BASE, ALTERA_CORE_PLL_RECONFIG_C1_COUNTER_OFFSET, val);
}

void jesd204b_rx_virtual_uart::IOWR_CORE_PLL_RECONFIG_START_REG (int val)
{
#if DEBUG_JESD204B_RX_DEVICE_DRIVER
   printf ("Writing value 0x%x to core PLL start register...\n", val);
#endif
   IOWR(JESD204B_IP_INST_CORE_PLL_RECONFIG_BASE, ALTERA_CORE_PLL_RECONFIG_START_REGISTER_OFFSET, val);
}
*/
