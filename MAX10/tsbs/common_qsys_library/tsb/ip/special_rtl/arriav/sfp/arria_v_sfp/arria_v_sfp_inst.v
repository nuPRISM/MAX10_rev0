	arria_v_sfp u0 (
		.alt_xcvr_reconfig_reconfig_busy_reconfig_busy           (<connected-to-alt_xcvr_reconfig_reconfig_busy_reconfig_busy>),           //      alt_xcvr_reconfig_reconfig_busy.reconfig_busy
		.alt_xcvr_reconfig_reconfig_from_xcvr_reconfig_from_xcvr (<connected-to-alt_xcvr_reconfig_reconfig_from_xcvr_reconfig_from_xcvr>), // alt_xcvr_reconfig_reconfig_from_xcvr.reconfig_from_xcvr
		.alt_xcvr_reconfig_reconfig_to_xcvr_reconfig_to_xcvr     (<connected-to-alt_xcvr_reconfig_reconfig_to_xcvr_reconfig_to_xcvr>),     //   alt_xcvr_reconfig_reconfig_to_xcvr.reconfig_to_xcvr
		.alt_xcvr_reconfig_rx_cal_busy_tx_cal_busy               (<connected-to-alt_xcvr_reconfig_rx_cal_busy_tx_cal_busy>),               //        alt_xcvr_reconfig_rx_cal_busy.tx_cal_busy
		.alt_xcvr_reconfig_tx_cal_busy_tx_cal_busy               (<connected-to-alt_xcvr_reconfig_tx_cal_busy_tx_cal_busy>),               //        alt_xcvr_reconfig_tx_cal_busy.tx_cal_busy
		.arriav_v_standalone_gigabit_xcvr_tx_ready               (<connected-to-arriav_v_standalone_gigabit_xcvr_tx_ready>),               //     arriav_v_standalone_gigabit_xcvr.tx_ready
		.arriav_v_standalone_gigabit_xcvr_rx_ready               (<connected-to-arriav_v_standalone_gigabit_xcvr_rx_ready>),               //                                     .rx_ready
		.arriav_v_standalone_gigabit_xcvr_pll_ref_clk            (<connected-to-arriav_v_standalone_gigabit_xcvr_pll_ref_clk>),            //                                     .pll_ref_clk
		.arriav_v_standalone_gigabit_xcvr_tx_serial_data         (<connected-to-arriav_v_standalone_gigabit_xcvr_tx_serial_data>),         //                                     .tx_serial_data
		.arriav_v_standalone_gigabit_xcvr_tx_forceelecidle       (<connected-to-arriav_v_standalone_gigabit_xcvr_tx_forceelecidle>),       //                                     .tx_forceelecidle
		.arriav_v_standalone_gigabit_xcvr_pll_locked             (<connected-to-arriav_v_standalone_gigabit_xcvr_pll_locked>),             //                                     .pll_locked
		.arriav_v_standalone_gigabit_xcvr_rx_serial_data         (<connected-to-arriav_v_standalone_gigabit_xcvr_rx_serial_data>),         //                                     .rx_serial_data
		.arriav_v_standalone_gigabit_xcvr_rx_is_lockedtoref      (<connected-to-arriav_v_standalone_gigabit_xcvr_rx_is_lockedtoref>),      //                                     .rx_is_lockedtoref
		.arriav_v_standalone_gigabit_xcvr_rx_is_lockedtodata     (<connected-to-arriav_v_standalone_gigabit_xcvr_rx_is_lockedtodata>),     //                                     .rx_is_lockedtodata
		.arriav_v_standalone_gigabit_xcvr_rx_signaldetect        (<connected-to-arriav_v_standalone_gigabit_xcvr_rx_signaldetect>),        //                                     .rx_signaldetect
		.arriav_v_standalone_gigabit_xcvr_tx_clkout              (<connected-to-arriav_v_standalone_gigabit_xcvr_tx_clkout>),              //                                     .tx_clkout
		.arriav_v_standalone_gigabit_xcvr_rx_clkout              (<connected-to-arriav_v_standalone_gigabit_xcvr_rx_clkout>),              //                                     .rx_clkout
		.arriav_v_standalone_gigabit_xcvr_tx_parallel_data       (<connected-to-arriav_v_standalone_gigabit_xcvr_tx_parallel_data>),       //                                     .tx_parallel_data
		.arriav_v_standalone_gigabit_xcvr_rx_parallel_data       (<connected-to-arriav_v_standalone_gigabit_xcvr_rx_parallel_data>),       //                                     .rx_parallel_data
		.arriav_v_standalone_gigabit_xcvr_reconfig_from_xcvr     (<connected-to-arriav_v_standalone_gigabit_xcvr_reconfig_from_xcvr>),     //                                     .reconfig_from_xcvr
		.arriav_v_standalone_gigabit_xcvr_reconfig_to_xcvr       (<connected-to-arriav_v_standalone_gigabit_xcvr_reconfig_to_xcvr>),       //                                     .reconfig_to_xcvr
		.avalon_slave_waitrequest                                (<connected-to-avalon_slave_waitrequest>),                                //                         avalon_slave.waitrequest
		.avalon_slave_readdata                                   (<connected-to-avalon_slave_readdata>),                                   //                                     .readdata
		.avalon_slave_readdatavalid                              (<connected-to-avalon_slave_readdatavalid>),                              //                                     .readdatavalid
		.avalon_slave_burstcount                                 (<connected-to-avalon_slave_burstcount>),                                 //                                     .burstcount
		.avalon_slave_writedata                                  (<connected-to-avalon_slave_writedata>),                                  //                                     .writedata
		.avalon_slave_address                                    (<connected-to-avalon_slave_address>),                                    //                                     .address
		.avalon_slave_write                                      (<connected-to-avalon_slave_write>),                                      //                                     .write
		.avalon_slave_read                                       (<connected-to-avalon_slave_read>),                                       //                                     .read
		.avalon_slave_byteenable                                 (<connected-to-avalon_slave_byteenable>),                                 //                                     .byteenable
		.avalon_slave_debugaccess                                (<connected-to-avalon_slave_debugaccess>),                                //                                     .debugaccess
		.ethernet_clk_125mhz_clk                                 (<connected-to-ethernet_clk_125mhz_clk>),                                 //                  ethernet_clk_125mhz.clk
		.ethernet_clk_125mhz_reset_reset_n                       (<connected-to-ethernet_clk_125mhz_reset_reset_n>)                        //            ethernet_clk_125mhz_reset.reset_n
	);

