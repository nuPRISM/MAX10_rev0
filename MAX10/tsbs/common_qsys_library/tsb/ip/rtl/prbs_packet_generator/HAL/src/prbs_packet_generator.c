#include "prbs_packet_generator.h"
#include "prbs_packet_generator_regs.h"

//
// prbs_packet_generator utility routines
//

int start_packet_generator(void *base, alt_u16 byte_count, alt_u32 initial_value) {
    
    alt_u32 current_csr;

    // is the packet generator already running?
    current_csr = PRBS_PACKET_GENERATOR_RD_CSR(base);
    if(current_csr & PRBS_PACKET_GENERATOR_CSR_GO_BIT_MASK) {
        return 1;
    }
    if(current_csr & PRBS_PACKET_GENERATOR_CSR_RUNNING_BIT_MASK) {
        return 2;
    }
    
    // clear the counter    
    PRBS_PACKET_GENERATOR_CLEAR_PACKET_COUNTER(base);
    
    // write the parameter registers
    PRBS_PACKET_GENERATOR_WR_BYTE_COUNT(base, byte_count);
    PRBS_PACKET_GENERATOR_WR_INITIAL_VALUE(base, initial_value);
    
    // and set the go bit
    PRBS_PACKET_GENERATOR_WR_CSR(base, PRBS_PACKET_GENERATOR_CSR_GO_BIT_MASK);
    
    return 0;
}

int stop_packet_generator(void *base) {
    
    // is the packet generator already stopped?
    if(!(PRBS_PACKET_GENERATOR_RD_CSR(base) & PRBS_PACKET_GENERATOR_CSR_GO_BIT_MASK)) {
        return 1;
    }

    // clear the go bit
    PRBS_PACKET_GENERATOR_WR_CSR(base, 0);
    
    return 0;
}

int is_packet_generator_running(void *base) {
    
    // is the packet generator running?
    if((PRBS_PACKET_GENERATOR_RD_CSR(base) & PRBS_PACKET_GENERATOR_CSR_RUNNING_BIT_MASK)) {
        return 1;
    }

    return 0;
}

int wait_until_packet_generator_stops_running(void *base) {
    
    // wait until packet generator stops running?
    while(is_packet_generator_running(base));

    return 0;
}

int get_packet_generator_stats(void *base, PKT_GEN_STATS *stats) {
    
    stats->csr_state        = PRBS_PACKET_GENERATOR_RD_CSR(base);
    stats->byte_count       = PRBS_PACKET_GENERATOR_RD_BYTE_COUNT(base);
    stats->initial_value    = PRBS_PACKET_GENERATOR_RD_INITIAL_VALUE(base);
    stats->packet_count     = PRBS_PACKET_GENERATOR_RD_PACKET_COUNTER(base);
    
    return 0;
}
