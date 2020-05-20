// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/STARTUP_FPGACORE.v,v 1.4.158.1 2007/03/09 18:13:20 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  User Interface to Global Clock, Reset and 3-State Controls for FPGACORE
// /___/   /\     Filename : STARTUP_FPGACORE.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:41 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module STARTUP_FPGACORE (CLK, GSR);

    input  CLK, GSR;

    tri0 GSR;

	assign glbl.GSR = GSR;

endmodule

