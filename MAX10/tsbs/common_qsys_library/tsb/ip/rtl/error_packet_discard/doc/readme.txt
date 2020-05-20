This component is intended to be placed into an SOPC Builder system.  It
receives incoming packets into an Avalon ST sink interface and it produces
packets out an Avalon ST source interface.  This component is monitored through
an Avalon MM slave interface.

//
//  error_packet_discard
//
//  This component monitors an incoming packet on its Avalon ST interface for
//  any error signal.  If an error signal is detected, this component discards
//  the packet.  If no error signal is detected, then this component forwards
//  the packet out its Avalon ST source interface.  This component uses a store
//  and forward algorithm, whereby it will store each packet it receives in a
//  local FIFO, and upon successfully receiving the entire packet, it will then
//  forward the packet on, or in the event of an error, it will discard the
//  packet.  The local FIFO in this component is able to hold 2KB of packet
//  data, it is intended to filter out errant Ethernet packets which are
//  assumed to be no greater than 1518 bytes long, so there should be plenty
//  of FIFO buffer to manage a full sized Ethernet packet.
//
//  ---------------------------------------------------------------------------
//  Register Map
//  ---------------------------------------------------------------------------
//  
//  The slave interface for the error_packet_discard is broken up into two
//  32-bit registers with the following layout:
//  
//  Register 0 - Packet Count Register
//      Bits [31:0] - R/WC - this is the total number of packets that have been
//                  processed since the last reset or clearing of this register.
//                  This includes valid packets as well as error'ed packet.
//                  
//  Register 1 - Error Packet Count Register
//      Bits [31:0] - R/WC - this is the number of error'ed packets that have
//                  been processed since the last reset or clearing of this 
//                  register.
//                  
//  R - Readable
//  W - Writeable
//  WC - Clear on Write
//

