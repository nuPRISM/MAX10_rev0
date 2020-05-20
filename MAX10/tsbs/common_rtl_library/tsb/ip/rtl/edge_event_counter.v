`default_nettype none
module edge_event_counter
#(
parameter counter_bits = 32,
parameter numevents = 2
)
(
input event_signal[numevents],
output logic event_detected_now[numevents],
input clk,
input reset,
output logic [counter_bits-1:0] event_count[numevents]
);

genvar i;
generate
			for (i = 0; i < numevents; i++)
			begin : count_events
					edge_detector 
					event_edge_detector
					(
					 .insignal (event_signal[i]), 
					 .outsignal(event_detected_now[i]), 
					 .clk      (clk)
					);
					always @(posedge clk)
					begin
						  if (reset)
						  begin
								event_count[i] <= 0;
						  end else
						  begin
								if (event_detected_now[i])
								begin
									  event_count[i] <= event_count[i]+1;			
								end
						  end
					end
			end
endgenerate
endmodule
`default_nettype wire