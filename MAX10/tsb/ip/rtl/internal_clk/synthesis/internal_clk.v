// internal_clk.v

// Generated using ACDS version 18.1 625

`timescale 1 ps / 1 ps
module internal_clk (
		output wire  clkout, // clkout.clk
		input  wire  oscena  // oscena.oscena
	);

	altera_int_osc #(
		.DEVICE_FAMILY   ("MAX 10"),
		.DEVICE_ID       ("25"),
		.CLOCK_FREQUENCY ("55")
	) int_osc_0 (
		.oscena (oscena), // oscena.oscena
		.clkout (clkout)  // clkout.clk
	);

endmodule
