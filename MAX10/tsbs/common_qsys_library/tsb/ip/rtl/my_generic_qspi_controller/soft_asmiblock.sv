// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


//---------------------------------------------------------------------
//
// Module Name : asmiblock
// Description : Standard/QUAD IO mode
//
//---------------------------------------------------------------------

`timescale 1 ps/1 ps
module  soft_asmiblock #(
	parameter IO_MODE = "STANDARD",
	parameter CS_WIDTH = 1
)(
	dclk,
	sce,
	dataout,
	dataoe,
	datain,
	dclk_out,
	ncs
);

input 					dclk;
input  [CS_WIDTH-1:0]	sce;
input  [3:0]			dataout;
input  [3:0]			dataoe;
inout  [3:0]			datain;
output 					dclk_out;
output [CS_WIDTH-1:0]	ncs;

wire oe;
wire data[3:0];
wire data_buf[3:0];

assign oe = 1'b0;

assign dclk_out = (oe === 1'b0) ? dclk : (oe === 1'b1) ? 1'bz : 1'bx;
assign ncs = (oe === 1'b0) ? sce : (oe === 1'b1) ? 1'bz : 1'bx;

assign data[0] = (oe === 1'b0) ? data_buf[0] : (oe === 1'b1) ? 1'bz : 1'bx;
assign data_buf[0] = (dataoe[0] === 1'b1) ? dataout[0] : (dataoe[0] === 1'b0) ? 1'bz : 1'bx;
assign datain[0] = data[0];

assign data[1] = (oe === 1'b0) ? data_buf[1] : (oe === 1'b1) ? 1'bz : 1'bx;
assign data_buf[1] = (dataoe[1] === 1'b1) ? dataout[1] : (dataoe[1] === 1'b0) ? 1'bz : 1'bx;
assign datain[1] = data[1];

generate 
	if (IO_MODE == "STANDARD") begin
		assign data[2] = (oe === 1'b0) ? data_buf[2] : (oe === 1'b1) ? 1'bz : 1'bx;
		assign data_buf[2] = (dataoe[2] === 1'b1) ? 1'b1 : (dataoe[2] === 1'b0) ? 1'bz : 1'bx;
		assign datain[2] = data[2];
		
		assign data[3] = (oe === 1'b0) ? data_buf[3] : (oe === 1'b1) ? 1'bz : 1'bx;
		assign data_buf[3] = (dataoe[3] === 1'b1) ? 1'b1 : (dataoe[3] === 1'b0) ? 1'bz : 1'bx;
		assign datain[3] = data[3];
	end
	else begin
		assign data[2] = (oe === 1'b0) ? data_buf[2] : (oe === 1'b1) ? 1'bz : 1'bx;
		assign data_buf[2] = (dataoe[2] === 1'b1) ? dataout[2] : (dataoe[2] === 1'b0) ? 1'bz : 1'bx;
		assign datain[2] = data[2];
		
		assign data[3] = (oe === 1'b0) ? data_buf[3] : (oe === 1'b1) ? 1'bz : 1'bx;
		assign data_buf[3] = (dataoe[3] === 1'b1) ? dataout[3] : (dataoe[3] === 1'b0) ? 1'bz : 1'bx;
		assign datain[3] = data[3];
	end
endgenerate

endmodule	//	asmiblock
