// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/IBUF_CTT.v,v 1.5.158.1 2007/03/09 18:13:06 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Input Buffer with CTT I/O Standard
// /___/   /\     Filename : IBUF_CTT.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:31 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module IBUF_CTT (O, I);

    output O;

    input  I;

	buf B1 (O, I);


endmodule

