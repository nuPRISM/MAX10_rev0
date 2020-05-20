///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 9.1i 
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  18X18 Signed Multiplier Followed by Three-Input Adder plus ALU with Pipeline Registers
// /___/   /\     Filename : DSP48E.v
// \   \  /  \    Timestamp : Thu Mar 24 16:44:06 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/05 - Initial version.
//    05/26/05 - BTrack 191 mult not valid in TWO24/FOUR12/USE_MULT=NONE.
//    06/16/05 - Added MULTSIGNIN/OUT pins and functionality
//    09/29/05 - Made xyz muxes to be sensitive to carryinsel when recovering from invalid opmode/carryinsel
//    10/05/05 - Added more valid DRC check entries.
//    10/25/05 - CR 219047 
//    11/03/05 - Added two DRC checks -- ARITHMETIC and LOGIC 
//    11/07/05 - 'X'ed out carrycascout in LOGIC modes (like the carryout)
//    11/21/05 - 'X'ed out pattern detect signals when in illegal opmodes.
//    02/28/06 - CR 225886 -- USE_MULT check updates.
//    02/28/06 - CR 226267 -- Changed USE_MULT default to MULT_S.
//    02/28/06 - CR 226003 -- Added Parameter Types (integer/real)
//    05/28/06 - CR 230656 -- disabled timing checks for all RSTs when GSR is active.
//    12/10/06 - CR 429825 -- Added timing checks for CARRYCASCIN.
//    10/16/07 - CR 452039 -- Enhanced DRC warning for OPMODE/CARRYINSEL checks.
// End Revision

`timescale  1 ps / 1 ps

module DSP48E (ACOUT, BCOUT, CARRYCASCOUT, CARRYOUT, MULTSIGNOUT, OVERFLOW, P, PATTERNBDETECT, PATTERNDETECT, PCOUT, UNDERFLOW, A, ACIN, ALUMODE, B, BCIN, C, CARRYCASCIN, CARRYIN, CARRYINSEL, CEA1, CEA2, CEALUMODE, CEB1, CEB2, CEC, CECARRYIN, CECTRL, CEM, CEMULTCARRYIN, CEP, CLK, MULTSIGNIN, OPMODE, PCIN, RSTA, RSTALLCARRYIN, RSTALUMODE, RSTB, RSTC, RSTCTRL, RSTM, RSTP); 

    parameter integer ACASCREG = 1;
    parameter integer ALUMODEREG = 1;
    parameter integer AREG = 1;
    parameter AUTORESET_PATTERN_DETECT = "FALSE"; 
    parameter AUTORESET_PATTERN_DETECT_OPTINV = "MATCH";
    parameter A_INPUT = "DIRECT";
    parameter integer BCASCREG = 1;
    parameter integer BREG = 1;
    parameter B_INPUT = "DIRECT";
    parameter integer CARRYINREG = 1;
    parameter integer CARRYINSELREG = 1;
    parameter integer CREG = 1;
    parameter MASK =  48'h3FFFFFFFFFFF;
    parameter integer MREG = 1;
    parameter integer MULTCARRYINREG = 1;
    parameter integer OPMODEREG = 1;
    parameter PATTERN =  48'h000000000000;
    parameter integer PREG = 1;
    parameter SEL_MASK = "MASK";
    parameter SEL_PATTERN = "PATTERN";
    parameter SEL_ROUNDING_MASK = "SEL_MASK";
    parameter USE_MULT = "MULT_S";
    parameter USE_PATTERN_DETECT = "NO_PATDET";
    parameter USE_SIMD = "ONE48";

    output [29:0] ACOUT; 
    output [17:0] BCOUT; 
    output CARRYCASCOUT;
    output [3:0] CARRYOUT;
    output MULTSIGNOUT;
    output OVERFLOW;
    output [47:0] P; 
    output PATTERNBDETECT;
    output PATTERNDETECT;
    output [47:0] PCOUT;
    output UNDERFLOW;

    input [29:0] A;
    input [29:0] ACIN;
    input [3:0] ALUMODE;
    input [17:0] B;
    input [17:0] BCIN;
    input [47:0] C;
    input CARRYCASCIN;
    input CARRYIN;
    input [2:0] CARRYINSEL;
    input CEA1;
    input CEA2;
    input CEALUMODE;
    input CEB1;
    input CEB2;
    input CEC;
    input CECARRYIN;
    input CECTRL;
    input CEM;
    input CEMULTCARRYIN;
    input CEP;
    input CLK;
    input MULTSIGNIN;
    input [6:0] OPMODE;
    input [47:0] PCIN;
    input RSTA;
    input RSTALLCARRYIN;
    input RSTALUMODE;
    input RSTB;
    input RSTC;
    input RSTCTRL;
    input RSTM;  
    input RSTP;

    tri0  GSR = glbl.GSR;

//------------------- constants -------------------------
   localparam MAX_ACOUT      = 30;
   localparam MAX_BCOUT      = 18;
   localparam MAX_CARRYOUT   = 4;
   localparam MAX_P          = 48;
   localparam MAX_PCOUT      = 48;

   localparam MAX_A          = 30;
   localparam MAX_ACIN       = 30;
   localparam MAX_ALUMODE    = 4;
   localparam MAX_A_MULT     = 25;
   localparam MAX_B          = 18;
   localparam MAX_B_MULT     = 18;
   localparam MAX_BCIN       = 18;
   localparam MAX_C          = 48;
   localparam MAX_CARRYINSEL = 3;
   localparam MAX_OPMODE     = 7;
   localparam MAX_PCIN       = 48;

   localparam MAX_ALU_FULL   = 48;
   localparam MAX_ALU_HALF   = 24;
   localparam MAX_ALU_QUART  = 12;

   localparam MSB_ACOUT      = MAX_ACOUT - 1;
   localparam MSB_BCOUT      = MAX_BCOUT - 1;
   localparam MSB_CARRYOUT   = MAX_CARRYOUT - 1;
   localparam MSB_P          = MAX_P - 1;
   localparam MSB_PCOUT      = MAX_PCOUT - 1;
 
   localparam MSB_A          = MAX_A - 1;
   localparam MSB_ACIN       = MAX_ACIN - 1;
   localparam MSB_ALUMODE    = MAX_ALUMODE - 1;
   localparam MSB_A_MULT     = MAX_A_MULT - 1;
   localparam MSB_B          = MAX_B - 1;
   localparam MSB_B_MULT     = MAX_B_MULT - 1;
   localparam MSB_BCIN       = MAX_BCIN - 1;
   localparam MSB_C          = MAX_C - 1;
   localparam MSB_CARRYINSEL = MAX_CARRYINSEL - 1;
   localparam MSB_OPMODE     = MAX_OPMODE - 1;
   localparam MSB_PCIN       = MAX_PCIN - 1;

   localparam MSB_ALU_FULL   = MAX_ALU_FULL  - 1;
   localparam MSB_ALU_HALF   = MAX_ALU_HALF  - 1;
   localparam MSB_ALU_QUART  = MAX_ALU_QUART - 1;

   localparam SHIFT_MUXZ     = 17;

    reg [29:0] a_o_mux, qa_o_mux, qa_o_reg1, qa_o_reg2, qacout_o_mux;
    reg [17:0] b_o_mux, qb_o_mux, qb_o_reg1, qb_o_reg2, qbcout_o_mux;
    reg [2:0] qcarryinsel_o_mux, qcarryinsel_o_reg1;
    reg [(MSB_A_MULT+MSB_B_MULT+1):0] qmult_o_mux, qmult_o_reg;
    reg [47:0] qc_o_mux, qc_o_reg1;
    reg [47:0] qp_o_mux, qp_o_reg1;
    reg [47:0] qx_o_mux, qy_o_mux, qz_o_mux;
    reg [6:0]  qopmode_o_mux, qopmode_o_reg1;

    

    reg qcarryin_o_mux0, qcarryin_o_reg0, qcarryin_o_mux7, qcarryin_o_reg7;
    reg qcarryin_o_mux, qcarryin_o_reg;

    reg [3:0]  qalumode_o_mux, qalumode_o_reg1;

    reg invalid_opmode, opmode_valid_flag, alumode_valid_flag, ping_opmode_drc_check = 0;

    reg [47:0] alu_o;

    reg qmultsignout_o_reg, multsignout_o_mux, multsignout_o_opmode;

    reg [MAX_ALU_FULL:0]  alu_full_tmp;
    reg [MAX_ALU_HALF:0]  alu_hlf1_tmp, alu_hlf2_tmp;
    reg [MAX_ALU_QUART:0] alu_qrt1_tmp,  alu_qrt2_tmp, alu_qrt3_tmp, alu_qrt4_tmp;
    
    wire [29:0] acin_in, a_in;
    wire [17:0] bcin_in, b_in;
    wire [2:0] carryinsel_in;
    wire [(MSB_A_MULT+MSB_B_MULT+1):0] mult_o;
    wire [47:0] pcin_in, c_in;
    wire [6:0] opmode_in;
    wire [3:0] alumode_in;
    wire pdet_o_mux, detb_o_mux;

    reg [47:0] pattern_qp = 0, mask_qp = 0;
    reg carrycascout_o;
    reg carrycascout_o_reg = 0;
    reg carrycascout_o_mux = 0;

    reg [3:0] carryout_o = 0;
    reg [3:0] carryout_o_reg = 0;
    reg [3:0] carryout_o_mux = 0;
    wire [3:0] carryout_x_o;

    reg pdet_o, pdetb_o, pdet_o_reg1, pdet_o_reg2, pdetb_o_reg1, pdetb_o_reg2;
    reg overflow_o, underflow_o;

//----------------------------------------------------------------------
//------------------------  Output Ports  ------------------------------
//----------------------------------------------------------------------
    buf b_acout_o[MSB_ACOUT:0] (ACOUT, qacout_o_mux);
    buf b_bcout_o[MSB_BCOUT:0] (BCOUT, qbcout_o_mux);
    buf b_carrycascout (CARRYCASCOUT, carrycascout_o_mux);
    buf b_carryout[MSB_CARRYOUT:0] (CARRYOUT, carryout_x_o);
    buf b_multsignout (MULTSIGNOUT,  multsignout_o_mux);
    buf b_overflow (OVERFLOW,  overflow_o);
    buf b_p_o[MSB_P:0] (P, qp_o_mux);
    buf b_pcout_o[MSB_PCOUT:0] (PCOUT, qp_o_mux);
    buf b_patterndetect (PATTERNDETECT,  pdet_o_mux);
    buf b_patternbdetect (PATTERNBDETECT, pdetb_o_mux);
    buf b_underflow (UNDERFLOW, underflow_o);

//-----------------------------------------------------
//-----------   Inputs --------------------------------
//-----------------------------------------------------
    buf b_a[MSB_A:0] (a_in, A);
    buf b_acin[MSB_ACIN:0] (acin_in, ACIN);
    buf b_alumode[MSB_ALUMODE:0] (alumode_in, ALUMODE);

    buf b_b[MSB_B:0] (b_in, B);
    buf b_bcin[MSB_BCIN:0] (bcin_in, BCIN);

    buf b_c[MSB_C:0] (c_in, C);

    buf b_carryin (carryin_in, CARRYIN);
    buf b_carrycascin (carrycascin_in, CARRYCASCIN);
    buf b_carryinsel[MSB_CARRYINSEL:0] (carryinsel_in, CARRYINSEL);
    buf b_cep (cep_in, CEP);
    buf b_cea1 (cea1_in, CEA1);
    buf b_cea2 (cea2_in, CEA2);
    buf b_cealumode (cealumode_in, CEALUMODE);
    buf b_ceb1 (ceb1_in, CEB1);
    buf b_ceb2 (ceb2_in, CEB2);
    buf b_cec (cec_in, CEC);
    buf b_cecarryin (cecarryin_in, CECARRYIN);
    buf b_cectrl (cectrl_in, CECTRL);
    buf b_cem (cem_in, CEM);
    buf b_cemultcarryin (cemultcarryin_in, CEMULTCARRYIN);
    buf b_clk (clk_in, CLK);
    buf b_gsr (gsr_in, GSR);
    buf b_multsignin (multsignin_in, MULTSIGNIN);
    buf b_opmode[MSB_OPMODE:0] (opmode_in, OPMODE);
    buf b_pcin[MSB_PCIN:0] (pcin_in, PCIN);
    buf b_rstp (rstp_in, RSTP);
    buf b_rsta (rsta_in, RSTA);
    buf b_rstalumode (rstalumode_in, RSTALUMODE);
    buf b_rstb (rstb_in, RSTB);
    buf b_rstallcarryin (rstallcarryin_in, RSTALLCARRYIN);
    buf b_rstc (rstc_in, RSTC);
    buf b_rstctrl (rstctrl_in, RSTCTRL);
    buf b_rstm (rstm_in, RSTM);

//*** GLOBAL hidden GSR pin
    always @(gsr_in) begin
	if (gsr_in) begin
            assign qcarryin_o_reg0 = 1'b0;
            assign qcarryinsel_o_reg1 = 3'b0;
            assign qopmode_o_reg1 = 7'b0;
            assign qalumode_o_reg1 = 4'b0;
            assign qa_o_reg1 = 30'b0;
            assign qa_o_reg2 = 30'b0;
            assign qb_o_reg1 = 18'b0;
            assign qb_o_reg2 = 18'b0;
            assign qc_o_reg1 = 48'b0;
            assign qp_o_reg1 = 48'b0;
	    assign qmult_o_reg = 36'b0;

            assign underflow_o = 1'b0;
            assign overflow_o = 1'b0;
            assign pdet_o = 1'b0;
            assign pdetb_o = 1'b0;
            assign pdet_o_reg1 = 1'b0;
            assign pdet_o_reg2 = 1'b0;
            assign pdetb_o_reg1 = 1'b0;
            assign pdetb_o_reg2 = 1'b0;

            assign carryout_o_reg = 4'b0;
            assign carrycascout_o_reg = 1'b0;

	    assign qmultsignout_o_reg = 1'b0;
	end
	else begin
            deassign qcarryin_o_reg0;
            deassign qcarryinsel_o_reg1;
            deassign qopmode_o_reg1;
            deassign qalumode_o_reg1;
            deassign qa_o_reg1;
            deassign qa_o_reg2;
            deassign qb_o_reg1;
            deassign qb_o_reg2;
            deassign qc_o_reg1;
            deassign qp_o_reg1;
	    deassign qmult_o_reg;

            deassign underflow_o;
            deassign overflow_o;
            deassign pdet_o;
            deassign pdetb_o;
            deassign pdet_o_reg1;
            deassign pdet_o_reg2;
            deassign pdetb_o_reg1;
            deassign pdetb_o_reg2;

            deassign carryout_o_reg;
            deassign carrycascout_o_reg;

	    deassign qmultsignout_o_reg;
	end
    end


    initial begin
	opmode_valid_flag <= 1;
	alumode_valid_flag <= 1;
	invalid_opmode <= 1;

        //-------- AREG check

	case (AREG)
            0, 1, 2 : ;
            default : begin
	                  $display("Attribute Syntax Error : The attribute AREG on DSP48E instance %m is set to %d.  Legal values for this attribute are 0, 1 or 2.", AREG);
	                  $finish;
	              end
	endcase

        //-------- (ACASCREG) and (ACASCREG vs AREG) check

	case (AREG)
            0 : if(AREG != ACASCREG) begin
                    $display("Attribute Syntax Error : The attribute ACASCREG  on DSP48E instance %m is set to %d.  ACASCREG has to be set to 0 when attribute AREG = 0.", ACASCREG);
                    $finish;
                end
            1 : if(AREG != ACASCREG) begin
                    $display("Attribute Syntax Error : The attribute ACASCREG  on DSP48E instance %m is set to %d.  ACASCREG has to be set to 1 when attribute AREG = 1.", ACASCREG);
                    $finish;
                end
            2 : if((AREG != ACASCREG) && ((AREG-1) != ACASCREG)) begin
                    $display("Attribute Syntax Error : The attribute ACASCREG  on DSP48E instance %m is set to %d.  ACASCREG has to be set to either 2 or 1 when attribute AREG = 2.", ACASCREG);
                    $finish;
                end
            default : ;
	endcase

        //-------- BREG check

	case (BREG)
            0, 1, 2 : ;
            default : begin
	                  $display("Attribute Syntax Error : The attribute BREG on DSP48E instance %m is set to %d.  Legal values for this attribute are 0, 1 or 2.", BREG);
	                  $finish;
	              end
	endcase

        //-------- (BCASCREG) and (BCASCREG vs BREG) check

	case (BREG)
            0 : if(BREG != BCASCREG) begin
                    $display("Attribute Syntax Error : The attribute BCASCREG  on DSP48E instance %m is set to %d.  BCASCREG has to be set to 0 when attribute BREG = 0.", BCASCREG);
                    $finish;
                end
            1 : if(BREG != BCASCREG) begin
                    $display("Attribute Syntax Error : The attribute BCASCREG  on DSP48E instance %m is set to %d.  BCASCREG has to be set to 1 when attribute BREG = 1.", BCASCREG);
                    $finish;
                end
            2 : if((BREG != BCASCREG) && ((BREG-1) != BCASCREG)) begin
                    $display("Attribute Syntax Error : The attribute BCASCREG  on DSP48E instance %m is set to %d.  BCASCREG has to be set to either 2 or 1 when attribute BREG = 2.", BCASCREG);
                    $finish;
                end
            default : ;
	endcase


        //-------- AUTORESET_PATTERN_DETECT

        case (AUTORESET_PATTERN_DETECT)
            "TRUE", "FALSE" : ;
            default : begin
               $display("Attribute Syntax Error : The attribute AUTORESET_PATTERN_DETECT on DSP48E instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.",  AUTORESET_PATTERN_DETECT);
               $finish;
            end
        endcase

        //-------- AUTORESET_PATTERN_DETECT_OPTINV

        case (AUTORESET_PATTERN_DETECT_OPTINV)
            "MATCH", "NOT_MATCH" : ;
            default : begin
               $display("Attribute Syntax Error : The attribute AUTORESET_PATTERN_DETECT_OPTINV on DSP48E instance %m is set to %s.  Legal values for this attribute are MATCH or NOT_MATCH.",  AUTORESET_PATTERN_DETECT_OPTINV);
               $finish;
            end
        endcase

        //-------- USE_MULT

        case (USE_MULT)
            "NONE" : ;
            "MULT" : if (MREG != 0) begin
                               $display("Attribute Syntax Error : The attribute USE_MULT on DSP48E instance %m is set to %s. This requires attribute MREG to be set to 0.", USE_MULT);
                               $finish;
                        end
            "MULT_S" : if (MREG != 1) begin
                               $display("Attribute Syntax Error : The attribute USE_MULT on DSP48E instance %m is set to %s. This requires attribute MREG to be set to 1.", USE_MULT);
                               $finish;
                        end
            default : begin
                          $display("Attribute Syntax Error : The attribute USE_MULT on DSP48E instance %m is set to %s. Legal values for this attribute are NONE, MULT or MULT_S.", USE_MULT);
                          $finish;
                      end
        endcase

        //-------- USE_PATTERN_DETECT

        case (USE_PATTERN_DETECT)
            "PATDET", "NO_PATDET" : ;
            default : begin
               $display("Attribute Syntax Error : The attribute USE_PATTERN_DETECT on DSP48E instance %m is set to %s.  Legal values for this attribute are PATDET or NO_PATDET.",  USE_PATTERN_DETECT);
               $finish;
            end
        endcase

        #100010 ping_opmode_drc_check <= 1;

    
//*********************************************************
//*** ADDITIONAL DRC  
//*********************************************************
// CR 219407  --  (1)
    if((AUTORESET_PATTERN_DETECT == "TRUE") && (USE_PATTERN_DETECT == "NO_PATDET")) begin
         $display("Attribute Syntax Error : The attribute USE_PATTERN_DETECT on DSP48E instance %m must be set to PATDET in order to use AUTORESET_PATTERN_DETECT equals TRUE. Failure to do so could make timing reports inaccurate. ");
     end

    end
    
//*********************************************************
//*** Input register A with 2 level deep of registers
//*********************************************************

    always @(acin_in or a_in) begin
	case (A_INPUT)
             "DIRECT" : a_o_mux <= a_in;
            "CASCADE" : a_o_mux <= acin_in;
              default : begin
	       	            $display("Attribute Syntax Error : The attribute A_INPUT on DSP48E instance %m is set to %s.  Legal values for this attribute are DIRECT or CASCADE.", A_INPUT);
		            $finish;
                        end
	endcase
    end

    always @(posedge clk_in) begin
	if (rsta_in) begin
            qa_o_reg1 <= 30'b0;
            qa_o_reg2 <= 30'b0;
        end
	else begin
               case (AREG)
                  1 :  if (cea2_in)
                           qa_o_reg2 <= a_o_mux;

                  2 : begin
                         if (cea1_in)
                            qa_o_reg1 <= a_o_mux;
                         if (cea2_in)
                            qa_o_reg2 <= qa_o_reg1;
                      end
                  default : ;
               endcase
        end
    end

    always @(a_o_mux or qa_o_reg1 or qa_o_reg2) begin
	case (AREG)
                  0   : qa_o_mux <= a_o_mux;
                  1,2 : qa_o_mux <= qa_o_reg2;
            default : begin
	                  $display("Attribute Syntax Error : The attribute AREG on DSP48E instance %m is set to %d.  Legal values for this attribute are 0, 1 or 2.", AREG);
	                  $finish;
	              end
	endcase
    end

    always @(qa_o_mux or qa_o_reg1 or qa_o_reg2) begin
        case (ACASCREG)
                  1 : if(AREG == 2)
                           qacout_o_mux <= qa_o_reg1;
                       else
                           qacout_o_mux <= qa_o_mux;
            default : qacout_o_mux <= qa_o_mux;
        endcase
    end

//*********************************************************
//*** Input register B with 2 level deep of registers
//*********************************************************

    always @(bcin_in or b_in) begin
	case (B_INPUT)
             "DIRECT" : b_o_mux <= b_in;
            "CASCADE" : b_o_mux <= bcin_in;
              default : begin
	       	            $display("Attribute Syntax Error : The attribute B_INPUT on DSP48E instance %m is set to %s.  Legal values for this attribute are DIRECT or CASCADE.", B_INPUT);
		            $finish;
                        end
	endcase
    end

    always @(posedge clk_in) begin
	if (rstb_in) begin
            qb_o_reg1 <= 18'b0;
            qb_o_reg2 <= 18'b0;
        end
	else begin
               case (BREG)
                  1 : if (ceb2_in)
                           qb_o_reg2 <= b_o_mux;

                  2 : begin
                         if (ceb1_in)
                            qb_o_reg1 <= b_o_mux;
                         if (ceb2_in)
                            qb_o_reg2 <= qb_o_reg1;
                      end
                  default : ;
               endcase
        end
    end

    always @(b_o_mux or qb_o_reg1 or qb_o_reg2) begin
	case (BREG)
                  0   : qb_o_mux <= b_o_mux;
                  1,2 : qb_o_mux <= qb_o_reg2;
            default : begin
	                  $display("Attribute Syntax Error : The attribute BREG on DSP48E instance %m is set to %d.  Legal values for this attribute are 0, 1 or 2.", BREG);
	                  $finish;
	              end
	endcase
    end

    always @(qb_o_mux or qb_o_reg1 or qb_o_reg2) begin
        case (BCASCREG)
                  1 : if(BREG == 2)
                           qbcout_o_mux <= qb_o_reg1;
                       else
                           qbcout_o_mux <= qb_o_mux;
            default : qbcout_o_mux <= qb_o_mux;
        endcase
    end

//*********************************************************
//*** Input register C with 1 level deep of register
//*********************************************************

    always @(posedge clk_in) begin
	if (rstc_in)
            qc_o_reg1 <= 48'b0;
	else if (cec_in)
            qc_o_reg1 <= c_in;
    end

    always @(c_in or qc_o_reg1) begin
	case (CREG)
                  0 : qc_o_mux <= c_in;
                  1 : qc_o_mux <= qc_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute CREG on DSP48E instance %m is set to %d.  Legal values for this attribute are 0 or 1.", CREG);
	                  $finish;
	              end
	endcase
    end

//*********************************************************
//***************      25x18 Multiplier     ***************
//*********************************************************
// 05/26/05 -- FP -- Added warning for invalid mult when USE_MULT=NONE
// SIMD=FOUR12 and SIMD=TWO24
// Made mult_o to be "X"

    always @(qopmode_o_mux) begin
       if(qopmode_o_mux[3:0] == 4'b0101)
          if((USE_MULT == "NONE") || (USE_SIMD == "TWO24") || (USE_SIMD == "FOUR12")) 
               $display("OPMODE Input Warning : The OPMODE[3:0] %b to DSP48E instance %m is invalid when using attributes USE_MULT = NONE, or USE_SIMD = TWO24 or FOUR12 at %.3f ns.", qopmode_o_mux[3:0], $time/1000.0);
    end

    assign mult_o = ((USE_MULT == "NONE") || (USE_SIMD == "TWO24") || (USE_SIMD == "FOUR12"))? 43'b0 : {{18{qa_o_mux[24]}}, qa_o_mux[24:0]} * {{25{qb_o_mux[17]}}, qb_o_mux};

    always @(posedge clk_in) begin
	if (rstm_in) begin
            qmult_o_reg <= 18'b0;
	end
	else if (cem_in) begin
            qmult_o_reg <= mult_o;
	end
    end

    always @(mult_o or qmult_o_reg) begin
	case (MREG)
                  0 : qmult_o_mux <= mult_o;
                  1 : qmult_o_mux <= qmult_o_reg;
            default : begin
	                  $display("Attribute Syntax Error : The attribute MREG on DSP48E instance %m is set to %d.  Legal values for this attribute are 0 or 1.", MREG);
	                  $finish;
	              end
	endcase
    end


//*** X mux
    
    always @(qp_o_mux or qa_o_mux or qb_o_mux or qmult_o_mux or qopmode_o_mux or qcarryinsel_o_mux) begin
	case (qopmode_o_mux[1:0])
              2'b00 : qx_o_mux <= 48'b0;
              2'b01 : qx_o_mux <= {{5{qmult_o_mux[MSB_A_MULT + MSB_B_MULT + 1]}}, qmult_o_mux};
              2'b10 : qx_o_mux <= qp_o_mux;
              2'b11 : qx_o_mux <= {qa_o_mux[MSB_A:0], qb_o_mux[MSB_B:0]};
            default : begin
	              end
	endcase
    end


//*** Y mux

    always @(qc_o_mux or qopmode_o_mux or qcarryinsel_o_mux or multsignin_in) begin
	case (qopmode_o_mux[3:2])
              2'b00 : qy_o_mux <= 48'b0;
              2'b01 : qy_o_mux <= 48'b0;

              2'b10 : if((qopmode_o_mux[6:4]) == 3'b100) 
                          qy_o_mux <= {48{multsignin_in}};
                      else
                          qy_o_mux <= 48'hFFFFFFFFFFFF;

              2'b11 : qy_o_mux <= qc_o_mux;
            default : begin
	              end
	endcase
    end


//*** Z mux

    always @(qp_o_mux or qc_o_mux or pcin_in or qopmode_o_mux or qcarryinsel_o_mux) begin
	case (qopmode_o_mux[6:4])
             3'b000 : qz_o_mux <= 48'b0;
             3'b001 : qz_o_mux <= pcin_in;
             3'b010 : qz_o_mux <= qp_o_mux;
             3'b011 : qz_o_mux <= qc_o_mux;
             3'b100 : qz_o_mux <= qp_o_mux; // Use for MACC extend -- multsignin
             3'b101 : qz_o_mux <= {{17{pcin_in[47]}}, pcin_in[47:17]};
             3'b110 : qz_o_mux <= {{17{qp_o_mux[47]}}, qp_o_mux[47:17]};
            default : begin
	              end
	endcase
    end



//*** CarryInSel and OpMode with 1 level of register
    always @(posedge clk_in) begin
	if (rstctrl_in) begin
            qcarryinsel_o_reg1 <= 3'b0;
            qopmode_o_reg1 <= 7'b0;
	end  
	else if (cectrl_in) begin
            qcarryinsel_o_reg1 <= carryinsel_in;
            qopmode_o_reg1 <= opmode_in;
	end
    end


    always @(carryinsel_in or qcarryinsel_o_reg1) begin
	case (CARRYINSELREG)
                  0 : qcarryinsel_o_mux <= carryinsel_in;
                  1 : qcarryinsel_o_mux <= qcarryinsel_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute CARRYINSELREG on DSP48E instance %m is set to %d.  Legal values for this attribute are 0 or 1.", CARRYINSELREG);
	                  $finish;
	              end
	endcase
    end

//CR 219047 (3) 

//    always @(qcarryinsel_o_mux or multsignin_in or qopmode_o_mux) begin
//    always @(carrycascin_in or multsignin_in or qopmode_o_mux) begin
    always @(qcarryinsel_o_mux or carrycascin_in or multsignin_in or qopmode_o_mux) begin
        if(qcarryinsel_o_mux == 3'b010) begin 
           if(!((multsignin_in === 1'bx) || ((qopmode_o_mux == 7'b1001000) && !(multsignin_in === 1'bx)) 
                                 || ((multsignin_in == 1'b0) && (carrycascin_in == 1'b0)))) begin
	      $display("DRC warning : CARRYCASCIN can only be used in the current DSP48E instance %m if the previous DSP48E is performing a two input ADD operation, or the current DSP48E is configured in the MAC extend opmode 7'b1001000 at %.3f ns.", $time);
            end  
        end  
    end 

//CR 219047 (4) 
    always @(qcarryinsel_o_mux) begin
       if((qcarryinsel_o_mux == 3'b110) && (MULTCARRYINREG != MREG)) begin
	  $display("Attribute Syntax Warning : It is recommended that MREG and MULTCARRYINREG on DSP48E instance %m be set to the same value when using CARRYINSEL = 110 for multiply rounding.");
       end
    end


    always @(opmode_in or qopmode_o_reg1) begin
	case (OPMODEREG)
                  0 : qopmode_o_mux <= opmode_in;
                  1 : qopmode_o_mux <= qopmode_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute OPMODEREG on DSP48E instance %m is set to %d.  Legal values for this attribute are 0 or 1.", OPMODEREG);
	                  $finish;
	              end
	endcase
    end



//*** ALUMODE with 1 level of register
    always @(posedge clk_in) begin
	if (rstalumode_in)
            qalumode_o_reg1 <= 4'b0;
	else if (cealumode_in)
            qalumode_o_reg1 <= alumode_in;
    end


    always @(alumode_in or qalumode_o_reg1) begin
	case (ALUMODEREG)
                  0 : qalumode_o_mux <= alumode_in;
                  1 : qalumode_o_mux <= qalumode_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute ALUMODEREG on DSP48E instance %m is set to %d.  Legal values for this attribute are 0 or 1.", ALUMODEREG);
	                  $finish;
	              end
	endcase
    end

    
//------------------------------------------------------------------
//*** DRC for OPMODE
//------------------------------------------------------------------

    always @(ping_opmode_drc_check or qalumode_o_mux or qopmode_o_mux or qcarryinsel_o_mux ) begin

      if ($time > 100000) begin  // no check at first 100ns
        case (qalumode_o_mux[3:2]) 
          2'b00 :
          //-- ARITHMETIC MODES DRC
            case ({qopmode_o_mux, qcarryinsel_o_mux})
                10'b0000000000 : deassign_xyz_mux;
                10'b0000010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0000010010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0000011000 : deassign_xyz_mux;
                10'b0000011010 : deassign_xyz_mux;
                10'b0000011100 : deassign_xyz_mux;
                10'b0000101000 : deassign_xyz_mux;
                10'b0001000000 : deassign_xyz_mux;
                10'b0001010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0001010010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0001011000 : deassign_xyz_mux;
                10'b0001011010 : deassign_xyz_mux;
                10'b0001011100 : deassign_xyz_mux;
                10'b0001100000 : deassign_xyz_mux;
                10'b0001100010 : deassign_xyz_mux;
                10'b0001100100 : deassign_xyz_mux;
                10'b0001110000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0001110010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0001110101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0001110111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0001111000 : deassign_xyz_mux;
                10'b0001111010 : deassign_xyz_mux;
                10'b0001111100 : deassign_xyz_mux;
                10'b0010000000 : deassign_xyz_mux;
                10'b0010010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0010010101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0010010111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0010011000 : deassign_xyz_mux;
                10'b0010011001 : deassign_xyz_mux;
                10'b0010011011 : deassign_xyz_mux;
                10'b0010101000 : deassign_xyz_mux;
                10'b0010101001 : deassign_xyz_mux;
                10'b0010101011 : deassign_xyz_mux;
                10'b0010101110 : deassign_xyz_mux;
                10'b0011000000 : deassign_xyz_mux;
                10'b0011010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0011010101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0011010111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0011011000 : deassign_xyz_mux;
                10'b0011011001 : deassign_xyz_mux;
                10'b0011011011 : deassign_xyz_mux;
                10'b0011100000 : deassign_xyz_mux;
                10'b0011100001 : deassign_xyz_mux;
                10'b0011100011 : deassign_xyz_mux;
                10'b0011110000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0011110101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0011110111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0011110001 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0011110011 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0011111000 : deassign_xyz_mux;
                10'b0011111001 : deassign_xyz_mux;
                10'b0011111011 : deassign_xyz_mux;
                10'b0100000000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100000010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100010010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100011000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100011010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100011101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100011111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100101000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100101101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100101111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101000000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101000010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101011000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101011101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101011111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101100000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101100010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101100101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101100111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101110000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101110101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101110111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101111000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101111101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101111111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0110000000 : deassign_xyz_mux;
                10'b0110000010 : deassign_xyz_mux;
                10'b0110000100 : deassign_xyz_mux;
                10'b0110010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0110010010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0110010101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0110010111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0110011000 : deassign_xyz_mux;
                10'b0110011010 : deassign_xyz_mux;
                10'b0110011100 : deassign_xyz_mux;
                10'b0110101000 : deassign_xyz_mux;
                10'b0110101110 : deassign_xyz_mux;
                10'b0111000000 : deassign_xyz_mux;
                10'b0111000010 : deassign_xyz_mux;
                10'b0111000100 : deassign_xyz_mux;
                10'b0111010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0111010101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0111010111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0111011000 : deassign_xyz_mux;
                10'b0111100000 : deassign_xyz_mux;
                10'b0111100010 : deassign_xyz_mux;
                10'b0111110000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0111111000 : deassign_xyz_mux;
                10'b1001000010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1010000000 : deassign_xyz_mux;
                10'b1010010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1010010101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1010010111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1010011000 : deassign_xyz_mux;
                10'b1010011001 : deassign_xyz_mux;
                10'b1010011011 : deassign_xyz_mux;
                10'b1010101000 : deassign_xyz_mux;
                10'b1010101001 : deassign_xyz_mux;
                10'b1010101011 : deassign_xyz_mux;
                10'b1010101110 : deassign_xyz_mux;
                10'b1011000000 : deassign_xyz_mux;
                10'b1011010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1011010101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1011010111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1011011000 : deassign_xyz_mux;
                10'b1011011001 : deassign_xyz_mux;
                10'b1011011011 : deassign_xyz_mux;
                10'b1011100000 : deassign_xyz_mux;
                10'b1011100001 : deassign_xyz_mux;
                10'b1011100011 : deassign_xyz_mux;
                10'b1011110000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1011110101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1011110111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1011110001 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1011110011 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1011111000 : deassign_xyz_mux;
                10'b1011111001 : deassign_xyz_mux;
                10'b1011111011 : deassign_xyz_mux;
                10'b1100000000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1100010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1100011000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1100011101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1100011111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1100101000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1100101101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1100101111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101000000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101011000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101011101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101011111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101100000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101100101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101100111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101110000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101110101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101110111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101111000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101111101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101111111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                default : begin
                              if (invalid_opmode) begin

                                  opmode_valid_flag = 0;
                                  invalid_opmode = 0;
                                  assign qx_o_mux = 48'bx;
                                  assign qy_o_mux = 48'bx;
                                  assign qz_o_mux = 48'bx;
                                  assign alu_o    = 48'bx;
// CR 452039
                                  $display("OPMODE Input Warning : The OPMODE %b to DSP48E instance %m is either invalid or the CARRYINSEL %b for that specific OPMODE is invalid at %.3f ns. This error may be due to a mismatch in the OPMODEREG and CARRYINSELREG attribute settings. It is recommended that OPMODEREG and CARRYINSELREG always be set to the same value. ", qopmode_o_mux, qcarryinsel_o_mux, $time/1000.0);

                              end
                          end

            endcase // case(opmode_in)

          2'b01, 2'b11 :
          //-- LOGIC MODES DRC
             case (qopmode_o_mux)
                7'b0000000 : deassign_xyz_mux;
                7'b0000010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0000011 : deassign_xyz_mux;
                7'b0010000 : deassign_xyz_mux;
                7'b0010010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0010011 : deassign_xyz_mux;
                7'b0100000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0100010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0100011 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0110000 : deassign_xyz_mux;
                7'b0110010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0110011 : deassign_xyz_mux;
                7'b1010000 : deassign_xyz_mux;
                7'b1010010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b1010011 : deassign_xyz_mux;
                7'b1100000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b1100010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b1100011 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0001000 : deassign_xyz_mux;
                7'b0001010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0001011 : deassign_xyz_mux;
                7'b0011000 : deassign_xyz_mux;
                7'b0011010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0011011 : deassign_xyz_mux;
                7'b0101000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0101010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0101011 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0111000 : deassign_xyz_mux;
                7'b0111010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0111011 : deassign_xyz_mux;
                7'b1011000 : deassign_xyz_mux;
                7'b1011010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b1011011 : deassign_xyz_mux;
                7'b1101000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b1101010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b1101011 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
              default : begin
                 if (invalid_opmode) begin

                    opmode_valid_flag = 0;
                    invalid_opmode = 0;
                    assign qx_o_mux = 48'bx;
                    assign qy_o_mux = 48'bx;
                    assign qz_o_mux = 48'bx;
                    assign alu_o    = 48'bx;
                    $display("OPMODE Input Warning : The OPMODE %b to DSP48E instance %m is invalid for LOGIC MODES at %.3f ns.", qopmode_o_mux, $time/1000.0);

                 end
              end

            endcase // case(opmode_in)

        endcase // case(qalumode_o_mux)

     end // if ($time > 100000)

    end // always @ (qopmode_o_mux)

//--####################################################################
//--#####                         ALU                              #####
//--####################################################################
 
    always @(qx_o_mux or qy_o_mux or qz_o_mux or qalumode_o_mux, qopmode_o_mux or qcarryin_o_mux) begin
	if (opmode_valid_flag) begin

           casex ({qopmode_o_mux[3:2], qalumode_o_mux})
              //---------  ADD --------------
              6'bXX0000 : begin

                 alumode_valid_flag = 1;

                 case (USE_SIMD)
                    "ONE48", "one48" : begin
                        // verilog will zero_pad qx, qy and qz before addition
	                alu_full_tmp = qz_o_mux + (qx_o_mux + qy_o_mux + qcarryin_o_mux);
                        alu_o = alu_full_tmp[MSB_ALU_FULL:0];
                        carrycascout_o = alu_full_tmp[MAX_ALU_FULL];
                        // -- if multiply operation then "X"out the carryout 
                        if((qopmode_o_mux[1:0] == 2'b01) || (qopmode_o_mux[3:2] == 2'b01))
                           carryout_o = 4'bx;
                        else begin
                           carryout_o[3]  = alu_full_tmp[MAX_ALU_FULL];
                           carryout_o[2]  = 1'bx;
                           carryout_o[1]  = 1'bx;
                           carryout_o[0]  = 1'bx;
                        end
                    end
                    "TWO24", "two24" : begin
		        alu_hlf1_tmp = qz_o_mux[((1*MAX_ALU_HALF)-1):0] + (qx_o_mux[((1*MAX_ALU_HALF)-1):0] +
                                       qy_o_mux[((1*MAX_ALU_HALF)-1):0] + qcarryin_o_mux);

		        alu_hlf2_tmp = qz_o_mux[((2*MAX_ALU_HALF)-1):(1*MAX_ALU_HALF)] + 
                                       (qx_o_mux[((2*MAX_ALU_HALF)-1):(1*MAX_ALU_HALF)] + 
                                       qy_o_mux[((2*MAX_ALU_HALF)-1):(1*MAX_ALU_HALF)] );

                        alu_o = { alu_hlf2_tmp[MSB_ALU_HALF:0], alu_hlf1_tmp[MSB_ALU_HALF:0]};

                        carrycascout_o = alu_hlf2_tmp[MAX_ALU_HALF];
                        // -- if multiply operation then "X"out the carryout 
                        if((qopmode_o_mux[1:0] == 2'b01) || (qopmode_o_mux[3:2] == 2'b01))
                           carryout_o = 4'bx;
                        else begin
                           carryout_o[3]  = alu_hlf2_tmp[MAX_ALU_HALF];
                           carryout_o[2]  = 1'bx;
                           carryout_o[1]  = alu_hlf1_tmp[MAX_ALU_HALF];
                           carryout_o[0]  = 1'bx;
                        end
                    end
                    "FOUR12", "four12" : begin
		        alu_qrt1_tmp = qz_o_mux[((1*MAX_ALU_QUART)-1):0] + (qx_o_mux[((1*MAX_ALU_QUART)-1):0] +
                                       qy_o_mux[((1*MAX_ALU_QUART)-1):0] + qcarryin_o_mux);

		        alu_qrt2_tmp = qz_o_mux[((2*MAX_ALU_QUART)-1):(1*MAX_ALU_QUART)] + 
                                       (qx_o_mux[((2*MAX_ALU_QUART)-1):(1*MAX_ALU_QUART)] + 
                                       qy_o_mux[((2*MAX_ALU_QUART)-1):(1*MAX_ALU_QUART)] );

		        alu_qrt3_tmp = qz_o_mux[((3*MAX_ALU_QUART)-1):(2*MAX_ALU_QUART)] + 
                                       (qx_o_mux[((3*MAX_ALU_QUART)-1):(2*MAX_ALU_QUART)] + 
                                       qy_o_mux[((3*MAX_ALU_QUART)-1):(2*MAX_ALU_QUART)] );

		        alu_qrt4_tmp = qz_o_mux[((4*MAX_ALU_QUART)-1):(3*MAX_ALU_QUART)] + 
                                       (qx_o_mux[((4*MAX_ALU_QUART)-1):(3*MAX_ALU_QUART)] + 
                                       qy_o_mux[((4*MAX_ALU_QUART)-1):(3*MAX_ALU_QUART)] );

                        alu_o = { alu_qrt4_tmp[MSB_ALU_QUART:0], alu_qrt3_tmp[MSB_ALU_QUART:0], 
                                  alu_qrt2_tmp[MSB_ALU_QUART:0], alu_qrt1_tmp[MSB_ALU_QUART:0]};

                        carrycascout_o = alu_qrt4_tmp[MAX_ALU_QUART];
                        // -- if multiply operation then "X"out the carryout 
                        if((qopmode_o_mux[1:0] == 2'b01) || (qopmode_o_mux[3:2] == 2'b01))
                           carryout_o = 4'bx;
                        else begin
                           carryout_o[3]  = alu_qrt4_tmp[MAX_ALU_QUART];
                           carryout_o[2]  = alu_qrt3_tmp[MAX_ALU_QUART];
                           carryout_o[1]  = alu_qrt2_tmp[MAX_ALU_QUART];
                           carryout_o[0]  = alu_qrt1_tmp[MAX_ALU_QUART];
                        end

                    end
                    default : begin
                        $display("Attribute Syntax Error : The attribute USE_SIMD on DSP48E instance %m is set to %s. Legal values for this attribute are  ONE48 or TWO24 or FOUR12.", USE_SIMD);
                        $finish;
                    end
                 endcase
              end
              //----------------- SUBTRACT (X + ~Z ) carryin must be 1 ---------------
              6'bXX0001 : begin

                 alumode_valid_flag = 1;

                 case (USE_SIMD)
                    "ONE48", "one48" : begin
                        // verilog will zero_pad qx, qy and qz before inversing/addition
	                alu_full_tmp = ~qz_o_mux + (qx_o_mux + qy_o_mux + qcarryin_o_mux);
                        alu_o = alu_full_tmp[MSB_ALU_FULL:0];
                        carrycascout_o = ~alu_full_tmp[MAX_ALU_FULL];
                        // -- if multiply operation then "X"out the carryout 
                        if((qopmode_o_mux[1:0] == 2'b01) || (qopmode_o_mux[3:2] == 2'b01))
                           carryout_o = 4'bx;
                        else begin
                           carryout_o[3]  = ~alu_full_tmp[MAX_ALU_FULL];
                           carryout_o[2]  = 1'bx;
                           carryout_o[1]  = 1'bx;
                           carryout_o[0]  = 1'bx;
                        end
                    end
                    "TWO24", "two24" : begin
		        alu_hlf1_tmp = ~qz_o_mux[((1*MAX_ALU_HALF)-1):0] + (qx_o_mux[((1*MAX_ALU_HALF)-1):0] +
                                       qy_o_mux[((1*MAX_ALU_HALF)-1):0] + qcarryin_o_mux);

		        alu_hlf2_tmp = ~qz_o_mux[((2*MAX_ALU_HALF)-1):(1*MAX_ALU_HALF)] + 
                                       (qx_o_mux[((2*MAX_ALU_HALF)-1):(1*MAX_ALU_HALF)] + 
                                       qy_o_mux[((2*MAX_ALU_HALF)-1):(1*MAX_ALU_HALF)] );

                        alu_o = { alu_hlf2_tmp[MSB_ALU_HALF:0], alu_hlf1_tmp[MSB_ALU_HALF:0]};

                        carrycascout_o = ~alu_hlf2_tmp[MAX_ALU_HALF];
                        // -- if multiply operation then "X"out the carryout 
                        if((qopmode_o_mux[1:0] == 2'b01) || (qopmode_o_mux[3:2] == 2'b01))
                           carryout_o = 4'bx;
                        else begin
                           carryout_o[3]  = ~alu_hlf2_tmp[MAX_ALU_HALF];
                           carryout_o[2]  = 1'bx;
                           carryout_o[1]  = ~alu_hlf1_tmp[MAX_ALU_HALF];
                           carryout_o[0]  = 1'bx;
                        end
                    end
                    "FOUR12", "four12" : begin
		        alu_qrt1_tmp = ~qz_o_mux[((1*MAX_ALU_QUART)-1):0] + (qx_o_mux[((1*MAX_ALU_QUART)-1):0] +
                                       qy_o_mux[((1*MAX_ALU_QUART)-1):0] + qcarryin_o_mux);

		        alu_qrt2_tmp = ~qz_o_mux[((2*MAX_ALU_QUART)-1):(1*MAX_ALU_QUART)] + 
                                       (qx_o_mux[((2*MAX_ALU_QUART)-1):(1*MAX_ALU_QUART)] + 
                                       qy_o_mux[((2*MAX_ALU_QUART)-1):(1*MAX_ALU_QUART)] );

		        alu_qrt3_tmp = ~qz_o_mux[((3*MAX_ALU_QUART)-1):(2*MAX_ALU_QUART)] + 
                                       (qx_o_mux[((3*MAX_ALU_QUART)-1):(2*MAX_ALU_QUART)] + 
                                       qy_o_mux[((3*MAX_ALU_QUART)-1):(2*MAX_ALU_QUART)] );

		        alu_qrt4_tmp = ~qz_o_mux[((4*MAX_ALU_QUART)-1):(3*MAX_ALU_QUART)] + 
                                       (qx_o_mux[((4*MAX_ALU_QUART)-1):(3*MAX_ALU_QUART)] + 
                                       qy_o_mux[((4*MAX_ALU_QUART)-1):(3*MAX_ALU_QUART)] );

                        alu_o = { alu_qrt4_tmp[MSB_ALU_QUART:0], alu_qrt3_tmp[MSB_ALU_QUART:0], 
                                  alu_qrt2_tmp[MSB_ALU_QUART:0], alu_qrt1_tmp[MSB_ALU_QUART:0]};

                        carrycascout_o = ~alu_qrt4_tmp[MAX_ALU_QUART];
                        // -- if multiply operation then "X"out the carryout 
                        if((qopmode_o_mux[1:0] == 2'b01) || (qopmode_o_mux[3:2] == 2'b01))
                           carryout_o = 4'bx;
                        else begin
                           carryout_o[3]  = ~alu_qrt4_tmp[MAX_ALU_QUART];
                           carryout_o[2]  = ~alu_qrt3_tmp[MAX_ALU_QUART];
                           carryout_o[1]  = ~alu_qrt2_tmp[MAX_ALU_QUART];
                           carryout_o[0]  = ~alu_qrt1_tmp[MAX_ALU_QUART];
                        end

                    end
                    default : begin
                        $display("Attribute Syntax Error : The attribute USE_SIMD on DSP48E instance %m is set to %s. Legal values for this attribute are  ONE48 or TWO24 or FOUR12.", USE_SIMD);
                        $finish;
                    end
                 endcase
              end

              //----------------- NOT (X + Z) ----------------------------------------
              6'bXX0010 : begin

                 alumode_valid_flag = 1;

                 case (USE_SIMD)
                    "ONE48", "one48" : begin
	                alu_full_tmp = ~(qz_o_mux + (qx_o_mux + qy_o_mux + qcarryin_o_mux));
                        alu_o = alu_full_tmp[MSB_ALU_FULL:0];
                        carrycascout_o = ~alu_full_tmp[MAX_ALU_FULL];
                        // -- if multiply operation then "X"out the carryout 
                        if((qopmode_o_mux[1:0] == 2'b01) || (qopmode_o_mux[3:2] == 2'b01))
                           carryout_o = 4'bx;
                        else begin
                           carryout_o[3]  = ~alu_full_tmp[MAX_ALU_FULL];
                           carryout_o[2]  = 1'bx;
                           carryout_o[1]  = 1'bx;
                           carryout_o[0]  = 1'bx;
                        end
                    end
                    "TWO24", "two24" : begin
		        alu_hlf1_tmp = ~(qz_o_mux[((1*MAX_ALU_HALF)-1):0] + (qx_o_mux[((1*MAX_ALU_HALF)-1):0] +
                                       qy_o_mux[((1*MAX_ALU_HALF)-1):0] + qcarryin_o_mux));

		        alu_hlf2_tmp = ~(qz_o_mux[((2*MAX_ALU_HALF)-1):(1*MAX_ALU_HALF)] + 
                                       (qx_o_mux[((2*MAX_ALU_HALF)-1):(1*MAX_ALU_HALF)] + 
                                       qy_o_mux[((2*MAX_ALU_HALF)-1):(1*MAX_ALU_HALF)] ));

                        alu_o = { alu_hlf2_tmp[MSB_ALU_HALF:0], alu_hlf1_tmp[MSB_ALU_HALF:0]};

                        carrycascout_o = ~alu_hlf2_tmp[MAX_ALU_HALF];
                        // -- if multiply operation then "X"out the carryout 
                        if((qopmode_o_mux[1:0] == 2'b01) || (qopmode_o_mux[3:2] == 2'b01))
                           carryout_o = 4'bx;
                        else begin
                           carryout_o[3]  = ~alu_hlf2_tmp[MAX_ALU_HALF];
                           carryout_o[2]  = 1'bx;
                           carryout_o[1]  = ~alu_hlf1_tmp[MAX_ALU_HALF];
                           carryout_o[0]  = 1'bx;
                        end
                    end
                    "FOUR12", "four12" : begin
		        alu_qrt1_tmp = ~(qz_o_mux[((1*MAX_ALU_QUART)-1):0] + (qx_o_mux[((1*MAX_ALU_QUART)-1):0] +
                                       qy_o_mux[((1*MAX_ALU_QUART)-1):0] + qcarryin_o_mux));

		        alu_qrt2_tmp = ~(qz_o_mux[((2*MAX_ALU_QUART)-1):(1*MAX_ALU_QUART)] + 
                                       (qx_o_mux[((2*MAX_ALU_QUART)-1):(1*MAX_ALU_QUART)] + 
                                       qy_o_mux[((2*MAX_ALU_QUART)-1):(1*MAX_ALU_QUART)] ));

		        alu_qrt3_tmp = ~(qz_o_mux[((3*MAX_ALU_QUART)-1):(2*MAX_ALU_QUART)] + 
                                       (qx_o_mux[((3*MAX_ALU_QUART)-1):(2*MAX_ALU_QUART)] + 
                                       qy_o_mux[((3*MAX_ALU_QUART)-1):(2*MAX_ALU_QUART)] ));

		        alu_qrt4_tmp = ~(qz_o_mux[((4*MAX_ALU_QUART)-1):(3*MAX_ALU_QUART)] + 
                                       (qx_o_mux[((4*MAX_ALU_QUART)-1):(3*MAX_ALU_QUART)] + 
                                       qy_o_mux[((4*MAX_ALU_QUART)-1):(3*MAX_ALU_QUART)] ));

                        alu_o = { alu_qrt4_tmp[MSB_ALU_QUART:0], alu_qrt3_tmp[MSB_ALU_QUART:0], 
                                  alu_qrt2_tmp[MSB_ALU_QUART:0], alu_qrt1_tmp[MSB_ALU_QUART:0]};

                        carrycascout_o = ~alu_qrt4_tmp[MAX_ALU_QUART];
                        // -- if multiply operation then "X"out the carryout 
                        if((qopmode_o_mux[1:0] == 2'b01) || (qopmode_o_mux[3:2] == 2'b01))
                           carryout_o = 4'bx;
                        else begin
                           carryout_o[3]  = ~alu_qrt4_tmp[MAX_ALU_QUART];
                           carryout_o[2]  = ~alu_qrt3_tmp[MAX_ALU_QUART];
                           carryout_o[1]  = ~alu_qrt2_tmp[MAX_ALU_QUART];
                           carryout_o[0]  = ~alu_qrt1_tmp[MAX_ALU_QUART];
                        end

                    end
                    default : begin
                        $display("Attribute Syntax Error : The attribute USE_SIMD on DSP48E instance %m is set to %s. Legal values for this attribute are  ONE48 or TWO24 or FOUR12.", USE_SIMD);
                        $finish;
                    end
                 endcase
              end
              //----------------- SUBTRACT (Z - X)  ----------------------------------
              6'bXX0011 : begin

                 alumode_valid_flag = 1;

                 case (USE_SIMD)
                    "ONE48", "one48" : begin
		        alu_full_tmp = qz_o_mux - (qx_o_mux + qy_o_mux + qcarryin_o_mux);
                        alu_o = alu_full_tmp[MSB_ALU_FULL:0];
                        carrycascout_o = alu_full_tmp[MAX_ALU_FULL];
                        // -- if multiply operation then "X"out the carryout 
                        if((qopmode_o_mux[1:0] == 2'b01) || (qopmode_o_mux[3:2] == 2'b01))
                           carryout_o = 4'bx;
                        else begin
                           carryout_o[3]  = ~alu_full_tmp[MAX_ALU_FULL];
                           carryout_o[2]  = 1'bx;
                           carryout_o[1]  = 1'bx;
                           carryout_o[0]  = 1'bx;
                        end
                    end
                    "TWO24", "two24" : begin
		        alu_hlf1_tmp = qz_o_mux[((1*MAX_ALU_HALF)-1):0] - (qx_o_mux[((1*MAX_ALU_HALF)-1):0] +
                                       qy_o_mux[((1*MAX_ALU_HALF)-1):0] + qcarryin_o_mux);

		        alu_hlf2_tmp = qz_o_mux[((2*MAX_ALU_HALF)-1):(1*MAX_ALU_HALF)] - 
                                       (qx_o_mux[((2*MAX_ALU_HALF)-1):(1*MAX_ALU_HALF)] + 
                                       qy_o_mux[((2*MAX_ALU_HALF)-1):(1*MAX_ALU_HALF)] );

                        alu_o = { alu_hlf2_tmp[MSB_ALU_HALF:0], alu_hlf1_tmp[MSB_ALU_HALF:0]};

                        carrycascout_o = alu_hlf2_tmp[MAX_ALU_HALF];
                        // -- if multiply operation then "X"out the carryout 
                        if((qopmode_o_mux[1:0] == 2'b01) || (qopmode_o_mux[3:2] == 2'b01))
                           carryout_o = 4'bx;
                        else begin
                           carryout_o[3]  = ~alu_hlf2_tmp[MAX_ALU_HALF];
                           carryout_o[2]  = 1'bx;
                           carryout_o[1]  = ~alu_hlf1_tmp[MAX_ALU_HALF];
                           carryout_o[0]  = 1'bx;
                        end
                    end
                    "FOUR12", "four12" : begin
	      	        alu_qrt1_tmp = qz_o_mux[((1*MAX_ALU_QUART)-1):0] - (qx_o_mux[((1*MAX_ALU_QUART)-1):0] +
                                       qy_o_mux[((1*MAX_ALU_QUART)-1):0] + qcarryin_o_mux);

		        alu_qrt2_tmp = qz_o_mux[((2*MAX_ALU_QUART)-1):(1*MAX_ALU_QUART)] - 
                                       (qx_o_mux[((2*MAX_ALU_QUART)-1):(1*MAX_ALU_QUART)] + 
                                       qy_o_mux[((2*MAX_ALU_QUART)-1):(1*MAX_ALU_QUART)] );

		        alu_qrt3_tmp = qz_o_mux[((3*MAX_ALU_QUART)-1):(2*MAX_ALU_QUART)] - 
                                       (qx_o_mux[((3*MAX_ALU_QUART)-1):(2*MAX_ALU_QUART)] + 
                                       qy_o_mux[((3*MAX_ALU_QUART)-1):(2*MAX_ALU_QUART)] );

		        alu_qrt4_tmp = qz_o_mux[((4*MAX_ALU_QUART)-1):(3*MAX_ALU_QUART)] - 
                                       (qx_o_mux[((4*MAX_ALU_QUART)-1):(3*MAX_ALU_QUART)] + 
                                       qy_o_mux[((4*MAX_ALU_QUART)-1):(3*MAX_ALU_QUART)] );

                        alu_o = { alu_qrt4_tmp[MSB_ALU_QUART:0], alu_qrt3_tmp[MSB_ALU_QUART:0], 
                                  alu_qrt2_tmp[MSB_ALU_QUART:0], alu_qrt1_tmp[MSB_ALU_QUART:0]};

                        carrycascout_o = alu_qrt4_tmp[MAX_ALU_QUART];
                        // -- if multiply operation then "X"out the carryout 
                        if((qopmode_o_mux[1:0] == 2'b01) || (qopmode_o_mux[3:2] == 2'b01))
                           carryout_o = 4'bx;
                        else begin
                           carryout_o[3]  = ~alu_qrt4_tmp[MAX_ALU_QUART];
                           carryout_o[2]  = ~alu_qrt3_tmp[MAX_ALU_QUART];
                           carryout_o[1]  = ~alu_qrt2_tmp[MAX_ALU_QUART];
                           carryout_o[0]  = ~alu_qrt1_tmp[MAX_ALU_QUART];
                        end

                    end
                    default : begin
                        $display("Attribute Syntax Error : The attribute USE_SIMD on DSP48E instance %m is set to %s. Legal values for this attribute are  ONE48 or TWO24 or FOUR12.", USE_SIMD);
                        $finish;
                    end
                 endcase
              end
//----------------------------------------------------------
              //--------------- XOR ------------------
              6'b000100, 6'b000111, 6'b100101, 6'b100110 : begin
                    alu_o = qx_o_mux ^ qz_o_mux;
                    carryout_o = 4'bx;
                    carrycascout_o = 1'bx; 
                    alumode_valid_flag = 1;
              end

              //--------------- XNOR ------------------
              6'b000101, 6'b000110, 6'b100100, 6'b100111 : begin
                    alu_o = qx_o_mux ~^ qz_o_mux;
                    carryout_o = 4'bx;
                    carrycascout_o = 1'bx; 
                    alumode_valid_flag = 1;
              end
//----------------------------------------------------------

           //--------------- AND ------------------
              6'b001100 : begin
                    alu_o = qx_o_mux & qz_o_mux;
                    carryout_o = 4'bx;
                    carrycascout_o = 1'bx; 
                    alumode_valid_flag = 1;
              end

              //--------------- X AND (NOT Z) ------------------
              6'b001101 : begin
                    alu_o = qx_o_mux & (~qz_o_mux);
                    carryout_o = 4'bx;
                    carrycascout_o = 1'bx; 
                    alumode_valid_flag = 1;
              end

              //--------------- X NAND Z ------------------
              6'b001110 : begin
                    alu_o = ~(qx_o_mux & qz_o_mux);
                    carryout_o = 4'bx;
                    carrycascout_o = 1'bx; 
                    alumode_valid_flag = 1;
              end

              //--------------- (NOT X) OR Z ------------------
              6'b001111 : begin
                    alu_o = (~qx_o_mux) | (qz_o_mux);
                    carryout_o = 4'bx;
                    carrycascout_o = 1'bx; 
                    alumode_valid_flag = 1;
              end
//----------------------------------------------------------

              //--------------- X OR Z ------------------
              6'b101100 : begin
                    alu_o = qx_o_mux | qz_o_mux;
                    carryout_o = 4'bx;
                    carrycascout_o = 1'bx; 
                    alumode_valid_flag = 1;
              end

              //--------------- X OR ~Z ------------------
              6'b101101 : begin
                    alu_o = (qx_o_mux) |  (~qz_o_mux);
                    carryout_o = 4'bx;
                    carrycascout_o = 1'bx; 
                    alumode_valid_flag = 1;
              end

              //--------------- X NOR Z ------------------
              6'b101110 : begin
                    alu_o = ~((qx_o_mux) | (qz_o_mux));
                    carryout_o = 4'bx;
                    carrycascout_o = 1'bx; 
                    alumode_valid_flag = 1;
              end

              //--------------- (NOT X) and Z ------------------
              6'b101111 : begin
                    alu_o = (~qx_o_mux) & (qz_o_mux);
                    carryout_o = 4'bx;
                    carrycascout_o = 1'bx; 
                    alumode_valid_flag = 1;
              end

//----------------------------------------------------------
//----------------------------------------------------------

              default : begin 
                    alu_o = 48'bx;
                    carryout_o = 4'bx;
                    carrycascout_o = 1'bx; 

                    alumode_valid_flag = 0;

                    $display("ALUMODE Input Warning : The ALUMODE %b to DSP48E instance %m is either invalid or the OPMODE %b for that specific ALUMODE is invalid at %.3f ns.", qalumode_o_mux, qopmode_o_mux, $time/1000.0);
              end
           endcase

        end

    end // always @ (qalumode_o_mux)
    
    task deassign_xyz_mux;
	begin
	    opmode_valid_flag = 1;
	    invalid_opmode = 1;  // reset invalid opmode
	    deassign qx_o_mux;
	    deassign qy_o_mux;
	    deassign qz_o_mux;
	    deassign alu_o;
	end
    endtask // deassign_xyz_mux

    task display_invalid_opmode_no_mreg;
	begin
	    if (invalid_opmode) begin
		
		opmode_valid_flag = 0;
		invalid_opmode = 0;
		assign qx_o_mux = 48'bx;
		assign qy_o_mux = 48'bx;
		assign qz_o_mux = 48'bx;
		assign alu_o = 48'bx;
		$display("OPMODE Input Warning : The OPMODE %b with CARRYINSEL %b to DSP48E instance %m at %.3f ns requires attribute MREG set to 0.", qopmode_o_mux, qcarryinsel_o_mux, $time/1000.0);
	    end
	end
    endtask // display_invalid_opmode_no_mreg

    task display_invalid_opmode_mreg;
	begin
	    if (invalid_opmode) begin
		opmode_valid_flag = 0;
		invalid_opmode = 0;
		assign qx_o_mux = 48'bx;
		assign qy_o_mux = 48'bx;
		assign qz_o_mux = 48'bx;
		assign alu_o = 48'bx;
		$display("OPMODE Input Warning : The OPMODE %b with CARRYINSEL %b to DSP48E instance %m at %.3f ns requires attribute MREG set to 1.", qopmode_o_mux, qcarryinsel_o_mux, $time/1000.0);
	    end
	end
    endtask // display_invalid_opmode_mreg
    
    task display_invalid_opmode;
	begin
	    if (invalid_opmode) begin
		opmode_valid_flag = 0;
		invalid_opmode = 0;
		assign qx_o_mux = 48'bx;
		assign qy_o_mux = 48'bx;
		assign qz_o_mux = 48'bx;
		assign alu_o = 48'bx;
		$display("OPMODE Input Warning : The OPMODE %b to DSP48E instance %m at %.3f ns requires attribute PREG set to 1.", qopmode_o_mux, $time/1000.0);
	    end
	end
    endtask // display_invalid_opmode
    
    
//*** CarryIn Mux and Register

//-------  input 0
    always @(posedge clk_in) begin
	if (rstallcarryin_in)
            qcarryin_o_reg0 <= 1'b0;
	else if (cecarryin_in)
            qcarryin_o_reg0 <= carryin_in;
    end

    always @(carryin_in or qcarryin_o_reg0) begin
	case (CARRYINREG)
                  0 : qcarryin_o_mux0 <= carryin_in;
                  1 : qcarryin_o_mux0 <= qcarryin_o_reg0;
            default : begin
	                  $display("Attribute Syntax Error : The attribute CARRYINREG on DSP48E instance %m is set to %d.  Legal values for this attribute are 0 or 1.", CARRYINREG);
	                  $finish;
	              end
	endcase
    end

//-------  input 7
    always @(posedge clk_in) begin
	if (rstallcarryin_in)
            qcarryin_o_reg7 <= 1'b0;
	else if (cemultcarryin_in)
            qcarryin_o_reg7 <=  qa_o_mux[24] ~^ qb_o_mux[17];  // xnor
    end

    always @(qa_o_mux[24] or qb_o_mux[17] or qcarryin_o_reg7) begin
	case (MULTCARRYINREG)
                  0 : qcarryin_o_mux7 <= qa_o_mux[24] ~^ qb_o_mux[17];
                  1 : qcarryin_o_mux7 <= qcarryin_o_reg7;
            default : begin
	                  $display("Attribute Syntax Error : The attribute MULTCARRYINREG on DSP48E instance %m is set to %d.  Legal values for this attribute are 0 or 1.", MULTCARRYINREG);
	                  $finish;
	              end
	endcase
    end
   

    always @(qcarryin_o_mux0 or pcin_in[47] or carrycascin_in or carrycascout_o_mux or qp_o_mux[47], qcarryin_o_mux7, qcarryinsel_o_mux) begin
	case (qcarryinsel_o_mux)
              3'b000 : qcarryin_o_mux <= qcarryin_o_mux0;
              3'b001 : qcarryin_o_mux <= ~pcin_in[47];
              3'b010 : qcarryin_o_mux <= carrycascin_in;
              3'b011 : qcarryin_o_mux <= pcin_in[47];
              3'b100 : qcarryin_o_mux <= carrycascout_o_mux;
              3'b101 : qcarryin_o_mux <= ~qp_o_mux[47];
              3'b110 : qcarryin_o_mux <= qcarryin_o_mux7;
              3'b111 : qcarryin_o_mux <= qp_o_mux[47];
            default : begin
	              end
	endcase
    end
//--####################################################################
//--#####             CARRYOUT and CARRYCASCOUT                    #####
//--####################################################################
//*** register with 1 level of register
    always @(posedge clk_in) begin
        if ((rstp_in) ||
            ((AUTORESET_PATTERN_DETECT == "TRUE") && (
              ((AUTORESET_PATTERN_DETECT_OPTINV == "MATCH") && pdet_o_reg1) ||
              ((AUTORESET_PATTERN_DETECT_OPTINV == "NOT_MATCH") && (pdet_o_reg2 && !pdet_o_reg1)))
            )
           ) begin
               carrycascout_o_reg <= 1'b0;
               carryout_o_reg     <= 4'b0;
             end
        else if (cep_in) begin
                   carrycascout_o_reg <= carrycascout_o;
                   carryout_o_reg     <= carryout_o;
             end
    end

    always @(carryout_o or carryout_o_reg) begin
        case (PREG)
                  0 : carryout_o_mux <= carryout_o;
                  1 : carryout_o_mux <= carryout_o_reg;
            default : begin
//                          $display("Attribute Syntax Error : The attribute PREG on DSP48E instance %m is set to %d.  Legal values for this attribute are 0 or 1.", PREG);
//                          $finish;
                      end
        endcase
    end

    always @(carrycascout_o or carrycascout_o_reg) begin
        case (PREG)
                  0 : carrycascout_o_mux <= carrycascout_o;
                  1 : carrycascout_o_mux <= carrycascout_o_reg;
            default : begin
//                          $display("Attribute Syntax Error : The attribute PREG on DSP48E instance %m is set to %d.  Legal values for this attribute are 0 or 1.", PREG);
//                          $finish;
                      end
        endcase
    end

//CR 219047 (2)

    always @(qmult_o_mux[(MSB_A_MULT+MSB_B_MULT+1)] or qopmode_o_mux[3:0]) begin
        if(qopmode_o_mux[3:0] == 4'b0101)
           multsignout_o_opmode = qmult_o_mux[(MSB_A_MULT+MSB_B_MULT+1)];
        else
           multsignout_o_opmode = 1'bx;
    end 


    always @(multsignout_o_opmode or qmultsignout_o_reg) begin
        case (PREG)
                  0 : multsignout_o_mux <= multsignout_o_opmode;
                  1 : multsignout_o_mux <= qmultsignout_o_reg;

            default : begin
//                          $display("Attribute Syntax Error : The attribute PREG on DSP48E instance %m is set to %d.  Legal values for this attribute are 0 or 1.", PREG);
//                          $finish;
                      end
        endcase
    end

    assign carryout_x_o[3] =  carryout_o_mux[3];
    assign carryout_x_o[2] = (USE_SIMD == "FOUR12") ? carryout_o_mux[2] : 1'bx;
    assign carryout_x_o[1] = ((USE_SIMD == "TWO24") ||  (USE_SIMD == "FOUR12")) ? carryout_o_mux[1] : 1'bx;
    assign carryout_x_o[0] = (USE_SIMD == "FOUR12") ? carryout_o_mux[0] : 1'bx;

//--####################################################################
//--#####                    PCOUT and MULTSIGNOUT                 #####
//--####################################################################
//*** Output register P with 1 level of register
    always @(posedge clk_in) begin
	if ((rstp_in) || 
            ((AUTORESET_PATTERN_DETECT == "TRUE") && (
              ((AUTORESET_PATTERN_DETECT_OPTINV == "MATCH") && pdet_o_reg1) ||
              ((AUTORESET_PATTERN_DETECT_OPTINV == "NOT_MATCH") && (pdet_o_reg2 && !pdet_o_reg1))) 
            )
           )
         begin
           qp_o_reg1 <= 48'b0;
           qmultsignout_o_reg <= 1'b0;
        end 
	else if (cep_in) begin
                  qp_o_reg1 <= alu_o;
                  qmultsignout_o_reg <= multsignout_o_opmode;
             end
    end
 
    always @(qp_o_reg1 or alu_o) begin
	case (PREG)
                  0 : qp_o_mux <= alu_o;
                  1 : qp_o_mux <= qp_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute PREG on DSP48E instance %m is set to %d.  Legal values for this attribute are 0 or 1.", PREG);
	                  $finish;
	              end
	endcase
    end

//--####################################################################
//--#####                    Pattern Detector                      #####
//--####################################################################
    assign pdet_o_mux  = ((USE_PATTERN_DETECT == "NO_PATDET") | ~opmode_valid_flag | ~alumode_valid_flag) ? 1'bx : (PREG == 1) ? pdet_o_reg1 : pdet_o;
    assign pdetb_o_mux = ((USE_PATTERN_DETECT == "NO_PATDET") | ~opmode_valid_flag | ~alumode_valid_flag) ? 1'bx : (PREG == 1) ? pdetb_o_reg1 : pdetb_o;

    always @(alu_o, qc_o_mux, negedge gsr_in) begin

        //-- Select the pattern
        case(SEL_PATTERN)
           "PATTERN" : pattern_qp <= PATTERN;
           "C"       : pattern_qp <= qc_o_mux;
            default : begin
                         $display("Attribute Syntax Error : The attribute SEL_PATTERN on DSP48E instance %m is set to %s.  Legal values for this attribute are PATTERN or C.", SEL_PATTERN);
                         $finish;
                      end
	endcase

        //-- Select the mask  -- if ROUNDING MASK set, use rounding mode, else use SEL_MASK 
        case(SEL_ROUNDING_MASK)
           "SEL_MASK" : 
               case(SEL_MASK)
                  "MASK" : mask_qp <= MASK;
                  "C"    : mask_qp <= qc_o_mux;
                   default : begin
                                $display("Attribute Syntax Error : The attribute SEL_MASK on DSP48E instance %m is set to %s.  Legal values for this attribute are MASK or C.", SEL_MASK);
                                $finish;
                             end
       	       endcase
           "MODE1" :  mask_qp     <=   ~qc_o_mux << 1;
           "MODE2" :  mask_qp     <=   ~qc_o_mux << 2;
            default : begin
                         $display("Attribute Syntax Error : The attribute SEL_ROUNDING_MASK on DSP48E instance %m is set to %s.  Legal values for this attribute are SEL_MASK or MODE1 or MODE2.", SEL_ROUNDING_MASK);
                         $finish;
                      end
        endcase
                    
    end

        //--  now do the pattern detection
        
    always @(alu_o, mask_qp, pattern_qp, gsr_in) begin
        if((alu_o |  mask_qp) == (pattern_qp | mask_qp))
          pdet_o <= 1'b1;
        else 
          pdet_o <= 1'b0;
       
        if((alu_o |  mask_qp) == (~pattern_qp | mask_qp))
          pdetb_o <= 1'b1;
        else 
          pdetb_o <= 1'b0;
    end

//*** Output register PATTERN DETECT and UNDERFLOW / OVERFLOW 
    always @(posedge clk_in) begin
        if((rstp_in) ||
            ((AUTORESET_PATTERN_DETECT == "TRUE") && (
              ((AUTORESET_PATTERN_DETECT_OPTINV == "MATCH") && pdet_o_reg1) ||
              ((AUTORESET_PATTERN_DETECT_OPTINV == "NOT_MATCH") && (pdet_o_reg2 && !pdet_o_reg1)))
            )
          )
          begin 
            pdet_o_reg1  <= 1'b0;
            pdet_o_reg2  <= 1'b0;
            pdetb_o_reg1 <= 1'b0;
            pdetb_o_reg2 <= 1'b0;
          end
	else if(cep_in)
               begin
                 //-- the previous values are used in Underflow/Overflow
                 pdet_o_reg2  <= pdet_o_reg1;
                 pdet_o_reg1  <= pdet_o;
                 pdetb_o_reg2 <= pdetb_o_reg1;
                 pdetb_o_reg1 <= pdetb_o;
               end
    end
 
//--####################################################################
//--#####                    Underflow / Overflow                  #####
//--####################################################################
    always @(pdet_o_reg1 or pdet_o_reg2 or pdetb_o_reg1 or pdetb_o_reg2) begin
        case (USE_PATTERN_DETECT)
          "NO_PATDET" : begin
                          overflow_o  <= 1'bx;
                          underflow_o <= 1'bx;
                        end
           default    : begin
               case (PREG)

                   0 : begin
                          overflow_o  <= 1'bx;
                          underflow_o <= 1'bx;
                       end
                   default : begin

                               overflow_o  <= pdet_o_reg2 & !pdet_o_reg1 & !pdetb_o_reg1;
                               underflow_o <= pdetb_o_reg2  & !pdet_o_reg1 & !pdetb_o_reg1;
                             end
               endcase
           end
        endcase
    end

    specify

        (CLK *> ACOUT) = (100, 100);
        (CLK *> BCOUT) = (100, 100);
        (CLK *> CARRYCASCOUT)      = (100, 100);
        (CLK *> CARRYOUT)       = (100, 100);
        (CLK *> MULTSIGNOUT)       = (100, 100);
        (CLK *> OVERFLOW)       = (100, 100);
        (CLK *> P) = (100, 100);
        (CLK *> PATTERNBDETECT) = (100, 100);
        (CLK *> PATTERNDETECT)  = (100, 100);
        (CLK *> PCOUT) = (100, 100);
        (CLK *> UNDERFLOW)      = (100, 100);

        specparam PATHPULSE$ = 0;

    endspecify

endmodule // DSP48E

