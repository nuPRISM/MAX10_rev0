// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/MUXF8_D.v,v 1.8.158.1 2007/03/09 18:13:10 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  2-to-1 Lookup Table Multiplexer with Dual Output
// /___/   /\     Filename : MUXF8_D.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:56 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    02/04/05 - Rev 0.0.1 Remove input/output bufs; Remove unnessasary begin/end;
// End Revision

`timescale  100 ps / 10 ps


module MUXF8_D (LO, O, I0, I1, S);

    output LO, O;
    reg    O, LO;

    input  I0, I1, S;

	always @(I0 or I1 or S)
	    if (S) begin
		O <= I1;
		LO <= I1;
            end
	    else begin
		O <= I0;
		LO <= I0;
	    end
endmodule

