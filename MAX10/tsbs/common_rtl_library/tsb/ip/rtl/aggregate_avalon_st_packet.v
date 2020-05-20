module aggregate_avalon_st_packet
(
output [34:0] aggregated_avalon_st_packet,
input  [1:0]  empty, 
input         endofpacket,	
input         startofpacket, 
input         valid,         
input  [31:0] data  
);

assign   aggregated_avalon_st_packet =
		 {
    	  endofpacket,	
		  startofpacket, 
		  valid,         
		  data  
		  };

endmodule
