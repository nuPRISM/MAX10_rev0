`default_nettype none
module vip_to_cameralink_out_convert  
#(
parameter NUM_DATA_BITS = 16,
parameter FRAME_DELAY_COUNTER_VAL = 8,
parameter FRAME_WIDTH_COUNTER_VAL = 5,
parameter INVERT_FRAMEVALID_OUTPUT = 1'b1
)
(
input  logic clk, reset,
input  logic [NUM_DATA_BITS-1:0] in_data,
input  in_linevalid,
input  in_framevalid,
input  in_data_valid,
output logic [NUM_DATA_BITS-1:0] out_data,
output logic out_linevalid,
output logic out_framevalid,
output logic out_data_valid,
output reg [11:0] state,
output reg [15:0] frame_delay_counter,
output reg [15:0] frame_width_counter,
output logic got_frame_valid_edge
);

wire strobe_read_reg;
assign out_data = in_data;
assign out_linevalid = in_linevalid;
assign out_data_valid = in_data_valid;
			 		                       
parameter idle		 		            = 12'b0000_0000_0000;
parameter start_frame_valid_delay 		= 12'b0000_0101_0001;
parameter start_frame_delay_pulse 	    = 12'b0000_1110_0010; 

wire    enable_delay_counter = state[4];
wire    enable_width_counter = state[5];
wire    reset_counters       = !state[6];
assign  out_framevalid       = INVERT_FRAMEVALID_OUTPUT^state[7];

non_sync_edge_detector 
detect_frame_valid_edge 
(
.insignal(in_framevalid), 
.outsignal(got_frame_valid_edge), 
.clk(clk)
);

always_ff @(posedge clk)
begin
     if (reset)
	 	 state <= idle;
	 else
	 	 case(state)
		 idle :begin
		            if (got_frame_valid_edge) state <= start_frame_valid_delay;
			   end
		 start_frame_valid_delay : begin
									   if (frame_delay_counter >= (FRAME_DELAY_COUNTER_VAL -1))
											state <= start_frame_delay_pulse;
										else
										   state <= start_frame_valid_delay;
										
								  end

		 start_frame_delay_pulse:  begin
		                                if (frame_width_counter >= (FRAME_WIDTH_COUNTER_VAL-1))
											state <= idle;
										else
										   state <= start_frame_delay_pulse;
									end

		
		 endcase
end
always_ff @(posedge clk)
begin
     if (reset_counters)
	 begin
          frame_delay_counter <= 0;
          frame_width_counter <= 0;
	 end else
	 begin
	      if (enable_delay_counter)
		  begin
		        frame_delay_counter <= frame_delay_counter +1;
		  end
		  
          if (enable_width_counter)
		  begin
		        frame_width_counter <= frame_width_counter +1;
		  end
     end
end

endmodule
`default_nettype wire


