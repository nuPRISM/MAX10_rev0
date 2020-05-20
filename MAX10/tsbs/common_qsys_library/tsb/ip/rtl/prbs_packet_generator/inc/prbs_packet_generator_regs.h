#ifndef PRBS_PACKET_GENERATOR_REGS_H
#define PRBS_PACKET_GENERATOR_REGS_H

#include "io.h"

// prbs_packet_generator accessor macros

#define PRBS_PACKET_GENERATOR_RD_CSR(base)                  IORD(base, 0)
#define PRBS_PACKET_GENERATOR_WR_CSR(base, data)            IOWR(base, 0, data)

#define PRBS_PACKET_GENERATOR_CSR_GO_BIT_MASK               (0x01)
#define PRBS_PACKET_GENERATOR_CSR_GO_BIT_OFST               (0)
#define PRBS_PACKET_GENERATOR_CSR_RUNNING_BIT_MASK          (0x02)
#define PRBS_PACKET_GENERATOR_CSR_RUNNING_BIT_OFST          (1)

#define PRBS_PACKET_GENERATOR_RD_BYTE_COUNT(base)           IORD(base, 1)
#define PRBS_PACKET_GENERATOR_WR_BYTE_COUNT(base, data)     IOWR(base, 1, data)

#define PRBS_PACKET_GENERATOR_BYTE_COUNT_MASK               (0xFFFF)
#define PRBS_PACKET_GENERATOR_BYTE_COUNT_OFST               (0)

#define PRBS_PACKET_GENERATOR_RD_INITIAL_VALUE(base)        IORD(base, 2)
#define PRBS_PACKET_GENERATOR_WR_INITIAL_VALUE(base, data)  IOWR(base, 2, data)

#define PRBS_PACKET_GENERATOR_INITIAL_VALUE_MASK            (0xFFFFFFFF)
#define PRBS_PACKET_GENERATOR_INITIAL_VALUE_OFST            (0)

#define PRBS_PACKET_GENERATOR_RD_PACKET_COUNTER(base)       IORD(base, 3)
#define PRBS_PACKET_GENERATOR_CLEAR_PACKET_COUNTER(base)    IOWR(base, 3, 0)

#define PRBS_PACKET_GENERATOR_PACKET_COUNTER_MASK           (0xFFFFFFFF)
#define PRBS_PACKET_GENERATOR_PACKET_COUNTER_OFST           (0)

#endif /*PRBS_PACKET_GENERATOR_REGS_H*/
