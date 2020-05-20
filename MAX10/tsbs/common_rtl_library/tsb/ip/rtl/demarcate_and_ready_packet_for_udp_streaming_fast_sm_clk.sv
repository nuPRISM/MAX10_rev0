`default_nettype none
module demarcate_and_ready_packet_for_udp_streaming_fast_sm_clk
#(
parameter numbits = 32,
parameter synchronizer_depth = 3
)
(
input  [numbits-1:0] indata,
output logic [numbits-1:0] outdata,
output valid,
output startofpacket,
output endofpacket,
input in_sop,
input in_eop,
input in_valid,
input packet_word_clk,
input fast_sm_clk,
input transpose_input,
input transpose_output,
input enable,
input reset,
input ready,
output [1:0] empty,
output reg found_sop = 0,
output reg found_eop = 0,
output found_sop_raw,
output found_eop_raw,
output reg [11:0] state = 0,
output [numbits-1:0] actual_possibly_transposed_indata,
output logic [15:0] packet_byte_count,
output new_packet_word_clk_has_arrived,
output reg found_valid = 0,
output found_valid_raw
);

parameter idle                            = 12'b0000_0000_0000;
parameter waiting_for_start_of_packet     = 12'b0000_0000_0001;
parameter strobe_valid_for_first_data     = 12'b0000_1001_1011;
parameter select_regular_data             = 12'b0010_0100_0100;
parameter check_if_eop_has_arrived        = 12'b0000_0000_0111;  
parameter strobe_valid_for_regular_data   = 12'b0000_0001_1000;
parameter strobe_valid_for_eop            = 12'b0001_0001_1010;
                                
assign valid                   = state[4];
assign startofpacket           = state[7];
assign endofpacket             = state[8];

assign empty = 0;
wire actual_enable;
wire actual_reset;

doublesync_no_reset
sync_reset
(
.indata(reset),
.outdata(actual_reset),
.clk(fast_sm_clk)
);
	
doublesync_no_reset
sync_enable
(
.indata(enable),
.outdata(actual_enable),
.clk(fast_sm_clk)
);

async_trap_and_reset_gen_1_pulse_robust 
make_data_ready_signal
(.async_sig(packet_word_clk), 
.outclk(fast_sm_clk), 
.out_sync_sig(new_packet_word_clk_has_arrived), 
.auto_reset(1'b1), 
.reset(1'b1)
);

registered_controlled_transpose_with_enable  //note sampling with fast_sm_clk; but we will not look at this until stable
#(
.numbits(numbits)
)
input_controlled_transpose
(
.indata(indata),
.outdata(actual_possibly_transposed_indata),
.enable(new_packet_word_clk_has_arrived),
.clk(fast_sm_clk),
.transpose(transpose_input)
);

assign outdata = actual_possibly_transposed_indata;

assign found_eop_raw   = in_eop;
assign found_sop_raw   = in_sop;
assign found_valid_raw = in_valid;

always @(posedge fast_sm_clk or posedge actual_reset)
begin
      if (actual_reset)
	  begin
	        found_valid <= 0;
	  end else
	  begin
	       if (new_packet_word_clk_has_arrived)
		   begin
                found_valid <= found_valid_raw;
		   end 
	  end
end

always @(posedge fast_sm_clk or posedge actual_reset)
begin
      if (actual_reset)
	  begin
	        found_eop <= 0;
	  end else
	  begin
	       if (new_packet_word_clk_has_arrived)
		   begin
                found_eop <= found_eop_raw;
		   end 
	  end
end


always @(posedge fast_sm_clk or posedge actual_reset)
begin
      if (actual_reset)
	  begin
	        found_sop <= 0;
	  end else
	  begin
	      if (new_packet_word_clk_has_arrived)
		   begin
                found_sop <= found_sop_raw;
		   end
	  end
end


always @(posedge fast_sm_clk or posedge actual_reset)
begin
     if (actual_reset)
	 begin
	      packet_byte_count <= 0; 
	 end else
	 begin 
	      if (found_sop)
		  begin
		      packet_byte_count <= 4;
		  end	
	      else 
		  begin
			   if (valid & (!found_eop))
			   begin
		 			packet_byte_count <= packet_byte_count + 4;
	 		   end 
		  end		 
	 end
end

always @(posedge fast_sm_clk or posedge actual_reset)
begin
      if (actual_reset)
	  begin
	        state <= idle;
	  end else
	  begin
	       case (state)
		   idle   : if (actual_enable) 
		            begin
						      state <= waiting_for_start_of_packet;		   		   
					   end 
										 
		   waiting_for_start_of_packet : if (found_sop && found_valid)
		                                 begin
										      //state <= select_extra_header_data;
										     state <= strobe_valid_for_first_data; 
										 end else
										 begin
										     state <= waiting_for_start_of_packet;
										 end

		   strobe_valid_for_first_data   : if (ready) begin state <= select_regular_data; end

		   select_regular_data : if (new_packet_word_clk_has_arrived)
		                          begin
								        state <= check_if_eop_has_arrived;
								  end
								  
			check_if_eop_has_arrived:  if (found_valid)
			                           begin			
			                                  if (found_eop)
                                              begin
      								                 state <= strobe_valid_for_eop; 
									          end else 
									          begin
		   	                                         state <= strobe_valid_for_regular_data; 
									          end
									   end else
									   begin
                                             state <= select_regular_data;
                                       end
		   strobe_valid_for_regular_data :  if (ready) begin state <= select_regular_data; end
		   										 		  
		   strobe_valid_for_eop : if (ready) begin state <= idle; end
		   
           endcase
      end
end

endmodule

`default_nettype wire
