#include "udp_payload_extractor_regs.h"
#include "udp_payload_extractor.h"

//
// udp payload extractor utility routines
//

int get_udp_payload_extractor_stats (void *base, UDP_EXT_STATS *stats) {

    stats->packet_count = UDP_PAYLOAD_EXTRACTOR_RD_PACKET_COUNTER(base);
    
    return 0;
}

int clear_udp_payload_extractor_counter (void *base) {
    
    UDP_PAYLOAD_EXTRACTOR_CLEAR_PACKET_COUNTER(base);
    
    return 0;
}
