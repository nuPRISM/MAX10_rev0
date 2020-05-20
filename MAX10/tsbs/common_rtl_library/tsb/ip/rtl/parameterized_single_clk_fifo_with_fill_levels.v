
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module parameterized_single_clk_fifo_with_fill_levels
#(
 parameter device_family = "Stratix IV",
 parameter num_locations  = 256,
 parameter num_data_bits = 128,
 parameter almost_empty_value = 2,
 parameter almost_full_value = num_locations-2,
 parameter num_usedw_bits = $clog2(num_locations)
)

(
	aclr,
	clock,
	data,
	rdreq,
	wrreq,
	almost_empty,
	almost_full,
	empty,
	full,
	q,
	usedw	
);

	
	input	  aclr;
	input	  clock;
	input	[num_data_bits-1:0]  data;
	input	  rdreq;
	input	  wrreq;
	output	  almost_empty;
	output	  almost_full;
	output	  empty;
	output	  full;
	output	[num_data_bits-1:0]  q;
	output	[num_usedw_bits-1:0]  usedw;

	wire  sub_wire0;
	wire  sub_wire1;
	wire  sub_wire2;
	wire  sub_wire3;
	wire [num_data_bits-1:0] sub_wire4;
	wire [num_usedw_bits-1:0] sub_wire5;
	wire  almost_empty = sub_wire0;
	wire  almost_full = sub_wire1;
	wire  empty = sub_wire2;
	wire  full = sub_wire3;
	wire [num_data_bits-1:0] q = sub_wire4[num_data_bits-1:0];
	wire [num_usedw_bits-1:0] usedw = sub_wire5[num_usedw_bits-1:0];

	scfifo	scfifo_component (
				.aclr (aclr),
				.clock (clock),
				.data (data),
				.rdreq (rdreq),
				.wrreq (wrreq),
				.almost_empty (sub_wire0),
				.almost_full (sub_wire1),
				.empty (sub_wire2),
				.full (sub_wire3),
				.q (sub_wire4),
				.usedw (sub_wire5),
				.sclr ());
	defparam
		scfifo_component.add_ram_output_register = "ON",
		scfifo_component.almost_empty_value = almost_empty_value,
		scfifo_component.almost_full_value = almost_full_value,
		scfifo_component.intended_device_family = device_family,
		scfifo_component.lpm_numwords = num_locations,
		scfifo_component.lpm_showahead = "ON",
		scfifo_component.lpm_type = "scfifo",
		scfifo_component.lpm_width = num_data_bits,
		scfifo_component.lpm_widthu = num_usedw_bits,
		scfifo_component.overflow_checking = "ON",
		scfifo_component.underflow_checking = "ON",
		scfifo_component.use_eab = "ON";

endmodule
