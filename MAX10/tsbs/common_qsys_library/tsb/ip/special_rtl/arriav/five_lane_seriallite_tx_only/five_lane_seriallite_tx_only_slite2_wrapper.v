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
// rxnl_std = 0
// rxnl = 0
// p_BROADCAST = 0
// rxloops = 1;
// txloops = 1;
// Local RX = 0
// Local TX = 1
// STD RX = 0
// STD TX = 1
// (1024 != 0) and (1 == 0) and (0 != 0) and (0 != 0)
// altera message_level level2
// altera message_off 10030 10036 10230 10236
// vx2 translate_off
(* message_disable = "13410,15610" *)
(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION OFF" } *)
//vx2 translate_on

module  five_lane_seriallite_tx_only_slite2_top /* vx2 no_prefix */  (
tx_parallel_data_in,
tx_ctrlenable,
tx_coreclk,
tx_coreclock,
ctrl_tc_enascram,
ctrl_tc_force_train,
mreset_n,
txrdp_ena,
txrdp_dav,
txrdp_dat);

// Ports and local variables. 
// '_F' indicates an auxiliary variable for flip-flops
// '_S' indicates an auxiliary variable for combinational signals
// '_W' indicates a VX2-created wire
output[32 - 1:0] tx_parallel_data_in;
output[4 - 1:0] tx_ctrlenable;
input tx_coreclk;
output tx_coreclock;
input ctrl_tc_enascram;
input ctrl_tc_force_train;
input mreset_n;
input txrdp_ena;
output txrdp_dav;
input[32 - 1:0] txrdp_dat;
// Wire Declarations
// Various Debug wires. Not pin outputs, but here for debug purposes. Won't make it into simgen though.
// From RX Core:
// From TX Core:
wire  [32 - 1:0] tx_parallel_data_in  /*   Serial Lite transmit data bus to the transceiver. Bus carries packets cells or in-band control words  */
/* vx2 port_info  <desc scope="external"/>    <grpmember grpid=       "slite2"  />     <desc>  Serial Lite transmit data bus to the transceiver. Bus carries packets cells or in-band control words </desc> */;
wire  [4 - 1:0] tx_ctrlenable  /*   Serial Lite transmit control enable to the transceiver.  */
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
// TX Signals
wire  txrdp_ena  /*  Enable signal on the Atlantic Interface, indicates that the data is valid.  */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "aif"        />     <desc> Enable signal on the Atlantic Interface, indicates that the data is valid. </desc> */;
wire  txrdp_dav  /*  Indicates that the input TX core is ready for data.  */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "aif"        />     <desc> Indicates that the input TX core is ready for data. </desc> */;
wire  [32 - 1:0] txrdp_dat  /*  User Data bits.  */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "aif"        />     <desc> User Data bits. </desc> */;
// From RX Core:
// From TX Core:
// RX/TX Flow Control/ROE signals.
wire  [3:0] stat_txpep_state  ;
// Non Debug wire declarations
// Transmitter Only "fake" link-up signal (based on force train).
wire  link_up = ~ ctrl_tc_force_train  ;
// trefclk available for all configurations.
wire  tx_reset_n ;
wire  tc_reset_n  ;
wire  tc_ll_reset_n  ;
// Stratix II GX TX uses coreclock. Sync the reset to this domain as well.
wire  [1 - 1:0] tx_clkout  ;
assign tx_coreclock = tx_clkout[0];

assign tx_clkout[0] = tx_coreclk;// call to module reset_syncer;
/*CALL*/

 five_lane_seriallite_tx_only_reset_syncer /* vx2 no_prefix */   tx_coreclock_reset_syncer(.clk(tx_coreclock),
// input
.reset_in(mreset_n), // input
.sync_signal_in(1'b1), // input
.reset_out(tc_reset_n)// output
);
////////////////////////////
/////// RX Reset SYNC //////
////////////////////////////
/////////////////////////////////////////////////
/////////// END OF ATLANTIC FIFO CALLS //////////
/////////////////////////////////////////////////
wire[32 - 1:0] lsm_pcs_data; // output for module slite2_phy
wire[4 - 1:0] lsm_pcs_ctrl; // output for module slite2_phy
wire[4 - 1:0] lsm_pcs_val;
// output for module slite2_phy
///////////////////////////////////////////////
/////////// Reset Logic for GXB ///////////////
///////////////////////////////////////////////
// Put GXB Here.
wire[1 - 1:0] pll_tx_locked;
// TX Only, need connection to the output pll locked signal.
assign stat_tc_pll_locked = & pll_tx_locked;

wire rcvd_rst_n0;
wire pll_areset;
///////////////////////////////////////////////
/////////// ALTGXB or ALT2GXB /////////////////
///////////////////////////////////////////////
// TX Signals
////////////////////////////////////////////////////////////////////////
//Exclude transceiver instantiation for this group of device families //
///////////////////////////////////////////////////////////////////////
assign tx_parallel_data_in = lsm_pcs_data;

assign tx_ctrlenable = lsm_pcs_ctrl;///////////////////////////////////////////////
///////////////////////////////////////////////
/////////// SLITE2 PHY Layer  /////////////////
///////////////////////////////////////////////
// Put SLITE2 PHY Modules Here.
// *******************************************
// call to module slite2_phy;
/*CALL*/

 five_lane_seriallite_tx_only_slite2_phy /* vx2 no_prefix */   slite2_phy(.trefclk(tx_coreclock),
// input
.tx_reset_n(tc_reset_n), // input
.ctrl_tc_enascram(ctrl_tc_enascram), // input
.ctrl_tc_force_train(ctrl_tc_force_train), // input
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