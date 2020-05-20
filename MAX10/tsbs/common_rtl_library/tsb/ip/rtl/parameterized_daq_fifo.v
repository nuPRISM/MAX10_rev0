

// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
//`include "math_func_package.v"
import math_func_package::*;

module parameterized_daq_fifo
#(
 parameter device_family = "Arria V",
 parameter num_output_locations  = 16384,
 parameter input_to_output_ratio = 8,
 parameter num_output_bits = 16,
 parameter num_input_bits = input_to_output_ratio*num_output_bits,
 parameter num_input_locations = (num_output_locations/input_to_output_ratio),
 //parameter num_wrusedw_bits = $clog2(num_input_locations),
 //parameter num_rdusedw_bits = $clog2(num_output_locations)
 parameter num_wrusedw_bits = math_func_package::my_clog2(num_input_locations),
 parameter num_rdusedw_bits = math_func_package::my_clog2(num_output_locations),
 parameter use_better_metastability_performance = 1
)

(
	data,
	rdclk,
	rdreq,
	wrclk,
	wrreq,
	q,
	rdempty,
	rdfull,
	wrempty,
	wrfull,
	wrusedw,
	rdusedw,
	aclr);

	input	[num_input_bits-1:0]  data;
	input	  rdclk;
	input	  rdreq;
	input	  wrclk;
	input	  wrreq;
	input     aclr;
	output	[num_output_bits-1:0]  q;
	output	  rdempty;
	output	  rdfull;
	output	  wrempty;
	output	  wrfull;
	output	[num_wrusedw_bits-1:0]  wrusedw;
	output	[num_rdusedw_bits-1:0]  rdusedw;

	wire [num_output_bits-1:0] sub_wire0;
	wire  sub_wire1;
	wire  sub_wire2;
	wire  sub_wire3;
	wire  sub_wire4;
	wire [num_wrusedw_bits-1:0] sub_wire5;
	wire [num_output_bits-1:0] q = sub_wire0[num_output_bits-1:0];
	wire  rdempty = sub_wire1;
	wire  rdfull = sub_wire2;
	wire  wrempty = sub_wire3;
	wire  wrfull = sub_wire4;
	wire [num_wrusedw_bits-1:0] wrusedw = sub_wire5[num_wrusedw_bits-1:0];
	wire	[num_rdusedw_bits-1:0]  rdusedw;

	dcfifo_mixed_widths	dcfifo_mixed_widths_component (
				.data (data),
				.rdclk (rdclk),
				.rdreq (rdreq),
				.wrclk (wrclk),
				.wrreq (wrreq),
				.q (sub_wire0),
				.rdempty (sub_wire1),
				.rdfull (sub_wire2),
				.wrempty (sub_wire3),
				.wrfull (sub_wire4),
				.wrusedw (sub_wire5),
				.aclr (aclr),
				.rdusedw (rdusedw));
	defparam
		dcfifo_mixed_widths_component.intended_device_family = device_family,
		dcfifo_mixed_widths_component.lpm_numwords = num_input_locations,
		dcfifo_mixed_widths_component.lpm_showahead = "OFF",
		dcfifo_mixed_widths_component.lpm_type = "dcfifo_mixed_widths",
		dcfifo_mixed_widths_component.lpm_width = num_input_bits,
		dcfifo_mixed_widths_component.lpm_widthu = num_wrusedw_bits,
		dcfifo_mixed_widths_component.lpm_widthu_r = num_rdusedw_bits,
		dcfifo_mixed_widths_component.lpm_width_r = num_output_bits,
		dcfifo_mixed_widths_component.overflow_checking = "ON",
		dcfifo_mixed_widths_component.rdsync_delaypipe = use_better_metastability_performance ? 5 : 4,
		dcfifo_mixed_widths_component.underflow_checking = "ON",
		dcfifo_mixed_widths_component.use_eab = "ON",
		dcfifo_mixed_widths_component.wrsync_delaypipe = use_better_metastability_performance ? 5 : 4;


endmodule

