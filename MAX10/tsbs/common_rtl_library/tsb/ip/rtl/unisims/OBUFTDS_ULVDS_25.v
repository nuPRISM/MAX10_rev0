// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/OBUFTDS_ULVDS_25.v,v 1.5.158.1 2007/03/09 18:13:11 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  3-State Differential Signaling Output Buffer with ULVDS_25 I/O Standard
// /___/   /\     Filename : OBUFTDS_ULVDS_25.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:02 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module OBUFTDS_ULVDS_25 (O, OB, I, T);

    output O, OB;

    input  I, T;

    tri0 GTS = glbl.GTS;

    or O1 (ts, GTS, T);
    bufif0 B1 (O, I, ts);
    notif0 N1 (OB, I, ts);


endmodule


