// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/MULT_AND.v,v 1.4.158.1 2007/03/09 18:13:09 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Fast Multiplier AND
// /___/   /\     Filename : MULT_AND.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:54 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module MULT_AND (LO, I0, I1);

    output LO;

    input  I0, I1;

    and A1 (LO, I0, I1);

    specify
	(I0 *> LO) = (0, 0);
	(I1 *> LO) = (0, 0);
    endspecify

endmodule

