module record_events
#(
parameter numchannels=4
) 
(
input [numchannels-1:0] monitored_signals,
input clk,
input clear,
output reg [numchannels-1:0] event_recorded
);

genvar i;
generate
         for (i = 0; i < numchannels; i = i + 1)
		 begin : individual_event_record
               always @(posedge clk)
			   begin
			         if (clear)
					 begin
					       event_recorded[i] <= 0;
					 
					 end else
					 begin
					      if (monitored_signals[i])
						  begin
					            event_recorded[i] <= 1;
						  end					 
					 end			   
			   end				 
		 end
endgenerate


endmodule
