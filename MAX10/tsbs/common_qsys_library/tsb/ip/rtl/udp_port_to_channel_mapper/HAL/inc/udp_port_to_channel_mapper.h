#ifndef UDP_PORT_TO_CHANNEL_MAPPER_H
#define UDP_PORT_TO_CHANNEL_MAPPER_H

#include "alt_types.h"

typedef struct {
    alt_u16 chan_0_udp_port;    // the udp port that maps to channel 0
    alt_u16 chan_0_en;          // channel 0 enable status
    alt_u16 chan_1_udp_port;    // the udp port that maps to channel 1
    alt_u16 chan_1_en;          // channel 1 enable status
    alt_u16 chan_2_udp_port;    // the udp port that maps to channel 2
    alt_u16 chan_2_en;          // channel 2 enable status
    alt_u16 chan_3_udp_port;    // the udp port that maps to channel 3
    alt_u16 chan_3_en;          // channel 3 enable status
    alt_u32 packet_count;       // packet counter value
} CHAN_MAP_STATS;

int map_udp_port_to_channel(void *base, alt_u32 channel, alt_u16 udp_port_number);
int disable_udp_port_to_channel_mapping(void *base, alt_u32 channel);
int get_udp_port_to_channel_mapper_stats(void *base, CHAN_MAP_STATS *stats);
int clear_udp_port_to_channel_mapper_counter(void *base);

#endif /*UDP_PORT_TO_CHANNEL_MAPPER_H*/
