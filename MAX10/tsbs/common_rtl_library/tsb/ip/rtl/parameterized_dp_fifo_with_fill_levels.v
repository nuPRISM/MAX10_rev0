
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module parameterized_dp_fifo_with_fill_levels
#(
 parameter device_family = "Arria V",
 parameter num_locations  = 256,
 parameter num_data_bits = 128,
 parameter num_usedw_bits = $clog2(num_locations)
)
 (
	aclr,
	data,
	rdclk,
	rdreq,
	wrclk,
	wrreq,
	q,
	rdempty,
	rdfull,
	rdusedw,
	wrempty,
	wrfull,
	wrusedw);

	input	  aclr;
	input	[num_data_bits-1:0]  data;
	input	  rdclk;
	input	  rdreq;
	input	  wrclk;
	input	  wrreq;
	output	[num_data_bits-1:0]  q;
	output	  rdempty;
	output	  rdfull;
	output	[num_usedw_bits-1:0]  rdusedw;
	output	  wrempty;
	output	  wrfull;
	output	[num_usedw_bits-1:0]  wrusedw;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0	  aclr;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire [num_data_bits-1:0] sub_wire0;
	wire  sub_wire1;
	wire  sub_wire2;
	wire [num_usedw_bits-1:0] sub_wire3;
	wire  sub_wire4;
	wire  sub_wire5;
	wire [num_usedw_bits-1:0] sub_wire6;
	wire [num_data_bits-1:0] q = sub_wire0[num_data_bits-1:0];
	wire  rdempty = sub_wire1;
	wire  rdfull = sub_wire2;
	wire [num_usedw_bits-1:0] rdusedw = sub_wire3[num_usedw_bits-1:0];
	wire  wrempty = sub_wire4;
	wire  wrfull = sub_wire5;
	wire [num_usedw_bits-1:0] wrusedw = sub_wire6[num_usedw_bits-1:0];

	dcfifo	dcfifo_component (
				.aclr (aclr),
				.data (data),
				.rdclk (rdclk),
				.rdreq (rdreq),
				.wrclk (wrclk),
				.wrreq (wrreq),
				.q (sub_wire0),
				.rdempty (sub_wire1),
				.rdfull (sub_wire2),
				.rdusedw (sub_wire3),
				.wrempty (sub_wire4),
				.wrfull (sub_wire5),
				.wrusedw (sub_wire6));
	defparam
		dcfifo_component.intended_device_family = "Stratix IV",
		dcfifo_component.lpm_numwords = num_locations,
		dcfifo_component.lpm_showahead = "OFF",
		dcfifo_component.lpm_type = "dcfifo",
		dcfifo_component.lpm_width = num_data_bits,
		dcfifo_component.lpm_widthu = num_usedw_bits,
		dcfifo_component.overflow_checking = "ON",
		dcfifo_component.rdsync_delaypipe = 5,
		dcfifo_component.read_aclr_synch = "ON",
		dcfifo_component.underflow_checking = "ON",
		dcfifo_component.use_eab = "ON",
		dcfifo_component.write_aclr_synch = "ON",
		dcfifo_component.wrsync_delaypipe = 5;


endmodule
