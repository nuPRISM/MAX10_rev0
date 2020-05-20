module decode_upper_10_bits_of_14bit_frame_with_8b_10b 
(
input reset,
input  [13:0] data_in,
output [11:0] data_out,
input  clk,
output control_character_detected,
output [7:0] decoded_8b_10b_data_fragment,
output reg [3:0] pipeline_delay_of_bits_3_to_0,
output [9:0] frame_region_8b_10b,
output coding_err,
output disparity,
output disparity_err  
);


assign frame_region_8b_10b = data_in[13:4];

always @(posedge clk)
begin
     pipeline_delay_of_bits_3_to_0 <= data_in[3:0]; //to match delay of 8b_10b encoder
end


 decoder_8b10b
 decoder_8b10b_inst (	  
   // --- Resets ---
  .reset(reset),

   // --- Clocks ---
   .RBYTECLK(clk),
		  
   // --- TBI (Ten Bit Interface) input bus
   .tbi(frame_region_8b_10b),

   // --- Control (K)
   .K_out(control_character_detected),
		  
   // -- Eight bit output bus
   .ebi(decoded_8b_10b_data_fragment),

   // --- 8B/10B RX coding error ---
   .coding_err(coding_err),
		 
   // --- 8B/10B RX disparity ---
   .disparity(disparity),
   
   // --- 8B/10B RX disparity error ---
   .disparity_err(disparity_err)
  
  );

assign data_out = {decoded_8b_10b_data_fragment,pipeline_delay_of_bits_3_to_0};

endmodule


