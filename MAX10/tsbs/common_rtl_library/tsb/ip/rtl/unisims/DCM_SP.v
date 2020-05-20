// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/DCM_SP.v,v 1.9.4.3 2007/04/11 20:30:19 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 9.2i (J.36)
//  \   \         Description : Xilinx Function Simulation Library Component
//  /   /                  Digital Clock Manager
// /___/   /\     Filename : DCM_SP.v
// \   \  /  \    Timestamp : 
//  \___\/\___\
//
// Revision:
//    02/28/06 - Initial version.
//    05/09/06 - Add clkin_ps_mkup and clkin_ps_mkup_win for phase shifting (CR 229789).
//    06/14/06 - Add clkin_ps_mkup_flag for multiple cycle delays (CR233283).
//    07/21/06 - Change range of variable phase shifting to +/- integer of 20*(Period-3ns).
//               Give warning not support initial phase shifting for variable phase shifting.
//               (CR 235216).
//    09/22/06 - Add lock_period and lock_fb to clkfb_div block (CR 418722).
//    12/19/06 - Add clkfb_div_en for clkfb2x divider (CR431210).
//    04/06/07 - Enable the clock out in clock low time after reset in model 
//               clock_divide_by_2  (CR 437471).
// End Revision


`timescale  1 ps / 1 ps

module DCM_SP (
	CLK0, CLK180, CLK270, CLK2X, CLK2X180, CLK90,
	CLKDV, CLKFX, CLKFX180, LOCKED, PSDONE, STATUS,
	CLKFB, CLKIN, DSSEN, PSCLK, PSEN, PSINCDEC, RST);

parameter real CLKDV_DIVIDE = 2.0;
parameter integer CLKFX_DIVIDE = 1;
parameter integer CLKFX_MULTIPLY = 4;
parameter CLKIN_DIVIDE_BY_2 = "FALSE";
parameter real CLKIN_PERIOD = 10.0;			// non-simulatable
parameter CLKOUT_PHASE_SHIFT = "NONE";
parameter CLK_FEEDBACK = "1X";
parameter DESKEW_ADJUST = "SYSTEM_SYNCHRONOUS";	// non-simulatable
parameter DFS_FREQUENCY_MODE = "LOW";
parameter DLL_FREQUENCY_MODE = "LOW";
parameter DSS_MODE = "NONE";			// non-simulatable
parameter DUTY_CYCLE_CORRECTION = "TRUE";
parameter FACTORY_JF = 16'hC080;		// non-simulatable
localparam integer MAXPERCLKIN = 1000000;		// non-modifiable simulation parameter
localparam integer MAXPERPSCLK = 100000000;		// non-modifiable simulation parameter
parameter integer PHASE_SHIFT = 0;
localparam integer SIM_CLKIN_CYCLE_JITTER = 300;		// non-modifiable simulation parameter
localparam integer SIM_CLKIN_PERIOD_JITTER = 1000;	// non-modifiable simulation parameter
parameter STARTUP_WAIT = "FALSE";		// non-simulatable


localparam PS_STEP = 25;

input CLKFB, CLKIN, DSSEN;
input PSCLK, PSEN, PSINCDEC, RST;

output CLK0, CLK180, CLK270, CLK2X, CLK2X180, CLK90;
output CLKDV, CLKFX, CLKFX180, LOCKED, PSDONE;
output [7:0] STATUS;

reg CLK0, CLK180, CLK270, CLK2X, CLK2X180, CLK90;
reg CLKDV, CLKFX, CLKFX180;

wire locked_out_out;
wire clkfb_in, clkin_in, dssen_in;
wire psclk_in, psen_in, psincdec_in, rst_in;
reg clk0_out;
reg clk2x_out, clkdv_out;
reg clkfx_out, clkfx180_en;
reg rst_flag;
reg locked_out, psdone_out, ps_overflow_out, ps_lock;
reg clkfb_div, clkfb_chk, clkfb_div_en;
integer clkdv_cnt;

reg [1:0] clkfb_type;
reg [8:0] divide_type;
reg clkin_type;
reg [1:0] ps_type;
reg [3:0] deskew_adjust_mode;
reg dfs_mode_type;
reg dll_mode_type;
reg clk1x_type;
integer ps_in;

reg lock_period, lock_delay, lock_clkin, lock_clkfb;
reg first_time_locked;
reg en_status;
reg ps_overflow_out_ext;
reg clkin_lost_out_ext;
reg clkfx_lost_out_ext;
reg [1:0] lock_out;
reg lock_out1_neg;
reg lock_fb, lock_ps, lock_ps_dly, lock_fb_dly, lock_fb_dly_tmp;
reg fb_delay_found;
reg clock_stopped;
reg clkin_chkin, clkfb_chkin;

wire chk_enable, chk_rst;
wire clkin_div;
wire lock_period_pulse;
wire lock_period_dly, lock_period_dly1;

reg clkin_ps, clkin_ps_tmp, clkin_ps_mkup, clkin_ps_mkup_win, clkin_ps_mkup_flag;
reg clkin_fb;

time FINE_SHIFT_RANGE;
//time ps_delay, ps_delay_init, ps_delay_md, ps_delay_all, ps_max_range;
integer ps_delay, ps_delay_init, ps_delay_md, ps_delay_all, ps_max_range;
integer ps_delay_last;
integer ps_acc;
time clkin_edge;
time clkin_div_edge;
time clkin_ps_edge;
time delay_edge;
time clkin_period [2:0];
time period;
integer period_int, period_int2, period_int3, period_ps_tmp;
time period_div;
integer period_orig_int;
time period_orig;
time period_ps;
time clkout_delay;
time fb_delay;
time period_fx, remain_fx;
time period_dv_high, period_dv_low;
time cycle_jitter, period_jitter;

reg clkin_window, clkfb_window;
reg [2:0] rst_reg;
reg [12:0] numerator, denominator, gcd;
reg [23:0] i, n, d, p;

reg notifier;

endmodule

//////////////////////////////////////////////////////

module dcm_sp_clock_divide_by_2 (clock, clock_type, clock_out, rst);
input clock;
input clock_type;
input rst;
output clock_out;

reg clock_out;
reg clock_div2;
reg [2:0] rst_reg;
wire clk_src;

initial begin
    clock_out = 1'b0;
    clock_div2 = 1'b0;
end

always @(posedge clock) 
    clock_div2 <= ~clock_div2;

always @(posedge clock) begin
    rst_reg[0] <= rst;
    rst_reg[1] <= rst_reg[0] & rst;
    rst_reg[2] <= rst_reg[1] & rst_reg[0] & rst;
end

assign clk_src = (clock_type) ? clock_div2 : clock;

always @(clk_src or rst or rst_reg) 
    if (rst == 1'b0)
        clock_out = clk_src;
    else if (rst == 1'b1) begin
        clock_out = 1'b0;
        @(negedge rst_reg[2]);
        if (clk_src == 1'b1)
          @(negedge clk_src);
    end


endmodule

module dcm_sp_maximum_period_check (clock, rst);
parameter clock_name = "";
parameter maximum_period = 0;
input clock;
input rst;

time clock_edge;
time clock_period;

initial begin
    clock_edge = 0;
    clock_period = 0;
end

always @(posedge clock) begin
    clock_edge <= $time;
//    clock_period <= $time - clock_edge;
    clock_period = $time - clock_edge;
    if (clock_period > maximum_period ) begin
        if (rst == 0) 
	$display(" Warning : Input clock period of %1.3f ns, on the %s port of instance %m exceeds allowed value of %1.3f ns at time %1.3f ns.", clock_period/1000.0, clock_name, maximum_period/1000.0, $time/1000.0);
    end
end
endmodule

module dcm_sp_clock_lost (clock, enable, lost, rst);
input clock;
input enable;
input rst;
output lost;

time clock_edge;
reg [63:0] period;
reg clock_low, clock_high;
reg clock_posedge, clock_negedge;
reg lost_r, lost_f, lost;
reg clock_second_pos, clock_second_neg;

initial begin
    clock_edge = 0;
    clock_high = 0;
    clock_low = 0;
    lost_r = 0;
    lost_f = 0;
    period = 0;
    clock_posedge = 0;
    clock_negedge = 0;
    clock_second_pos = 0;
    clock_second_neg = 0;
end

always @(posedge clock or posedge rst)
  if (rst==1) 
    period <= 0;
  else begin
    clock_edge <= $time;
    if (period != 0 && (($time - clock_edge) <= (1.5 * period)))
        period <= $time - clock_edge;
    else if (period != 0 && (($time - clock_edge) > (1.5 * period)))
        period <= 0;
    else if ((period == 0) && (clock_edge != 0) && clock_second_pos == 1)
        period <= $time - clock_edge;
  end


always @(posedge clock or posedge rst)
  if (rst) 
    lost_r <= 0;
  else 
  if (enable == 1 && clock_second_pos == 1) begin
      #1;
      if ( period != 0)
         lost_r <= 0;
      #((period * 9.1) / 10)
      if ((clock_low != 1'b1) && (clock_posedge != 1'b1) && rst == 0)
        lost_r <= 1;
    end

always @(posedge clock or negedge clock or posedge rst)
  if (rst) begin
     clock_second_pos <= 0;
     clock_second_neg <= 0;
  end
  else if (clock)
     clock_second_pos <= 1;
  else if (~clock)
     clock_second_neg <= 1;

always @(negedge clock or posedge rst)
  if (rst==1) begin
     lost_f <= 0;
   end
   else begin
     if (enable == 1 && clock_second_neg == 1) begin
      if ( period != 0)
        lost_f <= 0;
      #((period * 9.1) / 10)
      if ((clock_high != 1'b1) && (clock_negedge != 1'b1) && rst == 0)
        lost_f <= 1;
    end
  end

always @( lost_r or  lost_f or enable)
begin
  if (enable == 1)
         lost = lost_r | lost_f;
  else
        lost = 0;
end


always @(posedge clock or negedge clock or posedge rst)
  if (rst==1) begin
           clock_low   <= 1'b0;
           clock_high  <= 1'b0;
           clock_posedge  <= 1'b0;
           clock_negedge <= 1'b0;
  end
  else begin
    if (clock ==1) begin
           clock_low   <= 1'b0;
           clock_high  <= 1'b1;
           clock_posedge  <= 1'b0;
           clock_negedge <= 1'b1;
    end
    else if (clock == 0) begin
           clock_low   <= 1'b1;
           clock_high  <= 1'b0;
           clock_posedge  <= 1'b1;
           clock_negedge <= 1'b0;
    end
end


endmodule
