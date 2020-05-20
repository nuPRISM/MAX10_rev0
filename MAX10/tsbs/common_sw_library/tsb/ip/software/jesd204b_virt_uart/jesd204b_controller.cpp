/*
 * jesd204b_controller.cpp
 *
 *  Created on: Jan 21, 2019
 *      Author: yairlinn
 */

#include "jesd204b_controller.h"
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "system.h"
#include "io.h"
#include "alt_types.h"
#include "sys/alt_irq.h"
#include <stdio.h>

using namespace jesd204b_tx;
using namespace jesd204b_rx;

namespace jesd204b_ctrl {

jesd204b_controller::jesd204b_controller (
		std::vector<jesd204b_tx::jesd204b_tx_virtual_uart*>* jesd_tx_uarts_vector,
		std::vector<jesd204b_rx::jesd204b_rx_virtual_uart*>* jesd_rx_uarts_vector,
		altera_pio_encapsulator* pio_control,
		altera_pio_encapsulator* pio_status,
		std::vector<generic_driver_encapsulator*>* reset_controller_encapsulator_vector,
		uint32_t num_links,
		uint32_t subclass
	) {

	this->jesd_tx_uarts_vector = jesd_tx_uarts_vector;
	this->jesd_rx_uarts_vector = jesd_rx_uarts_vector;
    this->pio_control = pio_control;
    this->pio_status = pio_status;
    this->reset_controller_encapsulator_vector = reset_controller_encapsulator_vector;
    if ((num_links != jesd_tx_uarts_vector->size()) || (num_links != jesd_rx_uarts_vector->size()) || (num_links != reset_controller_encapsulator_vector->size())) {
    	std::cout <<"Error: jesd204b_controller::jesd204b_controller  num_links = " << num_links << " but jesd_tx_uarts_vector->size() = " <<
    			jesd_tx_uarts_vector->size() << " jesd_rx_uarts_vector->size() = " << jesd_rx_uarts_vector->size() << " reset_controller_encapsulator_vector->size() = "
				<< reset_controller_encapsulator_vector->size() << std::endl;
    	this->set_num_links(0);
    } else {
    	std::cout << "jesd204b_controller::jesd204b_controller  initialized for num_links = " << num_links  <<std::endl;
        this->set_num_links(num_links);
    }
    this->set_subclass(subclass);
}


int jesd204b_controller::IORD_RESET_SEQUENCER_STATUS_REG (int link) {
	if ( this->reset_controller_encapsulator_vector->at(link) == NULL) {
			 xprintf ("Error IORD_RESET_SEQUENCER_RESET_ACTIVE for link %d..., NULL pointer for reset sequencer\n", link);
			 return 0;
	}
	return this->reset_controller_encapsulator_vector->at(link)->read_reg_by_byte_offset(ALTERA_RESET_SEQUENCER_STATUS_REG_OFFSET);
}

int jesd204b_controller::IORD_RESET_SEQUENCER_RESET_ACTIVE (int link) {
	 if ( this->reset_controller_encapsulator_vector->at(link) == NULL) {
		 xprintf ("Error IORD_RESET_SEQUENCER_RESET_ACTIVE for link %d..., NULL pointer for reset sequencer\n", link);
		 return 0;
	 }
	   int val;
	   val = this->IORD_RESET_SEQUENCER_STATUS_REG(link);

	   if((val & ALTERA_RESET_SEQUENCER_RESET_ACTIVE_MASK) == ALTERA_RESET_SEQUENCER_RESET_ACTIVE_ASSERT)
	      return 1;
	   else
	      return 0;


}

void jesd204b_controller::IOWR_RESET_SEQUENCER_INIT_RESET_SEQ (int link) {
	#if DEBUG_JESD204B_CONTROLLER
	   xprintf ("Executing complete reset sequencing on link %d...\n", link);
	#endif
	   if ( this->reset_controller_encapsulator_vector->at(link) != NULL) {
	      this->reset_controller_encapsulator_vector->at(link)->write_reg_by_byte_offset(ALTERA_RESET_SEQUENCER_CONTROL_REG_OFFSET, 0x1);
	   } else {
		   xprintf ("Error IOWR_RESET_SEQUENCER_INIT_RESET_SEQ for link %d..., NULL pointer for reset sequencer\n", link);
	   }

}

void jesd204b_controller::IOWR_RESET_SEQUENCER_FORCE_RESET (int link, int val) {
	 if ( this->reset_controller_encapsulator_vector->at(link) != NULL) {
	      this->reset_controller_encapsulator_vector->at(link)->write_reg_by_byte_offset(ALTERA_RESET_SEQUENCER_SW_DIRECT_CONTROLLED_RESETS_OFFSET,val);
	 } else {
		 xprintf ("Error IOWR_RESET_SEQUENCER_FORCE_RESET for link %d..., NULL pointer for reset sequencer\n", link);
	}
}


int jesd204b_controller::IORD_PIO_CONTROL_REG () {
	return this->pio_control->read();
}

void jesd204b_controller::IOWR_PIO_CONTROL_REG (int val){
	this->pio_control->write(val);
}

int jesd204b_controller::IORD_PIO_STATUS_REG () {
	return this->pio_status->read();
}



jesd204b_controller::~jesd204b_controller() {
	// TODO Auto-generated destructor stub
}



#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
static void ISR_JESD_RX (void *);
static void ISR_JESD_TX (void *);
static void ISR_SPI (void *);
#else
static void ISR_JESD_RX (void *, alt_u32);
//static void ISR_JESD_TX (void *, alt_u32);
//static void ISR_SPI (void *, alt_u32);
#endif /*ALT_ENHANCED_INTERRUPT_API_PRESENT*/


void  jesd204b_controller::do_loopback(unsigned int link, unsigned int loopback_flag) {
	unsigned long write_val;
	 if (loopback_flag == 1)
	            write_val = this->IORD_PIO_CONTROL_REG() | (ALTERA_PIO_CONTROL_RX_SERIALLPBKEN_0_MASK << link); //Force loopback PIO registers to 1 (but leave other PIO registers untouched)
	         else if (loopback_flag == 0)
	            write_val = this->IORD_PIO_CONTROL_REG() & ~(ALTERA_PIO_CONTROL_RX_SERIALLPBKEN_0_MASK << link); //Force loopback PIO registers to 0 (but leave other PIO registers untouched)
	         else {
	            xprintf("FATAL ERROR: Invalid value for loopback_flag\n"); // FATAL ERROR: Should never arrive here during normal operation
                return;
	         }
	#if DEBUG_JESD204B_CONTROLLER
	         xprintf("DEBUG: Value to be written to PIO control: 0x0%x\n", write_val);
	         xprintf("DEBUG: Writing loopback value to PIO control...\n");
	#endif
	         this->IOWR_PIO_CONTROL_REG(write_val);


}

int jesd204b_controller::jesd204b_a10_main()
{
   int link = 0;
   int write_val = 0;
   int initialize_ret = 0;
   char *options[MAX_NUM_OPTIONS][MAX_OPTIONS_CHAR] = {{NULL}};
   int held_resets[this->get_num_links()];

   for (int i = 0; i < this->get_num_links(); i++) {
	   held_resets[i] = 0x0;  //Bit positions: {7, 6, 5, 4, 3, 2, 1, 0} = {rx_frame, rx_link, rx_csr, tx_frame, tx_link, tx_csr, xcvr, pll}
   }

   //Assert complete reset sequencing for each link
   xprintf("INFO: Asserting complete reset sequencing for each link...\n");

   for (link = 0; link < this->get_num_links(); link++)
   {
	   if (this->reset_controller_encapsulator_vector->at(link) != NULL) {
			  if (ResetSeq(link, held_resets) != 0)
			  {
				 xprintf("ERROR: Initial reset sequencing failed for link %d!\n", link);
				 xprintf("ERROR: Exiting terminal...\n");
				 exit(0);
			  }
	   } else {
		   xprintf("Reset seq pointer for link %d is NULL, relying on other link to reset link\n", link);
	   }
   }

   //Disable certain TX/RX Error Interrupt Enable CSR registers in JESD204B IP Core
   xprintf("INFO: Disabling certain TX/RX error interrupt enables from JESD204B CSR for each link...\n");

   for (link = 0; link < this->get_num_links(); link++)
   {
#if DEBUG_JESD204B_CONTROLLER
      xprintf("\n");
      xprintf("DEBUG: Validating tx_err_enable CSR before write...\n");
      xprintf("DEBUG: tx_err_enable value for link %d is 0x%x\n", link, this->jesd_tx_uarts_vector->at(link)->IORD_JESD204_TX_ERR_EN_REG());
      xprintf("DEBUG: Validating rx_err_enable CSR before write...\n");
      xprintf("DEBUG: rx_err_enable value for link %d is 0x%x\n", link, this->jesd_rx_uarts_vector->at(link)->IORD_JESD204_RX_ERR_EN_REG());
      xprintf("\n");
#endif

      //Write to TX error interrupt enable register
      write_val = this->jesd_tx_uarts_vector->at(link)->IORD_JESD204_TX_ERR_EN_REG() & ~(ALTERA_JESD204_TX_ERR_EN_REG_XCVR_PLL_LOCKED_ERR_EN_MASK |
                                                       ALTERA_JESD204_TX_ERR_EN_REG_PCFIFO_FULL_ERR_EN_MASK |
                                                       ALTERA_JESD204_TX_ERR_EN_REG_PCFIFO_EMPTY_ERR_EN_MASK);
#if DEBUG_JESD204B_CONTROLLER
      xprintf("DEBUG: Value to be written in to TX Error Interrupt Enable register for link %d is 0x%x\n", link, write_val);
#endif
      this->jesd_tx_uarts_vector->at(link)->IOWR_JESD204_TX_ERR_EN_REG(write_val);

      //Write to RX error interrupt enable register
      write_val =  this->jesd_rx_uarts_vector->at(link)->IORD_JESD204_RX_ERR_EN_REG() & ~(ALTERA_JESD204_RX_ERR_EN_REG_RX_LOCKED_TO_DATA_ERR_EN_MASK |
                                                       ALTERA_JESD204_RX_ERR_EN_REG_PCFIFO_FULL_ERR_EN_MASK |
                                                       ALTERA_JESD204_RX_ERR_EN_REG_PCFIFO_EMPTY_ERR_EN_MASK);
#if DEBUG_JESD204B_CONTROLLER
      xprintf("DEBUG: Value to be written in to RX Error Interrupt Enable register for link %d is 0x%x\n", link, write_val);
#endif
      this->jesd_rx_uarts_vector->at(link)->IOWR_JESD204_RX_ERR_EN_REG(write_val);

#if DEBUG_JESD204B_CONTROLLER
      xprintf("\n");
      xprintf("DEBUG: Validating tx_err_enable CSR after write...\n");
      xprintf("DEBUG: tx_err_enable value for link %d is 0x%x\n", link, this->jesd_tx_uarts_vector->at(link)->IORD_JESD204_TX_ERR_EN_REG());
      xprintf("DEBUG: Validating rx_err_enable CSR after write...\n");
      xprintf("DEBUG: rx_err_enable value for link %d is 0x%x\n", link, this->jesd_rx_uarts_vector->at(link)->IORD_JESD204_RX_ERR_EN_REG());
      xprintf("\n");
#endif

      // Write 1 to clear all the valid and active status in RX Error status 0, RX Error status 1, TX Error status register
      this->jesd_rx_uarts_vector->at(link)->IOWR_JESD204_RX_ERR0_REG(ALTERA_JESD204_RX_ERR_STATUS_0_CLEAR_ERROR_MASK);
      this->jesd_rx_uarts_vector->at(link)->IOWR_JESD204_RX_ERR1_REG(ALTERA_JESD204_RX_ERR_STATUS_1_CLEAR_ERROR_MASK);
      this->jesd_tx_uarts_vector->at(link)->IOWR_JESD204_TX_ERR_REG(ALTERA_JESD204_TX_ERR_STATUS_CLEAR_ERROR_MASK);
   }

   initialize_ret = Initialize(options, held_resets);

   if (initialize_ret == 0)
      xprintf("INFO: Initialization successful!\n");
   else if (initialize_ret == 1)
      xprintf("ERROR: Initialization FAILED!\n");
   else
   {
      if ((initialize_ret & STATUS_ERROR_SYNC_USER_DATA) == STATUS_ERROR_SYNC_USER_DATA)
         xprintf("WARNING: Initialization completed but link errors found!\n");

#if JESD204B_CONTROLLER_PATCHK_EN
      if ((initialize_ret & STATUS_ERROR_PATCHK) == STATUS_ERROR_PATCHK)
         xprintf("WARNING: Initialization completed but pattern check errors found!\n");
#endif
   }

   xprintf("INFO: Reset link and clear JESD204B error status registers for each link...\n");

   for (link = 0; link < this->get_num_links(); link++)
   {
	  if ( this->reset_controller_encapsulator_vector->at(link) == NULL) {
	  		 xprintf ("Skipping reset for link %d because NULL pointer for reset sequencer\n", link);
	  } else {
      //Assert and hold XCVR, link, frame resets
      if (ResetForce(link, XCVR_LINK_FRAME_RESET_MASK, HOLD_RESET_MASK, held_resets) != 0)
         return 1;

      //Release XCVR, link and frame resets
      if (Reset_X_L_F_Release (link, held_resets) != 0)
         return 1;

      // Write 1 to clear all the valid and active status in RX Error status 0, RX Error status 1, TX Error status register
      this->jesd_rx_uarts_vector->at(link)->IOWR_JESD204_RX_ERR0_REG(ALTERA_JESD204_RX_ERR_STATUS_0_CLEAR_ERROR_MASK);
      this->jesd_rx_uarts_vector->at(link)->IOWR_JESD204_RX_ERR1_REG(ALTERA_JESD204_RX_ERR_STATUS_1_CLEAR_ERROR_MASK);
      this->jesd_tx_uarts_vector->at(link)->IOWR_JESD204_TX_ERR_REG(ALTERA_JESD204_TX_ERR_STATUS_CLEAR_ERROR_MASK);
      this->jesd_rx_uarts_vector->at(link)->IOWR_JESD204_RX_TEST_MODE_REG(0); //move to normal mode
	  }
      do_loopback(link,0); //remove loopback
   }

   //Initialize (i.e register) ISRs
  // InitISR(this);

   xprintf("INFO: End JESD204B initialization sequence\n");

  return 0;
}

int jesd204b_controller::StringIsNumeric (char *str)
{
   while (*str)
   {
      if (!isdigit(*str))
      {
         return 0;
      }
      str++;
   }

   return 1;
}

void jesd204b_controller::DelayCounter(alt_u32 count)
{
   alt_u32 tick;
   alt_u32 tock = 0;

   for (tock = 0; tock < count; tock++)
   {
      for (tick = 0; tick < TICK_DURATION; tick++) {
         __asm__("nop"); //NOP
      }
#if DEBUG_JESD204B_CONTROLLER
      xprintf("DEBUG: Count: %d\n", (int) tock+1);
#endif
   }
}

int jesd204b_controller::Initialize(char *options[][MAX_OPTIONS_CHAR], int *held_resets)
{
   char *null_options[MAX_NUM_OPTIONS][MAX_OPTIONS_CHAR] = {{NULL}};
   char *current_option;
   int i = 0;
   int ret_val = 0;

   xprintf("INFO: Initialization in progress...\n");
   Sysref_enable_off();

   for (i = 0; options[i][MAX_OPTIONS_CHAR] != NULL; i++)
   {
      current_option = options[i][MAX_OPTIONS_CHAR];

      if (i == 0 && StringIsNumeric(current_option)) //Do nothing
         xprintf("INFO: Current option value: %s\n", current_option);
      else
      {
         if (strcmp("n", current_option) == 0)
         {
            xprintf("INFO: Initializing to user mode...\n");
         }
         else
         {
            xprintf("ERROR: Option entered: %s is invalid!\n", current_option);
            return 1;
         }
      }
   }

   if (Test(options, held_resets) != 0)
   {
      xprintf("ERROR: While setting Test mode\n");
      return 1;
   }

   /*
   //Pulse sysref

   xprintf("INFO: Pulse sysref...\n");
   Sysref();
*/
   Sysref_enable_on();
   xprintf("INFO: Wait for 10 seconds...\n");
   DelayCounter(10); //Delay for 10 "seconds"
   Sync_assert();
   DelayCounter(1); //delay for 1 second
   Sync_deassert();
   DelayCounter(10); //Delay for 10 "seconds"
   //Report Status 0 registers and pattern checker error status (for test mode only)
   ret_val = Status(null_options);

   return ret_val;
}

int jesd204b_controller::Status(char *options[][MAX_OPTIONS_CHAR])
{
   char *current_option;
   int i = 0;
   int link = 0;
   int link_indicator = 0;
   int link_id;
   int opt = 0;
   int ret_val = 0;
   alt_u32 status0;
   alt_u32 patchk_error_mask   = 0x0;
   alt_u32 patchk_error_assert = 0x0;

   xprintf("INFO: Reporting link status...\n");

   for (i = 0; options[i][MAX_OPTIONS_CHAR] != NULL; i++)
   {
      current_option = options[i][MAX_OPTIONS_CHAR];

      if (i == 0 && StringIsNumeric(current_option))
      {
         link_id = atoi(current_option);
         if (link_id >= this->get_num_links())
         {
            xprintf("ERROR: Link indicated: %d must be less than this->get_num_links(): %d\n", link_id, this->get_num_links());
            return 1;
         }
         else
         {
            link_indicator = 1;
            xprintf("INFO: Link indicated: %d\n", link_id);
         }
      }
      else
      {
         if (strcmp("t", current_option) == 0)
         {
            xprintf("INFO: TX option detected...\n");
            opt |= TX_MASK;
         }
         else if (strcmp("r", current_option) == 0)
         {
            xprintf("INFO: RX option detected...\n");
            opt |= RX_MASK;
         }
         else
         {
            xprintf("ERROR: Option entered: %s is invalid!\n", current_option);
            return 1;
         }
      }
   }

   //If no options indicated, set default options
   if (opt == 0)
      opt = DATAPATH; //1: TX only
                      //2: RX only
                      //3: Duplex mode

   //Report status of each link
   for (link = 0; link < this->get_num_links(); link++)
   {
      if (link_indicator == 1 && link != link_id)
         continue;
      else
      {
         if ((opt & TX_MASK) == TX_MASK)
         {
            status0 = this->jesd_tx_uarts_vector->at(link)->IORD_JESD204_TX_STATUS0_REG();
            xprintf("\n");
            xprintf("INFO: TX status 0 register for link %d: 0x%08X\n", link, (unsigned int) status0);
            if (((status0 & ALTERA_JESD204_TX_RX_STATUS0_REG_SYNCN_MASK) != ALTERA_JESD204_TX_RX_STATUS0_REG_SYNCN_DEASSERT) ||
               ((status0 & ALTERA_JESD204_TX_RX_STATUS0_REG_DLL_STATE_MASK) != ALTERA_JESD204_TX_RX_STATUS0_REG_USER_DATA_MODE))
            {
               xprintf("WARNING: TX Link %d is not in sync or link is not in user data mode\n", link);
               ret_val |= STATUS_ERROR_SYNC_USER_DATA;
            }
         }

         if ((opt & RX_MASK) == RX_MASK)
         {
            status0 = this->jesd_rx_uarts_vector->at(link)->IORD_JESD204_RX_STATUS0_REG();
            xprintf("\n");
            xprintf("INFO: RX status 0 register for link %d: 0x%08X\n", link, (unsigned int) status0);
            if ((status0 & ALTERA_JESD204_TX_RX_STATUS0_REG_SYNCN_MASK) != ALTERA_JESD204_TX_RX_STATUS0_REG_SYNCN_DEASSERT)
            {
               xprintf("WARNING: RX Link %d is not in sync\n", link);
               ret_val |= STATUS_ERROR_SYNC_USER_DATA;
            }
         }
#if JESD204B_CONTROLLER_PATCHK_EN
         xprintf("\n");
         xprintf("INFO: Reporting pattern checker status...\n");

         patchk_error_mask = ALTERA_PIO_STATUS_PATCHK_ERROR_0_MASK << (3*link);
         patchk_error_assert = ALTERA_PIO_STATUS_PATCHK_ERROR_0_ASSERT << (3*link);

#if DEBUG_JESD204B_CONTROLLER
         xprintf("\n");
         xprintf("DEBUG: patchk_error_mask value for link %d: 0x%x\n", link, (unsigned int) patchk_error_mask);
         xprintf("DEBUG: patchk_error_assert value for link %d: 0x%x\n", link, (unsigned int) patchk_error_assert);
         xprintf("DEBUG: IORD_PIO_STATUS_REG value: 0x%x\n", this->IORD_PIO_STATUS_REG());
         xprintf("\n");
#endif

         if ((this->IORD_PIO_STATUS_REG() & patchk_error_mask) == patchk_error_assert)
         {
            xprintf("WARNING: Pattern checker error detected on link %d\n", link);
            ret_val |= STATUS_ERROR_PATCHK;
         }
         else
            xprintf("INFO: No pattern checker error detected on link %d\n", link);
#endif
      }
   }

return ret_val;
}

int jesd204b_controller::Loopback (char *options[][MAX_OPTIONS_CHAR], int *held_resets, int dnr)
{
   char *current_option;
   int i = 0;
   int link = 0;
   int link_indicator = 0;
   int link_id;
   int loopback_flag = LOOPBACK_INIT;
   int write_val = 0;

   xprintf("INFO: Setting loopback mode in progress...\n");

   for (i = 0; options[i][MAX_OPTIONS_CHAR] != NULL; i++)
   {
      current_option = options[i][MAX_OPTIONS_CHAR];

      if (i == 0 && StringIsNumeric(current_option))
      {
         link_id = atoi(current_option);
         if (link_id >= this->get_num_links())
         {
            xprintf("ERROR: Link indicated: %d must be less than this->get_num_links(): %d\n", link_id, this->get_num_links());
            return 1;
         }
         else
         {
            link_indicator = 1;
            xprintf("INFO: Link indicated: %d\n", link_id);
         }
      }
      else
      {
         if (strcmp("n", current_option) == 0)
         {
            xprintf("INFO: Loopback disable detected...\n");
            loopback_flag = 0;
         }
         else
         {
            xprintf("ERROR: Option entered: %s is invalid!\n", current_option);
            return 1;
         }
      }
   }

   if (loopback_flag == 1)
      xprintf("INFO: Loopback enable detected...\n");
   else if (loopback_flag == 0)
      xprintf("INFO: Loopback disable detected...\n");

   for (link = 0; link < this->get_num_links(); link++)
   {
      if (link_indicator == 1 && link != link_id)
      {
         continue;
      }
      else
      {
         if (loopback_flag == 1)
            write_val = this->IORD_PIO_CONTROL_REG() | (ALTERA_PIO_CONTROL_RX_SERIALLPBKEN_0_MASK << link); //Force loopback PIO registers to 1 (but leave other PIO registers untouched)
         else if (loopback_flag == 0)
            write_val = this->IORD_PIO_CONTROL_REG() & ~(ALTERA_PIO_CONTROL_RX_SERIALLPBKEN_0_MASK << link); //Force loopback PIO registers to 0 (but leave other PIO registers untouched)
         else
            xprintf("FATAL ERROR: Invalid value for loopback_flag\n"); // FATAL ERROR: Should never arrive here during normal operation

         //Assert and hold XCVR, link, frame resets while writing to JESD CSR
         if (ResetForce(link, XCVR_LINK_FRAME_RESET_MASK, HOLD_RESET_MASK, held_resets) != 0)
            return 1;
#if DEBUG_JESD204B_CONTROLLER
         xprintf("DEBUG: Value to be written to PIO control: 0x0%x\n", write_val);
         xprintf("DEBUG: Writing loopback value to PIO control...\n");
#endif
         this->IOWR_PIO_CONTROL_REG(write_val);

         if (dnr != DO_NOT_RELEASE_RESETS)
         {
            //Relese XCVR, link and frame resets after done writing to JESD CSR
            if (Reset_X_L_F_Release (link, held_resets) != 0)
               return 1;
         }
      }
   }

   return 0;
}

int jesd204b_controller::SourceDest (char *options[][MAX_OPTIONS_CHAR], int *held_resets, int dnr)
{
   char *current_option;
   int i = 0;
   int link = 0;
   int link_indicator = 0;
   int link_id;
   int sd = 0;
   int opt_set = 0;
   int mask_val = 0xF;

   xprintf("INFO: Setting source/destination mode in progress...\n");

   for (i = 0; options[i][MAX_OPTIONS_CHAR] != NULL; i++)
   {
      current_option = options[i][MAX_OPTIONS_CHAR];

      if (i == 0 && StringIsNumeric(current_option))
      {
         link_id = atoi(current_option);
         if (link_id >= this->get_num_links())
         {
            xprintf("ERROR: Link indicated: %d must be less than this->get_num_links(): %d\n", link_id, this->get_num_links());
            return 1;
         }
         else
         {
            link_indicator = 1;
            xprintf("INFO: Link indicated: %d\n", link_id);
         }
      }
      else
      {
     	 if (strcmp("s", current_option) == 0)
         {
            xprintf("INFO: TX datapath detected...\n");
            sd |= TX_MASK;
         }
     	 else if (strcmp("d", current_option) == 0)
         {
            xprintf("INFO: RX datapath detected...\n");
            sd |= RX_MASK;
         }
     	 else if ((strcmp("u", current_option) == 0) || (strcmp("n", current_option) == 0))
         {
            xprintf("INFO: User data detected...\n");
            if (opt_set == 1)
            {
               xprintf("ERROR: Too many options entered!\n");
               return 1;
            }
            else
            {
               mask_val = ALTERA_JESD204_TX_RX_TEST_MODE_NO_TEST_MASK;
               opt_set = 1;
            }
         }
         else if (strcmp("a", current_option) == 0)
         {
            xprintf("INFO: Alternate pattern detected...\n");
            if (opt_set == 1)
            {
               xprintf("ERROR: Too many options entered!\n");
               return 1;
            }
            else
            {
               mask_val = ALTERA_JESD204_TX_RX_TEST_MODE_ALT_MASK;
               opt_set = 1;
            }
         }
         else if (strcmp("r", current_option) == 0)
         {
            xprintf("INFO: Ramp pattern detected...\n");
            if (opt_set == 1)
            {
               xprintf("ERROR: Too many options entered!\n");
               return 1;
            }
            else
            {
               mask_val = ALTERA_JESD204_TX_RX_TEST_MODE_RAMP_MASK;
               opt_set = 1;
            }
         }
         else if (strcmp("p", current_option) == 0)
         {
            xprintf("INFO: PRBS pattern detected...\n");
            if (opt_set == 1)
            {
               xprintf("ERROR: Too many options entered!\n");
               return 1;
            }
            else
            {
               mask_val = ALTERA_JESD204_TX_RX_TEST_MODE_PRBS_MASK;
               opt_set = 1;
            }
         }
         else
         {
        	 xprintf("ERROR: Option entered: %s is invalid!\n", current_option);
        	 return 1;
         }
      }
   }

   //Default options checking
   if (sd == 0)
      sd = DATAPATH; //1: TX only
                     //2: RX only
                     //3: Duplex mode

   if (mask_val == 0xF) //No options set
   {
      xprintf("INFO: Defaulting to PRBS pattern generator/checker...\n");
      mask_val = SOURCEDEST_INIT;
#if DEBUG_JESD204B_CONTROLLER
      xprintf("\n");
      xprintf("DEBUG: Default mask_val is 0x%X\n", mask_val);
      xprintf("\n");
#endif
   }

   for (link = 0; link < this->get_num_links(); link++)
   {
      if (link_indicator == 1 && link != link_id)
         continue;
      else
      {
         //Assert and hold XCVR, link, frame resets while writing to JESD CSR
         if (ResetForce(link, XCVR_LINK_FRAME_RESET_MASK, HOLD_RESET_MASK, held_resets) != 0)
            return 1;

         if ((sd & TX_MASK) == TX_MASK)
         {
#if DEBUG_JESD204B_CONTROLLER
            xprintf("DEBUG: TX test mode register value at link %d before write: 0x%08X\n", link, this->jesd_tx_uarts_vector->at(link)->IORD_JESD204_TX_TEST_MODE_REG());
            xprintf("DEBUG: Writing to TX test mode register...\n");
#endif
            this->jesd_tx_uarts_vector->at(link)->IOWR_JESD204_TX_TEST_MODE_REG (mask_val);
#if DEBUG_JESD204B_CONTROLLER
            xprintf("DEBUG: TX test mode register value at link %d after write: 0x%08X\n", link, this->jesd_tx_uarts_vector->at(link)->IORD_JESD204_TX_TEST_MODE_REG());
#endif
         }

         if ((sd & RX_MASK) == RX_MASK)
         {
#if DEBUG_JESD204B_CONTROLLER
            xprintf("DEBUG: RX test mode register value at link %d before write: 0x%08X\n", link, this->jesd_rx_uarts_vector->at(link)->IORD_JESD204_RX_TEST_MODE_REG());
            xprintf("DEBUG: Writing to RX test mode register...\n");
#endif
            this->jesd_rx_uarts_vector->at(link)->IOWR_JESD204_RX_TEST_MODE_REG (mask_val);
#if DEBUG_JESD204B_CONTROLLER
            xprintf("DEBUG: RX test mode register value at link %d after write: 0x%08X\n", link, this->jesd_rx_uarts_vector->at(link)->IORD_JESD204_RX_TEST_MODE_REG());
#endif
         }

         if (dnr != DO_NOT_RELEASE_RESETS)
         {
            //Relese XCVR, link and frame resets after done writing to JESD CSR
            if (Reset_X_L_F_Release (link, held_resets) != 0)
               return 1;
         }
      }
   }

   return 0;
}

int jesd204b_controller::Test(char *options[][MAX_OPTIONS_CHAR], int *held_resets)
{
   char *current_option;
   int i = 0;

   for (i = 0; options[i][MAX_OPTIONS_CHAR] != NULL; i++)
   {
      current_option = options[i][MAX_OPTIONS_CHAR];

      if (i == 0 && StringIsNumeric(current_option)) //Do nothing
         ;
      else
      {
         if (strcmp("n", current_option) == 0)
            xprintf("INFO: Test mode disabled detected...\n");
         else
         {
        	 xprintf("ERROR: Option entered: %s is invalid!\n", current_option);
        	 return 1;
         }
      }
   }

   //Execute SourceDest command
   if ( SourceDest( options, held_resets, DO_NOT_RELEASE_RESETS ) != 0 )
      return 1;

   //Execute Loopback command
   if ( Loopback( options, held_resets, RELEASE_RESETS ) != 0 )
      return 1;

   return 0;
}

void jesd204b_controller::Sysref(void)
{
#if DEBUG_JESD204B_CONTROLLER
   xprintf("DEBUG: Force sysref to 0 before asserting...\n");
#endif
   this->IOWR_PIO_CONTROL_REG(IORD_PIO_CONTROL_REG() & ~ALTERA_PIO_CONTROL_SYSREF_MASK); //Force sysref PIO register to 0 (but leave other PIO registers untouched)

#if DEBUG_JESD204B_CONTROLLER
   xprintf("DEBUG: Asserting sysref...\n");
#endif
   this->IOWR_PIO_CONTROL_REG(IORD_PIO_CONTROL_REG() | ALTERA_PIO_CONTROL_SYSREF_MASK); //Force sysref PIO register to 1 (but leave other PIO registers untouched)

#if DEBUG_JESD204B_CONTROLLER
   xprintf("DEBUG: De-asserting sysref...\n");
#endif
   this->IOWR_PIO_CONTROL_REG(IORD_PIO_CONTROL_REG() & ~ALTERA_PIO_CONTROL_SYSREF_MASK); //Force sysref PIO register to 0 (but leave other PIO registers untouched)
}



void jesd204b_controller::Sysref_enable_off(void)
{
#if DEBUG_JESD204B_CONTROLLER
   xprintf("DEBUG: disable sysref...\n");
#endif
   this->IOWR_PIO_CONTROL_REG(IORD_PIO_CONTROL_REG() & ~ALTERA_PIO_CONTROL_SYSREF_MASK); //Force sysref PIO register to 0 (but leave other PIO registers untouched)
}

void jesd204b_controller::Sysref_enable_on(void)
{

#if DEBUG_JESD204B_CONTROLLER
   xprintf("DEBUG: enable sysref...\n");
#endif
   this->IOWR_PIO_CONTROL_REG(IORD_PIO_CONTROL_REG() | ALTERA_PIO_CONTROL_SYSREF_MASK); //Force sysref PIO register to 1 (but leave other PIO registers untouched)

}

void  jesd204b_controller::Sync_assert(void) {
#if DEBUG_JESD204B_CONTROLLER
   xprintf("DEBUG: asserting sync_n...\n");
#endif
   this->IOWR_PIO_CONTROL_REG(IORD_PIO_CONTROL_REG() | ALTERA_PIO_CONTROL_SYNC_N_ASSERT_MASK); //Force sysref PIO register to 1 (but leave other PIO registers untouched)

}

void  jesd204b_controller::Sync_deassert(void) {
#if DEBUG_JESD204B_CONTROLLER
   xprintf("DEBUG: deasserting sync_n...\n");
#endif
   this->IOWR_PIO_CONTROL_REG(IORD_PIO_CONTROL_REG() & ~ALTERA_PIO_CONTROL_SYNC_N_ASSERT_MASK); //Force sysref PIO register to 0 (but leave other PIO registers untouched)
}

int jesd204b_controller::ResetSeq (int link, int *held)
{
#if DEBUG_JESD204B_CONTROLLER
   xprintf("DEBUG: Held resets for link %d at beginning of ResetSeq: 0x0%x\n", link, held[link]);
#endif

   //Wait until reset sequencer RESET_ACTIVE signal de-asserts before proceeding
   while (IORD_RESET_SEQUENCER_RESET_ACTIVE(link) == 1) {
		#if DEBUG_JESD204B_CONTROLLER
		   xprintf("DEBUG reset stage 1: Held reset sequencer link status is: 0x%x\n", this->IORD_RESET_SEQUENCER_STATUS_REG(link));
		   usleep(2000000);
		#endif
   }

   //Clear any previous reset overwrite trigger enable settings
   IOWR_RESET_SEQUENCER_FORCE_RESET(link, 0x0);

   //Wait until reset sequencer RESET_ACTIVE signal de-asserts before proceeding
   while (IORD_RESET_SEQUENCER_RESET_ACTIVE(link) == 1){
		#if DEBUG_JESD204B_CONTROLLER
		   xprintf("DEBUG reset stage 2: Held reset sequencer link status is: 0x%x\n", this->IORD_RESET_SEQUENCER_STATUS_REG(link));
		   usleep(2000000);
		#endif
		}

   held[link] = 0x0; //Clear all held reset flags

   IOWR_RESET_SEQUENCER_INIT_RESET_SEQ(link);

#if DEBUG_JESD204B_CONTROLLER
   xprintf("DEBUG: Held resets for link %d at end of ResetSeq: 0x0%x\n", link, held[link]);
#endif

   return 0;
}

int jesd204b_controller::ResetForce (int link, int reset_val, int hr, int *held)
{
   int val = 0x0;
   int j = 0;

#if DEBUG_JESD204B_CONTROLLER
   xprintf("DEBUG: Held resets for link %d at beginning of ResetForce: 0x0%x\n", link, held[link]);
#endif

   if (hr == 0) //If pulse resets detected, set to reset assertion case first
      j = 2;
   else
      j = hr;

   switch (j)
   {
      case 2: //Force assert resets
      {
#if DEBUG_JESD204B_CONTROLLER
         xprintf ("DEBUG: Executing forced reset assertion on link %d...\n", link);
#endif
         //Set Reset Overwrite Trigger Enable register values
         val = ((held[link] | reset_val) << 16);
         //Set Reset Overwrite register values
         val |= (held[link] | reset_val);
#if DEBUG_JESD204B_CONTROLLER
         xprintf ("DEBUG: Reset val: 0x0%x\n", val);
#endif

         //Wait until reset sequencer RESET_ACTIVE signal de-asserts before proceeding
         while (IORD_RESET_SEQUENCER_RESET_ACTIVE(link) == 1);

         IOWR_RESET_SEQUENCER_FORCE_RESET(link, val);

         if (hr == 2) //If hold resets detected
         {
            //Update held resets info
            held[link] |= reset_val;
#if DEBUG_JESD204B_CONTROLLER
            xprintf("DEBUG: Held resets for link %d after reset_val update: 0x0%x\n", link, held[link]);
#endif
            return 0;
         }
         //else, pulse resets detected. Fall through to next statement
      }

      case 1:
      {
#if DEBUG_JESD204B_CONTROLLER
         xprintf ("DEBUG: Executing forced reset de-assertion on link %d...\n", link);
#endif
         //Set Reset Overwrite Trigger Enable register values
         val = ((held[link] | reset_val) << 16);
         //Set Reset Overwrite register values
         val |= (held[link] & (~reset_val));
#if DEBUG_JESD204B_CONTROLLER
         xprintf ("DEBUG: Reset val: 0x0%x\n", val);
#endif

         //Wait until reset sequencer RESET_ACTIVE signal de-asserts before proceeding
         while (IORD_RESET_SEQUENCER_RESET_ACTIVE(link) == 1);

         IOWR_RESET_SEQUENCER_FORCE_RESET(link, val);

         //Clear Reset Overwrite Trigger Enables that were released (but not held resets)
         val = ((held[link] & (~reset_val)) << 16);
         //Set Reset Overwrite register values
         val |= (held[link] & (~reset_val));
#if DEBUG_JESD204B_CONTROLLER
         xprintf ("DEBUG: Reset val: 0x0%x\n", val);
#endif

         //Wait until reset sequencer RESET_ACTIVE signal de-asserts before proceeding
         while (IORD_RESET_SEQUENCER_RESET_ACTIVE(link) == 1);

         IOWR_RESET_SEQUENCER_FORCE_RESET(link, val);

         //Update held resets info
         held[link] &= ~reset_val;
#if DEBUG_JESD204B_CONTROLLER
         xprintf("DEBUG: Held resets for link %d after reset_val update: 0x0%x\n", link, held[link]);
#endif
         return 0;
      }

      default:
      {
         xprintf ("ERROR: Unrecognized hold/release setting\n");
         return 1;
      }
   }

   return 0;
}

int jesd204b_controller::Reset_X_L_F_Release (int link, int *held_resets)
{
   alt_u32 xcvr_ready_mask   = 0x0;
   alt_u32 xcvr_ready_assert = 0x0;

   //Relese XCVR reset after writing to JESD CSR
   if (ResetForce(link, XCVR_RESET_MASK, RELEASE_RESET_MASK, held_resets) != 0)
      return 1;

   xcvr_ready_mask = ALTERA_PIO_STATUS_ALL_TX_READY_0_MASK << (3*link);
   xcvr_ready_assert = ALTERA_PIO_STATUS_ALL_TX_READY_0_ASSERT << (3*link);

#if DEBUG_JESD204B_CONTROLLER
   xprintf("DEBUG: TX xcvr_ready_mask for link %d: 0x%x\n", link, (unsigned int) xcvr_ready_mask);
   xprintf("DEBUG: TX xcvr_ready_assert for link %d: 0x%x\n", link, (unsigned int) xcvr_ready_assert);
#endif
   /*
   //Wait for XCVR TX ready signal before proceeding to release tx_link and tx_frame resets
#if DEBUG_JESD204B_CONTROLLER
   xprintf("DEBUG: Checking XCVR TX ready...\n");
#endif
   while((IORD_PIO_STATUS_REG() & xcvr_ready_mask) != xcvr_ready_assert)
      ; //wait, do nothing
*/
   //Release tx_link and tx_frame resets once XCVR tx_ready signal asserted
   if (ResetForce(link, TX_LINK_FRAME_RESET_MASK, RELEASE_RESET_MASK, held_resets) != 0)
      return 1;

   xcvr_ready_mask = ALTERA_PIO_STATUS_ALL_RX_READY_0_MASK << (3*link);
   xcvr_ready_assert = ALTERA_PIO_STATUS_ALL_RX_READY_0_ASSERT << (3*link);

#if DEBUG_JESD204B_CONTROLLER
   xprintf("DEBUG: RX xcvr_ready_mask for link %d: 0x%x\n", link, (unsigned int) xcvr_ready_mask);
   xprintf("DEBUG: RX xcvr_ready_assert for link %d: 0x%x\n", link, (unsigned int) xcvr_ready_assert);
#endif

   //Wait for XCVR RX ready signal before proceeding to release rx_link and rx_frame resets
#if DEBUG_JESD204B_CONTROLLER
   xprintf("DEBUG: Checking XCVR RX ready...\n");
#endif
   while((IORD_PIO_STATUS_REG() & xcvr_ready_mask) != xcvr_ready_assert)
      ; //wait, do nothing

   //Release rx_link and rx_frame resets once XCVR rx_ready signal asserted
   if (ResetForce(link, RX_LINK_FRAME_RESET_MASK, RELEASE_RESET_MASK, held_resets) != 0)
      return 1;

   return 0;
}


// JESD RX Core ISR
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
static void ISR_JESD_RX (void * context)
#else
static void ISR_JESD_RX (void * context, alt_u32 id)
#endif
{
   // Variable to store the error type register
   volatile unsigned int error_type;
   int link = 0;
   jesd204b_controller* jesd204b_controller_ptr;
   jesd204b_controller_ptr =  (jesd204b_controller *) context;

   //link = (int) context;

#if DEBUG_MODE
   xprintf("DEBUG: Link indicated for ISR_JESD_RX: %d\n", link);
#endif

   // Read Rx Error 0 status register
   error_type = jesd204b_controller_ptr->get_jesd_rx_uarts_vector()->at(link)->IORD_JESD204_RX_ERR0_REG();

if (PRINT_INTERRUPT_MESSAGES) {
   if ((error_type & ALTERA_JESD204_RX_ERR_STATUS_0_REG_SYSREF_LMFC_MASK) == ALTERA_JESD204_RX_ERR_STATUS_0_REG_SYSREF_LMFC_ERROR)
   {
      xprintf("Rx Error 0: Sysref LMFC error happened\n");
   }
   if ((error_type & ALTERA_JESD204_RX_ERR_STATUS_0_REG_DLL_DATA_RDY_MASK) == ALTERA_JESD204_RX_ERR_STATUS_0_REG_DLL_DATA_RDY_ERROR)
   {
      xprintf("Rx Error 0: DLL Data Ready error happened\n");
   }
   if ((error_type & ALTERA_JESD204_RX_ERR_STATUS_0_REG_FRAME_DATA_RDY_MASK) == ALTERA_JESD204_RX_ERR_STATUS_0_REG_FRAME_DATA_RDY_ERROR)
   {
      xprintf("Rx Error 0: Transport Data Ready error happened\n");
   }
   if ((error_type & ALTERA_JESD204_RX_ERR_STATUS_0_REG_LANE_ALIGN_MASK) == ALTERA_JESD204_RX_ERR_STATUS_0_REG_LANE_ALIGN_ERROR)
   {
      xprintf("Rx Error 0: Lane Align error happened\n");
   }
   if ((error_type & ALTERA_JESD204_RX_ERR_STATUS_0_REG_RX_LOCKED_TO_DATA_MASK) == ALTERA_JESD204_RX_ERR_STATUS_0_REG_RX_LOCKED_TO_DATA_ERROR)
   {
      xprintf("Rx Error 0: RX locked to data error happened\n");
   }
   if ((error_type & ALTERA_JESD204_RX_ERR_STATUS_0_REG_PCFIFO_FULL_MASK) == ALTERA_JESD204_RX_ERR_STATUS_0_REG_PCFIFO_FULL_ERROR)
   {
      xprintf("Rx Error 0: PCFIFO full error happened\n");
   }
   if ((error_type & ALTERA_JESD204_RX_ERR_STATUS_0_REG_PCFIFO_EMPTY_MASK) == ALTERA_JESD204_RX_ERR_STATUS_0_REG_PCFIFO_EMPTY_ERROR)
   {
      xprintf("Rx Error 0: PCFIFO empty error happened\n");
   }
}

   // Write 1 to clear all the valid and active status in Rx Error status 0 register
jesd204b_controller_ptr->get_jesd_rx_uarts_vector()->at(link)->IOWR_JESD204_RX_ERR0_REG(ALTERA_JESD204_RX_ERR_STATUS_0_CLEAR_ERROR_MASK);

#if DEBUG_JESD204B_CONTROLLER
   if (jesd204b_controller_ptr->get_jesd_rx_uarts_vector()->at(link)->IORD_JESD204_RX_ERR0_REG() != 0x0)
   {
      xprintf("Rx Error 0: Error and interrupt not cleared!!!\n");
   }
   else
   {
      xprintf("Rx Error 0: Error and interrupt all cleared!!!\n");
   }
#endif

   // Read Rx Error 1 status register
   error_type = jesd204b_controller_ptr->get_jesd_rx_uarts_vector()->at(link)->IORD_JESD204_RX_ERR1_REG();

if (PRINT_INTERRUPT_MESSAGES) {
   if ((error_type & ALTERA_JESD204_RX_ERR_STATUS_1_CGS_MASK) == ALTERA_JESD204_RX_ERR_STATUS_1_CGS_ERROR)
   {
      xprintf("Rx Error 1: CGS error happened\n");
   }
   if ((error_type & ALTERA_JESD204_RX_ERR_STATUS_1_FRAME_ALIGNMENT_MASK) == ALTERA_JESD204_RX_ERR_STATUS_1_FRAME_ALIGNMENT_ERROR)
   {
      xprintf("Rx Error 1: Frame Alignment error happened\n");
   }
   if ((error_type & ALTERA_JESD204_RX_ERR_STATUS_1_LANE_ALIGNMENT_MASK) == ALTERA_JESD204_RX_ERR_STATUS_1_LANE_ALIGNMENT_ERROR)
   {
      xprintf("Rx Error 1: Lane Alignment error happened\n");
   }
   if ((error_type & ALTERA_JESD204_RX_ERR_STATUS_1_UNEXP_K_CHAR_MASK) == ALTERA_JESD204_RX_ERR_STATUS_1_UNEXP_K_CHAR_ERROR)
   {
      xprintf("Rx Error 1: Unexpected K Char error happened\n");
   }
   if ((error_type & ALTERA_JESD204_RX_ERR_STATUS_1_NOT_IN_TABLE_MASK) == ALTERA_JESD204_RX_ERR_STATUS_1_NOT_IN_TABLE_ERROR)
   {
      xprintf("Rx Error 1: Not In Table error happened\n");
   }
   if ((error_type & ALTERA_JESD204_RX_ERR_STATUS_1_DISPARITY_MASK) == ALTERA_JESD204_RX_ERR_STATUS_1_DISPARITY_ERROR)
   {
      xprintf("Rx Error 1: Disparity error happened\n");
   }
   if ((error_type & ALTERA_JESD204_RX_ERR_STATUS_1_ILAS_MASK) == ALTERA_JESD204_RX_ERR_STATUS_1_ILAS_ERROR)
   {
      xprintf("Rx Error 1: ILAS error happened\n");
   }
   if ((error_type & ALTERA_JESD204_RX_ERR_STATUS_1_DLL_RSVD_MASK) == ALTERA_JESD204_RX_ERR_STATUS_1_DLL_RSVD_ERROR)
   {
      xprintf("Rx Error 1: DLL Rsvd error happened\n");
   }
   if ((error_type & ALTERA_JESD204_RX_ERR_STATUS_1_ECC_CORRECTED_MASK) == ALTERA_JESD204_RX_ERR_STATUS_1_ECC_CORRECTED_ERROR)
   {
      xprintf("Rx Error 1: ECC Corrected error happened\n");
   }
   if ((error_type & ALTERA_JESD204_RX_ERR_STATUS_1_ECC_FATAL_MASK) == ALTERA_JESD204_RX_ERR_STATUS_1_ECC_FATAL_ERROR)
   {
      xprintf("Rx Error 1: ECC Fatal error happened\n");
   }
}

   // Write 1 to clear all the valid and active status in Rx Error status 1 register
   jesd204b_controller_ptr->get_jesd_rx_uarts_vector()->at(link)->IOWR_JESD204_RX_ERR1_REG(ALTERA_JESD204_RX_ERR_STATUS_1_CLEAR_ERROR_MASK);

#if DEBUG_JESD204B_CONTROLLER
   if (jesd204b_controller_ptr->get_jesd_rx_uarts_vector()->at(link)->IORD_JESD204_RX_ERR1_REG() != 0x0)
   {
      xprintf("Rx Error 1: Error and interrupt not cleared!!!\n");
   }
   else
   {
      xprintf("Rx Error 1: Error and interrupt all cleared!!!\n");
   }
#endif

}

void jesd204b_controller::link_reinit(int link) {
#if DEBUG_JESD204B_CONTROLLER
   xprintf("DEBUG: Reinitializing link %d...\n",link);
#endif
  this->get_jesd_rx_uarts_vector()->at(link)->reinit_link();
}


void jesd204b_controller::reinit_all_links() {
#if DEBUG_JESD204B_CONTROLLER
   xprintf("DEBUG: Reinitializing all links...\n");
#endif
   for (int i = 0; i < this->get_jesd_rx_uarts_vector()->size(); i++ ){
	   link_reinit(i);
   }
}
void jesd204b_controller::InitISR (jesd204b_controller* jesd204b_controller_ptr)
{
   //int link = 1;
   //int base_irq_priority = JESD204B_IP_INST_JESD204B_SUBSYSTEM_0_JESD204B_JESD204_TX_AVS_IRQ;

#if DEBUG_JESD204B_CONTROLLER
   xprintf("DEBUG: Start of InitISR function...\n");
#endif

   // Register interrupt handler
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
//   for (link = 0; link < MAX_LINKS; link++)
//   {
      alt_ic_isr_register (JESD204B_IP_INST_JESD204B_SUBSYSTEM_0_JESD204B_JESD204_TX_AVS_IRQ_INTERRUPT_CONTROLLER_ID,
                           //(base_irq_priority*link),
                           JESD204B_IP_INST_JESD204B_SUBSYSTEM_0_JESD204B_JESD204_TX_AVS_IRQ,
                           ISR_JESD_TX,
                           //(void *)link,
                           NULL,
                           0x0);

      alt_ic_isr_register (JESD204B_IP_INST_JESD204B_SUBSYSTEM_0_JESD204B_JESD204_RX_AVS_IRQ_INTERRUPT_CONTROLLER_ID,
                           //((base_irq_priority*link) + 1),
                           JESD204B_IP_INST_JESD204B_SUBSYSTEM_0_JESD204B_JESD204_RX_AVS_IRQ,
                           ISR_JESD_RX,
                           //(void *)link,
                           NULL,
                           0x0);
//   }

   alt_ic_isr_register (JESD204B_IP_INST_JESD_204B_SPI_IRQ_INTERRUPT_CONTROLLER_ID,
		                JESD204B_IP_INST_JESD_204B_SPI_IRQ,
                        ISR_SPI,
                        NULL,
                        0x0);

#else
//   for (link = 0; link < MAX_LINKS; link++)
//   {
      /*alt_irq_register (//(base_irq_priority*link),
                        JESD204B_IP_INST_JESD204B_SUBSYSTEM_0_JESD204B_JESD204_TX_AVS_IRQ,
                        //(void *)link,
                        NULL,
                        ISR_JESD_TX); */

      alt_irq_register (//((base_irq_priority*link) + 1),
                        JESD204B_IP_INST_JESD204B_SUBSYSTEM_0_JESD204B_JESD204_RX_AVS_IRQ,
                        //(void *)link,
                        (void *) jesd204b_controller_ptr,
                        ISR_JESD_RX);
//   }

/*   alt_irq_register (SPI_0_IRQ,
                     NULL,
                     ISR_SPI);*/
#endif

   // Disable timer and jtag uart interrupt generation.
   // Will let user to customize timer usage and it's corresponding ISR (eg: watchdog timer)
   //IOWR_ALTERA_AVALON_TIMER_CONTROL(NIOS_SUBSYSTEM_TIMER_BASE, 0);
   //IOWR_ALTERA_AVALON_JTAG_UART_CONTROL(NIOS_SUBSYSTEM_JTAG_UART_BASE, 0x0);

#if DEBUG_JESD204B_CONTROLLER
   xprintf("DEBUG: End of InitISR function...\n");
#endif

   return;
}


} /* namespace jesd204b_ctrl */
