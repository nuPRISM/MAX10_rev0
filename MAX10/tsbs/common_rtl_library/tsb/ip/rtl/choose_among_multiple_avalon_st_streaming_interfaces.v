`default_nettype none
`include "interface_defs.v"
module choose_among_multiple_avalon_st_streaming_interfaces
#(
parameter num_selection_bits = 5,
parameter num_input_streams = 32,
parameter unselected_streams_ready_value = 1'b1
)
(
 multiple_avalon_st_streaming_interfaces avst_in_streams,
 avalon_st_streaming_interface avst_out_stream,
 input [num_selection_bits-1:0] sel
)

assign avst_out_stream.data = avst_in_streams[sel].data;
assign avst_out_stream.valid = avst_in_streams[sel].valid;

integer current_stream;

always @*
begin
        for (current_stream = 0; current_stream < num_input_streams; current_stream++)
		begin
		      avst_in_streams[current_stream].ready = (current_stream == sel) ? avst_out_stream.ready : unselected_streams_ready_value;
		end
end
endmodule

