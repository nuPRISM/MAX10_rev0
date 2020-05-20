// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/IBUF_LVDCI_33.v,v 1.5.158.1 2007/03/09 18:13:06 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Input Buffer with LVDCI_33 I/O Standard
// /___/   /\     Filename : IBUF_LVDCI_33.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:34 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module IBUF_LVDCI_33 (O, I);

    output O;

    input  I;

	buf B1 (O, I);


endmodule

