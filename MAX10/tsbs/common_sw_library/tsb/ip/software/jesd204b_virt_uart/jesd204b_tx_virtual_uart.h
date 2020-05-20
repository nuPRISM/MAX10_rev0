/*
 * jesd204b_tx_virtual_uart.h
 *
 *  Created on: Jan 22, 2018
 *      Author: yairlinn
 */

#ifndef JESD204B_TX_VIRTUAL_UART_H_
#define JESD204B_TX_VIRTUAL_UART_H_

#include "generic_driver_encapsulator.h"
#include "virtual_uart_register_file.h"

namespace jesd204b_tx {

	const unsigned int SPAN_JESD204B_TX_BYTES = 0xE4;
	
	class jesd204b_tx_virtual_uart : public virtual_uart_register_file, public generic_driver_encapsulator {
	protected:
	  unsigned int link;
	  register_desc_map_type default_register_descriptions;
		
	public:

		jesd204b_tx_virtual_uart(unsigned long the_base_address, std::string name = "undefined", unsigned int link_index = 0);
		virtual ~jesd204b_tx_virtual_uart();
		virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
		virtual void write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
		virtual int IORD_JESD204_TX_STATUS0_REG ();
		virtual int IORD_JESD204_TX_SYNCN_SYSREF_CTRL_REG ();
		virtual void IOWR_JESD204_TX_SYNCN_SYSREF_CTRL_REG (int val);
		virtual int IORD_JESD204_TX_DLL_CTRL_REG();
		virtual void IOWR_JESD204_TX_DLL_CTRL_REG(int val);
		virtual int IORD_JESD204_TX_ILAS_DATA1_REG ();
		virtual void IOWR_JESD204_TX_ILAS_DATA1_REG (int val);
		virtual int IORD_JESD204_TX_ILAS_DATA2_REG ();
		virtual void IOWR_JESD204_TX_ILAS_DATA2_REG (int val);
		virtual int IORD_JESD204_TX_ILAS_DATA12_REG ();
		virtual void IOWR_JESD204_TX_ILAS_DATA12_REG (int val);
		virtual int IORD_JESD204_TX_GET_L_VAL ();
		virtual int IORD_JESD204_TX_GET_F_VAL ();
		virtual int IORD_JESD204_TX_GET_K_VAL ();
		virtual int IORD_JESD204_TX_GET_M_VAL ();
		virtual int IORD_JESD204_TX_GET_N_VAL ();
		virtual int IORD_JESD204_TX_GET_NP_VAL();
		virtual int IORD_JESD204_TX_GET_S_VAL ();
		virtual int IORD_JESD204_TX_GET_HD_VAL();
		virtual int IORD_JESD204_TX_TEST_MODE_REG ();
		virtual void IOWR_JESD204_TX_TEST_MODE_REG (int val);
		virtual int IORD_JESD204_TX_ERR_REG ();
		virtual void IOWR_JESD204_TX_ERR_REG (int val);
		virtual int IORD_JESD204_TX_ERR_EN_REG ();
		virtual void IOWR_JESD204_TX_ERR_EN_REG (int val);

		virtual unsigned int jesd204b_tx_virtual_uart::get_link() {
			return link;
		}

		virtual void jesd204b_tx_virtual_uart::set_link(unsigned int link) {
			this->link = link;
		}




	};
}
#endif /* jesd204b_tx_virtual_uart_H_ */
