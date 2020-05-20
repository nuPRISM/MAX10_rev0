This component is intended to be placed into an SOPC Builder system.  It
receives incoming packets into Avalon ST sink interfaces and it produces
packets out an Avalon ST source interface.

//
//  ethernet_packet_multiplexer
//
//  This component multiplexes 5 Avalon ST sink interfaces out one Avalon ST
//  source interface.  Once a pending channel is selected to transmit its data,
//  the mux allows the entire packet from that channel to transmit out the
//  source interface.  There is no arbitration applied to the multiplexing
//  schedule, it follows a simple round robin schedule of pending channels.
//
