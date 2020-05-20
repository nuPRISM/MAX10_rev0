 module non_sync_edge_detector (input insignal, output reg outsignal, input clk);
	reg shift_reg=0;

	always @ (posedge clk)
	begin
          shift_reg <= insignal;		  
	end

	always @*
	begin
	       outsignal  =  insignal & !shift_reg;
	end
endmodule

				