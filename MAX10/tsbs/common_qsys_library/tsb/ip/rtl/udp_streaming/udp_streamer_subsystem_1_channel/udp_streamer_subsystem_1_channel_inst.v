	udp_streamer_subsystem_1_channel u0 (
		.clk_100_clk                                (<connected-to-clk_100_clk>),                                //                      clk_100.clk
		.dc_fifo_0_in_clk_clk                       (<connected-to-dc_fifo_0_in_clk_clk>),                       //             dc_fifo_0_in_clk.clk
		.external_avalon_st_packet_in_data          (<connected-to-external_avalon_st_packet_in_data>),          // external_avalon_st_packet_in.data
		.external_avalon_st_packet_in_valid         (<connected-to-external_avalon_st_packet_in_valid>),         //                             .valid
		.external_avalon_st_packet_in_ready         (<connected-to-external_avalon_st_packet_in_ready>),         //                             .ready
		.external_avalon_st_packet_in_startofpacket (<connected-to-external_avalon_st_packet_in_startofpacket>), //                             .startofpacket
		.external_avalon_st_packet_in_endofpacket   (<connected-to-external_avalon_st_packet_in_endofpacket>),   //                             .endofpacket
		.external_avalon_st_packet_in_empty         (<connected-to-external_avalon_st_packet_in_empty>),         //                             .empty
		.external_packet_clk_clk                    (<connected-to-external_packet_clk_clk>),                    //          external_packet_clk.clk
		.external_packet_reset_reset_n              (<connected-to-external_packet_reset_reset_n>),              //        external_packet_reset.reset_n
		.nios_bridge_s0_100_mhz_waitrequest         (<connected-to-nios_bridge_s0_100_mhz_waitrequest>),         //       nios_bridge_s0_100_mhz.waitrequest
		.nios_bridge_s0_100_mhz_readdata            (<connected-to-nios_bridge_s0_100_mhz_readdata>),            //                             .readdata
		.nios_bridge_s0_100_mhz_readdatavalid       (<connected-to-nios_bridge_s0_100_mhz_readdatavalid>),       //                             .readdatavalid
		.nios_bridge_s0_100_mhz_burstcount          (<connected-to-nios_bridge_s0_100_mhz_burstcount>),          //                             .burstcount
		.nios_bridge_s0_100_mhz_writedata           (<connected-to-nios_bridge_s0_100_mhz_writedata>),           //                             .writedata
		.nios_bridge_s0_100_mhz_address             (<connected-to-nios_bridge_s0_100_mhz_address>),             //                             .address
		.nios_bridge_s0_100_mhz_write               (<connected-to-nios_bridge_s0_100_mhz_write>),               //                             .write
		.nios_bridge_s0_100_mhz_read                (<connected-to-nios_bridge_s0_100_mhz_read>),                //                             .read
		.nios_bridge_s0_100_mhz_byteenable          (<connected-to-nios_bridge_s0_100_mhz_byteenable>),          //                             .byteenable
		.nios_bridge_s0_100_mhz_debugaccess         (<connected-to-nios_bridge_s0_100_mhz_debugaccess>),         //                             .debugaccess
		.out_to_tse_mac_data                        (<connected-to-out_to_tse_mac_data>),                        //               out_to_tse_mac.data
		.out_to_tse_mac_valid                       (<connected-to-out_to_tse_mac_valid>),                       //                             .valid
		.out_to_tse_mac_ready                       (<connected-to-out_to_tse_mac_ready>),                       //                             .ready
		.out_to_tse_mac_startofpacket               (<connected-to-out_to_tse_mac_startofpacket>),               //                             .startofpacket
		.out_to_tse_mac_endofpacket                 (<connected-to-out_to_tse_mac_endofpacket>),                 //                             .endofpacket
		.out_to_tse_mac_empty                       (<connected-to-out_to_tse_mac_empty>),                       //                             .empty
		.out_to_tse_mac_error                       (<connected-to-out_to_tse_mac_error>),                       //                             .error
		.reset_100_reset_n                          (<connected-to-reset_100_reset_n>),                          //                    reset_100.reset_n
		.udp_inserter_0_snk_data                    (<connected-to-udp_inserter_0_snk_data>),                    //           udp_inserter_0_snk.data
		.udp_inserter_0_snk_valid                   (<connected-to-udp_inserter_0_snk_valid>),                   //                             .valid
		.udp_inserter_0_snk_ready                   (<connected-to-udp_inserter_0_snk_ready>),                   //                             .ready
		.udp_inserter_0_snk_startofpacket           (<connected-to-udp_inserter_0_snk_startofpacket>),           //                             .startofpacket
		.udp_inserter_0_snk_endofpacket             (<connected-to-udp_inserter_0_snk_endofpacket>),             //                             .endofpacket
		.udp_inserter_0_snk_empty                   (<connected-to-udp_inserter_0_snk_empty>)                    //                             .empty
	);

