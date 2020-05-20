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

#include "sll_lld_S26KSxxxS_S26KLxxxS.h"

#define LLD_BUFFER_SIZE (512)


/* private functions */

/* Public Functions  */

/******************************************************************************
* 
* sll_lld_Poll - Polls flash device for embedded operation completion
*
*  Function polls the Flash device to determine when an embedded
*  operation has finished - bit 7 is 1.  
*
* RETURNS: value of status register
*
*/
uint16_t sll_lld_Poll
(
uint32_t * base_addr,          /* device base address in system */
uint32_t offset                 /* address offset from base address */
)
{       
  unsigned long polling_counter = 0xFFFFFFFF;
  volatile uint16_t status_reg;

  do
  {
    polling_counter--;

    FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_STATUS_REG_READ_CMD);   /* Issue status register read command */

    status_reg = FLASH_RD(base_addr, offset);       /* read the status register */
    if( (status_reg & DEV_RDY_MASK) == DEV_RDY_MASK  )  /* Are all devices done bit 7 is 1 */
      break;

  }while(polling_counter);
  
  return( status_reg );          /* retrun the status reg. */
}



/******************************************************************************
* 
* sll_lld_SectorEraseOp - Performs a Sector Erase Operation
*
* Function erases the sector containing <base_addr> + <offset>.
* Function issues all required commands and polls for completion.
*
*
* RETURNS: DEVSTATUS
*
* ERRNO: 
*/

DEVSTATUS sll_lld_SectorEraseOp
(
uint32_t * base_addr,    /* device base address is system */
uint32_t offset        /* address offset from base address */
)
{
  uint16_t         status_reg;
  uint32_t          offset_16;
  
// Note: adress offset is translated to 16-bit word offset
  offset_16 = offset >> 1;

  /* Issue unlock sequence command */
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);

  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_ERASE_SETUP_CMD);
  
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);

  /* Write Sector Erase Command to Offset */
  FLASH_WR(base_addr, offset_16, NOR_SECTOR_ERASE_CMD);

  /* Poll Status */
  status_reg = sll_lld_Poll(base_addr, offset_16 );

  if( status_reg & DEV_SEC_LOCK_MASK )
    return( DEV_SECTOR_LOCK );    /* sector locked */

  if( (status_reg & DEV_ERASE_MASK) == DEV_ERASE_MASK )
    return( DEV_ERASE_ERROR );    /* erase error */
      
  return( DEV_NOT_BUSY );         /* erease complete */
}


/******************************************************************************
* 
* sll_lld_WriteBufferProgramOp - Performs a Write Buffer Programming Operation.
*
* Function programs a write-buffer overlay of addresses to data 
* passed via <data_buf>.
* Function issues all required commands and polls for completion.
*
* There are 4 main sections to the function:
*  Set-up and write command sequence
*  Determine number of locations to program and load buffer
*  Start operation with "Program Buffer to Flash" command
*  Poll for completion
*
* REQUIREMENTS:
*  Data in the buffer MUST be properly aligned with the Flash bus width.
*  No parameter checking is performed. 
*  The <word_count> variable must be properly initialized.  
*  Valid <byte_cnt> values: 
*   min = 1 byte (only valid when used with a single x8 Flash)
*   max = write buffer size in bytes * number of devices in parallel
      (e.g. 32-byte buffer per device, 2 x16 devices = 64 bytes)
*
* RETURNS: DEVSTATUS 
*/
DEVSTATUS sll_lld_WriteBufferProgramOp
( 
uint32_t * base_addr,  /* device base address in system     */
uint32_t  offset,     /* address offset from base address  */
uint32_t word_count, /* number of words to program        */
uint8_t *data_buf   /* buffer containing data to program */
)
{
	
  uint32_t last_loaded_addr;
  uint32_t current_offset;
  uint32_t end_offset;
  uint16_t wcount16;
  uint16_t wdata_16;
  uint16_t status_reg;

  uint32_t   offset_16;
  
  offset_16     = offset >> 1;  

  /* don't try with a count of zero */
  if (!word_count) 
  {
    return(DEV_NOT_BUSY);
  }

  /* Issue Load Write Buffer Command Sequence */
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);

  /* Write Write Buffer Load Command */
  FLASH_WR(base_addr, offset_16, NOR_WRITE_BUFFER_LOAD_CMD);

  /*16-bit word count*/
   wcount16 = (uint16_t)(word_count >> 1);  
   
  // If even number of bytes and address offset is on a half word boundary, 
  // subtract one to count
  if(word_count%2 == 0 && offset%2 == 0) {
     wcount16 = wcount16 - 1;  	
  }  

  /* Initialize variables - everything is  byte oriented*/
  current_offset   = offset;
  end_offset       = offset + word_count - 1;
  last_loaded_addr = offset;

 
  /* In the datasheets of some latest Cypress devices, such as GLP, GLS, etc, the 
  command sequence of "write to buffer" command states the address of word count is 
  "Sector Address". Notice that to make LLD backward compatibility, the actual word 
  count address implemented is "Sector Address + LLD_UNLOCK_ADDR2", since the lower 
  address bits (a0-a15) are "don't care" bits and will be ignored anyway.
  */
  FLASH_WR(base_addr, offset_16 & SA_OFFSET_MASK , wcount16);

  /* check whether first byte is 16-bit aligned  */
  if(current_offset%2 != 0)
  {
    /* Store last loaded address & data value (for polling) */
    last_loaded_addr = current_offset;
 
    //patch 16-bit data
    wdata_16  = IORD_8DIRECT(base_addr,  current_offset-1);
    wdata_16 |= *data_buf++ << 8;
  	
    /* Write Data */
    FLASH_WR(base_addr, (current_offset>>1), wdata_16);
    current_offset++;
  } 
  
  /* Load Data into Buffer */
  while(current_offset < end_offset) 
  {
    /* Store last loaded address & data value (for polling) */
    last_loaded_addr = current_offset;
    
    wdata_16  = *data_buf++;
    wdata_16 |= *data_buf++ << 8;
  
    /* Write Data */
    FLASH_WR(base_addr, (current_offset>>1), wdata_16);
    current_offset=current_offset+2; //data is 16-bit
  }

  /*check and patch last byte */
  if(current_offset == end_offset)
  {
    /* Store last loaded address & data value (for polling) */
    last_loaded_addr = current_offset;
 
    //patch 16-bit data
    wdata_16  = *data_buf++ ;
    wdata_16 |= IORD_8DIRECT(base_addr,  current_offset+1) << 8;
  	
    /* Write Data */
    FLASH_WR(base_addr, (current_offset>>1), wdata_16);
  }


  /* Issue Program Buffer to Flash command */
  FLASH_WR(base_addr, offset_16, NOR_WRITE_BUFFER_PGM_CONFIRM_CMD);

  status_reg = sll_lld_Poll(base_addr, last_loaded_addr>>1);

  if( status_reg & DEV_SEC_LOCK_MASK )
    return( DEV_SECTOR_LOCK );    /* sector locked */

  if( (status_reg & DEV_PROGRAM_MASK) == DEV_PROGRAM_MASK )
    return( DEV_PROGRAM_ERROR );    /* program error */

  return( DEV_NOT_BUSY );           /* program complete */
}



/******************************************************************************
* 
* sll_lld_memcpy   This function attempts to mimic the standard memcpy
*              function for flash.  It segments the source data
*              into page size chunks for use by Write Buffer Programming.
*
* RETURNS: DEVSTATUS
*
*/
DEVSTATUS sll_lld_memcpy
(
uint32_t * base_addr,    /* device base address is system */
uint32_t offset,           /* address offset from base address */
uint32_t word_cnt,       /* number of words to program */
uint8_t *data_buf       /* buffer containing data to program */
)
{
  
   uint32_t mask    = LLD_BUFFER_SIZE - 1;
   uint32_t intwc   = word_cnt;
   DEVSTATUS status = DEV_NOT_BUSY;

  if (offset & mask)
  {
    /* program only as much as necessary, so pick the lower of the two numbers */
    if (word_cnt < (LLD_BUFFER_SIZE - (offset & mask)) ) 
      intwc = word_cnt; 
    else
      intwc = LLD_BUFFER_SIZE - (offset & mask);

    /* program the first few to get write buffer aligned */
    status = sll_lld_WriteBufferProgramOp(base_addr, offset, intwc, data_buf);
    if (status != DEV_NOT_BUSY) 
    {
     return(status);
    }

    offset    += intwc; /* adjust pointers and counter */
    word_cnt  -= intwc;
    data_buf  += intwc;
    if (word_cnt == 0)
    {
     return(status);
    }
  }

  while(word_cnt >= LLD_BUFFER_SIZE) /* while big chunks to do */
  {
    status = sll_lld_WriteBufferProgramOp(base_addr, offset, LLD_BUFFER_SIZE, data_buf);
    if (status != DEV_NOT_BUSY)
    {
      return(status);
    }

    offset    += LLD_BUFFER_SIZE; /* adjust pointers and counter */
    word_cnt  -= LLD_BUFFER_SIZE;
    data_buf  += LLD_BUFFER_SIZE;
  }
  if (word_cnt == 0)
  {
    return(status);
  }

  status = sll_lld_WriteBufferProgramOp(base_addr, offset, word_cnt, data_buf);
  return(status);
}

