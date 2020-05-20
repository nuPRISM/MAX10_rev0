This component is intended to be placed into an SOPC Builder system.  It
receives incoming packets into an Avalon ST sink interface and it produces
packets out an Avalon ST source interface.

//  alignment_pad_remover
//  
//  This component simply removes two pad bytes from the beginning of an
//  Avalon ST packet.  This is useful for preparing packets for reception from
//  the Altera TSE MAC when it is configured to insert two pad bytes at the
//  beginning of each Avalon ST packet that it produces.
//  
