// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/BUFT.v,v 1.5.158.1 2007/03/09 18:13:02 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Internal 3-State Buffers with Active Low Enable
// /___/   /\     Filename : BUFT.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:14 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module BUFT (O, I, T);

    output O;

    input  I, T;

	bufif0 T1 (O, I, T);


endmodule

