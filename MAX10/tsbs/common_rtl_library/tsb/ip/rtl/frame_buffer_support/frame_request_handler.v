module frame_request_handler
(
input clk,
output reg frame_request = 0,
input reset_frame_request,
input request_frame_now
);


always @(posedge clk)
begin
	  if (reset_frame_request)
		begin
			 frame_request <= 0;
		end else
		begin
			  if (request_frame_now)
				begin
					 frame_request <= 1;
				end
			 
		end
end

endmodule