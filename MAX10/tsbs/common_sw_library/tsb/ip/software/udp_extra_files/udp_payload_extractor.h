#ifndef UDP_PAYLOAD_EXTRACTOR_H
#define UDP_PAYLOAD_EXTRACTOR_H

#include "alt_types.h"

typedef struct {
    alt_u32 packet_count;   // packet counter value
} UDP_EXT_STATS;

int get_udp_payload_extractor_stats (void *base, UDP_EXT_STATS *stats);
int clear_udp_payload_extractor_counter (void *base);

#endif /*UDP_PAYLOAD_EXTRACTOR_H*/
