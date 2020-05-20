This component is intended to be placed into an SOPC Builder system.  It
receives incoming packets into an Avalon ST sink interface and it produces
packets out an Avalon ST source interface.  This component is monitored and
controlled through an Avalon MM slave interface.

//
//	udp_payload_extractor
//
//	This component extracts the UDP payload out of an Ethernet packet and
//	forwards it in a RAW proprietary packet format.  This component assumes
//	that the input packet is a valid UDP packet within an Ethernet frame.
//	The input and output for the packet data thru this component are provided
//	by an Avalon ST sink and source interface.  Status information is collected
//	thru an Avalon MM slave interface.
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
//  Proprietary RAW Output Packet Layout
//  |-------------------------------------------------------|
//  |       Packet Length       |                           |
//  |----------------------------                           |
//  |                                                       |
//  |                    Packet Payload                     |
//  |                                                       |
//  |-------------------------------------------------------|
//
//  The general payload extraction flows like this:
//  
//	This component begins by receiving the Ethenet packet on its Avalon ST
//	interface.  It is assumed that the Ethernet packet contains a valid UDP
//	packet that we wish to extract the payload from.  This component assumes
//	that the Ethernet MAC header is the first 14 bytes, followed by a standard
//	IP header of 20 bytes, followed by a standard UDP header of 8 bytes.  If
//	the packet format does not follow these assumptions, then it should not be
//	sent into this component.  This component will discard all of the protocol
//	headers until it gets to the UDP Message Length field, where it will read
//	the length value and use that to create the length field of the RAW output
//	packet that it creates for the UDP payload.  Once the payload length is
//	known, this component will create a RAW output packet that has the length
//	of the RAW packet payload as its first two bytes, followed by the UDP
//	payload from the input packet.
//
//	The RAW output packet will only contain the number of bytes indicated in
//	the UDP header for its payload.  Any Ethernet payload pad bytes as well as
//	the Frame Check Sequence will be discarded.
//
//  ---------------------------------------------------------------------------
//  Register Map
//  ---------------------------------------------------------------------------
//  
//  The slave interface for the udp_payload_extractor contains one 32-bit
//	register with the following layout:
//  
//  Register 0 - Packet Count Register
//      Bits [31:0] - R/WC - this is the number of packets that have been
//                  processed since the last reset or clearing of this register.
//                  
//  R - Readable
//  W - Writeable
//  WC - Clear on Write
//
