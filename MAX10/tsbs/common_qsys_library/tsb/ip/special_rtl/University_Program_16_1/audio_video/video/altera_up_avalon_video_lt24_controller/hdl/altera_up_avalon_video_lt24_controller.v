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


module altera_up_avalon_video_lt24_controller (
	// Inputs
	clk,
	reset,
	data_in_valid,
	startofpacket,
	endofpacket,
	data_in,
	
	// Outputs
	lt24_lcd_on,
	lt24_reset_n,
	ready,
	data_to_lcd,
	data_not_cmd,
	wrx,
	rdx,
	csx
);

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input					clk;
input					reset;
input					data_in_valid;
input					startofpacket;
input					endofpacket;
input		[15:0]	data_in;

// Outputs
output				lt24_lcd_on;
output				lt24_reset_n;
output				ready;
output				data_not_cmd;
output				wrx;
output				rdx;
output				csx;
output	[15:0]	data_to_lcd;

/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/

// States
localparam	IDLE 	=					22'b0000000000000000000001,
				RESET_OUT_WAIT = 		22'b0000000000000000000010,
				COLMOD_CMD =			22'b0000000000000000000100,
				COLMOD_PARAM =			22'b0000000000000000001000,
				MADCTL_CMD =			22'b0000000000000000010000,
				MADCTL_PARAM =			22'b0000000000000000100000,
				CASET_CMD =				22'b0000000000000001000000,
				CASET_PARAM_1 =		22'b0000000000000010000000,
				CASET_PARAM_2 =		22'b0000000000000100000000,
				CASET_PARAM_3 =		22'b0000000000001000000000,
				CASET_PARAM_4 =		22'b0000000000010000000000,
				PASET_CMD =				22'b0000000000100000000000,
				PASET_PARAM_1 =		22'b0000000001000000000000,
				PASET_PARAM_2 =		22'b0000000010000000000000,
				PASET_PARAM_3 =		22'b0000000100000000000000,
				PASET_PARAM_4 =		22'b0000001000000000000000,
				SLEEP_OUT_CMD =		22'b0000010000000000000000,
				SLEEP_OUT_WAIT =		22'b0000100000000000000000,
				DISP_ON_CMD =			22'b0001000000000000000000,
				MEM_WRITE_CMD =		22'b0010000000000000000000,
				MEM_WRITE_WAIT =		22'b0100000000000000000000,
				MEM_WRITE_PARAM =		22'b1000000000000000000000;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire 				wait_sig;

// Internal registers
reg				state_counter;
reg	[15:0]	data_in_reg;
reg	[16:0]	wait_counter;

// State Machine Registers
reg	[21:0] ns_mode;
reg	[21:0] s_mode;

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/

always @(posedge clk) // sync reset
begin
	if (reset == 1'b1)
		s_mode <= IDLE;
	else
		s_mode <= ns_mode;
end

always @(*)
begin
	case (s_mode)
		IDLE:
		begin
			ns_mode <= RESET_OUT_WAIT;
		end
		RESET_OUT_WAIT:
		begin
			if (wait_counter == 75000) // Must wait 5msec between reset and commands. 5msec * 15MHz = 75,000 clock cycles
				ns_mode <= COLMOD_CMD;
			else
				ns_mode <= RESET_OUT_WAIT;
		end
		COLMOD_CMD:
		begin
			if (state_counter)
				ns_mode <= COLMOD_PARAM;
			else
				ns_mode <= COLMOD_CMD;
		end
		COLMOD_PARAM:
		begin
			if (state_counter)
				ns_mode <= MADCTL_CMD;
			else
				ns_mode <= COLMOD_PARAM;
		end
		MADCTL_CMD:
		begin
			if (state_counter)
				ns_mode <= MADCTL_PARAM;
			else
				ns_mode <= MADCTL_CMD;
		end
		MADCTL_PARAM:
		begin
			if (state_counter)
				ns_mode <= CASET_CMD;
			else
				ns_mode <= MADCTL_PARAM;
		end
		CASET_CMD:
		begin
			if (state_counter)
				ns_mode <= CASET_PARAM_1;
			else
				ns_mode <= CASET_CMD;
		end
		CASET_PARAM_1:
		begin
			if (state_counter)
				ns_mode <= CASET_PARAM_2;
			else
				ns_mode <= CASET_PARAM_1;
		end
		CASET_PARAM_2:
		begin
			if (state_counter)
				ns_mode <= CASET_PARAM_3;
			else
				ns_mode <= CASET_PARAM_2;
		end
		CASET_PARAM_3:
		begin
			if (state_counter)
				ns_mode <= CASET_PARAM_4;
			else
				ns_mode <= CASET_PARAM_3;
		end
		CASET_PARAM_4:
		begin
			if (state_counter)
				ns_mode <= PASET_CMD;
			else
				ns_mode <= CASET_PARAM_4;
		end
		PASET_CMD:
		begin
			if (state_counter)
				ns_mode <= PASET_PARAM_1;
			else
				ns_mode <= PASET_CMD;
		end
		PASET_PARAM_1:
		begin
			if (state_counter)
				ns_mode <= PASET_PARAM_2;
			else
				ns_mode <= PASET_PARAM_1;
		end
		PASET_PARAM_2:
		begin
			if (state_counter)
				ns_mode <= PASET_PARAM_3;
			else
				ns_mode <= PASET_PARAM_2;
		end
		PASET_PARAM_3:
		begin
			if (state_counter)
				ns_mode <= PASET_PARAM_4;
			else
				ns_mode <= PASET_PARAM_3;
		end
		PASET_PARAM_4:
		begin
			if (state_counter)
				ns_mode <= SLEEP_OUT_CMD;
			else
				ns_mode <= PASET_PARAM_4;
		end
		SLEEP_OUT_CMD:
		begin
			if (state_counter)
				ns_mode <= SLEEP_OUT_WAIT;
			else
				ns_mode <= SLEEP_OUT_CMD;
		end
		SLEEP_OUT_WAIT:
		begin
			if (wait_counter == 75000) // Must wait 5msec between Sleep Out and next command. 15MHz * 5msec = 75,000 clock cycles
				ns_mode <= DISP_ON_CMD;
			else
				ns_mode <= SLEEP_OUT_WAIT;
		end
		DISP_ON_CMD:
		begin
			if (state_counter)
				ns_mode <= MEM_WRITE_CMD;
			else
				ns_mode <= DISP_ON_CMD;
		end
		MEM_WRITE_CMD:
		begin
			if (state_counter)
				ns_mode <= MEM_WRITE_WAIT;
			else
				ns_mode <= MEM_WRITE_CMD;
		end
		MEM_WRITE_WAIT:
		begin
			if (data_in_valid)
				ns_mode = MEM_WRITE_PARAM;
			else
				ns_mode = MEM_WRITE_WAIT;
		end
		MEM_WRITE_PARAM:
		begin
			if (endofpacket)
				ns_mode <= MEM_WRITE_CMD;
			else
				ns_mode <= MEM_WRITE_WAIT;
		end
		default:
		begin
			ns_mode <= IDLE;
		end
	endcase
end

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

// Output Registers

// Internal Registers
always @(posedge clk)
begin
	if (s_mode == IDLE || s_mode == RESET_OUT_WAIT || s_mode == SLEEP_OUT_WAIT)
		state_counter <= 1'b0;
	else
		state_counter <= state_counter + 1'b1;
end

always @(posedge clk)
begin
	if (s_mode == IDLE || s_mode == MEM_WRITE_CMD)
		wait_counter <= 17'b0;
	else if (s_mode == RESET_OUT_WAIT || s_mode == SLEEP_OUT_WAIT)
		wait_counter <= wait_counter + 1'b1;
end

always @(posedge clk)
begin
	if (s_mode == MEM_WRITE_WAIT)
		data_in_reg <= data_in;
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
// Output Assignments
assign lt24_lcd_on = 1'b1;
assign lt24_reset_n = ~reset;
assign wait_sig = (ns_mode == RESET_OUT_WAIT || ns_mode == SLEEP_OUT_WAIT || ns_mode == MEM_WRITE_WAIT) ? 1'b1 : 1'b0;
assign data_not_cmd = (s_mode == COLMOD_CMD || s_mode == MADCTL_CMD ||
								s_mode == CASET_CMD || s_mode == PASET_CMD ||
								s_mode == SLEEP_OUT_CMD || s_mode == DISP_ON_CMD ||
								s_mode == MEM_WRITE_CMD) ? 1'b0 : 1'b1;

assign data_to_lcd = (s_mode == COLMOD_CMD)			? 16'b0000000000111010 :
							(s_mode == COLMOD_PARAM)		? 16'b0000000000000101 :
							(s_mode == MADCTL_CMD)			? 16'b0000000000110110 :
							(s_mode == MADCTL_PARAM)		? 16'b0000000011101000 :
							(s_mode == CASET_CMD)			? 16'b0000000000101010 :
							(s_mode == CASET_PARAM_1)		? 16'b0000000000000000 :
							(s_mode == CASET_PARAM_2)		? 16'b0000000000000000 :
							(s_mode == CASET_PARAM_3)		? 16'b0000000000000001 :
							(s_mode == CASET_PARAM_4)		? 16'b0000000000111111 :
							(s_mode == PASET_CMD)			? 16'b0000000000101011 :
							(s_mode == PASET_PARAM_1)		? 16'b0000000000000000 :
							(s_mode == PASET_PARAM_2)		? 16'b0000000000000000 :
							(s_mode == PASET_PARAM_3)		? 16'b0000000000000000 :
							(s_mode == PASET_PARAM_4)		? 16'b0000000011101111 :
							(s_mode == SLEEP_OUT_CMD)		? 16'b0000000000010001 :
							(s_mode == DISP_ON_CMD)			? 16'b0000000000101001 :
							(s_mode == MEM_WRITE_CMD)		? 16'b0000000000101100 :
							(s_mode == MEM_WRITE_PARAM)	? data_in_reg			  :
																	  16'bzzzzzzzzzzzzzzzz;

assign ready = (s_mode == MEM_WRITE_WAIT) ? 1'b1 : 1'b0;

assign rdx = 1'b1;
assign csx = 1'b0;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

altera_up_avalon_video_lt24_write_sequencer Write_Timing (clk, reset, wait_sig, wrx);

endmodule
