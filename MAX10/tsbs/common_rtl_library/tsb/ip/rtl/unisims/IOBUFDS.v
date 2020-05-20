// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/IOBUFDS.v,v 1.7.158.1 2007/03/09 18:13:07 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  3-State Diffential Signaling I/O Buffer
// /___/   /\     Filename : IOBUFDS.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:37 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module IOBUFDS (O, IO, IOB, I, T);

    parameter CAPACITANCE = "DONT_CARE";
    parameter IBUF_DELAY_VALUE = "0";
    parameter IFD_DELAY_VALUE = "AUTO";
    parameter IOSTANDARD = "DEFAULT";

    output O;
    inout  IO, IOB;
    input  I, T;

    tri0 GTS = glbl.GTS;

    reg O;
    
    or O1 (ts, GTS, T);
    bufif0 B1 (IO, I, ts);
    notif0 N1 (IOB, I, ts);


    initial begin
	
        case (CAPACITANCE)

            "LOW", "NORMAL", "DONT_CARE" : ;
            default : begin
                          $display("Attribute Syntax Error : The attribute CAPACITANCE on IOBUFDS instance %m is set to %s.  Legal values for this attribute are DONT_CARE, LOW or NORMAL.", CAPACITANCE);
                          $finish;
                      end

        endcase


	case (IBUF_DELAY_VALUE)

            "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16" : ;
            default : begin
                          $display("Attribute Syntax Error : The attribute IBUF_DELAY_VALUE on IOBUFDS instance %m is set to %s.  Legal values for this attribute are 0, 1, 2, ... or 16.", IBUF_DELAY_VALUE);
                          $finish;
                      end

        endcase


	case (IFD_DELAY_VALUE)

            "AUTO", "0", "1", "2", "3", "4", "5", "6", "7", "8" : ;
            default : begin
                          $display("Attribute Syntax Error : The attribute IFD_DELAY_VALUE on IOBUFDS instance %m is set to %s.  Legal values for this attribute are AUTO, 0, 1, 2, ... or 8.", IFD_DELAY_VALUE);
                          $finish;
                      end

	endcase

    end


    always @(IO or IOB) begin
        if (IO == 1'b1 && IOB == 1'b0)
            O <= IO;
        else if (IO == 1'b0 && IOB == 1'b1)
            O <= IO;
    end

    
endmodule


