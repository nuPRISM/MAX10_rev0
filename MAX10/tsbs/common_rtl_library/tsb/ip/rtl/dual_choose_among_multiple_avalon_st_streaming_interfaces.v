`default_nettype none
`include "interface_defs.v"
module dual_choose_among_multiple_avalon_st_streaming_interfaces
#(
parameter num_selection_bits = 5,
parameter num_input_streams = 32,
parameter unselected_streams_ready_value = 1'b1
)
(
 multiple_avalon_st_streaming_interfaces avst_in_streams,
 avalon_st_streaming_interface avst_out_stream0,
 avalon_st_streaming_interface avst_out_stream1,
 input [num_selection_bits-1:0] sel0,
 input [num_selection_bits-1:0] sel1
);

assign avst_out_stream0.data = avst_in_streams.data[sel0];
assign avst_out_stream0.valid = avst_in_streams.valid[sel0];


assign avst_out_stream1.data = avst_in_streams.data[sel1];
assign avst_out_stream1.valid = avst_in_streams.valid[sel1];

integer current_stream;
wire [num_input_streams-1:0] raw_sel0;
wire [num_input_streams-1:0] raw_sel1;

always @*
begin
        for (current_stream = 0; current_stream < num_input_streams; current_stream++)
		begin
		      raw_sel0[current_stream] = (current_stream == sel0) ? avst_out_stream0.ready : unselected_streams_ready_value;
		      raw_sel1[current_stream] = (current_stream == sel1) ? avst_out_stream1.ready : unselected_streams_ready_value;
		      avst_in_streams.ready[current_stream] = raw_sel0[current_stream] | raw_sel1[current_stream];
		end
end

endmodule

