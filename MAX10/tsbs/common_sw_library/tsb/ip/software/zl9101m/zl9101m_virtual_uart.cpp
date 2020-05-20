/*
 * zl9101m_virtual_uart.cpp
 *
 *  Created on: Sep 30, 2015
 *      Author: yairlinn
 */

#include "zl9101m_virtual_uart.h"




#include "basedef.h"
#include <sstream>
#include <iostream>
#include <string>
#include <stdio.h>
#include "linnux_utils.h"
#include "basedef.h"
#include "board_management.h"

#include <vector>
extern "C" {
#include <xprintf.h>
#include <altera_avalon_pio_regs.h>

}


zl9101m_virtual_uart::~zl9101m_virtual_uart() {
	// TODO Auto-generated destructor stub
}

#define u(x) do { if (UART_REG_DEBUG) {x;} } while (0)

#define dureg(x)  do { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n");); } while (0)
#define debureg(x)  do { if (UART_REG_DEBUG) { safe_print(xprintf("[%s][%s][%d]:\n",__FILE__,__func__,__LINE__););  x; safe_print(xprintf("\n"););} } while (0)

register_desc_map_type default_zl9101m_device_driver_ctrl_register_descriptions;
register_desc_map_type default_zl9101m_device_driver_status_register_descriptions;

zl9101m_virtual_uart::zl9101m_virtual_uart(unsigned int pmbusBase) : zl9101m_virtual_uart()  {
	this->set_pmbus_base(pmbusBase);

}

zl9101m_virtual_uart::zl9101m_virtual_uart() :
		virtual_uart_register_file()
        {
	/*
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x000 >>2] ="ADC_FIFO_FREEZE";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x004 >>2] ="ADC_FIFO_FREEZE_DELAY" ;
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x008 >>2] ="LEDS" ;
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x00C >>2] ="GLOBAL_TRIG_CONTROL" ;
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x010 >>2] ="SUPPRESSION_TIME_(0)";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x014 >>2] ="SUPPRESSION_TIME_(1)";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x018 >>2] ="SUPPRESSION_TIME_(2)";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x01C >>2] ="SUPPRESSION_TIME_(3)";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x020 >>2] ="SUPPRESSION_TIME_(4)";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x024 >>2] ="SUPPRESSION_TIME_(5)";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x028 >>2] ="SUPPRESSION_TIME_(6)";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x02C >>2] ="SUPPRESSION_TIME_(7)";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x030 >>2] ="PERIODIC_(0)_CTRL";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x034 >>2] ="PERIODIC_(0)_DIV";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x038 >>2] ="PERIODIC_(1)_CTRL";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x03C >>2] ="PERIODIC_(1)_DIV";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x040 >>2] ="EXPONENTIAL_(0)_CTRL";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x044 >>2] ="EXPONENTIAL_(0)_LAMBDA";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x048 >>2] ="EXPONENTIAL_(0)_SEED";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x04C >>2] ="EXPONENTIAL_(1)_CTRL";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x050 >>2] ="EXPONENTIAL_(1)_LAMBDA";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x054 >>2] ="EXPONENTIAL_(1)_SEED";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x058 >>2] ="EXPONENTIAL_(2)_CTRL";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x05C >>2] ="EXPONENTIAL_(2)_LAMBDA";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x060 >>2] ="EXPONENTIAL_(2)_SEED";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x064 >>2] ="EXPONENTIAL_(3)_CTRL";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x068 >>2] ="EXPONENTIAL_(3)_LAMBDA";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x06C >>2] ="EXPONENTIAL_(3)_SEED";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x070 >>2] ="EXPONENTIAL_(4)_CTRL";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x074 >>2] ="EXPONENTIAL_(4)_LAMBDA";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x078 >>2] ="EXPONENTIAL_(4)_SEED";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x07C >>2] ="EXTERNAL_(0)_CTRL";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x080 >>2] ="EXTERNAL(1)_CTRL";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x084 >>2] ="EXTERNAL(2)_CTRL";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x088 >>2] ="ADC_TRIGGER_CTRL";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x08C >>2] ="ADC_TRIGGER_THRESHOLD_LOW_ENERGY";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x090 >>2] ="ADC_TRIGGER_THRESHOLD_MEDIUM_ENERGY";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x094 >>2] ="ADC_TRIGGER_THRESHOLD_HIGH_ENERGY";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x098 >>2] ="ADC_TRIGGER_FPROMPT_THRESHOLD_LOW_ENERGY";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x09C >>2] ="ADC_TRIGGER_FPROMPT_THRESHOLD_MEDIUM_ENERGY";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0A0 >>2] ="ADC_TRIGGER_INTEGRATION_TIME_WINDOWS";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0A4 >>2] ="ADC_TRIGGER_SCAN&DEAD_TIME_WINDOWS";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0A8 >>2] ="ADC_MIN_BIAS_CTRL";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0AC >>2] ="ADC_MIN_BIAS_THRESHOLD_SUM";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0B0 >>2] ="ADC_MIN_BIAS_ToT_&DEAD_TIME";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0B4 >>2] ="ADC_MIN_BIAS_CHANNEL_SELECT_SINGLE";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0B8 >>2] ="ADC_MIN_BIAS_CHANNEL_SELECT_COINCIDENCE";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0BC >>2] ="ADC_MIN_BIAS_TIME_WINDOW_COINCIDENCE";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0C0 >>2] ="ADC_MIN_BIAS_THRESHOLD_CHANNELS_(1)_(0)";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0C4 >>2] ="ADC_MIN_BIAS_THRESHOLD_CHANNELS_(3)_(2)";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0C8 >>2] ="ADC_MIN_BIAS_THRESHOLD_CHANNELS_(5)_(4)";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0CC >>2] ="ADC_MIN_BIAS_THRESHOLD_CHANNELS_(7)_(6)";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0D0 >>2] ="ADC_MIN_BIAS_THRESHOLD_CHANNELS_(9)_(8)";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0D4 >>2] ="ADC_MIN_BIAS_THRESHOLD_CHANNELS_(11)_(10)";
	    default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0D8 >>2] ="ADC_MIN_BIAS_THRESHOLD_CHANNELS_(13)_(12)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0DC >>2] ="ADC_MIN_BIAS_THRESHOLD_CHANNELS_(15)_(14)" ;
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0E0 >>2] ="ADC_MIN_BIAS_THRESHOLD_CHANNELS_(17)_(16)" ;
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0E4 >>2] ="ADC_MIN_BIAS_THRESHOLD_CHANNELS_(19)_(18)" ;
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0E8 >>2] ="ADC_MIN_BIAS_THRESHOLD_CHANNELS_(21)_(20)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0EC >>2] ="TRIGGER_OUTPUT_(0)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0F0 >>2] ="TRIGGER_OUTPUT_(0)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0F4 >>2] ="TRIGGER_OUTPUT_(0)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0F8 >>2] ="TRIGGER_OUTPUT_(0)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x0FC >>2] ="TRIGGER_OUTPUT_(1)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x100 >>2] ="TRIGGER_OUTPUT_(1)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x104 >>2] ="TRIGGER_OUTPUT_(1)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x108 >>2] ="TRIGGER_OUTPUT_(1)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x10C >>2] ="TRIGGER_OUTPUT_(2)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x110 >>2] ="TRIGGER_OUTPUT_(2)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x114 >>2] ="TRIGGER_OUTPUT_(2)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x118 >>2] ="TRIGGER_OUTPUT_(2)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x11C >>2] ="TRIGGER_OUTPUT_(3)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x120 >>2] ="TRIGGER_OUTPUT_(3)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x124 >>2] ="TRIGGER_OUTPUT_(3)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x128 >>2] ="TRIGGER_OUTPUT_(3)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x12C >>2] ="TRIGGER_OUTPUT_(4)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x130 >>2] ="TRIGGER_OUTPUT_(4)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x134 >>2] ="TRIGGER_OUTPUT_(4)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x138 >>2] ="TRIGGER_OUTPUT_(4)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x13C >>2] ="TRIGGER_OUTPUT_(5)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x140 >>2] ="TRIGGER_OUTPUT_(5)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x144 >>2] ="TRIGGER_OUTPUT_(5)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x148 >>2] ="TRIGGER_OUTPUT_(5)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x14C >>2] ="TRIGGER_OUTPUT_(6)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x150 >>2] ="TRIGGER_OUTPUT_(6)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x158 >>2] ="TRIGGER_OUTPUT_(6)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x158 >>2] ="TRIGGER_OUTPUT_(6)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x15C >>2] ="TRIGGER_OUTPUT_(7)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x160 >>2] ="TRIGGER_OUTPUT_(7)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x164 >>2] ="TRIGGER_OUTPUT_(7)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x168 >>2] ="TRIGGER_OUTPUT_(7)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x16C >>2] ="TRIGGER_OUTPUT_(8)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x170 >>2] ="TRIGGER_OUTPUT_(8)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x174 >>2] ="TRIGGER_OUTPUT_(8)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x178 >>2] ="TRIGGER_OUTPUT_(8)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x17C >>2] ="TRIGGER_OUTPUT_(9)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x180 >>2] ="TRIGGER_OUTPUT_(9)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x184 >>2] ="TRIGGER_OUTPUT_(9)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x188 >>2] ="TRIGGER_OUTPUT_(9)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x18C >>2] ="TRIGGER_OUTPUT_(10)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x190 >>2] ="TRIGGER_OUTPUT_(10)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x194 >>2] ="TRIGGER_OUTPUT_(10)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x198 >>2] ="TRIGGER_OUTPUT_(10)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x19C >>2] ="TRIGGER_OUTPUT_(11)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1A0 >>2] ="TRIGGER_OUTPUT_(11)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1A4 >>2] ="TRIGGER_OUTPUT_(11)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1A8 >>2] ="TRIGGER_OUTPUT_(11)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1AC >>2] ="TRIGGER_OUTPUT_(12)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1B0 >>2] ="TRIGGER_OUTPUT_(12)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1B4 >>2] ="TRIGGER_OUTPUT_(12)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1B8 >>2] ="TRIGGER_OUTPUT_(12)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1BC >>2] ="TRIGGER_OUTPUT_(13)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1C0 >>2] ="TRIGGER_OUTPUT_(13)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1C4 >>2] ="TRIGGER_OUTPUT_(13)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1C8 >>2] ="TRIGGER_OUTPUT_(13)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1CC >>2] ="TRIGGER_OUTPUT_(14)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1D0 >>2] ="TRIGGER_OUTPUT_(14)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1D4 >>2] ="TRIGGER_OUTPUT_(14)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1D8 >>2] ="TRIGGER_OUTPUT_(14)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1DC >>2] ="TRIGGER_OUTPUT_(15)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1E0 >>2] ="TRIGGER_OUTPUT_(15)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1E4 >>2] ="TRIGGER_OUTPUT_(15)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1E8 >>2] ="TRIGGER_OUTPUT_(15)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1EC >>2] ="TRIGGER_OUTPUT_(16)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1F0 >>2] ="TRIGGER_OUTPUT_(16)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1F4 >>2] ="TRIGGER_OUTPUT_(16)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1F8 >>2] ="TRIGGER_OUTPUT_(16)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x1FC >>2] ="TRIGGER_OUTPUT_(17)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x200 >>2] ="TRIGGER_OUTPUT_(17)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x204 >>2] ="TRIGGER_OUTPUT_(17)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x208 >>2] ="TRIGGER_OUTPUT_(17)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x20C >>2] ="TRIGGER_OUTPUT_(18)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x210 >>2] ="TRIGGER_OUTPUT_(18)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x214 >>2] ="TRIGGER_OUTPUT_(18)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x218 >>2] ="TRIGGER_OUTPUT_(18)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x21C >>2] ="TRIGGER_OUTPUT_(19)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x220 >>2] ="TRIGGER_OUTPUT_(19)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x224 >>2] ="TRIGGER_OUTPUT_(19)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x228 >>2] ="TRIGGER_OUTPUT_(19)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x22C >>2] ="TRIGGER_OUTPUT_(20)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x230 >>2] ="TRIGGER_OUTPUT_(20)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x234 >>2] ="TRIGGER_OUTPUT_(20)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x238 >>2] ="TRIGGER_OUTPUT_(20)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x23C >>2] ="TRIGGER_OUTPUT_(21)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x240 >>2] ="TRIGGER_OUTPUT_(21)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x244 >>2] ="TRIGGER_OUTPUT_(21)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x248 >>2] ="TRIGGER_OUTPUT_(21)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x24C >>2] ="TRIGGER_OUTPUT_(22)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x250 >>2] ="TRIGGER_OUTPUT_(22)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x254 >>2] ="TRIGGER_OUTPUT_(22)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x258 >>2] ="TRIGGER_OUTPUT_(22)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x25C >>2] ="TRIGGER_OUTPUT_(23)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x260 >>2] ="TRIGGER_OUTPUT_(23)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x264 >>2] ="TRIGGER_OUTPUT_(23)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x268 >>2] ="TRIGGER_OUTPUT_(23)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x26C >>2] ="TRIGGER_OUTPUT_(24)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x270 >>2] ="TRIGGER_OUTPUT_(24)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x274 >>2] ="TRIGGER_OUTPUT_(24)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x278 >>2] ="TRIGGER_OUTPUT_(24)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x27C >>2] ="TRIGGER_OUTPUT_(25)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x280 >>2] ="TRIGGER_OUTPUT_(25)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x284 >>2] ="TRIGGER_OUTPUT_(25)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x288 >>2] ="TRIGGER_OUTPUT_(25)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x28C >>2] ="TRIGGER_OUTPUT_(26)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x290 >>2] ="TRIGGER_OUTPUT_(26)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x294 >>2] ="TRIGGER_OUTPUT_(26)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x298 >>2] ="TRIGGER_OUTPUT_(26)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x29C >>2] ="TRIGGER_OUTPUT_(27)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2A0 >>2] ="TRIGGER_OUTPUT_(27)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2A4 >>2] ="TRIGGER_OUTPUT_(27)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2A8 >>2] ="TRIGGER_OUTPUT_(27)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2AC >>2] ="TRIGGER_OUTPUT_(28)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2B0 >>2] ="TRIGGER_OUTPUT_(28)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2B4 >>2] ="TRIGGER_OUTPUT_(28)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2B8 >>2] ="TRIGGER_OUTPUT_(28)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2BC >>2] ="TRIGGER_OUTPUT_(29)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2C0 >>2] ="TRIGGER_OUTPUT_(29)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2C4 >>2] ="TRIGGER_OUTPUT_(29)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2C8 >>2] ="TRIGGER_OUTPUT_(29)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2CC >>2] ="TRIGGER_OUTPUT_(30)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2D0 >>2] ="TRIGGER_OUTPUT_(30)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2D4 >>2] ="TRIGGER_OUTPUT_(30)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2D8 >>2] ="TRIGGER_OUTPUT_(30)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2DC >>2] ="TRIGGER_OUTPUT_(31)_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2E0 >>2] ="TRIGGER_OUTPUT_(31)_RATE";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2E4 >>2] ="TRIGGER_OUTPUT_(31)_DELAY";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2E8 >>2] ="TRIGGER_OUTPUT_(31)_SOURCE_ID";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2EC >>2] ="ADC_BASELINE_CTRL";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2F0 >>2] ="ADC_BASELINE_INPUT_CH(0)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2F4 >>2] ="ADC_BASELINE_INPUT_CH(1)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2F8 >>2] ="ADC_BASELINE_INPUT_CH(2)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x2FC >>2] ="ADC_BASELINE_INPUT_CH(3)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x300 >>2] ="ADC_BASELINE_INPUT_CH(4)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x304 >>2] ="ADC_BASELINE_INPUT_CH(5)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x308 >>2] ="ADC_BASELINE_INPUT_CH(6)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x30C >>2] ="ADC_BASELINE_INPUT_CH(7)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x310 >>2] ="ADC_BASELINE_INPUT_CH(8)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x314 >>2] ="ADC_BASELINE_INPUT_CH(9)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x318 >>2] ="ADC_BASELINE_INPUT_CH(10)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x31C >>2] ="ADC_BASELINE_INPUT_CH(11)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x320 >>2] ="ADC_BASELINE_INPUT_CH(12)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x324 >>2] ="ADC_BASELINE_INPUT_CH(13)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x328 >>2] ="ADC_BASELINE_INPUT_CH(14)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x32C >>2] ="ADC_BASELINE_INPUT_CH(15)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x330 >>2] ="ADC_BASELINE_INPUT_CH(16)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x334 >>2] ="ADC_BASELINE_INPUT_CH(17)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x338 >>2] ="ADC_BASELINE_INPUT_CH(18)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x33C >>2] ="ADC_BASELINE_INPUT_CH(19)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x340 >>2] ="ADC_BASELINE_INPUT_CH(20)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x344 >>2] ="ADC_BASELINE_INPUT_CH(21)";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x348 >>2] ="ADC_BASELINE_INPUT_SUM";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x3B0 >>2] ="NIM_Diagnostics";
		default_zl9101m_device_driver_ctrl_register_descriptions[ 0x3B4 >>2] = "UARTinterfaceregister" ;

		default_zl9101m_device_driver_ctrl_register_descriptions[ 240 ] = "user_preamble(0)" ;
		default_zl9101m_device_driver_ctrl_register_descriptions[ 241 ] = "user_preamble(1)" ;
		default_zl9101m_device_driver_ctrl_register_descriptions[ 242 ] = "user_preamble(2)" ;
		default_zl9101m_device_driver_ctrl_register_descriptions[ 243 ] = "user_preamble(3)" ;
		default_zl9101m_device_driver_ctrl_register_descriptions[ 244 ] = "user_preamble(4)" ;
		default_zl9101m_device_driver_ctrl_register_descriptions[ 245 ] = "user_preamble(5)" ;
		default_zl9101m_device_driver_ctrl_register_descriptions[ 246 ] = "external_trigger" ;
		default_zl9101m_device_driver_ctrl_register_descriptions[ 247 ] = "dma_first_descriptor" ;
		default_zl9101m_device_driver_ctrl_register_descriptions[ 248 ] = "dma_num_descriptors" ;
		default_zl9101m_device_driver_ctrl_register_descriptions[ 249 ] = "retransmit_address";
			default_zl9101m_device_driver_ctrl_register_descriptions[ 250 ] = "retransmit_length";
			default_zl9101m_device_driver_ctrl_register_descriptions[ 251 ] = "retransmit_now";
*/

		uart_regfile_single_uart_included_regs_type the_included_ctrl_regs = get_all_map_keys<register_desc_map_type>(default_zl9101m_device_driver_ctrl_register_descriptions);

		this->set_control_reg_map_desc(default_zl9101m_device_driver_ctrl_register_descriptions);
		this->set_included_ctrl_regs(the_included_ctrl_regs);

	       default_zl9101m_device_driver_status_register_descriptions    [ 0x01 ] = "OPERATION";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x02 ] = "ON_OFF_CONFIG";
		   //default_zl9101m_device_driver_status_register_descriptions[ 0x03 ] = "CLEAR_FAULTS";
		   //default_zl9101m_device_driver_status_register_descriptions[ 0x11 ] = "STORE_DEFAULT_ALL;
		   //default_zl9101m_device_driver_status_register_descriptions[ 0x12 ] = "RESTORE_DEFAULT_ALL;
		   //default_zl9101m_device_driver_status_register_descriptions[ 0x15 ] = "STORE_USER_ALL;
		   //default_zl9101m_device_driver_status_register_descriptions[ 0x16 ] = "RESTORE_USER_ALL;
		    default_zl9101m_device_driver_status_register_descriptions[ 0x20 ] = "VOUT_MODE";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x21 ] = "VOUT_COMMAND";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x22 ] = "VOUT_TRIM";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x23 ] = "VOUT_CAL_OFFSET";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x24 ] = "VOUT_MAX";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x25 ] = "VOUT_MARGIN_HIGH";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x26 ] = "VOUT_MARGIN_LOW";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x27 ] = "VOUT_TRANSITION_RATE";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x28 ] = "VOUT_DROOP";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x32 ] = "MAX_DUTY";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x33 ] = "FREQUENCY_SWITCH";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x37 ] = "INTERLEAVE";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x38 ] = "IOUT_CAL_GAIN";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x39 ] = "IOUT_CAL_OFFSET";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x40 ] = "VOUT_OV_FAULT_LIMIT";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x41 ] = "VOUT_OV_FAULT_RESPONSE";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x44 ] = "VOUT_UV_FAULT_LIMIT";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x45 ] = "VOUT_UV_FAULT_RESPONSE";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x46 ] = "IOUT_OC_FAULT_LIMIT";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x4B ] = "IOUT_UC_FAULT_LIMIT";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x4F ] = "OT_FAULT_LIMIT";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x50 ] = "OT_FAULT_RESPONSE";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x51 ] = "OT_WARN_LIMIT";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x52 ] = "UT_WARN_LIMIT";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x53 ] = "UT_FAULT_LIMIT";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x54 ] = "UT_FAULT_RESPONSE";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x55 ] = "VIN_OV_FAULT_LIMIT";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x56 ] = "VIN_OV_FAULT_RESPONSE";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x57 ] = "VIN_OV_WARN_LIMIT";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x58 ] = "VIN_UV_WARN_LIMIT";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x59 ] = "VIN_UV_FAULT_LIMIT";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x5A ] = "VIN_UV_FAULT_RESPONSE";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x5E ] = "POWER_GOOD_ON";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x60 ] = "TON_DELAY";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x61 ] = "TON_RISE";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x64 ] = "TOFF_DELAY";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x65 ] = "TOFF_FALL";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x78 ] = "STATUS_BYTE";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x79 ] = "STATUS_WORD";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x7A ] = "STATUS_VOUT";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x7B ] = "STATUS_IOUT";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x7C ] = "STATUS_INPUT";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x7D ] = "STATUS_TEMPERATURE";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x7E ] = "STATUS_CML";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x80 ] = "STATUS_MFR_SPECIFIC";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x88 ] = "READ_VIN";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x8B ] = "READ_VOUT";
		    default_zl9101m_device_driver_status_register_descriptions[ 0x8C ] = "READ_IOUT";
			default_zl9101m_device_driver_status_register_descriptions[ 0x8D ] = "READ_TEMPERATURE_1";
			default_zl9101m_device_driver_status_register_descriptions[ 0x94 ] = "READ_DUTY_CYCLE";
			default_zl9101m_device_driver_status_register_descriptions[ 0x95 ] = "READ_FREQUENCY";
			default_zl9101m_device_driver_status_register_descriptions[ 0x98 ] = "PMBUS_REVISION"       ;
			// default_zl9101m_device_driver_status_register_descriptions[ 0x99 ] = "MFR_ID"               ;
			// default_zl9101m_device_driver_status_register_descriptions[ 0x9A ] = "MFR_MODEL"            ;
			// default_zl9101m_device_driver_status_register_descriptions[ 0x9B ] = "MFR_REVISION"         ;
			// default_zl9101m_device_driver_status_register_descriptions[ 0x9C ] = "MFR_LOCATION"         ;
			// default_zl9101m_device_driver_status_register_descriptions[ 0x9D ] = "MFR_DATE"             ;
			// default_zl9101m_device_driver_status_register_descriptions[ 0x9E ] = "MFR_SERIAL"           ;
		//	default_zl9101m_device_driver_status_register_descriptions[ 0xB0 ] = "USER_DATA_00"         ;
			default_zl9101m_device_driver_status_register_descriptions[ 0xBC ] = "AUTO_COMP_CONFIG"     ;
	      //default_zl9101m_device_driver_status_register_descriptions[ 0xBD ] = "AUTO_COMP_CONTROL"    ;
			default_zl9101m_device_driver_status_register_descriptions[ 0xBF ] = "DEADTIME_MAX"         ;
			default_zl9101m_device_driver_status_register_descriptions[ 0xD0 ] = "MFR_CONFIG"           ;
			default_zl9101m_device_driver_status_register_descriptions[ 0xD1 ] = "USER_CONFIG"          ;
			default_zl9101m_device_driver_status_register_descriptions[ 0xD2 ] = "ISHARE_CONFIG"        ;
			default_zl9101m_device_driver_status_register_descriptions[ 0xD3 ] = "DDC_CONFIG"           ;
			default_zl9101m_device_driver_status_register_descriptions[ 0xD4 ] = "POWER_GOOD_DELAY"     ;
		//	default_zl9101m_device_driver_status_register_descriptions[ 0xD5 ] = "PID_TAPS"             ;
			default_zl9101m_device_driver_status_register_descriptions[ 0xD6 ] = "INDUCTOR"             ;
			default_zl9101m_device_driver_status_register_descriptions[ 0xD7 ] = "NLR_CONFIG"           ;
			default_zl9101m_device_driver_status_register_descriptions[ 0xD8 ] = "OVUV_CONFIG"          ;
			default_zl9101m_device_driver_status_register_descriptions[ 0xDC ] = "TEMPCO_CONFIG"        ;
			default_zl9101m_device_driver_status_register_descriptions[ 0xDD ] = "DEADTIME"             ;
			default_zl9101m_device_driver_status_register_descriptions[ 0xDE ] = "DEADTIME_CONFIG"      ;
			default_zl9101m_device_driver_status_register_descriptions[ 0xE0 ] = "SEQUENCE"             ;
			default_zl9101m_device_driver_status_register_descriptions[ 0xE1 ] = "TRACK_CONFIG"         ;
		//	default_zl9101m_device_driver_status_register_descriptions[ 0xE2 ] = "DDC_GROUP"            ;
		//	default_zl9101m_device_driver_status_register_descriptions[ 0xE4 ] = "DEVICE_ID"            ;
			default_zl9101m_device_driver_status_register_descriptions[ 0xE5 ] ="MFR_IOUT_OC_FAULT_RESPONSE";
			default_zl9101m_device_driver_status_register_descriptions[ 0xE6 ] ="MFR_IOUT_UC_FAULT_RESPONSE";
			default_zl9101m_device_driver_status_register_descriptions[ 0xE7 ] ="IOUT_AVG_OC_FAULT_LIMIT";
			default_zl9101m_device_driver_status_register_descriptions[ 0xE8 ] ="IOUT_AVG_UC_FAULT_LIMIT";
			default_zl9101m_device_driver_status_register_descriptions[ 0xE9 ] ="MISC_CONFIG";
		//	default_zl9101m_device_driver_status_register_descriptions[ 0xEA ] ="SNAPSHOT";
		//	default_zl9101m_device_driver_status_register_descriptions[ 0xEB ] ="BLANK_PARAMS";
			default_zl9101m_device_driver_status_register_descriptions[ 0xF0 ] ="PHASE_CONTROL";
			default_zl9101m_device_driver_status_register_descriptions[ 0xF3 ] ="SNAPSHOT_CONTROL";
		//	default_zl9101m_device_driver_status_register_descriptions[ 0xF4 ] ="RESTORE_FACTORY";
			default_zl9101m_device_driver_status_register_descriptions[ 0xF5 ] ="MFR_VMON_OV_FAULT_LIMIT";
			default_zl9101m_device_driver_status_register_descriptions[ 0xF6 ] ="MFR_VMON_UV_FAULT_LIMIT";
			default_zl9101m_device_driver_status_register_descriptions[ 0xF7 ] ="MFR_READ_VMON";
			default_zl9101m_device_driver_status_register_descriptions[ 0xF8 ] ="VMON_OV_FAULT_RESPONSE";
			default_zl9101m_device_driver_status_register_descriptions[ 0xF9 ] ="VMON_UV_FAULT_RESPONSE";
			default_zl9101m_device_driver_status_register_descriptions[ 0xFA ] ="SECURITY_LEVEL";
		//	default_zl9101m_device_driver_status_register_descriptions[ 0xFB ] ="PRIVATE_PASSWORD";
		//	default_zl9101m_device_driver_status_register_descriptions[ 0xFC ] ="PUBLIC_PASSWORD";
		//	default_zl9101m_device_driver_status_register_descriptions[ 0xFD ] ="UNPROTECT";


			uart_regfile_single_uart_included_regs_type the_included_status_regs = get_all_map_keys<register_desc_map_type>(default_zl9101m_device_driver_status_register_descriptions);

			this->set_status_reg_map_desc(default_zl9101m_device_driver_status_register_descriptions);
			this->set_included_status_regs(the_included_status_regs);


			            reg_type_map[ 0x01 ] = rw_byte_type;//= "OPERATION";
					    reg_type_map[ 0x02 ] = rw_byte_type;//= "ON_OFF_CONFIG";
					    reg_type_map[ 0x03 ] = send_byte;//= "CLEAR_FAULTS";
					    reg_type_map[ 0x11 ] = send_byte;//= "STORE_DEFAULT_ALL;
					    reg_type_map[ 0x12 ] = send_byte;//= "RESTORE_DEFAULT_ALL;
					    reg_type_map[ 0x15 ] = send_byte;//= "STORE_USER_ALL;
					    reg_type_map[ 0x16 ] = send_byte;//= "RESTORE_USER_ALL;
					    reg_type_map[ 0x20 ] = r_byte_type;//= "VOUT_MODE";
					    reg_type_map[ 0x21 ] = rw_word_type;//= "VOUT_COMMAND";
					    reg_type_map[ 0x22 ] = rw_word_type;//= "VOUT_TRIM";
					    reg_type_map[ 0x23 ] = rw_word_type;//= "VOUT_CAL_OFFSET";
					    reg_type_map[ 0x24 ] = rw_word_type;//= "VOUT_MAX";
					    reg_type_map[ 0x25 ] = rw_word_type;//= "VOUT_MARGIN_HIGH";
					    reg_type_map[ 0x26 ] = rw_word_type;//= "VOUT_MARGIN_LOW";
					    reg_type_map[ 0x27 ] = rw_word_type;//= "VOUT_TRANSITION_RATE";
					    reg_type_map[ 0x28 ] = rw_word_type;//= "VOUT_DROOP";
					    reg_type_map[ 0x32 ] = rw_word_type;//= "MAX_DUTY";
					    reg_type_map[ 0x33 ] = rw_word_type;//= "FREQUENCY_SWITCH";
					    reg_type_map[ 0x37 ] = rw_word_type;//= "INTERLEAVE";
					    reg_type_map[ 0x38 ] = rw_word_type;//= "IOUT_CAL_GAIN";
					    reg_type_map[ 0x39 ] = rw_word_type;//= "IOUT_CAL_OFFSET";
					    reg_type_map[ 0x40 ] = rw_word_type;//= "VOUT_OV_FAULT_LIMIT";
					    reg_type_map[ 0x41 ] = rw_byte_type;//= "VOUT_OV_FAULT_RESPONSE";
					    reg_type_map[ 0x44 ] = rw_word_type;//= "VOUT_UV_FAULT_LIMIT";
					    reg_type_map[ 0x45 ] = rw_byte_type;//= "VOUT_UV_FAULT_RESPONSE";
					    reg_type_map[ 0x46 ] = rw_word_type;//= "IOUT_OC_FAULT_LIMIT";
					    reg_type_map[ 0x4B ] = rw_word_type;//= "IOUT_UC_FAULT_LIMIT";
					    reg_type_map[ 0x4F ] = rw_word_type;//= "OT_FAULT_LIMIT";
					    reg_type_map[ 0x50 ] = rw_byte_type;//= "OT_FAULT_RESPONSE";
					    reg_type_map[ 0x51 ] = rw_word_type;//= "OT_WARN_LIMIT";
					    reg_type_map[ 0x52 ] = rw_word_type;//= "UT_WARN_LIMIT";
					    reg_type_map[ 0x53 ] = rw_word_type;//= "UT_FAULT_LIMIT";
					    reg_type_map[ 0x54 ] = rw_byte_type;//= "UT_FAULT_RESPONSE";
					    reg_type_map[ 0x55 ] = rw_word_type;//= "VIN_OV_FAULT_LIMIT";
					    reg_type_map[ 0x56 ] = rw_byte_type;//= "VIN_OV_FAULT_RESPONSE";
					    reg_type_map[ 0x57 ] = rw_word_type;//= "VIN_OV_WARN_LIMIT";
					    reg_type_map[ 0x58 ] = rw_word_type;//= "VIN_UV_WARN_LIMIT";
					    reg_type_map[ 0x59 ] = rw_word_type;//= "VIN_UV_FAULT_LIMIT";
					    reg_type_map[ 0x5A ] = rw_byte_type;//= "VIN_UV_FAULT_RESPONSE";
					    reg_type_map[ 0x5E ] = rw_word_type;//= "POWER_GOOD_ON";
					    reg_type_map[ 0x60 ] = rw_word_type;//= "TON_DELAY";
					    reg_type_map[ 0x61 ] = rw_word_type;//= "TON_RISE";
					    reg_type_map[ 0x64 ] = rw_word_type;//= "TOFF_DELAY";
					    reg_type_map[ 0x65 ] = rw_word_type;//= "TOFF_FALL";
					    reg_type_map[ 0x78 ] = r_byte_type;//= "STATUS_BYTE";
					    reg_type_map[ 0x79 ] = r_word_type;//= "STATUS_WORD";
					    reg_type_map[ 0x7A ] = r_byte_type;//= "STATUS_VOUT";
					    reg_type_map[ 0x7B ] = r_byte_type;//= "STATUS_IOUT";
					    reg_type_map[ 0x7C ] = r_byte_type;//= "STATUS_INPUT";
					    reg_type_map[ 0x7D ] = r_byte_type;//= "STATUS_TEMPERATURE";
					    reg_type_map[ 0x7E ] = r_byte_type;//= "STATUS_CML";
					    reg_type_map[ 0x80 ] = r_byte_type;//= "STATUS_MFR_SPECIFIC";
					    reg_type_map[ 0x88 ] = r_word_type;//= "READ_VIN";
					    reg_type_map[ 0x8B ] = r_word_type;//= "READ_VOUT";
					    reg_type_map[ 0x8C ] = r_word_type;//= "READ_IOUT";
						reg_type_map[ 0x8D ] = r_word_type;//= "READ_TEMPERATURE_1";
						reg_type_map[ 0x94 ] = r_word_type;//= "READ_DUTY_CYCLE";
						reg_type_map[ 0x95 ] = r_word_type;//= "READ_FREQUENCY";
						reg_type_map[ 0x98 ] = r_byte_type;//= "PMBUS_REVISION"       ;
						reg_type_map[ 0x99 ] = block_type;//= "MFR_ID"               ;
						reg_type_map[ 0x9A ] = block_type;//= "MFR_MODEL"            ;
						reg_type_map[ 0x9B ] = block_type;//= "MFR_REVISION"         ;
						reg_type_map[ 0x9C ] = block_type;//= "MFR_LOCATION"         ;
						reg_type_map[ 0x9D ] = block_type;//= "MFR_DATE"             ;
						reg_type_map[ 0x9E ] = block_type;//= "MFR_SERIAL"           ;
						reg_type_map[ 0xB0 ] = block_type;//= "USER_DATA_00"         ;
						reg_type_map[ 0xBC ] = rw_byte_type;//= "AUTO_COMP_CONFIG"     ;
				        reg_type_map[ 0xBD ] = send_byte;//= "AUTO_COMP_CONTROL"    ;
						reg_type_map[ 0xBF ] = rw_word_type;//= "DEADTIME_MAX"         ;
						reg_type_map[ 0xD0 ] = rw_word_type;//= "MFR_CONFIG"           ;
						reg_type_map[ 0xD1 ] = rw_word_type;//= "USER_CONFIG"          ;
						reg_type_map[ 0xD2 ] = rw_word_type;//= "ISHARE_CONFIG"        ;
						reg_type_map[ 0xD3 ] = rw_word_type;//= "DDC_CONFIG"           ;
						reg_type_map[ 0xD4 ] = rw_word_type;//= "POWER_GOOD_DELAY"     ;
					    reg_type_map[ 0xD5 ] = block_type;//= "PID_TAPS"             ;
						reg_type_map[ 0xD6 ] = rw_word_type;//= "INDUCTOR"             ;
						reg_type_map[ 0xD7 ] = rw_word_type;//= "NLR_CONFIG"           ;
						reg_type_map[ 0xD8 ] = rw_byte_type;//= "OVUV_CONFIG"          ;
						reg_type_map[ 0xDC ] = rw_byte_type;//= "TEMPCO_CONFIG"        ;
						reg_type_map[ 0xDD ] = rw_word_type;//= "DEADTIME"             ;
						reg_type_map[ 0xDE ] = rw_word_type;//= "DEADTIME_CONFIG"      ;
						reg_type_map[ 0xE0 ] = rw_word_type;//= "SEQUENCE"             ;
						reg_type_map[ 0xE1 ] = rw_byte_type;//= "TRACK_CONFIG"         ;
						reg_type_map[ 0xE2 ] = block_type;//= "DDC_GROUP"            ;
					    reg_type_map[ 0xE4 ] = r_block_type;//= "DEVICE_ID"            ;
						reg_type_map[ 0xE5 ] = rw_byte_type;//="MFR_IOUT_OC_FAULT_RESPONSE";
						reg_type_map[ 0xE6 ] = rw_byte_type;//="MFR_IOUT_UC_FAULT_RESPONSE";
						reg_type_map[ 0xE7 ] = rw_word_type;//="IOUT_AVG_OC_FAULT_LIMIT";
						reg_type_map[ 0xE8 ] = rw_word_type;//="IOUT_AVG_UC_FAULT_LIMIT";
						reg_type_map[ 0xE9 ] = rw_word_type;//="MISC_CONFIG";
						reg_type_map[ 0xEA ] = r_block_type;//="SNAPSHOT";
						reg_type_map[ 0xEB ] = r_block_type;//="BLANK_PARAMS";
						reg_type_map[ 0xF0 ] = rw_byte_type;//="PHASE_CONTROL";
						reg_type_map[ 0xF3 ] = rw_byte_type;//="SNAPSHOT_CONTROL";
						reg_type_map[ 0xF4 ] = send_byte;//="RESTORE_FACTORY";
						reg_type_map[ 0xF5 ] = rw_word_type;//="MFR_VMON_OV_FAULT_LIMIT";
						reg_type_map[ 0xF6 ] = rw_word_type;//="MFR_VMON_UV_FAULT_LIMIT";
						reg_type_map[ 0xF7 ] = r_word_type;//="MFR_READ_VMON";
						reg_type_map[ 0xF8 ] = rw_byte_type;//="VMON_OV_FAULT_RESPONSE";
						reg_type_map[ 0xF9 ] = rw_byte_type;//="VMON_UV_FAULT_RESPONSE";
						reg_type_map[ 0xFA ] = r_byte_type;//="SECURITY_LEVEL";
						reg_type_map[ 0xFB ] = block_type;//="PRIVATE_PASSWORD";
						reg_type_map[ 0xFC ] = block_type;//="PUBLIC_PASSWORD";
						//reg_type_map[ 0xFC ] = rw_doubleword_type;//="PUBLIC_PASSWORD";

						reg_type_map[ 0xFD ] = block_type;//="UNPROTECT";

		    dureg(safe_print(std::cout << "zl9101m_virtual_uart set status included registers to: (" << this->get_included_ctrl_regs_as_string() << ")" << std::endl;););
}


unsigned long long zl9101m_virtual_uart::read_control_reg(unsigned long address, unsigned long secondary_uart_address, int* errorptr)
{
    if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return 0;
	}
    unsigned long long result = 0xEAA;

    switch (reg_type_map[address]) {
    case  rw_byte_type:
    case  r_byte_type:
        result =  ZL9101M_ReadByte(this->get_pmbus_base(), this->address_defs.control_addr_min, address);
        break;
    case  rw_word_type:
    case  r_word_type:
         result =  ZL9101M_ReadWord(this->get_pmbus_base(), this->address_defs.control_addr_min, address);
         break;
    case rw_doubleword_type:
      	     result = ZL9101M_ReadDoubleWord(this->get_pmbus_base(), this->address_defs.control_addr_min, address);
      	     break;
    default:
    	std::cout << "Unsupported control read for register address " << std::hex << address << std::dec << " in uart " << this->get_device_name()  << std::endl;

    }
    return result;
};

void zl9101m_virtual_uart::write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address, int* errorptr)
{
	if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return;
	}
	std::cout<<"zl9101m control write unsupported for the moment! \n";
};


unsigned long long zl9101m_virtual_uart::read_status_reg(unsigned long address, unsigned long secondary_uart_address, int* errorptr)
{
    if (!is_valid_secondary_uart(secondary_uart_address)) {
		dureg(safe_print(std::cout << "invalid secondary Address: " << secondary_uart_address<< std::endl););
		return 0;
	}


    unsigned long long result = 0xEAA;

       switch (reg_type_map[address]) {
       case  rw_byte_type:
       case  r_byte_type:
           result =  ZL9101M_ReadByte(this->get_pmbus_base(), this->address_defs.status_addr_min, address);
           break;
       case  rw_word_type:
       case  r_word_type:
            result =  ZL9101M_ReadWord(this->get_pmbus_base(), this->address_defs.status_addr_min, address);
            break;

       case rw_doubleword_type:
    	     result = ZL9101M_ReadDoubleWord(this->get_pmbus_base(), this->address_defs.status_addr_min, address);
    	     break;
       default:
       	std::cout << "Unsupported status read for register address " << std::hex << address << std::dec << " in uart " << this->get_device_name()  << std::endl;

       }

    return result;
};


std::string zl9101m_virtual_uart::read_block(unsigned long address, unsigned long length) {

	 std::string result;
	 switch (reg_type_map[address]) {
	       case  block_type:
	       case r_block_type:
	            ZL9101M_ReadBlock(this->get_pmbus_base(), this->address_defs.status_addr_min, address, result, length);
	           break;

	       default:
    		char helper_str[20];
    		snprintf(helper_str,10,"%x %d",address,(int) (reg_type_map[address]));
    		result = "Error - illegal read from address " + std::string(helper_str);
	       	std::cout << "Unsupported block read for register address " << std::hex << address << std::dec << " in uart " << this->get_device_name()  << " Error string is (" << result << ")" << std::endl;

	       }
	 return result;
}
