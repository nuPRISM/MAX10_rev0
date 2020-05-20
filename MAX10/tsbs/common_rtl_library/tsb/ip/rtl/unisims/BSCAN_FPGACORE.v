// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/BSCAN_FPGACORE.v,v 1.5.158.1 2007/03/09 18:13:01 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Boundary Scan Logic Control Circuit for FPGACORE
// /___/   /\     Filename : BSCAN_FPGACORE.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:13 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module BSCAN_FPGACORE (CAPTURE, DRCK1, DRCK2, RESET, SEL1, SEL2, SHIFT, TDI, UPDATE, TDO1, TDO2);

    input TDO1, TDO2;

    output CAPTURE, DRCK1, DRCK2, RESET, SEL1, SEL2, SHIFT, TDI, UPDATE;

    pulldown (DRCK1);
    pulldown (DRCK2);
    pulldown (RESET);
    pulldown (SEL1);
    pulldown (SEL2);
    pulldown (SHIFT);
    pulldown (TDI);
    pulldown (UPDATE);


endmodule

