`default_nettype none
`include "log2_function.v"
`include "ikomed_types.sv"
module handle_frame_requests_and_dma_w_structs
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
input  logic frame_request_from_driver_array[NUMREADERS],

input  logic frame_buffer_clk,
complete_dma_frame_buffer_hw_control_interface frame_buffer_interface_pins
);

(* keep = 1, preserve = 1 *) logic  get_frame_now_ack_array[NUMREADERS];
(* keep = 1, preserve = 1 *) logic  reader_swap_buffers_now[NUMREADERS];
(* keep = 1, preserve = 1 *) logic [NUM_ADDRESS_BITS-1:0] next_reader_buffer_address[NUMREADERS];
(* keep = 1, preserve = 1 *) logic frame_request_to_frame_buffer[NUMREADERS];
logic                        writer_swap_buffers_now;

assign frame_buffer_interface_pins.frame_dma_writer_hw_control_struct.default_buffer_address       = BUFFER_REPOSITORY_BASE_ADDRESS + BUFFER_SIZE_IN_BYTES;
assign frame_buffer_interface_pins.frame_dma_writer_hw_control_struct.default_back_buf_address     = BUFFER_REPOSITORY_BASE_ADDRESS;

genvar reader_index;
generate
             for (reader_index = 0; reader_index < NUMREADERS; reader_index++)
			begin : assign_reader_arrays	
                    assign frame_buffer_interface_pins.frame_dma_reader_hw_control_struct[reader_index].default_buffer_address    = BUFFER_REPOSITORY_BASE_ADDRESS;
                    assign frame_buffer_interface_pins.frame_dma_reader_hw_control_struct[reader_index].default_back_buf_address  = BUFFER_REPOSITORY_BASE_ADDRESS + BUFFER_SIZE_IN_BYTES;			
					assign get_frame_now_ack_array[reader_index] = frame_buffer_interface_pins.frame_dma_reader_hw_control_struct[reader_index].get_frame_now_ack;
                    assign frame_buffer_interface_pins.frame_dma_reader_hw_control_struct[reader_index].external_priority_backbuffer_address = next_reader_buffer_address[reader_index];					
					assign reader_swap_buffers_now[reader_index] = frame_buffer_interface_pins.frame_dma_reader_hw_control_struct[reader_index].swap_buffers_now;
					assign frame_buffer_interface_pins.frame_dma_reader_hw_control_struct[reader_index].get_frame_now =  frame_request_to_frame_buffer[reader_index];
			end
endgenerate



handle_frame_requests_and_dma
#(
.NUM_DATA_BITS    (NUM_DATA_BITS),
.NUM_ADDRESS_BITS (NUM_ADDRESS_BITS),
.NUMBUFFERS       (NUMBUFFERS ),
.NUMREADERS       (NUMREADERS ),
.FRAME_WIDTH                   (FRAME_WIDTH),
.FRAME_HEIGHT                  (FRAME_HEIGHT),
.BUFFER_REPOSITORY_BASE_ADDRESS(BUFFER_REPOSITORY_BASE_ADDRESS),
.BUFFER_SIZE_IN_BYTES          (BUFFER_SIZE_IN_BYTES)
)
handle_frame_requests_and_dma_inst
(
.driver_clk(driver_clk),
.frame_request_from_driver(frame_request_from_driver_array),
.frame_buffer_clk(frame_buffer_clk),
.frame_request_to_frame_buffer(frame_request_to_frame_buffer),
.reset_frame_request_from_frame_buffer(get_frame_now_ack_array),
.next_writer_buffer_address(frame_buffer_interface_pins.frame_dma_writer_hw_control_struct.external_priority_backbuffer_address),
.next_reader_buffer_address(next_reader_buffer_address),
.writer_is_currently_writing(frame_buffer_interface_pins.frame_dma_writer_hw_control_struct.currently_processing_packet),
.writer_swap_buffers_now(frame_buffer_interface_pins.frame_dma_writer_hw_control_struct.external_swap_buffer_now),
.reader_swap_buffers_now(reader_swap_buffers_now),
.writer_has_finished_frame()
);


endmodule
`default_nettype wire