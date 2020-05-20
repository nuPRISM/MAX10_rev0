// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/PULLDOWN.v,v 1.4.158.1 2007/03/09 18:13:17 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Resistor to GND
// /___/   /\     Filename : PULLDOWN.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:32 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module PULLDOWN (O);

    output O;

	pulldown (A);
	buf (weak0,weak1) #(1,1) (O,A);

endmodule

