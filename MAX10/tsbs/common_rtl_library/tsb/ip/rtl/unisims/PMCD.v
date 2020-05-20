// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/virtex4/PMCD.v,v 1.4.218.2 2007/06/22 18:58:28 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 9.1i (J.38)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Phase-Matched Clock Divider
// /___/   /\     Filename : PMCD.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:52 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    06/20/07 - generate clka1d2 clka1d4 clka1d8 in same always block to remove delta delay (CR440337)
// End Revision

`timescale  1 ps / 1 ps

module PMCD (CLKA1, CLKA1D2, CLKA1D4, CLKA1D8, CLKB1, CLKC1, CLKD1, CLKA, CLKB, CLKC, CLKD, REL, RST); 

    output CLKA1;
    output CLKA1D2;
    output CLKA1D4;
    output CLKA1D8;
    output CLKB1;
    output CLKC1;
    output CLKD1;
 
    input CLKA;
    input CLKB;
    input CLKC;
    input CLKD;
    input REL;
    input RST;
   
    parameter EN_REL = "FALSE";
    parameter RST_DEASSERT_CLK = "CLKA";

    reg clka1_out, clkb1_out, clkc1_out, clkd1_out; 
    reg clka1d2_out, clka1d4_out, clka1d8_out;
    reg clkdiv_rel_rst;
    reg qrel_o_reg1, qrel_o_reg2, qrel_o_reg3;
    reg rel_o_mux;
    wire rel_rst_o;

    buf buf_clka1_out (CLKA1, clka1_out);
    buf buf_clka1d2_out (CLKA1D2, clka1d2_out);
    buf buf_clka1d4_out (CLKA1D4, clka1d4_out);
    buf buf_clka1d8_out (CLKA1D8, clka1d8_out);
    buf buf_clkb1_out (CLKB1, clkb1_out);
    buf buf_clkc1_out (CLKC1, clkc1_out);
    buf buf_clkd1_out (CLKD1, clkd1_out);

    buf buf_clka_in (clka_in, CLKA);
    buf buf_clkb_in (clkb_in, CLKB);
    buf buf_clkc_in (clkc_in, CLKC);
    buf buf_clkd_in (clkd_in, CLKD);
    buf buf_rel_in (rel_in, REL);
    buf buf_rst_in (rst_in, RST);


    initial begin

	clka1_out <= 1'b0;
	clkb1_out <= 1'b0;	   
	clkc1_out <= 1'b0;	   
	clkd1_out <= 1'b0;	   
        clka1d2_out <= 1'b0;
        clka1d4_out <= 1'b0;
        clka1d8_out <= 1'b0;
	qrel_o_reg1 <= 1'b0;
	qrel_o_reg2 <= 1'b0;
	qrel_o_reg3 <= 1'b0;

    end

    
//*** asyn RST
    always @(rst_in) begin

	if (rst_in == 1'b1) begin

	    assign qrel_o_reg1 = 1'b1;
	    assign qrel_o_reg2 = 1'b1;
	    assign qrel_o_reg3 = 1'b1;

	end
	else if (rst_in == 1'b0) begin

	    deassign qrel_o_reg1;
	    deassign qrel_o_reg2;
	    deassign qrel_o_reg3;

	end
    end


//*** Clocks MUX

    always @(clka_in or clkb_in or clkc_in or clkd_in) begin
	case (RST_DEASSERT_CLK)
             "CLKA" : rel_o_mux <= clka_in;
             "CLKB" : rel_o_mux <= clkb_in;
             "CLKC" : rel_o_mux <= clkc_in;
             "CLKD" : rel_o_mux <= clkd_in;
            default : begin
	                  $display("Attribute Syntax Error : The attribute RST_DEASSERT_CLK on PMCD instance %m is set to %s.  Legal values for this attribute are CLKA, CLKB, CLKC or CLKD.", RST_DEASSERT_CLK);
	                  $finish;
	              end
	endcase
    end

//*** CLKDIV_RST
    initial begin
	case (EN_REL)
              "FALSE" : clkdiv_rel_rst <= 1'b0;
              "TRUE" : clkdiv_rel_rst <= 1'b1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute EN_REL on PMCD instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EN_REL);
	                  $finish;
	              end
	endcase
    end


//*** Rel and Rst
    always @(posedge rel_o_mux) begin
	qrel_o_reg1 <= 1'b0;
    end

    always @(negedge rel_o_mux) begin
	qrel_o_reg2 <= qrel_o_reg1;
    end

    always @(posedge rel_in) begin
	qrel_o_reg3 <= 1'b0;
    end

    assign rel_rst_o = clkdiv_rel_rst ? (qrel_o_reg3 || qrel_o_reg1) : qrel_o_reg1;


//*** CLKA
    always @(clka_in or qrel_o_reg2)
	if (qrel_o_reg2 == 1'b1)
	    clka1_out <= 1'b0;
	else if (qrel_o_reg2 == 1'b0)
	    clka1_out <= clka_in;

//*** CLKB   
    always @(clkb_in or qrel_o_reg2)
	if (qrel_o_reg2 == 1'b1)
	    clkb1_out <= 1'b0;
	else if (qrel_o_reg2 == 1'b0)
	    clkb1_out <= clkb_in;

//*** CLKC
    always @(clkc_in or qrel_o_reg2)
	if (qrel_o_reg2 == 1'b1)
	    clkc1_out <= 1'b0;
	else if (qrel_o_reg2 == 1'b0)
	    clkc1_out <= clkc_in;

//*** CLKD   
    always @(clkd_in or qrel_o_reg2)
	if (qrel_o_reg2 == 1'b1)
	    clkd1_out <= 1'b0;
	else if (qrel_o_reg2 == 1'b0)
	    clkd1_out <= clkd_in;


//*** Clock divider

always @(posedge clka_in or posedge rel_rst_o)
  if (rel_rst_o == 1'b1)
  begin
     clka1d2_out <= 1'b0;
     clka1d4_out <= 1'b0;
     clka1d8_out <= 1'b0;
  end 
 else if (rel_rst_o == 1'b0)
  begin
     clka1d2_out <= ~clka1d2_out;
     if (!clka1d2_out)
      begin
         clka1d4_out <= ~clka1d4_out;
         if (!clka1d4_out)
          clka1d8_out <= ~clka1d8_out;
      end 
  end 

endmodule
