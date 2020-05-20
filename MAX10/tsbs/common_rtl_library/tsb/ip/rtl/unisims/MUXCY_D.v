// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/MUXCY_D.v,v 1.8.158.1 2007/03/09 18:13:09 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  2-to-1 Multiplexer for Carry Logic with Dual Output
// /___/   /\     Filename : MUXCY_D.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:55 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    02/04/05 - Rev 0.0.1 Remove input/output bufs; Remove unnessasary begin/end;
// End Revision

`timescale  100 ps / 10 ps


module MUXCY_D (LO, O, CI, DI, S);

    output LO, O;
    reg    O, LO;

    input  CI, DI, S;

	always @(CI or DI or S) 
	    if (S) begin
		O <= CI;
                LO <= CI;
            end
	    else begin
		O <= DI;
                LO <= DI;
            end

endmodule

