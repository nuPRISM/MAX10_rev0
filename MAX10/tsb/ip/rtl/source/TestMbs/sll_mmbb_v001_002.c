/*
 * sll_mmbb_v001_001.c
 *
 *  Created on: 09/02/2017
 *      Author: Benjamin
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include "alt_types.h"
#include "system.h"
#include "sys/alt_timestamp.h"
#include "sys/alt_cache.h"
#include "sys/alt_irq.h"
#include "sll_mmbb_v001_002.h"

typedef SLL_MBB_V001_002_BENCHMARK_STATUS (*sll_mbb_v001_002_benchmark_abs)(unsigned long span_08, unsigned long multiple, void *dst, void const *src );

#define REPORT_WITH_DOUBLE 1

//#define USE_CUSTOM_MEMSET

#ifdef USE_CUSTOM_MEMSET

#define	wsize	sizeof(u_int)
#define	wmask	(wsize - 1)
#define	VAL	c0
#define	WIDEVAL	c

void *
memset(dst0, c0, length)
	void *dst0;
	register int c0;
	register size_t length;
{
	register size_t t;
	register u_int c;
	register u_char *dst;

	dst = dst0;
	/*
	 * If not enough words, just fill bytes.  A length >= 2 words
	 * guarantees that at least one of them is `complete' after
	 * any necessary alignment.  For instance:
	 *
	 *	|-----------|-----------|-----------|
	 *	|00|01|02|03|04|05|06|07|08|09|0A|00|
	 *	          ^---------------------^
	 *		 dst		 dst+length-1
	 *
	 * but we use a minimum of 3 here since the overhead of the code
	 * to do word writes is substantial.
	 */
	if (length < 3 * wsize) {
		while (length != 0) {
			*dst++ = VAL;
			--length;
		}
		return (dst0);
	}

	if ((c = (u_char)c0) != 0) {	/* Fill the word. */
		c = (c << 8) | c;	/* u_int is 16 bits. */
		c = (c << 16) | c;	/* u_int is 32 bits. */
	}

	/* Align destination by filling in bytes. */
	if ((t = (int)dst & wmask) != 0) {
		t = wsize - t;
		length -= t;
		do {
			*dst++ = VAL;
		} while (--t != 0);
	}

	/* Fill words.  Length was >= 2*words so we know t >= 1 here. */
	t = length / wsize;
	do {
		*(u_int *)dst = WIDEVAL;
		dst += wsize;
	} while (--t != 0);

	/* Mop up trailing bytes, if any. */
	t = length & wmask;
	if (t != 0)
		do {
			*dst++ = VAL;
		} while (--t != 0);
	return (dst0);
}

#endif





__attribute__((aligned(32), optimize("O0")))
SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark_abs__empty( unsigned long span_08, unsigned long multiple, void *dst, void const *src )
{
	volatile char *d = (char*) dst;
	volatile char *s = (char*) src;
	while( multiple-- ){ d++; s++; }
	return OKAY;
}

/*
void *memcpy_ben (void *dst, void *src, size_t n ){

	void_ save = dst0;
	char *dst = (char *) dst0;
	char *src = (char *) src0;

	if(n = 0 || dst=src){ return dst; }

	while (n--){
	      *dst++ = *src++;
	}

return dst;
}
*/

__attribute__((aligned(32)))
SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark_abs__memcpy_ben( unsigned long span_08, unsigned long multiple, void *dst, void const *src )
{
	char *d = (char*) dst;
	char *s = (char*) src;
	while( multiple-- ){
		memcpy( d, s, span_08 );
		s += span_08;
		d += span_08;
	}
	return OKAY;
}

__attribute__((aligned(32)))
SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark_abs__memcpy( unsigned long span_08, unsigned long multiple, void *dst, void const *src )
{
	char *d = (char*) dst;
	char *s = (char*) src;
	while( multiple-- ){
		memcpy( d, s, span_08 );
		s += span_08;
		d += span_08;
	}
	return OKAY;
}

__attribute__((aligned(32)))
SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark_abs__memset( unsigned long span_08, unsigned long multiple, void *dst, void const *src )
{
	char *d = (char*) dst;
	while( multiple-- ){
		memset( d, 0xAA, span_08 );
		d += span_08;
	}
	return OKAY;
}


__attribute__((aligned(32), optimize("O2")))
SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark_abs__mem_st_32( unsigned long span_08, unsigned long multiple, void *dst, void const *src )
{
	register alt_u32 i;
	register alt_u32 span_32 = span_08 >> 2;
	register alt_u32 *d = (alt_u32*) dst;
	register alt_u32 mult = multiple;

	while ( mult-- ) {
		i = span_32;
		while(i--){
			*d++ = 0x00;
		}
	}
	return OKAY;
}


__attribute__((aligned(32), optimize("O2")))
SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark_abs__mem_st_64( unsigned long span_08, unsigned long multiple, void *dst, void const *src )
{
	register alt_u32 i;
	register alt_u32 span_64 = span_08 >> 3;
	register alt_u64 *d = (alt_u64*) dst;
	register alt_u32 mult = multiple;

	while ( mult-- ) {
		i = span_64;
		while(i--){
			*d++ = 0x00;
		}
	}
	return OKAY;
}

__attribute__((aligned(32), optimize("O2")))
SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark_abs__mem_st_128( unsigned long span_08, unsigned long multiple, void *dst, void const *src )
{
	register alt_u32 i;
	register alt_u32 span_64 = span_08 >> 4;
	register alt_u64 *d = (alt_u64*) dst;
	register alt_u32 mult = multiple;

	while ( mult-- ) {
		i = span_64;
		while(i--){
			d[0] = 0x00;
			d[1] = 0x00;
			d += 2;
		}
	}
	return OKAY;
}

__attribute__((aligned(32), optimize("O2")))
SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark_abs__mem_st_256( unsigned long span_08, unsigned long multiple, void *dst, void const *src )
{
	register alt_u32 i;
	register alt_u32 span_64 = span_08 >> 5;
	register alt_u64 *d = (alt_u64*) dst;
	register alt_u32 mult = multiple;

	while ( mult-- ) {
		i = span_64;
		while(i--){
			d[0] = 0x00;
			d[1] = 0x00;
			d[2] = 0x00;
			d[3] = 0x00;
			d += 4;
		}
	}
	return OKAY;
}

__attribute__((aligned(32), optimize("O2")))
SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark_abs__mem_st_512( unsigned long span_08, unsigned long multiple, void *dst, void const *src )
{
	register alt_u32 i;
	register alt_u32 span_64 = span_08 >> 6;
	register alt_u64 *d = (alt_u64*) dst;
	register alt_u32 mult = multiple;

	while ( mult-- ) {
		i = span_64;
		while(i--){
			d[0] = 0x00;
			d[1] = 0x00;
			d[2] = 0x00;
			d[3] = 0x00;
			d[4] = 0x00;
			d[5] = 0x00;
			d[6] = 0x00;
			d[7] = 0x00;
			d += 8;
		}
	}
	return OKAY;
}




__attribute__((aligned(32), optimize("O2")))
SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark_abs__mem_st_08( unsigned long span_08, unsigned long multiple, void *dst, void const *src )
{
	register alt_u8* d = (alt_u8*) dst;
	register alt_u32 i = span_08 * multiple;

	while( i-- ) {
		*d++ = 0x00;
	}

	return OKAY;
}


__attribute__((aligned(32), optimize("O0")))
SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark_abs__mem_ld_08( unsigned long span_08, unsigned long multiple, void *dst, void const *src )
{
	register alt_u32 r;
	register alt_u32 i;
	register alt_u8 *d = (alt_u8*) dst;
	register alt_u32 mult = multiple;

	while ( mult-- ) {
		i = span_08;
		while(i--){
			r = *d++;
		}
	}
	r=r;
	return OKAY;
}

__attribute__((aligned(32), optimize("O0")))
SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark_abs__mem_ld_32( unsigned long span_08, unsigned long multiple, void *dst, void const *src )
{
	register alt_u32 r;
	register alt_u32 i;
	register alt_u32 span_32 = span_08 >> 2;
	register alt_u32 *d = (alt_u32*) dst;
	register alt_u32 mult = multiple;

	while ( mult-- ) {
		i = span_32;
		while(i--){
			r = *d++;
		}
	}
	r=r;
	return OKAY;
}

__attribute__((aligned(32), optimize("O0")))
SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark_abs__mem_ld_64( unsigned long span_08, unsigned long multiple, void *dst, void const *src )
{
	register alt_u64 r;
	register alt_u32 i;
	register alt_u32 span_64 = span_08 >> 3;
	register alt_u64 *d = (alt_u64*) dst;
	register alt_u32 mult = multiple;

	while ( mult-- ) {
		i = span_64;
		while(i--){
			r = *d++;
		}
	}
	r=r;
	return OKAY;
}


__attribute__((aligned(32), optimize("O0")))
SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark_abs__mem_ld_128( unsigned long span_08, unsigned long multiple, void *dst, void const *src )
{
	register alt_u64 r;
	register alt_u32 i;
	register alt_u32 span_128 = span_08 >> 4;
	register alt_u64 *d = (alt_u64*) dst;
	register alt_u32 mult = multiple;

	while ( mult-- ) {
		i = span_128;
		while(i--){
			r = d[0];
			r = d[1];
			d+=2;
		}
	}
	r=r;
	return OKAY;
}


__attribute__((aligned(32), optimize("O0")))
SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark_abs__mem_ld_256( unsigned long span_08, unsigned long multiple, void *dst, void const *src )
{
	register alt_u64 r;
	register alt_u32 i;
	register alt_u32 span_256 = span_08 >> 5;
	register alt_u64 *d = (alt_u64*) dst;
	register alt_u32 mult = multiple;

	while ( mult-- ) {
		i = span_256;
		while(i--){
			r = d[0];
			r = d[1];
			r = d[2];
			r = d[3];
			d+=4;
		}
	}
	r=r;
	return OKAY;
}


__attribute__((aligned(32), optimize("O0")))
SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark_abs__mem_ld_512( unsigned long span_08, unsigned long multiple, void *dst, void const *src )
{
	register alt_u64 r;
	register alt_u32 i;
	register alt_u32 span_256 = span_08 >> 6;
	register alt_u64 *d = (alt_u64*) dst;
	register alt_u32 mult = multiple;

	while ( mult-- ) {
		i = span_256;
		while(i--){
			r = d[0];
			r = d[1];
			r = d[2];
			r = d[3];
			r = d[4];
			r = d[5];
			r = d[6];
			r = d[7];
			d+=8;
		}
	}
	r=r;
	return OKAY;
}


__attribute__((aligned(32)))
SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark_measure(
	char const *func_name,
	sll_mbb_v001_002_benchmark_abs func,
	unsigned long span_08, unsigned long multiple, void *dst, void const *src )
{
	SLL_MBB_V001_002_BENCHMARK_STATUS status;
	alt_timestamp_type  time_start;
	alt_timestamp_type  time_stop;
	alt_timestamp_type  time_duration;
	alt_timestamp_type  time_duration_avg = 0;
	int i;

	fflush(stdout);							// I am not convinced this flushes out the UART entirely.
	usleep( 50*1000 );						// Pause briefly to allow slow UART to flush.
	alt_irq_context irq_context;
	int was_irq_enabled = alt_irq_enabled();
	if( was_irq_enabled ){ irq_context = alt_irq_disable_all(); }

	for( i = 0; i != 4; i++ )
	{
		alt_icache_flush_all();					// Ensure no memcpy code is in cache.
		alt_dcache_flush_all();					// Ensure no data that will be used in next memcpy is in cache.
		time_start = alt_timestamp();
		status = (*func)( span_08, multiple, dst, src );
		alt_dcache_flush_all();					// Ensure dirty lines are written to memory.
		time_stop = alt_timestamp();
		time_duration = (time_stop - time_start);
		time_duration_avg += time_duration;
	}
	if( was_irq_enabled ){ alt_irq_enable_all( irq_context ); }

	printf( "%s : span( %8lu ), multiple( %4lu ), avg_ticks( %8llu )",
			func_name, span_08, multiple, (time_duration_avg >> 2) );

	#if REPORT_WITH_DOUBLE
	{
		unsigned long bytes = span_08 * multiple;
		double mib = (((double)bytes / (double)1024) / (double)1024);
		double seconds = ((double)1 / (double)ALT_CPU_CPU_FREQ) * (double)(time_duration);
		double mib_sec = mib / seconds;
		printf( ", Avg MB/s( %5.2f )", (float) mib_sec );
	}
	#endif

	printf( "\n" );

return status;
}


typedef struct function_list
{
	char func_name[80];
	sll_mbb_v001_002_benchmark_abs func;
} function_list;

#define FUNCTIONS_ELEMENTS 15
static const function_list functions [FUNCTIONS_ELEMENTS] =
{
		{ "sll_mbb_v001_002_benchmark_abs__empty     ", &sll_mbb_v001_002_benchmark_abs__empty      },
		{ "sll_mbb_v001_002_benchmark_abs__memcpy    ", &sll_mbb_v001_002_benchmark_abs__memcpy     },
		{ "sll_mbb_v001_002_benchmark_abs__memset    ", &sll_mbb_v001_002_benchmark_abs__memset     },
		{ "sll_mbb_v001_002_benchmark_abs__mem_st_08 ", &sll_mbb_v001_002_benchmark_abs__mem_st_08  },
		{ "sll_mbb_v001_002_benchmark_abs__mem_st_32 ", &sll_mbb_v001_002_benchmark_abs__mem_st_32  },
		{ "sll_mbb_v001_002_benchmark_abs__mem_st_64 ", &sll_mbb_v001_002_benchmark_abs__mem_st_64  },
		{ "sll_mbb_v001_002_benchmark_abs__mem_st_128", &sll_mbb_v001_002_benchmark_abs__mem_st_128 },
		{ "sll_mbb_v001_002_benchmark_abs__mem_st_256", &sll_mbb_v001_002_benchmark_abs__mem_st_256 },
		{ "sll_mbb_v001_002_benchmark_abs__mem_st_512", &sll_mbb_v001_002_benchmark_abs__mem_st_512 },
		{ "sll_mbb_v001_002_benchmark_abs__mem_ld_08 ", &sll_mbb_v001_002_benchmark_abs__mem_ld_32  },
		{ "sll_mbb_v001_002_benchmark_abs__mem_ld_32 ", &sll_mbb_v001_002_benchmark_abs__mem_ld_32  },
		{ "sll_mbb_v001_002_benchmark_abs__mem_ld_64 ", &sll_mbb_v001_002_benchmark_abs__mem_ld_64  },
		{ "sll_mbb_v001_002_benchmark_abs__mem_ld_128", &sll_mbb_v001_002_benchmark_abs__mem_ld_128 },
		{ "sll_mbb_v001_002_benchmark_abs__mem_ld_256", &sll_mbb_v001_002_benchmark_abs__mem_ld_256 },
		{ "sll_mbb_v001_002_benchmark_abs__mem_ld_512", &sll_mbb_v001_002_benchmark_abs__mem_ld_512 }
};

SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark__run( unsigned long span_08, unsigned long multiple )
{
	unsigned long bytes = span_08 * multiple;
	void *array_a, *array_b;
	unsigned long f, i, s_08;

	// Load bytes array, plus a small margin to mis-align the next malloc to prevent cache-line thrashing o
	// Results in memcpy being 3.6x faster.
	//
	array_a = (void*) malloc( bytes + ALT_CPU_DCACHE_LINE_SIZE );

	printf( "Allocate u8 array_a[%lu] at address (%08lx) : ", bytes + ALT_CPU_DCACHE_LINE_SIZE, (unsigned long)array_a );
	if(array_a){
		printf( "OKAY\n" );
	}else{
		printf( "FAIL\n" );
		return FAIL;
	}

	array_b = (void*) malloc( bytes );
	printf( "Allocate u8 array_b[%lu] at address (%08lx) : ", bytes, (unsigned long)array_b );
	if(array_b){
		printf( "OKAY\n" );
	}else{
		free( array_a );
		printf( "FAIL\n" );
		return FAIL;
	}

	printf( "\n*****\nsll_mbb_v001_002_benchmark__run( linear spans increasing by %lu )\n", span_08 );

	for( f = 0; f != FUNCTIONS_ELEMENTS; f++ ){
		s_08 = 0;
		for ( i = 0; i != multiple; i++ ){
			s_08 += span_08;
			sll_mbb_v001_002_benchmark_measure( functions[f].func_name, functions[f].func, s_08, 1, array_b, array_a );
		}
	}

	printf( "\n*****\nsll_mbb_v001_002_benchmark__run( span of %lu iterated %lu times )\n", span_08, multiple );

	for( f = 0; f != FUNCTIONS_ELEMENTS; f++ ){
		sll_mbb_v001_002_benchmark_measure( functions[f].func_name, functions[f].func, span_08, multiple, array_b, array_a );
	}
	printf("\n");

	free (array_a);
	free (array_b);

return OKAY;
}
