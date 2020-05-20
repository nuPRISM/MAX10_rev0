
#include <stdio.h>
#include <string.h>
#include <io.h>
#include "sys/alt_cache.h"
#include "system.h"

#include "db_tests.h"


//--------------------------------------------------------------------------------------------------------------------------
// Test bits 0 through 31 to make sure the data path bus connections are all working
//
int db_tests_single_data_bit_test(unsigned long base, int use_printf )
{
	int errors = 0;
    unsigned long i;
    unsigned long readback;

    if( use_printf ){ printf("\nDevBoards Test: Sliding single data bit test within 32-bit word at Address: 0x%08lX\n", base); }

    for (i = 0; i <= 31; i++)
    {
      unsigned long test_value = 1 << i;

      // Test bits 0 through 31 to make sure the data path bus connections are all working
      IOWR_32DIRECT(base, 0, test_value);
      readback = IORD_32DIRECT(base, 0);

      if (readback != test_value){
    	  if( use_printf ){ printf("  - ERROR: Value should be 0x%08lXU but is 0x%08lX\n", test_value, readback); }
        errors++;
      }
   }

  if (!errors){
	  if( use_printf ){ printf("  - PASS\n\n"); }
  }
  return (errors);
}

static int db_tests_byte_check_report_08bits( unsigned char target, unsigned char value, int errors, int use_printf ){
	if(value != target){
		if( use_printf ){ printf("FAIL: should be 0x%02X but is 0x%02X\n", target, value); }
		return errors+1;
	}else{
		if( use_printf ){ printf("PASS\n"); }
		return errors;
	}
}

static int db_tests_byte_check_report_16bits( unsigned short target, unsigned short value, int errors, int use_printf ){
	if(value != target){
		if( use_printf ){ printf("FAIL: should be 0x%04X but is 0x%04X\n", target, value); }
		return errors+1;
	}else{
		if( use_printf ){ printf("PASS\n"); }
		return errors;
	}
}

static int db_tests_byte_check_report_32bits( unsigned int target, unsigned int value, int errors, int use_printf ){
	if(value != target){
		if( use_printf ){ printf("FAIL: should be 0x%08X but is 0x%08X\n", target, value); }
		return errors+1;
	}else{
		if( use_printf ){ printf("PASS\n"); }
		return errors;
	}
}


//--------------------------------------------------------------------------------------------------------------------------
// Test the Byte Enable logic on the target memory
//
int db_tests_byte_enable_test(unsigned long base, int use_printf )
{
  unsigned long  	d32;
  unsigned short 	d16;
  unsigned char  	d08;
  int 			 	errors = 0;
//  volatile unsigned long*	sdram = (unsigned long*)base;

  if( use_printf ){ printf("\nDevBoards Test: SDRAM 8/16 bit Byte Enable Test at address: 0x%08lX\n", base); }

//  printf( " = Flush all data cache\n");
  alt_dcache_flush_all();

//  printf( " = Invalidate word\n");
  IOWR_32DIRECT(base, 0, 0xdeadbeef);

//  printf( " = Flush all data cache\n");
  alt_dcache_flush_all();


  /////////////////////////////////////////////////////////////////////

  if( use_printf ){  printf(" = 4x08-bit Write:\n"); }
  IOWR_8DIRECT(base, 0, 0x0A);		//  sdram[0] = 0x0A;
  IOWR_8DIRECT(base, 1, 0x05);		//	sdram[1] = 0x05;
  IOWR_8DIRECT(base, 2, 0xA0);		//	sdram[2] = 0xA0;
  IOWR_8DIRECT(base, 3, 0x50);		//	sdram[3] = 0x50;

//  printf( "   - Flush all data cache\n");
  alt_dcache_flush_all();

  if( use_printf ){ printf("   - 32-bit Read [0]:  " );}
  d32 = IORD_32DIRECT( base, 0 );  	//  d = sdram[0];
  errors = db_tests_byte_check_report_32bits( 0x50A0050A, d32, errors, use_printf  );

  if( use_printf ){ printf("   - 16-bit Read [0]:  "); }
  d16 = IORD_16DIRECT( base, 0 );	//  d16 = sdram16[0];
  errors = db_tests_byte_check_report_16bits( 0x050a, d16, errors, use_printf  );

  if( use_printf ){ printf("   - 16-bit Read [1]:  "); }
  d16 = IORD_16DIRECT( base, 2 );	//  d16 = sdram16[1];
  errors = db_tests_byte_check_report_16bits( 0x50A0, d16, errors, use_printf  );

  if( use_printf ){ printf("   - 08-bit Read [0]:  "); }
  d08 = IORD_8DIRECT( base, 0 );  	//  d = sdram[0];
  errors = db_tests_byte_check_report_08bits( 0x0A, d08, errors, use_printf  );

  if( use_printf ){ printf("   - 08-bit Read [1]:  "); }
  d08 = IORD_8DIRECT( base, 1 );  	//  d = sdram[1];
  errors = db_tests_byte_check_report_08bits( 0x05, d08, errors, use_printf  );

  if( use_printf ){ printf("   - 08-bit Read [2]:  "); }
  d08 = IORD_8DIRECT( base, 2 );  	//  d = sdram[2];
  errors = db_tests_byte_check_report_08bits( 0xA0, d08, errors, use_printf  );

  if( use_printf ){ printf("   - 08-bit Read [3]:  "); }
  d08 = IORD_8DIRECT( base, 3 );  	//  d = sdram[3];
  errors = db_tests_byte_check_report_08bits( 0x50, d08, errors, use_printf  );


  /////////////////////////////////////////////////////////////////////

//  printf(" = Invalidate word\n");
  IOWR_32DIRECT(base, 0, 0xdeadbeef);

//  printf( " = Flush all data cache\n");
  alt_dcache_flush_all();

  if( use_printf ){ printf(" = 2x16-bit Write:\n"); }
  IOWR_16DIRECT(base, 0, 0x050a);		//  sdram16[0] = 0x050a;
  IOWR_16DIRECT(base, 2, 0x50a0);		//	sdram16[1] = 0x50a0;

//  printf( "   - Flush all data cache\n");
  alt_dcache_flush_all();

  if( use_printf ){ printf("   - 32-bit Read [0]:  " ); }
  d32 = IORD_32DIRECT( base, 0 );  	//  d = sdram[0];
  errors = db_tests_byte_check_report_32bits( 0x50A0050A, d32, errors, use_printf  );

  if( use_printf ){ printf("   - 16-bit Read [0]:  "); }
  d16 = IORD_16DIRECT( base, 0 );	//  d16 = sdram16[0];
  errors = db_tests_byte_check_report_16bits( 0x050a, d16, errors, use_printf  );

  if( use_printf ){  printf("   - 16-bit Read [1]:  "); }
  d16 = IORD_16DIRECT( base, 2 );	//  d16 = sdram16[1];
  errors = db_tests_byte_check_report_16bits( 0x50A0, d16, errors, use_printf  );

  if( use_printf ){ printf("   - 08-bit Read [0]:  "); }
  d08 = IORD_8DIRECT( base, 0 );  	//  d = sdram[0];
  errors = db_tests_byte_check_report_08bits( 0x0A, d08, errors, use_printf  );

  if( use_printf ){ printf("   - 08-bit Read [1]:  "); }
  d08 = IORD_8DIRECT( base, 1 );  	//  d = sdram[1];
  errors = db_tests_byte_check_report_08bits( 0x05, d08, errors, use_printf  );

  if( use_printf ){ printf("   - 08-bit Read [2]:  "); }
  d08 = IORD_8DIRECT( base, 2 );  	//  d = sdram[2];
  errors = db_tests_byte_check_report_08bits( 0xA0, d08, errors, use_printf  );

  if( use_printf ){ printf("   - 08-bit Read [3]:  "); }
  d08 = IORD_8DIRECT( base, 3 );  	//  d = sdram[3];
  errors = db_tests_byte_check_report_08bits( 0x50, d08, errors, use_printf  );


  /////////////////////////////////////////////////////////////////////

//  printf(" = Invalidate word\n");
  IOWR_32DIRECT(base, 0, 0xdeadbeef);

//  printf( " = Flush all data cache\n");
  alt_dcache_flush_all();

  if( use_printf ){ printf(" = 1x32-bit Write:\n"); }
  IOWR_32DIRECT(base, 0, 0x50a0050a);		//  sdram32[0] = 0x50a0050a;

//  printf( "   - Flush all data cache\n");
  alt_dcache_flush_all();

  if( use_printf ){ printf("   - 32-bit Read [0]:  " ); }
  d32 = IORD_32DIRECT( base, 0 );  	//  d = sdram[0];
  errors = db_tests_byte_check_report_32bits( 0x50A0050A, d32, errors, use_printf  );

  if( use_printf ){ printf("   - 16-bit Read [0]:  "); }
  d16 = IORD_16DIRECT( base, 0 );	//  d16 = sdram16[0];
  errors = db_tests_byte_check_report_16bits( 0x050a, d16, errors, use_printf  );

  if( use_printf ){ printf("   - 16-bit Read [1]:  "); }
  d16 = IORD_16DIRECT( base, 2 );	//  d16 = sdram16[1];
  errors = db_tests_byte_check_report_16bits( 0x50A0, d16, errors, use_printf  );

  if( use_printf ){ printf("   - 08-bit Read [0]:  "); }
  d08 = IORD_8DIRECT( base, 0 );  	//  d = sdram[0];
  errors = db_tests_byte_check_report_08bits( 0x0A, d08, errors, use_printf  );

  if( use_printf ){ printf("   - 08-bit Read [1]:  "); }
  d08 = IORD_8DIRECT( base, 1 );  	//  d = sdram[1];
  errors = db_tests_byte_check_report_08bits( 0x05, d08, errors, use_printf  );

  if( use_printf ){ printf("   - 08-bit Read [2]:  "); }
  d08 = IORD_8DIRECT( base, 2 );  	//  d = sdram[2];
  errors = db_tests_byte_check_report_08bits( 0xA0, d08, errors, use_printf  );

  if( use_printf ){ printf("   - 08-bit Read [3]:  "); }
  d08 = IORD_8DIRECT( base, 3 );  	//  d = sdram[3];
  errors = db_tests_byte_check_report_08bits( 0x50, d08, errors, use_printf  );


  if (!errors){
	  if( use_printf ){ printf("\n = All Byte Enabled Tests Passed\n\n"); }
  }
  return (errors);
}


//--------------------------------------------------------------------------------------------------------------------------
//
// This tests that values can be assigned to EVERY address in the SDRAM address space
//

int db_tests_read_write_span_accessibility_test(unsigned long base, unsigned long span, int use_printf )
{
	int errors = 0;
    unsigned long readback;
    unsigned long *sdram = (unsigned long*) (base);
    unsigned long index;

    if( use_printf ){ printf("\nDevBoards Test: Read and Write to each 32-bit word in range 0x%08lX to 0x%08lX\n", base, (base+span)); }

 //   printf("  - Invalidate contents of memory region using memset\n");
    memset( sdram, 0xDEADBEEF, span );

//    printf("  - Flush all of L1 data cache\n");
    alt_dcache_flush_all();

    if( use_printf ){  printf("  - Writing value of index into each 32-bit word of span using IOWR operations\n"); }
    for (index = 0; index < (span / 4); index++) {
    	IOWR_32DIRECT(base, index * 4, index);
    }

//    printf("  - Flush all of L1 data cache\n");
    alt_dcache_flush_all();

    if( use_printf ){ printf("  - Reading value of index from each 32-bit word of span using IORD operations\n"); }
    for (index = 0; index < (span / 4); index++) {
      //check that the value at the current SDRAM address is what we assigned it to
      readback = IORD_32DIRECT(base, index * 4);
      if (readback != index){
    	  if( use_printf ){ printf("    - ERROR    Value should be 0x%08lX but is 0x%08lX at 0x%08lX\n", index, readback, index*4); }
        errors++;
      }
    }
    if ( errors == 0 ){
    	if( use_printf ){ printf("    - PASS verification test\n"); }
    }else{
    	if( use_printf ){ printf("    - FAIL with %d errors\n", errors); }
    }

    errors = 0;

//    printf("  - Invalidate contents of memory region using memset\n");
    memset( sdram, 0xDEADBEEF, span );

//    printf("  - Flush all of L1 data cache\n");
    alt_dcache_flush_all();

    if( use_printf ){ printf("  - Writing value of index into each 32-bit word of span using (cacheable) WR operations\n"); }
    for (index = 0; index < (span / 4); index++){
    	sdram[index] = index;
    }

//    printf("  - Flush all of L1 data cache\n");
    alt_dcache_flush_all();

    if( use_printf ){ printf("  - Reading value of index from each 32-bit word of span using (cacheable) RD operations\n"); }
    for (index = 0; index < (span /4); index++)    {
      //check that the value at the current SDRAM address is what we assigned it to
      readback = sdram[index];
      if (readback != index){
    	  if( use_printf ){ printf("    - ERROR    Value should be 0x%08lX but is 0x%08lX at 0x%08lx\n", index, readback, index*4); }
        errors++;
     }
    }
    if( use_printf ){
    if ( errors == 0 ){
    	printf("    - PASS verification test\n");
    }else{
    	printf("    - FAIL with %d errors\n", errors);
    }
    }


    return errors;
}



#define HYPERFLASH_IO_RD_16( base, word_offs )  	  	IORD_16DIRECT( base, (word_offs*2) )
#define HYPERFLASH_IO_WR_16( base, word_offs, val )  	IOWR_16DIRECT( base, (word_offs*2), val )

int db_tests_hypermax_check_cfi( unsigned long base, int use_printf )
{
	register unsigned long d, d1, d2, d3, d4;
	register int errors = 0;


	if( use_printf ){   printf("\nDevBoards Test: Validating HyperMax Board HyperFlash CFI at Address: 0x%08lX\n", base); }

	    HYPERFLASH_IO_WR_16( base, 0x555, 0x0071 );  	// Issue "Status Register Clear" command
	    HYPERFLASH_IO_WR_16( base, 0x555, 0x0070 );		// Issue "Read Status Register" Command
	d = HYPERFLASH_IO_RD_16( base, 0x0 );				// Read the status register value
	if( use_printf ){ printf("Status Register    : %04lX",d); }


	// Do not call any functions (such as printf) that reside in flash while in CFI mode.
	// To be extra-conservative, do not access any HyperRAM memory either.
	//
	HYPERFLASH_IO_WR_16( base, 0x1234, 0x00FF ); // RESET FLASH
	HYPERFLASH_IO_WR_16( base, 0x55,   0x0098 ); // enter CFI Mode.
	d1 = HYPERFLASH_IO_RD_16( base, 0x0 );
	d2 = HYPERFLASH_IO_RD_16( base, 0x1 );
	d3 = HYPERFLASH_IO_RD_16( base, 0xC );
	d4 = HYPERFLASH_IO_RD_16( base, 0xE );
	HYPERFLASH_IO_WR_16( base, 0x55, 0x00F0 ); // exit CFI Mode

	if (d1 != 0x0001)  errors++;
	if (d2 != 0x007E)  errors++;
	if (d3 != 0x0005)  errors++;
	if (d4 != 0x0070)  errors++;

	if( use_printf ){
		printf("\nManufacturer ID    : %04lX",d1);
		printf("\nDevice ID          : %04lX",d2);
		printf("\nLower SW Bits      : %04lX",d3);
		printf("\nDevice ID 2        : %04lX",d4);
	}

		HYPERFLASH_IO_WR_16( base, 0x555, 0x0070 );		// Issue "Read Status Register" Command
	d = HYPERFLASH_IO_RD_16( base, 0x0 );				// Read the status register value
	if( use_printf ){
		printf("\nStatus Register    : %04lX",d);
		if (errors != 0){
			printf("\nTesting Flash      : FAIL - %d Errors in CFI Table\n\n", errors);
		}else{
			printf("\nTesting Flash      : PASS\n\n");
		}
	}

return errors;
}





/*
*  DISCLAIMER:
*
*      THIS SOFTWARE, SOURCE CODE AND ASSOCIATED MATERIALS INCLUDING BUT NOT LIMITED TO TUTORIALS,
*      GUIDES AND COMMENTARY PROVIDED WITH THIS EXERCISE ARE ONLY DESIGNED FOR REFERENCE PURPOSES
*      TO GIVE AN EXAMPLE TO LICENSEE FOR THEIR OWN NECESSARY DEVELOPMENT OF THEIR OWN SOFTWARE AND/OR
*      APPLICATION. IT IS NOT DESIGNED FOR ANY SPECIAL PURPOSE, SERIAL PRODUCTION OR USE IN MEDICAL,
*      MILITARY, AIR CRAFT, AVIATION, SPACE OF LIFE SUPPORT EQUIPMENT.
*
*      TO THE EXTENT PERMITTED BY LAW, THE EXERCISE SOFTWARE AND/OR SOURCE CODE AND/OR AND ASSOCIATED
*      MATERIALS IS PROVIDED AS IS WITHOUT WARRANTY OF ANY KIND AND ONLY FOR REFERENCE PURPOSES.
*
*      SYNAPTIC LABORATORIES LTD. MAKES NO WARRANTIES, EITHER EXPRESS OR IMPLIED, WITH RESPECT TO THE
*      LICENSED SOFTWARE AND/OR SOURCE CODE AND/OR ASSOCIATED MATERIALS, CONFIDENTIAL INFORMATION AND
*      DOCUMENTATION PROVIDED HEREUNDER. 
*
*      SYNAPTIC LABORATORIES LTD. SPECIFICALLY DISCLAIMS THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
*      FITNESS FOR A PARTICULAR PURPOSE AND ANY WARRANTY AGAINST INFRINGEMENT OF ANY INTELLECTUAL
*      PROPERTY RIGHT OF ANY THIRD PARTY WITH REGARD TO THE SOFTWARE, DOCUMENTATION (SCHEMATICS ETC.),
*      SOURCE CODE AND ASSOCIATED MATERIALS, CONFIDENTIAL INFORMATION AND DOCUMENTATION.
*
*      ANY USE, COMPILATION AND TESTING OF THE SOFTWARE AND/OR SOURCE CODE IS AT LICENSEE`S OWN RISK
*      AND LICENSEE IS OBLIGED TO CONDUCT EXTENSIVE TESTS TO AVOID ANY ERRORS AND FAILURE IN THE
*      COMPILED SOURCE CODE, DOCUMENTATION (SCHEMATICS ETC.) AND THE HEREFROM GENERATED SOFTWARE
*      OF LICENSEE.
*
*      EXCEPT FOR WILFULL INTENT SYNAPTIC LABORATORIES LTD. SHALL IN NO EVENT BE ENTITLED TO OR LIABLE
*      FOR ANY INDIRECT, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES OF ANY KIND OR NATURE, INCLUDING,
*      WITHOUT LIMITATION, BUSINESS INTERRUPTION COSTS, LOSS OF PROFIT OR REVENUE, LOSS OF DATA,
*      PROMOTIONAL OR MANUFACTURING EXPENSES, OVERHEAD, COSTS OR EXPENSES ASSOCIATED WITH WARRANTY
*      OR INTELLECTUAL PROPERTY INFRINGEMENT CLAIMS, INJURY TO REPUTATION OR LOSS OF CUSTOMERS.
*
*/