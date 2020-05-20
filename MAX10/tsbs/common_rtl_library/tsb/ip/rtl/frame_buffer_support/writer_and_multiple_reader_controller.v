`default_nettype none
`include "log2_function.v"
`include "ikomed_types.sv"
module writer_and_multiple_reader_smart_cyclic_controller
#(
parameter num_data_bits = 16,
parameter numbuffers = 4,
parameter numreaders = 2,
parameter num_buffer_index_bits = log2(numbuffers),
parameter num_reader_index_bits = log2(numreaders)
)
(
input clk,
input  logic [31:0] buffer_addresses[numbuffers],
output logic [31:0] next_writer_buffer_address,
output logic [31:0] next_reader_buffer_address[numreaders],
input  logic writer_is_currently_writing,
output  logic writer_swap_buffers_now,
input  logic reader_swap_buffers_now[numreaders],
output       writer_has_finished_frame,
output logic [num_buffer_index_bits-1:0] next_write_buffer_index,
output logic [num_buffer_index_bits-1:0] next_read_buffer_index,
output logic [num_buffer_index_bits-1:0] writer_buffer_index,
output logic [num_buffer_index_bits-1:0] reader_buffer_index[numreaders]
);

			
integer i;			
always @(posedge clk)
begin
       next_writer_buffer_address <= buffer_addresses[writer_buffer_index];
	   for (i = 0; i < numreaders; i = i + 1)
	   begin : set_next_reader_buffer_address
            next_reader_buffer_address[i] <= buffer_addresses[next_read_buffer_index];
	   end	  
end 

genvar j;
generate
		for (j = 0; j < numreaders; j = j+1)
		begin : set_current_buffer_index
				always @(posedge clk)
				begin
					   if (reader_swap_buffers_now[j])
					   begin
							 reader_buffer_index[j] <= next_read_buffer_index;
					   end			   
				end
		end
endgenerate

multi_reader_smart_cyclic_buffer
#(
.numbuffers(numbuffers), 
.num_readers(numreaders)
)
multi_reader_smart_cyclic_buffer_inst
(
	.clk(clk),
    .next_write_buffer_index,
    .next_read_buffer_index,
	.read_buffer_index(reader_buffer_index),
    .write_buffer_index(writer_buffer_index),
	.writer_is_currently_writing(writer_is_currently_writing),
    .writer_has_finished_frame,
    .swap_buffers_now(writer_swap_buffers_now)	
);

endmodule
`default_nettype wire


