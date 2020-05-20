// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/NAND3.v,v 1.5.158.1 2007/03/09 18:13:10 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  3-input NAND Gate
// /___/   /\     Filename : NAND3.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:56 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module NAND3 (O, I0, I1, I2);

    output O;

    input  I0, I1, I2;

    nand A1 (O, I0, I1, I2);


endmodule

