#include "error_packet_discard_regs.h"
#include "error_packet_discard.h"

//
// error packet discard routines
//

int get_error_packet_discard_stats(void *base, EPD_STATS *stats) {
    
    stats->packet_count         = ERROR_PACKET_DISCARD_RD_PACKET_COUNTER(base);
    stats->error_packet_count   = ERROR_PACKET_DISCARD_RD_ERROR_PACKET_COUNTER(base);
    
    return 0;
}

int clear_error_packet_discard_counters(void *base) {
    
    ERROR_PACKET_DISCARD_CLEAR_PACKET_COUNTER(base);
    ERROR_PACKET_DISCARD_CLEAR_ERROR_PACKET_COUNTER(base);
    
    return 0;
}
