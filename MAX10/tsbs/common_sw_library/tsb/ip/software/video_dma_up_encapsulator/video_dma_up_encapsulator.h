/*
 * video_dma_up_encapsulator.h
 *
 *  Created on: Nov 7, 2015
 *      Author: user
 */

#ifndef VIDEO_DMA_UP_ENCAPSULATOR_H_
#define VIDEO_DMA_UP_ENCAPSULATOR_H_

#include "generic_driver_encapsulator.h"
#include <string>
namespace vdma {

    const unsigned int SWAP_BIT_LOCATION = 0;
    const unsigned int SOFT_RESET_BIT_LOCATION = 1;
    const unsigned int ENABLED_BIT_LOCATION = 2;
    const unsigned int USE_EXTERNAL_BUFFER_CTRL_BIT_LOCATION = 3;
    const unsigned int AUTO_SWAP_CTRL_BIT_LOCATION = 4;
    const unsigned int CURRENTLY_PROCESSING_FRAME_BIT_LOCATION = 5;
    const unsigned int RESET_REQUEST_PENDING_BIT_LOCATION = 6;
    const unsigned int WATCHDOG_ENABLED_BIT_LOCATION = 10;
    const unsigned int SET_BUFFER_ADDRESS_DIRECTLY_BIT_LOCATION = 7;
    const unsigned int AVMM_SWAP_BUFFER_NOW_BIT_LOCATION            = 14;
    const unsigned int OVERRIDE_SWAP_BUFFER_NOW_BIT_LOCATION        = 13;
    const unsigned int AVMM_PAUSE_AFTER_EACH_FRAME_BIT_LOCATION     = 12;
    const unsigned int OVERRIDE_PAUSE_AFTER_EACH_FRAME_BIT_LOCATION = 11;
    const unsigned int ACTUAL_SWAP_BUFFER_NOW_BIT_LOCATION          = 14;
    const unsigned int ACTUAL_PAUSE_AFTER_EACH_FRAME_BIT_LOCATION   = 12;







    const unsigned int DMA_ADDRESS_SPACE_SPAN_IN_BYTES = 16;
	typedef enum  {
		VIDEO_DMA_BUFFER_REG = 0,
		VIDEO_DMA_BACKBUFFER_REG = 1,
		VIDEO_DMA_RESOLUTION_REG = 2,
		VIDEO_DMA_CONTROL_AND_STATUS_REG = 3,
		VIDEO_DMA_NUM_PACKETS_PROCESSED_REG = 4,
		VIDEO_DMA_NUM_SWAPS_REG = 5,
		VIDEO_DMA_NUM_REPEATED_PACKETS = 6,
		VIDEO_DMA_LAST_BUF_ADDRESS_REG = 7,
		VIDEO_DMA_NUM_WATCHDOG_EVENTS_REG = 8,
		VIDEO_DMA_NUM_DISCARD_EVENTS_REG  = 9,
		VIDEO_DMA_NUM_OUT_OF_BAND_DATA_REG  = 10,
		VIDEO_DMA_NUM_PIXELS_IN_FRAME_REG  = 11,
		VIDEO_DMA_NUM_FINISHED_PACKETS_PROCESSED_REG  = 12,
		VIDEO_DMA_WATCHDOG_LIMIT_REG  = 13,
		VIDEO_DMA_WATCHDOG_UPPER_BITS_LIMIT_REG  = 14,
		VIDEO_DMA_DIRECT_BUFFER_ADDRESS  = 15,
		VIDEO_DMA_BITS_PER_PIXEL = 16,
		VIDEO_DMA_PARALLELIZATION_RATIO = 17,
		VIDEO_DMA_SWAP_SYMBOL_CONTROL = 18,
		VIDEO_DMA_FSM_STATE = 19
	} VIDEO_DMA_REGISTER_TYPE;
	typedef enum  {
			VIDEO_DMA_SWAP_IS_DONE = 0,
			VIDEO_DMA_SWAP_IS_IN_PROGRESS = 1
		} VIDEO_SWAP_STATUS_TYPE;
	typedef enum  {
				VIDEO_DMA_NEXT_BUFFER_ADDR_SET = 0,
				VIDEO_DMA_NEXT_BUFFER_ADDR_NOT_SET = 1
			} VIDEO_NEXT_BUFFER_ADDR_STATUS_TYPE;
	typedef enum  {
			VIDEO_DMA_IS_DISABLED = 0,
			VIDEO_DMA_IS_ENABLED = 1
		} VIDEO_ENABLE_STATUS_TYPE;
		typedef enum  {
					VIDEO_DMA_DEASSERT_SOFT_RESET = 0,
					VIDEO_DMA_ASSERT_SOFT_RESET = 1
				} VIDEO_SOFT_RESET_TYPE;

		typedef enum  {
			VIDEO_DMA_IS_INTERNALLY_CONTROLLED = 0,
			VIDEO_DMA_IS_EXTERNALLY_CONTROLLED = 1
			} VIDEO_BUFFER_ADDR_CTRL_STATUS_TYPE;

			typedef enum  {
						VIDEO_DMA_AUTO_SWAP_DISABLED = 0,
						VIDEO_DMA_AUTO_SWAP_ENABLED = 1
						} VIDEO_BUFFER_AUTO_SWAP_STATUS_TYPE;
	class video_dma_up_encapsulator : public generic_driver_encapsulator {

	protected:
			   std::string name;
	public:
		video_dma_up_encapsulator(unsigned long the_base_address, std::string the_name = "undefined") :
				generic_driver_encapsulator(the_base_address,
						DMA_ADDRESS_SPACE_SPAN_IN_BYTES) {
			this->set_name(the_name);
		};
		video_dma_up_encapsulator() : generic_driver_encapsulator() { };
		virtual void set_up_for_swap();
		virtual void set_back_buffer_address(unsigned long addr);
		virtual unsigned long get_back_buffer_address();
		virtual unsigned long get_current_buffer_address();
		virtual VIDEO_NEXT_BUFFER_ADDR_STATUS_TYPE check_status_and_set_next_buffer_address(unsigned long next_buffer_addr);
		virtual VIDEO_NEXT_BUFFER_ADDR_STATUS_TYPE set_and_possibly_overwrite_next_buffer_address(unsigned long next_buffer_addr);
		virtual VIDEO_BUFFER_ADDR_CTRL_STATUS_TYPE get_buf_addr_ctrl_status();
        virtual unsigned long get_status();
        virtual void write_control(unsigned long data);
        virtual unsigned long get_resolution();
        virtual VIDEO_SWAP_STATUS_TYPE get_swap_status();
        virtual VIDEO_ENABLE_STATUS_TYPE get_enable_status();
        virtual VIDEO_SOFT_RESET_TYPE get_soft_reset_status();
        virtual bool get_watchdog_enable_status();
        virtual unsigned long long get_watchdog_limit();
		virtual unsigned long get_fsm_state();

        virtual void set_buf_addr_ctrl_status(VIDEO_BUFFER_ADDR_CTRL_STATUS_TYPE e);
        virtual void set_auto_swap(VIDEO_BUFFER_AUTO_SWAP_STATUS_TYPE e);
        virtual VIDEO_BUFFER_AUTO_SWAP_STATUS_TYPE get_auto_swap();
        virtual unsigned long get_direct_buffer_address() { return this->read(VIDEO_DMA_DIRECT_BUFFER_ADDRESS); };
        virtual unsigned long get_num_packets_processed() { return this->read(VIDEO_DMA_NUM_PACKETS_PROCESSED_REG); };
        virtual unsigned long get_num_finished_packets_processed() { return this->read(VIDEO_DMA_NUM_FINISHED_PACKETS_PROCESSED_REG); };
        virtual unsigned long get_num_swaps() { return this->read(VIDEO_DMA_NUM_SWAPS_REG); };
        virtual unsigned long get_num_repeated_packets() { return  this->read(VIDEO_DMA_NUM_REPEATED_PACKETS); };
        virtual unsigned long get_last_buf_addr() { return this->read(VIDEO_DMA_LAST_BUF_ADDRESS_REG); };
        virtual unsigned long get_num_watchdog_events() { return this->read(VIDEO_DMA_NUM_WATCHDOG_EVENTS_REG); };
        virtual unsigned long get_num_discard_events() { return this->read(VIDEO_DMA_NUM_DISCARD_EVENTS_REG); };
        virtual unsigned long get_num_out_of_band_data() { return this->read(VIDEO_DMA_NUM_OUT_OF_BAND_DATA_REG); };
        virtual unsigned long get_num_out_of_pixels_per_frame(){ return this->read(VIDEO_DMA_NUM_PIXELS_IN_FRAME_REG);};
        virtual unsigned long set_num_out_of_pixels_per_frame(unsigned long num_of_pixels);
        virtual unsigned long is_currently_processing_frame();
        virtual unsigned long soft_reset_request_is_pending();
        virtual void set_avmm_swap_buffer_now               (bool val);
		virtual void set_override_swap_buffer_now           (bool val);
		virtual void set_avmm_pause_after_each_frame        (bool val);
		virtual void set_override_pause_after_each_frame    (bool val);
        virtual unsigned long get_actual_swap_buffer_now            ();
		virtual unsigned long get_override_swap_buffer_now          ();
		virtual unsigned long get_actual_pause_after_each_frame     ();
		virtual unsigned long get_override_pause_after_each_frame   ();





        virtual void do_soft_reset();
        virtual void set_enable(VIDEO_ENABLE_STATUS_TYPE e);
        virtual void set_soft_reset(VIDEO_SOFT_RESET_TYPE e);
        virtual void set_use_direct_buffer_adddress(bool yes);

        virtual void set_watchdog_enable(bool enable);
        virtual void set_watchdog_limit(unsigned long long limit);
        virtual void set_direct_buffer_address(unsigned long addr);
        virtual bool get_use_direct_buffer_adddress();
		virtual ~video_dma_up_encapsulator();

	const std::string& get_name() const {
		return name;
	}

	void set_name(const std::string& name) {
		this->name = name;
	}
};
}
#endif /* VIDEO_DMA_UP_ENCAPSULATOR_H_ */
