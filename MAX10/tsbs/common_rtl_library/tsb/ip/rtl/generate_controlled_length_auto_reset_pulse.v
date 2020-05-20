module generate_controlled_length_auto_reset_pulse
#(
parameter default_count = 10,
parameter wait_clks_before_start = 1,
parameter num_bits_counter = 16,
parameter synchronizer_depth = 3
)
(
input wire async_level_reset,
output reg pulse_out = 0,
input wire clk
);

wire actual_reset;

reg [num_bits_counter-1:0] counter = 0;

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_async_reset
(
.indata(async_level_reset),
.outdata(actual_reset),
.clk(clk)
);
				
				
always_ff @(posedge clk)
begin
     if (actual_reset)
	 begin
	      counter <= 0;
	 end else 
	 begin
	       if (counter >= (wait_clks_before_start+default_count))
	       begin
	             counter <= counter; //stay here until reset
	       end else
		   begin
		          counter <= counter+1;
		   end
     end
end

always_ff @(posedge clk)
begin
      pulse_out <= ((counter >= (wait_clks_before_start-1)) && (counter < (wait_clks_before_start+default_count))); 
end

endmodule