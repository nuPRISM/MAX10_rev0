// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/IOBUFDS_BLVDS_25.v,v 1.6.158.1 2007/03/09 18:13:07 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  3-State Differential Signaling I/O Buffer with BLVDS_25 I/O Standard
// /___/   /\     Filename : IOBUFDS_BLVDS_25.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:37 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module IOBUFDS_BLVDS_25 (O, IO, IOB, I, T);
    
    output O;
    inout IO, IOB;
    input I, T;
    
    tri0 GTS = glbl.GTS;

    reg O;
    
    or O1 (ts, GTS, T);
    bufif0 B1 (IO, I, ts);
    notif0 N1 (IOB, I, ts);
    
    always @(IO or IOB) begin
        if (IO == 1'b1 && IOB == 1'b0)
            O <= IO;
        else if (IO == 1'b0 && IOB == 1'b1)
            O <= IO;
    end

endmodule


