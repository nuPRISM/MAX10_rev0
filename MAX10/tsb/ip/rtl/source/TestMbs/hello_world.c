/*
 * main.c
 *
 *  Created on: 27/05/2016
 *      Author: Benjamin
 */

#include <stdio.h>
#include <time.h>
#include "io.h"
#include "sys/alt_timestamp.h"

#include <unistd.h>
#include "sll_mmbb_v001_002.h"

//#define SLL_HYPERRAM_ONLY

#define SLL_HYPERRAM_BASE  HYPERRAM_BASE
#define SLL_HYPERRAM_SPAN  HYPERRAM_SPAN


#define TEST_MALLOC_SIZE  (1044*1024)

#define RUN_SLL_MMBB_V001_002_4k		1
#define RUN_SLL_MMBB_V001_002_8k		1



int run_benchmarks( int errors )
{

	#if RUN_SLL_MMBB_V001_002_4k
		printf("\n\n****************************************************************\n");
		printf(" BENCHMARK - SLL Modular Memory Bandwidth Benchmark (MMBB) v001.002 \n");
		printf("****************************************************************\n\n");
		sll_mbb_v001_002_benchmark__run( 4*1024, 1 );
	#endif

	#if RUN_SLL_MMBB_V001_002_8k
		printf("\n\n****************************************************************\n");
		printf(" BENCHMARK - SLL Modular Memory Bandwidth Benchmark (MMBB) v001.002 \n");
		printf("****************************************************************\n\n");
		sll_mbb_v001_002_benchmark__run( 4*1024, 2 );
	#endif

	printf("\n\n****************************************************************\n");
	printf("****************************************************************\n*\n");
	printf("* !!! FINISH BENCHMARKS !!! \n*\n");
	printf("****************************************************************\n");
	printf("****************************************************************\n\n");

	return 0;
}


volatile int x;	// use for determining approximate location of BSS

int main( void )
{
	int errors = 0;

	printf( "\n\nProfiler v001.002: Compiled %s, %s.\n", __DATE__, __TIME__ );
	printf( "CPU_MHZ(%d)\nD$(%d)\nI$(%d)\n", ALT_CPU_CPU_FREQ, ALT_CPU_DCACHE_SIZE, ALT_CPU_ICACHE_SIZE );
	printf( "CPU_HWDIV(%d)\nCPU_HWMUL(%d)\nCPU_MULX(%d)\n", ALT_CPU_HARDWARE_DIVIDE_PRESENT, ALT_CPU_HARDWARE_MULTIPLY_PRESENT, ALT_CPU_HARDWARE_MULX_PRESENT );
	printf( "CPI_DBG(%d)\n", ALT_CPU_HAS_DEBUG_CORE );
	printf( "CPU_RESET_ADDR:                         0x%08x\n", ALT_CPU_RESET_ADDR );
	printf( "SLL_HYPERRAM_BASE:                			 0x%08x\n\n", SLL_HYPERRAM_BASE );
	printf( "ONCHIP_MEMORY2_0_BASE:                  0x%08x\n\n", ONCHIP_MEMORY2_0_BASE );
	printf( "Main:                                   0x%08x\n", (unsigned int)main );
	printf( "BSS:                                    0x%08x\n\n", (unsigned int)&x );

#ifdef SMALL_C_LIB
	printf( "NEWLIB - SMALL C LIBRARY\n  -- Employs slowest, simple byte aligned, no unrolled loops\n  -- memset (~3.6x), memcpy (~3.2x) slower than Large C library for >1KB\n\n");
#else
	printf( "NEWLIB - LARGE C LIBRARY\n  -- Employs faster, byte/word aligned, 4x unrolled loops\n  -- memset (~3.6x), memcpy (~3.2x) faster than Small C library for >1KB\n\n");
#endif


#ifdef ALT_SYS_CLK
	printf( "ALT_SYS_CLK          : PRESENT\n" );
#else
	printf( "ALT_SYS_CLK          : none\n");
#endif
	alt_timestamp_start();
	printf( "Clocks per second    : %d\n",  CLOCKS_PER_SEC );
	printf( "Timestamp per second : %lu\n", alt_timestamp_freq() );

	errors = run_benchmarks( errors );


	printf("\n\n****************************************************************\n");
	printf(" END \n");
	printf("****************************************************************\n\n");
    printf("\4");
	while(1);
	return 0;
}


#ifdef SMALL_C_LIB

// This function is missing from SMALL_C_LIB.
//
int fflush( FILE *fp )
{
	printf( "fflush( not required ) - You should only see this message on SMALL C LIBRARY Projects\n" );
return 0; // success
}
#endif



