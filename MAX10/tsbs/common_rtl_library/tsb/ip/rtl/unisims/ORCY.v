// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/ORCY.v,v 1.5.158.1 2007/03/09 18:13:17 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  OR with Carry Logic
// /___/   /\     Filename : ORCY.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:32 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module ORCY (O, CI, I);

    output O;

    input  CI, I;

	or X1 (O, CI, I);


endmodule

