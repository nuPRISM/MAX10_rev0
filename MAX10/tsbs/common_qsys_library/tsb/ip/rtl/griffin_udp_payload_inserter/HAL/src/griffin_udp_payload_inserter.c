#include "griffin_udp_payload_inserter_regs.h"
#include "griffin_udp_payload_inserter.h"

//
// udp payload inserter utility routines
//

int start_griffin_udp_payload_inserter(void *base, UDP_INS_STATS *stats) {
    
    alt_u32 current_csr;

    // is the packet generator already running?
    current_csr = GRIFFIN_UDP_PAYLOAD_INSERTER_RD_CSR(base);
    if(current_csr & GRIFFIN_UDP_PAYLOAD_INSERTER_CSR_GO_BIT_MASK) {
        return 1;
    }
    if(current_csr & GRIFFIN_UDP_PAYLOAD_INSERTER_CSR_RUNNING_BIT_MASK) {
        return 2;
    }
    
    // clear the counter    
    GRIFFIN_UDP_PAYLOAD_INSERTER_CLEAR_PACKET_COUNTER(base);
    
    // write the parameter registers
    GRIFFIN_UDP_PAYLOAD_INSERTER_WR_MAC_DST_HI  (base, stats->mac_dst_hi);
    GRIFFIN_UDP_PAYLOAD_INSERTER_WR_MAC_DST_LO  (base, stats->mac_dst_lo);
    GRIFFIN_UDP_PAYLOAD_INSERTER_WR_MAC_SRC_HI  (base, stats->mac_src_hi);
    GRIFFIN_UDP_PAYLOAD_INSERTER_WR_MAC_SRC_LO  (base, stats->mac_src_lo);
    GRIFFIN_UDP_PAYLOAD_INSERTER_WR_IP_SRC      (base, stats->ip_src);
    GRIFFIN_UDP_PAYLOAD_INSERTER_WR_IP_DST      (base, stats->ip_dst);
    GRIFFIN_UDP_PAYLOAD_INSERTER_WR_UDP_PORTS   (base, (alt_u32)(stats->udp_src << 16) | (alt_u32)(stats->udp_dst));

    // and set the go bit
    GRIFFIN_UDP_PAYLOAD_INSERTER_WR_CSR(base, GRIFFIN_UDP_PAYLOAD_INSERTER_CSR_GO_BIT_MASK);
    
    return 0;
    
}

int stop_griffin_udp_payload_inserter(void *base) {
    
    // is the peripheral already stopped?
    if(!(GRIFFIN_UDP_PAYLOAD_INSERTER_RD_CSR(base) & GRIFFIN_UDP_PAYLOAD_INSERTER_CSR_GO_BIT_MASK)) {
        return 1;
    }

    // clear the go bit
    GRIFFIN_UDP_PAYLOAD_INSERTER_WR_CSR(base, 0);
    
    return 0;
}

int is_griffin_udp_payload_inserter_running(void *base) {
    
    // is the peripheral running?
    if((GRIFFIN_UDP_PAYLOAD_INSERTER_RD_CSR(base) & GRIFFIN_UDP_PAYLOAD_INSERTER_CSR_RUNNING_BIT_MASK)) {
        return 1;
    }

    return 0;
}

int wait_until_griffin_udp_payload_inserter_stops_running(void *base) {
    
    // wait until peripheral stops running?
    while(is_griffin_udp_payload_inserter_running(base));

    return 0;
}

int check_griffin_udp_payload_inserter_error(void *base) {
    
    // is the peripheral in error state?
    if((GRIFFIN_UDP_PAYLOAD_INSERTER_RD_CSR(base) & GRIFFIN_UDP_PAYLOAD_INSERTER_CSR_ERROR_BIT_MASK)) {
        return 1;
    }

    return 0;
}

int get_griffin_udp_payload_inserter_stats(void *base, UDP_INS_STATS *stats) {
    
    stats->csr_state    = GRIFFIN_UDP_PAYLOAD_INSERTER_RD_CSR(base);
    stats->mac_dst_hi   = GRIFFIN_UDP_PAYLOAD_INSERTER_RD_MAC_DST_HI(base);
    stats->mac_dst_lo   = GRIFFIN_UDP_PAYLOAD_INSERTER_RD_MAC_DST_LO(base);
    stats->mac_src_hi   = GRIFFIN_UDP_PAYLOAD_INSERTER_RD_MAC_SRC_HI(base);
    stats->mac_src_lo   = GRIFFIN_UDP_PAYLOAD_INSERTER_RD_MAC_SRC_LO(base);
    stats->ip_src       = GRIFFIN_UDP_PAYLOAD_INSERTER_RD_IP_SRC(base);
    stats->ip_dst       = GRIFFIN_UDP_PAYLOAD_INSERTER_RD_IP_DST(base);
    stats->udp_src      = (GRIFFIN_UDP_PAYLOAD_INSERTER_RD_UDP_PORTS(base) & GRIFFIN_UDP_PAYLOAD_INSERTER_UDP_SRC_MASK) >> GRIFFIN_UDP_PAYLOAD_INSERTER_UDP_SRC_OFST;
    stats->udp_dst      = (GRIFFIN_UDP_PAYLOAD_INSERTER_RD_UDP_PORTS(base) & GRIFFIN_UDP_PAYLOAD_INSERTER_UDP_DST_MASK) >> GRIFFIN_UDP_PAYLOAD_INSERTER_UDP_DST_OFST;
    stats->packet_count = GRIFFIN_UDP_PAYLOAD_INSERTER_RD_PACKET_COUNTER(base);
    
    return 0;
}
