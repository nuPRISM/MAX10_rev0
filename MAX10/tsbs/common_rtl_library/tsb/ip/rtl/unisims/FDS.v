// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/FDS.v,v 1.11.48.1 2007/03/09 18:13:03 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.27)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  D Flip-Flop with Synchronous Set
// /___/   /\     Filename : FDS.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:18 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    02/04/05 - Rev 0.0.1 Remove input/output bufs; Seperate GSR from clock block.
//    10/20/05 - Add set & reset check to main  block. (CR219794)
//    2/07/06 - Remove set & reset from main block and add specify block (CR225119)
//    2/10/06 - Change Q from reg to wire (CR 225613)
// End Revision

`timescale  1 ps / 1 ps


module FDS (Q, C, D, S);

    parameter INIT = 1'b1;

    output Q;

    input  C, D, S;

    wire Q;
    reg q_out;

    initial q_out = INIT;

    assign Q = q_out;



    always @(posedge C )
         if (S)
	     q_out <=  1;
         else
	     q_out <=  D;

    specify
        if (S)
            (posedge C => (Q +: 1'b1)) = (100, 100);
        if (!S)
            (posedge C => (Q +: D)) = (100, 100);
    endspecify

endmodule
