// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/STARTUP_SPARTAN2.v,v 1.4.158.1 2007/03/09 18:13:20 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  User Interface to Global Clock, Reset and 3-State Controls for SPARTAN2
// /___/   /\     Filename : STARTUP_SPARTAN2.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:41 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module STARTUP_SPARTAN2 (CLK, GSR, GTS);

    input  CLK, GSR, GTS;

    tri0 GSR, GTS;

	assign glbl.GSR = GSR;
	assign glbl.GTS = GTS;

endmodule

