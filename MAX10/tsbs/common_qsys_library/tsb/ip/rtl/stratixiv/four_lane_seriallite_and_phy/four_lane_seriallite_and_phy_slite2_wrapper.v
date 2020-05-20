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

module  four_lane_seriallite_and_phy_slite2_top /* vx2 no_prefix */  (
rxin,
rrefclk,
stat_rr_link,
ctrl_rr_enadscram,
txout,
stat_tc_pll_locked,
tx_coreclock,
ctrl_tc_enascram,
ctrl_tc_force_train,
trefclk,
cal_blk_clk,
gxb_powerdown,
mreset_n,
rcvd_clk_out,
err_rr_8berrdet,
err_rr_disp,
err_rr_pcfifo_uflw,
err_rr_pcfifo_oflw,
err_rr_rlv,
stat_rr_gxsync,
stat_rr_freqlock,
stat_rr_rxlocked,
stat_rr_pattdet,
rxrdp_ena,
rxrdp_dat,
err_tc_pcfifo_oflw,
err_tc_pcfifo_uflw,
txrdp_ena,
txrdp_dav,
txrdp_dat,
ctrl_tc_serial_lpbena,
reconfig_clk,
reconfig_togxb,
reconfig_fromgxb,
stat_tc_rst_done,
err_rr_pol_rev_required,
err_rr_dskfifo_oflw,
stat_rr_dskw_done_bc);

// Ports and local variables. 
// '_F' indicates an auxiliary variable for flip-flops
// '_S' indicates an auxiliary variable for combinational signals
// '_W' indicates a VX2-created wire
input[4 - 1:0] rxin;
output rrefclk;
output stat_rr_link;
input ctrl_rr_enadscram;
output[4 - 1:0] txout;
output stat_tc_pll_locked;
output tx_coreclock;
input ctrl_tc_enascram;
input ctrl_tc_force_train;
input trefclk;
input cal_blk_clk;
input gxb_powerdown;
input mreset_n;
output[4 - 1:0] rcvd_clk_out;
output[16 - 1:0] err_rr_8berrdet;
output[16 - 1:0] err_rr_disp;
output[4 - 1:0] err_rr_pcfifo_uflw;
output[4 - 1:0] err_rr_pcfifo_oflw;
output[4 - 1:0] err_rr_rlv;
output[16 - 1:0] stat_rr_gxsync;
output[4 - 1:0] stat_rr_freqlock;
output[4 - 1:0] stat_rr_rxlocked;
output[16 - 1:0] stat_rr_pattdet;
output rxrdp_ena;
output[128 - 1:0] rxrdp_dat;
output[4 - 1:0] err_tc_pcfifo_oflw;
output[4 - 1:0] err_tc_pcfifo_uflw;
input txrdp_ena;
output txrdp_dav;
input[128 - 1:0] txrdp_dat;
input ctrl_tc_serial_lpbena;
input reconfig_clk;
input[3:0] reconfig_togxb;
output[17 - 1:0] reconfig_fromgxb;
output stat_tc_rst_done;
output[4 - 1:0] err_rr_pol_rev_required;
output err_rr_dskfifo_oflw;
output stat_rr_dskw_done_bc;
// Wire Declarations
// Various Debug wires. Not pin outputs, but here for debug purposes. Won't make it into simgen though.
// From RX Core:
wire  [4 - 1:0] rxin  /*   Serial Lite differential receive data bus.Bus carries packets cells or in-band control words.  */
/* vx2 port_info  <desc scope="external"/>     <grpmember grpid=       "slite2"  />     <desc>  Serial Lite differential receive data bus.Bus carries packets cells or in-band control words. </desc> */;
wire  rrefclk  /*    Reference clk. Signals with _rr_ are synchronous to this this clock.    */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "cnr"    />     <desc>   Reference clk. Signals with _rr_ are synchronous to this this clock.   </desc> */;
// Generic Status Output pins (RREFCLK domain)
wire  stat_rr_link  /*    Link Status. When high, the link is up.  */
/* vx2 port_info    <desc scope="internal"/>  <grpmember grpid=       "doc_stat"    />     <desc>   Link Status. When high, the link is up. </desc> */;
wire  ctrl_rr_enadscram  /*    Enable data de-scrambling in the RX core. CONNECT TYPE */
/* vx2 port_info <desc scope="internal"/>     <grpmember grpid=       "doc_ctl"    />     <desc>   Enable data de-scrambling in the RX core. CONNECT TYPE</desc> */;
wire  [4 - 1:0] txout  /*   Serial Lite differential transmit data bus. Bus carries packets cells or in-band control words  */
/* vx2 port_info  <desc scope="external"/>    <grpmember grpid=       "slite2"  />     <desc>  Serial Lite differential transmit data bus. Bus carries packets cells or in-band control words </desc> */;
wire  stat_tc_pll_locked  /*  PLL locked signal. Indicates that the GXB PLL (!p_SLITE2) has locked to the TREFCLK.  */
/* vx2 port_info  <desc scope="internal"/><grpmember grpid=       "doc_stat"        />     <desc> PLL locked signal. Indicates that the GXB PLL (!p_SLITE2) has locked to the TREFCLK. </desc> */;
wire  tx_coreclock  /*    Reference clk. Signals with _tc_ are synchronous to this this clock. Derived from TREFCLK. *Active if TREFCLK active.     */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "cnr"    />     <desc>   Reference clk. Signals with _tc_ are synchronous to this this clock. Derived from TREFCLK. *Active if TREFCLK active.    </desc> */;
wire  ctrl_tc_enascram  /*    Enable data scrambling in the TX Core. CONNECT TYPE */
/* vx2 port_info    <desc scope="internal"/>  <grpmember grpid=       "doc_ctl"    />     <desc>   Enable data scrambling in the TX Core. CONNECT TYPE</desc> */;
wire  ctrl_tc_force_train  /*   Force training patterns to be sent. Negate once RX has locked.  */
/* vx2 port_info   <desc scope="internal"/> <grpmember grpid=       "doc_ctl"        />     <desc>  Force training patterns to be sent. Negate once RX has locked. </desc> */;
wire  trefclk  /*    Reference clk. Signals with _tr_ are synchronous to this this clock. */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "cnr"    />     <desc>   Reference clk. Signals with _tr_ are synchronous to this this clock.</desc> */;
wire  cal_blk_clk  /*   Calibration clock for the termination resistor calibration block. The frequency range of the cal_blk_clk is 10 MHz to 125 MHz. The quality of the calibration clock is not an issue, so PLD local routing is sufficient to route the calibration clock. */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "altgxb"    />     <desc>  Calibration clock for the termination resistor calibration block. The frequency range of the cal_blk_clk is 10 MHz to 125 MHz. The quality of the calibration clock is not an issue, so PLD local routing is sufficient to route the calibration clock.</desc> */;
wire  gxb_powerdown  /*   Transceiver block reset and power down. This resets and powers down all circuits in the transceiver block. Min pulse width is currently 1ms, subject to change based on characterization. */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "altgxb"    />     <desc>  Transceiver block reset and power down. This resets and powers down all circuits in the transceiver block. Min pulse width is currently 1ms, subject to change based on characterization.</desc> */;
wire  mreset_n  /*    Active low reset signal. Causes the entire Serial Lite Core including the Atlantic FIFOs to be reset. */
/* vx2 port_info    <desc scope="internal"/>  <grpmember grpid=       "cnr"    />     <desc>   Active low reset signal. Causes the entire Serial Lite Core including the Atlantic FIFOs to be reset.</desc> */;
/////////////////////////////////////////
// interface "Protocol Processing Core //
/////////////////////////////////////////
// RX Signals
wire  [4 - 1:0] rcvd_clk_out  /*  Per channel Recovered clock. For debug?            */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "cnr"        />     <desc> Per channel Recovered clock. For debug?           </desc> */;
wire  [16 - 1:0] err_rr_8berrdet  /*  8b10b Error detect signal (1,2 or 4 bits)          */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "doc_err"        />     <desc> 8b10b Error detect signal (1,2 or 4 bits)         </desc> */;
wire  [16 - 1:0] err_rr_disp  /*  Disparity error detect signal (1, 2 or 4 bits)     */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "doc_err"        />     <desc> Disparity error detect signal (1, 2 or 4 bits)    </desc> */;
// Opportunistically support: output wire [4-1:0] err_rr_rmfifo_full (* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "doc_err"        />     <desc> Rate match FIFO full status signal                </desc> *),
wire  [4 - 1:0] err_rr_pcfifo_uflw  /*  Interface/Phase comp FIFO underflow signal         */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "altgxb"        />     <desc> Interface/Phase comp FIFO underflow signal        </desc> */;
wire  [4 - 1:0] err_rr_pcfifo_oflw  /*  Interface/Phase comp FIFO overflow signal          */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "altgxb"        />     <desc> Interface/Phase comp FIFO overflow signal         </desc> */;
wire  [4 - 1:0] err_rr_rlv  /*  run length violation status signal                 */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "doc_err"        />     <desc> run length violation status signal                </desc> */;
wire  [16 - 1:0] stat_rr_gxsync  /*  Gives the status of the pattern detector and word aligner      */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "altgxb"        />     <desc> Gives the status of the pattern detector and word aligner     </desc> */;
wire  [4 - 1:0] stat_rr_freqlock  /*  Frequency locked signal from the CRU. Indicates whether transceiver block receiver channel is locked to the data mode in the RXIN port   */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "doc_stat"        />     <desc> Frequency locked signal from the CRU. Indicates whether transceiver block receiver channel is locked to the data mode in the RXIN port  </desc> */;
wire  [4 - 1:0] stat_rr_rxlocked  /*  Receiver PLL locked signal. Indicates if the receiver PLL is phase locked to the CRU reference clock. When the pll has locked to data, which is some time after the rx_freqlocked on the XCVR goes to high, this signal is not that meaningful anymore because it only indicates lock to reference. It is not applicable for Stratix II GX */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "altgxb"        />     <desc> Receiver PLL locked signal. Indicates if the receiver PLL is phase locked to the CRU reference clock. When the pll has locked to data, which is some time after the rx_freqlocked on the XCVR goes to high, this signal is not that meaningful anymore because it only indicates lock to reference. It is not applicable for Stratix II GX</desc> */;
wire  [16 - 1:0] stat_rr_pattdet  /*  Pattern char detect signal (1, 2 or 4 bits)          */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "doc_stat"        />     <desc> Pattern char detect signal (1, 2 or 4 bits)         </desc> */;
wire  rxrdp_ena  /*  Out Data is Valid. In streaming mode, this signal is on the rrefclk domain UNLESS clock compensation is used, in which case the signal is on the TREFCLK domain */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "aif"        />     <desc> Out Data is Valid. In streaming mode, this signal is on the rrefclk domain UNLESS clock compensation is used, in which case the signal is on the TREFCLK domain</desc> */;
wire  [128 - 1:0] rxrdp_dat  /*  User Data bits. In streaming mode, this signal is on the rrefclk domain UNLESS clock compensation is used, in which case the signal is on the TREFCLK domain */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "aif"        />     <desc> User Data bits. In streaming mode, this signal is on the rrefclk domain UNLESS clock compensation is used, in which case the signal is on the TREFCLK domain</desc> */;
// TX Signals
wire  [4 - 1:0] err_tc_pcfifo_oflw  /*  Interface/Phase comp FIFO overflow signal          */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "altgxb"        />     <desc> Interface/Phase comp FIFO overflow signal         </desc> */;
wire  [4 - 1:0] err_tc_pcfifo_uflw  /*  Interface/Phase comp FIFO underflow signal         */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "altgxb"        />     <desc> Interface/Phase comp FIFO underflow signal        </desc> */;
wire  txrdp_ena  /*  Enable signal on the Atlantic Interface, indicates that the data is valid.  */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "aif"        />     <desc> Enable signal on the Atlantic Interface, indicates that the data is valid. </desc> */;
wire  txrdp_dav  /*  Indicates that the input TX core is ready for data.  */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "aif"        />     <desc> Indicates that the input TX core is ready for data. </desc> */;
wire  [128 - 1:0] txrdp_dat  /*  User Data bits.  */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "aif"        />     <desc> User Data bits. </desc> */;
wire  ctrl_tc_serial_lpbena  /*  Serial Loopback (TXOUT internally connected to RXIN). Tie signal to 1'b0 to NOT use loopback, tie to 1'b1 to USE Serial Loopback.       */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "altgxb"        />     <desc> Serial Loopback (TXOUT internally connected to RXIN). Tie signal to 1'b0 to NOT use loopback, tie to 1'b1 to USE Serial Loopback.      </desc> */;
wire  reconfig_clk  /*   ALT2GXB Reconfig Clock  */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "altgxb"    />     <desc>  ALT2GXB Reconfig Clock </desc> */;
wire  [3:0] reconfig_togxb  /*   ALT2GXB Reconfig to GXB Bus. If Unused, this MUST be tied to 3'b010  */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "altgxb"    />     <desc>  ALT2GXB Reconfig to GXB Bus. If Unused, this MUST be tied to 3'b010 </desc> */;
wire  [17 - 1:0] reconfig_fromgxb  /*   ALT2GXB Reconfig From GXB Bus  */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid=       "altgxb"    />     <desc>  ALT2GXB Reconfig From GXB Bus </desc> */;
// Debug Output Pins
wire  stat_tc_rst_done  /*  Status indicator from the GXB Reset logic indicating that the reset cycle is complete and was successful  */
/* vx2 port_info <desc scope="internal"/> <grpmember grpid="doc_stat"/> <desc> Status indicator from the GXB Reset logic indicating that the reset cycle is complete and was successful </desc> */;
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
assign tx_coreclock = tx_clkout[0];// call to module reset_syncer;
/*CALL*/

 four_lane_seriallite_and_phy_reset_syncer /* vx2 no_prefix */   tx_coreclock_reset_syncer(.clk(tx_coreclock),
// input
.reset_in(mreset_n), // input
.sync_signal_in(1'b1), // input
.reset_out(tc_reset_n)// output
);
// call to module reset_syncer;
/*CALL*/
 four_lane_seriallite_and_phy_reset_syncer /* vx2 no_prefix */   trefclk_reset_syncer(.clk(trefclk),
// input
.reset_in(mreset_n), // input
.sync_signal_in(1'b1), // input
.reset_out(tx_reset_n)// output
);
////////////////////////////
/////// RX Reset SYNC //////
////////////////////////////
wire[4 - 1:0] rx_clkout;
assign rcvd_clk_out = rx_clkout;

assign rrefclk = rx_clkout[0];


wire  rx_reset_n  ; // call to module reset_syncer;
/*CALL*/
 four_lane_seriallite_and_phy_reset_syncer /* vx2 no_prefix */   rrefclk_reset_syncer(.clk(rrefclk),
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
wire[4 - 1:0] rx_enacdet;
wire stat_inval_patdet;
// Invalid Pattern Detect signal received. Debug signal.
wire[1 - 1:0] pll_locked;
wire[4 - 1:0] flip_polarity;
// Debug signal!
// State machine data sent to the TX path to be sent over the XCVR --
wire[4 - 1:0] send_ts2_out;
wire send_tds_out;
assign stat_alanes_up = send_tds_out;

assign stat_tc_pll_locked = & pll_locked;

wire rcvd_rst_n0;
wire pll_areset;
wire rxareset;
wire tx_dig_reset;
wire rx_dig_reset;
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
wire force_digital_reset_pulse;
// The following code is controlling the forcing of a rx_digitalreset when
// the link is down due to a remote end performing a hard reset.
// Currently only needed for Stratix GX w/ Phase Comp FIFO's.
// However, leaving the code in (will be optimized out if not used) for future use.
// Disable this code when the family is Stratix V and above

always @(posedge trefclk)
begin 
    link_d1<=stat_rr_link;
    link_d2<=link_d1;
    link_d3<=link_d2;
end 

always @(posedge trefclk)
begin 
    freq_lock_d1<=stat_rr_freqlock;
    freq_lock_d2<=freq_lock_d1;
    freq_lock_d3<=freq_lock_d2;
end 

always @(posedge trefclk or negedge tx_reset_n)
if (tx_reset_n == 1'b0)    freqlock_lost<=1'b0;
else
    if (~ freqlock_lost && stat_rr_link && ~& freq_lock_d3)        freqlock_lost<=1'b1;
    else
        if (link_going_up)            freqlock_lost<=1'b0;
assign link_going_up = link_d2 && ~ link_d3;

assign link_going_down = ~ link_d2 && link_d3;


always @(posedge trefclk or negedge tx_reset_n)
if (tx_reset_n == 1'b0)    detect_errors<=1'b0;
else
    if (link_going_down && ~ freqlock_lost)        detect_errors<=1'b1;
    else
        if (link_going_up)            detect_errors<=1'b0;

always @(posedge trefclk or negedge tx_reset_n)
if (tx_reset_n == 1'b0)    force_digital_reset<=1'b0;
else
    if
    (~ force_digital_reset && detect_errors && (| err_rr_rlv || | err_rr_disp))        force_digital_reset<=1'b1;
    else
        if (link_going_up)            force_digital_reset<=1'b0;

always @(posedge trefclk)
force_digital_reset_d1<=force_digital_reset;
assign force_digital_reset_pulse = force_digital_reset && ~
    force_digital_reset_d1;


parameter rx_rst_size = 4;
assign rx_analogreset = {rx_rst_size {rxareset}};

assign rx_digitalreset = {rx_rst_size {rx_dig_reset}};

wire[4 - 1:0] tx_digitalreset;

parameter tx_rst_size = 4;
assign tx_digitalreset = {tx_rst_size {tx_dig_reset}};// RESET LOGIC


 four_lane_seriallite_and_phy_reset_logic_gx /* vx2 no_prefix */   reset_logic_inst(.clk(tx_coreclock),
.mreset_n(tc_reset_n), .pll_locked(stat_tc_pll_locked),
.pll_areset(pll_areset),
// Unused. mreset_n used instead of PLL merging.
.rcvd_clk0(rx_clkout[0]), .rx_freqlocked(& stat_rr_freqlock),
.rcvd_rst_n0(rcvd_rst_n0),
// Use this reset instead of rx_reset_n. Check DA
.rx_analogreset(rxareset), .rx_digitalreset(rx_dig_reset),
.rx_locktodata(rx_locktodata),
// Avaialable to user if required (needs changes to XCVR and this wrapper).
.tx_digitalreset(tx_dig_reset), .stat_rst_done(stat_tc_rst_done));
///////////////////////////////////////////////
/////////// ALTGXB or ALT2GXB /////////////////
///////////////////////////////////////////////
// TX Signals
assign err_tc_pcfifo_oflw = 4'd0;

assign err_tc_pcfifo_uflw = 4'd0;

assign err_rr_pcfifo_uflw = 4'd0;

assign err_rr_pcfifo_oflw = 4'd0;


parameter number_of_channels = 4;
parameter number_of_quads = 1;
 four_lane_seriallite_and_phy_slite2_xcvr /* vx2 no_prefix */   xcvr_inst(.cal_blk_clk(cal_blk_clk),
// What do we set this to???
.gxb_powerdown({number_of_quads {gxb_powerdown}}), .pll_inclk(trefclk),
.reconfig_clk(reconfig_clk), .reconfig_togxb(reconfig_togxb),
.reconfig_fromgxb(reconfig_fromgxb), .rx_analogreset(rx_analogreset),
.rx_coreclk({number_of_channels {rx_clkout[0]}}),
.rx_cruclk({number_of_channels {trefclk}}), .rx_datain(rxin),
.rx_digitalreset(rx_digitalreset),
.rx_seriallpbken({number_of_channels {ctrl_tc_serial_lpbena}}),
.rx_enapatternalign(rx_enacdet), .rx_invpolarity(flip_polarity),
.tx_coreclk({number_of_channels {tx_clkout[0]}}),
.tx_datain(lsm_pcs_data), .tx_ctrlenable(lsm_pcs_ctrl),
.tx_digitalreset(tx_digitalreset), .rx_phase_comp_fifo_error(),
.tx_phase_comp_fifo_error(), .pll_locked(pll_locked),
.rx_clkout(rx_clkout), .tx_clkout(tx_clkout),
// [0] tied to tx_coreclock.
.rx_ctrldetect(pcs_lsm_ctrl), .rx_dataout(pcs_lsm_data),
.rx_disperr(err_rr_disp), .rx_errdetect(err_rr_8berrdet),
.rx_freqlocked(stat_rr_freqlock), .rx_patterndetect(stat_rr_pattdet),
.rx_pll_locked(stat_rr_rxlocked),
// Not to be confused with the rxlocked out (unused).
.rx_rlv(err_rr_rlv), .rx_syncstatus(stat_rr_gxsync), .tx_dataout(txout));
///////////////////////////////////////////////
///////////////////////////////////////////////
/////////// SLITE2 PHY Layer  /////////////////
///////////////////////////////////////////////
// Put SLITE2 PHY Modules Here.
// *******************************************
// call to module slite2_phy;
/*CALL*/
 four_lane_seriallite_and_phy_slite2_phy /* vx2 no_prefix */   slite2_phy(.trefclk(tx_coreclock),
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
.rx_enacdet0(rx_enacdet), //
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