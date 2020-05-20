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
 * This module scales video streams on the DE boards.                         *
 *                                                                            *
 ******************************************************************************/

module altera_up_avalon_video_scaler (
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


	stream_out_channel,
	stream_out_data,
	stream_out_startofpacket,
	stream_out_endofpacket,
	stream_out_empty,
	stream_out_valid
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

parameter CW					=   0; // Frame's Channel Width
parameter DW					=  15; // Frame's Data Width
parameter EW					=   0; // Frame's Empty Width

parameter WIW					=   9; // Incoming frame's width's address width
parameter HIW					=   9; // Incoming frame's height's address width
parameter WIDTH_IN			= 640;

parameter WIDTH_DROP_MASK	= 4'b0101;
parameter HEIGHT_DROP_MASK	= 4'b0000;

parameter MH_WW				=   9; // Multiply height's incoming width's address width
parameter MH_WIDTH_IN		= 640; // Multiply height's incoming width
parameter MH_CW				=   0; // Multiply height's counter width

parameter MW_CW				=   0; // Multiply width's counter width

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input						clk;
input						reset;

input			[DW: 0]	stream_in_data;
input						stream_in_startofpacket;
input						stream_in_endofpacket;
input			[EW: 0]	stream_in_empty;
input						stream_in_valid;

input						stream_out_ready;

// Bidirectional

// Outputs
output					stream_in_ready;

output		[CW: 0]	stream_out_channel;
output		[DW: 0]	stream_out_data;
output					stream_out_startofpacket;
output					stream_out_endofpacket;
output		[EW: 0]	stream_out_empty;
output					stream_out_valid;

/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire			[CW: 0]	internal_channel;
wire			[DW: 0]	internal_data;
wire						internal_startofpacket;
wire						internal_endofpacket;
wire						internal_valid;

wire						internal_ready;

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

// Internal Registers

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

// Output Assignments
`ifdef USE_HEIGHT_ENLARGE
`elsif USE_WIDTH_ENLARGE
`else
assign stream_out_channel	= 'h0;
`endif
assign stream_out_empty		= 'h0;

// Internal Assignments

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

`ifdef USE_IMAGE_SHRINK
altera_up_video_scaler_shrink Shrink_Frame (
	// Inputs
	.clk								(clk),
	.reset							(reset),

	.stream_in_data				(stream_in_data),
	.stream_in_startofpacket	(stream_in_startofpacket),
	.stream_in_endofpacket		(stream_in_endofpacket),
	.stream_in_valid				(stream_in_valid),

`ifdef USE_HEIGHT_ENLARGE
	.stream_out_ready				(internal_ready),
`elsif USE_WIDTH_ENLARGE
	.stream_out_ready				(internal_ready),
`else
	.stream_out_ready				(stream_out_ready),
`endif
	
	// Bidirectional

	// Outputs
	.stream_in_ready				(stream_in_ready),

`ifdef USE_HEIGHT_ENLARGE
	.stream_out_data				(internal_data),
	.stream_out_startofpacket	(internal_startofpacket),
	.stream_out_endofpacket		(internal_endofpacket),
	.stream_out_valid				(internal_valid)
`elsif USE_WIDTH_ENLARGE
	.stream_out_data				(internal_data),
	.stream_out_startofpacket	(internal_startofpacket),
	.stream_out_endofpacket		(internal_endofpacket),
	.stream_out_valid				(internal_valid)
`else
	.stream_out_data				(stream_out_data),
	.stream_out_startofpacket	(stream_out_startofpacket),
	.stream_out_endofpacket		(stream_out_endofpacket),
	.stream_out_valid				(stream_out_valid)
`endif
);
defparam
	Shrink_Frame.DW					= DW,
	Shrink_Frame.WW					= WIW,
	Shrink_Frame.HW					= HIW,

	Shrink_Frame.WIDTH_IN			= WIDTH_IN,

	Shrink_Frame.WIDTH_DROP_MASK	= WIDTH_DROP_MASK,
	Shrink_Frame.HEIGHT_DROP_MASK	= HEIGHT_DROP_MASK;
`endif

`ifdef USE_HEIGHT_ENLARGE
altera_up_video_scaler_multiply_height Multiply_Height (
	// Inputs
	.clk								(clk),
	.reset							(reset),

`ifdef USE_IMAGE_SHRINK
	.stream_in_data				(internal_data),
	.stream_in_startofpacket	(internal_startofpacket),
	.stream_in_endofpacket		(internal_endofpacket),
	.stream_in_valid				(internal_valid),
`else
	.stream_in_data				(stream_in_data),
	.stream_in_startofpacket	(stream_in_startofpacket),
	.stream_in_endofpacket		(stream_in_endofpacket),
	.stream_in_valid				(stream_in_valid),
`endif

`ifdef USE_WIDTH_ENLARGE
	.stream_out_ready				(internal_ready),
`else
	.stream_out_ready				(stream_out_ready),
`endif

	// Bi-Directional

	// Outputs
`ifdef USE_IMAGE_SHRINK
	.stream_in_ready				(internal_ready),
`else
	.stream_in_ready				(stream_in_ready),
`endif

`ifdef USE_WIDTH_ENLARGE
	.stream_out_channel			(internal_channel),
	.stream_out_data				(internal_data),
	.stream_out_startofpacket	(internal_startofpacket),
	.stream_out_endofpacket		(internal_endofpacket),
	.stream_out_valid				(internal_valid)
`else
	.stream_out_channel			(stream_out_channel),
	.stream_out_data				(stream_out_data),
	.stream_out_startofpacket	(stream_out_startofpacket),
	.stream_out_endofpacket		(stream_out_endofpacket),
	.stream_out_valid				(stream_out_valid)
`endif
);
defparam
	Multiply_Height.DW		= DW,
	Multiply_Height.WW		= MH_WW,
	Multiply_Height.WIDTH	= MH_WIDTH_IN,

	Multiply_Height.MCW		= MH_CW;
`endif

`ifdef USE_WIDTH_ENLARGE
altera_up_video_scaler_multiply_width Multiply_Width (
	// Inputs
	.clk								(clk),
	.reset							(reset),

`ifdef USE_IMAGE_SHRINK
	.stream_in_channel			(0),
	.stream_in_data				(internal_data),
	.stream_in_startofpacket	(internal_startofpacket),
	.stream_in_endofpacket		(internal_endofpacket),
	.stream_in_valid				(internal_valid),
`elsif USE_HEIGHT_ENLARGE
	.stream_in_channel			(internal_channel),
	.stream_in_data				(internal_data),
	.stream_in_startofpacket	(internal_startofpacket),
	.stream_in_endofpacket		(internal_endofpacket),
	.stream_in_valid				(internal_valid),
`else
	.stream_in_channel			(0),
	.stream_in_data				(stream_in_data),
	.stream_in_startofpacket	(stream_in_startofpacket),
	.stream_in_endofpacket		(stream_in_endofpacket),
	.stream_in_valid				(stream_in_valid),
`endif

	.stream_out_ready				(stream_out_ready),

	// Bi-Directional

	// Outputs
`ifdef USE_IMAGE_SHRINK
	.stream_in_ready				(internal_ready),
`elsif USE_HEIGHT_ENLARGE
	.stream_in_ready				(internal_ready),
`else
	.stream_in_ready				(stream_in_ready),
`endif

	.stream_out_channel			(stream_out_channel),
	.stream_out_data				(stream_out_data),
	.stream_out_startofpacket	(stream_out_startofpacket),
	.stream_out_endofpacket		(stream_out_endofpacket),
	.stream_out_valid				(stream_out_valid)
);
defparam
	Multiply_Width.CW		= CW,
	Multiply_Width.DW		= DW,
	Multiply_Width.MCW	= MW_CW;
`endif

endmodule

