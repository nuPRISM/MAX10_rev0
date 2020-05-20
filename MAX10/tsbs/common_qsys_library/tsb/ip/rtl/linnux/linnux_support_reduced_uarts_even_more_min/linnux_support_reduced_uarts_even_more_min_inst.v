	linnux_support_reduced_uarts_even_more_min u0 (
		.clk_50_clk                                       (<connected-to-clk_50_clk>),                                       //                                    clk_50.clk
		.counter_64_bit_0_current_count_export            (<connected-to-counter_64_bit_0_current_count_export>),            //            counter_64_bit_0_current_count.export
		.fmc_present_external_connection_export           (<connected-to-fmc_present_external_connection_export>),           //           fmc_present_external_connection.export
		.generic_hdl_info_word_export                     (<connected-to-generic_hdl_info_word_export>),                     //                     generic_hdl_info_word.export
		.hires_timer_irq_irq                              (<connected-to-hires_timer_irq_irq>),                              //                           hires_timer_irq.irq
		.nios_avalon_mm_50mhz_waitrequest                 (<connected-to-nios_avalon_mm_50mhz_waitrequest>),                 //                      nios_avalon_mm_50mhz.waitrequest
		.nios_avalon_mm_50mhz_readdata                    (<connected-to-nios_avalon_mm_50mhz_readdata>),                    //                                          .readdata
		.nios_avalon_mm_50mhz_readdatavalid               (<connected-to-nios_avalon_mm_50mhz_readdatavalid>),               //                                          .readdatavalid
		.nios_avalon_mm_50mhz_burstcount                  (<connected-to-nios_avalon_mm_50mhz_burstcount>),                  //                                          .burstcount
		.nios_avalon_mm_50mhz_writedata                   (<connected-to-nios_avalon_mm_50mhz_writedata>),                   //                                          .writedata
		.nios_avalon_mm_50mhz_address                     (<connected-to-nios_avalon_mm_50mhz_address>),                     //                                          .address
		.nios_avalon_mm_50mhz_write                       (<connected-to-nios_avalon_mm_50mhz_write>),                       //                                          .write
		.nios_avalon_mm_50mhz_read                        (<connected-to-nios_avalon_mm_50mhz_read>),                        //                                          .read
		.nios_avalon_mm_50mhz_byteenable                  (<connected-to-nios_avalon_mm_50mhz_byteenable>),                  //                                          .byteenable
		.nios_avalon_mm_50mhz_debugaccess                 (<connected-to-nios_avalon_mm_50mhz_debugaccess>),                 //                                          .debugaccess
		.reset_reset_n                                    (<connected-to-reset_reset_n>),                                    //                                     reset.reset_n
		.uart_0_external_connection_rxd                   (<connected-to-uart_0_external_connection_rxd>),                   //                uart_0_external_connection.rxd
		.uart_0_external_connection_txd                   (<connected-to-uart_0_external_connection_txd>),                   //                                          .txd
		.uart_0_irq_irq                                   (<connected-to-uart_0_irq_irq>),                                   //                                uart_0_irq.irq
		.uart_10_external_connection_rxd                  (<connected-to-uart_10_external_connection_rxd>),                  //               uart_10_external_connection.rxd
		.uart_10_external_connection_txd                  (<connected-to-uart_10_external_connection_txd>),                  //                                          .txd
		.uart_10_irq_irq                                  (<connected-to-uart_10_irq_irq>),                                  //                               uart_10_irq.irq
		.uart_13_external_connection_rxd                  (<connected-to-uart_13_external_connection_rxd>),                  //               uart_13_external_connection.rxd
		.uart_13_external_connection_txd                  (<connected-to-uart_13_external_connection_txd>),                  //                                          .txd
		.uart_13_irq_irq                                  (<connected-to-uart_13_irq_irq>),                                  //                               uart_13_irq.irq
		.uart_7_external_connection_rxd                   (<connected-to-uart_7_external_connection_rxd>),                   //                uart_7_external_connection.rxd
		.uart_7_external_connection_txd                   (<connected-to-uart_7_external_connection_txd>),                   //                                          .txd
		.uart_7_irq_irq                                   (<connected-to-uart_7_irq_irq>),                                   //                                uart_7_irq.irq
		.uart_enabled_word_export                         (<connected-to-uart_enabled_word_export>),                         //                         uart_enabled_word.export
		.uart_internal_disable_external_connection_export (<connected-to-uart_internal_disable_external_connection_export>), // uart_internal_disable_external_connection.export
		.uart_internal_enable_external_connection_export  (<connected-to-uart_internal_enable_external_connection_export>),  //  uart_internal_enable_external_connection.export
		.uart_is_regfile_external_connection_export       (<connected-to-uart_is_regfile_external_connection_export>)        //       uart_is_regfile_external_connection.export
	);

