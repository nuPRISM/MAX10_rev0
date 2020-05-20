module edge_detect_and_hold(
input in_signal, 
input reset, 
output reg edge_received = 0, 
input clk);

logic prev_sig, edge_detect_sig;

always_ff @(posedge clk)
begin
      prev_sig <= in_signal;
end

assign edge_detect_sig = !prev_sig & in_signal;

always_ff @(posedge clk)
begin 
        if (reset)
		begin
		      edge_received <= 0;
		end else
		begin
				if (edge_detect_sig)
				begin
						edge_received <= 1;
				end
		end
end

endmodule
