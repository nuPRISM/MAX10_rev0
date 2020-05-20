This component is intended to be placed into an SOPC Builder system.  It
receives incoming packets into an Avalon ST sink interface and it produces
packets out an Avalon ST source interface.  This component is monitored and
controlled through an Avalon MM slave interface.

//
//  udp_port_to_channel_mapper
//
//  This component is used to map incoming Ethernet packets onto specific
//  Avalon ST channels to allow them to be easily demultiplexed and routed.
//  This component receives Ethernet packets on an Avalon ST sink interface and
//  transmits the channelized packets out an Avalon ST source interface.  The
//  configuration and monitoring of this peripheral is performed thru an Avalon
//  MM slave interface.
//  
//  This component inspects the incoming Ethernet packet to locate specific
//  UDP packets that have been programmed in this component to map to a
//  specific Avalon ST channel.  There are 5 possible channels that this
//  component will map to, 4 programmable UDP port numbers, or the fifth
//  channel where all unmapped packets are assigned.
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
//  |                 Frame Check Sequence                  |
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
//  The general packet channel mapping flows like this:
//  
//  This component supports the mapping of up to 4 UDP port numbers.
//
//  The primary condition that this component looks at to qualify a packet to
//  be mapped to a channel is the Destination UDP Port number in the UDP
//  header.  However, as the Ethernet packet is received by this component a
//  number of other sanity checks are made to ensure that we have a UDP packet
//  to deal with.  Here are the qualifications that are applied to the various
//  fields of the header layers:
//  
//      MAC Destination Address     = X
//      MAC Source Address          = X
//      MAC EtherType               = must be IPV4
//      IP Version                  = must be IPV4
//      IP Header Length            = must be FIVE
//      IP Type of Service          = X
//      IP Total Length             = X
//      IP Identification           = X
//      IP Flags                    = must NOT be fragmented
//      IP Fragment Offset          = must be ZERO
//      IP Time to Live             = X
//      IP Protocol                 = must be UDP
//      IP Checksum                 = must verify
//      IP Source Address           = X
//      IP Destination Address      = X
//      UDP Source UDP Port         = X
//      UDP Destination UDP Port    = must match user programmed value
//      UDP UDP Message Length      = X
//      UDP UDP Checksum            = X
//      
//  If any of the observed fields do not match their expected values then the
//  packet will be assigned to the default channel and forwarded.  If all of
//  the fields match their expected values and the user has programmed a
//  particular UDP port number into a channel mapping and enabled it, then the
//  packet will be mapped onto that channel and forwarded.
//  
//  You can see that there are a few restrictions placed on the received
//  packets to make them eligible for mapping.  First, only a single MAC
//  header is allowed, no VLAN headers are allowed.  Second, only a standard 20
//  byte IP header is allowed, no option words are allowed.  Third, the packet
//  must not be fragmented.
//  
//  ---------------------------------------------------------------------------
//  Register Map
//  ---------------------------------------------------------------------------
//  
//  The slave interface for the udp_port_to_channel_mapper is broken up into 5
//  32-bit registers with the following layout:
//  
//  Register 0 - Channel 0 Mapping Register
//      Bits [15:0] - R/W - this is the destination UDP port value to map on this channel
//      Bits [16]   - R/W - this bit enables this channel, 1 is enabled, 0 is disabled
//                  
//  Register 1 - Channel 1 Mapping Register
//      Bits [15:0] - R/W - this is the destination UDP port value to map on this channel
//      Bits [16]   - R/W - this bit enables this channel, 1 is enabled, 0 is disabled
//                  
//  Register 2 - Channel 2 Mapping Register
//      Bits [15:0] - R/W - this is the destination UDP port value to map on this channel
//      Bits [16]   - R/W - this bit enables this channel, 1 is enabled, 0 is disabled
//                  
//  Register 3 - Channel 3 Mapping Register
//      Bits [15:0] - R/W - this is the destination UDP port value to map on this channel
//      Bits [16]   - R/W - this bit enables this channel, 1 is enabled, 0 is disabled
//                  
//  Register 4 - Packet Count Register
//      Bits [31:0] - R/WC - this is the number of packets that have been
//                  processed since the last reset or clearing of this register.
//                  
//  R - Readable
//  W - Writeable
//  WC - Clear on Write
//
