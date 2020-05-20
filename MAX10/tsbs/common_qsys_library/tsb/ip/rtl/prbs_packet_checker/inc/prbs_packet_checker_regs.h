#ifndef PRBS_PACKET_CHECKER_REGS_H
#define PRBS_PACKET_CHECKER_REGS_H

#include "io.h"

// prbs_packet_checker accessor macros

#define PRBS_PACKET_CHECKER_RD_CSR(base)                    IORD(base, 0)
#define PRBS_PACKET_CHECKER_WR_CSR(base, data)              IOWR(base, 0, data)

#define PRBS_PACKET_CHECKER_CSR_GO_BIT_MASK                 (0x01)
#define PRBS_PACKET_CHECKER_CSR_GO_BIT_OFST                 (0)

#define PRBS_PACKET_CHECKER_RD_LENGTH_ERROR_COUNT(base)     IORD(base, 1)
#define PRBS_PACKET_CHECKER_RD_SEQUENCE_ERROR_COUNT(base)   IORD(base, 2)
#define PRBS_PACKET_CHECKER_RD_DATA_ERROR_COUNT(base)       IORD(base, 3)
#define PRBS_PACKET_CHECKER_RD_BYTE_COUNT(base)             IORD(base, 4)
#define PRBS_PACKET_CHECKER_RD_PACKET_COUNT(base)           IORD(base, 5)
#define PRBS_PACKET_CHECKER_CLEAR_COUNTERS(base)            IOWR(base, 1, 0)

#define PRBS_PACKET_CHECKER_COUNTERS_MASK                   (0xFFFFFFFF)
#define PRBS_PACKET_CHECKER_COUNTERS_OFST                   (0)

#endif /*PRBS_PACKET_CHECKER_REGS_H*/
