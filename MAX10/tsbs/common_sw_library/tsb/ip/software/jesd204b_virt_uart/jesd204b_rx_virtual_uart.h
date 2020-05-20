/*
 * jesd204b_rx_virtual_uart.h
 *
 *  Created on: Jan 22, 2018
 *      Author: yairlinn
 */

#ifndef JESD204B_RX_VIRTUAL_UART_H_
#define JESD204B_RX_VIRTUAL_UART_H_

#include "generic_driver_encapsulator.h"
#include "virtual_uart_register_file.h"

	namespace jesd204b_rx {
		
		const unsigned int SPAN_JESD204B_RX_BYTES = 0x100;
		
	class jesd204b_rx_virtual_uart : public virtual_uart_register_file, public generic_driver_encapsulator {
	protected:
	  unsigned int link;
	  register_desc_map_type default_register_descriptions;


	public:
		jesd204b_rx_virtual_uart(unsigned long the_base_address, std::string name = "undefined", unsigned int link_index = 0);
		virtual ~jesd204b_rx_virtual_uart();
		virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
		virtual void write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
		int IORD_JESD204_RX_STATUS0_REG ();
		virtual		int IORD_JESD204_RX_SYNCN_SYSREF_CTRL_REG ();
		virtual		void IOWR_JESD204_RX_SYNCN_SYSREF_CTRL_REG (int val);
		virtual		int IORD_JESD204_RX_ILAS_DATA1_REG ();
		virtual		void IOWR_JESD204_RX_ILAS_DATA1_REG (int val);
		virtual		int IORD_JESD204_RX_ILAS_DATA2_REG ();
		virtual		void IOWR_JESD204_RX_ILAS_DATA2_REG (int val);
		virtual		int IORD_JESD204_RX_ILAS_DATA12_REG ();
		virtual		void IOWR_JESD204_RX_ILAS_DATA12_REG (int val);
		virtual		int IORD_JESD204_RX_GET_L_VAL  ();
		virtual		int IORD_JESD204_RX_GET_F_VAL  ();
		virtual		int IORD_JESD204_RX_GET_K_VAL  ();
		virtual		int IORD_JESD204_RX_GET_M_VAL  ();
		virtual		int IORD_JESD204_RX_GET_N_VAL  ();
		virtual		int IORD_JESD204_RX_GET_NP_VAL ();
		virtual		int IORD_JESD204_RX_GET_S_VAL  ();
		virtual		int IORD_JESD204_RX_GET_HD_VAL ();
		virtual		int IORD_JESD204_RX_TEST_MODE_REG ();
		virtual		void IOWR_JESD204_RX_TEST_MODE_REG (int val);
		virtual		int IORD_JESD204_RX_ERR0_REG ();
		virtual		void IOWR_JESD204_RX_ERR0_REG (int val);
		virtual		int IORD_JESD204_RX_ERR1_REG ();
		virtual		void IOWR_JESD204_RX_ERR1_REG (int val);
		virtual		int IORD_JESD204_RX_ERR_EN_REG ();
		virtual     void IOWR_JESD204_RX_ERR_EN_REG (int val);
        virtual     void reinit_link();
	virtual unsigned int get_link() {
		return link;
	}

	virtual void set_link(unsigned int link) {
		this->link = link;
	}
};
}

#endif /* jesd204b_rx_virtual_uart_H_ */
