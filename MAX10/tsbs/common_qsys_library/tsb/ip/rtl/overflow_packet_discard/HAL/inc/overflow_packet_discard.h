#ifndef OVERFLOW_PACKET_DISCARD_H
#define OVERFLOW_PACKET_DISCARD_H

#include "alt_types.h"

typedef struct {
    alt_u32 overflow_packet_count;      // the overflow packet counter value
} OPD_STATS;

int get_overflow_packet_discard_stats(void *base, OPD_STATS *stats);
int clear_overflow_packet_discard_counters(void *base);

#endif /*OVERFLOW_PACKET_DISCARD_H*/
