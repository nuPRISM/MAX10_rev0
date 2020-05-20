/******************************************************************************
 * License Agreement                                                          *
 *                                                                            *
 * Copyright (c) 1991-2013 Altera Corporation, San Jose, California, USA.     *
 * All rights reserved.                                                       *
 *                                                                            *
 * Any megafunction design, and related net list (encrypted or decrypted),    *
 *  support information, device programming or simulation file, and any other *
 *  associated documentation or information provided by Altera or a partner   *
 *  under Altera's Megafunction Partnership Program may be used only to       *
 *  program PLD devices (but not masked PLD devices) from Altera.  Any other  *
 *  use of such megafunction design, net list, support information, device    *
 *  programming or simulation file, or any other related documentation or     *
 *  information is prohibited for any other purpose, including, but not       *
 *  limited to modification, reverse engineering, de-compiling, or use with   *
 *  any other silicon devices, unless such use is explicitly licensed under   *
 *  a separate agreement with Altera or a megafunction partner.  Title to     *
 *  the intellectual property, including patents, copyrights, trademarks,     *
 *  trade secrets, or maskworks, embodied in any such megafunction design,    *
 *  net list, support information, device programming or simulation file, or  *
 *  any other related documentation or information provided by Altera or a    *
 *  megafunction partner, remains with Altera, the megafunction partner, or   *
 *  their respective licensors.  No other licenses, including any licenses    *
 *  needed under any third party's intellectual property, are provided herein.*
 *  Copying or modifying any file, or portion thereof, to which this notice   *
 *  is attached violates this copyright.                                      *
 *                                                                            *
 * THIS FILE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    *
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,   *
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    *
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER *
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING    *
 * FROM, OUT OF OR IN CONNECTION WITH THIS FILE OR THE USE OR OTHER DEALINGS  *
 * IN THIS FILE.                                                              *
 *                                                                            *
 * This agreement shall be governed in all respects by the laws of the State  *
 *  of California and by the laws of the United States of America.            *
 *                                                                            *
 ******************************************************************************/

//  - - - - - - - - - -ADC- - - - - - - - - - - - - - -
module adv_adc (clock, reset, go, sclk, cs_n, din, dout, done, reading0, reading1, 
						reading2, reading3, reading4, reading5, reading6, reading7);
input go, dout, clock, reset;

output reg done;
output reg sclk, din, cs_n;
output reg [11:0] reading0, reading1, reading2, reading3, reading4, reading5, reading6, reading7;

parameter T_SCLK = 8'd4;
parameter NUM_CH = 3'd7;
//FSM state values
parameter resetState = 3'd0, waitState=3'd1, transState=3'd2, doneState=3'd3, pauseState=3'd4, initCtrlRegState=3'd5;

reg [2:0] currState, nextState;
reg [14:0] dout_shift_reg;
reg [11:0] din_shift_reg;
reg [7:0] counter;
reg [7:0] pause_counter;
reg [3:0] sclk_counter;
reg [2:0] address, next_addr;
reg error;

always @(posedge clock)
	currState <=nextState;
	
// - - - - -NextState Selection Logic - - - - - - - -
	always @(*)
	begin
		din = din_shift_reg[11];
		if (reset)
			nextState=resetState;
		case (currState)
			resetState:begin
				cs_n=1;
				done=0;
				nextState=initCtrlRegState;
			end
			initCtrlRegState:begin
				cs_n=0;
				done=0;
				if (sclk_counter==4'd15&& counter==0 && !sclk)
					nextState=waitState;
				else
					nextState=initCtrlRegState;
			end
			waitState:begin
				cs_n=1;
				done=0;
				if (go)
					nextState=transState;
				else
					nextState=waitState;
			end
			transState:begin
				cs_n=0;
				done=0;
				if (sclk_counter==4'd15&& counter==0 && !sclk)
					nextState=pauseState;
				else
					nextState=transState;
			end
			// pause state must be >= 50ns! This is the "tquiet" required between conversions
			pauseState:begin
				cs_n=1;
				done=0;
				if (pause_counter > 8'd0)
					nextState=pauseState;
				else if(address==NUM_CH[2:0])
					nextState=doneState;
				else
					nextState=transState;
			end
			doneState:begin
				cs_n=1;
				done=1;
				if (go)
					nextState=doneState;
				else
					nextState=resetState;
			end
			default:begin
				cs_n=1;
				done=0;
				nextState = resetState;
			end
		endcase
	end
// - - - - - - - - - pause counter logic - - - - - - - - - - 
	always @(posedge clock)
	if (currState == pauseState)
		pause_counter <= pause_counter - 8'd1;
	else 
		pause_counter <= T_SCLK[7:1]+(T_SCLK[0]&&sclk)-8'd1;
// - - - - - - - - - counter logic - - - - - - - - - - 
	always @(posedge clock or posedge reset)
	if (reset)
		counter <= T_SCLK[7:1]+(T_SCLK[0]&&sclk)-8'd1;
	else if (cs_n)
		counter <= T_SCLK[7:1]+(T_SCLK[0]&&sclk)-8'd1;
	else if (counter == 0)
		counter <= T_SCLK[7:1]+(T_SCLK[0]&&sclk)-8'd1;
	else
		counter <= counter - 8'b1;
// - - - - - - - - ADC_SCLK generation - - - - - - - - - 
	always @(posedge clock or posedge reset)
	if (reset)
		sclk <= 1;
	else if (cs_n)
		sclk <= 1;
	else if (counter == 0)
		sclk <= ~sclk;
// - - - - - - - - - - - sclk_counter logic - - - - - - - -
	always @ (posedge clock)
		if (currState == doneState || currState == waitState || currState == resetState)
			sclk_counter <=4'b0;
		else if (counter == 0 && !sclk)
			sclk_counter <= sclk_counter + 4'b1;
// - - - - - - - - - - readings logic - - - - - - - - - -
	always @(posedge clock)
		if (sclk_counter == 4'd15 && counter == 0 && sclk)
			case (dout_shift_reg[13:11])
				3'd0: reading0 <= {dout_shift_reg[10:0],dout}; // should be {dout_shift_reg[10:0],dout}
				3'd1: reading1 <= {dout_shift_reg[10:0],dout};
				3'd2: reading2 <= {dout_shift_reg[10:0],dout};
				3'd3: reading3 <= {dout_shift_reg[10:0],dout};
				3'd4: reading4 <= {dout_shift_reg[10:0],dout};
				3'd5: reading5 <= {dout_shift_reg[10:0],dout};
				3'd6: reading6 <= {dout_shift_reg[10:0],dout};
				3'd7: reading7 <= {dout_shift_reg[10:0],dout};
			endcase
// - - - - - - - - - address logic - - - - - - - - -
	always @(posedge clock)
		if (currState == resetState)
			address <= 3'd0;
		else if (currState == pauseState && pause_counter == 8'd0)
			if (address >= NUM_CH[2:0])
				address <= 3'd0;
			else
				address <= next_addr;
// - - - - - - - - - - dout_shift_reg logic - - - - - - - - - - - - 
	always @(posedge clock)
		if (counter==0 && sclk && sclk_counter != 4'd15)
			dout_shift_reg [14:0] <= {dout_shift_reg [13:0], dout};
// - - - - - - - - - - din_shift_reg logic - - - - - - - - -
	always @(posedge clock)
		if (currState == resetState)
			din_shift_reg <= {3'b110,NUM_CH[2:0],6'b111001};     //13'hDF9; // Ctrl reg initialize to 0xdf90. MSB is a dummy value that doesnt actually get used
		else if ((currState == waitState && go) || (currState == pauseState && address != NUM_CH[2:0]))
			din_shift_reg <= {3'b010,NUM_CH[2:0],6'b111001};     //13'h5DF9  WRITE=0,SEQ=1,DONTCARE,ADDR2,ADDR1,ADDR0,DONTCARE*6
		else if (counter==0 && !sclk)
			din_shift_reg <={din_shift_reg[10:0],1'b0};
// - - - - - - - - - - next_addr logic - - - - - - - - - - - -
	always @(posedge clock)
		next_addr <= address + 3'b1;

endmodule 
