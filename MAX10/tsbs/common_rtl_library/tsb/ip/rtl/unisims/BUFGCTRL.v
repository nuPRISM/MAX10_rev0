// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/virtex4/BUFGCTRL.v,v 1.7.40.1 2007/03/09 18:13:21 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Global Clock Mux Buffer
// /___/   /\     Filename : BUFGCTRL.v
// \   \  /  \    Timestamp : Thu Mar 11 16:43:43 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    03/11/05 - Initialized outpus.
// End Revision

`timescale 1 ps/1 ps

module BUFGCTRL (O, CE0, CE1, I0, I1, IGNORE0, IGNORE1, S0, S1);

    output O;
    input CE0;
    input CE1;
    tri0 GSR = 0;
    input I0;
    input I1;
    input IGNORE0;
    input IGNORE1;
    input S0;
    input S1;

    parameter integer INIT_OUT = 0;
    parameter PRESELECT_I0 = "FALSE";
    parameter PRESELECT_I1 = "FALSE";

    reg o_out = 0;
    reg q0, q1;
    reg q0_enable, q1_enable;
    reg preselect_i0, preselect_i1;
    reg task_input_ce0, task_input_ce1, task_input_i0;
    reg task_input_i1, task_input_ignore0, task_input_ignore1;
    reg task_input_gsr, task_input_s0, task_input_s1;

    wire i0_int, i1_int;

    buf O0 (O, o_out);
    buf B0 (ce0_in, CE0);
    buf B1 (ce1_in, CE1);
    buf B2 (i0_in, I0);
    buf B3 (i1_in, I1);
    buf B4 (ignore0_in, IGNORE0);
    buf B5 (ignore1_in, IGNORE1);
    buf B6 (gsr_in, GSR);
    buf B7 (s0_in, S0);
    buf B8 (s1_in, S1);


// *** parameter checking

	initial begin
	    case (PRESELECT_I0)
                  "TRUE"   : preselect_i0 = 1'b1;
                  "FALSE"  : preselect_i0 = 1'b0;
                  default : begin
                                $display("Attribute Syntax Error : The attribute PRESELECT_I0 on BUFGCTRL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", PRESELECT_I0);
                                $finish;
                            end
	    endcase
	end

	initial begin
	    case (PRESELECT_I1)
                  "TRUE"   : preselect_i1 = 1'b1;
                  "FALSE"  : preselect_i1 = 1'b0;
                  default : begin
                                $display("Attribute Syntax Error : The attribute PRESELECT_I1 on BUFGCTRL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", PRESELECT_I1);
                                $finish;
                            end
	    endcase
	end


// *** both preselects can not be 1 simultaneously.
	initial begin
	    if (preselect_i0 && preselect_i1) begin
                $display("Attribute Syntax Error : The attributes PRESELECT_I0 and PRESELECT_I1 on BUFGCTRL instance %m should not be set to TRUE simultaneously.");
                $finish;
	    end
	end

	initial begin
	    if ((INIT_OUT != 0) && (INIT_OUT != 1)) begin
	        $display("Attribute Syntax Error : The attribute INIT_OUT on BUFGCTRL instance %m is set to %d.  Legal values for this attribute are 0 or 1.", INIT_OUT);
	        $finish;
	    end
	end


// *** Start here
	assign i0_int = INIT_OUT ? ~i0_in : i0_in;
	assign i1_int = INIT_OUT ? ~i1_in : i1_in;

// *** Input enable for i1
	always @(ignore1_in or i1_int or s1_in or gsr_in or q0) begin
	    if (gsr_in == 1)
                q1_enable <= preselect_i1;

	    else if (gsr_in == 0) begin
                if ((i1_int == 0) && (ignore1_in == 0))
                    q1_enable <= q1_enable;
	        else if ((i1_int == 1) || (ignore1_in == 1))
                    q1_enable <= (~q0 && s1_in);
	    end
	end

// *** Output q1 for i1
	always @(q1_enable or ce1_in or i1_int or ignore1_in or gsr_in) begin
	    if (gsr_in == 1)
                q1 <= preselect_i1;

	    else if (gsr_in == 0) begin
	        if ((i1_int == 1)&& (ignore1_in == 0))
                    q1 <= q1;
	        else if ((i1_int == 0) || (ignore1_in == 1))
                    q1 <= (ce1_in && q1_enable);
	    end
	end

// *** input enable for i0
	always @(ignore0_in or i0_int or s0_in or gsr_in or q1) begin
	    if (gsr_in == 1)
                q0_enable <= preselect_i0;

	    else if (gsr_in == 0) begin
	        if ((i0_int == 0) && (ignore0_in == 0))
                    q0_enable <= q0_enable;
	        else if ((i0_int == 1) || (ignore0_in == 1))
                    q0_enable <= (~q1 && s0_in);
	    end
	end

// *** Output q0 for i0
	always @(q0_enable or ce0_in or i0_int or ignore0_in or gsr_in) begin
	    if (gsr_in == 1)
                q0 <= preselect_i0;

	    else if (gsr_in == 0) begin 
	        if ((i0_int == 1) && (ignore0_in == 0))
                    q0 <= q0;
	        else if ((i0_int == 0) || (ignore0_in == 1))
                    q0 <= (ce0_in && q0_enable);
	    end
	end


	always @(q0 or q1 or i0_int or i1_int) begin 
	    case ({q1, q0})
                2'b01: o_out = i0_in;
                2'b10: o_out = i1_in; 
                2'b00: o_out = INIT_OUT;
	        2'b11: begin
		           q0 = 1'bx;
		           q1 = 1'bx;
		           q0_enable = 1'bx;
		           q1_enable = 1'bx;
		           o_out = 1'bx;
		       end
            endcase
	end

endmodule
