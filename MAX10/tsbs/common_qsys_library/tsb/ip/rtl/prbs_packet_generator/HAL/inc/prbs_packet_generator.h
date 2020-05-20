#ifndef PRBS_PACKET_GENERATOR_H
#define PRBS_PACKET_GENERATOR_H

#include "alt_types.h"

typedef struct {
    alt_u32 csr_state;      // csr value
    alt_u16 byte_count;     // byte length of generated packets
    alt_u32 initial_value;  // initial value for random number generator
    alt_u32 packet_count;   // packet counter value
} PKT_GEN_STATS;

int start_packet_generator(void *base, alt_u16 byte_count, alt_u32 initial_value);
int stop_packet_generator(void *base);
int is_packet_generator_running(void *base);
int wait_until_packet_generator_stops_running(void *base);
int get_packet_generator_stats(void *base, PKT_GEN_STATS *stats);

#endif /*PRBS_PACKET_GENERATOR_H*/
