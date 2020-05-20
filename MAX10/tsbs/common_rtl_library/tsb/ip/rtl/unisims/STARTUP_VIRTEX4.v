// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/virtex4/STARTUP_VIRTEX4.v,v 1.3.230.1 2007/03/09 18:13:22 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 7.1i (H.19)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  User Interface to Global Clock, Reset and 3-State Controls for VIRTEX4
// /___/   /\     Filename : STARTUP_VIRTEX4.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:52 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.

`timescale  100 ps / 10 ps


module STARTUP_VIRTEX4 (EOS, CLK, GSR, GTS, USRCCLKO, USRCCLKTS, USRDONEO, USRDONETS);

    output EOS;
    
    input CLK;
    input GSR;
    input GTS;
    input USRCCLKO;
    input USRCCLKTS;
    input USRDONEO;
    input USRDONETS;
    
    tri0 GSR, GTS;

	assign glbl.GSR = GSR;
	assign glbl.GTS = GTS;

endmodule

