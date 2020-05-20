#ifndef ERROR_PACKET_DISCARD_H
#define ERROR_PACKET_DISCARD_H

#include "alt_types.h"

typedef struct {
    alt_u32 packet_count;           // the packet counter value
    alt_u32 error_packet_count;     // the error packet counter value
} EPD_STATS;

int get_error_packet_discard_stats(void *base, EPD_STATS *stats);
int clear_error_packet_discard_counters(void *base);

#endif /*ERROR_PACKET_DISCARD_H*/
