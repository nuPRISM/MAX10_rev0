/* lld.c - Source Code for HyperFlash Low Level Driver */
/**************************************************************************
* Copyright (C)2017 Synaptic Laboratories Limited. All Rights Reserved . 
*
* This software is owned and published by: 
* Synaptic Laboratories Limited (S/Labs).
*
* BY DOWNLOADING, INSTALLING OR USING THIS SOFTWARE, YOU AGREE TO BE BOUND 
* BY ALL THE TERMS AND CONDITIONS OF THIS AGREEMENT.
*
* This software constitutes driver source code for use in programming HyperFLash 
* memory components. This software is licensed by S/Labs to be adapted only 
* for use in systems utilizing Cypress's Flash memories. S/Labs is not be 
* responsible for misuse or illegal use of this software for devices not 
* supported herein.  S/Labs is providing this source code "AS IS" and will 
* not be responsible for issues arising from incorrect user implementation 
* of the source code herein.  
*
* S/Labs MAKES NO WARRANTY, EXPRESS OR IMPLIED, ARISING BY LAW OR OTHERWISE, 
* REGARDING THE SOFTWARE, ITS PERFORMANCE OR SUITABILITY FOR YOUR INTENDED 
* USE, INCLUDING, WITHOUT LIMITATION, NO IMPLIED WARRANTY OF MERCHANTABILITY, 
* FITNESS FOR A  PARTICULAR PURPOSE OR USE, OR NONINFRINGEMENT.  CYPRESS WILL 
* HAVE NO LIABILITY (WHETHER IN CONTRACT, WARRANTY, TORT, NEGLIGENCE OR 
* OTHERWISE) FOR ANY DAMAGES ARISING FROM USE OR INABILITY TO USE THE SOFTWARE, 
* INCLUDING, WITHOUT LIMITATION, ANY DIRECT, INDIRECT, INCIDENTAL, 
* SPECIAL, OR CONSEQUENTIAL DAMAGES OR LOSS OF DATA, SAVINGS OR PROFITS, 
* EVEN IF CYPRESS HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.  
*
* This software may be replicated in part or whole for the licensed use, 
* with the restriction that this Copyright notice must be included with 
* this software, whether used in part or whole, at all times.  
*/

#ifndef __INC_H_SLL_lldh
#define __INC_H_SLL_lldh

//delay altera delay

#ifdef __cplusplus
 extern "C" {
#endif /* __cplusplus */

 
#include "io.h"
#include <stdio.h>
#include <stdint.h>
 
/* boolean macros */
#ifndef TRUE  // LLD_KEEP
 #define TRUE  (1)
#endif      // LLD_KEEP
#ifndef FALSE // LLD_KEEP
 #define FALSE (0)
#endif      // LLD_KEEP

#define SA_OFFSET_MASK	0xFFFE0000   /* mask off the offset */

/* LLD Command Definition */
#define NOR_ERASE_SETUP_CMD              (0x80)
#define NOR_RESET_CMD                    (0xF0)
#define NOR_SECSI_SECTOR_ENTRY_CMD       (0x88)
#define NOR_SECTOR_ERASE_CMD             (0x30)
#define NOR_WRITE_BUFFER_LOAD_CMD        (0x25)
#define NOR_WRITE_BUFFER_PGM_CONFIRM_CMD (0x29) 
                                         
#define NOR_ERASE_SUSPEND_CMD            (0xB0)
#define NOR_ERASE_RESUME_CMD             (0x30)
#define NOR_PROGRAM_SUSPEND_CMD          (0x51)
#define NOR_PROGRAM_RESUME_CMD           (0x50)
#define NOR_STATUS_REG_READ_CMD          (0x70)
#define NOR_STATUS_REG_CLEAR_CMD         (0x71)
#define NOR_BLANK_CHECK_CMD              (0x33)

/* Command code definition */
#define NOR_UNLOCK_DATA1                 (0xAA)
#define NOR_UNLOCK_DATA2                 (0x55)


/* polling routine options */
typedef enum
{
LLD_P_POLL_NONE = 0,      /* pull program status */
LLD_P_POLL_PGM,           /* pull program status */
LLD_P_POLL_WRT_BUF_PGM,     /* Poll write buffer   */
LLD_P_POLL_SEC_ERS,         /* Poll sector erase   */
LLD_P_POLL_CHIP_ERS,      /* Poll chip erase     */
LLD_P_POLL_RESUME,
LLD_P_POLL_BLANK          /* Poll device sector blank check */
}POLLING_TYPE;

/* polling return status */
typedef enum {
 DEV_STATUS_UNKNOWN = 0,
 DEV_NOT_BUSY,
 DEV_BUSY,
 DEV_EXCEEDED_TIME_LIMITS,
 DEV_SUSPEND,
 DEV_WRITE_BUFFER_ABORT,
 DEV_STATUS_GET_PROBLEM,
 DEV_VERIFY_ERROR,
 DEV_BYTES_PER_OP_WRONG,
 DEV_ERASE_ERROR,       
 DEV_PROGRAM_ERROR,       
 DEV_SECTOR_LOCK,
 DEV_PROGRAM_SUSPEND,     /* Device is in program suspend mode */
 DEV_PROGRAM_SUSPEND_ERROR,   /* Device program suspend error */
 DEV_ERASE_SUSPEND,       /* Device is in erase suspend mode */
 DEV_ERASE_SUSPEND_ERROR,   /* Device erase suspend error */
 DEV_BUSY_IN_OTHER_BANK,     /* Busy operation in other bank */
 DEV_CONTINUITY_CHECK_PATTERN_ERROR, /*Continuity Check error, detected continuity pattern as unexpected */
 DEV_CONTINUITY_CHECK_NO_PATTERN_ERROR, /* Continuity Check error, no detected continuity pattern as unexpected */
 DEV_CONTINUITY_CHECK_PATTERN_DETECTED /* Continuity Check successfully and pattern detected */
} DEVSTATUS;


#define DEV_RDY_MASK          (0x80) /* Device Ready Bit */
#define DEV_ERASE_MASK        (0x20) /* Erase Status Bit */
#define DEV_PROGRAM_MASK      (0x10) /* Program Status Bit */
#define DEV_SEC_LOCK_MASK     (0x02) /* Sector lock Bit */

/*****************************************************
* Define Flash read/write macro to be used by LLD    *
*****************************************************/
#define FLASH_WR(b,o,d)    IOWR_16DIRECT(b, ((o)<<1), d)
#define FLASH_RD(b,o)      IORD_16DIRECT(b, ((o)<<1))


#define LLD_DEV_READ_MASK    0x0000FFFF
#define LLD_UNLOCK_ADDR1     0x00000555
#define LLD_UNLOCK_ADDR2     0x000002AA
#define LLD_BYTES_PER_OP     0x00000002
#define LLD_CFI_UNLOCK_ADDR1 0x00000055


/* public function prototypes */

/* Operation Functions */


extern DEVSTATUS sll_lld_WriteBufferProgramOp
(
uint32_t * base_addr,      /* device base address is system */
uint32_t offset,         /* address offset from base address */
uint32_t word_cnt,       /* number of words to program */
uint8_t *data_buf       /* buffer containing data to program */
);



extern DEVSTATUS sll_lld_SectorEraseOp
(
uint32_t * base_addr,      /* device base address is system */
uint32_t offset          /* address offset from base address */
);



DEVSTATUS sll_lld_memcpy
(
uint32_t * base_addr,      /* device base address is system */
uint32_t offset,         /* address offset from base address */
uint32_t words_cnt,      /* number of words to program */
uint8_t *data_buf       /* buffer containing data to program */
);


extern uint16_t sll_lld_Poll
(
uint32_t * base_addr,      /* device base address in system */
uint32_t offset          /* address offset from base address */
);


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __INC_H_SLL_lldh  */


