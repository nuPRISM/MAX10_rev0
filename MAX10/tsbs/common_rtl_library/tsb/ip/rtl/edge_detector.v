 module edge_detector (input insignal, output reg outsignal, input clk);
	reg [2:0] shift_reg=0;

	always @ (posedge clk)
	begin
          shift_reg <= {shift_reg[1:0], insignal};
		  outsignal <=  shift_reg[1] & !shift_reg[2];
	end

endmodule

				