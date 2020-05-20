//
// udp_image_line_packet_generator
//
// This component is designed to create sequenced packets of programmable
// length, filled with pseudo random data or sequential data.  The packets are transmitted from an
// Avalon ST source interface.  These packets are intended to be verified by
// the prbs_ checker on the receiving end of the data path.
//
// The packets are created with this format:
//
//  |-------------------------------------------------------|
//  |    PRBS Packet Length     |   Seq LSB   |   Seq MSB   |
//  |-------------------------------------------------------|
//  |             PRBS Data Word 0 (MSB first)              |
//  |-------------------------------------------------------|
//  |                                                       |
//  |                         . . .                         |
//  |                                                       |
//  |-------------------------------------------------------|
//  |             PRBS Data Word N (MSB first)              |
//  |-------------------------------------------------------|
//
//  PRBS Packet Length - is the length of the packet data not including this
//      length field.  This value is programmed via control register.
//
//  Sequence Number - is the packet sequence number which begins at ZERO when
//      the peripheral is enabled and then incremented for each subsequent
//      packet.
//
//  Sequence LSB - is the least significant byte of the sequence number
//
//  Sequence MSB - is the most significant byte of the sequence number
//
//  PRBS Data Word -
//      If  PRBS_EN bit is set to "0" :
//      A sequential counte starting with the value in "Initial Value"  Register and counting
//      to  "Initial Value" + "Packet Length Register"
//
//      If  PRBS_EN bit is set to "1" :
//      The pseudo random data pattern that fills the packet.
//      When the peripheral is enabled, the first PRBS data word is the initial
//      value which is programmed via control register.  Each subsequent PRBS
//      word is computed using the PRBS algorithm encoded in this peripheral,
//      which follows no standard PRBS generation scheme.  The PRBS data words
//      are transmitted most significant byte first, and it is perfectly legal
//      to transmit partial PRBS data words, depending on the packet length.
//      Packet lengths less than three will contain no PRBS data at all, and
//      only packets of length 7 or greater will contain enough PRBS data for
//      verification by the corresponding checker peripheral.
//

//  ---------------------------------------------------------------------------
//  Register Map
//  ---------------------------------------------------------------------------
//
//  The slave interface for the udp_image_line_packet_generator is broken up into four
//  32-bit registers with the following layout:
//
//  Register 0 - Status Register
//      Bit 0 - R/W - GO control and status bit.  Set this bit to 1 to enable
//                  the packet generator, and clear it to disable it.  Note
//                  that once cleared, the packet generator will not truely
//                  stop until it completes the current packe that it's
//                  generating.
//      Bit 1 - RO  - Running status bit.  This bit indicates whether the
//                  peripheral is currently running or not.  After clearing the
//                  GO bit, you can monitor this status bit to tell when the
//                  generator is truely stopped.
//      Bit 2 - R/W - PRBS_EN prbs enable bit. set this bit to 1 to enable PRBS modee
//
//  Register 1 - Packet Length Register
//      Bits [15:0] - R/W - byte count of packet payload length, does not
//                  include the length field of the packet.  The length value
//                  may be anything from 0x0000 thru 0xFFFF.
//
//  Register 2 - Initial Value Register
//      Bits [31:0] - R/W - the initial seed value for the PRBS pattern
//                  generator.  A good value for this is 0x33557799.
//
//  Register 3 - Packet Count Register
//      Bits [31:0] - R/WC - the packet count that this peripheral has
//                  generated since it's last reset, or clear.  Writing to any
//                  byte in this register will clear the packet count.
//
//  Register 4 - time stamp 31:0 register
//      Bits [31:0] - R/WC - the clock cycles count that this peripheral has
//                  generated since it's last reset, or clear.  Writing to any
//                  byte in this register will clear the packet count.
//
//  Register 5 - time stamp 47:32 register
//      Bits [15:0] - R/WC - the clock cycles count that this peripheral has
//                  generated since it's last reset, or clear.  Writing to any
//                  byte in this register will clear the event count.
//
//  Register 6 - data event Identifier and length
//      Bits [15:0] - R/W  -   bits 7:0      event ID  Default:     0x10:   Normal event
//                             bits 15:8     event LENGTH   Length of event (including header and checksum) , Default - 0x28  (40 words)
//
//  Register 7 - Source Address of data event
//      Bits [15:0] - R/W  -   bits [3:0] ADC channel number - default 0
//                         -   bits [7:4] ADC Chip ID        - default 0
//                         -   bits[11:8] FE Id              - default 0
//
//




//  R - Readable
//  W - Writeable
//  RO - Read Only
//  WC - Clear on Write
//


#include "udp_image_line_packet_generator.h"
#include "udp_image_line_packet_generator_regs.h"

//
// udp_image_line_packet_generator utility routines
//

int start_packet_generator(void *base, alt_u16 byte_count, alt_u32 initial_value) {
    
    alt_u32 current_csr;

    // is the packet generator already running?
    current_csr = UDP_IMAGE_LINE_PACKET_GENERATOR_RD_CSR(base);
    if(current_csr & UDP_IMAGE_LINE_PACKET_GENERATOR_CSR_GO_BIT_MASK) {
        return 1;
    }
    if(current_csr & UDP_IMAGE_LINE_PACKET_GENERATOR_CSR_RUNNING_BIT_MASK) {
        return 2;
    }
    
    // clear the counter    
    UDP_IMAGE_LINE_PACKET_GENERATOR_CLEAR_PACKET_COUNTER(base);
    
    // write the parameter registers
    UDP_IMAGE_LINE_PACKET_GENERATOR_WR_BYTE_COUNT(base, byte_count);
    UDP_IMAGE_LINE_PACKET_GENERATOR_WR_INITIAL_VALUE(base, initial_value);
    
    // and set the go bit
    UDP_IMAGE_LINE_PACKET_GENERATOR_WR_CSR(base, UDP_IMAGE_LINE_PACKET_GENERATOR_CSR_GO_BIT_MASK);
    
    return 0;
}

int stop_packet_generator(void *base) {
    
    // is the packet generator already stopped?
    if(!(UDP_IMAGE_LINE_PACKET_GENERATOR_RD_CSR(base) & UDP_IMAGE_LINE_PACKET_GENERATOR_CSR_GO_BIT_MASK)) {
        return 1;
    }

    // clear the go bit
    UDP_IMAGE_LINE_PACKET_GENERATOR_WR_CSR(base, 0);
    
    return 0;
}

int is_packet_generator_running(void *base) {
    
    // is the packet generator running?
    if((UDP_IMAGE_LINE_PACKET_GENERATOR_RD_CSR(base) & UDP_IMAGE_LINE_PACKET_GENERATOR_CSR_RUNNING_BIT_MASK)) {
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
    
    stats->csr_state        = UDP_IMAGE_LINE_PACKET_GENERATOR_RD_CSR(base);
    stats->byte_count       = UDP_IMAGE_LINE_PACKET_GENERATOR_RD_BYTE_COUNT(base);
    stats->initial_value    = UDP_IMAGE_LINE_PACKET_GENERATOR_RD_INITIAL_VALUE(base);
    stats->packet_count     = UDP_IMAGE_LINE_PACKET_GENERATOR_RD_PACKET_COUNTER(base);
    
    return 0;
}
