`default_nettype none
`include "interface_defs.v"
module quadruple_choose_among_multiple_avalon_st_streaming_interfaces
#(
parameter num_selection_bits = 5,
parameter num_input_streams = 32,
parameter unselected_streams_ready_value = 1'b1
)
(
 multiple_avalon_st_streaming_interfaces avst_in_streams,
 avalon_st_streaming_interface avst_out_stream0,
 avalon_st_streaming_interface avst_out_stream1,
 avalon_st_streaming_interface avst_out_stream2,
 avalon_st_streaming_interface avst_out_stream3,
 input [num_selection_bits-1:0] sel0,
 input [num_selection_bits-1:0] sel1,
 input [num_selection_bits-1:0] sel2,
 input [num_selection_bits-1:0] sel3
);

assign avst_out_stream0.data = avst_in_streams.data[sel0];
assign avst_out_stream0.valid = avst_in_streams.valid[sel0];


assign avst_out_stream1.data = avst_in_streams.data[sel1];
assign avst_out_stream1.valid = avst_in_streams.valid[sel1];


assign avst_out_stream2.data = avst_in_streams.data[sel2];
assign avst_out_stream2.valid = avst_in_streams.valid[sel2];


assign avst_out_stream3.data = avst_in_streams.data[sel3];
assign avst_out_stream3.valid = avst_in_streams.valid[sel3];

integer current_stream;
wire [num_input_streams-1:0] raw_sel0;
wire [num_input_streams-1:0] raw_sel1;
wire [num_input_streams-1:0] raw_sel2;
wire [num_input_streams-1:0] raw_sel3;

always_comb
begin
        for (current_stream = 0; current_stream < num_input_streams; current_stream++)
		begin
		      raw_sel0[current_stream] = (current_stream == sel0) ? avst_out_stream0.ready : unselected_streams_ready_value;
		      raw_sel1[current_stream] = (current_stream == sel1) ? avst_out_stream1.ready : unselected_streams_ready_value;
		      raw_sel2[current_stream] = (current_stream == sel2) ? avst_out_stream2.ready : unselected_streams_ready_value;
		      raw_sel3[current_stream] = (current_stream == sel3) ? avst_out_stream3.ready : unselected_streams_ready_value;
		      avst_in_streams.ready[current_stream] = raw_sel0[current_stream] | raw_sel1[current_stream] |  raw_sel2[current_stream] | raw_sel3[current_stream];
		end
end

endmodule

