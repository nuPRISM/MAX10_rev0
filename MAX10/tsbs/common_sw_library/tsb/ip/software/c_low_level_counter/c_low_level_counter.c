/*
 * low_level_counter.cpp
 *
 *  Created on: Jun 29, 2017
 *      Author: user
 */

#include "c_low_level_counter.h"
#include "io.h"
#include <unistd.h>



void low_level_counter_get_ref_and_counter_timestamp(uint32_t base,
		uint32_t clock_crossing_wait_us,
		uint64_t* measured_count,
		uint64_t* ref_count) {

	//Note: one should really call this using mutual exclusion in order that snapl and snaph agree
	IOWR(base,0,0); //write operation gets snapshot of counter
	usleep(clock_crossing_wait_us);
	unsigned long long snapl = (unsigned long long) (IORD(base,0));
	unsigned long long snaph = (unsigned long long) (IORD(base,1));
	snapl = snapl & 0xFFFFFFFF;
	snaph = snaph & 0xFFFFFFFF;
	(*measured_count) = (snaph << 32) + snapl;
	unsigned long long ref_snapl = (unsigned long long) (IORD(base,2));
	unsigned long long ref_snaph = (unsigned long long) (IORD(base,3));
	ref_snapl = ref_snapl & 0xFFFFFFFF;
	ref_snaph = ref_snaph & 0xFFFFFFFF;
	(*ref_count) = (ref_snaph << 32) + ref_snapl;
}

void low_level_counter_get_ref_and_counter_delta_time(uint32_t base,
		uint32_t measurement_time_us,
		uint32_t clock_crossing_wait_us,
		uint64_t* measured_count,
		uint64_t* ref_count) {


	uint64_t measured_count1;
	uint64_t ref_count1;
	uint64_t measured_count2;
	uint64_t ref_count2;

		int try_count = 0;

		do {
		     try_count = try_count + 1;;
		     low_level_counter_get_ref_and_counter_timestamp(base,clock_crossing_wait_us,&measured_count1,&ref_count1);
			 usleep(measurement_time_us);
			 low_level_counter_get_ref_and_counter_timestamp(base,clock_crossing_wait_us,&measured_count2,&ref_count2);
		} while (((measured_count2 < measured_count1) || (ref_count2 < ref_count1)) && (try_count < 2)); //try to recover once from wrapping of counter, if not successful measurement
		                                                                                                 //time might be too long
		(*measured_count) = measured_count2-measured_count1;;
		(*ref_count) = ref_count2 - ref_count1;
}

unsigned long long low_level_counter_get_timestamp(uint32_t base,uint32_t clock_crossing_wait_us) {
	uint64_t measured_count;
	uint64_t ref_count;
	low_level_counter_get_ref_and_counter_timestamp(base,clock_crossing_wait_us,&measured_count,&ref_count);
	return measured_count;
}

unsigned long long low_level_counter_get_ref_timestamp(uint32_t base,uint32_t clock_crossing_wait_us) {
	uint64_t measured_count;
	uint64_t ref_count;
	low_level_counter_get_ref_and_counter_timestamp(base,clock_crossing_wait_us,&measured_count,&ref_count);
	return ref_count;
}

unsigned long long low_level_counter_get_delta_time(uint32_t base,uint32_t measurement_time_us,uint32_t clock_crossing_wait_us) {
	uint64_t measured_count;
	uint64_t ref_count;
	low_level_counter_get_ref_and_counter_delta_time(base,measurement_time_us,clock_crossing_wait_us,&measured_count,&ref_count);
    return measured_count;
}

unsigned long long low_level_counter_get_ref_delta_time(uint32_t base,uint32_t measurement_time_us,uint32_t clock_crossing_wait_us) {
	uint64_t measured_count;
	uint64_t ref_count;
	low_level_counter_get_ref_and_counter_delta_time(base,measurement_time_us,clock_crossing_wait_us,&measured_count,&ref_count);
    return ref_count;
}

