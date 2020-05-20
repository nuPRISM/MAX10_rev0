module generate_controlled_length_pulse
#(
parameter default_count = 100,
parameter initial_count = default_count,
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

reg [num_bits_counter-1:0] counter = initial_count;

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_async_reset
(
.indata(async_reset),
.outdata(actual_reset),
.clk(clk)
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