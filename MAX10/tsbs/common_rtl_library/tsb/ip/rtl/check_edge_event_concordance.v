`default_nettype none
module check_edge_event_concordance
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
output reg  event_discord = 0,
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
 

 

always @(posedge clk)
begin
     if (sync_reset || sync_clear_event_discord)
	 begin
	             event_discord <= 0;	           
	 end else
	 begin
	      if (sync_enable)
		  begin
		       if (event_discord == 0)
			   begin
		            if ((diff_counter > positive_discord_thresh) || (negative_discord_thresh > diff_counter))
					begin
					       event_discord <= 1;
					end			
			   end		  
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
				
	            diff_counter <= counter_a - counter_b;
		  
		  end 
	 end
end

endmodule
`default_nettype wire