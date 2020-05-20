/*
 * jesd204b_controller.h
 *
 *  Created on: Jan 21, 2019
 *      Author: yairlinn
 */

#ifndef JESD204B_CONTROLLER_H_
#define JESD204B_CONTROLLER_H_

#include "jesd204b_tx_virtual_uart.h"
#include "jesd204b_rx_virtual_uart.h"
#include "jesd204b_tx_and_rx_regs.h"
#include "stdint.h"
#include "generic_driver_encapsulator.h"
#include "basedef.h"
#include <sstream>
#include <iostream>
#include <string>
#include <stdio.h>
#include "linnux_utils.h"
#include <vector>
#include "debug_macro_definitions.h"

#ifndef JESD204B_CONTROLLER_PATCHK_EN
#define JESD204B_CONTROLLER_PATCHK_EN (1)
#endif


#ifndef DEBUG_JESD204B_CONTROLLER
#define DEBUG_JESD204B_CONTROLLER (0)
#endif

namespace jesd204b_ctrl {
const unsigned int MAX_NUM_OPTIONS  = 20; //Maximum number of options per command
const unsigned int MAX_OPTIONS_CHAR = 10; //Maximum number of characters per option
const unsigned int DATAPATH                =       3;                 //1: TX only
const unsigned int PRINT_INTERRUPT_MESSAGES = 1;
                                   //2: RX only
                                   //3: Duplex mode
const unsigned int LOOPBACK_INIT            =   0 ;
const unsigned int USER                        = (0x0);
const unsigned int ALT                         = (0x8);
const unsigned int RAMP                        = (0x9);
const unsigned int PRBS =  (0xA);

const unsigned int SOURCEDEST_INIT  = PRBS;
const unsigned int TICK_DURATION  = 2000000; //Set to 2000000 for mgmt_clk = 100Mhz
const unsigned int RELEASE_RESETS = 0;
const unsigned int DO_NOT_RELEASE_RESETS = 1;
const unsigned int TX_MASK = 0x1;
const unsigned int RX_MASK = 0x2;
const unsigned int PLL_RESET_MASK              =  0x01;
const unsigned int XCVR_RESET_MASK             =  0x02;
const unsigned int CSR_RESET_MASK              =  0x24;// Set both tx_csr and rx_csr
const unsigned int LINK_RESET_MASK             =  0x48;// Set both tx_link and rx_link
const unsigned int FRAME_RESET_MASK            =  0x90;// Set both tx_frame and rx_frame
const unsigned int ALL_RESET_MASK              =  0xFF;// Set ALL resets
const unsigned int HOLD_RESET_MASK             =  0x2 ;
const unsigned int RELEASE_RESET_MASK          =  0x1 ;
const unsigned int XCVR_LINK_FRAME_RESET_MASK  =  0xDA;//Set xcvr, tx_link, tx_frame, rx_link, rx_frame
const unsigned int TX_LINK_FRAME_RESET_MASK    =  0x18;//Set tx_link, tx_frame
const unsigned int RX_LINK_FRAME_RESET_MASK    =  0xC0;//Set rx_link, rx_frame
const unsigned int STATUS_ERROR_SYNC_USER_DATA =  0x2;
const unsigned int STATUS_ERROR_PATCHK         =  0x4;










class jesd204b_controller {

protected:
	std::vector<jesd204b_tx::jesd204b_tx_virtual_uart*>* jesd_tx_uarts_vector;
	std::vector<jesd204b_rx::jesd204b_rx_virtual_uart*>* jesd_rx_uarts_vector;
	altera_pio_encapsulator* pio_control;
	altera_pio_encapsulator* pio_status;
	std::vector<generic_driver_encapsulator*>*  reset_controller_encapsulator_vector;
	uint32_t num_links;
	uint32_t subclass;

public:
	virtual int IORD_RESET_SEQUENCER_STATUS_REG (int link);
	virtual int IORD_RESET_SEQUENCER_RESET_ACTIVE (int link);
	virtual void IOWR_RESET_SEQUENCER_INIT_RESET_SEQ (int link);
	virtual void IOWR_RESET_SEQUENCER_FORCE_RESET (int link, int val);
	virtual int IORD_PIO_CONTROL_REG ();
	virtual void IOWR_PIO_CONTROL_REG (int val);
	virtual int IORD_PIO_STATUS_REG ();
	virtual void link_reinit(int link);
	virtual void reinit_all_links();
	jesd204b_controller(
		std::vector<jesd204b_tx::jesd204b_tx_virtual_uart*>* jesd_tx_uarts_vector,
		std::vector<jesd204b_rx::jesd204b_rx_virtual_uart*>* jesd_rx_uarts_vector,
		altera_pio_encapsulator* pio_control,
		altera_pio_encapsulator* pio_status,
		std::vector<generic_driver_encapsulator*>* reset_controller_encapsulator_vector,
		uint32_t num_links,
		uint32_t subclass
	);


	virtual ~jesd204b_controller();

	virtual uint32_t get_num_links() {
		return num_links;
	}

	virtual void set_num_links(uint32_t num_links) {
		this->num_links = num_links;
	}

	virtual void  do_loopback(unsigned int link, unsigned int loopback_flag)                   ;
	virtual int   jesd204b_a10_main()                                                          ;
	virtual int   StringIsNumeric (char *str)                                                  ;
	virtual void  DelayCounter(alt_u32 count)                                                  ;
	virtual int   Initialize(char *options[][MAX_OPTIONS_CHAR], int *held_resets)              ;
	virtual int   Status(char *options[][MAX_OPTIONS_CHAR])                                    ;
	virtual int   Loopback (char *options[][MAX_OPTIONS_CHAR], int *held_resets, int dnr)      ;
	virtual int   SourceDest (char *options[][MAX_OPTIONS_CHAR], int *held_resets, int dnr)    ;
	virtual int   Test(char *options[][MAX_OPTIONS_CHAR], int *held_resets)                    ;
	virtual void  Sysref(void)                                                                 ;
	virtual int   ResetForce (int link, int reset_val, int hr, int *held)                      ;
	virtual void  Sysref_enable_on(void)                                                       ;
	virtual void  Sysref_enable_off(void)                                                       ;
	virtual void  Sync_assert(void)                                                       ;
	virtual void  Sync_deassert(void);
	virtual int   Reset_X_L_F_Release (int link, int *held_resets)                             ;
	virtual int   ResetSeq (int link, int *held);
	virtual void  InitISR (jesd204b_controller* jesd204b_controller_ptr);

	std::vector<jesd204b_rx::jesd204b_rx_virtual_uart*>* get_jesd_rx_uarts_vector()  {
		return jesd_rx_uarts_vector;
	}

	void set_jesd_rx_uarts_vector(
			std::vector<jesd204b_rx::jesd204b_rx_virtual_uart*>* jesd_rx_uarts_vector) {
		this->jesd_rx_uarts_vector = jesd_rx_uarts_vector;
	}

	std::vector<jesd204b_tx::jesd204b_tx_virtual_uart*>* get_jesd_tx_uarts_vector()  {
		return jesd_tx_uarts_vector;
	}

	void set_jesd_tx_uarts_vector(std::vector<jesd204b_tx::jesd204b_tx_virtual_uart*>* jesd_tx_uarts_vector) {
		this->jesd_tx_uarts_vector = jesd_tx_uarts_vector;
	}

	uint32_t get_subclass() const {
		return subclass;
	}

	void set_subclass(uint32_t subclass) {
		this->subclass = subclass;
	}
};

} /* namespace jesd204b_ctrl */

#endif /* JESD204B_CONTROLLER_H_ */
