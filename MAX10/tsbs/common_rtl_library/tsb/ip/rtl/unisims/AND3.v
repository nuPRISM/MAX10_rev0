// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/AND3.v,v 1.5.158.1 2007/03/09 18:13:00 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  3-input AND Gate
// /___/   /\     Filename : AND3.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:12 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module AND3 (O, I0, I1, I2);

    output O;

    input  I0, I1, I2;

    and A1 (O, I0, I1, I2);


endmodule

