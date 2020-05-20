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
 * This module connects the PS2 core to Avalon.                               *
 *                                                                            *
 ******************************************************************************/


module altera_up_avalon_st_ps2 (
	// Inputs
	clk,
	reset,

	command,
	command_valid,
	
	data_ready,
	
	// Bidirectionals
	PS2_CLK,					// PS2 Clock
 	PS2_DAT,					// PS2 Data

	// Outputs
	command_ready,
		
	data,
	data_valid
);


/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input						clk;
input						reset;

input			[ 7: 0]	command;
input						command_valid;

input						data_ready;

// Bidirectionals
inout						PS2_CLK;
inout					 	PS2_DAT;

// Outputs
output					command_ready;

output 		[ 7: 0]	data;
output					data_valid;

/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/

// Command path parameters
localparam	CLOCK_CYCLES_FOR_101US	= 5050;
localparam	DATA_WIDTH_FOR_101US		= 13;
localparam	CLOCK_CYCLES_FOR_15MS	= 750000;
localparam	DATA_WIDTH_FOR_15MS		= 20;
localparam	CLOCK_CYCLES_FOR_2MS		= 100000;
localparam	DATA_WIDTH_FOR_2MS		= 17;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire			[ 7: 0]	data_from_the_PS2_port;
wire						data_from_the_PS2_port_en;

wire						data_fifo_is_empty;
wire						data_fifo_is_full;

// Internal Registers

// State Machine Registers

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
assign data_valid				= ~data_fifo_is_empty;

// Internal Assignments

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

altera_up_ps2 PS2_Serial_Port (
	// Inputs
	.clk										(clk),
	.reset									(reset),

	.the_command							(command),
	.send_command							(command_valid),

	// Bidirectionals
	.PS2_CLK									(PS2_CLK),
 	.PS2_DAT									(PS2_DAT),

	// Outputs
	.command_was_sent						(command_ready),
	.error_communication_timed_out	(),

	.received_data							(data_from_the_PS2_port),
	.received_data_en						(data_from_the_PS2_port_en)
);
defparam
	PS2_Serial_Port.CLOCK_CYCLES_FOR_101US	= CLOCK_CYCLES_FOR_101US,
	PS2_Serial_Port.DATA_WIDTH_FOR_101US	= DATA_WIDTH_FOR_101US,
	PS2_Serial_Port.CLOCK_CYCLES_FOR_15MS	= CLOCK_CYCLES_FOR_15MS,
	PS2_Serial_Port.DATA_WIDTH_FOR_15MS		= DATA_WIDTH_FOR_15MS,
	PS2_Serial_Port.CLOCK_CYCLES_FOR_2MS	= CLOCK_CYCLES_FOR_2MS,
	PS2_Serial_Port.DATA_WIDTH_FOR_2MS		= DATA_WIDTH_FOR_2MS;

scfifo	Incoming_Data_FIFO (
	// Inputs
	.clock			(clk),
	.sclr				(reset),

	.rdreq			(data_ready & ~data_fifo_is_empty),
	.wrreq			(data_from_the_PS2_port_en & ~data_fifo_is_full),
	.data				(data_from_the_PS2_port),

	// Bidirectionals

	// Outputs
	.q					(data),

	.usedw			(),
	.empty			(data_fifo_is_empty),
	.full				(data_fifo_is_full),

	// synopsys translate_off
	
	.almost_empty	(),
	.almost_full	(),
	.aclr				()
	// synopsys translate_on
);
defparam
	Incoming_Data_FIFO.add_ram_output_register	= "ON",
	Incoming_Data_FIFO.intended_device_family		= "Cyclone II",
	Incoming_Data_FIFO.lpm_numwords					= 256,
	Incoming_Data_FIFO.lpm_showahead					= "ON",
	Incoming_Data_FIFO.lpm_type						= "scfifo",
	Incoming_Data_FIFO.lpm_width						= 8,
	Incoming_Data_FIFO.lpm_widthu						= 8,
	Incoming_Data_FIFO.overflow_checking			= "OFF",
	Incoming_Data_FIFO.underflow_checking			= "OFF",
	Incoming_Data_FIFO.use_eab							= "ON";

endmodule

