`default_nettype none
module generate_delayed_pulse_variable_count
#(
parameter initial_count = 0,
parameter num_bits_counter = 16,
parameter pulse_out_initial_value = 1,
parameter synchronizer_depth = 3
)
(
input async_reset,
output reg pulse_out = pulse_out_initial_value,
input logic [num_bits_counter-1:0] default_count,
input logic [num_bits_counter-1:0] initial_pulse_delay,
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
	      counter <= default_count+initial_pulse_delay;
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
      pulse_out <= ((counter <= default_count) && (counter != 0)); 
end

endmodule
`default_nettype wire
