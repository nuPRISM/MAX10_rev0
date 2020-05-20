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
// rxnl_std = 4
// rxnl = 4
// p_BROADCAST = 0
// rxloops = 1;
// txloops = 1;
// Local RX = 4
// Local TX = 4
// STD RX = 4
// STD TX = 4
// (1024 != 0) and (1 == 0) and (0 != 0) and (4 != 0)
// altera message_level level2
// altera message_off 10030 10036 10230 10236
// vx2 translate_off
(* message_disable = "13410,15610" *)
(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION OFF" } *)
//vx2 translate_on

module  four_lane_seriallite_slite2_top /* vx2 no_prefix */  (
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
tx_parallel_data_in,
tx_ctrlenable,
tx_coreclk,
tx_coreclock,
ctrl_tc_enascram,
ctrl_tc_force_train,
mreset_n,
rxrdp_ena,
rxrdp_dat,
txrdp_ena,
txrdp_dav,
txrdp_dat,
err_rr_pol_rev_required,
err_rr_dskfifo_oflw,
stat_rr_dskw_done_bc);

// Ports and local variables. 
// '_F' indicates an auxiliary variable for flip-flops
// '_S' indicates an auxiliary variable for combinational signals
// '_W' indicates a VX2-created wire
input[128 - 1:0] rx_parallel_data_out;
input rx_coreclk;
input[16 - 1:0] rx_ctrldetect;
input[16 - 1:0] stat_rr_pattdet;
input[16 - 1:0] err_rr_disp;
output[4 - 1:0] flip_polarity;
output rrefclk;
output stat_rr_link;
output[16 - 1:0] err_rr_8berrdet;
input ctrl_rr_enadscram;
output[128 - 1:0] tx_parallel_data_in;
output[16 - 1:0] tx_ctrlenable;
input tx_coreclk;
output tx_coreclock;
input ctrl_tc_enascram;
input ctrl_tc_force_train;
input mreset_n;
output rxrdp_ena;
output[128 - 1:0] rxrdp_dat;
input txrdp_ena;
output txrdp_dav;
input[128 - 1:0] txrdp_dat;
output[4 - 1:0] err_rr_pol_rev_required;
output err_rr_dskfifo_oflw;
output stat_rr_dskw_done_bc;
// Wire Declarations
// Various Debug wires. Not pin outputs, but here for debug purposes. Won't make it into simgen though.
// From RX Core:
wire  [128 - 1:0] rx_parallel_data_out  /*   Serial Lite differential receive data bus.Bus carries the receiver data output.  */
/* vx2 port_info  <desc scope="external"/>     <grpmember grpid=       "slite2"  />     <desc>  Serial Lite differential receive data bus.Bus carries the receiver data output. </desc> */;
wire  rx_coreclk  /*   Serial Lite receiver's coreclk input.  */
/* vx2 port_info  <desc scope="external"/>     <grpmember grpid=       "slite2"  />     <desc>  Serial Lite receiver's coreclk input. </desc> */;
wire  [16 - 1:0] rx_ctrldetect  /*   Serial Lite receiver's control detect output.  */
/* vx2 port_info  <desc scope="external"/>     <grpmember grpid=       "slite2"  />     <desc>  Serial Lite receiver's control detect output. </desc> */;
wire  [16 - 1:0] stat_rr_pattdet  /*   Serial Lite receiver's pattern detect output.  */
/* vx2 port_info  <desc scope="external"/>     <grpmember grpid=       "slite2"  />     <desc>  Serial Lite receiver's pattern detect output. </desc> */;
wire  [16 - 1:0] err_rr_disp  /*   Serial Lite receiver's disparity error output.  */
/* vx2 port_info  <desc scope="external"/>     <grpmember grpid=       "slite2"  />     <desc>  Serial Lite receiver's disparity error output. </desc> */;
wire  [4 - 1:0] flip_polarity  /*   Serial Lite receiver's polarity inversion input.  */
/* vx2 port_info  <desc scope="external"/>     <grpmember grpid=       "slite2"  />     <desc>  Serial Lite receiver's polarity inversion input. </desc> */;
wire  rrefclk  /*    Reference clk. Signals with _rr_ are synchronous to this this clock.    */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "cnr"    />     <desc>   Reference clk. Signals with _rr_ are synchronous to this this clock.   </desc> */;
// Generic Status Output pins (RREFCLK domain)
wire  stat_rr_link  /*    Link Status. When high, the link is up.  */
/* vx2 port_info    <desc scope="internal"/>  <grpmember grpid=       "doc_stat"    />     <desc>   Link Status. When high, the link is up. </desc> */;
wire  [16 - 1:0] err_rr_8berrdet  /*  Serial Lite receiver's 8b10b Error detect signal (1,2 or 4 bits)          */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "doc_err"        />     <desc> Serial Lite receiver's 8b10b Error detect signal (1,2 or 4 bits)         </desc> */;
wire  ctrl_rr_enadscram  /*    Enable data de-scrambling in the RX core. CONNECT TYPE */
/* vx2 port_info <desc scope="internal"/>     <grpmember grpid=       "doc_ctl"    />     <desc>   Enable data de-scrambling in the RX core. CONNECT TYPE</desc> */;
wire  [128 - 1:0] tx_parallel_data_in  /*   Serial Lite transmit data bus to the transceiver. Bus carries packets cells or in-band control words  */
/* vx2 port_info  <desc scope="external"/>    <grpmember grpid=       "slite2"  />     <desc>  Serial Lite transmit data bus to the transceiver. Bus carries packets cells or in-band control words </desc> */;
wire  [16 - 1:0] tx_ctrlenable  /*   Serial Lite transmit control enable to the transceiver.  */
/* vx2 port_info  <desc scope="external"/>    <grpmember grpid=       "slite2"  />     <desc>  Serial Lite transmit control enable to the transceiver. </desc> */;
wire  tx_coreclk  /*   Serial Lite transmiter's core clock.  */
/* vx2 port_info  <desc scope="external"/>    <grpmember grpid=       "slite2"  />     <desc>  Serial Lite transmiter's core clock. </desc> */;
wire  tx_coreclock  /*    Reference clk. Signals with _tc_ are synchronous to this this clock. Derived from TREFCLK. *Active if TREFCLK active.     */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "cnr"    />     <desc>   Reference clk. Signals with _tc_ are synchronous to this this clock. Derived from TREFCLK. *Active if TREFCLK active.    </desc> */;
wire  ctrl_tc_enascram  /*    Enable data scrambling in the TX Core. CONNECT TYPE */
/* vx2 port_info    <desc scope="internal"/>  <grpmember grpid=       "doc_ctl"    />     <desc>   Enable data scrambling in the TX Core. CONNECT TYPE</desc> */;
wire  ctrl_tc_force_train  /*   Force training patterns to be sent. Negate once RX has locked.  */
/* vx2 port_info   <desc scope="internal"/> <grpmember grpid=       "doc_ctl"        />     <desc>  Force training patterns to be sent. Negate once RX has locked. </desc> */;
wire  mreset_n  /*    Active low reset signal. Causes the entire Serial Lite Core including the Atlantic FIFOs to be reset. */
/* vx2 port_info    <desc scope="internal"/>  <grpmember grpid=       "cnr"    />     <desc>   Active low reset signal. Causes the entire Serial Lite Core including the Atlantic FIFOs to be reset.</desc> */;
/////////////////////////////////////////
// interface "Protocol Processing Core //
/////////////////////////////////////////
// RX Signals
wire  rxrdp_ena  /*  Out Data is Valid. In streaming mode, this signal is on the rrefclk domain UNLESS clock compensation is used, in which case the signal is on the TREFCLK domain */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "aif"        />     <desc> Out Data is Valid. In streaming mode, this signal is on the rrefclk domain UNLESS clock compensation is used, in which case the signal is on the TREFCLK domain</desc> */;
wire  [128 - 1:0] rxrdp_dat  /*  User Data bits. In streaming mode, this signal is on the rrefclk domain UNLESS clock compensation is used, in which case the signal is on the TREFCLK domain */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "aif"        />     <desc> User Data bits. In streaming mode, this signal is on the rrefclk domain UNLESS clock compensation is used, in which case the signal is on the TREFCLK domain</desc> */;
// TX Signals
wire  txrdp_ena  /*  Enable signal on the Atlantic Interface, indicates that the data is valid.  */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "aif"        />     <desc> Enable signal on the Atlantic Interface, indicates that the data is valid. </desc> */;
wire  txrdp_dav  /*  Indicates that the input TX core is ready for data.  */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "aif"        />     <desc> Indicates that the input TX core is ready for data. </desc> */;
wire  [128 - 1:0] txrdp_dat  /*  User Data bits.  */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "aif"        />     <desc> User Data bits. </desc> */;
// From RX Core:
wire  [4 - 1:0] err_rr_pol_rev_required  /*  Catastrophic error. Polarity on input GXB lines is reversed, and core can't change polarity. Core is unable to function.  */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid="doc_err"/> <desc> Catastrophic error. Polarity on input GXB lines is reversed, and core can't change polarity. Core is unable to function. </desc> */;
wire  err_rr_dskfifo_oflw  /*  Deskew FIFO has overflow. Link will restart.  */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid="doc_err"/> <desc> Deskew FIFO has overflow. Link will restart. </desc> */;
wire  stat_rr_dskw_done_bc  /*  A bad column has been received after successful deskew completion. Link will be restarted.  */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid="doc_stat"/> <desc> A bad column has been received after successful deskew completion. Link will be restarted. </desc> */;
// BC = Bad Colum. DONE state problem.
// From TX Core:
// RX/TX Flow Control/ROE signals.
wire  stat_tp_violation  ;
wire  stat_t1_t2_notval  ;
wire  stat_mkck_inalign  ;
wire  stat_mkck_waitts2  ;
wire  stat_mkck_wait1ts2  ;
wire  stat_not_t2  ;
wire  stat_patdet_wrgslt  ; // Nice to do : Add to Port list.
wire  stat_k_cnt_ge7  ;
// Nice to do : Add to Port List, Rename to 8 T's received or something
wire  stat_deskew_done  ; // output for module lsm
wire  stat_alanes_up  ;
// Locally assigned in this module. All Lanes Up.
wire  stat_dskwoflw_align  ;
wire  stat_dskwst_bc  ;
wire  stat_dskwst_btds  ;
wire  stat_dskwst_lnio  ;
wire  lsm_pdf_error  ; // From TX Core:
wire  [3:0] stat_txpep_state  ; // Non Debug wire declarations
wire  [1 - 1:0] link_up  ;
assign link_up = {stat_rr_link};

wire rxrdp_err;
// Debug signal for data error marking. May be useful in future.

wire  rcvd_clk0 ;
wire  rcvd_clk1 ;
wire  rcvd_clk2 ;
wire  rcvd_clk3  ; // trefclk available for all configurations.
wire  tx_reset_n ;
wire  tc_reset_n  ;
wire  tc_ll_reset_n  ;
// Stratix II GX TX uses coreclock. Sync the reset to this domain as well.
wire  [4 - 1:0] tx_clkout  ;
assign tx_coreclock = tx_clkout[0];

assign tx_clkout[0] = tx_coreclk;// call to module reset_syncer;
/*CALL*/

 four_lane_seriallite_reset_syncer /* vx2 no_prefix */   tx_coreclock_reset_syncer(.clk(tx_coreclock),
// input
.reset_in(mreset_n), // input
.sync_signal_in(1'b1), // input
.reset_out(tc_reset_n)// output
);
////////////////////////////
/////// RX Reset SYNC //////
////////////////////////////
wire[4 - 1:0] rx_clkout;
assign rx_clkout = rx_coreclk;

assign rrefclk = rx_clkout[0];


wire  rx_reset_n  ; // call to module reset_syncer;
/*CALL*/
 four_lane_seriallite_reset_syncer /* vx2 no_prefix */   rrefclk_reset_syncer(.clk(rrefclk),
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
wire[128 - 1:0] pcs_lsm_data; // input for module slite2_phy
wire[16 - 1:0] pcs_lsm_ctrl; // input for module slite2_phy
wire[16 - 1:0] pcs_lsm_val; // input for module slite2_phy
assign pcs_lsm_val = 16'd1;// Always Valid
// outputs for module slite2_phy;


wire[128 - 1:0] lsm_pdf_data; // output for module slite2_phy
wire[16 - 1:0] lsm_pdf_ctrl; // output for module slite2_phy
wire[16 - 1:0] lsm_pdf_val; // output for module slite2_phy
wire[128 - 1:0] lsm_pcs_data; // output for module slite2_phy
wire[16 - 1:0] lsm_pcs_ctrl; // output for module slite2_phy
wire[16 - 1:0] lsm_pcs_val;
// output for module slite2_phy
///////////////////////////////////////////////
/////////// Reset Logic for GXB ///////////////
///////////////////////////////////////////////
// Put GXB Here.
wire[1 - 1:0] pll_tx_locked;
wire stat_inval_patdet;
// Invalid Pattern Detect signal received. Debug signal.
wire[1 - 1:0] pll_locked;
// State machine data sent to the TX path to be sent over the XCVR --
wire[4 - 1:0] send_ts2_out;
wire send_tds_out;
assign stat_alanes_up = send_tds_out;

wire rcvd_rst_n0;
wire pll_areset;
wire rx_locktodata;
wire[4 - 1:0] rx_analogreset;
wire[4 - 1:0] rx_digitalreset;
reg[4 - 1:0] freq_lock_d1;
reg[4 - 1:0] freq_lock_d2;
reg[4 - 1:0] freq_lock_d3;
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
// TX Signals
////////////////////////////////////////////////////////////////////////
//Exclude transceiver instantiation for this group of device families //
///////////////////////////////////////////////////////////////////////
assign pcs_lsm_data = rx_parallel_data_out;

assign pcs_lsm_ctrl = rx_ctrldetect;

assign tx_parallel_data_in = lsm_pcs_data;

assign tx_ctrlenable = lsm_pcs_ctrl;///////////////////////////////////////////////
///////////////////////////////////////////////
/////////// SLITE2 PHY Layer  /////////////////
///////////////////////////////////////////////
// Put SLITE2 PHY Modules Here.
// *******************************************
// call to module slite2_phy;
/*CALL*/

 four_lane_seriallite_slite2_phy /* vx2 no_prefix */   slite2_phy(.trefclk(tx_coreclock),
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
.flip_polarity0(flip_polarity), // output
.pol_rev_required0(err_rr_pol_rev_required), // output
.send_ts2_out0(send_ts2_out), .send_tds_out0(send_tds_out),
// Debug Signals.
.stat_tp_violation0(stat_tp_violation),
.stat_t1_t2_notval0(stat_t1_t2_notval),
.stat_mkck_inalign0(stat_mkck_inalign),
.stat_mkck_waitts20(stat_mkck_waitts2),
.stat_mkck_wait1ts20(stat_mkck_wait1ts2), .stat_not_t20(stat_not_t2),
.stat_patdet_wrgslt0(stat_patdet_wrgslt), .k_count_ge_70(stat_k_cnt_ge7),
.lsm_ldm_deskewed0(stat_deskew_done), // Deskew Debug Signals
.stat_dskwoflw_align0(stat_dskwoflw_align),
.stat_dskfifo_oflw0(err_rr_dskfifo_oflw),
.stat_dskwst_bc0(stat_dskwst_bc), .stat_dskwst_btds0(stat_dskwst_btds),
.stat_dskwst_lnio0(stat_dskwst_lnio),
.stat_dskw_done_bc0(stat_rr_dskw_done_bc), .rxrdp_ena0(rxrdp_ena),
.rxrdp_dat0(rxrdp_dat), .rxrdp_err0(rxrdp_err),
.lsm_pdf_error0(lsm_pdf_error), // debug output
.ctrl_tc_enascram(ctrl_tc_enascram), // input
.ctrl_tc_force_train(ctrl_tc_force_train), // input
.send_ts2(& send_ts2_out), //send_ts2_out_bcst
.send_tds(send_tds_out), //send_tds_out_bcst
.txrdp_ena(txrdp_ena), .txrdp_dav(txrdp_dav), .txrdp_dat(txrdp_dat),
.lsm_pcs_data(lsm_pcs_data), // output [32-1:0]
.lsm_pcs_ctrl(lsm_pcs_ctrl), // output [4-1:0]
.lsm_pcs_val(lsm_pcs_val)// output [4-1:0]
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