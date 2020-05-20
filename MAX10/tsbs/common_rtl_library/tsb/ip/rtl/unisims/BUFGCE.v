// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/BUFGCE.v,v 1.6.158.1 2007/03/09 18:13:02 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Global Clock Mux Buffer with Clock Enable and Output State 0
// /___/   /\     Filename : BUFGCE.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:14 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps

module BUFGCE (O, CE, I);

    output O;

    input  CE, I;

    wire   NCE;

    BUFGMUX B1 (.I0(I),
	.I1(1'b0),
	.O(O),
	.S(NCE));

    INV I1 (.I(CE),
	.O(NCE));

endmodule
