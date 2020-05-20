// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/IBUFGDS_LVDSEXT_33.v,v 1.5.158.1 2007/03/09 18:13:04 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Differential Signaling Input Clock Buffer with LVDSEXT_33 I/O Standard
// /___/   /\     Filename : IBUFGDS_LVDSEXT_33.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:25 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module IBUFGDS_LVDSEXT_33 (O, I, IB);

    output O;

    input  I, IB;

    reg o_out;

    buf b_0 (O, o_out);

    always @(I or IB) begin
	if (I == 1'b1 && IB == 1'b0)
	    o_out <= I;
	else if (I == 1'b0 && IB == 1'b1)
	    o_out <= I;
    end


endmodule


