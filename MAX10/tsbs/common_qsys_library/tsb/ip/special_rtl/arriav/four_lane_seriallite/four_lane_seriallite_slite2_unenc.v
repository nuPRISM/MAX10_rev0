/*
*******************************************************************************

MODULE_NAME = lsm_leaky
COMPANY     = Altera Corporation, Altera Ottawa Technology Center
WEB         = www.altera.com

FUNCTIONAL_DESCRIPTION :
LSM - Leaky Bucket Portion of the LSM.
$Id: //acds/rel/14.1/ip/slite/slite2/hw/src/rtl/lsm_leaky.vx.erp#1 $
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
// vx2 translate_off
(* message_disable="14130" *)
//vx2 translate_on

//altera message_off 10230
module  four_lane_seriallite_lsm_leaky /* vx2 no_prefix */  (
rrefclk,
rx_reset_n,
err_in,
rx_ll_err,
reinit);

// Ports and local variables. 
// '_F' indicates an auxiliary variable for flip-flops
// '_S' indicates an auxiliary variable for combinational signals
// '_W' indicates a VX2-created wire
input rrefclk;
input rx_reset_n;
input err_in;
input rx_ll_err;
output reinit;
wire  rrefclk ;
wire  rx_reset_n ;
wire  err_in  ;
wire  rx_ll_err  ;
reg  reinit, _Freinit  ;
reg  crc_err_meta, _Fcrc_err_meta  ;
reg  crc_err_sync, _Fcrc_err_sync  ;
reg  crc_err_sync_d1, _Fcrc_err_sync_d1  ;
reg  nxt_error_detected, _Snxt_error_detected  ;
reg  error_detected, _Ferror_detected  ;
reg  [1:0] error_count, _Ferror_count  ;
reg  [3:0] drain_count, _Fdrain_count  ;

always @( * )  begin
// initialize flip-flop and combinational regs
    _Freinit = reinit;
    _Fcrc_err_meta = crc_err_meta;
    _Fcrc_err_sync = crc_err_sync;
    _Fcrc_err_sync_d1 = crc_err_sync_d1;
    _Snxt_error_detected = 0;
    _Ferror_detected = error_detected;
    _Ferror_count = error_count;
    _Fdrain_count = drain_count;

// mainline code
    begin // TODO : P+R : CRC Error domain issues?

        _Fcrc_err_meta = rx_ll_err;
        _Fcrc_err_sync = crc_err_meta;
        _Fcrc_err_sync_d1 = crc_err_sync;
        _Snxt_error_detected = err_in == 1 || (crc_err_sync && ! crc_err_sync_d1);
        _Ferror_detected = nxt_error_detected;
        if (error_detected) begin 
            _Ferror_count = error_count + 1;
        end 
        else
            if (& drain_count == 1 && error_count != 0) begin 
                _Ferror_count = error_count - 1;
            end 
        if (error_detected && & error_count == 1) begin 
            _Freinit = 1;
        end 
        else
        begin 
            _Freinit = 0;
        end 
        if (error_count != 0) begin 
            _Fdrain_count = drain_count + 1;
        end 
        else
        begin 
            _Fdrain_count = 0;
        end 
    end 


// update regs for combinational signals
// The non-blocking assignment causes the always block to 
// re-stimulate if the signal has changed
    nxt_error_detected <= _Snxt_error_detected;
end
always @(posedge rrefclk or negedge rx_reset_n) begin
    if (!rx_reset_n) begin
        reinit<=0;
        crc_err_meta<=0;
        crc_err_sync<=0;
        crc_err_sync_d1<=0;
        error_detected<=0;
        error_count<=0;
        drain_count<=0;
    end else begin
        reinit<=_Freinit;
        crc_err_meta<=_Fcrc_err_meta;
        crc_err_sync<=_Fcrc_err_sync;
        crc_err_sync_d1<=_Fcrc_err_sync_d1;
        error_detected<=_Ferror_detected;
        error_count<=_Ferror_count;
        drain_count<=_Fdrain_count;
    end
end
endmodule

/*Vx2, V2.1.5
Released 2006-10-10
Checked out from CVS as $Header: //acds/rel/14.1/ip/infrastructure/tools/lib/ToolVersion.pm#1 $
*/