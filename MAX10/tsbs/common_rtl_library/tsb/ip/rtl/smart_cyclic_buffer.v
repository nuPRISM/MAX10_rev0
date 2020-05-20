`default_nettype none
module smart_cyclic_buffer
#(
parameter numbuffers = 4,
parameter num_index_bits = $clog2(numbuffers),
parameter num_address_bits = 32,
parameter synchronizer_depth = 2
)
(
	input clk,
    output logic   [num_index_bits-1:0]   next_write_buffer_index,
    output logic   [num_index_bits-1:0]   next_read_buffer_index,
    input          [num_index_bits-1:0]   read_buffer_index,
    output reg     [num_index_bits-1:0]   write_buffer_index = 1,
    output logic   [num_address_bits-1:0] next_write_buffer_address,
    output logic   [num_address_bits-1:0] next_read_buffer_address,
	input          [num_address_bits-1:0] buffer_addresses[numbuffers],
	input          writer_is_currently_writing,
    output         writer_has_finished_frame,
    output         swap_buffers_now		
);
logic writer_has_finished_frame_delay1;

non_sync_edge_detector writer_finish_edge_detector
		(
		 .insignal (!writer_is_currently_writing), 
		 .outsignal(writer_has_finished_frame), 
		 .clk      (clk)
		);
			       
//skip buffer in use; take advantage of modulo behavior for wraparound
assign next_write_buffer_index  = ((read_buffer_index == (write_buffer_index+2)) ?
			                        (write_buffer_index+3) : (write_buffer_index+2));
always @(posedge clk)
begin
      if (writer_has_finished_frame)
	  begin	 
	        next_read_buffer_index <= write_buffer_index;
            next_read_buffer_address <= buffer_addresses[write_buffer_index]; //current buffer is now done
	        write_buffer_index <= next_write_buffer_index; 
	        next_write_buffer_address <= buffer_addresses[next_write_buffer_index]; 
	  end
end

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
delay1_writer_has_finished_frame(.indata (writer_has_finished_frame),
				    .outdata(writer_has_finished_frame_delay1),
				    .clk    (clk)
					);
					
doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
delay2_writer_has_finished_frame(
                    .indata (writer_has_finished_frame_delay1),
				    .outdata(swap_buffers_now),
				    .clk    (clk)
					);

endmodule
`default_nettype wire