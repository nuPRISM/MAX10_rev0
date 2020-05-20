// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/GND.v,v 1.4.158.1 2007/03/09 18:13:03 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  GND Connection
// /___/   /\     Filename : GND.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:19 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module GND(G);

    output G;

	assign G = 1'b0;

endmodule

