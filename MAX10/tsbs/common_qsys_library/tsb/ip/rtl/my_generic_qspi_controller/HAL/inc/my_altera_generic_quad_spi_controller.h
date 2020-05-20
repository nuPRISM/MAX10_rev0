/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2015 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
*                                                                             *
******************************************************************************/

#ifndef __MY_ALT_QSPI_CONTROLLER_H__
#define __MY_ALT_QSPI_CONTROLLER_H__

#include "alt_types.h"
#include "sys/alt_flash_dev.h"
#include "sys/alt_llist.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

/**
 *  Description of the QSPI controller
 */
typedef struct my_alt_qspi_controller_dev
{
    alt_flash_dev dev;

    alt_u32 data_base; /** base address of data slave */
    alt_u32 data_end; /** end address of data slave (not inclusive) */
    alt_u32 csr_base; /** base address of CSR slave */
    alt_u32 size_in_bytes; /** size of memory in bytes */
    alt_u32 is_epcs; /** 1 if device is an EPCS device */
    alt_u32 number_of_sectors; /** number of flash sectors */
    alt_u32 sector_size; /** size of each flash sector */
    alt_u32 page_size; /** page size */
    alt_u32 silicon_id; /** ID of silicon used with EPCQ/QSPI IP */
    alt_u32 allow_override_from_actual_device; /** 1 if allow override of parameters of this structure if device encountered in practice differs from what QSPI was generated with */
} my_alt_qspi_controller_dev;

/**
*   Macros used by alt_sys_init.c to create data storage for driver instance
*/
#define MY_ALTERA_GENERIC_QUAD_SPI_CONTROLLER_AVL_MEM_AVL_CSR_INSTANCE(qspi_name, avl_mem, avl_csr, qspi_dev) \
static my_alt_qspi_controller_dev qspi_dev =                                                       \
{                                                                                               \
  .dev = {                                                                                      \
            .llist = ALT_LLIST_ENTRY,                                                           \
            .name = avl_mem##_NAME,                                                             \
            .write = my_alt_qspi_controller_write,                                                 \
            .read = my_alt_qspi_controller_read,                                                   \
            .get_info = my_alt_qspi_controller_get_info,                                           \
            .erase_block = my_alt_qspi_controller_erase_block,                                     \
            .write_block = my_alt_qspi_controller_write_block,                                     \
            .base_addr = ((void*)(avl_mem##_BASE)),                                             \
            .length = ((int)(avl_mem##_SPAN)),                                                  \
            .lock = my_alt_qspi_controller_lock ,                                                  \
         },                                                                                     \
  .data_base = ((alt_u32)(avl_mem##_BASE)),   							\
  .data_end = ((alt_u32)(avl_mem##_BASE) + (alt_u32)(avl_mem##_SPAN)),	                        \
  .csr_base = ((alt_u32)(avl_csr##_BASE)),   							\
  .size_in_bytes = ((alt_u32)(avl_mem##_SPAN)),         				        \
  .is_epcs = ((alt_u32)(avl_mem##_IS_EPCS)),							\
  .number_of_sectors = ((alt_u32)(avl_mem##_NUMBER_OF_SECTORS)),			        \
  .sector_size = ((alt_u32)(avl_mem##_SECTOR_SIZE)),						\
  .page_size = ((alt_u32)(avl_mem##_PAGE_SIZE))	,						\
  .allow_override_from_actual_device = ((alt_u32)(avl_mem##_ALLOW_OVERWRITE))	,						\
}

/*
    Public API

    Refer to Using Flash Devices in the
    Developing Programs Using the Hardware Abstraction Layer chapter
    of the Nios II Software Developer's Handbook.

*/
int my_alt_qspi_controller_read(alt_flash_dev *flash_info, int offset, void *dest_addr, int length);

int my_alt_qspi_controller_get_info(alt_flash_fd *fd, flash_region **info, int *number_of_regions);

int my_alt_qspi_controller_erase_block(alt_flash_dev *flash_info, int block_offset);

int my_alt_qspi_controller_write_block(alt_flash_dev *flash_info, int block_offset, int data_offset, const void *data, int length);

int my_alt_qspi_controller_write(alt_flash_dev *flash_info, int offset, const void *src_addr, int length);

int my_alt_qspi_controller_lock(alt_flash_dev *flash_info, alt_u32 sectors_to_lock);


/*
 * Initialization function
 */
extern alt_32 my_altera_qspi_controller_init(my_alt_qspi_controller_dev *dev);

/*
 * alt_sys_init.c will call this macro automatically initialize the driver instance
 */
#define MY_ALTERA_GENERIC_QUAD_SPI_CONTROLLER_INIT(name, dev) 	\
		my_altera_qspi_controller_init(&dev);


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ALT_QSPI_CONTROLLER_H__ */
