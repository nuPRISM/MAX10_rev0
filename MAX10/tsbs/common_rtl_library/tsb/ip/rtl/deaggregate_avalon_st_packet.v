module deaggregate_avalon_st_packet
(
input   [34:0] aggregated_avalon_st_packet,
output  [1:0]  empty, 
output         endofpacket,	
output         startofpacket, 
output         valid,         
output  [31:0] data  
);

assign  data =  aggregated_avalon_st_packet[31:0];
assign  valid =  aggregated_avalon_st_packet[32];
assign  startofpacket =  aggregated_avalon_st_packet[33];
assign  endofpacket =  aggregated_avalon_st_packet[34];
assign  empty =  0;

endmodule
