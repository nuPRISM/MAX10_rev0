// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/virtex4/USR_ACCESS_VIRTEX4.v,v 1.3.230.1 2007/03/09 18:13:22 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 7.1i (H.19)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  
// /___/   /\     Filename : USR_ACCESS_VIRTEX4.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:52 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.

`timescale  100 ps / 10 ps

module USR_ACCESS_VIRTEX4 (DATA, DATAVALID);

    output [31:0] DATA;
    output DATAVALID;

endmodule // USR_ACCESS_VIRTEX4
