#ifndef ERROR_PACKET_DISCARD_REGS_H
#define ERROR_PACKET_DISCARD_REGS_H

#include "io.h"

// ERROR PACKET DISCARD ACCESS MACROS

#define ERROR_PACKET_DISCARD_RD_PACKET_COUNTER(base)            IORD(base, 0)
#define ERROR_PACKET_DISCARD_CLEAR_PACKET_COUNTER(base)         IOWR(base, 0, 0)

#define ERROR_PACKET_DISCARD_PACKET_COUNTER_MASK                (0xFFFFFFFF)
#define ERROR_PACKET_DISCARD_PACKET_COUNTER_OFST                (0)

#define ERROR_PACKET_DISCARD_RD_ERROR_PACKET_COUNTER(base)      IORD(base, 1)
#define ERROR_PACKET_DISCARD_CLEAR_ERROR_PACKET_COUNTER(base)   IOWR(base, 1, 0)

#define ERROR_PACKET_DISCARD_ERROR_PACKET_COUNTER_MASK          (0xFFFFFFFF)
#define ERROR_PACKET_DISCARD_ERROR_PACKET_COUNTER_OFST          (0)

#endif /*ERROR_PACKET_DISCARD_REGS_H*/
