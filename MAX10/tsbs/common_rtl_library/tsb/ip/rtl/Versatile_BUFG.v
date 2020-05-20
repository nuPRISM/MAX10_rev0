module Versatile_BUFG(input I, output O);
  `ifdef SOFTWARE_IS_QUARTUS
		                Altera_BUFG altera_BUFG_inst(.I(I), .O(O));
		`else
						BUFG xilinx_BUFG(.I(I), .O(O));
		`endif
endmodule
