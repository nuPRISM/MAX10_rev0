module generate_controlled_length_pulse_ver2
#(
parameter default_count = 100,
parameter num_bits_counter = 16,
parameter pulse_out_initial_value = 1,
parameter synchronizer_depth = 3
)
(
input async_reset,
output reg pulse_out = pulse_out_initial_value,
input clk
);

wire actual_reset;

reg [num_bits_counter-1:0] counter = default_count;

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
	      counter <= default_count;
	 end else 
	 begin
	       if (counter > 0)
	       begin
	             counter <= counter - 1;	
	       end else
		   begin
		          counter <= 0;
		   end
     end
end

always_ff @(posedge clk)
begin
      pulse_out <= (counter != 0); 
end

endmodule