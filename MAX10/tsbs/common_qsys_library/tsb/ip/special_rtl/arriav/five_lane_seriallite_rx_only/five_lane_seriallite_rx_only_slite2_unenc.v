/*
*******************************************************************************

MODULE_NAME = rx_phy_ssynchlsm
COMPANY     = Altera Corporation, Altera Ottawa Technology Center
WEB         = www.altera.com

FUNCTIONAL_DESCRIPTION :
Self Synchronizing Link State Machine, single lane mode only. Future release will support multi-lane alignment
$Id: //acds/rel/14.1/ip/slite/slite2/hw/src/rtl/rx_phy_ssynchlsm.vx.erp#1 $
END_FUNCTIONAL_DESCRIPTION

LEGAL :
  Copyright (C) 2007 Altera Corporation. All rights reserved.  This source code
  to a MegaCore logic function is highly confidential and proprietary
  information of Altera and is being provided in accordance with and
  subject to the applicable MegaCore Logic Function License Agreement
  which governs its use and disclosure.  Altera products and services
  are protected under numerous U.S. and foreign patents, maskwork rights,
  copyrights and other intellectual property laws.
END_LEGAL
*******************************************************************************
*/
// altera message_off 10230
module  five_lane_seriallite_rx_only_rx_phy_ssynchlsm /* vx2 no_prefix */  (
clk,
reset_n,
rx_disperr,
rx_errdetect,
rx_ll_err,
rx_patterndetect,
rx_phy_foffre_lsm_reinit,
rx_data,
rx_ctrl,
rx_val,
align_data,
align_ctrl,
align_val,
data_error,
rx_enacdet,
stat_inval_patdet,
lsm_up);

// Ports and local variables. 
// '_F' indicates an auxiliary variable for flip-flops
// '_S' indicates an auxiliary variable for combinational signals
// '_W' indicates a VX2-created wire
parameter bad_count_msb = 2;
// How many errors in the "good" window before link down.
parameter ALIGNING = 0;
parameter LOCKED0 = 1;
parameter LOCKED1 = 2;
parameter LOCKED2 = 3;
parameter LOCKED3 = 4;
input clk;
input reset_n;
input[4 - 1:0] rx_disperr;
input[4 - 1:0] rx_errdetect;
input rx_ll_err;
input[4 - 1:0] rx_patterndetect;
input rx_phy_foffre_lsm_reinit;
input[32 - 1:0] rx_data;
input[4 - 1:0] rx_ctrl;
input[4 - 1:0] rx_val;
output[32 - 1:0] align_data;
output[4 - 1:0] align_ctrl;
output[4 - 1:0] align_val;
output data_error;
output[1 - 1:0] rx_enacdet;
output stat_inval_patdet;
output lsm_up;
// vx2 translate_off
`ifdef QUARTUS__SIMGEN
parameter good_count_msb = 5;  // Simulation speedup version.
`else
parameter good_count_msb = 6; // Count up to 64 
`endif
// vx2 translate_on

wire  clk ;
wire  reset_n ;
wire  [4 - 1:0] rx_disperr  ;
wire  [4 - 1:0] rx_errdetect  ;
wire  rx_ll_err  ; // input   RX Link Layer Error.
wire  [4 - 1:0] rx_patterndetect  ;
wire  rx_phy_foffre_lsm_reinit  ;
wire  [32 - 1:0] rx_data  ;
wire  [4 - 1:0] rx_ctrl  ;
wire  [4 - 1:0] rx_val  ;
reg  [32 - 1:0] align_data  ;
// Could possibly be comb output (Small TSIZE).

reg[32 - 1:0] _Falign_data;
reg  [4 - 1:0] align_ctrl, _Falign_ctrl  ;
reg  [4 - 1:0] align_val, _Falign_val  ;
reg  data_error, _Fdata_error  ;
reg  [1 - 1:0] rx_enacdet, _Frx_enacdet  ;
reg  stat_inval_patdet  ; // Invalid Pattern Detect signal received.

reg _Fstat_inval_patdet;
reg  lsm_up  /* synthesis altera_attribute="disable_da_rule=\"d101,d102,d103\"" */;
reg _Flsm_up;
reg  [7:0] count, _Fcount  ;
reg  [7:0] count_no_match, _Fcount_no_match  ;
reg  [32 - 1:0] shifted_data_1, _Sshifted_data_1  ;
reg  [4 - 1:0] shifted_ctrl_1, _Sshifted_ctrl_1  ;
reg  [4 - 1:0] shifted_val_1, _Sshifted_val_1  ;
reg  shifted_err_1, _Sshifted_err_1  ;
reg  [7:0] rx_data_ff_1, _Frx_data_ff_1  ;
reg  rx_ctrl_ff_1, _Frx_ctrl_ff_1  ;
reg  rx_val_ff_1, _Frx_val_ff_1  ;
reg  rx_err_ff_1, _Frx_err_ff_1  ;
reg  [32 - 1:0] shifted_data_2, _Sshifted_data_2  ;
reg  [4 - 1:0] shifted_ctrl_2, _Sshifted_ctrl_2  ;
reg  [4 - 1:0] shifted_val_2, _Sshifted_val_2  ;
reg  shifted_err_2, _Sshifted_err_2  ;
reg  [15:0] rx_data_ff_2, _Frx_data_ff_2  ;
reg  [1:0] rx_ctrl_ff_2, _Frx_ctrl_ff_2  ;
reg  [1:0] rx_val_ff_2, _Frx_val_ff_2  ;
reg  [1:0] rx_err_ff_2, _Frx_err_ff_2  ;
reg  [32 - 1:0] shifted_data_4, _Sshifted_data_4  ;
reg  [4 - 1:0] shifted_ctrl_4, _Sshifted_ctrl_4  ;
reg  [4 - 1:0] shifted_val_4, _Sshifted_val_4  ;
reg  shifted_err_4, _Sshifted_err_4  ;
reg  [23:0] rx_data_ff_3, _Frx_data_ff_3  ;
reg  [2:0] rx_ctrl_ff_3, _Frx_ctrl_ff_3  ;
reg  [2:0] rx_val_ff_3, _Frx_val_ff_3  ;
reg  [2:0] rx_err_ff_3, _Frx_err_ff_3  ;
reg  [4 - 1:0] shift_rx_data, _Fshift_rx_data  ;
reg  error_detected, _Serror_detected  ;

always @( * )  begin
// initialize flip-flop and combinational regs
    _Falign_data = align_data;
    _Falign_ctrl = align_ctrl;
    _Falign_val = align_val;
    _Fdata_error = data_error;
    _Frx_enacdet = rx_enacdet;
    _Fstat_inval_patdet = stat_inval_patdet;
    _Flsm_up = lsm_up;
    _Fcount = count;
    _Fcount_no_match = count_no_match;
    _Sshifted_data_1 = 0;
    _Sshifted_ctrl_1 = 0;
    _Sshifted_val_1 = 0;
    _Sshifted_err_1 = 0;
    _Frx_data_ff_1 = rx_data_ff_1;
    _Frx_ctrl_ff_1 = rx_ctrl_ff_1;
    _Frx_val_ff_1 = rx_val_ff_1;
    _Frx_err_ff_1 = rx_err_ff_1;
    _Sshifted_data_2 = 0;
    _Sshifted_ctrl_2 = 0;
    _Sshifted_val_2 = 0;
    _Sshifted_err_2 = 0;
    _Frx_data_ff_2 = rx_data_ff_2;
    _Frx_ctrl_ff_2 = rx_ctrl_ff_2;
    _Frx_val_ff_2 = rx_val_ff_2;
    _Frx_err_ff_2 = rx_err_ff_2;
    _Sshifted_data_4 = 0;
    _Sshifted_ctrl_4 = 0;
    _Sshifted_val_4 = 0;
    _Sshifted_err_4 = 0;
    _Frx_data_ff_3 = rx_data_ff_3;
    _Frx_ctrl_ff_3 = rx_ctrl_ff_3;
    _Frx_val_ff_3 = rx_val_ff_3;
    _Frx_err_ff_3 = rx_err_ff_3;
    _Fshift_rx_data = shift_rx_data;
    _Serror_detected = 0;

// mainline code
    begin // RLV Should provide disperrs and errdetect issues. if not, it should be added.

        _Serror_detected = | rx_disperr || | rx_errdetect || rx_phy_foffre_lsm_reinit || rx_ll_err;// sync status will eventually force re-init.
        // align to GXB
        if (error_detected) begin 
            _Fcount = 0;
            _Fcount_no_match = count_no_match + 1;
        end 
        else
        begin // The count value was reset on error. Since the link is still up,
        // we don't need COM's, so we just increment on non error. 

            if (count_no_match != 0 && lsm_up) begin 
                _Fcount = count + 1;
            end // Once the count count has returned, then we can clear the count_no_match value          
            if (count[good_count_msb] == 1'b1) begin // can now clear the count_no_match value

                _Fcount_no_match = 0;
            end 
            if (| rx_patterndetect) begin // COMS's being received.

                _Fcount = count + 1;
            end 
        end 
        if (count[good_count_msb] == 1'b1 && count_no_match == 0) begin // Receive X words without any alignment errors before declaring aligned

            _Flsm_up = 1'b1;
        end 
        else
            if (count == 0 && count_no_match[bad_count_msb] == 1'b1) begin // Receive Z consecutive words not correct before declaring Not aligned

                _Flsm_up = 1'b0;
            end 
        if (lsm_up == 0) begin 
            _Frx_enacdet = -1;// Look for Training pattern constantly.
        end 
        else
        begin 
            _Frx_enacdet = 0;
        end // ****************************
        // WORD ALIGNMENT STATE MACHINE (For p_TSIZE > 0).
        // ****************************
        //  align the bytes so the msb contains the /K/ character
        //  delay things if necessary
        _Frx_data_ff_1 = rx_data[7:0];
        _Frx_ctrl_ff_1 = rx_ctrl[0];
        _Frx_val_ff_1 = rx_val[0];
        _Frx_err_ff_1 = rx_errdetect[0] | rx_disperr[0];
        _Sshifted_data_1 = {rx_data_ff_1, rx_data[31:8]};
        _Sshifted_ctrl_1 = {rx_ctrl_ff_1, rx_ctrl[3:1]};
        _Sshifted_val_1 = {rx_val_ff_1, rx_val[3:1]};
        _Sshifted_err_1 = | {rx_err_ff_1 , rx_errdetect [ 3 : 1 ] , rx_disperr [ 3 : 1 ]};
        _Frx_data_ff_2 = rx_data[15:0];
        _Frx_ctrl_ff_2 = rx_ctrl[1:0];
        _Frx_val_ff_2 = rx_val[1:0];
        _Frx_err_ff_2 = rx_errdetect[1:0] | rx_disperr[1:0];
        _Sshifted_data_2 = {rx_data_ff_2, rx_data[31:16]};
        _Sshifted_ctrl_2 = {rx_ctrl_ff_2, rx_ctrl[3:2]};
        _Sshifted_val_2 = {rx_val_ff_2, rx_val[3:2]};
        _Sshifted_err_2 = | {rx_err_ff_2 , rx_errdetect [ 3 : 2 ] , rx_disperr [ 3 : 2 ]};
        _Frx_data_ff_3 = rx_data[23:0];
        _Frx_ctrl_ff_3 = rx_ctrl[2:0];
        _Frx_val_ff_3 = rx_val[2:0];
        _Frx_err_ff_3 = rx_errdetect[2:0] | rx_disperr[2:0];
        _Sshifted_data_4 = {rx_data_ff_3, rx_data[31:24]};
        _Sshifted_ctrl_4 = {rx_ctrl_ff_3, rx_ctrl[3]};
        _Sshifted_val_4 = {rx_val_ff_3, rx_val[3]};
        _Sshifted_err_4 = | {rx_err_ff_3 , rx_errdetect [ 3 ] , rx_disperr [ 3 ]};// Now shift the data so the K is aligned.
        _Fstat_inval_patdet = 1'b0;
        if (! lsm_up) begin 
            if (rx_patterndetect == 4'd1) begin 
                _Fshift_rx_data = 4'd1;
            end 
            if (rx_patterndetect == 4'd2) begin 
                _Fshift_rx_data = 4'd2;
            end 
            if (rx_patterndetect == 4'd4) begin 
                _Fshift_rx_data = 4'd4;
            end 
            else
                if (rx_patterndetect == 4'd8) begin // We don't need to shift this one.

                    _Fshift_rx_data = 4'd0;
                end 
        end 
        if (shift_rx_data == 4'd1) begin 
            _Falign_data = shifted_data_1;
            _Falign_ctrl = shifted_ctrl_1;
            _Falign_val = shifted_val_1;
            _Fdata_error = shifted_err_1;
        end 
        else
            if (shift_rx_data == 4'd2) begin 
                _Falign_data = shifted_data_2;
                _Falign_ctrl = shifted_ctrl_2;
                _Falign_val = shifted_val_2;
                _Fdata_error = shifted_err_2;
            end 
            else
                if (shift_rx_data == 4'd4) begin 
                    _Falign_data = shifted_data_4;
                    _Falign_ctrl = shifted_ctrl_4;
                    _Falign_val = shifted_val_4;
                    _Fdata_error = shifted_err_4;
                end 
                else
                begin 
                    _Falign_data = rx_data;
                    _Falign_ctrl = rx_ctrl;
                    _Falign_val = rx_val;
                    _Fdata_error = | {rx_errdetect , rx_disperr};
                end 
    end 


// update regs for combinational signals
// The non-blocking assignment causes the always block to 
// re-stimulate if the signal has changed
    shifted_data_1 <= _Sshifted_data_1;
    shifted_ctrl_1 <= _Sshifted_ctrl_1;
    shifted_val_1 <= _Sshifted_val_1;
    shifted_err_1 <= _Sshifted_err_1;
    shifted_data_2 <= _Sshifted_data_2;
    shifted_ctrl_2 <= _Sshifted_ctrl_2;
    shifted_val_2 <= _Sshifted_val_2;
    shifted_err_2 <= _Sshifted_err_2;
    shifted_data_4 <= _Sshifted_data_4;
    shifted_ctrl_4 <= _Sshifted_ctrl_4;
    shifted_val_4 <= _Sshifted_val_4;
    shifted_err_4 <= _Sshifted_err_4;
    error_detected <= _Serror_detected;
end
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        align_data<=0;
        align_ctrl<=0;
        align_val<=0;
        data_error<=0;
        rx_enacdet<=0;
        stat_inval_patdet<=0;
        lsm_up<=0;
        count<=0;
        count_no_match<=0;
        rx_data_ff_1<=0;
        rx_ctrl_ff_1<=0;
        rx_val_ff_1<=0;
        rx_err_ff_1<=0;
        rx_data_ff_2<=0;
        rx_ctrl_ff_2<=0;
        rx_val_ff_2<=0;
        rx_err_ff_2<=0;
        rx_data_ff_3<=0;
        rx_ctrl_ff_3<=0;
        rx_val_ff_3<=0;
        rx_err_ff_3<=0;
        shift_rx_data<=0;
    end else begin
        align_data<=_Falign_data;
        align_ctrl<=_Falign_ctrl;
        align_val<=_Falign_val;
        data_error<=_Fdata_error;
        rx_enacdet<=_Frx_enacdet;
        stat_inval_patdet<=_Fstat_inval_patdet;
        lsm_up<=_Flsm_up;
        count<=_Fcount;
        count_no_match<=_Fcount_no_match;
        rx_data_ff_1<=_Frx_data_ff_1;
        rx_ctrl_ff_1<=_Frx_ctrl_ff_1;
        rx_val_ff_1<=_Frx_val_ff_1;
        rx_err_ff_1<=_Frx_err_ff_1;
        rx_data_ff_2<=_Frx_data_ff_2;
        rx_ctrl_ff_2<=_Frx_ctrl_ff_2;
        rx_val_ff_2<=_Frx_val_ff_2;
        rx_err_ff_2<=_Frx_err_ff_2;
        rx_data_ff_3<=_Frx_data_ff_3;
        rx_ctrl_ff_3<=_Frx_ctrl_ff_3;
        rx_val_ff_3<=_Frx_val_ff_3;
        rx_err_ff_3<=_Frx_err_ff_3;
        shift_rx_data<=_Fshift_rx_data;
    end
end
endmodule

/*Vx2, V2.1.5
Released 2006-10-10
Checked out from CVS as $Header: //acds/rel/14.1/ip/infrastructure/tools/lib/ToolVersion.pm#1 $
*/