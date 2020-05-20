
module demarcate_griffin_packet_fast_sm_clk
#(
parameter SOP_Marker = 32'h08000000,
parameter SOP_Mask   = 32'hFF000000,
parameter EOP_Marker = 32'h0E000000,
parameter EOP_Mask   = 32'hFF000000,
parameter numbits = 32
)
(
input  [numbits-1:0] indata,
output logic [numbits-1:0] outdata,
output valid,
output startofpacket,
output endofpacket,
input packet_work_clk,
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
output found_sop_synced,
output found_eop_synced,
output reg [11:0] state = 0,
output [numbits-1:0] possibly_transposed_indata,
output [numbits-1:0] actual_possibly_transposed_indata,
output logic [15:0] packet_byte_count,
output select_inserted_data,
output [numbits-1:0] inserted_data,
output [numbits-1:0] actual_output_data,
output enable_output_data,
output new_packet_work_clk_has_arrived,
input  [numbits-1:0]  fixed_header_data 

);

parameter idle                            = 12'b0000_0000_0000;
parameter waiting_for_start_of_packet     = 12'b0000_0000_0001;
parameter select_extra_header_data        = 12'b0000_0110_0010;
parameter strobe_valid_for_extra_data     = 12'b0000_1011_0011;
parameter remove_valid_for_extra_data     = 12'b0000_0100_1100;
parameter strobe_data_for_first_data      = 12'b0000_0001_1011;
parameter select_regular_data             = 12'b0000_0100_0100;
parameter check_if_eop_has_arrived_wait1  = 12'b0000_0000_0101; 
parameter check_if_eop_has_arrived_wait2  = 12'b0000_0000_0110;
parameter check_if_eop_has_arrived        = 12'b0000_0000_0111;  
parameter strobe_valid_for_regular_data   = 12'b0000_0001_1000;
parameter found_end_of_packet             = 12'b0000_0100_1001;
parameter strobe_valid_for_eop            = 12'b0001_0001_1010;
                                
assign valid                   = state[4];
assign select_inserted_data    = state[5];
assign enable_output_data      = state[6];
assign startofpacket           = state[7];
assign endofpacket             = state[8];

assign inserted_data = fixed_header_data;

assign empty = 0;

async_trap_and_reset_gen_1_pulse 
make_data_ready_signal
(.async_sig(packet_work_clk), 
.outclk(fast_sm_clk), 
.out_sync_sig(new_packet_work_clk_has_arrived), 
.auto_reset(1'b1), 
.reset(1'b1)
);

registered_controlled_transpose_with_enable
#(
.numbits(numbits)
)
input_controlled_transpose
(
.indata(indata),
.outdata(possibly_transposed_indata),
.enable(1'b1),
.clk(packet_work_clk),
.transpose(transpose_input)
);

registered_controlled_transpose_with_enable
#(
.numbits(numbits)
)
input_pipeline_reg
(
.indata(possibly_transposed_indata),
.outdata(actual_possibly_transposed_indata),
.enable(1'b1),
.clk(packet_work_clk),
.transpose(1'b0)
);


assign actual_output_data = select_inserted_data ? inserted_data : actual_possibly_transposed_indata;
//the output transposition is necessary for delay matching and also in case Avalon ST wants the bits in reverse position
registered_controlled_transpose_with_enable
#(
.numbits(numbits)
)
output_controlled_transpose
(
.indata(actual_output_data),
.outdata(outdata),
.enable(enable_output_data),
.clk(fast_sm_clk),
.transpose(transpose_input)
);


assign found_eop_raw = ((possibly_transposed_indata & EOP_Mask) ==  EOP_Marker);
assign found_sop_raw = ((possibly_transposed_indata & SOP_Mask) ==  SOP_Marker);

always @(posedge packet_work_clk or posedge reset)
begin
      if (reset)
	  begin
	        found_eop <= 0;
	  end else
	  begin
	       if (found_eop_raw)
		   begin
                found_eop <= 1;
		   end else 
		   begin
		        found_eop <= 0;
		   end
	  end
end


always @(posedge packet_work_clk or posedge reset)
begin
      if (reset)
	  begin
	        found_sop <= 0;
	  end else
	  begin
	       if (found_sop_raw)
		   begin
                found_sop <= 1;
		   end else 
		   begin
		        found_sop <= 0;
		   end
	  end
end

 doublesync_no_reset
 sync_found_sop
 (
 .indata(found_sop),
 .outdata(found_sop_synced),
 .clk(fast_sm_clk)
 );


 doublesync_no_reset
 sync_found_eop
 (
 .indata(found_eop),
 .outdata(found_eop_synced),
 .clk(fast_sm_clk)
 );


always @(posedge fast_sm_clk or posedge reset)
begin
     if (reset)
	 begin
	      packet_byte_count <= 0; 
	 end else
	 begin 
	      if (found_sop_raw)
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




always @(posedge fast_sm_clk or posedge reset)
begin
      if (reset)
	  begin
	        state <= idle;
	  end else
	  begin
	       case (state)
		   idle                        : if (enable) 
		                                 begin
										      state <= waiting_for_start_of_packet;		   		   
										 end 
										 
		   waiting_for_start_of_packet : if (found_sop_synced)
		                                 begin
										      state <= select_extra_header_data;
										 end else
										 begin
										     state <= waiting_for_start_of_packet;
										 end
				
           select_extra_header_data:  if (ready) begin state <= strobe_valid_for_extra_data; end
          		   
		   strobe_valid_for_extra_data : state <= remove_valid_for_extra_data;
		   remove_valid_for_extra_data : state <= strobe_data_for_first_data;
		   strobe_data_for_first_data   : state <= select_regular_data;

		   select_regular_data : if (new_packet_work_clk_has_arrived)
		                          begin
								        state <= check_if_eop_has_arrived_wait1;
								  end
								  
			check_if_eop_has_arrived_wait1:  state <= check_if_eop_has_arrived_wait2;
			check_if_eop_has_arrived_wait2:  state <= check_if_eop_has_arrived;
			check_if_eop_has_arrived:         if (found_eop_synced)
                                              begin
      								                 state <= found_end_of_packet; 
									          end else 
									          begin
		   	                                             if (ready) begin state <= strobe_valid_for_regular_data; end
									          end
		   strobe_valid_for_regular_data :  state <= select_regular_data;
		   
										 
           found_end_of_packet         : if (ready) begin state <= strobe_valid_for_eop; end
		   
		   strobe_valid_for_eop : state <= idle;
		   
           endcase
      end
end

endmodule


