// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/IBUFG_LVCMOS25.v,v 1.5.158.1 2007/03/09 18:13:05 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Input Clock Buffer with LVCMOS25 I/O Standard
// /___/   /\     Filename : IBUFG_LVCMOS25.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:28 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module IBUFG_LVCMOS25 (O, I);

    output O;

    input  I;

	buf B1 (O, I);


endmodule

