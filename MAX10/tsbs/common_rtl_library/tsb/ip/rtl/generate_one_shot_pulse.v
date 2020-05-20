module generate_one_shot_pulse #(parameter num_clks_to_wait = 10)  (input clk, output oneshot_pulse);

reg[num_clks_to_wait-1:0] start_shiftreg = 1'b1;

always @(posedge clk)
begin
	  start_shiftreg <= start_shiftreg << 1;
end

assign oneshot_pulse = start_shiftreg[num_clks_to_wait-1];

endmodule