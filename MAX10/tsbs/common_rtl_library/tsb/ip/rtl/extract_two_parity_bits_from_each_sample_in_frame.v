`default_nettype none

module extract_two_parity_bits_from_each_sample_in_frame
#(
parameter num_samples_per_frame = 8,
parameter num_bits_per_sample = 16,
parameter num_bits_per_output_sample = num_bits_per_sample-2,
parameter in_framewidth = num_bits_per_sample*num_samples_per_frame,
parameter out_framewidth = num_bits_per_output_sample*num_samples_per_frame,
parameter parity_width = 2*num_samples_per_frame
)
(
input clk,
input [in_framewidth-1:0] data_frame_in,
output [out_framewidth-1:0] data_frame_out,
output [parity_width-1:0] parity_out

);
genvar i;
generate
         for (i = 0; i < num_samples_per_frame; i++)
		 begin : append_parity_loop
		     extract_two_parity_bits
			 #(
			 .data_in_width(num_bits_per_sample)
			 )
			 extract_two_parity_bits_inst
			 (
			 .clk(clk),
			 .data_in(data_frame_in[(i+1)*num_bits_per_sample-1 -: num_bits_per_sample]),
			 .data_out(data_frame_out[(i+1)*num_bits_per_output_sample-1 -: num_bits_per_output_sample]),
			 .parity_out(parity_out[(i+1)*2-1 -: 2])             			 
			 );
		 end
endgenerate

endmodule
`default_nettype wire
