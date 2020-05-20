module generate_controlled_length_delayed_pulse
#(
parameter num_bits_counter = 32,
parameter synchronizer_depth = 3
)
(
input wire async_reset,
output reg pulse_out = 0,
input [num_bits_counter-1:0] wait_clks_before_start,
input [num_bits_counter-1:0] pulse_width,
input wire clk
);

wire actual_reset;

reg [num_bits_counter:0] counter = -1; //extra bit so that initial value can't be parameter

async_trap_and_reset_gen_1_pulse_robust
#(.synchronizer_depth(synchronizer_depth)) 
generate_reset_pulse(
.async_sig(async_reset), 
.outclk(clk), 
.out_sync_sig(actual_reset), 
.auto_reset(1'b1), 
.unregistered_out_sync_sig(),
.reset(1'b1)
);	
				
				
always_ff @(posedge clk)
begin
     if (actual_reset)
	 begin
	      counter <= 0;
	 end else 
	 begin
	       if (counter >= (wait_clks_before_start+pulse_width))
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
      pulse_out <= ((counter >= wait_clks_before_start) && (counter < (wait_clks_before_start+pulse_width))); 
end

endmodule