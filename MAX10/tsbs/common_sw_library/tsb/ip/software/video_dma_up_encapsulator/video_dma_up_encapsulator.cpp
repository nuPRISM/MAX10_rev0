/*
 * video_dma_up_encapsulator.cpp
 *
 *  Created on: Nov 7, 2015
 *      Author: user
 */
#include "system.h"
#include "basedef.h"
#include <stdio.h>
#include <stdlib.h> // malloc, free
#include <string.h>
#include <stddef.h>
#include <unistd.h>  // usleep (unix standard?)
//#include "sys/alt_flash.h"
//#include "sys/alt_flash_types.h"
#include "io.h"
#include "alt_types.h"  // alt_u32
#include "altera_avalon_pio_regs.h" //IOWR_ALTERA_AVALON_PIO_DATA
#include "sys/alt_irq.h"  // interrupt
#include "sys/alt_alarm.h" // time tick function (alt_nticks(), alt_ticks_per_second())
#include "sys/alt_timestamp.h"
#include "sys/alt_stdio.h"
#include "video_dma_up_encapsulator.h"
#include "debug_macro_definitions.h"

#ifndef DEBUG_UP_FRAME_BUFFER
#define DEBUG_UP_FRAME_BUFFER (1)
#endif

#define d_fb(x) do { if (DEBUG_UP_FRAME_BUFFER) { printf("%s: ",this->get_name().c_str()); x; } } while(0)

namespace vdma {
video_dma_up_encapsulator::~video_dma_up_encapsulator() {
	// TODO Auto-generated destructor stub
}

void video_dma_up_encapsulator::set_back_buffer_address(unsigned long addr) {
    this->write(VIDEO_DMA_BACKBUFFER_REG,addr);
}

void video_dma_up_encapsulator::set_direct_buffer_address(unsigned long addr) {
    this->write(VIDEO_DMA_DIRECT_BUFFER_ADDRESS,addr);
}

void video_dma_up_encapsulator::set_use_direct_buffer_adddress(bool yes) {
	if (yes) {
        this->turn_on_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,SET_BUFFER_ADDRESS_DIRECTLY_BIT_LOCATION);
	} else {
        this->turn_off_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,SET_BUFFER_ADDRESS_DIRECTLY_BIT_LOCATION);
	}
}

bool video_dma_up_encapsulator::get_use_direct_buffer_adddress() {
    return (this->get_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,SET_BUFFER_ADDRESS_DIRECTLY_BIT_LOCATION) ? true : false);
}

void video_dma_up_encapsulator::set_up_for_swap() {
    this->write(VIDEO_DMA_BUFFER_REG,0); //data is irrelevant
}

unsigned long video_dma_up_encapsulator::get_back_buffer_address() {
    return this->read(VIDEO_DMA_BACKBUFFER_REG);
}
unsigned long video_dma_up_encapsulator::get_fsm_state() {
    return this->read(VIDEO_DMA_FSM_STATE);
}
unsigned long video_dma_up_encapsulator::get_current_buffer_address() {
    return this->read(VIDEO_DMA_BUFFER_REG);
}
unsigned long video_dma_up_encapsulator::get_status() {
    return this->read(VIDEO_DMA_CONTROL_AND_STATUS_REG);
}

void video_dma_up_encapsulator::write_control(unsigned long data) {
    this->write(VIDEO_DMA_CONTROL_AND_STATUS_REG,data);
}

unsigned long video_dma_up_encapsulator::get_resolution() {
    return this->read(VIDEO_DMA_RESOLUTION_REG);
}

VIDEO_SWAP_STATUS_TYPE video_dma_up_encapsulator::get_swap_status() {
    return (this->get_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,SWAP_BIT_LOCATION) ? VIDEO_DMA_SWAP_IS_IN_PROGRESS : VIDEO_DMA_SWAP_IS_DONE);
}

VIDEO_ENABLE_STATUS_TYPE video_dma_up_encapsulator::get_enable_status() {
    return (this->get_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,ENABLED_BIT_LOCATION) ? VIDEO_DMA_IS_ENABLED : VIDEO_DMA_IS_DISABLED);
}
VIDEO_SOFT_RESET_TYPE video_dma_up_encapsulator::get_soft_reset_status() {
    return (this->get_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,SOFT_RESET_BIT_LOCATION) ? VIDEO_DMA_ASSERT_SOFT_RESET : VIDEO_DMA_DEASSERT_SOFT_RESET);
}

unsigned long video_dma_up_encapsulator::is_currently_processing_frame() {
    return (this->get_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,CURRENTLY_PROCESSING_FRAME_BIT_LOCATION));
}

unsigned long video_dma_up_encapsulator::soft_reset_request_is_pending() {
    return (this->get_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,RESET_REQUEST_PENDING_BIT_LOCATION));
}
VIDEO_BUFFER_ADDR_CTRL_STATUS_TYPE video_dma_up_encapsulator::get_buf_addr_ctrl_status() {
    return (this->get_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,SWAP_BIT_LOCATION) ? VIDEO_DMA_IS_EXTERNALLY_CONTROLLED : VIDEO_DMA_IS_INTERNALLY_CONTROLLED);
}

void video_dma_up_encapsulator::set_enable(VIDEO_ENABLE_STATUS_TYPE e) {
	if (e == VIDEO_DMA_IS_ENABLED) {
        this->turn_on_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,ENABLED_BIT_LOCATION);
	} else  {
		this->turn_off_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,ENABLED_BIT_LOCATION);
	}
}

void video_dma_up_encapsulator::set_soft_reset(VIDEO_SOFT_RESET_TYPE e) {
	if (e == VIDEO_DMA_ASSERT_SOFT_RESET) {
        this->turn_on_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,SOFT_RESET_BIT_LOCATION);
	} else  {
		this->turn_off_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,SOFT_RESET_BIT_LOCATION);
	}
}

void  video_dma_up_encapsulator::set_auto_swap(VIDEO_BUFFER_AUTO_SWAP_STATUS_TYPE e){
	if (e == VIDEO_DMA_AUTO_SWAP_ENABLED) {
        this->turn_on_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,AUTO_SWAP_CTRL_BIT_LOCATION);
	} else  {
		this->turn_off_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,AUTO_SWAP_CTRL_BIT_LOCATION);
	}
}
VIDEO_BUFFER_AUTO_SWAP_STATUS_TYPE  video_dma_up_encapsulator::get_auto_swap() {
	return (this->get_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,AUTO_SWAP_CTRL_BIT_LOCATION) ? VIDEO_DMA_AUTO_SWAP_ENABLED : VIDEO_DMA_AUTO_SWAP_DISABLED);
}

void video_dma_up_encapsulator::set_buf_addr_ctrl_status(VIDEO_BUFFER_ADDR_CTRL_STATUS_TYPE e) {
	if (e == VIDEO_DMA_IS_EXTERNALLY_CONTROLLED) {
        this->turn_on_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,USE_EXTERNAL_BUFFER_CTRL_BIT_LOCATION);
	} else  {
		this->turn_off_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,USE_EXTERNAL_BUFFER_CTRL_BIT_LOCATION);
	}
}

VIDEO_NEXT_BUFFER_ADDR_STATUS_TYPE video_dma_up_encapsulator::check_status_and_set_next_buffer_address(unsigned long next_buffer_addr) {
    if (this->get_swap_status() == VIDEO_DMA_SWAP_IS_DONE) {
        this->set_back_buffer_address(next_buffer_addr);
        this->set_up_for_swap();
        d_fb(printf("Swap Req. to Addr 0x%x\n",next_buffer_addr));
        return VIDEO_DMA_NEXT_BUFFER_ADDR_SET;
    } else {
    	//waiting for swap, buffer not changed
    	return VIDEO_DMA_NEXT_BUFFER_ADDR_NOT_SET;
    }
}

unsigned long video_dma_up_encapsulator::set_num_out_of_pixels_per_frame(unsigned long num_of_pixels) {
	 this->write(VIDEO_DMA_NUM_PIXELS_IN_FRAME_REG,num_of_pixels);
}

VIDEO_NEXT_BUFFER_ADDR_STATUS_TYPE video_dma_up_encapsulator::set_and_possibly_overwrite_next_buffer_address(unsigned long next_buffer_addr) {
  this->set_back_buffer_address(next_buffer_addr);
  this->set_up_for_swap();
  //d_fb(printf("Force Swap Req. to Addr 0x%x\n",next_buffer_addr));
  if (this->get_swap_status() == VIDEO_DMA_SWAP_IS_DONE) {
	  return VIDEO_DMA_NEXT_BUFFER_ADDR_SET;
  } else{
	  return VIDEO_DMA_NEXT_BUFFER_ADDR_NOT_SET;
  }

}


void video_dma_up_encapsulator::do_soft_reset() {
	this->set_soft_reset(VIDEO_DMA_ASSERT_SOFT_RESET);
	int i = 1;
	int status_counter= 0;
	/*do {

	} while (1);*/

    do {
	    if (i%100000 == 0) {
	    	 status_counter++;
	         printf("Status %u: %s waiting for reset, status = %x\n",status_counter,this->get_name().c_str(),read(VIDEO_DMA_CONTROL_AND_STATUS_REG));
	       }
        i++;
	  } while (soft_reset_request_is_pending());

	//usleep(100000);
	 printf("%s reset confirmed\n",this->get_name().c_str());
	this->set_soft_reset(VIDEO_DMA_DEASSERT_SOFT_RESET);
}

void video_dma_up_encapsulator::set_watchdog_enable(bool enable) {
	if (enable) {
        this->turn_on_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,WATCHDOG_ENABLED_BIT_LOCATION);
	} else  {
		this->turn_off_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,WATCHDOG_ENABLED_BIT_LOCATION);
	}
}



void video_dma_up_encapsulator::set_avmm_swap_buffer_now               (bool val) {
	       val ? this->turn_on_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,AVMM_SWAP_BUFFER_NOW_BIT_LOCATION           ) :
	    		 this->turn_off_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,AVMM_SWAP_BUFFER_NOW_BIT_LOCATION           );
}
void video_dma_up_encapsulator::set_override_swap_buffer_now           (bool val) {
	val ? this->turn_on_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,OVERRIDE_SWAP_BUFFER_NOW_BIT_LOCATION       ) :
			this->turn_off_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,OVERRIDE_SWAP_BUFFER_NOW_BIT_LOCATION       ) ;
}
void video_dma_up_encapsulator::set_avmm_pause_after_each_frame        (bool val) {
	val ? this->turn_on_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,AVMM_PAUSE_AFTER_EACH_FRAME_BIT_LOCATION    ) :
			this->turn_off_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,AVMM_PAUSE_AFTER_EACH_FRAME_BIT_LOCATION    );
}
void video_dma_up_encapsulator::set_override_pause_after_each_frame    (bool val) {
	val ? this->turn_on_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,OVERRIDE_PAUSE_AFTER_EACH_FRAME_BIT_LOCATION) :
		this->turn_off_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,OVERRIDE_PAUSE_AFTER_EACH_FRAME_BIT_LOCATION);
}

unsigned long video_dma_up_encapsulator::get_actual_swap_buffer_now            (){ return this->get_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,ACTUAL_SWAP_BUFFER_NOW_BIT_LOCATION         );};
unsigned long video_dma_up_encapsulator::get_override_swap_buffer_now          (){ return this->get_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,OVERRIDE_SWAP_BUFFER_NOW_BIT_LOCATION       );};
unsigned long video_dma_up_encapsulator::get_actual_pause_after_each_frame     (){ return this->get_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,ACTUAL_PAUSE_AFTER_EACH_FRAME_BIT_LOCATION  );};
unsigned long video_dma_up_encapsulator::get_override_pause_after_each_frame   (){ return this->get_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,OVERRIDE_PAUSE_AFTER_EACH_FRAME_BIT_LOCATION);};


void video_dma_up_encapsulator::set_watchdog_limit(unsigned long long limit) {
    this->write(VIDEO_DMA_WATCHDOG_LIMIT_REG,limit & 0xFFFFFFFF);
    this->write(VIDEO_DMA_WATCHDOG_UPPER_BITS_LIMIT_REG,((limit & 0xFFFFFFFF00000000ULL) >> 32));
}

bool video_dma_up_encapsulator::get_watchdog_enable_status() {
    return (this->get_bit(VIDEO_DMA_CONTROL_AND_STATUS_REG,WATCHDOG_ENABLED_BIT_LOCATION) ? true : false);
}


unsigned long long video_dma_up_encapsulator::get_watchdog_limit() {
    unsigned long long lower_32_bits  = this->read(VIDEO_DMA_WATCHDOG_LIMIT_REG) & 0xFFFFFFFF;
    unsigned long long upper_32_bits  = this->read(VIDEO_DMA_WATCHDOG_UPPER_BITS_LIMIT_REG) & 0xFFFFFFFF;
    unsigned long long total_watchdog_limit  = (upper_32_bits << 32)  + lower_32_bits;
    return total_watchdog_limit;
}



}
