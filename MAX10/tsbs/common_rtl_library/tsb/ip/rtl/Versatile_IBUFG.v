module Versatile_IBUFG(input I, output O);
  `ifdef SOFTWARE_IS_QUARTUS
		                Altera_BUFG altera_IBUFG_inst(.I(I), .O(O));
		`else
						IBUFG xilinx_IBUFG(.I(I), .O(O));
		`endif
endmodule
