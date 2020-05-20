This component is intended to be placed into an SOPC Builder system.  It
receives incoming packets into an Avalon ST sink interface and it produces
packets out an Avalon ST source interface.  This component is monitored and
controlled through an Avalon MM slave interface.

//
//  griffin_udp_payload_inserter
//
//  This component inserts a predefined raw packet payload into a fully framed
//  UDP packet for transport via Ethernet.  This means that the MAC header, IP
//  header and UDP header are all manufactured and prepended to the raw payload
//  data of the incoming packet.  The input and output for the packet data
//  streamed thru this component are provided by an Avalon ST sink and source
//  interface.  Configuration of this component is provided by an Avalon MM
//  slave interface.
//
//  The standard format of each of the header layers is illustrated below, you
//  can think of each layer being wrapped in the payload section of the layer
//  above it, with the Ethernet packet layout being the outer most wrapper.
//  
//  Standard Ethernet Packet Layout
//  |-------------------------------------------------------|
//  |                Destination MAC Address                |
//  |                           ----------------------------|
//  |                           |                           |
//  |----------------------------                           |
//  |                  Source MAC Address                   |
//  |-------------------------------------------------------|
//  |         EtherType         |                           |
//  |----------------------------                           |
//  |                                                       |
//  |                   Ethernet Payload                    |
//  |                                                       |
//  |-------------------------------------------------------|
//
//  Standard IP Packet Layout
//  |-------------------------------------------------------|
//  | VER  | HLEN |     TOS     |       Total Length        |
//  |-------------------------------------------------------|
//  |       Identification      | FLGS |    FRAG OFFSET     |
//  |-------------------------------------------------------|
//  |     TTL     |    PROTO    |      Header Checksum      |
//  |-------------------------------------------------------|
//  |                   Source IP Address                   |
//  |-------------------------------------------------------|
//  |                Destination IP Address                 |
//  |-------------------------------------------------------|
//  |                                                       |
//  |                      IP Payload                       |
//  |                                                       |
//  |-------------------------------------------------------|
//
//  Standard UDP Packet Layout
//  |-------------------------------------------------------|
//  |      Source UDP Port      |   Destination UDP Port    |
//  |-------------------------------------------------------|
//  |    UDP Message Length     |       UDP Checksum        |
//  |-------------------------------------------------------|
//  |                                                       |
//  |                      UDP Payload                      |
//  |                                                       |
//  |-------------------------------------------------------|
//
//  Proprietary RAW Input Packet Layout
//  |-------------------------------------------------------|
//  |       Packet Length       |                           |
//  |----------------------------                           |
//  |                                                       |
//  |                    Packet Payload                     |
//  |                                                       |
//  |-------------------------------------------------------|
//
//  The general packet assembly flows like this:
//  
//  This component begins by receiving the RAW input packet on its Avalon ST
//  interface, extracting and discarding the Packet Length field after
//  providing the length value to the UDP header layer such that the UDP
//  Message Length is now known.  The UDP Checksum field is zero'ed as this
//  component does not compute the UDP Checksum.  The Source UDP Port and
//  Destination UDP Port are known from user programmable registers within the
//  component.  Once the UDP Message Length is known, this is communicated
//  to the IP header so that the Total Length value is known.  Once the Total
//  Length value is known, the IP Header Checksum is computed.  The Source IP
//  Address and Destination IP Address are known from user programmable
//  registers within the component.  The Protocol field is set to UDP, the TTL
//  field is set to 255, the Fragment Offset field is set to ZERO, the Flags
//  are set to "do not fragment", the Identification field is set to ZERO, the
//  TOS field is set to ZERO, the Header Length field is set to 5, and the
//  Version field is set to 4.  At the MAC layer, the Destination MAC Address
//  and Source MAC Address are known from user programmable registers within
//  the component, and the EtherType field is set to 0x0800 for IPV4.
//  
//  The Ethernet Frame is transmitted out the Avalon ST source interface with
//  the Ethernet MAC header followed by the IP header, followed by the UDP
//  header and finally the RAW input packet payload.  The minimum size of an
//  Ethernet packet is 46 payload bytes, the IP header and UDP header consume
//  28 bytes, so if there are not at least 18 bytes of RAW packet payload, the
//  output packet is padded with up to 18 bytes of UDP Payload such that a
//  valid minimum sized Ethernet packet is transmitted.  The maximum size of
//  the Ethernet payload is 1500 bytes, so the largest valid size for the RAW
//  input packet payload is 1472 bytes, anything larger would result in an
//  invalid Ethernet packet length.  There are no checks built into the
//  hardware of this component that ensure the input packet length is within
//  proper limits, so the user should take care not to exceed packet lengths of
//  1472 bytes for input packet payload.  The minimum valid packet length is
//  ZERO, for the RAW input packet payload.
//
//  ---------------------------------------------------------------------------
//  Register Map
//  ---------------------------------------------------------------------------
//  
//  The slave interface for the griffin_udp_payload_inserter is broken up into eight
//  32-bit registers with the following layout:
//  
//  Register 0 - Status Register
//      Bit 0 - R/W - GO control and status bit.  Set this bit to 1 to enable
//                  the payload inserter, and clear it to disable it.
//      Bit 1 - RO  - Running status bit.  This bit indicates whether the
//                  peripheral is currently running or not.  After clearing the
//                  GO bit, you can monitor this status bit to tell when the
//                  inserter is actually stopped.
//      Bit 2 - RO  - Error status bit.  This bit indicates that an error
//                  occurred in the component.  There is only one error
//                  detected by this component, an Avalon ST protocol violation.
//                  When this component is enabled, it expect the first Avalon
//                  ST word that it receives on its sink interface to be the
//                  startofpacket, and when it receives an endofpacket word, it
//                  expects the next word to be the startofpacket for the next
//                  packet.  If this sequencing is not observed, then the Error
//                  status is asserted and the component's GO bit must be
//                  cleared to reset the error condition.
//      
//  Register 1 - Destination MAC HI Register
//      Bits [31:0] - R/W - these are the 32 most significant bits of the
//                  destination MAC address.  MAC bits [47:16].
//                  
//  Register 2 - Destination MAC LO Register
//      Bits [15:0] - R/W - these are the 16 least significant bits of the
//                  destination MAC address.  MAC bits [15:0].
//                  
//  Register 3 - Source MAC HI Register
//      Bits [31:0] - R/W - these are the 32 most significant bits of the
//                  source MAC address.  MAC bits [47:16].
//                  
//  Register 4 - Source MAC LO Register
//      Bits [15:0] - R/W - these are the 16 least significant bits of the
//                  source MAC address.  MAC bits [15:0].
//                  
//  Register 5 - Source IP Address Register
//      Bits [31:0] - R/W - this is the source IP adddress for the IP header
//                  
//  Register 6 - Destination IP Address Register
//      Bits [31:0] - R/W - this is the destination IP adddress for the IP header
//                  
//  Register 7 - UDP Ports Register
//      Bits [15:0]  - R/W - this is the destination UDP port for the UDP header
//      Bits [31:16] - R/W - this is the source UDP port for the UDP header
//                  
//  Register 8 - Packet Count Register
//      Bits [31:0] - R/WC - this is the number of packets that have been
//                  processed since the last reset or clearing of this register.
//                  
//  R - Readable
//  W - Writeable
//  RO - Read Only
//  WC - Clear on Write
//
