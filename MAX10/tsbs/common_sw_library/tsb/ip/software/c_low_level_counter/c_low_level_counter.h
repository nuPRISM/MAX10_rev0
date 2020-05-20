/*
 * low_level_counter.h
 *
 *  Created on: Jun 29, 2017
 *      Author: user
 */

#ifndef C_LOW_LEVEL_COUNTER_H_
#define C_LOW_LEVEL_COUNTER_H_

#include <stdint.h>
unsigned long long low_level_counter_get_timestamp(uint32_t base, uint32_t clock_crossing_wait_us);
unsigned long long low_level_counter_get_ref_timestamp(uint32_t base, uint32_t clock_crossing_wait_us);
unsigned long long low_level_counter_get_delta_time(uint32_t base,uint32_t measurement_time_us, uint32_t clock_crossing_wait_us);
unsigned long long low_level_counter_get_ref_delta_time(uint32_t base,uint32_t measurement_time_us, uint32_t clock_crossing_wait_us);
void low_level_counter_get_ref_and_counter_timestamp(uint32_t base, uint32_t clock_crossing_wait_us, uint64_t* measured_count, uint64_t* ref_count);
void low_level_counter_get_ref_and_counter_delta_time(uint32_t base, uint32_t measurement_time_us, uint32_t clock_crossing_wait_us, uint64_t* measured_count, uint64_t* ref_count);
#endif /* LOW_LEVEL_COUNTER_H_ */
