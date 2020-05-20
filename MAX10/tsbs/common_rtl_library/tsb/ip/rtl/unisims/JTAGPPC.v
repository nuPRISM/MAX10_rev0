// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/JTAGPPC.v,v 1.5.158.1 2007/03/09 18:13:09 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  
// /___/   /\     Filename : JTAGPPC.v
// \   \  /  \    Timestamp : Thu Jun 24 16:42:51 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps

module JTAGPPC (TCK, TDIPPC, TMS, TDOPPC, TDOTSPPC);

output TCK;
output TDIPPC;
output TMS;

input TDOPPC;
input TDOTSPPC;

	assign TCK = 1'b1;
	assign TDIPPC = 1'b1;
	assign TMS = 1'b1;
endmodule
