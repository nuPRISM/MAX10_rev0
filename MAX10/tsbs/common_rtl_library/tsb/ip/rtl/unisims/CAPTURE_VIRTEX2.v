// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/CAPTURE_VIRTEX2.v,v 1.6.52.1 2007/03/09 18:13:02 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Register State Capture for Bitstream Readback for VIRTEX2
// /___/   /\     Filename : CAPTURE_VIRTEX2.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:15 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    07/23/05 - Added ONESHOT to all CAPUTURE comps; CR # 212645
//    01/19/06 - made ONESHOT false; CR # 220151
// End Revision

`timescale  100 ps / 10 ps


module CAPTURE_VIRTEX2 (CAP, CLK);

    input  CAP, CLK;

    parameter ONESHOT = "FALSE";

endmodule

