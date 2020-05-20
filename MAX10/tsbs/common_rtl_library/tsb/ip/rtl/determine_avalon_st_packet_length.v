`default_nettype none
`include "interface_defs.v"
module determine_avalon_st_packet_length
#(
parameter synchronizer_depth = 3
)
(
avalon_st_32_bit_packet_interface  avalon_st_interface_in,
input  wire reset_n,
output reg [15:0] packet_length_in_bytes = 0,
output reg [15:0] raw_packet_length = 0,
output reg [47:0] packet_count = 0,
output reg [63:0] total_byte_count = 0,
output wire packet_ended_now
);

wire actual_reset;

async_trap_and_reset_gen_1_pulse_robust
#(.synchronizer_depth(synchronizer_depth))  
make_reset_signal
(
.async_sig(!reset_n), 
.outclk(avalon_st_interface_in.clk), 
.out_sync_sig(actual_reset), 
.auto_reset(1'b1), 
.reset(1'b1)
);


always @(posedge avalon_st_interface_in.clk or posedge actual_reset)
begin
      if (actual_reset)
      begin
           raw_packet_length <= 0;
           total_byte_count <= 0;
      end else
      begin
             if (avalon_st_interface_in.valid && avalon_st_interface_in.ready)
             begin
                  total_byte_count <= total_byte_count + (4-avalon_st_interface_in.empty);
                  if (avalon_st_interface_in.sop)
                  begin
                        raw_packet_length <= 4-avalon_st_interface_in.empty;
                  end else
                  begin
                        raw_packet_length <= raw_packet_length + (4-avalon_st_interface_in.empty);                        
                  end             
             end             
      end  
end


always @(posedge avalon_st_interface_in.clk or posedge actual_reset)
begin
      if (actual_reset)
      begin
           packet_length_in_bytes <= 0;    
           packet_count <= 0;    
      end else
      begin
             if (avalon_st_interface_in.valid && avalon_st_interface_in.ready)
             begin
                  if (avalon_st_interface_in.eop)
                  begin
                       packet_length_in_bytes <= raw_packet_length + (4-avalon_st_interface_in.empty);                    
                       packet_count <=  packet_count+1;
                  end                
             end
      end  
end

edge_detector 
eop_edge_detector
(
 .insignal (avalon_st_interface_in.eop && avalon_st_interface_in.valid && avalon_st_interface_in.ready), 
 .outsignal(packet_ended_now), 
 .clk      (avalon_st_interface_in.clk)
);

    
endmodule
