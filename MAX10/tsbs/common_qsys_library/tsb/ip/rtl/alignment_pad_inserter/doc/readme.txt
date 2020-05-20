This component is intended to be placed into an SOPC Builder system.  It
receives incoming packets into an Avalon ST sink interface and it produces
packets out an Avalon ST source interface.

//  alignment_pad_inserter
//  
//  This component simply inserts two pad bytes at the beginning of an
//  Avalon ST packet.  This is useful for preparing packets for transmission
//  thru the Altera TSE MAC when it is configured to have two pad bytes at the
//  beginning of each Avalon ST packet that it consumes.
//  
