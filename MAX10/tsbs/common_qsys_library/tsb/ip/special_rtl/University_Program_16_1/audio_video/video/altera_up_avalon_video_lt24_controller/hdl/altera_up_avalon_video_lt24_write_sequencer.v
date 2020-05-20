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


module altera_up_avalon_video_lt24_write_sequencer (clk, reset, wait_sig, wrx);
/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input clk;
input reset;
input wait_sig;

// Outputs
output wrx;

/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/
// States
localparam	WAIT	= 3'b0001,
				SETUP = 3'b0010,
				LATCH = 3'b0100;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// State Machine Registers
reg	[2:0] ns_mode;
reg	[2:0] s_mode;

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/
always @(posedge clk) // sync reset
begin
	if (reset == 1'b1)
		s_mode <= WAIT;
	else
		s_mode <= ns_mode;
end

always @(*)
begin
	case (s_mode)
		WAIT:
		begin
			if (wait_sig == 1'b1)
				ns_mode <= WAIT;
			else
				ns_mode <= SETUP;
		end
		SETUP:
		begin
			ns_mode <= LATCH;
		end
		LATCH:
		begin
			if (wait_sig == 1'b1)
				ns_mode <= WAIT;
			else
				ns_mode <= SETUP;
		end
		default:
		begin
			ns_mode <= WAIT;
		end
	endcase
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
// Output Assignments
assign wrx = (s_mode == SETUP) ? 1'b0 : 1'b1;

endmodule
