This component is intended to be placed into an SOPC Builder system.  It
produces packets out an Avalon ST source interface.  This component is
monitored and controlled through an Avalon MM slave interface.

//
// prbs_packet_generator
//
// This component is designed to create sequenced packets of programmable
// length, filled with pseudo random data.  The packets are transmitted from an
// Avalon ST source interface.  These packets are intended to be verified by
// the prbs_packet_checker on the receiving end of the data path.
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
//  PRBS Data Word - is the pseudo random data pattern that fills the packet.
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
//  The slave interface for the prbs_packet_generator is broken up into four
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
//  R - Readable
//  W - Writeable
//  RO - Read Only
//  WC - Clear on Write
//
