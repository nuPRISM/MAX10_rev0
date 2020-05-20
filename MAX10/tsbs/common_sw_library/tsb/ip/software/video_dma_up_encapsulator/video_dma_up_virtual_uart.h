/*
 * video_dma_up_virtual_uart.h
 *
 *  Created on: Feb 12, 2014
 *      Author: yairlinn
 */

#ifndef VIDEO_DMA_UP_VIRTUAL_UART_H_
#define VIDEO_DMA_UP_VIRTUAL_UART_H_
#include "video_dma_up_encapsulator.h"
#include "virtual_uart_register_file.h"

class video_dma_up_virtual_uart: public virtual_uart_register_file, public vdma::video_dma_up_encapsulator {
protected:
	int enable_phy_register_tunneling;
public:
	video_dma_up_virtual_uart(unsigned long the_base_address, std::string the_name = "undefined");
	virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
    virtual void write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);


};

#endif /* TSE_MAC_DEVICE_DRIVER_VIRTUAL_UART_H_ */
