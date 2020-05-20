	tse_w_sgdma_2_intercon_rgmii u0 (
		.avalon_slave_waitrequest                  (<connected-to-avalon_slave_waitrequest>),                  //                        avalon_slave.waitrequest
		.avalon_slave_readdata                     (<connected-to-avalon_slave_readdata>),                     //                                    .readdata
		.avalon_slave_readdatavalid                (<connected-to-avalon_slave_readdatavalid>),                //                                    .readdatavalid
		.avalon_slave_burstcount                   (<connected-to-avalon_slave_burstcount>),                   //                                    .burstcount
		.avalon_slave_writedata                    (<connected-to-avalon_slave_writedata>),                    //                                    .writedata
		.avalon_slave_address                      (<connected-to-avalon_slave_address>),                      //                                    .address
		.avalon_slave_write                        (<connected-to-avalon_slave_write>),                        //                                    .write
		.avalon_slave_read                         (<connected-to-avalon_slave_read>),                         //                                    .read
		.avalon_slave_byteenable                   (<connected-to-avalon_slave_byteenable>),                   //                                    .byteenable
		.avalon_slave_debugaccess                  (<connected-to-avalon_slave_debugaccess>),                  //                                    .debugaccess
		.clk_10_clk                                (<connected-to-clk_10_clk>),                                //                              clk_10.clk
		.clk_100_clk                               (<connected-to-clk_100_clk>),                               //                             clk_100.clk
		.clk_50_clk                                (<connected-to-clk_50_clk>),                                //                              clk_50.clk
		.reset_100_reset_n                         (<connected-to-reset_100_reset_n>),                         //                           reset_100.reset_n
		.reset_50_reset_n                          (<connected-to-reset_50_reset_n>),                          //                            reset_50.reset_n
		.sgdma_rx_csr_irq_irq                      (<connected-to-sgdma_rx_csr_irq_irq>),                      //                    sgdma_rx_csr_irq.irq
		.sgdma_rx_m_write_waitrequest              (<connected-to-sgdma_rx_m_write_waitrequest>),              //                    sgdma_rx_m_write.waitrequest
		.sgdma_rx_m_write_address                  (<connected-to-sgdma_rx_m_write_address>),                  //                                    .address
		.sgdma_rx_m_write_write                    (<connected-to-sgdma_rx_m_write_write>),                    //                                    .write
		.sgdma_rx_m_write_writedata                (<connected-to-sgdma_rx_m_write_writedata>),                //                                    .writedata
		.sgdma_rx_m_write_byteenable               (<connected-to-sgdma_rx_m_write_byteenable>),               //                                    .byteenable
		.sgdma_tx_csr_irq_irq                      (<connected-to-sgdma_tx_csr_irq_irq>),                      //                    sgdma_tx_csr_irq.irq
		.sgdma_tx_m_read_readdata                  (<connected-to-sgdma_tx_m_read_readdata>),                  //                     sgdma_tx_m_read.readdata
		.sgdma_tx_m_read_readdatavalid             (<connected-to-sgdma_tx_m_read_readdatavalid>),             //                                    .readdatavalid
		.sgdma_tx_m_read_waitrequest               (<connected-to-sgdma_tx_m_read_waitrequest>),               //                                    .waitrequest
		.sgdma_tx_m_read_address                   (<connected-to-sgdma_tx_m_read_address>),                   //                                    .address
		.sgdma_tx_m_read_read                      (<connected-to-sgdma_tx_m_read_read>),                      //                                    .read
		.sgdma_tx_out_data                         (<connected-to-sgdma_tx_out_data>),                         //                        sgdma_tx_out.data
		.sgdma_tx_out_valid                        (<connected-to-sgdma_tx_out_valid>),                        //                                    .valid
		.sgdma_tx_out_ready                        (<connected-to-sgdma_tx_out_ready>),                        //                                    .ready
		.sgdma_tx_out_endofpacket                  (<connected-to-sgdma_tx_out_endofpacket>),                  //                                    .endofpacket
		.sgdma_tx_out_startofpacket                (<connected-to-sgdma_tx_out_startofpacket>),                //                                    .startofpacket
		.sgdma_tx_out_empty                        (<connected-to-sgdma_tx_out_empty>),                        //                                    .empty
		.sgdma_tx_out_error                        (<connected-to-sgdma_tx_out_error>),                        //                                    .error
		.tse_mac_mac_mdio_connection_mdc           (<connected-to-tse_mac_mac_mdio_connection_mdc>),           //         tse_mac_mac_mdio_connection.mdc
		.tse_mac_mac_mdio_connection_mdio_in       (<connected-to-tse_mac_mac_mdio_connection_mdio_in>),       //                                    .mdio_in
		.tse_mac_mac_mdio_connection_mdio_out      (<connected-to-tse_mac_mac_mdio_connection_mdio_out>),      //                                    .mdio_out
		.tse_mac_mac_mdio_connection_mdio_oen      (<connected-to-tse_mac_mac_mdio_connection_mdio_oen>),      //                                    .mdio_oen
		.tse_mac_mac_misc_connection_magic_wakeup  (<connected-to-tse_mac_mac_misc_connection_magic_wakeup>),  //         tse_mac_mac_misc_connection.magic_wakeup
		.tse_mac_mac_misc_connection_magic_sleep_n (<connected-to-tse_mac_mac_misc_connection_magic_sleep_n>), //                                    .magic_sleep_n
		.tse_mac_mac_misc_connection_ff_tx_crc_fwd (<connected-to-tse_mac_mac_misc_connection_ff_tx_crc_fwd>), //                                    .ff_tx_crc_fwd
		.tse_mac_mac_misc_connection_ff_tx_septy   (<connected-to-tse_mac_mac_misc_connection_ff_tx_septy>),   //                                    .ff_tx_septy
		.tse_mac_mac_misc_connection_tx_ff_uflow   (<connected-to-tse_mac_mac_misc_connection_tx_ff_uflow>),   //                                    .tx_ff_uflow
		.tse_mac_mac_misc_connection_ff_tx_a_full  (<connected-to-tse_mac_mac_misc_connection_ff_tx_a_full>),  //                                    .ff_tx_a_full
		.tse_mac_mac_misc_connection_ff_tx_a_empty (<connected-to-tse_mac_mac_misc_connection_ff_tx_a_empty>), //                                    .ff_tx_a_empty
		.tse_mac_mac_misc_connection_rx_err_stat   (<connected-to-tse_mac_mac_misc_connection_rx_err_stat>),   //                                    .rx_err_stat
		.tse_mac_mac_misc_connection_rx_frm_type   (<connected-to-tse_mac_mac_misc_connection_rx_frm_type>),   //                                    .rx_frm_type
		.tse_mac_mac_misc_connection_ff_rx_dsav    (<connected-to-tse_mac_mac_misc_connection_ff_rx_dsav>),    //                                    .ff_rx_dsav
		.tse_mac_mac_misc_connection_ff_rx_a_full  (<connected-to-tse_mac_mac_misc_connection_ff_rx_a_full>),  //                                    .ff_rx_a_full
		.tse_mac_mac_misc_connection_ff_rx_a_empty (<connected-to-tse_mac_mac_misc_connection_ff_rx_a_empty>), //                                    .ff_rx_a_empty
		.tse_mac_mac_rgmii_connection_rgmii_in     (<connected-to-tse_mac_mac_rgmii_connection_rgmii_in>),     //        tse_mac_mac_rgmii_connection.rgmii_in
		.tse_mac_mac_rgmii_connection_rgmii_out    (<connected-to-tse_mac_mac_rgmii_connection_rgmii_out>),    //                                    .rgmii_out
		.tse_mac_mac_rgmii_connection_rx_control   (<connected-to-tse_mac_mac_rgmii_connection_rx_control>),   //                                    .rx_control
		.tse_mac_mac_rgmii_connection_tx_control   (<connected-to-tse_mac_mac_rgmii_connection_tx_control>),   //                                    .tx_control
		.tse_mac_mac_status_connection_set_10      (<connected-to-tse_mac_mac_status_connection_set_10>),      //       tse_mac_mac_status_connection.set_10
		.tse_mac_mac_status_connection_set_1000    (<connected-to-tse_mac_mac_status_connection_set_1000>),    //                                    .set_1000
		.tse_mac_mac_status_connection_eth_mode    (<connected-to-tse_mac_mac_status_connection_eth_mode>),    //                                    .eth_mode
		.tse_mac_mac_status_connection_ena_10      (<connected-to-tse_mac_mac_status_connection_ena_10>),      //                                    .ena_10
		.tse_mac_pcs_mac_rx_clock_connection_clk   (<connected-to-tse_mac_pcs_mac_rx_clock_connection_clk>),   // tse_mac_pcs_mac_rx_clock_connection.clk
		.tse_mac_pcs_mac_tx_clock_connection_clk   (<connected-to-tse_mac_pcs_mac_tx_clock_connection_clk>),   // tse_mac_pcs_mac_tx_clock_connection.clk
		.tse_mac_transmit_data                     (<connected-to-tse_mac_transmit_data>),                     //                    tse_mac_transmit.data
		.tse_mac_transmit_endofpacket              (<connected-to-tse_mac_transmit_endofpacket>),              //                                    .endofpacket
		.tse_mac_transmit_error                    (<connected-to-tse_mac_transmit_error>),                    //                                    .error
		.tse_mac_transmit_empty                    (<connected-to-tse_mac_transmit_empty>),                    //                                    .empty
		.tse_mac_transmit_ready                    (<connected-to-tse_mac_transmit_ready>),                    //                                    .ready
		.tse_mac_transmit_startofpacket            (<connected-to-tse_mac_transmit_startofpacket>),            //                                    .startofpacket
		.tse_mac_transmit_valid                    (<connected-to-tse_mac_transmit_valid>)                     //                                    .valid
	);

