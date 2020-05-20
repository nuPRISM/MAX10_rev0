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

#ifndef __SLL_HYPERFLASH_PROGRAM_H__
#define __SLL_HYPERFLASH_PROGRAM_H__

#include "alt_types.h"
#include "sys/alt_flash_dev.h"
#include "sys/alt_llist.h"

#include "sll_lld_S26KSxxxS_S26KLxxxS.h"


#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

/**
 *  Description of the EPCQ controller
 */
typedef struct sll_hyperflash_dev
{
    /* Flash common declaration */
    alt_flash_dev dev;

    /* IP specific information */
    void  *csr_base;
    alt_u32 data_base; /** base address of data slave */
    alt_u32 data_end; /** end address of data slave (not inclusive) */
    alt_u32 size_in_bytes; /** size of memory in bytes */
    alt_u32 number_of_sectors; /** number of flash sectors */
    alt_u32 sector_size; /** size of each flash sector */
    alt_u32 page_size; /** page size */

} sll_hyperflash_dev;


/**
*   Macros used by alt_sys_init.c to create data storage for driver instance
*/

#define SLL_MEMORY_REGION_BRIDGE_IAVSF_INSTANCE(name, avl_mem,  dev) \
static sll_hyperflash_dev dev =                \
{                                                       \
  {                               \
    ALT_LLIST_ENTRY,              \
    avl_mem##_NAME,               \
    NULL,                         \
    NULL,                         \
    sll_hyperflash_write,         \
    sll_hyperflash_read,          \
    sll_hyperflash_get_info,      \
    sll_hyperflash_erase_block,   \
    sll_hyperflash_write_block,   \
    ((void*)(avl_mem##_BASE)),    \
    ((int)(avl_mem##_SPAN)),      \
    0                          \
  },                           \
  ((void*)(avl_mem##_BASE)),      \
  .data_base = ((alt_u32)(avl_mem##_BASE)),                 \
  .data_end = ((alt_u32)(avl_mem##_BASE) + (alt_u32)(avl_mem##_SPAN)), \
  .size_in_bytes = ((alt_u32)(avl_mem##_SIZE)),                     \
  .number_of_sectors = ((alt_u32)(avl_mem##_NUMBER_OF_SECTORS)),    \
  .sector_size = ((alt_u32)(avl_mem##_SECTOR_SIZE)),                \
  .page_size = ((alt_u32)(avl_mem##_PAGE_SIZE))            \
}


/*
    Public API

    Refer to Using Flash Devices in the
    Developing Programs Using the Hardware Abstraction Layer chapter
    of the Nios II Software Developer's Handbook.

*/

int sll_hyperflash_read(alt_flash_dev *flash_info, int offset, void *dest_addr, int length);

int sll_hyperflash_get_info(alt_flash_fd *fd, flash_region **info, int *number_of_regions);

int sll_hyperflash_erase_block(alt_flash_dev *flash_info, int block_offset);

int sll_hyperflash_write_block(alt_flash_dev *flash_info, int block_offset, int data_offset, const void *data, int length);

int sll_hyperflash_write(alt_flash_dev *flash_info, int offset, const void *src_addr, int length);


/*
 * Initialization function
 */
extern alt_32 sll_memory_region_bridge_init(sll_hyperflash_dev *dev);

/*
 * alt_sys_init.c will call this macro automatically initialize the driver instance
 */
 #define SLL_MEMORY_REGION_BRIDGE_INIT(name, dev) { sll_memory_region_bridge_init(&dev); }
 
/*
	Private API

	Helper functions used by Public API functions.
*/


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __SLL_HYPERFLASH_PROGRAM_H__ */
