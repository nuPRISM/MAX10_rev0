// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/IBUFG_LVDCI_DV2_15.v,v 1.5.158.1 2007/03/09 18:13:05 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Input Clock Buffer with LVDCI_DV2_15 I/O Standard
// /___/   /\     Filename : IBUFG_LVDCI_DV2_15.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:29 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module IBUFG_LVDCI_DV2_15 (O, I);

    output O;

    input  I;

	buf B1 (O, I);


endmodule

