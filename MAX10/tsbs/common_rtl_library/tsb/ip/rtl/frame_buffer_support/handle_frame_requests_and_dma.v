`default_nettype none
`include "log2_function.v"
`include "ikomed_types.sv"
module handle_frame_requests_and_dma
#(
parameter NUM_DATA_BITS = 16,
parameter NUM_ADDRESS_BITS = 32,
parameter NUMBUFFERS     = 4,
parameter NUMREADERS     = 2,
parameter FRAME_WIDTH                    = 1536,
parameter FRAME_HEIGHT                   = 1536,
parameter BUFFER_SIZE_IN_BYTES           = (2**log2(FRAME_WIDTH*FRAME_HEIGHT))*2,
parameter BUFFER_REPOSITORY_BASE_ADDRESS = 32'h10000000
)
(
input  logic driver_clk,
input  logic frame_request_from_driver[NUMREADERS],

input  logic frame_buffer_clk,
output logic frame_request_to_frame_buffer[NUMREADERS],
input  logic reset_frame_request_from_frame_buffer[NUMREADERS],

output logic [NUM_ADDRESS_BITS-1:0] next_writer_buffer_address,
output logic [NUM_ADDRESS_BITS-1:0] next_reader_buffer_address[NUMREADERS],
input  logic                        writer_is_currently_writing,
output logic                        writer_swap_buffers_now,
input  logic                        reader_swap_buffers_now[NUMREADERS],
output                              writer_has_finished_frame
);

(* keep = 1, preserve = 1 *) logic [NUM_ADDRESS_BITS-1:0] buffer_addresses[NUMBUFFERS];

genvar buf_index;
generate
			for (buf_index = 0; buf_index < NUMBUFFERS; buf_index++)
			begin : assign_buffer_addresses
                  assign buffer_addresses[buf_index] = BUFFER_REPOSITORY_BASE_ADDRESS+buf_index*BUFFER_SIZE_IN_BYTES;		
			end
endgenerate
genvar reader_index;
generate
             for (reader_index = 0; reader_index < NUMREADERS; reader_index++)
			begin : generate_frame_requests
					async_frame_request_handler
					async_frame_request_handler_inst
					(
					.driver_clk,
					.frame_request_from_driver(frame_request_from_driver[reader_index]),
					.frame_buffer_clk,
					.frame_request_to_frame_buffer(frame_request_to_frame_buffer[reader_index]),
					.reset_frame_request_from_frame_buffer(reset_frame_request_from_frame_buffer[reader_index])
					);	
			end
endgenerate

writer_and_multiple_reader_smart_cyclic_controller
#(
.num_data_bits (NUM_DATA_BITS),
.numbuffers    (NUMBUFFERS   ),
.numreaders    (NUMREADERS   )
)
writer_and_multiple_reader_smart_cyclic_controller_inst
(
.clk(frame_buffer_clk),
.buffer_addresses,
.next_writer_buffer_address,
.next_reader_buffer_address,
.writer_is_currently_writing,
.writer_swap_buffers_now,
.reader_swap_buffers_now,
.writer_has_finished_frame,
.next_write_buffer_index(),
.next_read_buffer_index(),
.writer_buffer_index(),
.reader_buffer_index()
);

endmodule
`default_nettype wire