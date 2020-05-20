module measure_time_between_triggers
#(
parameter COUNTER_WIDTH = 32,
parameter DEFAULT_TIME_BETWEEN_TRIGGERS = 0
)
(
input trigger,
output logic [COUNTER_WIDTH-1:0] time_between_triggers,
input clk,
input reset,
//debugging outputs
output logic edge_detected_in_trigger,
output logic [COUNTER_WIDTH-1:0] running_time_between_triggers
);

	 edge_detector
     edge_detect_trigger	 (
			 .insignal(trigger), 
			 .outsignal(edge_detected_in_trigger), 
			 .clk(clk)
	 );

	always_ff @(posedge clk)
	begin
	     if (reset)
		 begin
		      time_between_triggers         <= DEFAULT_TIME_BETWEEN_TRIGGERS;
		      running_time_between_triggers <= 0;				  
		 end else
		 begin
				 if (edge_detected_in_trigger)
				 begin													 
						 time_between_triggers         <= running_time_between_triggers;
						 running_time_between_triggers <= 0;
				 end else
				 begin
						 time_between_triggers         <= time_between_triggers        ;	
						 running_time_between_triggers <= running_time_between_triggers  + 1;															 
				 end
		 end
	end
endmodule
