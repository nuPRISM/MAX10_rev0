module saturating_counter 
#(
parameter num_counter_bits = 4,
parameter [num_counter_bits-1:0] saturation_limit={1'b0,{(num_counter_bits-1){1'b1}}}
)
(
input clk,
input monitored_signal,
output reg [num_counter_bits-1:0] saturated_sum = 0,
input count_enable,
input clear_counter
);

always @(posedge clk)
begin
     if (clear_counter)
	 begin
	      saturated_sum <= 0;
     end else
     begin	 
	      if (count_enable)
		  begin
		      if (saturated_sum < saturation_limit)
			  begin
		           saturated_sum <= saturated_sum + monitored_signal;		  
			  end else
			  begin
			      saturated_sum <= saturated_sum;
			  end
		  end else 
		  begin
		       saturated_sum <= saturated_sum;
		  end
     end
end


endmodule
