// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/LUT1_L.v,v 1.6.158.1 2007/03/09 18:13:09 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  1-input Look-Up-Table with Local Output
// /___/   /\     Filename : LUT1_L.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:53 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    02/04/05 - Rev 0.0.1 Replace premitive with function; Remove buf.
// End Revision

`timescale  100 ps / 10 ps


module LUT1_L (LO, I0);

    parameter INIT = 2'h0;

    input I0;

    output LO;
  
    wire LO;

    assign LO = (INIT[0] == INIT[1]) ? INIT[0] : INIT[I0];

endmodule
