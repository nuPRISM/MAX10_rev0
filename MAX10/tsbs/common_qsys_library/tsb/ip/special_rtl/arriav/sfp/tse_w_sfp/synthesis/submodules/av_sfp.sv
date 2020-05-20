`default_nettype none
module av_sfp (
		output wire         busy,           //      alt_xcvr_reconfig_reconfig_busy.reconfig_busy
		output wire         tx_cal_busy,               //        alt_xcvr_reconfig_rx_cal_busy.tx_cal_busy
		output wire         rx_cal_busy,               //        alt_xcvr_reconfig_tx_cal_busy.tx_cal_busy
		output wire         avalon_slave_waitrequest,                                //                         avalon_slave.waitrequest
		output wire [31:0]  avalon_slave_readdata,                                   //                                     .readdata
		output wire         avalon_slave_readdatavalid,                              //                                     .readdatavalid
		input  wire [0:0]   avalon_slave_burstcount,                                 //                                     .burstcount
		input  wire [31:0]  avalon_slave_writedata,                                  //                                     .writedata
		input  wire [15:0]  avalon_slave_address,                                    //                                     .address
		input  wire         avalon_slave_write,                                      //                                     .write
		input  wire         avalon_slave_read,                                       //                                     .read
		input  wire [3:0]   avalon_slave_byteenable,                                 //                                     .byteenable
		input  wire         avalon_slave_debugaccess,                                //                                     .debugaccess
		input  wire         ethernet_clk_125mhz_control_clk,                                 //                  ethernet_clk_125mhz.clk
		input  wire         ethernet_clk_125mhz_reset_n,                        //            ethernet_clk_125mhz_reset.reset_n
		input  wire         ethernet_125Mhz_pll_base_clk,                        //            ethernet_clk_125mhz_reset.reset_n
		output wire         ethernet_tx_ready,                                                                                               //     arriav_v_standalone_gigabit_xcvr.tx_ready
		output wire         ethernet_rx_ready,
        output wire         xcvr_clk_pll_locked,
        output  wire        SFP_TX,		//                                     .rx_ready			
        input  wire        SFP_RX,
        output  wire        tbi_tx_clkout,
		output  wire        tbi_rx_clkout,
		input  wire  [9:0]  tbi_tx_d,
		output  wire [9:0] tbi_rx_d,
		output wire        rx_is_lockedtoref   ,
		output wire        rx_is_lockedtodata  ,
		output wire        rx_signaldetect,
        input wire         tx_forceelecidle		
	);
        
		logic [91:0]  alt_xcvr_reconfig_reconfig_from_xcvr_reconfig_from_xcvr;                                                                                 // alt_xcvr_reconfig_reconfig_from_xcvr.reconfig_from_xcvr
		logic [139:0] alt_xcvr_reconfig_reconfig_to_xcvr_reconfig_to_xcvr;                                                                                     //   alt_xcvr_reconfig_reconfig_to_xcvr.reconfig_to_xcvr                                                                                  //                                     .rx_clkout

    arria_v_sfp arria_v_sfp_inst (
        .alt_xcvr_reconfig_reconfig_busy_reconfig_busy           ( busy),           //      alt_xcvr_reconfig_reconfig_busy.reconfig_busy
        .alt_xcvr_reconfig_reconfig_from_xcvr_reconfig_from_xcvr ( alt_xcvr_reconfig_reconfig_from_xcvr_reconfig_from_xcvr), // alt_xcvr_reconfig_reconfig_from_xcvr.reconfig_from_xcvr
        .alt_xcvr_reconfig_reconfig_to_xcvr_reconfig_to_xcvr     ( alt_xcvr_reconfig_reconfig_to_xcvr_reconfig_to_xcvr),     //   alt_xcvr_reconfig_reconfig_to_xcvr.reconfig_to_xcvr
        .alt_xcvr_reconfig_rx_cal_busy_tx_cal_busy               ( rx_cal_busy),               //        alt_xcvr_reconfig_rx_cal_busy.tx_cal_busy
        .alt_xcvr_reconfig_tx_cal_busy_tx_cal_busy               ( tx_cal_busy),               //        alt_xcvr_reconfig_tx_cal_busy.tx_cal_busy
        .arriav_v_standalone_gigabit_xcvr_tx_ready               ( ethernet_tx_ready                             ), //     arriav_v_standalone_gigabit_xcvr.tx_ready
        .arriav_v_standalone_gigabit_xcvr_rx_ready               ( ethernet_rx_ready                             ), //                                     .rx_ready
        .arriav_v_standalone_gigabit_xcvr_pll_ref_clk            ( ethernet_125Mhz_pll_base_clk                    ), //                                     .pll_ref_clk
        .arriav_v_standalone_gigabit_xcvr_tx_serial_data         ( SFP_TX                             ), //                                     .tx_serial_data
        .arriav_v_standalone_gigabit_xcvr_tx_forceelecidle       ( tx_forceelecidle), //                                     .tx_forceelecidle
        .arriav_v_standalone_gigabit_xcvr_pll_locked             ( xcvr_clk_pll_locked                        ), //                                     .pll_locked
        .arriav_v_standalone_gigabit_xcvr_rx_serial_data         ( SFP_RX                           ), //                                     .rx_serial_data
        .arriav_v_standalone_gigabit_xcvr_rx_is_lockedtoref      ( rx_is_lockedtoref                         ), //                                     .rx_is_lockedtoref
        .arriav_v_standalone_gigabit_xcvr_rx_is_lockedtodata     ( rx_is_lockedtodata                      ), //                                     .rx_is_lockedtodata
        .arriav_v_standalone_gigabit_xcvr_rx_signaldetect        ( rx_signaldetect                          ), //                                     .rx_signaldetect
        .arriav_v_standalone_gigabit_xcvr_tx_clkout              ( tbi_tx_clkout       ), //                                     .tx_clkout
        .arriav_v_standalone_gigabit_xcvr_rx_clkout              ( tbi_rx_clkout         ), //                                      .rx_clkout
        .arriav_v_standalone_gigabit_xcvr_tx_parallel_data       ( tbi_tx_d                                ), //                                     .tx_parallel_data
        .arriav_v_standalone_gigabit_xcvr_rx_parallel_data       ( tbi_rx_d                       ), //                                     .rx_parallel_data
        .arriav_v_standalone_gigabit_xcvr_reconfig_from_xcvr     ( alt_xcvr_reconfig_reconfig_from_xcvr_reconfig_from_xcvr                             ), //                                     .reconfig_from_xcvr
        .arriav_v_standalone_gigabit_xcvr_reconfig_to_xcvr       ( alt_xcvr_reconfig_reconfig_to_xcvr_reconfig_to_xcvr                               ), //                                     .reconfig_to_xcvr
        .avalon_slave_waitrequest                                (avalon_slave_waitrequest       ),                                //                         avalon_slave.waitrequest
        .avalon_slave_readdata                                   (avalon_slave_readdata          ),                                   //                                     .readdata
        .avalon_slave_readdatavalid                              (avalon_slave_readdatavalid     ),                              //                                     .readdatavalid
        .avalon_slave_burstcount                                 (avalon_slave_burstcount        ),                                 //                                     .burstcount
        .avalon_slave_writedata                                  (avalon_slave_writedata         ),                                  //                                     .writedata
        .avalon_slave_address                                    (avalon_slave_address           ),                                    //                                     .address
        .avalon_slave_write                                      (avalon_slave_write             ),                                      //                                     .write
        .avalon_slave_read                                       (avalon_slave_read              ),                                       //                                     .read
        .avalon_slave_byteenable                                 (avalon_slave_byteenable        ),                                 //                                     .byteenable
        .avalon_slave_debugaccess                                (avalon_slave_debugaccess       ),                                //                                     .debugaccess
        .ethernet_clk_125mhz_clk                                 (ethernet_clk_125mhz_control_clk),                                 //                  ethernet_clk_125mhz.clk
        .ethernet_clk_125mhz_reset_reset_n                       (ethernet_clk_125mhz_reset_n)                        //            ethernet_clk_125mhz_reset.reset_n
    );

endmodule
`default_nettype wire