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


// THIS FILE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THIS FILE OR THE USE OR OTHER DEALINGS
// IN THIS FILE.

/******************************************************************************
 *                                                                            *
 * This module converts video streams between RGB color formats.              *
 *                                                                            *
 ******************************************************************************/

module altera_up_avalon_video_rgb_resampler (
	// Inputs
	clk,
	reset,

	stream_in_data,
	stream_in_startofpacket,
	stream_in_endofpacket,
	stream_in_empty,
	stream_in_valid,

	stream_out_ready,
	
	// Bidirectional

	// Outputs
	stream_in_ready,


	stream_out_data,
	stream_out_startofpacket,
	stream_out_endofpacket,
	stream_out_empty,
	stream_out_valid
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

parameter IDW		= 23;
parameter ODW		= 23;

parameter IEW		= 0;
parameter OEW		= 0;

parameter ALPHA	= 10'h3FF;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input						clk;
input						reset;

input			[IDW:0]	stream_in_data;
input						stream_in_startofpacket;
input						stream_in_endofpacket;
input			[IEW:0]	stream_in_empty;
input						stream_in_valid;

input						stream_out_ready;

// Bidirectional

// Outputs
output					stream_in_ready;

output reg	[ODW:0]	stream_out_data;
output reg				stream_out_startofpacket;
output reg				stream_out_endofpacket;
output reg	[OEW:0]	stream_out_empty;
output reg				stream_out_valid;

/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[ 9: 0]	r;
wire		[ 9: 0]	g;
wire		[ 9: 0]	b;
wire		[ 9: 0]	a;

`ifdef USE_GRAY_OUT
wire		[11: 0]	average_color;	
`endif

wire		[ODW:0]	converted_data;

// Internal Registers

// State Machine Registers

// Integers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

// Output Registers
always @(posedge clk)
begin
	if (reset)
	begin
		stream_out_data				<=  'b0;
		stream_out_startofpacket	<= 1'b0;
		stream_out_endofpacket		<= 1'b0;
		stream_out_empty				<=  'b0;
		stream_out_valid				<= 1'b0;
	end
	else if (stream_out_ready | ~stream_out_valid)
	begin
		stream_out_data				<= converted_data;
		stream_out_startofpacket	<= stream_in_startofpacket;
		stream_out_endofpacket		<= stream_in_endofpacket;
		stream_out_empty				<= stream_in_empty;
		stream_out_valid				<= stream_in_valid;
	end
end

// Internal Registers

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

// Output Assignments
assign stream_in_ready = stream_out_ready | ~stream_out_valid;

// Internal Assignments
`ifdef USE_BW_IN
assign r = {10{stream_in_data[0]}};
assign g = {10{stream_in_data[0]}};
assign b = {10{stream_in_data[0]}};
`elsif USE_GRAY_IN
assign r = {stream_in_data[ 7: 0], stream_in_data[ 7: 6]};
assign g = {stream_in_data[ 7: 0], stream_in_data[ 7: 6]};
assign b = {stream_in_data[ 7: 0], stream_in_data[ 7: 6]};
`elsif USE_8_BITS_IN
assign r = {{3{stream_in_data[ 7: 5]}}, stream_in_data[ 7]};
assign g = {{3{stream_in_data[ 4: 2]}}, stream_in_data[ 4]};
assign b = {5{stream_in_data[ 1: 0]}};
`elsif USE_9_BITS_IN
assign r = {{3{stream_in_data[ 8: 6]}}, stream_in_data[ 8]};
assign g = {{3{stream_in_data[ 5: 3]}}, stream_in_data[ 5]};
assign b = {{3{stream_in_data[ 2: 0]}}, stream_in_data[ 2]};
`elsif USE_16_BITS_IN
assign r = {stream_in_data[15:11], stream_in_data[15:11]};
assign g = {stream_in_data[10: 5], stream_in_data[10: 7]};
assign b = {stream_in_data[ 4: 0], stream_in_data[ 4: 0]};
`elsif USE_24_BITS_IN
assign r = {stream_in_data[23:16], stream_in_data[23:22]};
assign g = {stream_in_data[15: 8], stream_in_data[15:14]};
assign b = {stream_in_data[ 7: 0], stream_in_data[ 7: 6]};
`elsif USE_30_BITS_IN
assign r = stream_in_data[29:20];
assign g = stream_in_data[19:10];
assign b = stream_in_data[ 9: 0];
`elsif USE_A_12_BITS_IN
assign r = {{3{stream_in_data[ 8: 6]}}, stream_in_data[ 8]};
assign g = {{3{stream_in_data[ 5: 3]}}, stream_in_data[ 5]};
assign b = {{3{stream_in_data[ 2: 0]}}, stream_in_data[ 2]};
`elsif USE_A_16_BITS_IN
assign r = {{2{stream_in_data[11: 8]}}, stream_in_data[11:10]};
assign g = {{2{stream_in_data[ 7: 4]}}, stream_in_data[ 7: 6]};
assign b = {{2{stream_in_data[ 3: 0]}}, stream_in_data[ 3: 2]};
`elsif USE_A_32_BITS_IN
assign r = {stream_in_data[23:16], stream_in_data[23:22]};
assign g = {stream_in_data[15: 8], stream_in_data[15:14]};
assign b = {stream_in_data[ 7: 0], stream_in_data[ 7: 6]};
`elsif USE_A_40_BITS_IN
assign r = stream_in_data[29:20];
assign g = stream_in_data[19:10];
assign b = stream_in_data[ 9: 0];
`endif

`ifdef USE_A_12_BITS_IN
assign a = {{3{stream_in_data[11:9]}}, stream_in_data[11]};
`elsif USE_A_16_BITS_IN
assign a = {{2{stream_in_data[15:12]}}, stream_in_data[15:14]};
`elsif USE_A_32_BITS_IN
assign a = {stream_in_data[31:24], stream_in_data[31:30]};
`elsif USE_A_40_BITS_IN
assign a = stream_in_data[39:30];
`elsif USE_A_12_BITS_OUT
assign a = {ALPHA, 7'h0};
`elsif USE_A_16_BITS_OUT
assign a = {ALPHA, 6'h0};
`elsif USE_A_32_BITS_OUT
assign a = {ALPHA, 2'h0};
`elsif USE_A_40_BITS_OUT
assign a = ALPHA;
`else
assign a = ALPHA;
`endif

`ifdef USE_BW_OUT
assign converted_data[0] = (r[9] & g[9]) | (r[9] & b[9]) | (g[9] & b[9]);
`elsif USE_GRAY_OUT
assign average_color = {2'h0, r} + {1'b0, g, 1'b0} + {2'h0, b};

assign converted_data[ 7: 0] = average_color[11:4];
`elsif USE_8_BITS_OUT
assign converted_data[ 7: 5] = r[ 9: 7];
assign converted_data[ 4: 2] = g[ 9: 7];
assign converted_data[ 1: 0] = b[ 9: 8];
`elsif USE_9_BITS_OUT
assign converted_data[ 8: 6] = r[ 9: 7];
assign converted_data[ 5: 3] = g[ 9: 7];
assign converted_data[ 2: 0] = b[ 9: 7];
`elsif USE_16_BITS_OUT
assign converted_data[15:11] = r[ 9: 5];
assign converted_data[10: 5] = g[ 9: 4];
assign converted_data[ 4: 0] = b[ 9: 5];
`elsif USE_24_BITS_OUT
assign converted_data[23:16] = r[ 9: 2];
assign converted_data[15: 8] = g[ 9: 2];
assign converted_data[ 7: 0] = b[ 9: 2];
`elsif USE_30_BITS_OUT
assign converted_data[29:20] = r[ 9: 0];
assign converted_data[19:10] = g[ 9: 0];
assign converted_data[ 9: 0] = b[ 9: 0];
`elsif USE_A_12_BITS_OUT
assign converted_data[11: 9] = a[ 9: 7];
assign converted_data[ 8: 6] = r[ 9: 7];
assign converted_data[ 5: 3] = g[ 9: 7];
assign converted_data[ 2: 0] = b[ 9: 7];
`elsif USE_A_16_BITS_OUT
assign converted_data[15:12] = a[ 9: 6];
assign converted_data[11: 8] = r[ 9: 6];
assign converted_data[ 7: 4] = g[ 9: 6];
assign converted_data[ 3: 0] = b[ 9: 6];
`elsif USE_A_32_BITS_OUT
assign converted_data[31:24] = a[ 9: 2];
assign converted_data[23:16] = r[ 9: 2];
assign converted_data[15: 8] = g[ 9: 2];
assign converted_data[ 7: 0] = b[ 9: 2];
`elsif USE_A_40_BITS_OUT
assign converted_data[39:30] = a[ 9: 0];
assign converted_data[29:20] = r[ 9: 0];
assign converted_data[19:10] = g[ 9: 0];
assign converted_data[ 9: 0] = b[ 9: 0];
`endif

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


endmodule

