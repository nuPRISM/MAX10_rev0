module event_request_handler
(
input clk,
output reg event_request = 0,
input reset_event_request,
input request_event_now
);


always @(posedge clk)
begin
	  if (reset_event_request)
		begin
			 event_request <= 0;
		end else
		begin
			  if (request_event_now)
				begin
					 event_request <= 1;
				end
			 
		end
end

endmodule