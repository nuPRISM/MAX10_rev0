/*
 * sll_mmbb_v001_001.h
 *
 *  Created on: 09/02/2017
 *      Author: Benjamin
 */

#ifndef SLL_MMBB_V001_002_H_
#define SLL_MMBB_V001_002_H_


typedef enum SLL_MBB_V001_002_BENCHMARK_STATUS
{
	OKAY, FAIL
} SLL_MBB_V001_002_BENCHMARK_STATUS;


SLL_MBB_V001_002_BENCHMARK_STATUS
sll_mbb_v001_002_benchmark__run( unsigned long span_08, unsigned long multiple );



#endif /* SLL_MMBB_V001_001_H_ */
