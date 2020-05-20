module edge_detect(
input in_signal, 
output reg edge_detect = 0, 
input clk);

reg prev_sig = 0;

always_ff @(posedge clk)
begin
      prev_sig <= in_signal;
	  edge_detect <= !prev_sig & in_signal;
end

endmodule
