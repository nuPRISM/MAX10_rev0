// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/virtex4/ICAP_VIRTEX4.v,v 1.3.230.1 2007/03/09 18:13:22 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 7.1i (H.19)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Internal Configuration Access Port for Virtex4
// /___/   /\     Filename : ICAP_VIRTEX4.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:51 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.

`timescale  100 ps / 10 ps


module ICAP_VIRTEX4 (BUSY, O, CE, CLK, I, WRITE);

    output BUSY;
    output [31:0] O;

    input  CE, CLK, WRITE;
    input  [31:0] I;

    parameter ICAP_WIDTH = "X8";
    
endmodule

