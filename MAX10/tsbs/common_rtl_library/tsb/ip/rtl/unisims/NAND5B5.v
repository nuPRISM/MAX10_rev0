// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/NAND5B5.v,v 1.5.158.1 2007/03/09 18:13:10 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  5-input NAND Gate
// /___/   /\     Filename : NAND5B5.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:58 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module NAND5B5 (O, I0, I1, I2, I3, I4);

    output O;

    input  I0, I1, I2, I3, I4;

    not N4 (i4_inv, I4);
    not N3 (i3_inv, I3);
    not N2 (i2_inv, I2);
    not N1 (i1_inv, I1);
    not N0 (i0_inv, I0);
    nand A1 (O, i0_inv, i1_inv, i2_inv, i3_inv, i4_inv);


endmodule

