`default_nettype none

module append_two_parity_bits_to_each_sample_in_frame
#(
parameter num_samples_per_frame = 8,
parameter num_bits_per_sample = 14,
parameter num_bits_per_output_sample = num_bits_per_sample+2,
parameter in_framewidth = num_bits_per_sample*num_samples_per_frame,
parameter out_framewidth = num_bits_per_output_sample*num_samples_per_frame
)
(
input clk,
input [in_framewidth-1:0] data_frame_in,
input in_valid,
output [out_framewidth-1:0] data_frame_out,
output reg out_valid = 0,
input use_even_parity

);
genvar i;
generate
         always_ff @(posedge clk)
		 begin
			       out_valid <= in_valid; //one clock delay to match clock delay of "append_two_parity_bits";
		 end
		 
         for (i = 0; i < num_samples_per_frame; i++)
		 begin : append_parity_loop
		 
		   
			 
		     append_two_parity_bits
			 #(
			 .width(num_bits_per_sample)
			 )
			 append_two_parity_bits_inst
			 (
			 .clk(clk),
			 .use_even_parity(use_even_parity),
			 .data_in(data_frame_in[(i+1)*num_bits_per_sample-1 -: num_bits_per_sample]),
			 .data_out(data_frame_out[(i+1)*num_bits_per_output_sample-1 -: num_bits_per_output_sample])			 
			 );
		 end
endgenerate

endmodule
`default_nettype wire
