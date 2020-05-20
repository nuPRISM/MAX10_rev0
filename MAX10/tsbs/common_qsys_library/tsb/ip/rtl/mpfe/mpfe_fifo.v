

`timescale 1ns / 1ns

module mpfe_fifo #(
	parameter
		FIFO_WIDTH = 32,
		FIFO_DEPTH = 64,
		FIFO_DEPTH_BITS = 6
	)
	(
		clock,
		data,
		rdreq,
		wrreq,
		almost_empty,
		empty,
		full,
		q
	);

	input	  clock;
	input	[FIFO_WIDTH-1:0]  data;
	input	  rdreq;
	input	  wrreq;
	output	  almost_empty;
	output	  empty;
	output	  full;
	output	[FIFO_WIDTH-1:0]  q;

	wire  sub_wire0;
	wire  sub_wire1;
	wire [FIFO_WIDTH-1:0] sub_wire2;
	wire  sub_wire3;
	wire  empty = sub_wire0;
	wire  almost_empty = sub_wire1;
	wire [FIFO_WIDTH-1:0] q = sub_wire2[FIFO_WIDTH-1:0];
	wire  full = sub_wire3;

	scfifo	scfifo_component (
				.rdreq (rdreq),
				.clock (clock),
				.wrreq (wrreq),
				.data (data),
				.empty (sub_wire0),
				.almost_empty (sub_wire1),
				.q (sub_wire2),
				.full (sub_wire3)
				// synopsys translate_off
				,
				.aclr (),
				.almost_full (),
				.sclr (),
				.usedw ()
				// synopsys translate_on
				);
	defparam
		scfifo_component.add_ram_output_register = "OFF",
		scfifo_component.almost_empty_value = 2,
		scfifo_component.intended_device_family = "Stratix IV",
		scfifo_component.lpm_numwords = FIFO_DEPTH,
		scfifo_component.lpm_showahead = "OFF",
		scfifo_component.lpm_type = "scfifo",
		scfifo_component.lpm_width = FIFO_WIDTH,
		scfifo_component.lpm_widthu = FIFO_DEPTH_BITS,
		scfifo_component.overflow_checking = "ON",
		scfifo_component.underflow_checking = "ON",
		scfifo_component.use_eab = "ON";


endmodule


