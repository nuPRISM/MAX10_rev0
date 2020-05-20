// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/NOR4B2.v,v 1.5.158.1 2007/03/09 18:13:10 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  4-input NOR Gate
// /___/   /\     Filename : NOR4B2.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:59 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module NOR4B2 (O, I0, I1, I2, I3);

    output O;

    input  I0, I1, I2, I3;

    not N1 (i1_inv, I1);
    not N0 (i0_inv, I0);
    nor O1 (O, i0_inv, i1_inv, I2, I3);


endmodule

