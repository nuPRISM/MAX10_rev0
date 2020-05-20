`default_nettype none

module test_parity_generation_and_extraction
#(
parameter num_samples_per_frame = 8,
parameter num_bits_per_sample = 14,
parameter num_bits_per_output_sample = num_bits_per_sample+2,
parameter in_framewidth = num_bits_per_sample*num_samples_per_frame,
parameter out_framewidth = num_bits_per_output_sample*num_samples_per_frame,
parameter parity_width = 2*num_samples_per_frame
)
(
input clk,
input  [in_framewidth-1:0] data_frame_in,
output [in_framewidth-1:0] recovered_data_frame_in,
output [out_framewidth-1:0] data_frame_out,
input [out_framewidth-1:0] invert_bits_in_frame_out,
output [parity_width-1:0] received_parity_out,
output [parity_width-1:0] calculated_parity_out,
output [parity_width-1:0] calculated_parity_difference,
output parity_error
);

append_two_parity_bits_to_each_sample_in_frame
#(
.num_samples_per_frame(num_samples_per_frame),
.num_bits_per_sample(num_bits_per_sample)
)
append_two_parity_bits_to_each_sample_in_frame_inst
(
.clk(clk),
.data_frame_in(data_frame_in),
.data_frame_out(data_frame_out)
);


extract_and_compare_parity_bits_from_frame
#(
.num_samples_per_frame(num_samples_per_frame),
.num_bits_per_sample(num_bits_per_output_sample)
)
extract_and_compare_parity_bits_from_frame_inst
(
.clk(clk),
.data_frame_in(data_frame_out ^ invert_bits_in_frame_out),
.data_frame_out(recovered_data_frame_in),
.received_parity_out(received_parity_out),
.calculated_parity_out(calculated_parity_out),
.calculated_parity_difference(calculated_parity_difference),
.parity_error(parity_error)
);

endmodule
`default_nettype wire