// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/ICAP_VIRTEX2.v,v 1.4.158.1 2007/03/09 18:13:07 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Internal Configuration Access Port for Virtex2
// /___/   /\     Filename : ICAP_VIRTEX2.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:37 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module ICAP_VIRTEX2 (BUSY, O, CE, CLK, I, WRITE);

    output BUSY;
    output [7:0] O;
    input  CE, CLK, WRITE;
    input  [7:0] I;

endmodule

