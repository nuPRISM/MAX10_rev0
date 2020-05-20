// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/OBUFDS_LVDSEXT_25.v,v 1.5.158.1 2007/03/09 18:13:11 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Differential Signaling Output Buffer with LVDSEXT_25 I/O Standard
// /___/   /\     Filename : OBUFDS_LVDSEXT_25.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:00 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module OBUFDS_LVDSEXT_25 (O, OB, I);

    output O, OB;

    input  I;

    tri0 GTS = glbl.GTS;

	bufif0 B1 (O, I, GTS);
	notif0 N1 (OB, I, GTS);


endmodule


