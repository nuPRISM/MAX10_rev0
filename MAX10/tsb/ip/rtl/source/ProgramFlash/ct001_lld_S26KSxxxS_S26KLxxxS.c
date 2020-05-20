/* lld.c - Source Code for Cypress's Low Level Driver */
/**************************************************************************
* Copyright (C)2011 Cypress LLC. All Rights Reserved . 
*
* This software is owned and published by: 
* Cypress LLC, 915 DeGuigne Dr. Sunnyvale, CA  94088-3453 ("Cypress").
*
* BY DOWNLOADING, INSTALLING OR USING THIS SOFTWARE, YOU AGREE TO BE BOUND 
* BY ALL THE TERMS AND CONDITIONS OF THIS AGREEMENT.
*
* This software constitutes driver source code for use in programming Cypress's 
* Flash memory components. This software is licensed by Cypress to be adapted only 
* for use in systems utilizing Cypress's Flash memories. Cypress is not be 
* responsible for misuse or illegal use of this software for devices not 
* supported herein.  Cypress is providing this source code "AS IS" and will 
* not be responsible for issues arising from incorrect user implementation 
* of the source code herein.  
*
* CYPRESS MAKES NO WARRANTY, EXPRESS OR IMPLIED, ARISING BY LAW OR OTHERWISE, 
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
//#include "ct001_lld_target_specific.h" /* For building project, it needs enabled */
 
#include "ct001_S26KSxxxS_S26KLxxxS.h"
#define LLD_BUFFER_SIZE (256*LLD_BUF_SIZE_MULTIPLIER)
#define LLD_DPD_DELAY 300


/* private functions */

/* Public Functions  */
/******************************************************************************
* 
* ct001_lld_GetVersion - Get LLD Version Number in string format.
*
*  PARAMETERS:  LLD_CHAR[] versionStr
*               Pointer to an empty char array. The size of the array has to be at 
*               least 12 in order to avoid buffer overflow.
*  RETURNS: version number in string returned in versionStr  
*
* ERRNO: 
*/
void ct001_lld_GetVersion( LLD_CHAR versionStr[])
{
  LLD_CHAR*  pVer = (LLD_CHAR*)LLD_VERSION;    
  
  if (versionStr)
  {
    while (*pVer) *versionStr++ = *pVer++;
    *versionStr = 0;   
  }
}

/******************************************************************************
* 
* ct001_lld_InitCmd - Initialize LLD
*
*
* RETURNS: void
*
* ERRNO: 
*/
void ct001_lld_InitCmd
(
FLASHDATA * base_addr     /* device base address in system */
)
{
  (void) base_addr;
}

/******************************************************************************
* 
* ct001_lld_ResetCmd - Writes a Software Reset command to the flash device
*
*
* RETURNS: void
*
* ERRNO: 
*/

void ct001_lld_ResetCmd
(
FLASHDATA * base_addr   /* device base address in system */
)
{       
  /* Write Software RESET command */
  FLASH_WR(base_addr, 0, NOR_RESET_CMD);
  ct001_lld_InitCmd(base_addr);
}

/******************************************************************************
* 
* ct001_lld_SectorEraseCmd - Writes a Sector Erase Command to Flash Device
*
* This function only issues the Sector Erase Command sequence.
* Erase status polling is not implemented in this function.
*
* RETURNS: void
*
*/
 
void ct001_lld_SectorEraseCmd
(
FLASHDATA * base_addr,                   /* device base address in system */
ADDRESS offset                           /* address offset from base address */
)
{ 
 
  /* Issue unlock sequence command */
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);

  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_ERASE_SETUP_CMD);
  
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);

  /* Write Sector Erase Command to Offset */
  FLASH_WR(base_addr, offset, NOR_SECTOR_ERASE_CMD);

}
/******************************************************************************
* 
* ct001_lld_ChipEraseCmd - Writes a Chip Erase Command to Flash Device
*
* This function only issues the Chip Erase Command sequence.
* Erase status polling is not implemented in this function.
*
* RETURNS: void
* 
*/
void ct001_lld_ChipEraseCmd
(
FLASHDATA * base_addr    /* device base address in system */
)
{       
  /* Issue inlock sequence command */
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);

  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_ERASE_SETUP_CMD);

  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);

  /* Write Chip Erase Command to Base Address */
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_CHIP_ERASE_CMD);
}
/******************************************************************************
* 
* ct001_lld_ProgramCmd - Writes a Program Command to Flash Device
*
* This function only issues the Program Command sequence.
* Program status polling is not implemented in this function.
*
* RETURNS: void
*
*/
void ct001_lld_ProgramCmd
(
FLASHDATA * base_addr,               /* device base address in system */
ADDRESS offset,                  /* address offset from base address */
FLASHDATA *pgm_data_ptr          /* variable containing data to program */
)
{       
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);

  /* Write Program Command */
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_PROGRAM_CMD);
  /* Write Data */
  FLASH_WR(base_addr, offset, *pgm_data_ptr);
}
/******************************************************************************
* 
* ct001_lld_WriteToBufferCmd - Writes "Write to Buffer Pgm" Command sequence to Flash
*
* RETURNS: void
*
*/
void ct001_lld_WriteToBufferCmd
(
FLASHDATA * base_addr,               /* device base address in system */
ADDRESS offset                       /* address offset from base address */
)
{  
  /* Issue unlock command sequence */
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);

  /* Write Write Buffer Load Command */
  FLASH_WR(base_addr, offset, NOR_WRITE_BUFFER_LOAD_CMD);

}
/******************************************************************************
* 
* ct001_lld_ProgramBufferToFlashCmd - Writes "Pgm Buffer To Flash" Cmd sequence to Flash
*
* RETURNS: void
* 
*/ 
void ct001_lld_ProgramBufferToFlashCmd
(
FLASHDATA * base_addr,               /* device base address in system */
ADDRESS offset                       /* address offset from base address */
)
{       
  /* Transfer Buffer to Flash Command */
  FLASH_WR(base_addr, offset, NOR_WRITE_BUFFER_PGM_CONFIRM_CMD);
}
/******************************************************************************
* 
* ct001_lld_WriteBufferAbortResetCmd - Writes "Write To Buffer Abort" Reset to Flash
*
* RETURNS: void
*
*/
void ct001_lld_WriteBufferAbortResetCmd
(
FLASHDATA * base_addr        /* device base address in system */
)
{       
  
  /* Issue Write Buffer Abort Reset Command Sequence */
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);

  /* Write to Buffer Abort Reset Command */
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_WRITE_BUFFER_ABORT_RESET_CMD);   
}

/******************************************************************************
* 
* ct001_lld_CfiEntryCmd - Writes CFI Entry Command Sequence to Flash
*
* RETURNS: void
*
*/
void ct001_lld_CfiEntryCmd
(
FLASHDATA * base_addr,    /* device base address in system */
ADDRESS offset            /* sector address offset for ASO(Address Space Overlay) */
)
{        
  FLASH_WR(base_addr, (offset & SA_OFFSET_MASK) + LLD_CFI_UNLOCK_ADDR1, NOR_CFI_QUERY_CMD);
}
/******************************************************************************
* 
* ct001_lld_CfiExitCmd - Writes Cfi Exit Command Sequence to Flash
*
* This function resets the device out of CFI Query mode.
* This is a "wrapper function" to provide "Enter/Exit" symmetry in
* higher software layers.
*
* RETURNS: void
*
*/

void ct001_lld_CfiExitCmd
(
FLASHDATA * base_addr   /* device base address in system */
)
{       

  /* Write Software RESET command */
  FLASH_WR(base_addr, 0, NOR_RESET_CMD); 

}

/******************************************************************************
* 
* ct001_lld_ReadCfiWord - Read CFI word operation.
*
* RETURNS: word read
*
*/
FLASHDATA ct001_lld_ReadCfiWord
(
FLASHDATA * base_addr,    /* device base address is system */
ADDRESS offset        /* address offset from base address */
)
{
  FLASHDATA data;

  ct001_lld_CfiEntryCmd(base_addr, offset);
  data  = FLASH_RD(base_addr, offset);
  ct001_lld_CfiExitCmd(base_addr);

  return(data);
}


/******************************************************************************
* 
* ct001_lld_StatusRegReadCmd - Status register read command
*
* This function sends the status register read command before actually reading it.
*
* RETURNS: void
*
*/

void ct001_lld_StatusRegReadCmd
(
FLASHDATA * base_addr    /* device base address in system */
)
{         
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_STATUS_REG_READ_CMD); 
}

/******************************************************************************
* 
* ct001_lld_StatusRegClearCmd - Status register clear command
*
* This function clear the status register. It will not clear the device operation 
* bits such as program suspend and erase suspend bits.
*
* RETURNS: void
*
*/

void ct001_lld_StatusRegClearCmd
(
FLASHDATA * base_addr   /* device base address in system */
)
{         
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_STATUS_REG_CLEAR_CMD); 
}



/******************************************************************************
* 
* ct001_lld_AutoselectEntryCmd - Writes Autoselect Command Sequence to Flash
*
* This function issues the Autoselect Command Sequence to device.
*
* RETURNS: void
* 
*/
void ct001_lld_AutoselectEntryCmd
(
FLASHDATA * base_addr,      /* device base address in system */
ADDRESS offset          /* address offset from base address */
)
{ 
  /* Issue Autoselect Command Sequence */
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);

  FLASH_WR(base_addr, (offset & SA_OFFSET_MASK) + LLD_UNLOCK_ADDR1, NOR_AUTOSELECT_CMD); 
}

/******************************************************************************
* 
* ct001_lld_AutoselectExitCmd - Writes Autoselect Exit Command Sequence to Flash
*
* This function resets the device out of Autoselect mode.
* This is a "wrapper function" to provide "Enter/Exit" symmetry in
* higher software layers.
*
* RETURNS: void
* 
*/
void ct001_lld_AutoselectExitCmd
(
FLASHDATA * base_addr     /* device base address in system */
)
{       
  /* Write Software RESET command */
  FLASH_WR(base_addr, 0, NOR_RESET_CMD);
}


/******************************************************************************
* 
* ct001_lld_ProgramSuspendCmd - Writes Suspend Command to Flash
*
* RETURNS: void
* 
*/
void ct001_lld_ProgramSuspendCmd
(
FLASHDATA * base_addr           /* device base address in system */
)
{         
  /* Write Suspend Command */
  FLASH_WR(base_addr, 0, NOR_PROGRAM_SUSPEND_CMD);
}

/******************************************************************************
* 
* ct001_lld_EraseSuspendCmd - Writes Suspend Command to Flash
*
* RETURNS: void
*
*/
void ct001_lld_EraseSuspendCmd
(
FLASHDATA * base_addr      /* device base address in system */
)
{     
  
  
  /* Write Suspend Command */
  FLASH_WR(base_addr, 0, NOR_ERASE_SUSPEND_CMD);
}

/******************************************************************************
* 
* ct001_lld_EraseResumeCmd - Writes Resume Command to Flash
*
* RETURNS: void
*
*/
void ct001_lld_EraseResumeCmd
(
FLASHDATA * base_addr       /* device base address in system */
)
{       

  /* Write Resume Command */
  FLASH_WR(base_addr, 0, NOR_ERASE_RESUME_CMD);

}

/******************************************************************************
* 
* ct001_lld_ProgramResumeCmd - Writes Resume Command to Flash
*
* RETURNS: void
*
*/
void ct001_lld_ProgramResumeCmd
(
FLASHDATA * base_addr       /* device base address in system */
)
{       
  /* Write Resume Command */
  FLASH_WR(base_addr, 0, NOR_PROGRAM_RESUME_CMD);
}



/******************************************************************************
* 
* ct001_lld_EraseSuspendOp - Performs Erase Suspend Operation
*
* Function pergorm erase suspend operation.
* Function issues erase suspend commands and will poll for completion.
*
* RETURNS: DEVSTATUS
*/
DEVSTATUS ct001_lld_EraseSuspendOp
(
FLASHDATA * base_addr    /* device base address is system */
)
{       
  FLASHDATA    status_reg;
 
  ct001_lld_EraseSuspendCmd( base_addr );   /* issue erase suspend command */
  status_reg = ct001_lld_Poll(base_addr, 0 );    /* wait for device done */
  
  if( (status_reg & DEV_ERASE_SUSP_MASK) == DEV_ERASE_SUSP_MASK )
    return( DEV_ERASE_SUSPEND  );        /* Erase suspend  */
      
  return( DEV_ERASE_SUSPEND_ERROR );       /* Erase suspend error */

}

/******************************************************************************
* 
* ct001_lld_ProgramSuspendOp - Performs Program Suspend Operation
*
* Function pergorm program suspend operation.
* Function issues program suspend commands and will poll for completion.
*
* RETURNS: DEVSTATUS
*/
DEVSTATUS ct001_lld_ProgramSuspendOp
(
FLASHDATA * base_addr    /* Device base address is system */
)
{       
  FLASHDATA    status_reg;

  ct001_lld_ProgramSuspendCmd( base_addr );   /* Issue program suspend command */
  status_reg = ct001_lld_Poll( base_addr, 0 );
  
  if( (status_reg & DEV_PROGRAM_SUSP_MASK) == DEV_PROGRAM_SUSP_MASK )
    return( DEV_PROGRAM_SUSPEND );      /* Program suspend */
      
  return( DEV_PROGRAM_SUSPEND_ERROR  );     /* Program suspend error */ 
}



/******************************************************************************
* 
* ct001_lld_GetDeviceId - Get device ID operation (for RPC2)
*
* RETURNS: three byte ID in a single int
*
*/
unsigned int ct001_lld_GetDeviceId
(
FLASHDATA * base_addr,   /* device base address in system */
ADDRESS offset
)
{
  unsigned int id;

  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);

  FLASH_WR(base_addr, (offset & SA_OFFSET_MASK) + LLD_UNLOCK_ADDR1, NOR_AUTOSELECT_CMD);

  id  = (unsigned int)(FLASH_RD(base_addr, (offset & SA_OFFSET_MASK) + 0x0001) & 0x000000FF) << 16;
  id |= (unsigned int)(FLASH_RD(base_addr, (offset & SA_OFFSET_MASK) + 0x000E) & 0x000000FF) <<  8;
  id |= (unsigned int)(FLASH_RD(base_addr, (offset & SA_OFFSET_MASK) + 0x000F) & 0x000000FF)      ;

  /* Write Software RESET command */
  FLASH_WR(base_addr, 0, NOR_RESET_CMD);
  
  return(id);
}






/******************************************************************************
* 
* ct001_lld_Poll - Polls flash device for embedded operation completion
*
*  Function polls the Flash device to determine when an embedded
*  operation has finished - bit 7 is 1.  
*
* RETURNS: value of status register
*
*/
FLASHDATA ct001_lld_Poll
(
FLASHDATA * base_addr,          /* device base address in system */
ADDRESS offset                 /* address offset from base address */
)
{       
  unsigned long polling_counter = 0xFFFFFFFF;
  volatile FLASHDATA status_reg;

  do
  {
    polling_counter--;
    ct001_lld_StatusRegReadCmd( base_addr );    /* Issue status register read command */
    status_reg = FLASH_RD(base_addr, offset);       /* read the status register */
    if( (status_reg & DEV_RDY_MASK) == DEV_RDY_MASK  )  /* Are all devices done bit 7 is 1 */
      break;

  }while(polling_counter);
  
  return( status_reg );          /* retrun the status reg. */
}


/******************************************************************************
*    
* ct001_lld_StatusClear - Clears the flash status
*
*
* RETURNS: void
*
*/
void ct001_lld_StatusClear
(
FLASHDATA *  base_addr      /* device base address in system */
)
{
  ct001_lld_StatusRegClearCmd(base_addr );
}

/******************************************************************************
*    
* ct001_lld_StatusGetReg - Gets the flash status register bits
*
*
* RETURNS: FLASHDATA
*
*/
FLASHDATA ct001_lld_StatusGetReg
(
FLASHDATA *  base_addr,      /* device base address in system */
ADDRESS      offset          /* address offset from base address */
)
{
  FLASHDATA status_reg = 0xFFFF;
  ct001_lld_StatusRegReadCmd( base_addr );    /* Issue status register read command */
  status_reg = FLASH_RD( base_addr, offset );     /* read the status register */
  return status_reg;
}





/******************************************************************************
* 
* ct001_lld_SecSiSectorExitCmd - Writes SecSi Sector Exit Command Sequence to Flash
*
* This function issues the Secsi Sector Exit Command Sequence to device.
* Use this function to Exit the SecSi Sector.
*
*
* RETURNS: void
*
* ERRNO: 
*/

void ct001_lld_SecSiSectorExitCmd
(
FLASHDATA * base_addr               /* device base address in system */
)
{       
  /* Issue SecSi Sector Exit Command Sequence */
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);

  /* First Secsi Sector Reset Command */
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_SECSI_SECTOR_EXIT_SETUP_CMD);
  /* Second Secsi Sector Reset Command */
  FLASH_WR(base_addr, 0, NOR_SECSI_SECTOR_EXIT_CMD);
}
/******************************************************************************
* 
* ct001_lld_SecSiSectorEntryCmd - Writes SecSi Sector Entry Command Sequence to Flash
*
* This function issues the Secsi Sector Entry Command Sequence to device.
* Use this function to Enable the SecSi Sector.
*
*
* RETURNS: void
*
* ERRNO: 
*/
void ct001_lld_SecSiSectorEntryCmd
(
FLASHDATA * base_addr,      /* device base address in system */
ADDRESS offset        /* sector offset for ASO(Address Space Overlay) */
)
{       
  
  /* Issue SecSi Sector Entry Command Sequence */
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);

  FLASH_WR(base_addr, (offset & SA_OFFSET_MASK) + LLD_UNLOCK_ADDR1, NOR_SECSI_SECTOR_ENTRY_CMD); 
}


/******************************************************************************
* 
* ct001_lld_BlankCheckCmd - Blank Check command
*
* This function checks the sector is blank.
*
* RETURNS: void
*
* ERRNO: 
*/
void ct001_lld_BlankCheckCmd
(
FLASHDATA * base_addr,   /* device base address in system */
ADDRESS offset           /* sector address offset from base address */
)
{         
  FLASH_WR(base_addr, (offset & SA_OFFSET_MASK) + LLD_UNLOCK_ADDR1, NOR_BLANK_CHECK_CMD);  
}

/******************************************************************************
* 
* ct001_lld_BlankCheckOp - Performs a Blank Check Operation
*
* Function check blank at <base_addr> + <offset>.
* Function issues all required commands and will pool for completion
*
* RETURNS: DEVSTATUS
*/
DEVSTATUS ct001_lld_BlankCheckOp
(
FLASHDATA * base_addr,    /* device base address is system */
ADDRESS offset        /* address offset from base address */
)
{       
    FLASHDATA    status_reg;

  ct001_lld_BlankCheckCmd( base_addr, offset );

  status_reg = ct001_lld_Poll(base_addr, offset );
  
  if( (status_reg & DEV_ERASE_MASK) == DEV_ERASE_MASK )
    return( DEV_ERASE_ERROR );    /* sector not blank */
  else
     return( DEV_NOT_BUSY );      /* sector are blank */  

}


/******************************************************************************
* 
* ct001_lld_ReadOp - Read memory array operation
*
* RETURNS: data read
*
*/
FLASHDATA ct001_lld_ReadOp
(
FLASHDATA * base_addr,    /* device base address is system */
ADDRESS offset        /* address offset from base address */
)
{
  FLASHDATA data;
  
  data = FLASH_RD(base_addr, offset);

  return(data);
}
#ifdef USER_SPECIFIC_CMD_3 //added NOR Page Read
/******************************************************************************
* 
* ct001_lld_PageReadOp - Read memory array operation
*
* RETURNS: NA
*
*/
void ct001_lld_PageReadOp
(
FLASHDATA * base_addr,    /* device base address is system */
ADDRESS offset,        /* address offset from base address */
FLASHDATA * read_buf,  /* read data */
FLASHDATA cnt        /* read count */
)
{
  FLASH_PAGE_RD(base_addr, offset, read_buf, cnt);
}
#endif

/******************************************************************************
* 
* ct001_lld_WriteBufferProgramOp - Performs a Write Buffer Programming Operation.
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
DEVSTATUS ct001_lld_WriteBufferProgramOp
(
FLASHDATA *   base_addr,  /* device base address in system     */
ADDRESS   offset,     /* address offset from base address  */
WORDCOUNT word_count, /* number of words to program        */
FLASHDATA *data_buf   /* buffer containing data to program */
)
{
  ADDRESS   last_loaded_addr;
  ADDRESS   current_offset;
  ADDRESS   end_offset;
  FLASHDATA wcount;
  FLASHDATA status_reg;

  /* Initialize variables */
  current_offset   = offset;
  end_offset       = offset + word_count - 1;
  last_loaded_addr = offset;

  /* don't try with a count of zero */
  if (!word_count) 
  {
    return(DEV_NOT_BUSY);
  }

  /* Issue Load Write Buffer Command Sequence */
  ct001_lld_WriteToBufferCmd(base_addr, offset);

  /* Write # of locations to program */
  wcount = (FLASHDATA)word_count - 1;
  wcount *= LLD_DEV_MULTIPLIER;     /* For interleaving devices */

  /* In the datasheets of some latest Cypress devices, such as GLP, GLS, etc, the 
  command sequence of "write to buffer" command states the address of word count is 
  "Sector Address". Notice that to make LLD backward compatibility, the actual word 
  count address implemented is "Sector Address + LLD_UNLOCK_ADDR2", since the lower 
  address bits (a0-a15) are "don't care" bits and will be ignored anyway.
  */
    FLASH_WR(base_addr, offset & SA_OFFSET_MASK , wcount);
  
  /* Load Data into Buffer */
  while(current_offset <= end_offset)
  {
    /* Store last loaded address & data value (for polling) */
    last_loaded_addr = current_offset;

    /* Write Data */
    FLASH_WR(base_addr, current_offset, *data_buf++);
    current_offset++;
  }

  /* Issue Program Buffer to Flash command */
  ct001_lld_ProgramBufferToFlashCmd(base_addr, offset);

  status_reg = ct001_lld_Poll(base_addr, last_loaded_addr);

  if( status_reg & DEV_SEC_LOCK_MASK )
    return( DEV_SECTOR_LOCK );    /* sector locked */

  if( (status_reg & DEV_PROGRAM_MASK) == DEV_PROGRAM_MASK )
    return( DEV_PROGRAM_ERROR );    /* program error */

  return( DEV_NOT_BUSY );           /* program complete */
}


/******************************************************************************
* 
* ct001_lld_ProgramOp - Performs a standard Programming Operation.
*
* Function programs a single location to the specified data.
* Function issues all required commands and polls for completion.
*
*
* RETURNS: DEVSTATUS
*/
DEVSTATUS ct001_lld_ProgramOp
(
FLASHDATA * base_addr,      /* device base address is system */
ADDRESS offset,         /* address offset from base address */
FLASHDATA write_data    /* variable containing data to program */
)
{   
 DEVSTATUS status;
 status = ct001_lld_WriteBufferProgramOp(base_addr, offset, 1, &write_data );
 return(status);
}


/******************************************************************************
* 
* ct001_lld_SectorEraseOp - Performs a Sector Erase Operation
*
* Function erases the sector containing <base_addr> + <offset>.
* Function issues all required commands and polls for completion.
*
*
* RETURNS: DEVSTATUS
*
* ERRNO: 
*/

DEVSTATUS ct001_lld_SectorEraseOp
(
FLASHDATA * base_addr,    /* device base address is system */
ADDRESS offset        /* address offset from base address */
)
{
  FLASHDATA         status_reg;

  ct001_lld_SectorEraseCmd(base_addr, offset);
  status_reg = ct001_lld_Poll(base_addr, offset );

  if( status_reg & DEV_SEC_LOCK_MASK )
    return( DEV_SECTOR_LOCK );    /* sector locked */

  if( (status_reg & DEV_ERASE_MASK) == DEV_ERASE_MASK )
    return( DEV_ERASE_ERROR );    /* erase error */
      
  return( DEV_NOT_BUSY );         /* erease complete */
}



/******************************************************************************
* 
* ct001_lld_ChipEraseOp - Performs a Chip Erase Operation
*
* Function erases entire device located at <base_addr>.
* Function issues all required commands and polls for completion.
*
*
* RETURNS: DEVSTATUS
*/
DEVSTATUS ct001_lld_ChipEraseOp
(
FLASHDATA * base_addr   /* device base address in system */
)
{    
  FLASHDATA status_reg;

  ct001_lld_ChipEraseCmd(base_addr);
  status_reg = ct001_lld_Poll(base_addr, 0 );

  if( (status_reg & DEV_ERASE_MASK) == DEV_ERASE_MASK )
    return( DEV_ERASE_ERROR );    /* erase error */
      
  return( DEV_NOT_BUSY );         /* erease complete */ 
}


/******************************************************************************
* 
* ct001_lld_memcpy   This function attempts to mimic the standard memcpy
*              function for flash.  It segments the source data
*              into page size chunks for use by Write Buffer Programming.
*
* RETURNS: DEVSTATUS
*
*/
DEVSTATUS ct001_lld_memcpy
(
FLASHDATA * base_addr,    /* device base address is system */
ADDRESS offset,           /* address offset from base address */
WORDCOUNT word_cnt,       /* number of words to program */
FLASHDATA *data_buf       /* buffer containing data to program */
)
{
  ADDRESS mask = LLD_BUFFER_SIZE - 1;
  WORDCOUNT intwc = word_cnt;
  DEVSTATUS status = DEV_NOT_BUSY;

  if (offset & mask)
  {
    /* program only as much as necessary, so pick the lower of the two numbers */
    if (word_cnt < (LLD_BUFFER_SIZE - (offset & mask)) ) 
      intwc = word_cnt; 
    else
      intwc = LLD_BUFFER_SIZE - (offset & mask);

    /* program the first few to get write buffer aligned */
    status = ct001_lld_WriteBufferProgramOp(base_addr, offset, intwc, data_buf);
    if (status != DEV_NOT_BUSY) 
    {
     return(status);
    }

    offset   += intwc; /* adjust pointers and counter */
    word_cnt -= intwc;
    data_buf += intwc;
    if (word_cnt == 0)
    {
     return(status);
    }
  }

  while(word_cnt >= LLD_BUFFER_SIZE) /* while big chunks to do */
  {
    status = ct001_lld_WriteBufferProgramOp(base_addr, offset, LLD_BUFFER_SIZE, data_buf);
    if (status != DEV_NOT_BUSY)
    {
      return(status);
    }

    offset   += LLD_BUFFER_SIZE; /* adjust pointers and counter */
    word_cnt -= LLD_BUFFER_SIZE;
    data_buf += LLD_BUFFER_SIZE;
  }
  if (word_cnt == 0)
  {
    return(status);
  }

  status = ct001_lld_WriteBufferProgramOp(base_addr, offset, word_cnt, data_buf);
  return(status);
}

/******************************************************************************
* 
* DelayMilliseconds - Performs a delay.  If you have a better way,
*                     edit the macro DELAY_MS in ct001_lld_target_specific.h
*
* RETURNS: void
*
*/
void DelayMilliseconds(int milliseconds)
{
  int i;

  for (i = 0; i < milliseconds; i++)
    DelayMicroseconds(1000);
 
}

/******************************************************************************
* 
* DelayMicroseconds - Performs a delay.  If you have a better way,
*                     
* RETURNS: void
*
*/
#define DELAY_1us 150

void DelayMicroseconds(int microseconds)
{
  int volatile i, j;

  for (j = 0; j < microseconds; j++)
    for(i = 0; i < DELAY_1us; i++) i = i;
    
}

/************************************************************
*************************************************************
* Following are sector protection driver routines     *
*************************************************************
*************************************************************/

/******************************************************************************
* 
* ct001_lld_LockRegEntryCmd - Lock register entry command.
*
* RETURNS: n/a
*
*/
void ct001_lld_LockRegEntryCmd
(
FLASHDATA *   base_addr   /* device base address in system */
)
{

  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);

  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, WSXXX_LOCK_REG_ENTRY);
}

/******************************************************************************
* 
* ct001_lld_LockRegBitsProgramCmd - Lock register program command.
*
* RETURNS: n/a
*
*/
void ct001_lld_LockRegBitsProgramCmd
(
FLASHDATA *   base_addr,  /* device base address in system */
FLASHDATA value       /* value to program to lock reg. */
)
{

  FLASH_WR(base_addr, 0, NOR_UNLOCK_BYPASS_PROGRAM_CMD);
  FLASH_WR(base_addr, 0x0, value);

}

/******************************************************************************
* 
* ct001_lld_LockRegBitsReadCmd - Lock register read command.
* Note: Need to issue ct001_lld_LockRegEntryCmd() before use this routine.
*
* RETURNS:  
* DQ0 Customer SecSi Sector Protection Bit  0 = set
* DQ1 Persistent Protection Mode Lock Bit   0 = set
* DQ2 Password Protection Mode Lock Bit     0 = set
*
*/
FLASHDATA ct001_lld_LockRegBitsReadCmd
(
FLASHDATA *   base_addr   /* device base address in system */
)
{

  return(FLASH_RD(base_addr, 0x0));

}

/******************************************************************************
* 
* ct001_lld_LockRegExitCmd - Exit lock register read/write mode command.
*
* RETURNS: n/a
*
*/
void ct001_lld_LockRegExitCmd
(
FLASHDATA *   base_addr   /* device base address in system */
)
{

  FLASH_WR(base_addr, 0, NOR_SECSI_SECTOR_EXIT_SETUP_CMD);
  FLASH_WR(base_addr, 0, NOR_SECSI_SECTOR_EXIT_CMD);

}



/******************************************************************************
* 
* ct001_lld_PasswordProtectionEntryCmd - Write Password Protection Entry command sequence
*
* RETURNS: n/a
*
*/
void ct001_lld_PasswordProtectionEntryCmd
(
FLASHDATA *   base_addr   /* device base address in system */
)
{
  
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);

  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, WSXXX_PSWD_PROT_CMD_ENTRY);
}

/******************************************************************************
* 
* ct001_lld_PasswordProtectionProgramCmd - Write Password Protection Program command.
* Note: Need to issue ct001_lld_PasswordProtectionEntryCmd() before issue this routine.
* RETURNS: n/a
*
*/
void ct001_lld_PasswordProtectionProgramCmd
(
FLASHDATA *   base_addr,  /* device base address in system */
ADDRESS   offset,
FLASHDATA pwd
)
{
  FLASH_WR(base_addr, offset, NOR_UNLOCK_BYPASS_PROGRAM_CMD);
  FLASH_WR(base_addr, offset, pwd);
}

/******************************************************************************
* 
* ct001_lld_PasswordProtectionReadCmd - Issue read password command
* Note: Need to issue ct001_lld_PasswordProtectionEntryCmd() before issue this routine.
* RETURNS: n/a
*
*/
void ct001_lld_PasswordProtectionReadCmd
(
FLASHDATA *   base_addr,  /* device base address in system */
FLASHDATA *pwd0,      /* Password 0 */
FLASHDATA *pwd1,      /* Password 1 */
FLASHDATA *pwd2,      /* Password 2 */
FLASHDATA *pwd3       /* Password 3 */
)
{
  *pwd0 = FLASH_RD(base_addr, 0);
  *pwd1 = FLASH_RD(base_addr, 1);
  *pwd2 = FLASH_RD(base_addr, 2);
  *pwd3 = FLASH_RD(base_addr, 3);
}

/******************************************************************************
* 
* ct001_lld_PasswordProtectionUnlockCmd - Issue unlock password command.
* Note: Need to issue ct001_lld_PasswordProtectionEntryCmd() before issue this routine.
* RETURNS: n/a
*
*/
void ct001_lld_PasswordProtectionUnlockCmd
(
FLASHDATA *   base_addr,  /* device base address in system */
FLASHDATA pwd0,       /* Password 0 */
FLASHDATA pwd1,       /* Password 1 */
FLASHDATA pwd2,       /* Password 2 */
FLASHDATA pwd3        /* Password 3 */
)
{
  FLASH_WR(base_addr, 0, WSXXX_PSWD_UNLOCK_1);
  FLASH_WR(base_addr, 0, WSXXX_PSWD_UNLOCK_2);
  FLASH_WR(base_addr, 0, pwd0);
  FLASH_WR(base_addr, 1, pwd1);
  FLASH_WR(base_addr, 2, pwd2);
  FLASH_WR(base_addr, 3, pwd3);
  FLASH_WR(base_addr, 0, WSXXX_PSWD_UNLOCK_3);

}

/******************************************************************************
* 
* ct001_lld_PasswordProtectionExitCmd - Issue exit password protection mode command.
*
* RETURNS: n/a
*
*/
void ct001_lld_PasswordProtectionExitCmd
(
FLASHDATA *   base_addr   /* device base address in system */
)
{
  FLASH_WR(base_addr, 0, NOR_SECSI_SECTOR_EXIT_SETUP_CMD);
  FLASH_WR(base_addr, 0, NOR_SECSI_SECTOR_EXIT_CMD);
}

/******************************************************************************
* 
* ct001_lld_PpbEntryCmd - Non-Volatile Sector Protection Entry Command.
* Ppb entry command will disable the reads and writes for the bank selectd.
* RETURNS: n/a
*
*/
void ct001_lld_PpbEntryCmd
(
FLASHDATA *   base_addr  /* device base address in system */
)
{

  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, WSXXX_PPB_ENTRY);
}

/******************************************************************************
* 
* ct001_lld_PpbProgramCmd - Program Non-Volatile Sector Protection Command.
* Note: Need to issue ct001_lld_PpbEntryCmd() before issue this routine.
* RETURNS: n/a
*
*/
void ct001_lld_PpbProgramCmd
(
FLASHDATA *   base_addr,  /* device base address in system */
ADDRESS   offset      /* Sector offset address */
)
{
  FLASH_WR(base_addr, 0, NOR_UNLOCK_BYPASS_PROGRAM_CMD);
  FLASH_WR(base_addr, offset, 0);
}

/******************************************************************************
* 
* ct001_lld_PpbAllEraseCmd - Erase Non-Volatile Protection for All  Sectors Command.
* Note: Need to issue ct001_lld_PpbEntryCmd() before issue this routine.
* RETURNS: n/a
*
*/
void ct001_lld_PpbAllEraseCmd
(
FLASHDATA *   base_addr   /* device base address in system */
)
{
  FLASH_WR(base_addr, 0, NOR_ERASE_SETUP_CMD);
  FLASH_WR(base_addr, 0, WSXXX_PPB_ERASE_CONFIRM);
}

/******************************************************************************
* 
* ct001_lld_PpbStatusReadCmd - Read Non-Volatile Sector Status Command.
* Note: Need to issue ct001_lld_PpbEntryCmd() before issue this routine.
* Sector status 0 is locked and 1 is unlocked.
* RETURNS: 
*
*/
FLASHDATA ct001_lld_PpbStatusReadCmd
(
FLASHDATA *   base_addr,  /* device base address in system */
ADDRESS   offset      /* sector offset address */
)
{
  return(FLASH_RD(base_addr, offset));
}

/******************************************************************************
* 
* ct001_lld_PpbExitCmd - Exit the Non-Volatile Sector Status mode.
* After the exit command the device goes back to memory array mode.
* RETURNS: n/a
*
*/
void ct001_lld_PpbExitCmd
(
FLASHDATA *   base_addr   /* device base address in system */
)
{
  FLASH_WR(base_addr, 0, NOR_SECSI_SECTOR_EXIT_SETUP_CMD);
  FLASH_WR(base_addr, 0, NOR_SECSI_SECTOR_EXIT_CMD);
}

/******************************************************************************
* 
* ct001_lld_PpbLockBitEntryCmd - Issue Persistent Protection Bit Lock Bit Entry Command.
* The Ppb Lock Bit is a global bit for all sectors. 
* RETURNS: n/a
*
*/
void ct001_lld_PpbLockBitEntryCmd
(
FLASHDATA *   base_addr   /* device base address in system */
)
{

  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);

  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, WSXXX_PPB_LOCK_ENTRY);
}

/******************************************************************************
* 
* ct001_lld_PpbLockBitSetCmd - Issue set Persistent Protection Bit Lock Bit command.
* Once bit is set there is no command to unset it only hardware reset and power up 
* will clear the bit.
* RETURNS: n/a
*
*/
void ct001_lld_PpbLockBitSetCmd
(
FLASHDATA *   base_addr   /* device base address in system */
)
{
  FLASH_WR(base_addr, 0, NOR_UNLOCK_BYPASS_PROGRAM_CMD);
  FLASH_WR(base_addr, 0, 0);
}

/******************************************************************************
* 
* ct001_lld_PpbLockBitReadCmd - Read the Ppb Lock Bit value.
* Note: Need to issue ct001_lld_PpbLockBitEntryCmd() before read.
* RETURNS: 
*
*/
FLASHDATA ct001_lld_PpbLockBitReadCmd
(
FLASHDATA *   base_addr   /* device base address in system */
)
{
  return(FLASH_RD(base_addr, 0));
}

/******************************************************************************
* 
* ct001_lld_PpbLockBitExitCmd - Exit Ppb Lock Bit mode command.
*
* RETURNS: n/a
*
*/
void ct001_lld_PpbLockBitExitCmd
(
FLASHDATA *   base_addr   /* device base address in system */
)
{
  FLASH_WR(base_addr, 0, NOR_SECSI_SECTOR_EXIT_SETUP_CMD);
  FLASH_WR(base_addr, 0, NOR_SECSI_SECTOR_EXIT_CMD);
}


/******************************************************************************
* 
* ct001_lld_DybEntryCmd - Dynamic (Volatile) Sector Protection Entry Command.
*
* RETURNS: n/a
*
*/
void ct001_lld_DybEntryCmd
(
FLASHDATA *   base_addr   /* device base address in system */
)
{

  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);

  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, WSXXX_DYB_ENTRY);
}

/******************************************************************************
* 
* ct001_lld_DybSetCmd - Dynamic (Volatile) Sector Protection Set Command.
* Note: Need to issue ct001_lld_DybEntryCmd() before issue this command.
* RETURNS: n/a
*
*/
void ct001_lld_DybSetCmd
(
FLASHDATA *   base_addr,  /* device base address in system */
ADDRESS   offset      /* sector offset address */
)
{
  FLASH_WR(base_addr, 0, NOR_UNLOCK_BYPASS_PROGRAM_CMD);
  FLASH_WR(base_addr, offset, 0x00000000);
}

/******************************************************************************
* 
* ct001_lld_DybClrCmd - Dynamic (Volatile) Sector Protection Clear Command.
* Note: Need to issue ct001_lld_DybEntryCmd() before issue this command.
* RETURNS: n/a
*
*/
void ct001_lld_DybClrCmd
(
FLASHDATA *   base_addr,  /* device base address in system */
ADDRESS   offset      /* sector offset address */
)
{
  FLASH_WR(base_addr, 0, NOR_UNLOCK_BYPASS_PROGRAM_CMD);
  FLASH_WR(base_addr, offset, WSXXX_DYB_CLEAR);
}

/******************************************************************************
* 
* ct001_lld_DybReadCmd - Dynamic (Volatile) Sector Protection Read Command.
* Note: Need to issue ct001_lld_DybEntryCmd() before issue this command.
* RETURNS: 
*
*/
FLASHDATA ct001_lld_DybReadCmd
(
FLASHDATA *   base_addr,  /* device base address in system */
ADDRESS   offset      /* sector offset address */
)
{
  return(FLASH_RD(base_addr, offset));
}

/******************************************************************************
* 
* ct001_lld_DybExitCmd - Exit Dynamic (Volatile) Sector Protection Mode Command.
*
* RETURNS: n/a
*
*/
void ct001_lld_DybExitCmd
(
FLASHDATA *   base_addr   /* device base address in system */
)
{
  FLASH_WR(base_addr, 0, NOR_SECSI_SECTOR_EXIT_SETUP_CMD);
  FLASH_WR(base_addr, 0, NOR_SECSI_SECTOR_EXIT_CMD);
}

/******************************************************************************
* 
* ct001_lld_PpbLockBitReadOp - Operation to read global lock bit.
*
* RETURNS: FLASHDATA
*
*/
FLASHDATA  ct001_lld_PpbLockBitReadOp ( FLASHDATA *base_addr)
{
  FLASHDATA retval;

  (ct001_lld_PpbLockBitEntryCmd)(base_addr);
  retval = (ct001_lld_PpbLockBitReadCmd)(base_addr);
  ct001_lld_PpbLockBitExitCmd(base_addr);

  return retval;
}

/******************************************************************************
* 
* ct001_lld_PpbLockBitSetOp - Operation to set the global lock bit.
*
* RETURNS: 0 Successful
*         -1 Failed
*
*/
int ct001_lld_PpbLockBitSetOp ( FLASHDATA *   base_addr)
{ 
  DEVSTATUS dev_status = DEV_STATUS_UNKNOWN;
  FLASHDATA    status_reg;


  ct001_lld_PpbLockBitEntryCmd(base_addr);
  ct001_lld_PpbLockBitSetCmd(base_addr);
  /* poll for completion */
  status_reg = ct001_lld_Poll(base_addr, 0);
  if( (status_reg & DEV_PROGRAM_MASK) == DEV_PROGRAM_MASK )
    dev_status =  DEV_PROGRAM_ERROR;    /* program error */
  else
    dev_status = DEV_NOT_BUSY;

  /* if not done, then we have an error */
  if (dev_status != DEV_NOT_BUSY)
  {
    /* Write Software RESET command */
    FLASH_WR(base_addr, 0, NOR_RESET_CMD);
    ct001_lld_PpbLockBitExitCmd(base_addr);
    return (-1);  /* return error */ 
  }

  ct001_lld_PpbLockBitExitCmd(base_addr);
  return 0; /* successfull */
}

/******************************************************************************
* 
* ct001_lld_PpbAllEraseOp - Operation to clear protection for all sections.
*
* RETURNS: 0 Successful
*         -1 Failed
*
*/
int ct001_lld_PpbAllEraseOp ( FLASHDATA *   base_addr)
{
  DEVSTATUS    dev_status = DEV_STATUS_UNKNOWN;
  FLASHDATA    status_reg;

  if (ct001_lld_PpbLockBitReadOp(base_addr) == PPB_PROTECTED)    /* if it is already locked */
  {
    return(-1);                            /* return an error cuz Lock Bit is locked */
  }

  ct001_lld_PpbEntryCmd(base_addr);
  ct001_lld_PpbAllEraseCmd(base_addr);
  /* poll for completion */
  status_reg = ct001_lld_Poll(base_addr, 0);
  if( (status_reg & DEV_ERASE_MASK) == DEV_ERASE_MASK )
    dev_status =  DEV_ERASE_ERROR;    /* program error */
  else
    dev_status = DEV_NOT_BUSY;

  /* if not done, then we have an error */
  if (dev_status != DEV_NOT_BUSY)
  {
    /* Write Software RESET command */
    FLASH_WR(base_addr, 0, NOR_RESET_CMD);
    ct001_lld_PpbExitCmd(base_addr);
    return (-1); /* return error */
  }

  ct001_lld_PpbExitCmd(base_addr);    /* exit Ppb protection mode command */
  return 0; /* successful */
}

/******************************************************************************
* 
* ct001_lld_PpbProgramOp - Operation set the Persistent Protection for a sector.
*
* RETURNS: 0 Successful
*         -1 Failed
*
*/
int ct001_lld_PpbProgramOp ( FLASHDATA *base_addr, ADDRESS offset)
{
  DEVSTATUS    dev_status = DEV_STATUS_UNKNOWN;
  FLASHDATA    status_reg;
  
  if (ct001_lld_PpbLockBitReadOp(base_addr) == PPB_PROTECTED)      /* if it is already locked */
  {
    return(-1);                              /* return an error cuz Lock Bit is locked */
  }


  ct001_lld_PpbEntryCmd(base_addr);
  ct001_lld_PpbProgramCmd(base_addr, offset);

  /* poll for completion */
  status_reg = ct001_lld_Poll(base_addr, 0);
  if( (status_reg & DEV_PROGRAM_MASK) == DEV_PROGRAM_MASK )
    dev_status =  DEV_PROGRAM_ERROR;    /* program error */
  else
    dev_status = DEV_NOT_BUSY;

  /* if not done, then we have an error */
  if (dev_status != DEV_NOT_BUSY)
  {
    /* Write Software RESET command */
    FLASH_WR(base_addr, 0, NOR_RESET_CMD);
    ct001_lld_PpbExitCmd(base_addr);
    return (-1); /* return error */
  }

  ct001_lld_PpbExitCmd(base_addr);
  return 0; /* successful */
}

/******************************************************************************
* 
* ct001_lld_PpbStatusReadOp - Operation to read the Persistent Protection status register.
*
* RETURNS: FLASHDATA
*ct001_lld_read
*/

FLASHDATA ct001_lld_PpbStatusReadOp ( FLASHDATA *base_addr, ADDRESS offset)
{
  FLASHDATA  status;
  
  ct001_lld_PpbEntryCmd(base_addr);
  status = (FLASH_RD(base_addr, offset));
  ct001_lld_PpbExitCmd(base_addr);
  
  return status;

}

/******************************************************************************
* 
* ct001_lld_LockRegBitsReadOp - Operation to read the lock status register.
*
* RETURNS: FLASHDATA
*
*/
FLASHDATA ct001_lld_LockRegBitsReadOp ( FLASHDATA *base_addr)
{ 
  FLASHDATA value;

  ct001_lld_LockRegEntryCmd(base_addr);
  value = ct001_lld_LockRegBitsReadCmd(base_addr);
  ct001_lld_LockRegExitCmd(base_addr);

  return(value);
}


/******************************************************************************
* 
* ct001_lld_LockRegBitsProgramOp - Operation to program the lock register.
*
* RETURNS: 0 Successful
*         -1 Failed
*
*/
int ct001_lld_LockRegBitsProgramOp ( FLASHDATA *base_addr, FLASHDATA value)
{
  DEVSTATUS    dev_status = DEV_STATUS_UNKNOWN;
  FLASHDATA    status_reg;

  ct001_lld_LockRegEntryCmd(base_addr);
  ct001_lld_LockRegBitsProgramCmd(base_addr,value);

  /* poll for completion */
    status_reg = ct001_lld_Poll(base_addr, 0);
    if( (status_reg & DEV_PROGRAM_MASK) == DEV_PROGRAM_MASK )
      dev_status =  DEV_PROGRAM_ERROR;    /* program error */
  else
    dev_status = DEV_NOT_BUSY;

  /* if not done, then we have an error */
  if (dev_status != DEV_NOT_BUSY)
  {
     /* Write Software RESET command */
     FLASH_WR(base_addr, 0, NOR_RESET_CMD);
     ct001_lld_LockRegExitCmd(base_addr);
     return (-1); /* return error */
  }

  ct001_lld_LockRegExitCmd(base_addr);
  return 0; /* successful */
}







/**************************************************************************
* Special API for RPC2 device (KS-S/KL-S)
**************************************************************************/

/******************************************************************************
* 
* ct001_lld_EnterDeepPowerDownCmd - Enter Deep Power Down Command.
* Note: n/a
* RETURNS: n/a
*
*/
extern void ct001_lld_EnterDeepPowerDownCmd
(
  FLASHDATA *base_addr  /* device base address in system */
)
{
  /* Issue Enter Deep Power Down command */
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);
  FLASH_WR(base_addr, 0, NOR_ENTER_DEEP_POWER_DOWN_CMD);
}

/******************************************************************************
* 
* ct001_lld_ReleaseDeepPowerDownCmd - Release Deep Power Down.
* Note: 
*     mode = 0: issue write (e.g. a "dummy" write) to release deep power down (default)
*     mode = 1: issue read (e.g. read array) to release deep power down 
* RETURNS: n/a
*
*/
extern void ct001_lld_ReleaseDeepPowerDownCmd
(
  FLASHDATA *base_addr,  /* device base address in system */
  FLASHDATA mode            /* mode for release deep power down */
)
{
  switch (mode)  
  {
    case 0: /* issue write (e.g. a "dummy" write) to release deep power down (default)*/
      FLASH_WR(base_addr, 0x00000000, 0x0000);
      DelayMicroseconds(LLD_DPD_DELAY);
      break;
    case 1: /* issue read (e.g. read array) to release deep power down */
      ct001_lld_ReadOp(base_addr, 0);
      DelayMicroseconds(LLD_DPD_DELAY);
      break;
    default:
      FLASH_WR(base_addr, 0x00000000, 0x0000);
      DelayMicroseconds(LLD_DPD_DELAY);
      break;
  }
}

/******************************************************************************
* 
* ct001_lld_MeasureTemperatureCmd - Measure Temperature Command
* Note: n/a
* RETURNS: n/a
*
*/
extern void ct001_lld_MeasureTemperatureCmd
(
 FLASHDATA *base_addr
)
{
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_MEASURE_TEMPERATURE_CMD);
}

/******************************************************************************
* 
* ct001_lld_ReadTemperatureRegCmd - Read Temperature Register Command
* Note: n/a
* RETURNS: FLASHDATA
*
*/
extern FLASHDATA ct001_lld_ReadTemperatureRegCmd
(
 FLASHDATA *base_addr
)
{
  FLASHDATA value;

  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_READ_TEMPERATURE_REG_CMD);  
  value = (FLASH_RD(base_addr, 0));

  return(value);
}  

/******************************************************************************
* 
* ct001_lld_MeasureTemperatureRegOp - Read Temperature Register Operation
* Note: n/a
* RETURNS of API: 
*    DEVSTATUS   ---- Measure Temperature Status (failed or completed)
* RETURNS Parameter:
*    *temperature_reg   ----Pointer of Temperature Register Value
*
*/
extern DEVSTATUS ct001_lld_MeasureTemperatureRegOp
(
 FLASHDATA *base_addr,
 FLASHDATA *temperature_reg
)
{
  DEVSTATUS status;
  FLASHDATA status_reg;
 
  //Issue Measure Temperature Command
  ct001_lld_MeasureTemperatureCmd(base_addr);
  //Polling Status
  status_reg = ct001_lld_Poll(base_addr, 0);
  if( (status_reg & DEV_RDY_MASK) != DEV_RDY_MASK )
    status = DEV_BUSY;		/* measure failed */
  else
  {
    status = DEV_NOT_BUSY;			    /* measure complete */
    //Read Temperature Reg
    *temperature_reg = ct001_lld_ReadTemperatureRegCmd(base_addr);
  }
  
  return(status);
}  

/******************************************************************************
* 
* ct001_lld_ProgramPORTimerRegCmd - Program Power On Reset Timer Register Command
* Note: n/a
* RETURNS: n/a
*
*/
extern void ct001_lld_ProgramPORTimerRegCmd
(
 FLASHDATA *base_addr,
 FLASHDATA portime 			/* Power On Reset Time */
)
{
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_PROGRAM_POR_TIMER_CMD);
  FLASH_WR(base_addr, 0, portime);
}

/******************************************************************************
* 
* ct001_lld_ReadPORTimerRegCmd - Read Power On Reset Timer Register Command
* Note: n/a
* RETURNS: FLASHDATA
*
*/
extern FLASHDATA ct001_lld_ReadPORTimerRegCmd
(
 FLASHDATA *base_addr
)
{
  FLASHDATA value;
  
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_READ_POR_TIMER_CMD);
  value = (FLASH_RD(base_addr, 0));

  return(value);
}

/******************************************************************************
* 
* ct001_lld_LoadInterruptConfigRegCmd - Load Interrupt Configuration Register Command
* Note: n/a
* RETURNS: n/a
*
*/
extern void ct001_lld_LoadInterruptConfigRegCmd
(
 FLASHDATA *base_addr,
 FLASHDATA icr				/* Interrupt Configuration Register */
)
{
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_LOAD_INTERRUPT_CFG_REG_CMD);
  FLASH_WR(base_addr, 0, icr);
}

/******************************************************************************
* 
* ct001_lld_ReadInterruptConfigRegCmd - Read Interrupt Configuration Register Command
* Note: n/a
* RETURNS: FLASHDATA
*
*/
extern FLASHDATA ct001_lld_ReadInterruptConfigRegCmd
(
 FLASHDATA *base_addr
)
{
  FLASHDATA value;
  
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_READ_INTERRUPT_CFG_REG_CMD);
  value = (FLASH_RD(base_addr, 0));

  return(value);
}

/******************************************************************************
* 
* ct001_lld_LoadInterruptStatusRegCmd - Load Interrupt Status Register Command
* Note: n/a
* RETURNS: n/a
*
*/
extern void ct001_lld_LoadInterruptStatusRegCmd
(
 FLASHDATA *base_addr,
 FLASHDATA isr      /* Interrupt Status Register */
)
{
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_LOAD_INTERRUPT_STATUS_REG_CMD);
  FLASH_WR(base_addr, 0, isr);
}

/******************************************************************************
* 
* ct001_lld_ReadInterruptStatusRegCmd - Read Interrupt Status Register Command
* Note: n/a
* RETURNS: FLASHDATA
*
*/
extern FLASHDATA ct001_lld_ReadInterruptStatusRegCmd
(
 FLASHDATA *base_addr
)
{
  FLASHDATA value;
  
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_READ_INTERRUPT_STATUS_REG_CMD);
  value = (FLASH_RD(base_addr, 0));

  return(value);
}

/******************************************************************************
* 
* ct001_lld_LoadVolatileConfigRegCmd - Load Volatile Configuration Register Command
* Note: n/a
* RETURNS: n/a
*
*/
extern void ct001_lld_LoadVolatileConfigRegCmd
(
 FLASHDATA *base_addr,
 FLASHDATA vcr
)
{
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_LOAD_VOLATILE_CFG_REG_CMD);
  FLASH_WR(base_addr, 0, vcr);
}

/******************************************************************************
* 
* ct001_lld_ReadInterruptStatusRegCmd - Read Volatile Configuration Register Command
* Note: n/a
* RETURNS: FLASHDATA
*         
*/
extern FLASHDATA ct001_lld_ReadVolatileConfigRegCmd
(
 FLASHDATA *base_addr
)
{
  FLASHDATA value;
  
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_READ_VOLATILE_CFG_REG_CMD);
  value = (FLASH_RD(base_addr, 0));

  return(value);
}

/******************************************************************************
* 
* ct001_lld_ProgramVolatileConfigRegOp - Program Volatile Configuration Register Operation (with poll)
* Note: n/a
* RETURNS: DEVSTATUS
*         
*/
DEVSTATUS ct001_lld_ProgramVolatileConfigRegOp
(
 FLASHDATA *base_addr, 
 FLASHDATA vcr
)
{
  FLASHDATA status_reg;
  
  /* Load VCR */
  ct001_lld_LoadVolatileConfigRegCmd(base_addr, vcr);

  /* Poll for Program completion */
  status_reg = ct001_lld_Poll(base_addr, 0);

  if( (status_reg & DEV_PROGRAM_MASK) == DEV_PROGRAM_MASK )
	  return( DEV_PROGRAM_ERROR );		/* program error */

  return( DEV_NOT_BUSY );			    /* program complete */
}

/******************************************************************************
* 
* ct001_lld_ProgramNonVolatileConfigRegCmd - Program Non-Volatile Configuration Register Command
* Note: n/a
* RETURNS: n/a
*
*/
extern void ct001_lld_ProgramNonVolatileConfigRegCmd
(
 FLASHDATA *base_addr, 
 FLASHDATA nvcr
)
{
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_LOAD_VOLATILE_CFG_REG_CMD);
  FLASH_WR(base_addr, 0, nvcr);
}

/******************************************************************************
* 
* ct001_lld_EraseNonVolatileConfigRegCmd - Erase Non-Volatile Configuration Register Command
* Note: n/a
* RETURNS: n/a
*
*/
extern void ct001_lld_EraseNonVolatileConfigRegCmd
(
 FLASHDATA *base_addr
)
{
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_ERASE_NON_VOLATILE_CFG_REG_CMD);
}

/******************************************************************************
* 
* ct001_lld_ReadNonVolatileConfigRegCmd - Read Non-Volatile Configuration Register Command
* Note: n/a
* RETURNS: FLASHDATA
*
*/
extern FLASHDATA ct001_lld_ReadNonVolatileConfigRegCmd
(
 FLASHDATA *base_addr
)
{
  FLASHDATA value;
  
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_READ_NON_VOLATILE_CFG_REG_CMD);
  value = (FLASH_RD(base_addr, 0));

  return(value);
}

/******************************************************************************
* 
* ct001_lld_ProgramNonVolatileConfigRegOp - Program Non-Volatile Configuration Register Operation (with poll)
* Note: n/a
* RETURNS: DEVSTATUS
*         
*/
DEVSTATUS ct001_lld_ProgramNonVolatileConfigRegOp
(
 FLASHDATA *base_addr,
 FLASHDATA nvcr
)
{
  FLASHDATA status_reg;

  /* Erase NVCR */
  ct001_lld_EraseNonVolatileConfigRegCmd(base_addr);

  /* Poll for erase completion */
  status_reg = ct001_lld_Poll(base_addr, 0);
  if( (status_reg & DEV_ERASE_MASK) == DEV_ERASE_MASK )
    return( DEV_ERASE_ERROR );		/* erase  error */

  /* Program NVCR */
  ct001_lld_ProgramNonVolatileConfigRegCmd(base_addr, nvcr);

  /* Poll for program completion */
  status_reg = ct001_lld_Poll(base_addr, 0);
  if( (status_reg & DEV_PROGRAM_MASK) == DEV_PROGRAM_MASK )
    return( DEV_PROGRAM_ERROR );		/* program error */

  return( DEV_NOT_BUSY );			    /* program complete */
}

/******************************************************************************
* 
* ct001_lld_EvaluateEraseStatusCmd - Evaluate Erase Status Command
* Note: n/a
* RETURNS: n/a
*
*/
extern void ct001_lld_EvaluateEraseStatusCmd
(
 FLASHDATA *base_addr, 
 ADDRESS   offset
)
{
  /* Write Evaluate Erase Status Command to Offset */
  FLASH_WR(base_addr, (offset & SA_OFFSET_MASK) + LLD_UNLOCK_ADDR1, NOR_EVALUATE_ERASE_STATUS_CMD);
}

/******************************************************************************
* 
* ct001_lld_CRCEnterCmd - CRC Enter Command
* Note: n/a
* RETURNS: n/a
*
*/
extern void ct001_lld_CRCEnterCmd
(
 FLASHDATA *base_addr
)
{
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_UNLOCK_DATA1);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR2, NOR_UNLOCK_DATA2);
  FLASH_WR(base_addr, LLD_UNLOCK_ADDR1, NOR_CRC_ENTRY_CMD);
}

/******************************************************************************
* 
* ct001_lld_LoadCRCStartAddrCmd - Load CRC Start Address
* Note: n/a
* RETURNS: n/a
*
*/
extern void ct001_lld_LoadCRCStartAddrCmd
(
 FLASHDATA *base_addr, 
 ADDRESS   bl             /* Beginning location of checkvalue calculation */
)
{
  FLASH_WR(base_addr, bl, NOR_LOAD_CRC_START_ADDR_CMD);
}

/******************************************************************************
* 
* ct001_lld_LoadCRCEndAddrCmd - Load CRC End Address (start calculation)
* Note: n/a
* RETURNS: n/a
*
*/
extern void ct001_lld_LoadCRCEndAddrCmd
(
 FLASHDATA *base_addr, 
 ADDRESS   el             /* Ending location of checkvalue calculation */
)
{
  FLASH_WR(base_addr, el, NOR_LOAD_CRC_END_ADDR_CMD);
}

/******************************************************************************
* 
* ct001_lld_CRCSuspendCmd - CRC Suspend
* Note: n/a
* RETURNS: n/a
*
*/
extern void ct001_lld_CRCSuspendCmd
(
 FLASHDATA *base_addr
)
{
  FLASH_WR(base_addr, 0, NOR_CRC_SUSPEND_CMD);
}

/******************************************************************************
* 
* ct001_lld_CRCArrayReadCmd - Array Read (during suspend)
* Note: n/a
* RETURNS: FLASHDATA
*
*/
extern FLASHDATA ct001_lld_CRCArrayReadCmd
(
 FLASHDATA *base_addr, 
 ADDRESS   offset           /* Array Read Address */
)
{
  FLASHDATA value;
  value = (FLASH_RD(base_addr, offset));
  return(value);  
}

/******************************************************************************
* 
* ct001_lld_CRCResumeCmd - CRC Resume
* Note: n/a
* RETURNS: n/a
*
*/
extern void ct001_lld_CRCResumeCmd
(
 FLASHDATA *base_addr
)
{
  FLASH_WR(base_addr, 0, NOR_CRC_RESUME_CMD);
}

/******************************************************************************
* 
* ct001_lld_ReadCheckvalueLowResultRegCmd - Read Checkvalue Low Result Register
* Note: n/a
* RETURNS: FLASHDATA
*
*/
extern FLASHDATA ct001_lld_ReadCheckvalueLowResultRegCmd
(
 FLASHDATA *base_addr
)
{
  FLASHDATA value;
  FLASH_WR(base_addr, 0, NOR_CRC_READ_CHECKVALUE_RESLUT_REG_CMD);
  value = (FLASH_RD(base_addr, 0x00));
  return(value);  
}

/******************************************************************************
* 
* ct001_lld_ReadCheckvalueHighResultRegCmd - Read Checkvalue High Result Register
* Note: n/a
* RETURNS: FLASHDATA
*
*/
extern FLASHDATA ct001_lld_ReadCheckvalueHighResultRegCmd
(
 FLASHDATA *base_addr
)
{
  FLASHDATA value;
  FLASH_WR(base_addr, 0, NOR_CRC_READ_CHECKVALUE_RESLUT_REG_CMD);
  value = (FLASH_RD(base_addr, 0x01));
  return(value);  
}

/******************************************************************************
* 
* ct001_lld_CRCExitCmd - CRC Exit Command
* Note: n/a
* RETURNS: n/a
*
*/
extern void ct001_lld_CRCExitCmd
(
 FLASHDATA *base_addr
)
{
  FLASH_WR(base_addr, 0, NOR_CRC_EXIT_CMD);
}

/******************************************************************************
* 
* ct001_lld_PpbSAProtectStatusCmd
* Note: 
* RETURNS: FLASHDATA
*
*/
extern FLASHDATA ct001_lld_PpbSAProtectStatusCmd
(
 FLASHDATA *base_addr,   /* device base address in system */
 ADDRESS   offset        /* Sector Address for status read */
)
{
  FLASHDATA value;
  
  FLASH_WR(base_addr, 0, NOR_SA_PROTECT_STATUS_CMD);
  value = (FLASH_RD(base_addr, offset));
  return(value);
}

/******************************************************************************
* 
* ct001_lld_DybSAProtectStatusCmd
* Note: 
* RETURNS: FLASHDATA
*
*/
extern FLASHDATA ct001_lld_DybSAProtectStatusCmd
(
 FLASHDATA *base_addr,   /* device base address in system */
 ADDRESS   offset        /* Sector Address for status read */
)
{
  FLASHDATA value;
  
  FLASH_WR(base_addr, 0, NOR_SA_PROTECT_STATUS_CMD);
  value = (FLASH_RD(base_addr, offset));
  return(value);
}
