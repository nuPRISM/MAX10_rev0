#ifndef UDP_PORT_TO_CHANNEL_MAPPER_REGS_H
#define UDP_PORT_TO_CHANNEL_MAPPER_REGS_H

#include "io.h"

// UDP PORT MAPPER ACCESS MACROS

#define UDP_PORT_MAPPER_RD_CHAN_0_PORT(base)        IORD(base, 0)
#define UDP_PORT_MAPPER_WR_CHAN_0_PORT(base, data)  IOWR(base, 0, data)

#define UDP_PORT_MAPPER_RD_CHAN_1_PORT(base)        IORD(base, 1)
#define UDP_PORT_MAPPER_WR_CHAN_1_PORT(base, data)  IOWR(base, 1, data)

#define UDP_PORT_MAPPER_RD_CHAN_2_PORT(base)        IORD(base, 2)
#define UDP_PORT_MAPPER_WR_CHAN_2_PORT(base, data)  IOWR(base, 2, data)

#define UDP_PORT_MAPPER_RD_CHAN_3_PORT(base)        IORD(base, 3)
#define UDP_PORT_MAPPER_WR_CHAN_3_PORT(base, data)  IOWR(base, 3, data)

#define UDP_PORT_MAPPER_CHAN_X_PORT_MASK            (0x0000FFFF)
#define UDP_PORT_MAPPER_CHAN_X_PORT_OFST            (0)
#define UDP_PORT_MAPPER_CHAN_X_EN_MASK              (0x00010000)
#define UDP_PORT_MAPPER_CHAN_X_EN_OFST              (16)

#define UDP_PORT_MAPPER_RD_PACKET_COUNTER(base)     IORD(base, 4)
#define UDP_PORT_MAPPER_CLEAR_PACKET_COUNTER(base)  IOWR(base, 4, 0)

#define UDP_PORT_MAPPER_PACKET_COUNTER_MASK         (0xFFFFFFFF)
#define UDP_PORT_MAPPER_PACKET_COUNTER_OFST         (0)

#endif /*UDP_PORT_TO_CHANNEL_MAPPER_REGS_H*/
