`default_nettype none
`include "interface_defs.v"

module make_st_packet_from_triggered_data
#(
parameter num_packet_words = 8,
parameter num_counter_bits = 16,
parameter num_input_data_bits = 16
)
(
input clk,
input reset,
input trigger,
input [num_input_data_bits-1:0] indata,
avalon_st_streaming_interface  avalon_st_source_out,
output logic [num_counter_bits-1:0]  packet_word_counter,
output logic currently_processing_packet
);

assign avalon_st_source_out.clk = clk;

always_ff @(posedge clk)
begin
        avalon_st_source_out.data <= #1 indata;
end

always_ff @(posedge clk)
begin
      if (reset)
	  begin
	         packet_word_counter <= #1 0;
	         currently_processing_packet <= #1 0;
			 avalon_st_source_out.sop <= #1  0;
			 avalon_st_source_out.eop <= #1 0;
	  end else
      begin 
			  if (packet_word_counter == 0)
			  begin
					if (trigger)
					begin
							currently_processing_packet <= #1 1;
							packet_word_counter <= #1 packet_word_counter + 1;
							avalon_st_source_out.sop <= #1 1;
							avalon_st_source_out.eop <= #1 0;
					end else
					begin
							 packet_word_counter <= #1 0;
							 currently_processing_packet <= #1 0;
							 avalon_st_source_out.sop <= #1 0;
							 avalon_st_source_out.eop <= #1 0;
					end
			  end else
			  begin
					if (currently_processing_packet)
					begin
							if (packet_word_counter == num_packet_words-1)
							begin
								 packet_word_counter <= #1 0;
								 currently_processing_packet <= #1 1;
								 avalon_st_source_out.sop <= #1 0;
								 avalon_st_source_out.eop <= #1 1;
							end else 
							begin
								 packet_word_counter <= #1 packet_word_counter+1;
								 currently_processing_packet <= #1 1;
								 avalon_st_source_out.sop <= #1 0;
								 avalon_st_source_out.eop <= #1 0;
							end
					end
			  end
	 end
end

assign avalon_st_source_out.empty = 0;
assign avalon_st_source_out.error = 0;
assign avalon_st_source_out.valid = currently_processing_packet;

endmodule
`default_nettype wire