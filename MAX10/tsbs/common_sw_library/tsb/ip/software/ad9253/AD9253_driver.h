/***************************************************************************//**
 *   @file   AD9253.h
 *   @brief  Header file of AD9253 Driver.
 *   @author DNechita (Dan.Nechita@analog.com)
********************************************************************************
 * Copyright 2013(c) Analog Devices, Inc.
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *  - Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  - Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *  - Neither the name of Analog Devices, Inc. nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *  - The use of this software may or may not infringe the patent rights
 *    of one or more patent holders.  This license does not release you
 *    from the requirement that you obtain separate licenses from these
 *    patent holders to use this software.
 *  - Use of the software either in source or binary form, must be run
 *    on or directly connected to an Analog Devices Inc. component.
 *
 * THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT,
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, INTELLECTUAL PROPERTY RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
********************************************************************************
 *   SVN Revision: $WCREV$
*******************************************************************************/
#ifndef __AD9253_DRIVER__H__
#define __AD9253_DRIVER__H__

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include "opencores_spi_driver.h"
/******************************************************************************/
/*********************************** AD9253 ***********************************/
/******************************************************************************/
#define AD9253_SPI_CORE_BAUDRATE      50000
#define AD9253_SPI_CORE_CTRL_SETTINGS 0x2408 // char_len = 8 go_bsy = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1
#define AD9253_HIGHEST_REG_ADDR       0x110

#define DEBUG_AD9253_DEVICE_DRIVER (1)
/* Registers */

#define AD9253_READ                         (1 << 15)
#define AD9253_WRITE                        (0 << 15)
#define AD9253_CNT(x)                       ((((x) & 0x3) - 1) << 13)
#define AD9253_ADDR(x)                      ((x) & 0xFF)

#define AD9253_R1B                          (1 << 8)
#define AD9253_R2B                          (2 << 8)
#define AD9253_R3B                          (3 << 8)
#define AD9253_TRANSF_LEN(x)                (((x) >> 8) & 0xFF)
#define SHADOW(x)                           ((x) << 16)

/* Chip configuration registers */
#define AD9253_REG_SPI_CFG                  (AD9253_R1B | 0x00)
#define AD9253_REG_CHIP_ID                  (AD9253_R1B | 0x01)
#define AD9253_REG_CHIP_INFO                (AD9253_R1B | 0x02)

/* Channel index and transfer registers */
#define AD9253_REG_CH_INDEX                 (AD9253_R1B | 0x05)
#define AD9253_REG_DEVICE_UPDATE            (AD9253_R1B | 0xFF)

/* Program register map */
#define AD9253_REG_PDWN                     (AD9253_R1B | 0x08)
#define AD9253_REG_CLOCK                    (AD9253_R1B | 0x09)
#define AD9253_REG_PLL_STAT                 (AD9253_R1B | 0x0A)
#define AD9253_REG_CLOCK_DIV                (AD9253_R1B | 0x0B)
#define AD9253_REG_TEST                     (AD9253_R1B | 0x0D)
#define AD9253_REG_BIST                     (AD9253_R1B | 0x0E)
#define AD9253_REG_OFFSET                   (AD9253_R1B | 0x10)
#define AD9253_REG_OUT_MODE                 (AD9253_R1B | 0x14)
#define AD9253_REG_CML                      (AD9253_R1B | 0x15)
#define AD9253_REG_VREF                     (AD9253_R1B | 0x18)
#define AD9253_REG_USER_TEST1               (AD9253_R2B | 0x1A)
#define AD9253_REG_USER_TEST2               (AD9253_R2B | 0x1C)
#define AD9253_REG_USER_TEST3               (AD9253_R2B | 0x1E)
#define AD9253_REG_USER_TEST4               (AD9253_R2B | 0x20)
#define AD9253_REG_PLL_ENCODE               (AD9253_R1B | 0x21)
#define AD9253_REG_BIST_MISR                (AD9253_R2B | 0x25)
#define AD9253_REG_SYS_CTRL                 (AD9253_R1B | 0x3A)
#define AD9253_REG_DCC_CTRL                 (AD9253_R1B | 0x40)
#define AD9253_REG_DCC_VAL                  (AD9253_R2B | 0x42)
#define AD9253_REG_FAST_DETECT              (AD9253_R1B | 0x45)
#define AD9253_REG_FD_UPPER_THD             (AD9253_R2B | 0x48)
#define AD9253_REG_FD_LOWER_THD             (AD9253_R2B | 0x4A)
#define AD9253_REG_FD_DWELL_TIME            (AD9253_R2B | 0x4C)
#define AD9253_REG_204B_QUICK_CFG           (AD9253_R1B | 0x5E)
#define AD9253_REG_204B_CTRL1               (AD9253_R1B | 0x5F)
#define AD9253_REG_204B_CTRL2               (AD9253_R1B | 0x60)
#define AD9253_REG_204B_CTRL3               (AD9253_R1B | 0x61)
#define AD9253_REG_204B_DID_CFG             (AD9253_R1B | 0x64)
#define AD9253_REG_204B_BID_CFG             (AD9253_R1B | 0x65)
#define AD9253_REG_204B_LID_CFG1            (AD9253_R1B | 0x67)
#define AD9253_REG_204B_LID_CFG2            (AD9253_R1B | 0x68)
#define AD9253_REG_204B_PARAM_SCR_L         (AD9253_R1B | 0x6E)
#define AD9253_REG_204B_PARAM_F             (AD9253_R1B | 0x6F)
#define AD9253_REG_204B_PARAM_K             (AD9253_R1B | 0x70)
#define AD9253_REG_204B_PARAM_M             (AD9253_R1B | 0x71)
#define AD9253_REG_204B_PARAM_CS_N          (AD9253_R1B | 0x72)
#define AD9253_REG_204B_PARAM_NP            (AD9253_R1B | 0x73)
#define AD9253_REG_204B_PARAM_S             (AD9253_R1B | 0x74)
#define AD9253_REG_204B_PARAM_HD_CF         (AD9253_R1B | 0x75)
#define AD9253_REG_204B_RESV1               (AD9253_R1B | 0x76)
#define AD9253_REG_204B_RESV2               (AD9253_R1B | 0x77)
#define AD9253_REG_204B_CHKSUM0             (AD9253_R1B | 0x79)
#define AD9253_REG_204B_CHKSUM1             (AD9253_R1B | 0x7A)
#define AD9253_REG_204B_LANE_ASSGN1         (AD9253_R1B | 0x82)
#define AD9253_REG_204B_LANE_ASSGN2         (AD9253_R1B | 0x83)
#define AD9253_REG_204B_LMFC_OFFSET         (AD9253_R1B | 0x8B)
#define AD9253_REG_204B_PRE_EMPHASIS        (AD9253_R1B | 0xA8)

/* AD9253_REG_SPI_CFG */
#define AD9253_SPI_CFG_LSB_FIRST            ((1 << 6) | (1 << 1))
#define AD9253_SPI_CFG_SOFT_RST             ((1 << 5) | (1 << 2))
#define AD9253_SPI_CFG_USE_SDIO             ((1 << 7) | (1 << 0))
#define AD9253_SPI_CFG_USE_16BIT_ADDRESS    ((1 << 4) | (1 << 3))
/* AD9253_REG_CH_INDEX */
#define AD9253_CH_INDEX_ADC_A               (1 << 0)
#define AD9253_CH_INDEX_ADC_B               (1 << 1)

/* AD9253_REG_DEVICE_UPDATE */
#define AD9253_DEVICE_UPDATE_SW             (1 << 0)

/* AD9253_REG_PDWN */
#define AD9253_PDWN_EXTERN                  (1 << 5)
#define AD9253_PDWN_JTX                     (1 << 4)
#define AD9253_PDWN_JESD204B(x)             (((x) & 0x3) << 2)
#define AD9253_PDWN_CHIP(x)                 (((x) & 0x3) << 0)

/* AD9253_REG_CLOCK */
#define AD9253_CLOCK_SELECTION(x)           (((x) & 0x3) << 4)
#define AD9253_CLOCK_DUTY_CYCLE             (1 << 0)

/* AD9253_REG_PLL_STAT */
#define AD9253_PLL_STAT_LOCKED              (1 << 7)
#define AD9253_PLL_STAT_204B_LINK_RDY       (1 << 0)

/* AD9253_REG_CLOCK_DIV */
#define AD9253_CLOCK_DIV_PHASE(x)           (((x) & 0x7) << 3)
#define AD9253_CLOCK_DIV_RATIO(x)           (((x) & 0x7) << 0)

/* AD9253_REG_TEST */
#define AD9253_TEST_USER_TEST_MODE(x)       (((x) & 0x3) << 6)
#define AD9253_TEST_RST_PN_LONG             (1 << 5)
#define AD9253_TEST_RST_PN_SHOR             (1 << 4)
#define AD9253_TEST_OUTPUT_TEST(x)          (((x) & 0xF) << 0)

/* AD9253_REG_BIST */
#define AD9253_BIST_RESET                   (1 << 2)
#define AD9253_BIST_ENABLE                  (1 << 0)

/* AD9253_REG_OFFSET */
#define AD9253_REG_OFFSET_ADJUST(x)             (((x) & 0x3F) << 0)

/* AD9253_REG_OUT_MODE */
#define AD9253_OUT_MODE_JTX_BIT_ASSIGN(x)       (((x) & 0x7) << 5)
#define AD9253_OUT_MODE_DISABLE                 (1 << 4)
#define AD9253_OUT_MODE_INVERT_DATA             (1 << 3)
#define AD9253_OUT_MODE_DATA_FORMAT(x)          (((x) & 0x1) << 0)

/* AD9253_REG_CML */
#define AD9253_CML_DIFF_OUT_LEVEL(x)            (((x) & 0x7) << 0)

/* AD9253_REG_VREF */
#define AD9253_VREF_FS_ADJUST(x)                (((x) & 0x1F) << 0)

/* AD9253_REG_PLL_ENCODE */
#define AD9253_PLL_ENCODE(x)                    (((x) & 0x3) << 3)

/* AD9253_REG_SYS_CTRL */
#define AD9253_SYS_CTRL_REALIGN_ON_SYNCINB      (1 << 4)
#define AD9253_SYS_CTRL_REALIGN_ON_SYSREF       (1 << 3)
#define AD9253_SYS_CTRL_SYSREF_MODE             (1 << 2)
#define AD9253_SYS_CTRL_SYSREF_EN               (1 << 1)
#define AD9253_SYS_CTRL_SYNCINB_EN              (1 << 0)

/* AD9253_REG_DCC_CTRL */
#define AD9253_DCC_CTRL_FREEZE_DCC              (1 << 6)
#define AD9253_DCC_CTRL_DCC_BW(x)               (((x) & 0xF) << 2)
#define AD9253_DCC_CTRL_DCC_EN                  (1 << 1)

/* AD9253_REG_FAST_DETECT */
#define AD9253_FAST_DETECT_PIN_FCT              (1 << 4)
#define AD9253_FAST_DETECT_FORCE_FDA_FDB_PIN    (1 << 3)
#define AD9253_FAST_DETECT_FORCE_FDA_FDB_VAL    (1 << 2)
#define AD9253_FAST_DETECT_OUTPUT_ENABLE        (1 << 0)

/* AD9253_REG_204B_QUICK_CFG */
#define AD9253_204B_QUICK_CFG(x)                (((x) & 0xFF) << 0)

/* AD9253_REG_204B_CTRL1 */
#define AD9253_204B_CTRL1_TAIL_BITS             (1 << 6)
#define AD9253_204B_CTRL1_TEST_SAMPLE_EN        (1 << 5)
#define AD9253_204B_CTRL1_ILAS_MODE(x)          (((x) & 0x3) << 2)
#define AD9253_204B_CTRL1_POWER_DOWN            (1 << 0)

/* AD9253_REG_204B_CTRL2 */
#define AD9253_204B_CTRL2_INVERT_JESD_BITS      (1 << 1)

/* AD9253_REG_204B_CTRL3 */
#define AD9253_204B_CTRL3_TEST_DATA_INJ_PT(x)   (((x) & 0x3) << 4)
#define AD9253_204B_CTRL3_JESD_TEST_MODE(x)     (((x) & 0xF) << 0)

/* AD9253_REG_204B_PARAM_SCR_L */
#define AD9253_204B_PARAM_SCR_L_SCRAMBLING      (1 << 7)
#define AD9253_204B_PARAM_SCR_L_LANES           (1 << 0)

/* AD9253_REG_204B_PARAM_CS_N */
#define AD9253_204B_PARAM_CS_N_NR_CTRL_BITS(x)      (((x) & 0x3) << 6)
#define AD9253_204B_PARAM_CS_N_ADC_RESOLUTION(x)    (((x) & 0xF) << 0)

/* AD9253_REG_204B_PARAM_NP */
#define AD9253_204B_PARAM_NP_JESD_SUBCLASS(x)       (((x) & 0x3) << 5)
#define AD9253_204B_PARAM_NP_JESD_N_VAL(x)          (((x) & 0xF) << 0)

/* AD9253_REG_204B_PARAM_S */
#define AD9253_204B_PARAM_S(x)                  (((x) << 0x1F) << 0)

/* AD9253_REG_204B_PARAM_HD_CF */
#define AD9253_204B_PARAM_HD_CF_HD_VAL          (1 << 7)
#define AD9253_204B_PARAM_HD_CF_CF_VAL(x)       (((x) & 0x1F) << 0)

/* AD9253_REG_204B_LANE_ASSGN1 */
#define AD9253_204B_LANE_ASSGN1(x)              (((x) & 0x3) << 4)

/* AD9253_REG_204B_LANE_ASSGN2 */
#define AD9253_204B_LANE_ASSGN2(x)              (((x) &0x3) << 0)

/* AD9253_REG_204B_LMFC_OFFSET */
#define AD9253_204B_LMFC_OFFSET(x)              (((x) & 0x1F) << 0)

/*****************************************************************************/
/************************** Types Declarations *******************************/
/*****************************************************************************/

/**
 * struct AD9253_platform_data - Platform specific information.
 *
 * @extrnPDWNmode: External PDWN mode.
 *                 0 = PDWN is full power down
 *                 1 = PDWN puts device in standby
 * @enClkDCS: Clock duty cycle stabilizer enable.
 *            0 = disable
 *            1 = enable
 * @clkSelection: Clock selection.
 *                0 = Nyquist clock
 *                2 = RF clock divide by 4
 *                3 = clock off
 * @clkDivRatio: Clock divider ratio relative to the encode clock.
 *               0x00 = divide by 1
 *               0x01 = divide by 2
 *               ...
 *               0x07 = divide by 8
 * @clkDivPhase: Clock divide phase relative to the encode clock.
 *               0x0 = 0 input clock cycles delayed
 *               0x1 = 1 input clock cycles delayed
 *               ...
 *               0x7 = 7 input clock cycles delayed
 * @adcVref: Main reference full-scale VREF adjustment.
 *           0x0f = internal 2.087 V p-p
 *           ...
 *           0x01 = internal 1.772 V p-p
 *           0x00 = internal 1.75 V p-p [default]
 *           0x1F = internal 1.727 V p-p
 *           ...
 *           0x10 = internal 1.383 V p-p
 * @pllLowEncode: PLL low encode.
 *                0 = for lane speeds > 2 Gbps
 *                1 = for lane speeds < 2 Gbps
 * @name: Device name.
 */
struct AD9253_platform_data
{
    /* Power configuration */
    int8_t extrnPDWNmode;
    /* Global clock */
    int8_t enClkDCS;
    int8_t clkSelection;
    int8_t clkDivRatio;
    int8_t clkDivPhase;
    /* ADC Vref */
    int8_t adcVref;
    /* PLL */
    int8_t pllLowEncode;
    /* Device name */
    int8_t  name[16];
};

/**
 * struct AD9253_jesd204b_cfg - JESD204B interface configuration.
 *
 * @jtxInStandBy: JTX in standby.
 *                0 = 204B core is unaffected in standby
 *                1 = 204B core is powered down except for PLL during standby
 * @cmlLevel: JESD204B CML differential output drive level adjustment.
 *            0 = 81% of nominal (that is, 238 mV)
 *            1 = 89% of nominal (that is, 262 mV)
 *            2 = 98% of nominal (that is, 286 mV)
 *            3 = nominal [default] (that is, 293 mV)
 *            6 = 126% of nominal (that is, 368 mV)
 * @quickCfgOption: Quick configuration register.
 *                  0x11 = M = 1, L = 1; one converter, one lane
 *                  0x12 = M = 1, L = 2; one converter, two lanes
 *                  0x21 = M = 2, L = 1; two converters, one lane
 *                  0x22 = M = 2, L = 2; two converters, two lanes
 * @subclass: JESD204B subclass.
 *            0 = Subclass 0
 *            1 = Subclass 1
 * @ctrlBitsNo: Number of control bits (CS).
 *              0 = no control bits(CS = 0)
 *              1 = 1 control bit  (CS = 1)
 *              2 = 2 control bits (CS = 2)
 * @ctrlBitsAssign: JTX CS bits assignment.
 *                  0 = {overrange||underrange, valid}
 *                  1 = {overrange||underrange}
 *                  2 = {overrange||underrange, blank}
 *                  3 = {blank, valid}
 *                  4 = {blank, blank}
 *         All others = {overrange||underrange, valid}
 * @tailBitsMode: Tail bits: If CS bits are not enabled.
 *                0 = extra bits are 0
 *                1 = extra bits are 9-bit PN
 * @did: JESD204B device identification value: DID[7:0]
 * @bid: JESD204B bank identification value : BID[3:0]
 * @lid0: JESD204B lane0 identification value: LID[4:0]
 * @lid1: JESD204B lane1 identification value: LID[4:0]
 * @k: JESD204B number of frames per multiframe (K); set value of K per JESD204B
 *     specifications, but also must be a multiple of 4 octets.
 * @scrambling: JESD204B scrambling (SCR).
 *              0 = disabled
 *              1 = enabled
 * @ilasMode: Initial lane alignment sequence (ILAS) mode.
 *            1 = ILAS normal mode enabled
 *            3 = ILAS always on, test mode
 * @enIlasTest: JESD204B test sample.
 *              0 = disabled
 *              1 = enabled
 * @invertLogicBits: Invert logic of JESD204B bits.
 *                   0 = non-invert
 *                   1 = invert
 * @enSysRef: SYSREF+- enable.
 *            0 = disabled
 *            1 = enabled
 * @enSyncInB: Enable SYNCINB+- buffer.
 *             0 = buffer disabled
 *             1 = buffer enabled
 * @sysRefMode: SYSREF+- mode.
 *              0 = continuous reset clock dividers
 *              1 = sync on next SYSREF+- rising edge only
 * @alignSyncInB: Options for interpreting single on SYNCINB+-.
 *                0 = normal mode
 *                1 = realign lanes on every active SYNCINB+-
 * @alignSysRef: Options for interpreting single on SYSREF+-.
 *               0 = normal mode;
 *               1 = realign lanes on every active SYSREF+-
 * @lane0Assign: Option to remap converter and lane assignments.
 *               0 = assign Logical Lane 0 to Physical Lane A [default]
 *               1 = assign Logical Lane 0 to Physical Lane B
 * @lane1Assign: Option to remap converter and lane assignments.
 *               0 = assign Logical Lane 1 to Physical Lane A
 *               1 = assign Logical Lane 1 to Physical Lane B [default]
 */
struct AD9253_jesd204b_cfg
{
    /* Power configuration */
    int8_t jtxInStandBy;
    /* Output drive adjustment */
    int8_t cmlLevel;
    /* Quick configuration */
    int8_t quickCfgOption;
    /* Detailed Options */
    int8_t subclass;
    int8_t ctrlBitsNo;
    int8_t ctrlBitsAssign;
    int8_t tailBitsMode;
    int8_t did;
    int8_t bid;
    int8_t lid0;
    int8_t lid1;
    int8_t k;
    int8_t scrambling;
    int8_t ilasMode;
    int8_t enIlasTest;
    int8_t invertLogicBits;
    int8_t enSysRef;
    int8_t enSyncInB;
    int8_t sysRefMode;
    int8_t alignSyncInB;
    int8_t alignSysRef;
    int8_t lane0Assign;
    int8_t lane1Assign;
};

/**
 * struct AD9253_fast_detect_cfg - Fast Detect module configuration.
 *
 * @enFd: Enable fast detect output.
 *        0 = disable
 *        1 = enable
 * @pinFunction: Pin function.
 *               0 = fast detect
 *               1 = overrange
 * @forcePins: Force FDA/FDB pins
 *             0 = normal function
 *             1 = force to value
 * @pinForceValue: Force value of FDA/FDB pins.
 *                 0 = output on FD pins will be 0
 *                 1 = output on FD pins will be 1
 * @fdUpperTresh: Fast Detect Upper Threshold[14:0].
 * @fdLowerTresh: Fast Detect Lower Threshold[14:0].
 * @dfDwellTime: Fast Detect Dwell Time[15:0].
 */
struct AD9253_fast_detect_cfg
{
    int8_t  enFd;
    int8_t  pinFunction;
    int8_t  forcePins;
    int8_t  pinForceValue;
    int16_t fdUpperTresh;
    int16_t fdLowerTresh;
    int16_t dfDwellTime;
};
struct AD9253_state
{
    struct AD9253_platform_data   *pdata;
    struct AD9253_jesd204b_cfg    *pJesd204b;
    struct AD9253_fast_detect_cfg *pFd;

};

enum shadowRegisters
{
    AD9253_SHD_REG_CLOCK = 1,
    AD9253_SHD_REG_CLOCK_DIV,
    AD9253_SHD_REG_TEST,
    AD9253_SHD_REG_BIST,
    AD9253_SHD_REG_OFFSET,
    AD9253_SHD_REG_OUT_MODE,
    AD9253_SHD_REG_VREF,
    AD9253_SHD_REG_SYS_CTRL,
    AD9253_SHD_REG_DCC_CTRL,
    AD9253_SHD_REG_DCC_VAL,
    AD9253_SHD_REG_FAST_DETECT,
    AD9253_SHD_REG_FD_UPPER_THD,
    AD9253_SHD_REG_FD_LOWER_THD,
    AD9253_SHD_REG_FD_DWELL_TIME,
    SHADOW_REGISTER_COUNT
};


class AD9253_driver  {
protected:
	opencores_spi_driver* spi_driver;
	struct AD9253_state AD9253_st;
	int32_t shadowRegs[SHADOW_REGISTER_COUNT];
	int32_t AD9253_is_shadow_register(int32_t registerAddress);
	int32_t AD9253_reset_PN9(int32_t rst);
	int32_t AD9253_jesd204b_set_frames(int32_t k_frames);
	int32_t AD9253_set_bits_to_reg(uint32_t registerAddress,
	                               uint8_t  bitsValue,
	                               uint8_t  mask);
	unsigned long chipselect_index;
	void init_shadow_regs () {
		                         shadowRegs[0 ] =   0;
					             shadowRegs[AD9253_SHD_REG_CLOCK        ] =   0x01;
		shadowRegs[AD9253_SHD_REG_CLOCK_DIV] = 0x00;
		shadowRegs[AD9253_SHD_REG_TEST] = 0x00;
		shadowRegs[AD9253_SHD_REG_BIST] = 0x00;
		shadowRegs[AD9253_SHD_REG_OFFSET] = 0x00;
		shadowRegs[AD9253_SHD_REG_OUT_MODE] = 0x01;
		shadowRegs[AD9253_SHD_REG_VREF] = 0x00;
		shadowRegs[AD9253_SHD_REG_SYS_CTRL] = 0x00;
		shadowRegs[AD9253_SHD_REG_DCC_CTRL] = 0x00;
		shadowRegs[AD9253_SHD_REG_DCC_VAL] = 0x00;
		shadowRegs[AD9253_SHD_REG_FAST_DETECT] = 0x00;
		shadowRegs[AD9253_SHD_REG_FD_UPPER_THD] = 0x00;
		shadowRegs[AD9253_SHD_REG_FD_LOWER_THD] = 0x00;
		shadowRegs[AD9253_SHD_REG_FD_DWELL_TIME] = 0x00;
	}

public:
	AD9253_driver() {
		init_shadow_regs();
	}

	;
	int32_t AD9253_setup();
	int32_t AD9253_read(int32_t registerAddress);
	int32_t AD9253_write(int32_t registerAddress, int32_t registerValue);
	int32_t AD9253_transfer(void);
	int32_t AD9253_soft_reset(void);
	int32_t AD9253_chip_pwr_mode(int32_t mode);
	int32_t AD9253_select_channel_for_config(int32_t channel);
	int32_t AD9253_test_mode(int32_t mode);
	int32_t AD9253_offset_adj(int32_t adj);
	int32_t AD9253_output_disable(int32_t en);
	int32_t AD9253_output_invert(int32_t invert);
	int32_t AD9253_output_format(int32_t format);
	int32_t AD9253_reset_PN29(int32_t rst);
	int32_t AD9253_reset_PN23(int32_t rst);
	int32_t AD9253_set_user_pattern(int32_t patternNo, int32_t user_pattern);
	int32_t AD9253_bist_enable(int32_t enable);
	int32_t AD9253_bist_reset(int32_t reset);
	int32_t AD9253_jesd204b_setup(void);
	int32_t AD9253_jesd204b_pwr_mode(int32_t mode);
	int32_t AD9253_jesd204b_select_test_injection_point(int32_t injPoint);
	int32_t AD9253_jesd204b_test_mode(int32_t testMode);
	int32_t AD9253_jesd204b_invert_logic(int32_t invert);
	int32_t AD9253_fast_detect_setup(void);
	int32_t AD9253_dcc_enable(int32_t enable);
	int32_t AD9253_dcc_bandwidth(int32_t bw);
	int32_t AD9253_dcc_freeze(int32_t freeze);

	opencores_spi_driver* get_spi_driver() const {
		return spi_driver;
	}

	void set_spi_driver(opencores_spi_driver* spiDriver) {
		spi_driver = spiDriver;
	}

	unsigned long get_chipselect_index() const {
		return chipselect_index;
	}

	void set_chipselect_index(unsigned long chipselectIndex) {
		chipselect_index = chipselectIndex;
	}

};

#endif /* __AD9253_H__ */
