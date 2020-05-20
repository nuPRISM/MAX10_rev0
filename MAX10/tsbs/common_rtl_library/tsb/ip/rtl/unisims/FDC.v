// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/FDC.v,v 1.13.48.1 2007/03/09 18:13:02 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.27)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  D Flip-Flop with Asynchronous Clear
// /___/   /\     Filename : FDC.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:16 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    02/04/05 - Rev 0.0.1 Remove input/output bufs; Seperate GSR from clock block.
//    08/09/05 - Add CLR t0 GSR block (CR 215196).
//    10/20/05 - Add set & reset check to main  block. (CR219794)
//    2/07/06 - Remove set & reset from main block and add specify block (CR225119)
//    2/10/06 - Change Q from reg to wire (CR 225613)
// End Revision

`timescale  1 ps / 1 ps


module FDC (Q, C, CLR, D);

    parameter INIT = 1'b0;

    output Q;

    input  C, CLR, D;

    wire Q;
    reg q_out;
   
    initial q_out = INIT;

    always @(posedge C)
	         q_out <=  D;

    assign Q = q_out;

    specify
        (posedge CLR => (Q +: 1'b0)) = (0, 0);
        if (!CLR)
            (posedge C => (Q +: D)) = (100, 100);
    endspecify
endmodule
