`default_nettype none

module extract_and_compare_parity_bits_from_frame
#(
parameter num_samples_per_frame = 8,
parameter num_bits_per_sample = 16,
parameter num_bits_per_output_sample = num_bits_per_sample-2,
parameter in_framewidth = num_bits_per_sample*num_samples_per_frame,
parameter out_framewidth = num_bits_per_output_sample*num_samples_per_frame,
parameter parity_width = 2*num_samples_per_frame
)
(
input use_even_parity,
input [in_framewidth-1:0] data_frame_in,
output [out_framewidth-1:0] data_frame_out,
output [parity_width-1:0] received_parity_out,
output [parity_width-1:0] calculated_parity_out,
output [parity_width-1:0] calculated_parity_difference,
output parity_error
);

extract_two_parity_bits_from_each_sample_in_frame_comb
#(
.num_samples_per_frame (num_samples_per_frame),
.num_bits_per_sample   (num_bits_per_sample  )
)
extract_two_parity_bits_comb_inst
(
.data_frame_in(data_frame_in),
.data_frame_out(data_frame_out),             			 
.parity_out(received_parity_out)             			 
);			
			
genvar i;
generate
  for (i = 0; i < num_samples_per_frame; i++)
  begin : append_parity_loop
     calculate_parity_comb
	 #(
	  .width(num_bits_per_output_sample/2)
	 )
	 calculate_parity_comb_low_inst
	 (
	 .data_in(data_frame_out[(i+1)*num_bits_per_output_sample - num_bits_per_output_sample/2-1 -: num_bits_per_output_sample/2]),
	 .parity(calculated_parity_out[2*i]),
     .use_even_parity(use_even_parity),	 
	 );
	 
     calculate_parity_comb
	 #(
	  .width(num_bits_per_output_sample/2)
	 )
	 calculate_parity_comb_high_inst
	 (
	 .data_in(data_frame_out[(i+1)*num_bits_per_output_sample-1 -: num_bits_per_output_sample/2]),
	 .parity(calculated_parity_out[2*i+1]),
     .use_even_parity(use_even_parity)	 
	 );
  end	
endgenerate

assign calculated_parity_difference = calculated_parity_out ^ received_parity_out;
assign parity_error = |calculated_parity_difference; 

endmodule
`default_nettype wire