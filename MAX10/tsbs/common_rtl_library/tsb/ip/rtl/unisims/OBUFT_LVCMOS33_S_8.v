// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/OBUFT_LVCMOS33_S_8.v,v 1.5.158.1 2007/03/09 18:13:12 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  3-State Output Buffer with LVCMOS33 I/O Standard Slow Slew 8 mA Drive
// /___/   /\     Filename : OBUFT_LVCMOS33_S_8.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:11 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module OBUFT_LVCMOS33_S_8 (O, I, T);

    output O;

    input  I, T;

    tri0 GTS = glbl.GTS;

    or O1 (ts, GTS, T);
    bufif0 T1 (O, I, ts);


endmodule

