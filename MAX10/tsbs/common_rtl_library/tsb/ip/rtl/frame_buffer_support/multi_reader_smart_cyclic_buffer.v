`default_nettype none
`include "log2_function.v"
module multi_reader_smart_cyclic_buffer
#(
parameter numbuffers = 8,
parameter num_readers = 4,
parameter num_index_bits = log2(numbuffers),
parameter num_address_bits = 32
)
(
	input clk,
    output logic   [num_index_bits-1:0]   next_write_buffer_index,
    output logic   [num_index_bits-1:0]   next_read_buffer_index,
    input          [num_index_bits-1:0]   read_buffer_index[num_readers],
    output reg     [num_index_bits-1:0]   write_buffer_index = 1,
    input          writer_is_currently_writing,
    output         writer_has_finished_frame,
    output         swap_buffers_now,		
	output  logic  [numbuffers-1:0] buffer_is_free,
	output  logic error_all_buffers_are_in_use,
	output logic [num_readers-1:0] buffer_is_occupied[numbuffers]

	
	
);
logic writer_has_finished_frame_delay1;
logic writer_has_finished_frame_delay2;
logic writer_has_finished_frame_delay3;
logic writer_has_finished_frame_delay4;
logic a_free_buffer_exists;

assign error_all_buffers_are_in_use = ~a_free_buffer_exists;

non_sync_edge_detector writer_finish_edge_detector
		(
		 .insignal (!writer_is_currently_writing), 
		 .outsignal(writer_has_finished_frame), 
		 .clk      (clk)
		);


genvar i, j;
generate

          for (i = 0; i < numbuffers; i++)
		   begin : scan_buffers
				for (j = 0; j < num_readers; j++)
				begin : scan_readers
					  assign buffer_is_occupied[i][j] = (read_buffer_index[j] == i);
				end
		   end
endgenerate

always @(posedge clk)
begin
      for (int k = 0; k < numbuffers; k++)
	  begin : set_buffer_free_value
	            if (writer_has_finished_frame)
				begin
				     buffer_is_free[k] <= !(|buffer_is_occupied[k]) && !(write_buffer_index == k);
				end
	 end
end
									
find_first_free_buffer
#(
  .numbuffers(numbuffers)
 )
find_first_free_buffer_inst
(
 .clk(clk),
 .buffer_is_free(buffer_is_free),
 .free_buffer_decision(next_write_buffer_index),
 .a_free_buffer_exists(a_free_buffer_exists)
 );
   									
									
									
always @(posedge clk)
begin
      if (writer_has_finished_frame_delay2)
	  begin	 
	        next_read_buffer_index <= write_buffer_index;
	        write_buffer_index <= next_write_buffer_index; 
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
				    .outdata(writer_has_finished_frame_delay2),
				    .clk    (clk)
					);

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
delay3_writer_has_finished_frame(
                    .indata (writer_has_finished_frame_delay2),
				    .outdata(writer_has_finished_frame_delay3),
				    .clk    (clk)
					);
					
doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
delay4_writer_has_finished_frame(
                    .indata (writer_has_finished_frame_delay3),
				    .outdata(swap_buffers_now),
				    .clk    (clk)
					);
endmodule
`default_nettype wire