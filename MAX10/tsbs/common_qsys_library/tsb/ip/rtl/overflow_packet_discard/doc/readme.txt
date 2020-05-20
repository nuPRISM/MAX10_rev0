This component is intended to be placed into an SOPC Builder system.  It
receives incoming packets into an Avalon ST sink interface and it produces
packets out an Avalon ST source interface.  This component is monitored through
an Avalon MM slave interface.

//
//  overflow_packet_discard
//
//  This component contains a 4KB FIFO which it uses as an elastic overflow
//  buffer for the packet stream arriving on it's Avalon ST sink interface.
//  Packets are received on the Avalon ST sink interface and buffered in the
//  local FIFO memory until the Avalon ST source is allowed to transmit them
//  to the next peripheral.  If the Avalon ST source interface is back
//  pressured such that it cannot transmit packets forward, then the FIFO will
//  fill to a point where it cannot hold any additional packet data, at which
//  point it will mark the last packet it was receiving as discarded, and it
//  will continue to discard any further packets until the source is allowed to
//  empty data from the FIFO to make room for new packets.
//  
//  This component uses a store and forward algorithm to buffer the packets in
//  the FIFO.  Once it begins receiving a packet, it waits until it has
//  received the entire packet before it begins transmitting the packet forward
//  on its Avalon ST source interface.  This is done to ensure that the
//  component can ensure that once it begins transmitting a packet forward that
//  it actually has the entire packet available.
//
//  ---------------------------------------------------------------------------
//  Register Map
//  ---------------------------------------------------------------------------
//  
//  The slave interface for the overflow_packet_discard contains one 32-bit
//  registers with the following layout:
//  
//  Register 0 - Discarded Packet Count Register
//      Bits [31:0] - R/WC - this is the number of discarded packets that have
//                  been processed since the last reset or clearing of this 
//                  register.
//                  
//  R - Readable
//  W - Writeable
//  WC - Clear on Write
//
