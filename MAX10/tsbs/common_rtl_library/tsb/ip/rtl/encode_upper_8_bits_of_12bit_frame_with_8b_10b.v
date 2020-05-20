module encode_upper_8_bits_of_12bit_frame_with_8b_10b 
(
input reset,
input [11:0] data_in,
output [13:0] data_out,
input clk,
output disparity,
input is_control_code,
output [9:0] coded_8b_10b_data_fragment
);

reg [3:0] pipeline_match_data_delay1, pipeline_match_data_delay2;

always @(posedge clk)
begin
     pipeline_match_data_delay1 <= data_in[3:0];
     pipeline_match_data_delay2 <= pipeline_match_data_delay1;
end

encoder_8b10b 
encoder_8b10b_inst
   (
		  
   // --- Resets
   .reset(reset),

   // --- Clocks
   .SBYTECLK(clk),
		  
   // --- Control (K) input	  
   .K(is_control_code),
		  
   // --- Eight Bt input bus	  
   .ebi(data_in[11:4]),
		
   // --- TB (Ten Bt Interface) output bus
   .tbi(coded_8b_10b_data_fragment),

   .disparity(disparity)
   );
   
   assign data_out = {coded_8b_10b_data_fragment,pipeline_match_data_delay2};
   
endmodule


