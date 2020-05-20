#include "prbs_packet_checker.h"
#include "prbs_packet_checker_regs.h"

//
// prbs_packet_checker utility routines
//

int start_packet_checker(void *base) {
    
    // is the packet checker already running?
    if(PRBS_PACKET_CHECKER_RD_CSR(base) & PRBS_PACKET_CHECKER_CSR_GO_BIT_MASK) {
        return 1;
    }
    
    // clear the counters   
    PRBS_PACKET_CHECKER_CLEAR_COUNTERS(base);
    
    // and set the go bit
    PRBS_PACKET_CHECKER_WR_CSR(base, PRBS_PACKET_CHECKER_CSR_GO_BIT_MASK);
    
    return 0;
}

int stop_packet_checker(void *base) {
    
    // is the packet checker already stopped?
    if(!(PRBS_PACKET_CHECKER_RD_CSR(base) & PRBS_PACKET_CHECKER_CSR_GO_BIT_MASK)) {
        return 1;
    }

    // clear the go bit
    PRBS_PACKET_CHECKER_WR_CSR(base, 0);
    
    return 0;
}

int get_packet_checker_stats(void *base, PKT_CHKR_STATS *stats) {
    
    stats->csr_state            = PRBS_PACKET_CHECKER_RD_CSR(base);
    stats->length_error_count   = PRBS_PACKET_CHECKER_RD_LENGTH_ERROR_COUNT(base);
    stats->sequence_error_count = PRBS_PACKET_CHECKER_RD_SEQUENCE_ERROR_COUNT(base);
    stats->data_error_count     = PRBS_PACKET_CHECKER_RD_DATA_ERROR_COUNT(base);
    stats->byte_count           = PRBS_PACKET_CHECKER_RD_BYTE_COUNT(base);
    stats->packet_count         = PRBS_PACKET_CHECKER_RD_PACKET_COUNT(base);
    
    return 0;
}
