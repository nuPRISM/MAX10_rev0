// megafunction wizard: %FIFO%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: scfifo 

// ============================================================
// File Name: avmm_transaction_fifo.v
// Megafunction Name(s):
// 			Parameterized scfifo
//
// Simulation Library Files(s):
// 			altera_mf
// ============================================================

// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module avmm_transaction_fifo #(
  parameter P_FIFOSIZELOGN = 2,
  parameter P_FIFOWIDTH = 53)(
	clock,
	data,
	rdreq,
	sclr,
	wrreq,
	empty,
	full,
	q,
	usedw);

	input	  clock;
	input	[P_FIFOWIDTH-1:0]  data;
	input	  rdreq;
	input	  sclr;
	input	  wrreq;
	output	  empty;
	output	  full;
	output	[P_FIFOWIDTH-1:0]  q;
	output	[P_FIFOSIZELOGN-1:0]  usedw;

	scfifo	scfifo_component (
				.clock (clock),
				.data (data),
				.rdreq (rdreq),
				.sclr (sclr),
				.wrreq (wrreq),
				.usedw (usedw),
				.empty (empty),
				.full (full),
				.q (q),
				.aclr (),
				.almost_empty (),
				.almost_full ());
	defparam
		scfifo_component.add_ram_output_register = "OFF",
		scfifo_component.intended_device_family = "Cyclone IV GX",
		scfifo_component.lpm_numwords = 2**P_FIFOSIZELOGN,
		scfifo_component.lpm_showahead = "ON",
		scfifo_component.lpm_type = "scfifo",
		scfifo_component.lpm_width = P_FIFOWIDTH,
		scfifo_component.lpm_widthu = P_FIFOSIZELOGN,
		scfifo_component.overflow_checking = "ON",
		scfifo_component.underflow_checking = "ON",
		scfifo_component.use_eab = "ON";


endmodule
