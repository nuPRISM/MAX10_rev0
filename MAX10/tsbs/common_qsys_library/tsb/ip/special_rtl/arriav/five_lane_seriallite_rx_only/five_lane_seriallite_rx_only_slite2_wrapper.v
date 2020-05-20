/*
*******************************************************************************

MODULE_NAME = slite2_top
COMPANY     = Altera Corporation, Altera Ottawa Technology Center
WEB         = www.altera.com

FUNCTIONAL_DESCRIPTION :
SerialLite II Top Level Module
$Id: //acds/rel/14.1/ip/slite/slite2/hw/src/rtl/slite2_top.vx.erp#1 $
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
// rxnl_std = 1
// rxnl = 1
// p_BROADCAST = 0
// rxloops = 1;
// txloops = 1;
// Local RX = 1
// Local TX = 0
// STD RX = 1
// STD TX = 0
// (1024 != 0) and (1 == 0) and (0 != 0) and (1 != 0)
// altera message_level level2
// altera message_off 10030 10036 10230 10236
// vx2 translate_off
(* message_disable = "13410,15610" *)
(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION OFF" } *)
//vx2 translate_on

module  five_lane_seriallite_rx_only_slite2_top /* vx2 no_prefix */  (
rx_parallel_data_out,
rx_coreclk,
rx_ctrldetect,
stat_rr_pattdet,
err_rr_disp,
flip_polarity,
rrefclk,
stat_rr_link,
err_rr_8berrdet,
ctrl_rr_enadscram,
mreset_n,
rxrdp_ena,
rxrdp_dat);

// Ports and local variables. 
// '_F' indicates an auxiliary variable for flip-flops
// '_S' indicates an auxiliary variable for combinational signals
// '_W' indicates a VX2-created wire
input[32 - 1:0] rx_parallel_data_out;
input rx_coreclk;
input[4 - 1:0] rx_ctrldetect;
input[4 - 1:0] stat_rr_pattdet;
input[4 - 1:0] err_rr_disp;
output[1 - 1:0] flip_polarity;
output rrefclk;
output stat_rr_link;
output[4 - 1:0] err_rr_8berrdet;
input ctrl_rr_enadscram;
input mreset_n;
output rxrdp_ena;
output[32 - 1:0] rxrdp_dat;
// Wire Declarations
// Various Debug wires. Not pin outputs, but here for debug purposes. Won't make it into simgen though.
// From RX Core:
wire  [32 - 1:0] rx_parallel_data_out  /*   Serial Lite differential receive data bus.Bus carries the receiver data output.  */
/* vx2 port_info  <desc scope="external"/>     <grpmember grpid=       "slite2"  />     <desc>  Serial Lite differential receive data bus.Bus carries the receiver data output. </desc> */;
wire  rx_coreclk  /*   Serial Lite receiver's coreclk input.  */
/* vx2 port_info  <desc scope="external"/>     <grpmember grpid=       "slite2"  />     <desc>  Serial Lite receiver's coreclk input. </desc> */;
wire  [4 - 1:0] rx_ctrldetect  /*   Serial Lite receiver's control detect output.  */
/* vx2 port_info  <desc scope="external"/>     <grpmember grpid=       "slite2"  />     <desc>  Serial Lite receiver's control detect output. </desc> */;
wire  [4 - 1:0] stat_rr_pattdet  /*   Serial Lite receiver's pattern detect output.  */
/* vx2 port_info  <desc scope="external"/>     <grpmember grpid=       "slite2"  />     <desc>  Serial Lite receiver's pattern detect output. </desc> */;
wire  [4 - 1:0] err_rr_disp  /*   Serial Lite receiver's disparity error output.  */
/* vx2 port_info  <desc scope="external"/>     <grpmember grpid=       "slite2"  />     <desc>  Serial Lite receiver's disparity error output. </desc> */;
wire  [1 - 1:0] flip_polarity  /*   Serial Lite receiver's polarity inversion input.  */
/* vx2 port_info  <desc scope="external"/>     <grpmember grpid=       "slite2"  />     <desc>  Serial Lite receiver's polarity inversion input. </desc> */;
wire  rrefclk  /*    Reference clk. Signals with _rr_ are synchronous to this this clock.    */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "cnr"    />     <desc>   Reference clk. Signals with _rr_ are synchronous to this this clock.   </desc> */;
// Generic Status Output pins (RREFCLK domain)
wire  stat_rr_link  /*    Link Status. When high, the link is up.  */
/* vx2 port_info    <desc scope="internal"/>  <grpmember grpid=       "doc_stat"    />     <desc>   Link Status. When high, the link is up. </desc> */;
wire  [4 - 1:0] err_rr_8berrdet  /*  Serial Lite receiver's 8b10b Error detect signal (1,2 or 4 bits)          */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "doc_err"        />     <desc> Serial Lite receiver's 8b10b Error detect signal (1,2 or 4 bits)         </desc> */;
wire  ctrl_rr_enadscram  /*    Enable data de-scrambling in the RX core. CONNECT TYPE */
/* vx2 port_info <desc scope="internal"/>     <grpmember grpid=       "doc_ctl"    />     <desc>   Enable data de-scrambling in the RX core. CONNECT TYPE</desc> */;
wire  mreset_n  /*    Active low reset signal. Causes the entire Serial Lite Core including the Atlantic FIFOs to be reset. */
/* vx2 port_info    <desc scope="internal"/>  <grpmember grpid=       "cnr"    />     <desc>   Active low reset signal. Causes the entire Serial Lite Core including the Atlantic FIFOs to be reset.</desc> */;
/////////////////////////////////////////
// interface "Protocol Processing Core //
/////////////////////////////////////////
// RX Signals
wire  rxrdp_ena  /*  Out Data is Valid. In streaming mode, this signal is on the rrefclk domain UNLESS clock compensation is used, in which case the signal is on the TREFCLK domain */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "aif"        />     <desc> Out Data is Valid. In streaming mode, this signal is on the rrefclk domain UNLESS clock compensation is used, in which case the signal is on the TREFCLK domain</desc> */;
wire  [32 - 1:0] rxrdp_dat  /*  User Data bits. In streaming mode, this signal is on the rrefclk domain UNLESS clock compensation is used, in which case the signal is on the TREFCLK domain */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "aif"        />     <desc> User Data bits. In streaming mode, this signal is on the rrefclk domain UNLESS clock compensation is used, in which case the signal is on the TREFCLK domain</desc> */;
// From RX Core:
// From TX Core:
// RX/TX Flow Control/ROE signals.
wire  lsm_pdf_error  ; // From TX Core:
// Non Debug wire declarations
wire  [1 - 1:0] link_up  ;
assign link_up = {stat_rr_link};

wire rxrdp_err;
// Debug signal for data error marking. May be useful in future.

wire  rcvd_clk0  ; // trefclk available for all configurations.
wire  tx_reset_n ;
wire  tc_reset_n  ;
wire  tc_ll_reset_n  ;
assign tc_reset_n = tx_reset_n;////////////////////////////
/////// RX Reset SYNC //////
////////////////////////////


wire[1 - 1:0] rx_clkout;
assign rx_clkout = rx_coreclk;

assign rrefclk = rx_clkout;


wire  rx_reset_n  ; // call to module reset_syncer;
/*CALL*/
 five_lane_seriallite_rx_only_reset_syncer /* vx2 no_prefix */   rrefclk_reset_syncer(.clk(rrefclk),
// input
.reset_in(mreset_n), // input
.sync_signal_in(1'b1), // input
.reset_out(rx_reset_n)// output
);
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
//////// ATLANTIC FIFO CALLS ///////////////////////////////////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////
/////////// END OF ATLANTIC FIFO CALLS //////////
/////////////////////////////////////////////////
wire[32 - 1:0] pcs_lsm_data; // input for module slite2_phy
wire[4 - 1:0] pcs_lsm_ctrl; // input for module slite2_phy
wire[4 - 1:0] pcs_lsm_val; // input for module slite2_phy
assign pcs_lsm_val = 4'd1;// Always Valid
// outputs for module slite2_phy;


wire[32 - 1:0] lsm_pdf_data; // output for module slite2_phy
wire[4 - 1:0] lsm_pdf_ctrl; // output for module slite2_phy
wire[4 - 1:0] lsm_pdf_val;
// output for module slite2_phy
///////////////////////////////////////////////
/////////// Reset Logic for GXB ///////////////
///////////////////////////////////////////////
// Put GXB Here.
wire stat_inval_patdet;
// Invalid Pattern Detect signal received. Debug signal.
wire[1 - 1:0] pll_locked;
assign flip_polarity = 1'd0;// Polarity Rev not available in SSYNC mode.


wire rcvd_rst_n0;
wire pll_areset;
wire rx_locktodata;
wire[1 - 1:0] rx_analogreset;
wire[1 - 1:0] rx_digitalreset;
reg[1 - 1:0] freq_lock_d1;
reg[1 - 1:0] freq_lock_d2;
reg[1 - 1:0] freq_lock_d3;
reg link_d1;
reg link_d2;
reg link_d3;
reg freqlock_lost
/* synthesis altera_attribute="disable_da_rule=d101" */;
reg detect_errors;
reg force_digital_reset
/* synthesis altera_attribute="disable_da_rule=\"d101,d102,d103\"" */;
reg force_digital_reset_d1
/* synthesis altera_attribute="disable_da_rule=d103" */;
wire link_going_up;
wire link_going_down;
// The following code is controlling the forcing of a rx_digitalreset when
// the link is down due to a remote end performing a hard reset.
// Currently only needed for Stratix GX w/ Phase Comp FIFO's.
// However, leaving the code in (will be optimized out if not used) for future use.
// Disable this code when the family is Stratix V and above
///////////////////////////////////////////////
/////////// ALTGXB or ALT2GXB /////////////////
///////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
//Exclude transceiver instantiation for this group of device families //
///////////////////////////////////////////////////////////////////////
assign pcs_lsm_data = rx_parallel_data_out;

assign pcs_lsm_ctrl = rx_ctrldetect;///////////////////////////////////////////////
///////////////////////////////////////////////
/////////// SLITE2 PHY Layer  /////////////////
///////////////////////////////////////////////
// Put SLITE2 PHY Modules Here.
// *******************************************
// call to module slite2_phy;
/*CALL*/

 five_lane_seriallite_rx_only_slite2_phy /* vx2 no_prefix */   slite2_phy(.trefclk(tx_coreclock),
// input
.tx_reset_n(tc_reset_n), // input
.ctrl_rr_enadscram0(ctrl_rr_enadscram),
// Currently do not support Descram for individual cores.
.linked_up0(stat_rr_link), // output
.rrefclk0(rrefclk), // input
.rx_reset_n0(rx_reset_n), // input
.rx_ll_err0(1'b0), // input No Link Layer, so always 0.
.rx_phy_foffre_lsm_reinit0(1'b0),
// No Tolerance block present, or mode 15  
.rx_disperr0(err_rr_disp), // input [4-1:0]
.rx_errdetect0(err_rr_8berrdet), // input [4-1:0]
.rx_patterndetect0(stat_rr_pattdet), // input [4-1:0]
.stat_inval_patdet0(stat_inval_patdet), // output debug.
.pcs_lsm_data0(pcs_lsm_data), // input [32-1:0]
.pcs_lsm_ctrl0(pcs_lsm_ctrl), // input [4-1:0]
.pcs_lsm_val0(pcs_lsm_val), // input [4-1:0]
.rxrdp_ena0(rxrdp_ena), .rxrdp_dat0(rxrdp_dat), .rxrdp_err0(rxrdp_err),
.lsm_pdf_error0(lsm_pdf_error)// debug output
);
///////////////////////////////////////////////
///////////////////////////////////////////////
/////////// SLITE2 Link Layer /////////////////
///////////////////////////////////////////////

endmodule

/*Vx2, V2.1.5
Released 2006-10-10
Checked out from CVS as $Header: //acds/rel/14.1/ip/infrastructure/tools/lib/ToolVersion.pm#1 $
*/