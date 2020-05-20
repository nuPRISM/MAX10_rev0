`default_nettype none
module cosrom_w_explicit_block_ram (
	input c, // clock
	input [9:0] a0, a1, // angle
	output reg [34:0] d0, d1);
  
	// Declare the RAM variable
	
	wire [34:0] q_a, q_b;
	
	altera_cosrom_generic_megafunction	
	altera_cosrom_generic_megafunction_inst (
	.address_a ( a0 ),
	.address_b ( a1 ),
	.clock ( c ),
	.q_a ( d0 ),
	.q_b ( d1 )
	);

endmodule
`default_nettype wire