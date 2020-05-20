// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/BSCAN_VIRTEX.v,v 1.5.158.1 2007/03/09 18:13:01 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Boundary Scan Logic Control Circuit for VIRTEX
// /___/   /\     Filename : BSCAN_VIRTEX.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:13 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module BSCAN_VIRTEX (DRCK1, DRCK2, RESET, SEL1, SEL2, SHIFT, TDI, UPDATE, TDO1, TDO2);

    input TDO1, TDO2;

    output DRCK1, DRCK2, RESET, SEL1, SEL2, SHIFT, TDI, UPDATE;

    pulldown (TDI);
    pulldown (RESET);
    pulldown (SHIFT);
    pulldown (UPDATE);
    pulldown (SEL1);
    pulldown (DRCK1);
    pulldown (SEL2);
    pulldown (DRCK2);


endmodule

