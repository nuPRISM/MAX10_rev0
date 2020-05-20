// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/SRLC16E.v,v 1.6.158.1 2007/03/09 18:13:20 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  16-Bit Shift Register Look-Up-Table with Carry and Clock Enable
// /___/   /\     Filename : SRLC16E.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:40 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  1 ps / 1 ps


module SRLC16E (Q, Q15, A0, A1, A2, A3, CE, CLK, D);

    parameter INIT = 16'h0000;

    output Q, Q15;

    input  A0, A1, A2, A3, CE, CLK, D;

   

endmodule

