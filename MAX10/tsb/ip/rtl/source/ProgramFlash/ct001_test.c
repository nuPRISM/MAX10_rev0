  /**************************************************************************
  * Copyright (C)2016 - 2020 Synaptic Laboratories Ltd All Rights Reserved.
  *
  * This source code is owned and published by:
  * Synaptic Laboratories Ltd .
 */

/**************************************************************************
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

//#include <stdio.h>
#include <stddef.h>
#include <stdio.h>
#include "io.h"
#include "sys/alt_errno.h"
#include "altera_avalon_jtag_uart_regs.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"

#include "ct001_lld_target_specific.h"
#include "ct001_S26KSxxxS_S26KLxxxS.h"

/*
 * Typically:
 *
 * 	Span = 128 KB
 */

int main( void )
{
	int errors = 0;

		unsigned long span_in_bytes = 128*1024;
		
		printf("\n\n****************************************************************\n");
		printf("Test Synaptic Labs - Cypress LLD Test 001  \n");
		printf("****************************************************************\n\n");

		ct001_test( HYPERFLASH_BASE, HYPERRAM_BASE, span_in_bytes );

   while (1);
}

int alt_read_cfi_width(FLASHDATA * base_addr);


int ct001_test( unsigned long hb_flash_base, unsigned long sdram_base, unsigned long span_in_bytes )
{
  int errors = 0;
  int initial_seed = rand();
  int flash_reg, status;
  int data_addr_offset = 0;
  int data_addr_count  = span_in_bytes;

  unsigned long i    = 0;
  unsigned long  readback, cmp_data;

  FLASHDATA * 		hyperflash_08 = (FLASHDATA *) 	  (hb_flash_base);
  unsigned long *	hyperflash_32 = (unsigned long *) (hb_flash_base);

  FLASHDATA *	  	sdram_08      = (FLASHDATA *)    (sdram_base);
  unsigned long *	sdram_32      = (unsigned long*) (sdram_base);


  printf("Testing HyperFLASH using Cypress's Low Level Driver (LLD)\n");
  printf("FLASH  : 0x%08lX\n", hb_flash_base);
  printf("R/W MEM: 0x%08lX\n", sdram_base);
  printf("SPAN   : 0x%8lX\n", span_in_bytes);

  //----------------------------------------------------------------------------
  //Flash test
  //----------------------------------------------------------------------------
   
   alt_read_cfi_width(hyperflash_08);
 
  //----------------------------------------------------------------------------
  //Flash test
  //----------------------------------------------------------------------------
  printf(" Query Flash...\n");

  flash_reg = ct001_lld_Poll(hyperflash_08, 0);
  printf("  Status Register    : %04X \n",flash_reg);

//Reset Command
  ct001_lld_ResetCmd (hyperflash_08);

  flash_reg = ct001_lld_Poll(hyperflash_08, 0);
  printf("  Status Register    : %04X \n",flash_reg);

  flash_reg = ct001_lld_ReadCfiWord(hyperflash_08, 0x0);
  printf("  Manufacturer ID    : %04X \n", flash_reg );
  if (flash_reg != 0x0001) {
	 errors += 1;
  }

  flash_reg = ct001_lld_ReadCfiWord(hyperflash_08, 0x1);
  printf("  Device ID          : %04X \n",flash_reg);
  if (flash_reg != 0x007E) {
	  errors += 1;
  }

  flash_reg = ct001_lld_ReadCfiWord(hyperflash_08, 0xC);
  printf("  Lower SW Bits      : %04X \n", flash_reg);
  if (flash_reg != 0x0005) {
	  errors += 1;
  }

  flash_reg = ct001_lld_ReadCfiWord(hyperflash_08, 0xe);
  printf("  Device ID 2        : %04X \n", flash_reg);
  if (flash_reg != 0x0070) {
	  errors += 1;
  }


  flash_reg = ct001_lld_Poll(hyperflash_08, 0);
  printf("  Status Register    : %04X \n",flash_reg);

  printf("  CFI TABEL CHECK    : ");

  if (errors != 0) {
	  printf("FAIL - %d errors.\n", errors);
  }else{
	  printf("PASS\n");
  }

  printf(" Program Flash...\n");

  //----------------------------------------------------------------------------
  //fill part of SDRAM, so it can then copy it
  //----------------------------------------------------------------------------
  if (!errors){
	  printf("  Fill SDRAM with bit pattern that we will then write to Flash.\n");
	  for (i=0; i < (data_addr_count/4); i++) {
		  sdram_32[i] = initial_seed + i + ((i+1)<<16);
	  }
  }

  //----------------------------------------------------------------------------
  //Erase Sector
  //----------------------------------------------------------------------------
  if (!errors){
	  printf("  Erase Sector 0 of Flash : ");
	  status = ct001_lld_SectorEraseOp (hyperflash_08, data_addr_offset);

	  if (status != DEV_NOT_BUSY) {
		  printf("FAIL with error status 0x%04x  \n", status);
		  errors += 1;
	  } else {
		  printf("PASS \n");
	  }
  }

  //----------------------------------------------------------------------------
  //Programming start
  //----------------------------------------------------------------------------
  if (!errors){
	  printf("  Program Sector 0 of Flash : " );
	  status = ct001_lld_memcpy (hyperflash_08, data_addr_offset, data_addr_count, sdram_08);

	  if (status != DEV_NOT_BUSY) {
		  printf("FAIL with error status 0x%04x  \n", status);
		  errors += 1;
	  } else {
		  printf("PASS \n");
	  }
  }

  //----------------------------------------------------------------------------
  //Compare data
  //----------------------------------------------------------------------------
  if (!errors){
	  printf("  Verify  Sector 0 of Flash : ");
	  for (i=0; i< data_addr_count/4; i++) {
		  readback = hyperflash_32[data_addr_offset+i];
		  cmp_data = initial_seed + i + ((i+1)<<16);
		  if (cmp_data != readback) {
			  printf("\n  FAIL - Data should be 0x%08lX but was 0x%08lX", i, readback);
			  errors += 1;
		  }
	  }
	  if( !errors ){
		  printf("PASS\n");
	  }else{
		  printf("\n");
	  }
  }

  //----------------------------------------------------------------------------
  //Erase Sector
  //----------------------------------------------------------------------------
  if (!errors){
	  printf("  Erase   Sector 0 of Flash : ");
	  status = ct001_lld_SectorEraseOp (hyperflash_08, data_addr_offset);

	  if (status != DEV_NOT_BUSY) {
		  printf("FAIL with error status 0x%04X\n", status);
		  errors += 1;
	  } else {
		  printf("PASS \n");
	  }
  }

  if (errors) {
    printf(" TEST FAIL - Flash Programming with %d errors\n", errors);
  } else {
    printf(" TEST PASS - Flash Programming done\n");
  }  

  return errors;
}


/*
 * Write an 8 bit command to a flash
 */
void alt_write_flash_command_8bit_device_8bit_mode( void* base_addr, int offset, alt_u8 value)
{
  IOWR_8DIRECT(base_addr, offset, value);
  return;
}

void alt_write_flash_command_16bit_device_8bit_mode( void* base_addr, int offset, alt_u8 value)
{
  if (offset % 2)
  {
    IOWR_8DIRECT(base_addr, offset*2, value);
  }
  else
  {
    IOWR_8DIRECT(base_addr, (offset*2)+1, value);
  }
  return;
}

void alt_write_flash_command_32bit_device_8bit_mode( void* base_addr, int offset, alt_u8 value)
{
  IOWR_8DIRECT(base_addr, offset*4, value);
  return;
}

void alt_write_flash_command_16bit_device_16bit_mode( void* base_addr, int offset, alt_u8 value)
{
  IOWR_16DIRECT(base_addr, offset*2, ((alt_u16)value)& 0x00ff);
  return;
}

void alt_write_flash_command_32bit_device_16bit_mode( void* base_addr, int offset, alt_u8 value)
{
  IOWR_16DIRECT(base_addr, offset*4, ((alt_u16)value)& 0x00ff);
  return;
}

void alt_write_flash_command_32bit_device_32bit_mode( void* base_addr, int offset, alt_u8 value)
{
  IOWR_32DIRECT(base_addr, offset*4, ((alt_u32)value)& 0x000000ff);
  return;
}

#define READ_ARRAY_INTEL_MODE   (alt_u8)0xFF
#define READ_ARRAY_AMD_MODE   	(alt_u8)0xF0
#define QUERY_MODE        	    (alt_u8)0x98

#define QUERY_ADDR              0x10 
#define PRIMARY_ADDR            0x15
#define INTERFACE_ADDR          0x28


/*
 * alt_read_cfi_width
 * 
 * Work out the width of the device we're talking to and sanity check that we  
 * can read the CFI and the Primary Vendor specific Table
 */
int alt_read_cfi_width(FLASHDATA * base_addr)
{
  int i;
  alt_u8 byte_id[12];
  alt_u16 iface;
  int ret_code = 0;

  /*
  * Check for 8 bit wide flash
  */
  alt_write_flash_command_8bit_device_8bit_mode(base_addr, 0x55, QUERY_MODE);

  for(i=0;i<3;i++)
  {
    byte_id[i] = IORD_8DIRECT(base_addr, QUERY_ADDR+i);
  }
  
  printf("ID : %0x %0x %0x \n", byte_id[0], byte_id[1], byte_id[2]);
   
  if ((byte_id[0] == 'Q') &&
      (byte_id[1] == 'R') &&
      (byte_id[2] == 'Y'))
  {        
  	 printf("alt_write_flash_command_8bit_device_8bit_mode \n"); 	 
  }
  else
  {
    /*
    * Check for 8/16 bit in byte wide mode
    */
    alt_write_flash_command_16bit_device_8bit_mode(base_addr, 0x55, QUERY_MODE);
    for(i=0;i<6;i++)
    {
      byte_id[i] = IORD_8DIRECT(base_addr, (QUERY_ADDR*2)+i);
    }

  printf("ID1.0 : %0x %0x %0x \n", byte_id[0], byte_id[1], byte_id[2]);
  printf("ID1.1 : %0x %0x %0x \n", byte_id[3], byte_id[4], byte_id[5]);


    if ((byte_id[0] == 'Q') && 
        (byte_id[1] == 'Q') && 
        (byte_id[2] == 'R') &&
        (byte_id[3] == 'R') && 
        (byte_id[4] == 'Y') && 
        (byte_id[5] == 'Y'))
    {
  	 printf("alt_write_flash_command_16bit_device_8bit_mode \n");
    }
    else
    {
      /*
      * Check for 16 bit flash in word mode
      */
      alt_write_flash_command_16bit_device_16bit_mode(base_addr, 0x55, QUERY_MODE);
      for(i=0;i<6;i++)
      {
        byte_id[i] = IORD_8DIRECT(base_addr, (QUERY_ADDR*2)+i);
      }

      printf("ID2.0 : %0x %0x %0x \n", byte_id[0], byte_id[1], byte_id[2]);
      printf("ID2.1 : %0x %0x %0x \n", byte_id[3], byte_id[4], byte_id[5]);

      if ((byte_id[0] == 'Q') && 
          (byte_id[1] == '\0') && 
          (byte_id[2] == 'R') && 
          (byte_id[3] == '\0') && 
          (byte_id[4] == 'Y') && 
          (byte_id[5] == '\0'))
      {
  	 printf("alt_write_flash_command_16bit_device_16bit_mode \n" );

        iface = IORD_16DIRECT(base_addr, INTERFACE_ADDR*2);
      	 printf("iface %x \n" , iface);
        iface = iface | 2;
      	 printf("iface %x \n" , iface);

        if (!(iface & 0x2))
        {
          ret_code = -ENODEV;
        }

      }
      else
      {
        /*
        * Check for 32bit wide flash in 32 bit mode
        */
        alt_write_flash_command_32bit_device_32bit_mode(base_addr, 0x55, QUERY_MODE);
        for(i=0;i<12;i++)
        {
          byte_id[i] = IORD_8DIRECT(base_addr, (QUERY_ADDR*4)+i);
        }

        printf("ID3.0 : %0x %0x %0x \n", byte_id[0], byte_id[1], byte_id[2]);
        printf("ID3.1 : %0x %0x %0x \n", byte_id[3], byte_id[4], byte_id[5]);
        printf("ID3.2 : %0x %0x %0x \n", byte_id[6], byte_id[7], byte_id[8]);
        printf("ID3.3 : %0x %0x %0x \n", byte_id[9], byte_id[10], byte_id[11]);

        if ((byte_id[0] == 'Q') &&
          (byte_id[1] == '\0') && 
          (byte_id[2] == '\0') && 
          (byte_id[3] == '\0') && 
          (byte_id[4] == 'R') && 
          (byte_id[5] == '\0') && 
          (byte_id[6] == '\0') && 
          (byte_id[7] == '\0') && 
          (byte_id[8] == 'Y') && 
          (byte_id[9] == '\0') && 
          (byte_id[10] == '\0') && 
          (byte_id[11] == '\0'))
        {
         printf("alt_write_flash_command_32bit_device_32bit_mode \n");
        }
        else
        {
          /*
          * Check for 32 bit wide in 16 bit mode
          */
          alt_write_flash_command_32bit_device_16bit_mode(base_addr, 0x55, QUERY_MODE);
          for(i=0;i<12;i++)
          {
            byte_id[i] = IORD_8DIRECT(base_addr, (QUERY_ADDR*4)+i);
          }

        printf("ID4.0 : %0x %0x %0x \n", byte_id[0], byte_id[1], byte_id[2]);
        printf("ID4.1 : %0x %0x %0x \n", byte_id[3], byte_id[4], byte_id[5]);
        printf("ID4.2 : %0x %0x %0x \n", byte_id[6], byte_id[7], byte_id[8]);
        printf("ID4.3 : %0x %0x %0x \n", byte_id[9], byte_id[10], byte_id[11]);
        
          if ((byte_id[0] == 'Q') &&
              (byte_id[1] == '\0') &&
              (byte_id[2] == 'Q') &&
              (byte_id[3] == '\0') &&
              (byte_id[4] == 'R') &&
              (byte_id[5] == '\0') &&
              (byte_id[6] == 'R') &&
              (byte_id[7] == '\0') &&
              (byte_id[8] == 'Y') &&
              (byte_id[9] == '\0') &&
              (byte_id[10] == 'Y') &&
              (byte_id[11] == '\0'))
          {
         printf("alt_write_flash_command_32bit_device_16bit_mode \n");
          }
          else
          {
            /*
            * 32 Bit wide flash in byte mode
            */
            alt_write_flash_command_32bit_device_8bit_mode(base_addr, 0x55, QUERY_MODE);
            for(i=0;i<12;i++)
            {
              byte_id[i] = IORD_8DIRECT(base_addr, (QUERY_ADDR*4)+i);
            }

        printf("ID5.0 : %0x %0x %0x \n", byte_id[0], byte_id[1], byte_id[2]);
        printf("ID5.1 : %0x %0x %0x \n", byte_id[3], byte_id[4], byte_id[5]);
        printf("ID5.2 : %0x %0x %0x \n", byte_id[6], byte_id[7], byte_id[8]);
        printf("ID5.3 : %0x %0x %0x \n", byte_id[9], byte_id[10], byte_id[11]);
        
            if ((byte_id[0] == 'Q') &&
                (byte_id[1] == 'Q') &&
                (byte_id[2] == 'Q') &&
                (byte_id[3] == 'Q') &&
                (byte_id[4] == 'R') && 
                (byte_id[5] == 'R') && 
                (byte_id[6] == 'R') && 
                (byte_id[7] == 'R') && 
                (byte_id[8] == 'Y') && 
                (byte_id[9] == 'Y') && 
                (byte_id[10] == 'Y') && 
                (byte_id[11] == 'Y'))
            {
         printf("alt_write_flash_command_32bit_device_8bit_mode \n");
            }
          }
        }
      }
    }
  }
  
  return ret_code;
}
