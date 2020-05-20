#ifndef PRBS_PACKET_CHECKER_H
#define PRBS_PACKET_CHECKER_H

#include "alt_types.h"

typedef struct {
    alt_u32 csr_state;              // csr value
    alt_u32 length_error_count;     // length error counter value
    alt_u32 sequence_error_count;   // sequence error counter value
    alt_u32 data_error_count;       // data error counter value
    alt_u32 byte_count;             // byte counter value
    alt_u32 packet_count;           // packet counter value
} PKT_CHKR_STATS;

int start_packet_checker(void *base);
int stop_packet_checker(void *base);
int get_packet_checker_stats(void *base, PKT_CHKR_STATS *stats);

#endif /*PRBS_PACKET_CHECKER_H*/
