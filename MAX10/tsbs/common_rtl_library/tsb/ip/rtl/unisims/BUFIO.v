// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/virtex4/BUFIO.v,v 1.3.230.1 2007/03/09 18:13:21 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 7.1i (H.19)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Local Clock Buffer for I/O
// /___/   /\     Filename : BUFIO.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:43 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.

`timescale  100 ps / 10 ps


module BUFIO (O, I);

    output O;
    
    input  I;
    
    buf B1 (O, I);

endmodule

