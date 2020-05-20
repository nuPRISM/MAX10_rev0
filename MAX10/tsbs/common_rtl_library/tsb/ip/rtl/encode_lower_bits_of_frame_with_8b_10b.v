module encode_lower_bits_of_frame_with_8b_10b 
#(
parameter input_frame_length = 38,
parameter output_frame_length = input_frame_length + 2

)
(
input reset,
input [input_frame_length-1:0] data_in,
output [output_frame_length-1:0] data_out,
input clk,
output disparity,
input is_control_code,
output [9:0] coded_8b_10b_data_fragment
);

reg [input_frame_length-1:8] pipeline_match_data_delay1, pipeline_match_data_delay2;

always @(posedge clk)
begin
     pipeline_match_data_delay1 <= data_in[input_frame_length-1 : 8];
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
   .ebi(data_in[7:0]),
		
   // --- TB (Ten Bt Interface) output bus
   .tbi(coded_8b_10b_data_fragment),

   .disparity(disparity)
   );
   
   assign data_out = {pipeline_match_data_delay2,coded_8b_10b_data_fragment};
   
endmodule


