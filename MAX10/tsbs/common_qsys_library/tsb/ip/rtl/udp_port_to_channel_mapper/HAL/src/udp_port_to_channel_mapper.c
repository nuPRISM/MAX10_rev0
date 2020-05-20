#include "udp_port_to_channel_mapper.h"
#include "udp_port_to_channel_mapper_regs.h"

//
// udp port to channel mapper utility routines
//

int map_udp_port_to_channel(void *base, alt_u32 channel, alt_u16 udp_port_number) {
    
    alt_u32 channel_reg;
    
    // is the channel already enabled?
    switch(channel) {
    case(0):
        channel_reg = UDP_PORT_MAPPER_RD_CHAN_0_PORT(base);
        break;
    case(1):
        channel_reg = UDP_PORT_MAPPER_RD_CHAN_1_PORT(base);
        break;
    case(2):
        channel_reg = UDP_PORT_MAPPER_RD_CHAN_2_PORT(base);
        break;
    case(3):
        channel_reg = UDP_PORT_MAPPER_RD_CHAN_3_PORT(base);
        break;
    default:
        return 1;
    }
    
    if(channel_reg & UDP_PORT_MAPPER_CHAN_X_EN_MASK) {
        return 2;
    }
    
    // not already enabled, then we enable it with the input port number
    channel_reg = udp_port_number & UDP_PORT_MAPPER_CHAN_X_PORT_MASK;
    channel_reg |= UDP_PORT_MAPPER_CHAN_X_EN_MASK;
    switch(channel) {
    case(0):
        UDP_PORT_MAPPER_WR_CHAN_0_PORT(base, channel_reg);
        break;
    case(1):
        UDP_PORT_MAPPER_WR_CHAN_1_PORT(base, channel_reg);
        break;
    case(2):
        UDP_PORT_MAPPER_WR_CHAN_2_PORT(base, channel_reg);
        break;
    case(3):
        UDP_PORT_MAPPER_WR_CHAN_3_PORT(base, channel_reg);
        break;
    default:
        return 1;
    }
    
    return 0;
}

int disable_udp_port_to_channel_mapping(void *base, alt_u32 channel) {
    
    alt_u32 channel_reg;
    
    // is the channel already disabled?
    switch(channel) {
    case(0):
        channel_reg = UDP_PORT_MAPPER_RD_CHAN_0_PORT(base);
        break;
    case(1):
        channel_reg = UDP_PORT_MAPPER_RD_CHAN_1_PORT(base);
        break;
    case(2):
        channel_reg = UDP_PORT_MAPPER_RD_CHAN_2_PORT(base);
        break;
    case(3):
        channel_reg = UDP_PORT_MAPPER_RD_CHAN_3_PORT(base);
        break;
    default:
        return 1;
    }
    
    if(!(channel_reg & UDP_PORT_MAPPER_CHAN_X_EN_MASK)) {
        return 2;
    }
    
    // not already disabled, then we disable it
    channel_reg &= ~UDP_PORT_MAPPER_CHAN_X_EN_MASK;
    switch(channel) {
    case(0):
        UDP_PORT_MAPPER_WR_CHAN_0_PORT(base, channel_reg);
        break;
    case(1):
        UDP_PORT_MAPPER_WR_CHAN_1_PORT(base, channel_reg);
        break;
    case(2):
        UDP_PORT_MAPPER_WR_CHAN_2_PORT(base, channel_reg);
        break;
    case(3):
        UDP_PORT_MAPPER_WR_CHAN_3_PORT(base, channel_reg);
        break;
    default:
        return 1;
    }
    
    return 0;
}

int get_udp_port_to_channel_mapper_stats(void *base, CHAN_MAP_STATS *stats) {
    
    alt_u32 channel_reg;
    
    channel_reg             = UDP_PORT_MAPPER_RD_CHAN_0_PORT(base);
    stats->chan_0_udp_port  = (alt_u16)((channel_reg & UDP_PORT_MAPPER_CHAN_X_PORT_MASK) >> UDP_PORT_MAPPER_CHAN_X_PORT_OFST);
    stats->chan_0_en        = (alt_u16)((channel_reg & UDP_PORT_MAPPER_CHAN_X_EN_MASK) >> UDP_PORT_MAPPER_CHAN_X_EN_OFST);

    channel_reg             = UDP_PORT_MAPPER_RD_CHAN_1_PORT(base);
    stats->chan_1_udp_port  = (alt_u16)((channel_reg & UDP_PORT_MAPPER_CHAN_X_PORT_MASK) >> UDP_PORT_MAPPER_CHAN_X_PORT_OFST);
    stats->chan_1_en        = (alt_u16)((channel_reg & UDP_PORT_MAPPER_CHAN_X_EN_MASK) >> UDP_PORT_MAPPER_CHAN_X_EN_OFST);
    
    channel_reg             = UDP_PORT_MAPPER_RD_CHAN_2_PORT(base);
    stats->chan_2_udp_port  = (alt_u16)((channel_reg & UDP_PORT_MAPPER_CHAN_X_PORT_MASK) >> UDP_PORT_MAPPER_CHAN_X_PORT_OFST);
    stats->chan_2_en        = (alt_u16)((channel_reg & UDP_PORT_MAPPER_CHAN_X_EN_MASK) >> UDP_PORT_MAPPER_CHAN_X_EN_OFST);

    channel_reg             = UDP_PORT_MAPPER_RD_CHAN_3_PORT(base);
    stats->chan_3_udp_port  = (alt_u16)((channel_reg & UDP_PORT_MAPPER_CHAN_X_PORT_MASK) >> UDP_PORT_MAPPER_CHAN_X_PORT_OFST);
    stats->chan_3_en        = (alt_u16)((channel_reg & UDP_PORT_MAPPER_CHAN_X_EN_MASK) >> UDP_PORT_MAPPER_CHAN_X_EN_OFST);

    stats->packet_count     = UDP_PORT_MAPPER_RD_PACKET_COUNTER(base);
    
    return 0;
}

int clear_udp_port_to_channel_mapper_counter(void *base) {
    
    UDP_PORT_MAPPER_CLEAR_PACKET_COUNTER(base);
    
    return 0;
}
