#include "overflow_packet_discard_regs.h"
#include "overflow_packet_discard.h"

//
// overflow packet discard utility routines
//

int get_overflow_packet_discard_stats(void *base, OPD_STATS *stats) {
    
    stats->overflow_packet_count = OVERFLOW_PACKET_DISCARD_RD_OVERFLOW_PACKET_COUNTER(base);
    
    return 0;
}

int clear_overflow_packet_discard_counters(void *base) {
    
    OVERFLOW_PACKET_DISCARD_CLEAR_OVERFLOW_PACKET_COUNTER(base);
    
    return 0;
}
