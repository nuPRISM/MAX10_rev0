`default_nettype none
module smart_check_edge_event_concordance
#(
parameter counter_bits = 32,
parameter synchronizer_depth = 3
)
(
input event_a,
input event_b,
input clk,
input  async_reset,
output reg [counter_bits-1:0] counter_a = 0,
output reg [counter_bits-1:0] counter_b = 0,
output reg [counter_bits-1:0] counter_a_clock_count = 0,
output reg [counter_bits-1:0] counter_b_clock_count = 0,
output reg signed [counter_bits-1:0] diff_counter = 0,
input [counter_bits-1:0] counter_a_increment,
input [counter_bits-1:0] counter_b_increment,
input signed [counter_bits-1:0] negative_discord_thresh,
input signed [counter_bits-1:0] positive_discord_thresh,
output reg  signed event_discord = 0,
output reg  signed immediate_event_discord = 0,
output reg  signed signed_over_thresh = 0,
output reg         over_thresh = 0,
output reg  signed  signed_under_thresh = 0,
output reg         under_thresh = 0,
output logic diff_counter_below_negative_thresh, 
output logic diff_counter_above_positive_thresh,
input async_clear_event_discord,
input enable,

//debug outputs
output logic sync_enable,
output logic sync_reset,
output logic sync_clear_event_discord

);


 async_trap_and_reset_gen_1_pulse_robust
 #(.synchronizer_depth(synchronizer_depth))
 make_reset_signal
 (
 .async_sig(async_reset), 
 .outclk(clk), 
 .out_sync_sig(sync_reset), 
 .auto_reset(1'b1), 
 .reset(1'b1)
 );


 async_trap_and_reset_gen_1_pulse_robust 
 #(.synchronizer_depth(synchronizer_depth))
 make_clear_event_signal
 (
 .async_sig(async_clear_event_discord), 
 .outclk(clk), 
 .out_sync_sig(sync_clear_event_discord), 
 .auto_reset(1'b1), 
 .reset(1'b1)
 );
 
doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_enable_signal
(
.indata(enable),
.outdata(sync_enable),
.clk(clk)
);
 
 signed_bigger_than
 #(.width(counter_bits))
 compare_diff_counter_to_negative_thresh
 (
  .A(negative_discord_thresh),
  .B(diff_counter),
  .result(diff_counter_below_negative_thresh)
 );
 
 signed_bigger_than
 #(.width(counter_bits))
 compare_diff_counter_to_positive_thresh
 (
  .A(diff_counter),
  .B(positive_discord_thresh),
  .result(diff_counter_above_positive_thresh)
 );
 
 
 

always @(posedge clk)
begin
     if (sync_reset || sync_clear_event_discord)
	 begin
	             event_discord <= 0;
                 immediate_event_discord <= 0;				 
	 end else
	 begin
	      if (sync_enable)
		  begin
		       if (event_discord == 0)
			   begin
		            if (diff_counter_above_positive_thresh || diff_counter_below_negative_thresh)
					begin
					       event_discord <= 1;
					end			
			   end
               immediate_event_discord	<= (diff_counter_above_positive_thresh || diff_counter_below_negative_thresh);
			   signed_over_thresh       <= diff_counter >  positive_discord_thresh;
			   over_thresh              <= diff_counter_above_positive_thresh;
			   signed_under_thresh      <= negative_discord_thresh >  diff_counter;
			   under_thresh             <= diff_counter_below_negative_thresh;
		  end 
	 end
end


 

always @(posedge clk)
begin
     if (sync_reset)
	 begin
	             counter_a <= 0;
				 counter_a_clock_count <= 0;
	             counter_b <= 0;
				 counter_b_clock_count <= 0;
	             diff_counter <= 0;
	 end else
	 begin
	      if (sync_enable)
		  begin
		        if (event_a)
				begin
		             counter_a <= counter_a+counter_a_increment;
					 counter_a_clock_count <= counter_a_clock_count + 1;
				end 
				
				if (event_b)
				begin
		             counter_b <= counter_b+counter_b_increment;
 					 counter_b_clock_count <= counter_b_clock_count + 1;
				end 
				
				case ({event_b,event_a})
				2'b00 : begin diff_counter <= diff_counter; end
				2'b01 : begin diff_counter <= diff_counter + counter_a_increment; end
				2'b10 : begin diff_counter <= diff_counter - counter_b_increment; end
				2'b11 : begin diff_counter <= diff_counter + counter_a_increment - counter_b_increment; end			
				endcase					  
		  end 
	 end
end

endmodule
`default_nettype wire