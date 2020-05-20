// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/trilogy/SPI_ACCESS.v,v 1.8.2.5 2007/10/12 00:57:04 wloo Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Internal logic access to the Serial Peripheral Interface (SPI) PROM data
// /___/   /\     Filename : SPI_ACCESS.v
// \   \  /  \    Timestamp : Mon Jul 10 14:49:22 PDT 2006
//  \___\/\___\
//
//                WARNING!!!  -- "This behavioral model is for Xilinx test purpose only.
//                Simulation of this model is not currently supported by Xilinx."
//
// Revision:
//    07/10/06 - Initial version.
//    10/11/06 - #426351 -- Changed SIM_MEM_FILE default value to "NONE"
//    01/21/07 - #432680 -- Title Adjustment
//    10/11/07 - Removed functionality (CR 449588).
// End Revision

`timescale  1 ps / 1 ps

module SPI_ACCESS (MISO, CLK, CSB, MOSI);

    output MISO;

    input CLK, CSB, MOSI;
    
    parameter SIM_DEVICE = "UNSPECIFIED";
    parameter SIM_FACTORY_ID = 64'h0;
    parameter SIM_MEM_FILE = "NONE";
    parameter SIM_USER_ID = 64'h0;

    tri0  GSR = glbl.GSR;

    specify
	
        (CLK => MISO) = (100:100:100, 100:100:100);
        specparam PATHPULSE$ = 0;

    endspecify

endmodule // SPI_ACCESS

