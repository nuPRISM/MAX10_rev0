`default_nettype none
`include "interface_defs.v"
`include "arria_v_specific_interfaces.v"
`include "keep_defines.v"
//`define USE_SERIALLITE_BONDED_LANES
//`define USE_5_LANE_SERIALLITE_TO_CIRCUMVENT_ALTERA_BUG
`ifdef USE_5_LANE_SERIALLITE_TO_CIRCUMVENT_ALTERA_BUG
        `define SLITE_RECONFIG_MODULE_NAME five_lane_seriallite_custom_phy_reconfig
		`define SLITE_PHY_MODULE_NAME five_lane_seriallite_custom_phy_megafunction		
        `define SLITE_MODULE_NAME five_lane_seriallite
		`define NUM_SLITE_LANES 5
		
`else
        `define SLITE_MODULE_NAME four_lane_seriallite
		`define NUM_SLITE_LANES 4

		`ifdef USE_SERIALLITE_BONDED_LANES
				`define SLITE_RECONFIG_MODULE_NAME four_lane_seriallite_custom_phy_reconfig
				`define SLITE_PHY_MODULE_NAME four_lane_seriallite_custom_phy_megafunction		
		`else
				`define SLITE_RECONFIG_MODULE_NAME non_bonded_four_lane_seriallite_custom_phy_reconfig
				`define SLITE_PHY_MODULE_NAME non_bonded_four_lane_seriallite_custom_phy_megafunction		
		`endif
`endif
		
`define NUM_SLITE_COLUMNS 4

import uart_regfile_types::*;

module arria_v_standalone_four_lane_streaming_serialite_w_uart_control
#(
parameter DIAGNOSTIC_CLOCK_SPEED_IN_HZ = 50000000,
parameter PHY_CTRL_CLOCK_SPEED_IN_HZ = 100000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter [63:0] xcvr_name = "undef",
parameter [127:0] diagnostic_uart_name = {"SLStrm",xcvr_name},
parameter [127:0] phy_uart_name = {"PhyCtl",xcvr_name},
parameter [127:0] reconfig_uart_name = {"ReConf",xcvr_name},
parameter NUM_BITS_TX_RX_BUSSES = `NUM_SLITE_LANES*32,
parameter DEFAULT_WAIT_BETWEEN_STAGED_LOCK_CHECKS = 500000000, //10 seconds
parameter DEFAULT_WAIT_BETWEEN_STAGED_RESETS = 1000000, //a long time
parameter synchronizer_depth = 3,
parameter ENABLE_KEEPS = 0

)
(
	input [(`NUM_SLITE_LANES-1):0] XCVR_RX,
	output [(`NUM_SLITE_LANES-1):0] XCVR_TX,
	input CLKIN_125MHz,
	input RESET_FOR_CLKIN_125MHz,
	input CLKIN_100MHz,
	input RESET_FOR_CLKIN_100MHz,
	input CLKIN_50MHz,
	input RESET_FOR_CLKIN_50MHz,
	output uart_tx,
	input  uart_rx,
	avalon_st_streaming_interface  avalon_st_streaming_tx_out,
	avalon_st_streaming_interface  avalon_st_streaming_rx_in,
	input external_link_error_indication,
    input data_source_ready,	
	output rx_clk,
    input wire       TOP_UART_IS_SECONDARY_UART    ,
    input wire [7:0] TOP_UART_NUM_SECONDARY_UARTS  ,
    input wire [7:0] TOP_UART_ADDRESS_OF_THIS_UART,
	output logic [NUM_BITS_TX_RX_BUSSES-1:0]	tx_parallel_data_in,
	output logic [NUM_BITS_TX_RX_BUSSES-1:0]    rx_parallel_data_out,
	output tx_clk_of_pma

);



(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire slite_reconfig_uart_tx;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire slite_phy_uart_tx;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire slite_diagnostic_uart_tx;

assign uart_tx = slite_reconfig_uart_tx & slite_phy_uart_tx & slite_diagnostic_uart_tx;

(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire auto_reset;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire auto_reset_clk_125;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire auto_reset_clk_100;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire redo_auto_reset_100;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire synced_100_data_source_ready;

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Auto Reset Signal Generation
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////

generate_one_shot_pulse 
#(.num_clks_to_wait(1))  
generate_auto_reset
(
.clk(CLKIN_50MHz), 
.oneshot_pulse(auto_reset)
);

generate_one_shot_pulse 
#(.num_clks_to_wait(1))  
generate_auto_reset_clk_125
(
.clk(CLKIN_125MHz), 
.oneshot_pulse(auto_reset_clk_125)
);

/*
generate_one_shot_pulse 
#(.num_clks_to_wait(1))  
generate_auto_reset_clk_100
(
.clk(CLKIN_100MHz), 
.oneshot_pulse(auto_reset_clk_100)
);
*/

generate_controlled_length_pulse
#(
.default_count(100),
.num_bits_counter(10),
.pulse_out_initial_value(1)
)
generate_auto_reset_clk_100
(
.async_reset(redo_auto_reset_100),
.pulse_out(auto_reset_clk_100),
.clk(CLKIN_100MHz)
);

generate_controlled_length_pulse
#(
.default_count(100),
.num_bits_counter(10),
.pulse_out_initial_value(1)
)
generate_staged_reset_phy_clk_100
(
.async_reset(staged_reset_phy),
.pulse_out(staged_reset_phy_clk_100),
.clk(CLKIN_100MHz)
);


////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Interface Definitions
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////

generic_multi_lane_seriallite_phy_interface 
#(
.numcolumns(`NUM_SLITE_COLUMNS),
.numlanes(`NUM_SLITE_LANES)
)
seriallite_custom_phy();

	simple_atlantic_streaming_interface #(.numdatabits(NUM_BITS_TX_RX_BUSSES)) txout_atlantic_interface();
	simple_atlantic_streaming_interface #(.numdatabits(NUM_BITS_TX_RX_BUSSES)) rxin_atlantic_interface();	
	
    wire xcvr_reconfig_busy;
    wire xcvr_loopback_enable;
    wire actual_xcvr_loopback_enable;
    wire reset_serialite_n;
wire [559:0] reconfig_to_xcvr    ;
wire [367:0] reconfig_from_xcvr	 ;

	
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	ctrl_tc_force_train;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	mreset_n;

	 logic     	rrefclk;	
	 logic     	tx_coreclock;
	 
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic  tx_cal_busy;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic  rx_cal_busy;
	
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic            stat_rr_link;
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     [(`NUM_SLITE_LANES*`NUM_SLITE_COLUMNS-1):0]	stat_rr_gxsync;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     [(`NUM_SLITE_LANES-1):0]	stat_rr_freqlock;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     [(`NUM_SLITE_LANES*`NUM_SLITE_COLUMNS-1):0]	stat_rr_pattdet;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	    stat_tc_pll_locked;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	    stat_tc_rst_done;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	    stat_tc_foffre_empty;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	    stat_rr_ebprx;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	    stat_rxhpp_empty;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic    [0:0]   err_rr_dskfifo_oflw ;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	    stat_rr_dskw_done_bc;
	
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic  [(`NUM_SLITE_LANES*`NUM_SLITE_COLUMNS-1):0]	err_rr_8berrdet;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic  [(`NUM_SLITE_LANES*`NUM_SLITE_COLUMNS-1):0]	err_rr_disp;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	err_rr_pcfifo_uflw;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	err_rr_pcfifo_oflw;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic  [(`NUM_SLITE_LANES-1):0]   	err_rr_rlv;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	err_tc_rxhpp_oflw;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	err_tc_pcfifo_oflw;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	err_tc_pcfifo_uflw;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	err_txhpp_oflw;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	err_rr_foffre_oflw;

	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	err_rr_bip8;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	err_rr_crc;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	err_rr_fcrx_bne;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	err_rr_roerx_bne;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	err_rr_invalid_lmprx;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	err_rr_missing_start_dcw;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic     	err_rr_addr_mismatch;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic  [(`NUM_SLITE_LANES-1):0]	err_rr_pol_rev_required;
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic        err_tc_roe_rsnd_gt4;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic        stat_tc_roe_timeout;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic        stat_rr_roe_ack;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic        stat_rr_roe_nack;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic        err_tc_is_drop;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic        err_tc_lm_fifo_oflw;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic        err_rr_rx2txfifo_oflw;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic		stat_rr_fc_rdp_valid;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic		stat_rr_fc_hpp_valid;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic[7:0]	stat_rr_fc_value;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic		stat_tc_fc_rdp_retransmit;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic		stat_tc_fc_hpp_retransmit;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic		stat_tc_rdp_thresh_breach;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic		stat_tc_hpp_thresh_breach;
	

	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic	[(`NUM_SLITE_LANES*`NUM_SLITE_COLUMNS-1):0]	tx_ctrlenable;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic 	        rx_coreclk;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic 	        tx_coreclk;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [(`NUM_SLITE_LANES*`NUM_SLITE_COLUMNS-1):0]	    rx_ctrldetect;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [(`NUM_SLITE_LANES-1):0]	    flip_polarity;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [(`NUM_SLITE_LANES-1):0]          rx_is_lockedtoref;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [19:0]          rx_bitslipboundaryselectout;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [(`NUM_SLITE_LANES-1):0]          rx_is_lockedtodata;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [(`NUM_SLITE_LANES-1):0]           rx_signaldetect;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [(`NUM_SLITE_LANES*`NUM_SLITE_COLUMNS-1):0]      rx_runningdisp;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [(`NUM_SLITE_LANES*`NUM_SLITE_COLUMNS-1):0]      rx_rmfifodatainserted;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [(`NUM_SLITE_LANES*`NUM_SLITE_COLUMNS-1):0]      rx_rmfifodatadeleted;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic phy_mgmt_clk;
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  reg phy_mgmt_clk_reset_n = 0;
   
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire xcvr_tx_ready ;
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire xcvr_rx_ready  ;
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire [(`NUM_SLITE_LANES-1):0] tx_forceelecidle;
   
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire arria_v_xcvr_reconfig_reset_n;
   
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire reconfig_reset_n;
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire synced_independent_reconfig_reset;
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire independent_reconfig_reset;
   
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire phy_reset_n;
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire synced_independent_phy_reset;
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire independent_phy_reset;
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic enable_staged_auto_reset;
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic slite_link_lock_indication;
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0] wait_between_staged_lock_checks;
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0] wait_between_staged_resets     ;
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic reset_event_occurred_pulse;
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic staged_reset_phy  ;
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic staged_reset_phy_clk_100  ;
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic staged_reset_slite;
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic use_slow_mode;
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) reg [31:0] reset_event_counter = 0;
   (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire [31:0] staged_reset_state;

   
	wire override_ready;
	wire actual_override_ready;
	wire override_tx_ready;
	wire actual_override_tx_ready;
	
	
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire [127:0] slite_error = {
    err_rr_dskfifo_oflw,err_tc_is_drop,err_tc_lm_fifo_oflw,err_rr_rx2txfifo_oflw,err_rr_8berrdet,
    err_rr_disp,err_rr_pcfifo_uflw,  	err_rr_pcfifo_oflw,	err_rr_rlv, 		err_tc_rxhpp_oflw, 		err_tc_pcfifo_oflw, 	err_tc_pcfifo_uflw, 	err_txhpp_oflw, 		
	err_rr_foffre_oflw,	err_rr_bip8, 	         err_rr_crc, 	err_rr_fcrx_bne,	err_rr_roerx_bne, 	err_rr_invalid_lmprx, 	err_rr_missing_start_dcw, 	err_rr_addr_mismatch, 
	err_rr_pol_rev_required
};

(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire [127:0] slite_status = {
  flip_polarity,tx_cal_busy,rx_cal_busy,
  xcvr_reconfig_busy,
  rxin_atlantic_interface.dav,
  txout_atlantic_interface.dav, 
  stat_rr_dskw_done_bc,
  stat_rr_gxsync,
  stat_rr_pattdet,
  stat_rr_freqlock,  
  stat_tc_pll_locked, 
  stat_rr_link,
  stat_tc_rst_done,  
  stat_tc_foffre_empty,  
  stat_rr_ebprx,  
  stat_rxhpp_empty
 };
 
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire [127:0] custom_phy_status = {
    rx_bitslipboundaryselectout, 
	rx_signaldetect, 
	rx_is_lockedtodata,
    xcvr_tx_ready, 
	xcvr_rx_ready,
    rx_runningdisp,
	rx_ctrldetect,
    tx_ctrlenable,
	rx_rmfifodatainserted,
	rx_rmfifodatadeleted
};


logic [NUM_BITS_TX_RX_BUSSES-1:0] posedge_avalon_st_streaming_tx_out_data;
logic  posedge_avalon_st_streaming_tx_out_valid;
/*
logic [NUM_BITS_TX_RX_BUSSES-1:0] negedge_avalon_st_streaming_tx_out_data;
wire choose_negedge_for_tx_out; 
*/

assign tx_clk_of_pma = seriallite_custom_phy.tx_clkout[0];
always_ff @(posedge seriallite_custom_phy.tx_clkout[0])
begin
      //for now, let Quartus handle timing. Perhaps clock crossing FIFO is needed. Clocks have the same frequency but possibly different phases
      posedge_avalon_st_streaming_tx_out_data[31:0]    <= avalon_st_streaming_tx_out.data[31:0];
      posedge_avalon_st_streaming_tx_out_data[(`NUM_SLITE_LANES*32-1) -: 96]    <= avalon_st_streaming_tx_out.data[127:32];
	  posedge_avalon_st_streaming_tx_out_valid <= avalon_st_streaming_tx_out.valid;  
      
end
/*
always_ff @(negedge seriallite_custom_phy.tx_clkout[0])
begin
      //for now, let Quartus handle timing. Perhaps clock crossing FIFO is needed. Clocks have the same frequency but possibly different phases
      negedge_avalon_st_streaming_tx_out_data[31:0]    <= avalon_st_streaming_tx_out.data[31:0];
      negedge_avalon_st_streaming_tx_out_data[(`NUM_SLITE_LANES*32-1) -: 96]    <= avalon_st_streaming_tx_out.data[127:32];
      
end
*/
always_ff @(posedge seriallite_custom_phy.tx_clkout[0])
begin
      //for now, let Quartus handle timing. Perhaps clock crossing FIFO is needed. Clocks have the same frequency but possibly different phases
      //txout_atlantic_interface.dat    <= choose_negedge_for_tx_out ? negedge_avalon_st_streaming_tx_out_data : posedge_avalon_st_streaming_tx_out_data;
	  txout_atlantic_interface.dat    <= posedge_avalon_st_streaming_tx_out_data;
	  txout_atlantic_interface.ena <= posedge_avalon_st_streaming_tx_out_valid; 
      
end


// assign txout_atlantic_interface.dat = avalon_st_streaming_tx_out.data; //for now, let Quartus handle timing. Clock crossing FIFO is perhaps needed. Clocks have the same frequency but different phases
assign avalon_st_streaming_tx_out.ready = txout_atlantic_interface.dav;

assign avalon_st_streaming_rx_in.valid = rxin_atlantic_interface.ena;    
assign avalon_st_streaming_rx_in.data = {rxin_atlantic_interface.dat[(`NUM_SLITE_LANES*32-1) -: 96],rxin_atlantic_interface.dat[31:0]}; 	    
assign avalon_st_streaming_rx_in.clk = 	seriallite_custom_phy.rx_clkout[0];
	
assign ctrl_tc_force_train = 1'b0;
assign mreset_n = reset_serialite_n & (!staged_reset_slite) & (!auto_reset_clk_125) & xcvr_tx_ready & xcvr_rx_ready & data_source_ready;
assign rx_clk = rrefclk;

assign xcvr_tx_ready                                               = seriallite_custom_phy.tx_ready;
assign xcvr_rx_ready                                               = seriallite_custom_phy.rx_ready;
assign seriallite_custom_phy.pll_ref_clk          = CLKIN_125MHz;
assign seriallite_custom_phy.tx_forceelecidle     = tx_forceelecidle;
assign stat_tc_pll_locked                                          = seriallite_custom_phy.pll_locked;
assign rx_runningdisp                                              = seriallite_custom_phy.rx_runningdisp;
assign err_rr_disp                                                 = seriallite_custom_phy.rx_disperr;
//assign err_rr_8berrdet                                             = seriallite_custom_phy.rx_errdetect;
assign stat_rr_freqlock                                            = seriallite_custom_phy.rx_is_lockedtoref;
assign rx_is_lockedtodata                                          = seriallite_custom_phy.rx_is_lockedtodata;
assign rx_signaldetect                                             = seriallite_custom_phy.rx_signaldetect;
assign stat_rr_pattdet                                             = seriallite_custom_phy.rx_patterndetect;
assign stat_rr_gxsync                                              = seriallite_custom_phy.rx_syncstatus;
assign rx_bitslipboundaryselectout                                 = seriallite_custom_phy.rx_bitslipboundaryselectout;
assign err_rr_rlv                                                  = seriallite_custom_phy.rx_rlv;
assign tx_coreclk                                                  = seriallite_custom_phy.tx_clkout;
assign rx_coreclk                                                  = seriallite_custom_phy.rx_clkout;
assign seriallite_custom_phy.tx_parallel_data     = tx_parallel_data_in;
assign seriallite_custom_phy.tx_datak             = tx_ctrlenable;
assign rx_parallel_data_out                                        = seriallite_custom_phy.rx_parallel_data;
assign rx_ctrldetect                                               = seriallite_custom_phy.rx_datak;
              
           
generate
           genvar i;
		   for (i = 0; i < `NUM_SLITE_LANES; i++)
		   begin : assign_coreclks
		            assign seriallite_custom_phy.rx_coreclkin[i] = seriallite_custom_phy.rx_clkout[0];  
                	assign seriallite_custom_phy.tx_coreclkin[i] = seriallite_custom_phy.tx_clkout[0];  
		   end
endgenerate


`SLITE_MODULE_NAME 
seriallite_inst
	(
	.rx_parallel_data_out   (rx_parallel_data_out         ),                  /* input	[127:0]	rx_parallel_data_out;               */
	.rx_coreclk             (seriallite_custom_phy.rx_coreclkin[0]          ),                            /* input		rx_coreclk;                             */
	.rx_ctrldetect          (rx_ctrldetect),                         /* input	[(`NUM_SLITE_LANES*`NUM_SLITE_COLUMNS-1):0]	rx_ctrldetect;                      */
	.tx_coreclk             (seriallite_custom_phy.tx_coreclkin[0]          ),                            /* input		tx_coreclk;                             */
	.ctrl_tc_force_train    (ctrl_tc_force_train),                   /* input		ctrl_tc_force_train;                    */
	.mreset_n               (mreset_n                               ),                              /* input		mreset_n;                               */
	.flip_polarity          (flip_polarity /* unused */                               ),                         /* output	[(`NUM_SLITE_LANES-1):0]	flip_polarity;                  */
	.rrefclk                (rrefclk /*Recovered clock of lane 0 (not used in the design, can be used for Signaltap triggering)*/),                               /* output		rrefclk;                            */
	.stat_rr_link           (stat_rr_link /* status only */                 ),                          /* output		stat_rr_link;                       */
	.err_rr_8berrdet        (err_rr_8berrdet              ),                       /* output	[(`NUM_SLITE_LANES*`NUM_SLITE_COLUMNS-1):0]	err_rr_8berrdet;                */
	.tx_parallel_data_in    (tx_parallel_data_in        ),                   /* output	[127:0]	tx_parallel_data_in;            */
	.tx_ctrlenable          (tx_ctrlenable                ),                         /* output	[(`NUM_SLITE_LANES*`NUM_SLITE_COLUMNS-1):0]	tx_ctrlenable;                  */
	.tx_coreclock           (tx_coreclock/*tx_clkout of the transmit PLL (not used in the design, can be used for Signaltap triggering)*/),                          /* output		tx_coreclock;                       */
	//.err_rr_foffre_oflw     (err_rr_foffre_oflw /* status only */           ),                    /* output		err_rr_foffre_oflw;                 */
//	.stat_tc_foffre_empty   (stat_tc_foffre_empty /* status only */         ),                  /* output		stat_tc_foffre_empty;               */
	.err_rr_pol_rev_required(err_rr_pol_rev_required  /* status only */     ),                  /* output	[(`NUM_SLITE_LANES-1):0]	err_rr_pol_rev_required;     */
	.err_rr_dskfifo_oflw    (err_rr_dskfifo_oflw /* status only */          ),                   /* output		err_rr_dskfifo_oflw;                */
	.stat_rr_dskw_done_bc   (stat_rr_dskw_done_bc /* status only */         ),                     /* output		stat_rr_dskw_done_bc;;              */
	.stat_rr_pattdet        (stat_rr_pattdet           ),                       /* input	[(`NUM_SLITE_LANES*`NUM_SLITE_COLUMNS-1):0]	stat_rr_pattdet;                    */
	.err_rr_disp            (err_rr_disp              ),                           /* input	[(`NUM_SLITE_LANES*`NUM_SLITE_COLUMNS-1):0]	err_rr_disp;                        */                
	
	//To/from atlantic interfaces
	
    .txrdp_ena              (txout_atlantic_interface.ena),                             /* input		txrdp_ena;                              */
	.txrdp_dat              (txout_atlantic_interface.dat),                             /* input	[127:0]	txrdp_dat;                          */
    .txrdp_dav              (txout_atlantic_interface.dav),                             /* output		txrdp_dav;                          */
	.rxrdp_ena              (rxin_atlantic_interface.ena ),                             /* output		rxrdp_ena;                          */
	.rxrdp_dat              (rxin_atlantic_interface.dat )                             /* output	[127:0]	rxrdp_dat;                      */

);

    parameter local_regfile_data_numbytes        =   4;
    parameter local_regfile_data_width           =   8*local_regfile_data_numbytes;
    parameter local_regfile_desc_numbytes        =  16;
    parameter local_regfile_desc_width           =   8*local_regfile_desc_numbytes;
    parameter num_of_local_regfile_control_regs  =  24;
    parameter num_of_local_regfile_status_regs   =  48;
	
    wire [local_regfile_data_width-1:0] local_regfile_control_regs_default_vals[num_of_local_regfile_control_regs-1:0];
    wire [local_regfile_data_width-1:0] local_regfile_control_regs             [num_of_local_regfile_control_regs-1:0];
    wire [local_regfile_data_width-1:0] local_regfile_control_regs_bitwidth    [num_of_local_regfile_control_regs-1:0];
    wire [local_regfile_data_width-1:0] local_regfile_control_status           [num_of_local_regfile_status_regs-1:0];
    wire [local_regfile_desc_width-1:0] local_regfile_control_desc             [num_of_local_regfile_control_regs-1:0];
    wire [local_regfile_desc_width-1:0] local_regfile_status_desc              [num_of_local_regfile_status_regs-1:0];
	
    wire local_regfile_control_rd_error;
	wire local_regfile_control_async_reset = 1'b0;
	wire local_regfile_control_wr_error;
	wire local_regfile_control_transaction_error;
	
	
	wire [3:0] local_regfile_main_sm;
	wire [2:0] local_regfile_tx_sm;
	wire [7:0] local_regfile_command_count;
	
	assign local_regfile_control_regs_default_vals[0]  =  1;
    assign local_regfile_control_desc[0]               = "enaAutoStagedRst";
    assign enable_staged_auto_reset                           = local_regfile_control_regs[0];
    assign local_regfile_control_regs_bitwidth[0]      = 1;		

	assign local_regfile_control_regs_default_vals[1] = DEFAULT_WAIT_BETWEEN_STAGED_LOCK_CHECKS;
    assign local_regfile_control_desc[1] = "wait_stg_lck_chk";
    assign wait_between_staged_lock_checks                 = local_regfile_control_regs[1];
    assign local_regfile_control_regs_bitwidth[1] = 32;		
	 
	assign local_regfile_control_regs_default_vals[2] = DEFAULT_WAIT_BETWEEN_STAGED_RESETS;
    assign local_regfile_control_desc[2] = "wait_stg_resets";
    assign wait_between_staged_resets = local_regfile_control_regs[2];
    assign local_regfile_control_regs_bitwidth[2] = 32;		
	

	assign local_regfile_control_regs_default_vals[3] = 0;
    assign local_regfile_control_desc[3] = "use_slow_mode";
    assign use_slow_mode    = local_regfile_control_regs[3];
    assign local_regfile_control_regs_bitwidth[3] = 1;			
/*	
	assign local_regfile_control_regs_default_vals[4] = 0;
    assign local_regfile_control_desc[4] = "loopback_enable";
    assign xcvr_loopback_enable  = local_regfile_control_regs[4];
    assign local_regfile_control_regs_bitwidth[4] = 1;		
	 */
	assign local_regfile_control_regs_default_vals[5] = 1;
    assign local_regfile_control_desc[5] = "resetSerialite_n";
    assign reset_serialite_n = local_regfile_control_regs[5];
    assign local_regfile_control_regs_bitwidth[5] = 1;		
	
	/*
	assign local_regfile_control_regs_default_vals[6] = 0;
    assign local_regfile_control_desc[6] = "ovrride_rx_ready";
    assign override_ready = local_regfile_control_regs[6];
    assign local_regfile_control_regs_bitwidth[6] = 1;		
	 
	assign local_regfile_control_regs_default_vals[7] = 0;
    assign local_regfile_control_desc[7] = "ovrride_tx_ready";
    assign override_tx_ready = local_regfile_control_regs[7];
    assign local_regfile_control_regs_bitwidth[7] = 1;		
	 
	assign local_regfile_control_regs_default_vals[8] = 0;
    assign local_regfile_control_desc[8] = "atlConvFifoFlush";
    assign atlantic_to_st_converter_fifo_flush = local_regfile_control_regs[8];
    assign local_regfile_control_regs_bitwidth[8] = 1;		
	*/
	assign local_regfile_control_regs_default_vals[9] = 1;
    assign local_regfile_control_desc[9] = "reconfigReset_n";
    assign arria_v_xcvr_reconfig_reset_n  = local_regfile_control_regs[9];
    assign local_regfile_control_regs_bitwidth[9] = 1;		
	
	assign local_regfile_control_regs_default_vals[10] = 0;
    assign local_regfile_control_desc[10] = "txForceElecIdle";
    assign tx_forceelecidle  = local_regfile_control_regs[10];
    assign local_regfile_control_regs_bitwidth[10] = 3;	
	/*
    assign local_regfile_control_regs_default_vals[11] = 0;
    assign local_regfile_control_desc[11] = "ChooseNegTXOut";
    assign choose_negedge_for_tx_out  = local_regfile_control_regs[11];
    assign local_regfile_control_regs_bitwidth[11] = 1;	
	*/
	/*
	assign local_regfile_control_regs_default_vals[12] = 0;
    assign local_regfile_control_desc[12] = "phy_and_config_reset";
    assign {reconfig_reset_n, phy_reset_n} = local_regfile_control_regs[12];
    assign local_regfile_control_regs_bitwidth[12] = 2;	
	*/
	
	assign local_regfile_control_regs_default_vals[13] = 0;
    assign local_regfile_control_desc[13] = "independentRsts";
    assign {independent_phy_reset,independent_reconfig_reset}  = local_regfile_control_regs[13];
    assign local_regfile_control_regs_bitwidth[13] = 2;	
		
	assign local_regfile_control_regs_default_vals[14] = 0;
    assign local_regfile_control_desc[14] = "RedoAutoReset100";
    assign redo_auto_reset_100  = local_regfile_control_regs[14];
    assign local_regfile_control_regs_bitwidth[14] = 1;	
	
	doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
	sync_phy_and_reconfig_resets
	(
	 .indata(arria_v_xcvr_reconfig_reset_n),
	 .outdata(reconfig_reset_n),
	 .clk(CLKIN_100MHz)
	);		
	
	doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
	sync_data_source_ready
	(
	 .indata(data_source_ready),
	 .outdata(synced_100_data_source_ready),
	 .clk(CLKIN_100MHz)
	);	
	
	doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
	sync_independent_phy_reset
	(
	 .indata(independent_phy_reset),
	 .outdata(synced_independent_phy_reset),
	 .clk(CLKIN_100MHz)
	);
	
	doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
	sync_independent_reconfig_reset
	(
	 .indata(independent_reconfig_reset),
	 .outdata(synced_independent_reconfig_reset),
	 .clk(CLKIN_100MHz)
	);
	
	assign phy_reset_n = reconfig_reset_n;
	 
	assign local_regfile_control_status[0] = 32'h12345678;
	assign local_regfile_status_desc[0]    ="StatusAlive";
		
    assign local_regfile_control_status[1] =  slite_status;
	assign local_regfile_status_desc[1]    = "slite_status";
	  
    assign local_regfile_control_status[2] = slite_error;
	assign local_regfile_status_desc[2]    = "slite_error"; 
/*
    assign local_regfile_control_status[3] = avalon_st_streaming_rx_in.data[31:0];
	assign local_regfile_status_desc[3]    = "rx_in_data"; 

    assign local_regfile_control_status[4] = avalon_st_streaming_tx_out.data[31:0];
	assign local_regfile_status_desc[4]    = "tx_out_data"; 
*/
    assign local_regfile_control_status[5] = external_link_error_indication;
	assign local_regfile_status_desc[5]    = "extern_link_err"; 

	assign local_regfile_control_status[6] = custom_phy_status;			 
	assign local_regfile_status_desc[6]    = "CustomPhyStatus"; 
/*
	assign local_regfile_control_status[7] ={avalon_st_streaming_rx_in.ready,avalon_st_streaming_rx_in.valid,1'b0,
	                                          1'b0,2'b0,1'b0};
	assign local_regfile_status_desc[7]    = "avst_rx_sigs"; 
	
	
	assign local_regfile_control_status[8] = {avalon_st_streaming_tx_out.ready,avalon_st_streaming_tx_out.valid,1'b0,
	                                          1'b0,2'b0,1'b0};
	assign local_regfile_status_desc[8]    = "avst_tx_sigs"; 
	
	
    assign local_regfile_control_status[9] = rxin_atlantic_interface.dat;
	assign local_regfile_status_desc[9]    = "atl_rx_in_data"; 

    assign local_regfile_control_status[10] = txout_atlantic_interface.dat;
	assign local_regfile_status_desc[10]    = "atl_tx_out_data"; 
	*/
	assign local_regfile_control_status[11] = slite_error[127 -: 32];
	assign local_regfile_status_desc[11]    = "sliteErr_127_96";
	
	
	assign local_regfile_control_status[12] = slite_error[95  -: 32];
	assign local_regfile_status_desc[12]    = "sliteErr_95_64";
	
	
	assign local_regfile_control_status[13] = slite_error[63 -: 32];
	assign local_regfile_status_desc[13]    = "sliteErr_64_32";
	
	
	assign local_regfile_control_status[14] = slite_error[31 -: 32];
	assign local_regfile_status_desc[14]    = "sliteErr_31_0";
	
	assign local_regfile_control_status[15] = slite_status[127 -: 32];
	assign local_regfile_status_desc[15]    = "sliteStat_127_96";
	
	
	assign local_regfile_control_status[16] = slite_status[95  -: 32];
	assign local_regfile_status_desc[16]    = "sliteStat_95_64";
	
	
	assign local_regfile_control_status[17] = slite_status[63 -: 32];
	assign local_regfile_status_desc[17]    = "sliteStat_64_32";
	
	
	assign local_regfile_control_status[18] = slite_status[31 -: 32];
	assign local_regfile_status_desc[18]    = "sliteStat_31_0";
	
	assign local_regfile_control_status[19] = custom_phy_status[127 -: 32];
	assign local_regfile_status_desc[19]    = "PhyStat_127_96";
	
	
	assign local_regfile_control_status[20] = custom_phy_status[95  -: 32];
	assign local_regfile_status_desc[20]    = "PhyStat_95_64";
	
	
	assign local_regfile_control_status[21] = custom_phy_status[63 -: 32];
	assign local_regfile_status_desc[21]    = "PhyStat_64_32";
	
	
	assign local_regfile_control_status[22] = custom_phy_status[31 -: 32];
	assign local_regfile_status_desc[22]    = "PhyStat_31_0";
	
    assign local_regfile_control_status[23] = err_rr_disp;
	assign local_regfile_status_desc[23]    = "err_rr_disp"; 
	

	assign local_regfile_control_status[24] =  err_rr_8berrdet;
	assign local_regfile_status_desc[24]    = "err_rr_8berrdet"; 
	
	assign local_regfile_control_status[25] =  reset_event_counter;
	assign local_regfile_status_desc[25]    = "NumStagedResets"; 
		
	assign local_regfile_control_status[26] =  staged_reset_state;
	assign local_regfile_status_desc[26]    = "stagedResetState"; 
	
	/*
	assign local_regfile_control_status[13] =  {
	                                          err_tc_roe_rsnd_gt4,
	                                          stat_tc_roe_timeout,
	                                          stat_rr_roe_ack,
	                                          stat_rr_roe_nack
											           };
	assign local_regfile_status_desc[13]    = "RetryOnErrorStat"; 
	
	assign local_regfile_control_status[14] = 
			{
			 stat_tc_rdp_thresh_breach,
	         stat_tc_hpp_thresh_breach,			
			 stat_rr_fc_rdp_valid,
	         stat_rr_fc_hpp_valid,		     
	         stat_tc_fc_rdp_retransmit,
	         stat_tc_fc_hpp_retransmit,
			 stat_rr_fc_value
			 };
			 
	assign local_regfile_status_desc[14]    = "FlowCtrlStats"; 
	*/
/*
	assign local_regfile_control_status[15] = 
			{
			 atlantic_to_st_converter_fifo_almost_empty,
			 atlantic_to_st_converter_fifo_almost_full,
			 atlantic_to_st_converter_fifo_empty,
			 atlantic_to_st_converter_fifo_full,
			 atlantic_to_st_converter_fifo_usedw
			 };
			 
	assign local_regfile_status_desc[15]    = "AtlToSTFifoStats"; 
*/
/*
	assign local_regfile_control_status[16] = current_tx_packet_counter;
	assign local_regfile_status_desc[16]    = "tx_packet_cnt"; 
	
	assign local_regfile_control_status[17] = avalon_st_tx_packet_length_in_bytes;
	assign local_regfile_status_desc[17]    = "tx_pkt_len_bytes"; 
	

	
	assign local_regfile_control_status[19] = avalon_st_rx_packet_length_in_bytes;
	assign local_regfile_status_desc[19]    = "rx_pkt_len_bytes"; 
	
	assign local_regfile_control_status[20] = avalon_st_tx_packet_count[47:32];
	assign local_regfile_status_desc[20]    = "tx_pkt_cnt_47_32"; 
	
	assign local_regfile_control_status[21] = avalon_st_tx_packet_count[31:0];
	assign local_regfile_status_desc[21]    = "tx_pkt_cnt_31_0"; 
	
	assign local_regfile_control_status[22] = avalon_st_rx_packet_count[47:32];
	assign local_regfile_status_desc[22]    = "rx_pkt_cnt_47_32"; 
	
	assign local_regfile_control_status[23] = avalon_st_rx_packet_count[31:0];
	assign local_regfile_status_desc[23]    = "rx_pkt_cnt_31_0"; 
			
	assign local_regfile_control_status[24] = avalon_st_tx_total_byte_count[63:32];
	assign local_regfile_status_desc[24]    = "tx_byt_cnt_63_32"; 
	
	assign local_regfile_control_status[25] = avalon_st_tx_total_byte_count[31:0];
	assign local_regfile_status_desc[25]    = "tx_byt_cnt_31_0"; 
	
	assign local_regfile_control_status[26] = avalon_st_rx_total_byte_count[63:32];
	assign local_regfile_status_desc[26]    = "rx_byt_cnt_63_32"; 
	
	assign local_regfile_control_status[27] = avalon_st_rx_total_byte_count[31:0];
	assign local_regfile_status_desc[27]    = "rx_byt_cnt_31_0"; 
	*/
	/*
	assign local_regfile_control_status[28] = tx_parallel_data_in;			 
	assign local_regfile_status_desc[28]    = "txParDatIn"; 

	assign local_regfile_control_status[29] = rx_parallel_data_out;			 
	assign local_regfile_status_desc[29]    = "rxParDatOut"; 

	assign local_regfile_control_status[30] = avalon_st_streaming_tx_out.data[127 -: 32];			 
	assign local_regfile_status_desc[30]    = "avstxout(127_96)"; 

	assign local_regfile_control_status[31] = avalon_st_streaming_tx_out.data[95 -: 32];			 
	assign local_regfile_status_desc[31]    = "avstxout(95_64)"; 

	assign local_regfile_control_status[32] = avalon_st_streaming_tx_out.data[63 -: 32];			 
	assign local_regfile_status_desc[32]    = "avstxout(63_32)"; 

	assign local_regfile_control_status[33] = avalon_st_streaming_tx_out.data[31 -: 32];			 
	assign local_regfile_status_desc[33]    = "avstxout(31_0)"; 

	
	assign local_regfile_control_status[34] = avalon_st_streaming_rx_in.data[127 -: 32];			 
	assign local_regfile_status_desc[34]    = "avsrxin(127_96)"; 

	assign local_regfile_control_status[35] = avalon_st_streaming_rx_in.data[95 -: 32];			 
	assign local_regfile_status_desc[35]    = "avsrxin(95_64)"; 

	assign local_regfile_control_status[36] = avalon_st_streaming_rx_in.data[63 -: 32];			 
	assign local_regfile_status_desc[36]    = "avsrxin(63_32)"; 

	assign local_regfile_control_status[37] = avalon_st_streaming_rx_in.data[31 -: 32];			 
	assign local_regfile_status_desc[37]    = "avsrxin(31_0)"; 
	*/
    assign local_regfile_control_status[38] = seriallite_custom_phy.rx_errdetect;			 
	assign local_regfile_status_desc[38]    = "rx_errdetect"; 

	uart_controlled_register_file_ver3
	#( 
	  .NUM_OF_CONTROL_REGS(num_of_local_regfile_control_regs),
	  .NUM_OF_STATUS_REGS(num_of_local_regfile_status_regs),
	  .DATA_WIDTH_IN_BYTES  (local_regfile_data_numbytes),
      .DESC_WIDTH_IN_BYTES  (local_regfile_desc_numbytes),
	  .INIT_ALL_CONTROL_REGS_TO_DEFAULT (1'b0),  
	  .CONTROL_REGS_DEFAULT_VAL         (0),
	  .CLOCK_SPEED_IN_HZ(DIAGNOSTIC_CLOCK_SPEED_IN_HZ),
      .UART_BAUD_RATE_IN_HZ(REGFILE_BAUD_RATE)
	)
	local_uart_register_file
	(	
	 .DISPLAY_NAME(diagnostic_uart_name),
	 .CLK(CLKIN_50MHz),
	 .REG_ACTIVE_HIGH_ASYNC_RESET(local_regfile_control_async_reset),
	 .CONTROL(local_regfile_control_regs),
	 .CONTROL_DESC(local_regfile_control_desc),
	 .CONTROL_BITWIDTH(local_regfile_control_regs_bitwidth),
	 .STATUS(local_regfile_control_status),
	 .STATUS_DESC (local_regfile_status_desc),
	 .CONTROL_INIT_VAL(local_regfile_control_regs_default_vals),
	 .TRANSACTION_ERROR(local_regfile_control_transaction_error),
	 .WR_ERROR(local_regfile_control_wr_error),
	 .RD_ERROR(local_regfile_control_rd_error),
	 .USER_TYPE(uart_regfile_types::ARRIA_V_SLITE_FOUR_LANE_DIAGNOSTIC_REGFILE),
	 .NUM_SECONDARY_UARTS (TOP_UART_NUM_SECONDARY_UARTS),
     .ADDRESS_OF_THIS_UART(TOP_UART_ADDRESS_OF_THIS_UART),
     .IS_SECONDARY_UART   (TOP_UART_IS_SECONDARY_UART),	 
	 
	 //UART
	 .uart_active_high_async_reset(1'b0),
	 .rxd(uart_rx),
	 .txd(slite_diagnostic_uart_tx),
	 
	 //UART DEBUG
	 .main_sm               (local_regfile_main_sm),
	 .tx_sm                 (local_regfile_tx_sm),
	 .command_count         (local_regfile_command_count)
	  
	);
	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  XCVR PHY Uart
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
parameter slit_phy_local_regfile_address_numbits         =  16;
parameter slit_phy_local_regfile_data_numbytes           =  4;
parameter slit_phy_local_regfile_desc_numbytes           =  16;
parameter slit_phy_num_of_local_regfile_control_regs     =  32'h200; //number of words in the address space

	
uart_wishbone_bridge_interface 	
#(                                                                                                     
  .DATA_NUMBYTES                                (slit_phy_local_regfile_data_numbytes                       ),
  .DESC_NUMBYTES                                (slit_phy_local_regfile_desc_numbytes                       ),
  .NUM_OF_CONTROL_REGS                          (slit_phy_num_of_local_regfile_control_regs               ) //taken from QSYS address space
)
phy_uart_interface_pins();

	uart_controlled_avalon_mm_master_no_pipeline_w_interfaces
		#(
			.NUM_OF_CONTROL_REGS   (slit_phy_num_of_local_regfile_control_regs),
			.DATA_NUMBYTES         (slit_phy_local_regfile_data_numbytes      ),
			.DESC_NUMBYTES         (slit_phy_local_regfile_desc_numbytes      ),
			.ADDRESS_WIDTH_IN_BITS (slit_phy_local_regfile_address_numbits    ),		  
			.CLOCK_SPEED_IN_HZ(PHY_CTRL_CLOCK_SPEED_IN_HZ),
            .UART_BAUD_RATE_IN_HZ(REGFILE_BAUD_RATE),
			.USE_AUTO_RESET(1'b1),
			.DISABLE_ERROR_MONITORING(1'b1)				
		)
		uart_control_of_arria_v_seriallite_xcvr_standalone_phy
		(
		 .uart_regfile_interface_pins(phy_uart_interface_pins),
		 .avalon_mm_slave_interface_pins(phy_avalon_mm_control_interface_pins)
		);
		
assign phy_uart_interface_pins.display_name         = phy_uart_name;
assign phy_uart_interface_pins.clk                  = CLKIN_100MHz;
assign phy_uart_interface_pins.async_reset          = local_regfile_control_async_reset;
assign phy_uart_interface_pins.user_type            = uart_regfile_types::ARRIA_V_SLITE_FOUR_LANE_XCVR_PHY_CTRL_REGFILE;
assign phy_uart_interface_pins.num_secondary_uarts  = 0 ; 
assign phy_uart_interface_pins.address_of_this_uart = TOP_UART_ADDRESS_OF_THIS_UART+1;
assign phy_uart_interface_pins.is_secondary_uart    = 1;
assign phy_uart_interface_pins.rxd                  = uart_rx;
assign slite_phy_uart_tx                            = phy_uart_interface_pins.txd;

	avalon_mm_simple_bridge_interface 
	#(
		.num_address_bits(32),
		.num_data_bits(32)
	)
	phy_avalon_mm_control_interface_pins();

	`SLITE_PHY_MODULE_NAME
    seriallite_custom_phy_megafunction_inst	
	(
		/* input  wire         */ .phy_mgmt_clk               (CLKIN_100MHz),                                                                                                  //                phy_mgmt_clk.clk
		/* input  wire         */ .phy_mgmt_clk_reset         (RESET_FOR_CLKIN_100MHz || auto_reset_clk_100 || !phy_reset_n || synced_independent_phy_reset || !synced_100_data_source_ready),                                                                                            //          phy_mgmt_clk_reset.reset
		/* input  wire [8:0]   */ .phy_mgmt_address           ({phy_avalon_mm_control_interface_pins.address} ),                 //                    phy_mgmt.address
		/* input  wire         */ .phy_mgmt_read              (phy_avalon_mm_control_interface_pins.read                                       ),                                       //              //                            .read
		/* output wire [31:0]  */ .phy_mgmt_readdata          (phy_avalon_mm_control_interface_pins.readdata                                   ),                                   //              //                            .readdata
		/* output wire         */ .phy_mgmt_waitrequest       (phy_avalon_mm_control_interface_pins.waitrequest                                      ),                                      //        //                            .waitrequest
		/* input  wire         */ .phy_mgmt_write             (phy_avalon_mm_control_interface_pins.write                                ),                                  //                  //                            .write
		/* input  wire [31:0]  */ .phy_mgmt_writedata         (phy_avalon_mm_control_interface_pins.writedata                                ),                                //                //                            .writedata
		/* output wire         */ .tx_ready                   (seriallite_custom_phy.tx_ready                                                               ),                    //                    tx_ready.export
		/* output wire         */ .rx_ready                   (seriallite_custom_phy.rx_ready                                                               ),                    //                    rx_ready.export
		/* input  wire [0:0]   */ .pll_ref_clk                (seriallite_custom_phy.pll_ref_clk                                                            ),                 //                 pll_ref_clk.clk
		/* output wire [(`NUM_SLITE_LANES-1):0]   */ .tx_serial_data             (XCVR_TX                                                        ),              //              tx_serial_data.export
		/* input  wire [(`NUM_SLITE_LANES-1):0]   */ .tx_forceelecidle           (seriallite_custom_phy.tx_forceelecidle                                                       ),            //            tx_forceelecidle.export
		/* output wire [0:0]   */ .pll_locked                 (seriallite_custom_phy.pll_locked                                                             ),                  //                  pll_locked.export
		.rx_rmfifodatainserted,
		.rx_rmfifodatadeleted,
		/* input  wire [(`NUM_SLITE_LANES-1):0]   */ .rx_serial_data             (XCVR_RX                                                         ),              //              rx_serial_data.export
		/* output wire [(`NUM_SLITE_LANES*4-1):0]  */ .rx_runningdisp             (seriallite_custom_phy.rx_runningdisp                                                         ),              //              rx_runningdisp.export
		/* output wire [(`NUM_SLITE_LANES*4-1):0]  */ .rx_disperr                 (seriallite_custom_phy.rx_disperr                                                             ),                  //                  rx_disperr.export
		/* output wire [(`NUM_SLITE_LANES*4-1):0]  */ .rx_errdetect               (seriallite_custom_phy.rx_errdetect                                                           ),                //                rx_errdetect.export
		/* output wire [(`NUM_SLITE_LANES-1):0]   */ .rx_is_lockedtoref          (seriallite_custom_phy.rx_is_lockedtoref                                                      ),           //           rx_is_lockedtoref.export
		/* output wire [(`NUM_SLITE_LANES-1):0]   */ .rx_is_lockedtodata         (seriallite_custom_phy.rx_is_lockedtodata                                                     ),          //          rx_is_lockedtodata.export
		/* output wire [(`NUM_SLITE_LANES-1):0]   */ .rx_signaldetect            (seriallite_custom_phy.rx_signaldetect                                                        ),             //             rx_signaldetect.export
		/* output wire [(`NUM_SLITE_LANES*4-1):0]  */ .rx_patterndetect           (seriallite_custom_phy.rx_patterndetect                                                       ),            //            rx_patterndetect.export
		/* output wire [(`NUM_SLITE_LANES*4-1):0]  */ .rx_syncstatus              (seriallite_custom_phy.rx_syncstatus                                                          ),               //               rx_syncstatus.export
		/* output wire [19:0]  */ .rx_bitslipboundaryselectout(seriallite_custom_phy.rx_bitslipboundaryselectout                                            ), // rx_bitslipboundaryselectout.export
		/* output wire [(`NUM_SLITE_LANES-1):0]   */ .rx_rlv                     (seriallite_custom_phy.rx_rlv                                                                 ),                      //                      rx_rlv.export
		/* input  wire [(`NUM_SLITE_LANES-1):0]   */ .tx_coreclkin               (seriallite_custom_phy.tx_coreclkin                                                           ),                //                tx_coreclkin.export
		/* input  wire [(`NUM_SLITE_LANES-1):0]   */ .rx_coreclkin               (seriallite_custom_phy.rx_coreclkin                                                           ),                //                rx_coreclkin.export
		/* output wire [(`NUM_SLITE_LANES-1):0]   */ .tx_clkout                  (seriallite_custom_phy.tx_clkout                                                              ),                   //                   tx_clkout.export
		/* output wire [(`NUM_SLITE_LANES-1):0]   */ .rx_clkout                  (seriallite_custom_phy.rx_clkout                                                              ),                   //                   rx_clkout.export
		/* input  wire [127:0] */ .tx_parallel_data           (seriallite_custom_phy.tx_parallel_data                                                       ),            //            tx_parallel_data.export
		/* input  wire [(`NUM_SLITE_LANES*4-1):0]  */ .tx_datak                   (seriallite_custom_phy.tx_datak                                                               ),                    //                    tx_datak.export
		/* output wire [127:0] */ .rx_parallel_data           (seriallite_custom_phy.rx_parallel_data                                                       ),            //            rx_parallel_data.export
		/* output wire [(`NUM_SLITE_LANES*4-1):0]  */ .rx_datak                   (seriallite_custom_phy.rx_datak                                                               ),                    //                    rx_datak.export
		/* output wire [367:0] */ .reconfig_from_xcvr         (reconfig_from_xcvr                                                                           ),          //          reconfig_from_xcvr.reconfig_from_xcvr
		/* input  wire [559:0] */ .reconfig_to_xcvr           (reconfig_to_xcvr                                                                             ) //            reconfig_to_xcvr.reconfig_to_xcvr
	);	

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  SCVR Reconfig Uart
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
parameter slit_reconfig_local_regfile_address_numbits         =  16;
parameter slit_reconfig_local_regfile_data_numbytes           =  4;
parameter slit_reconfig_local_regfile_desc_numbytes           =  16;
parameter slit_reconfig_num_of_local_regfile_control_regs     =  32'h45; //number of words in the address space

	
uart_wishbone_bridge_interface 	
#(                                                                                                     
  .DATA_NUMBYTES                                (slit_reconfig_local_regfile_data_numbytes                       ),
  .DESC_NUMBYTES                                (slit_reconfig_local_regfile_desc_numbytes                       ),
  .NUM_OF_CONTROL_REGS                          (slit_reconfig_num_of_local_regfile_control_regs               ) //taken from QSYS address space
)
reconfig_uart_interface_pins();

assign reconfig_uart_interface_pins.display_name         = reconfig_uart_name;
assign reconfig_uart_interface_pins.clk                  = CLKIN_100MHz;
assign reconfig_uart_interface_pins.async_reset          = local_regfile_control_async_reset;
assign reconfig_uart_interface_pins.user_type            = uart_regfile_types::ARRIA_V_SLITE_FOUR_LANE_XCVR_RECONFIG_CTRL_REGFILE;
assign reconfig_uart_interface_pins.num_secondary_uarts  = 0; 
assign reconfig_uart_interface_pins.address_of_this_uart = TOP_UART_ADDRESS_OF_THIS_UART+2;
assign reconfig_uart_interface_pins.is_secondary_uart    = 1;
assign reconfig_uart_interface_pins.rxd                  = uart_rx;
assign slite_reconfig_uart_tx                            = reconfig_uart_interface_pins.txd;

	avalon_mm_simple_bridge_interface 
	#(
		.num_address_bits(32),
		.num_data_bits(32)
	)
	reconfig_avalon_mm_control_interface_pins();
	
	uart_controlled_avalon_mm_master_no_pipeline_w_interfaces
	#(
		.NUM_OF_CONTROL_REGS   (slit_reconfig_num_of_local_regfile_control_regs),
		.DATA_NUMBYTES         (slit_reconfig_local_regfile_data_numbytes      ),
		.DESC_NUMBYTES         (slit_reconfig_local_regfile_desc_numbytes      ),
		.ADDRESS_WIDTH_IN_BITS (slit_reconfig_local_regfile_address_numbits    ),		  
		.CLOCK_SPEED_IN_HZ(PHY_CTRL_CLOCK_SPEED_IN_HZ),
        .UART_BAUD_RATE_IN_HZ(REGFILE_BAUD_RATE),
		.USE_AUTO_RESET(1'b1),
		.DISABLE_ERROR_MONITORING(1'b1)				
	)
	uart_control_of_arria_v_seriallite_xcvr_standalone_reconfig
	(
	 .uart_regfile_interface_pins(reconfig_uart_interface_pins),
	 .avalon_mm_slave_interface_pins(reconfig_avalon_mm_control_interface_pins)
	);
		
`SLITE_RECONFIG_MODULE_NAME
seriallite_custom_phy_reconfig_inst	(
			/* output wire        */ .reconfig_busy            (xcvr_reconfig_busy), //      reconfig_busy.reconfig_busy
			/* output wire        */ .tx_cal_busy              (tx_cal_busy  ), //        tx_cal_busy.tx_cal_busy
			/* output wire        */ .rx_cal_busy              (rx_cal_busy  ), //        rx_cal_busy.tx_cal_busy
			/* input  wire        */ .mgmt_clk_clk             (CLKIN_100MHz)            , //       mgmt_clk_clk.clk
			/* input  wire        */ .mgmt_rst_reset           (RESET_FOR_CLKIN_100MHz || staged_reset_phy_clk_100 || auto_reset_clk_100 || !reconfig_reset_n || synced_independent_reconfig_reset || !synced_100_data_source_ready)  , //     mgmt_rst_reset.reset
			/* input  wire [6:0]  */ .reconfig_mgmt_address    ({reconfig_avalon_mm_control_interface_pins.address}), //      reconfig_mgmt.address
			/* input  wire        */ .reconfig_mgmt_read       (reconfig_avalon_mm_control_interface_pins.read                                      ), //                   .read
			/* output wire [31:0] */ .reconfig_mgmt_readdata   (reconfig_avalon_mm_control_interface_pins.readdata                                  ), //                   .readdata
			/* output wire        */ .reconfig_mgmt_waitrequest(reconfig_avalon_mm_control_interface_pins.waitrequest                                     ), //                   .waitrequest
			/* input  wire        */ .reconfig_mgmt_write      (reconfig_avalon_mm_control_interface_pins.write                                 ), //                   .write
			/* input  wire [31:0] */ .reconfig_mgmt_writedata  (reconfig_avalon_mm_control_interface_pins.writedata                               ), //                   .writedata
			/* output wire [559:0]*/ .reconfig_to_xcvr         (reconfig_to_xcvr  ), //   reconfig_to_xcvr.reconfig_to_xcvr
			/* input  wire [367:0]*/ .reconfig_from_xcvr       (reconfig_from_xcvr)  // reconfig_from_xcvr.reconfig_from_xcvr
		);


doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_slite_link_lock_indication
(
// .indata(!(|err_rr_disp)),
  .indata(!external_link_error_indication),
 .outdata(slite_link_lock_indication),
 .clk(CLKIN_50MHz)
);		

always_ff @(posedge CLKIN_50MHz)
begin
    if (reset_event_occurred_pulse)
	begin
	     reset_event_counter <= reset_event_counter + 1;
	end
end
		
wait_and_check_for_lock_and_do_staged_reset 
#(
.wait_counter_bits(32)
)
wait_and_check_for_lock_and_do_staged_reset_inst (
// port map - connection between master ports and signals/registers   
	.clk(CLKIN_50MHz),
	.enable(enable_staged_auto_reset),
	.lock_indication(slite_link_lock_indication),
	.programmable_wait_amount(),
	.reset(1'b0),
	.reset_event_occurred_pulse(reset_event_occurred_pulse),
	.reset_inner(staged_reset_phy  ),
	.reset_outer(staged_reset_slite),
	.select_wait_period(),
	.start_delay_counter(),
	.state(staged_reset_state),
	.wait_between_lock_checks(wait_between_staged_lock_checks),
	.wait_between_resets     (wait_between_staged_resets     ),
	.wait_counter_finished   (),
	.use_slow_mode(use_slow_mode)
);

endmodule
`default_nettype wire

