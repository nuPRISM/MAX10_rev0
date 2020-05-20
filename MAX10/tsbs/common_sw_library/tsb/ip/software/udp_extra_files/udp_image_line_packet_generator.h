#ifndef UDP_IMAGE_LINE_PACKET_GENERATOR_H
#define UDP_IMAGE_LINE_PACKET_GENERATOR_H

#include "alt_types.h"

typedef struct {
    alt_u32 csr_state;      	// control / status (csr) register value
    alt_u16 byte_count;     	// byte length of generated packets
    alt_u32 initial_value;  	// initial value for random number generator
    alt_u32 packet_count;   	// packet counter value
    alt_u32 timestamp31_0; 	 	// bits 31:0 of timestamp
    alt_u16 timestamp47_32;  	// bits 47:32 of timestamp
    alt_u16 event_id_and_length;// bits 7:0      event ID , bits 15:8     event LENGTH
    alt_u16 event_source_address;// source address of event
} PKT_GEN_STATS;

int start_packet_generator(void *base, alt_u16 byte_count, alt_u32 initial_value);
int stop_packet_generator(void *base);
int is_packet_generator_running(void *base);
int wait_until_packet_generator_stops_running(void *base);
int get_packet_generator_stats(void *base, PKT_GEN_STATS *stats);

#endif /*UDP_IMAGE_LINE_PACKET_GENERATOR_H*/
