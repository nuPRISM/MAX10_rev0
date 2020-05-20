// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/XORCY.v,v 1.5.158.1 2007/03/09 18:13:21 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  XOR for Carry Logic with General Output
// /___/   /\     Filename : XORCY.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:42 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module XORCY (O, CI, LI);

    output O;

    input  CI, LI;

	xor X1 (O, CI, LI);


endmodule

