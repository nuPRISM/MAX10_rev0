
module hw_watchdog_timer
#(
parameter numbits = 32
)
(
input     wire clk,
input     wire  async_reset,
input     wire enable,
input     wire  reset_watchdog,
output reg watchdog_reset_pulse,
input wire [numbits-1:0] watchdog_limit,
input wire [numbits-1:0] num_reset_cycles,

//debug outputs
output reg [numbits-1:0] current_count = 0

);


always @(posedge clk or posedge async_reset)
begin
     if (async_reset)
	 begin
	      current_count <= 0;
		  watchdog_reset_pulse <= 0;
	 end else
	 begin
	      if (reset_watchdog || (watchdog_limit == 0))
		  begin
		         current_count <= 0;
				 watchdog_reset_pulse <= 0;
		  end else
		  begin
		        if (enable)
				begin
				     if (current_count >= watchdog_limit)
					 begin
					       if (current_count < (num_reset_cycles+watchdog_limit))
						   begin
						        //output reset pulse
					            current_count <= current_count + 1;
								watchdog_reset_pulse <= 1;
						   end else
						   begin
						        //start again
						        current_count <= 0;
								watchdog_reset_pulse <= 0;
						   end							
					 end else
					 begin
					       //everything is normal, increase count
					       current_count <= current_count + 1;
						   watchdog_reset_pulse <= 0;
					 end				    
				end else
				begin
				     //we are not enabled. Maintain count and do not assert reset.
				     current_count <= current_count;	
                     watchdog_reset_pulse <= 0;					 
				end		  
		  end	 
	 end
end

endmodule

