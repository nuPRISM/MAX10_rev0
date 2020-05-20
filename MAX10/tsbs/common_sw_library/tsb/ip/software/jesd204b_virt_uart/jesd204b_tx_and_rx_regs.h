/*
 * altera_jesd204_regs.h
 *
 *  Created on: Aug 20, 2014
 *      Author: rchow
 */

#ifndef __JESD204_TX_AND_RX_REGS_H__
#define __JESD204_TX_AND_RX_REGS_H__

// Tx reserved register - used for debug purposes
#define ALTERA_JESD204_TX_CTRL_REGISTER_RSVD_OFFSET                 (0x58)

// Tx - Rx Sync_n and Sysref control register
#define ALTERA_JESD204_SYNCN_SYSREF_CTRL_REG_OFFSET                 (0x54)
#define ALTERA_JESD204_SYNCN_SYSREF_CTRL_REG_REINIT_MASK            (0x1)

// Tx - Rx Link status registers
#define ALTERA_JESD204_TX_RX_STATUS0_REG_OFFSET                     (0x80)
#define ALTERA_JESD204_TX_RX_STATUS0_REG_SYNCN_MASK                 (0x1)
#define ALTERA_JESD204_TX_RX_STATUS0_REG_DLL_STATE_MASK             (0x6)
#define ALTERA_JESD204_TX_RX_STATUS0_REG_SYNCN_DEASSERT             (0x1)
#define ALTERA_JESD204_TX_RX_STATUS0_REG_USER_DATA_MODE             (0x4)

// Tx - Rx Test mode control register
#define ALTERA_JESD204_TX_RX_TEST_MODE_REG_OFFSET                   (0xD0)
#define ALTERA_JESD204_TX_RX_TEST_MODE_NO_TEST_MASK                 (0x0)
#define ALTERA_JESD204_TX_RX_TEST_MODE_ALT_MASK                     (0x8)
#define ALTERA_JESD204_TX_RX_TEST_MODE_RAMP_MASK                    (0x9)
#define ALTERA_JESD204_TX_RX_TEST_MODE_PRBS_MASK                    (0xA)

// RX Error 0 registers
#define ALTERA_JESD204_RX_ERR_STATUS_0_REG_OFFSET                   (0x60)
#define ALTERA_JESD204_RX_ERR_STATUS_0_REG_SYSREF_LMFC_ERROR        (0x2)
#define ALTERA_JESD204_RX_ERR_STATUS_0_REG_SYSREF_LMFC_MASK         (0x2)
#define ALTERA_JESD204_RX_ERR_STATUS_0_REG_DLL_DATA_RDY_ERROR       (0x4)
#define ALTERA_JESD204_RX_ERR_STATUS_0_REG_DLL_DATA_RDY_MASK        (0x4)
#define ALTERA_JESD204_RX_ERR_STATUS_0_REG_FRAME_DATA_RDY_ERROR	    (0x8)
#define ALTERA_JESD204_RX_ERR_STATUS_0_REG_FRAME_DATA_RDY_MASK      (0x8)
#define ALTERA_JESD204_RX_ERR_STATUS_0_REG_LANE_ALIGN_ERROR         (0x10)
#define ALTERA_JESD204_RX_ERR_STATUS_0_REG_LANE_ALIGN_MASK          (0x10)
#define ALTERA_JESD204_RX_ERR_STATUS_0_REG_RX_LOCKED_TO_DATA_ERROR  (0x20)
#define ALTERA_JESD204_RX_ERR_STATUS_0_REG_RX_LOCKED_TO_DATA_MASK   (0x20)
#define ALTERA_JESD204_RX_ERR_STATUS_0_REG_PCFIFO_FULL_ERROR        (0x40)
#define ALTERA_JESD204_RX_ERR_STATUS_0_REG_PCFIFO_FULL_MASK         (0x40)
#define ALTERA_JESD204_RX_ERR_STATUS_0_REG_PCFIFO_EMPTY_ERROR       (0x80)
#define ALTERA_JESD204_RX_ERR_STATUS_0_REG_PCFIFO_EMPTY_MASK        (0x80)
#define ALTERA_JESD204_RX_ERR_STATUS_0_CLEAR_ERROR_MASK             (0xFE)

// RX Error 1 registers
#define ALTERA_JESD204_RX_ERR_STATUS_1_REG_OFFSET                   (0x64)
#define ALTERA_JESD204_RX_ERR_STATUS_1_CGS_ERROR                    (0x1)
#define ALTERA_JESD204_RX_ERR_STATUS_1_CGS_MASK                     (0x1)
#define ALTERA_JESD204_RX_ERR_STATUS_1_FRAME_ALIGNMENT_ERROR        (0x2)
#define ALTERA_JESD204_RX_ERR_STATUS_1_FRAME_ALIGNMENT_MASK         (0x2)
#define ALTERA_JESD204_RX_ERR_STATUS_1_LANE_ALIGNMENT_ERROR         (0x4)
#define ALTERA_JESD204_RX_ERR_STATUS_1_LANE_ALIGNMENT_MASK          (0x4)
#define ALTERA_JESD204_RX_ERR_STATUS_1_UNEXP_K_CHAR_ERROR           (0x8)
#define ALTERA_JESD204_RX_ERR_STATUS_1_UNEXP_K_CHAR_MASK            (0x8)
#define ALTERA_JESD204_RX_ERR_STATUS_1_NOT_IN_TABLE_ERROR           (0x10)
#define ALTERA_JESD204_RX_ERR_STATUS_1_NOT_IN_TABLE_MASK            (0x10)
#define ALTERA_JESD204_RX_ERR_STATUS_1_DISPARITY_ERROR              (0x20)
#define ALTERA_JESD204_RX_ERR_STATUS_1_DISPARITY_MASK               (0x20)
#define ALTERA_JESD204_RX_ERR_STATUS_1_ILAS_ERROR                   (0x40)
#define ALTERA_JESD204_RX_ERR_STATUS_1_ILAS_MASK                    (0x40)
#define ALTERA_JESD204_RX_ERR_STATUS_1_DLL_RSVD_ERROR               (0x80)
#define ALTERA_JESD204_RX_ERR_STATUS_1_DLL_RSVD_MASK                (0x80)
#define ALTERA_JESD204_RX_ERR_STATUS_1_ECC_CORRECTED_ERROR          (0x100)
#define ALTERA_JESD204_RX_ERR_STATUS_1_ECC_CORRECTED_MASK           (0x100)
#define ALTERA_JESD204_RX_ERR_STATUS_1_ECC_FATAL_ERROR              (0x200)
#define ALTERA_JESD204_RX_ERR_STATUS_1_ECC_FATAL_MASK               (0x200)
#define ALTERA_JESD204_RX_ERR_STATUS_1_CLEAR_ERROR_MASK             (0x3FF)

// TX Error register
#define ALTERA_JESD204_TX_ERR_STATUS_REG_OFFSET                     (0x60)
#define ALTERA_JESD204_TX_ERR_STATUS_REG_SYNCN_ERROR                (0x1)
#define ALTERA_JESD204_TX_ERR_STATUS_REG_SYNCN_MASK                 (0x1)
#define ALTERA_JESD204_TX_ERR_STATUS_REG_SYSREF_LMFC_ERROR          (0x2)
#define ALTERA_JESD204_TX_ERR_STATUS_REG_SYSREF_LMFC_MASK           (0x2)
#define ALTERA_JESD204_TX_ERR_STATUS_REG_DLL_DATA_INVALID_ERROR     (0x4)
#define ALTERA_JESD204_TX_ERR_STATUS_REG_DLL_DATA_INVALID_MASK      (0x4)
#define ALTERA_JESD204_TX_ERR_STATUS_REG_FRAME_DATA_INVALID_ERROR   (0x8)
#define ALTERA_JESD204_TX_ERR_STATUS_REG_FRAME_DATA_INVALID_MASK    (0x8)
#define ALTERA_JESD204_TX_ERR_STATUS_REG_SYNCN_REINIT_REQ_ERROR     (0x10)
#define ALTERA_JESD204_TX_ERR_STATUS_REG_SYNCN_REINIT_REQ_MASK      (0x10)
#define ALTERA_JESD204_TX_ERR_STATUS_REG_PLL_LOCKED_ERROR           (0x20)
#define ALTERA_JESD204_TX_ERR_STATUS_REG_PLL_LOCKED_MASK            (0x20)
#define ALTERA_JESD204_TX_ERR_STATUS_REG_PCFIFO_FULL_ERROR          (0x40)
#define ALTERA_JESD204_TX_ERR_STATUS_REG_PCFIFO_FULL_MASK           (0x40)
#define ALTERA_JESD204_TX_ERR_STATUS_REG_PCFIFO_EMPTY_ERROR         (0x80)
#define ALTERA_JESD204_TX_ERR_STATUS_REG_PCFIFO_EMPTY_MASK          (0x80)
#define ALTERA_JESD204_TX_ERR_STATUS_CLEAR_ERROR_MASK               (0xFF)

// Tx Error Enable register
#define ALTERA_JESD204_TX_ERR_EN_REG_OFFSET                         (0x64)
#define ALTERA_JESD204_TX_ERR_EN_REG_SYNCN_REINIT_REQ_EN_MASK       (0x10)
#define ALTERA_JESD204_TX_ERR_EN_REG_XCVR_PLL_LOCKED_ERR_EN_MASK    (0x20)
#define ALTERA_JESD204_TX_ERR_EN_REG_PCFIFO_FULL_ERR_EN_MASK        (0x40)
#define ALTERA_JESD204_TX_ERR_EN_REG_PCFIFO_EMPTY_ERR_EN_MASK       (0x80)
#define ALTERA_JESD204_TX_ERR_EN_REG_ALL_ERR_EN_MASK                (0xFF)

// Rx Error Enable register
#define ALTERA_JESD204_RX_ERR_EN_REG_OFFSET                         (0x74)
#define ALTERA_JESD204_RX_ERR_EN_REG_RX_LOCKED_TO_DATA_ERR_EN_MASK  (0x20)
#define ALTERA_JESD204_RX_ERR_EN_REG_PCFIFO_FULL_ERR_EN_MASK        (0x40)
#define ALTERA_JESD204_RX_ERR_EN_REG_PCFIFO_EMPTY_ERR_EN_MASK       (0x80)
#define ALTERA_JESD204_RX_ERR_EN_REG_ALL_ERR_EN_MASK                (0x1FF8FE)

// Tx - Rx ILAS Data 1 registers
#define ALTERA_JESD204_TX_RX_ILAS_DATA1_REG_OFFSET                  (0x94)
#define ALTERA_JESD204_TX_RX_L_VAL_MASK                             (0x1F)
#define ALTERA_JESD204_TX_RX_SCR_VAL_MASK                           (0x80)
#define ALTERA_JESD204_TX_RX_F_VAL_MASK                             (0xFF00)
#define ALTERA_JESD204_TX_RX_K_VAL_MASK                             (0X1F0000)
#define ALTERA_JESD204_TX_RX_M_VAL_MASK                             (0xFF000000)
#define ALTERA_JESD204_TX_RX_SCR_VAL_POS                            7
#define ALTERA_JESD204_TX_RX_F_VAL_POS                              8
#define ALTERA_JESD204_TX_RX_K_VAL_POS                              16
#define ALTERA_JESD204_TX_RX_M_VAL_POS                              24

// Tx - Rx ILAS Data 2 registers
#define ALTERA_JESD204_TX_RX_ILAS_DATA2_REG_OFFSET                  (0x98)
#define ALTERA_JESD204_TX_RX_N_VAL_MASK                             (0x1F)
#define ALTERA_JESD204_TX_RX_CS_VAL_MASK                            (0xC0)
#define ALTERA_JESD204_TX_RX_NP_VAL_MASK                            (0x1F00)
#define ALTERA_JESD204_TX_RX_SUB_VAL_MASK                           (0xE000)
#define ALTERA_JESD204_TX_RX_S_VAL_MASK                             (0x1F0000)
#define ALTERA_JESD204_TX_RX_HD_VAL_MASK                            (0x80000000)
#define ALTERA_JESD204_TX_RX_CS_VAL_POS                             6
#define ALTERA_JESD204_TX_RX_NP_VAL_POS                             8
#define ALTERA_JESD204_TX_RX_SUB_VAL_POS                            13
#define ALTERA_JESD204_TX_RX_S_VAL_POS                              16
#define ALTERA_JESD204_TX_RX_HD_VAL_POS                             31

// Tx - Rx ILAS Data 12 registers
#define ALTERA_JESD204_TX_RX_ILAS_DATA12_REG_OFFSET                 (0xC0)
#define ALTERA_JESD204_TX_RX_FXK_VAL_MASK                           (0x3FF)

// Tx - Lane control registers
#define ALTERA_JESD204_TX_RX_LANE_CTRL_0_OFFSET                     0x4
#define ALTERA_JESD204_TX_RX_LANE_CTRL_1_OFFSET                     0x8
#define ALTERA_JESD204_TX_RX_LANE_CTRL_2_OFFSET                     0xC
#define ALTERA_JESD204_TX_RX_LANE_CTRL_3_OFFSET                     0x10
#define ALTERA_JESD204_TX_RX_LANE_CTRL_4_OFFSET                     0x14
#define ALTERA_JESD204_TX_RX_LANE_CTRL_5_OFFSET                     0x18
#define ALTERA_JESD204_TX_RX_LANE_CTRL_6_OFFSET                     0x1C
#define ALTERA_JESD204_TX_RX_LANE_CTRL_7_OFFSET                     0x20
#define ALTERA_JESD204_TX_RX_LANE_CTRL_MASK                         0x2
#define ALTERA_JESD204_TX_RX_LANE_CTRL_POS                          1

// Tx - DLL control registers
#define ALTERA_JESD204_TX_DLL_CTRL_REG_OFFSET                       (0x50)
#define ALTERA_JESD204_CSR_RXSYNC_RISE_MASK                         0x800

//Define reset sequencer offsets
#define ALTERA_RESET_SEQUENCER_STATUS_REG_OFFSET                    (0x00)
#define ALTERA_RESET_SEQUENCER_CONTROL_REG_OFFSET                   (0x08)
#define ALTERA_RESET_SEQUENCER_SW_DIRECT_CONTROLLED_RESETS_OFFSET   (0x14)
#define ALTERA_RESET_SEQUENCER_RESET_ACTIVE_MASK                    (0x80000000)
#define ALTERA_RESET_SEQUENCER_RESET_ACTIVE_ASSERT                  (0x80000000)

//Define PIO Control Masks
#define ALTERA_PIO_CONTROL_RX_SERIALLPBKEN_0_MASK                   (0x1)
#define ALTERA_PIO_CONTROL_SYSREF_MASK                              (0x80000000)
#define ALTERA_PIO_CONTROL_HARD_RESET_MASK                          (0x40000000)
#define ALTERA_PIO_CONTROL_SYNC_N_ASSERT_MASK                       (0x20000000)

//Define PIO Status Masks
#define ALTERA_PIO_STATUS_CORE_PLL_LOCKED_MASK                      (0x1)
#define ALTERA_PIO_STATUS_CORE_PLL_LOCKED_ASSERT                    (0x1)
#define ALTERA_PIO_STATUS_ALL_TX_READY_0_MASK                       (0x2)
#define ALTERA_PIO_STATUS_ALL_TX_READY_0_ASSERT                     (0x2)
#define ALTERA_PIO_STATUS_ALL_RX_READY_0_MASK                       (0x4)
#define ALTERA_PIO_STATUS_ALL_RX_READY_0_ASSERT                     (0x4)
#define ALTERA_PIO_STATUS_PATCHK_ERROR_0_MASK                       (0x8)
#define ALTERA_PIO_STATUS_PATCHK_ERROR_0_ASSERT                     (0x8)

//Define core PLL reconfig offsets
#define ALTERA_CORE_PLL_RECONFIG_START_REGISTER_OFFSET              (0x0)
#define ALTERA_CORE_PLL_RECONFIG_C0_COUNTER_OFFSET                  (0xC0)
#define ALTERA_CORE_PLL_RECONFIG_C1_COUNTER_OFFSET                  (0xC1)
#define ALTERA_CORE_PLL_RECONFIG_C_COUNTER_LO_MASK                  (0xFF)
#define ALTERA_CORE_PLL_RECONFIG_C_COUNTER_HI_MASK                  (0xFF00)
#define ALTERA_CORE_PLL_RECONFIG_C_COUNTER_HI_POS                   8

#endif /* __ALTERA_JESD204_REGS_H__ */
