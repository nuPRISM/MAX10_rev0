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


#include <errno.h>
#include <io.h>
#include <string.h>
#include <stddef.h>
#include "sys/param.h"
#include "alt_types.h"
#include "sll_memory_region_bridge.h"
#include "priv/alt_busy_sleep.h"
#include "sys/alt_debug.h"
#include "sys/alt_cache.h"


/**
 * sll_hyperflash_get_info
 *
 * Pass the table of erase blocks to the user. This flash will return a single
 * flash_region that gives the number and size of sectors for the device used.
 *
 * Arguments:
 * - *fd: Pointer to general flash device structure.
 * - **info: Pointer to flash region
 * - *number_of_regions: Pointer to number of regions
 *
 * For details of setting sectors protection, please refer to EPCQ datasheet.
 *  
 * Returns:
 * 0 -> success
 * -EINVAL -> Invalid arguments
 * -EIO -> Could be hardware problem.
**/
int sll_hyperflash_get_info
(
    alt_flash_fd *fd, /** flash device descriptor */
    flash_region **info, /** pointer to flash_region will be stored here */
    int *number_of_regions /** number of regions will be stored here */
)
{
	alt_flash_dev* flash = NULL;

	
	/* return -EINVAL if fd,info and number_of_regions are NULL */
	if(NULL == fd || NULL == info || NULL == number_of_regions)
    {
    	return -EINVAL;
    }

    flash = (alt_flash_dev*)fd;

    *number_of_regions = flash->number_of_regions;

    if (!flash->number_of_regions)
    {
      return -EIO;
    }
    else
    {
      *info = &flash->region_info[0];
    }

    return 0;
}


/**
 * sll_memory_region_bridge_init
 *
 * alt_sys_init.c will call this function automatically through macro
 *
 * Information in system.h is checked against expected values that are determined by the silicon_id.
 * If the information doesn't match then this system is configured incorrectly. 
 *
 * Arguments:
 * - *flash: Pointer to HyperFlash device structure.
 *
 * Returns:
 * 0 -> success
 * -EINVAL -> Invalid arguments.
 * -ENODEV -> System is configured incorrectly.
**/
alt_32 sll_memory_region_bridge_init(sll_hyperflash_dev *flash)
{
	alt_u32 size_in_bytes     = 0;


	/* Calculate size of flash based on number of sectors */
	size_in_bytes = flash->number_of_sectors * flash->sector_size;

	/*
	 * Make sure calculated size is the same size given in system.h
	 */
	if(	size_in_bytes != flash->size_in_bytes)
	{
		flash->dev.number_of_regions = 0;
		return -ENODEV;
	}
	else
	{
		/*
		 * populate fields of region_info required to conform to HAL API
		 * create 1 region that composed of "number_of_sectors" blocks
		 */
		flash->dev.number_of_regions     = 1;
		flash->dev.region_info[0].offset = 0;
		flash->dev.region_info[0].region_size      = size_in_bytes;
		flash->dev.region_info[0].number_of_blocks = flash->number_of_sectors;
		flash->dev.region_info[0].block_size       = flash->sector_size;
	}
  
    /*
     * Register this device as a valid flash device type
     *
     * Only register the device if it's configured correctly.
     */
		alt_flash_device_register(&(flash->dev));


    return 0;
}

/**
 * sll_hyperflash_read
 *
 * There's no real need to use this function as opposed to using memcpy directly. It does
 * do some sanity checks on the bounds of the read.
 *
 * Arguments:
 * - *flash_info: Pointer to general flash device structure.
 * - offset: offset read from flash memory.
 * - *dest_addr: destination buffer
 * - length: size of reading
 *
 * Returns:
 * 0 -> success 
 * -EINVAL -> Invalid arguments
**/
int sll_hyperflash_read
(
    alt_flash_dev *flash_info, /** device info */
    int offset,                /** offset of read from base address */
    void *dest_addr,           /** destination buffer */
    int length                 /** size of read */
) 
{
 
    int ret_code = 0; 
    sll_hyperflash_dev* hyperflash_info = (sll_hyperflash_dev*)flash_info;

    /* Make sure the input parameters is not outside of this device's range. */
    if ((offset >= hyperflash_info->dev.length) || ((offset+length) > hyperflash_info->dev.length)) {
        return -EFAULT;
    }
    
    memcpy(dest_addr, (alt_u8*)hyperflash_info->dev.base_addr+offset, length);
    
    return ret_code;
}



/**
  * HyperFLash_erase_block
  *
  * This function erases a single flash sector.
  *
  * Arguments:
  * - *flash_info: Pointer to HyperFlash device structure.
  * - block_offset: byte-addressed offset, from start of flash, of the sector to be erased
  *  
  * Returns:
  * 0 -> success
  * -EINVAL -> Invalid arguments
  * -EIO -> write failed, sector might be protected 
**/
int sll_hyperflash_erase_block(alt_flash_dev *flash_info, int block_offset)
{
    DEVSTATUS dev_status     = 0;
    
    sll_hyperflash_dev *hyperflash_info = NULL;

    /* return -EINVAL if flash_info is NULL */
    if(NULL == flash_info)
    {
    	return -EINVAL;
    }
	
    hyperflash_info = (sll_hyperflash_dev*)flash_info;

    /* 
     * Sanity checks that block_offset is within the flash memory span and that the 
     * block offset is sector aligned.
     *
     */
    if((block_offset < 0) 
        || (block_offset >= hyperflash_info->size_in_bytes)
        || (block_offset & (hyperflash_info->sector_size - 1)) != 0)
    {
    	return -EINVAL;
    }

   
      
    dev_status = sll_lld_SectorEraseOp(hyperflash_info->data_base, block_offset);
    
    if( dev_status == DEV_SECTOR_LOCK ) {
      	return -EACCES; /* sector locked */
    }  	
    
    if( dev_status == DEV_ERASE_ERROR ) {
      	return -EIO;  /* erase error */
    }  	
        
    return 0;
}


/**
 * HyperFLash_write_block
 *
 * This function writes one block/sector of data to flash. The length of the write can NOT 
 * spill into the adjacent sector.
 *
 * It assumes that someone has already erased the appropriate sector(s).
 *
 * Arguments:
 * - *flash_info: Pointer to HyperFlash device structure.
 * - block_offset: byte-addressed offset, from the start of flash, of the sector to written to
 * - data-offset: Byte offset (unaligned access) of write into flash memory. 
 *                For best performance, word(32 bits - aligned access) offset of write is recommended.
 * - *src_addr: source buffer
 * - length: size of writing
 *  
 * Returns:
 * 0 -> success
 * -EINVAL -> Invalid arguments
 * -EIO -> write failed, sector might be protected 
**/
int sll_hyperflash_write_block
(
    alt_flash_dev *flash_info, /** flash device info */
    int block_offset, /** sector/block offset in byte addressing */
    int data_offset, /** offset of write from base address */
    const void *data, /** data to be written */
    int length /** bytes of data to be written, >0 */
)
{

    DEVSTATUS dev_status     = 0;

    sll_hyperflash_dev *hyperflash_info = (sll_hyperflash_dev*)flash_info;
	
    /* 
     * Sanity checks that data offset is not larger then a sector, that block offset is 
     * sector aligned and within the valid flash memory range and a write doesn't spill into 
     * the adjacent flash sector.
     */
    if(block_offset < 0
        || data_offset < 0
        || NULL == flash_info
        || NULL == data
        || data_offset  >= hyperflash_info->size_in_bytes
        || block_offset >= hyperflash_info->size_in_bytes
        || length > (hyperflash_info->sector_size - (data_offset - block_offset))
        || length < 0
        || (block_offset & (hyperflash_info->sector_size - 1)) != 0) 
    {
    	return -EINVAL;
    }
    
    dev_status = sll_lld_memcpy(hyperflash_info->data_base, data_offset, length, data);

    
    if (dev_status!=DEV_NOT_BUSY )   
      return( EIO );    /* program error */


    return 0;
}

/**
 * HyperFLash_write
 *
 * Program the data into the flash at the selected address.
 *
 * The different between this function and HyperFLash_write_block function
 * is that this function (HyperFLash_write) will automatically erase a block as needed
 * Arguments:
 * - *flash_info: Pointer to HyperFlash device structure.
 * - offset: Byte offset (unaligned access) of write to flash memory. For best performance, 
 *           word(32 bits - aligned access) offset of write is recommended.
 * - *src_addr: source buffer
 * - length: size of writing
 *  
 * Returns:
 * 0 -> success
 * -EINVAL -> Invalid arguments
 * -EIO -> write failed, sector might be protected 
 *
**/
int sll_hyperflash_write(
    alt_flash_dev *flash_info, /** device info */
    int offset, /** offset of write from base address */
    const void *src_addr, /** source buffer */
    int length /** size of writing */
)
{
    alt_32 ret_code = 0;
    alt_32 full_length = length;
    alt_32 start_offset = offset;

    sll_hyperflash_dev *hyperflash_info = NULL;

    alt_u32 write_offset     = offset; /** address of next byte to write */
    alt_u32 remaining_length = length; /** length of write data left to be written */
    alt_u32 buffer_offset    = 0;      /** offset into source buffer to get write data */
    alt_u32 i = 0;

    /* return -EINVAL if flash_info and src_addr are NULL */
	if(NULL == flash_info || NULL == src_addr || length == 0)
    {
    	return -EINVAL;
    }
	
 	  hyperflash_info = (sll_hyperflash_dev*)flash_info;

    /* Make sure the input parameters is not outside of this device's range. */
    if ((offset >= hyperflash_info->dev.length) || ((offset+length) > hyperflash_info->dev.length)) {
        return -EFAULT;
    }
	
    /*
     * This loop erases and writes data one sector at a time. We check for write completion 
     * before starting the next sector.
     */
    for(i = offset/hyperflash_info->sector_size ; i < hyperflash_info->number_of_sectors; i++)
    {
        alt_u32 block_offset                 = 0; /** block offset in byte addressing */
    	  alt_u32 offset_within_current_sector = 0; /** offset into current sector to write */
        alt_u32 length_to_write              = 0; /** length to write to current sector */

    	if(0 >= remaining_length)
    	{
    		break; /* out of data to write */
    	}

        /* calculate current sector/block offset in byte addressing */
        block_offset = write_offset & ~(hyperflash_info->sector_size - 1);
           
        /* calculate offset into sector/block if there is one */
        if(block_offset != write_offset)
        {
            offset_within_current_sector = write_offset - block_offset;
        }

        /* erase sector */
        ret_code = sll_hyperflash_erase_block(flash_info, block_offset);

        if(0 != ret_code)
        {
            return ret_code;
        }

        /* calculate the byte size of data to be written in a sector */
        length_to_write = MIN(hyperflash_info->sector_size - offset_within_current_sector, 
                remaining_length);

        /* write data to erased block */
        ret_code = sll_hyperflash_write_block(flash_info, block_offset, write_offset,
            src_addr + buffer_offset, length_to_write);


        if(0 != ret_code)
        {
            return ret_code;
        }

        /* update remaining length and buffer_offset pointer */
        remaining_length -= length_to_write;
        buffer_offset    += length_to_write;
        write_offset     += length_to_write; 
    }

finished:
    alt_dcache_flush((alt_u8*)hyperflash_info->dev.base_addr+start_offset, full_length);

    return ret_code;
}








