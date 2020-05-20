`default_nettype none
module av_tse_w_sfp (
		input  wire        clk_100_clk,                                       //                               clk_100.clk
		input  wire        clk_125_control_clk,                               //                       clk_125_control.clk
		input  wire        clk_125_enet_base_in_clk_clk,                      //              clk_125_enet_base_in_clk.clk
		input  wire        clk_50_clk,                                        //                                clk_50.clk
		output wire        mm_bridge_0_s0_waitrequest,                        //                        mm_bridge_0_s0.waitrequest
		output wire [31:0] mm_bridge_0_s0_readdata,                           //                                      .readdata
		output wire        mm_bridge_0_s0_readdatavalid,                      //                                      .readdatavalid
		input  wire [0:0]  mm_bridge_0_s0_burstcount,                         //                                      .burstcount
		input  wire [31:0] mm_bridge_0_s0_writedata,                          //                                      .writedata
		input  wire [18:0] mm_bridge_0_s0_address,                            //                                      .address
		input  wire        mm_bridge_0_s0_write,                              //                                      .write
		input  wire        mm_bridge_0_s0_read,                               //                                      .read
		input  wire [3:0]  mm_bridge_0_s0_byteenable,                         //                                      .byteenable
		input  wire        mm_bridge_0_s0_debugaccess,                        //                                      .debugaccess
		input  wire        reset_100_reset_n,                                 //                             reset_100.reset_n
		input  wire        reset_125_control_reset_n,                         //                     reset_125_control.reset_n
		input  wire        reset_50_reset_n,                                  //                              reset_50.reset_n
		output wire        tse_sgdma_rx_csr_irq_irq,                          //                  tse_sgdma_rx_csr_irq.irq
		input  wire        tse_sgdma_rx_m_write_waitrequest,                  //                  tse_sgdma_rx_m_write.waitrequest
		output wire [31:0] tse_sgdma_rx_m_write_address,                      //                                      .address
		output wire        tse_sgdma_rx_m_write_write,                        //                                      .write
		output wire [31:0] tse_sgdma_rx_m_write_writedata,                    //                                      .writedata
		output wire [3:0]  tse_sgdma_rx_m_write_byteenable,                   //                                      .byteenable
		output wire        tse_sgdma_tx_csr_irq_irq,                          //                  tse_sgdma_tx_csr_irq.irq
		input  wire [31:0] tse_sgdma_tx_m_read_readdata,                      //                   tse_sgdma_tx_m_read.readdata
		input  wire        tse_sgdma_tx_m_read_readdatavalid,                 //                                      .readdatavalid
		input  wire        tse_sgdma_tx_m_read_waitrequest,                   //                                      .waitrequest
		output wire [31:0] tse_sgdma_tx_m_read_address,                       //                                      .address
		output wire        tse_sgdma_tx_m_read_read,                          //                                      .read
		output wire [31:0] tse_sgdma_tx_out_data,                             //                      tse_sgdma_tx_out.data
		output wire        tse_sgdma_tx_out_valid,                            //                                      .valid
		input  wire        tse_sgdma_tx_out_ready,                            //                                      .ready
		output wire        tse_sgdma_tx_out_endofpacket,                      //                                      .endofpacket
		output wire        tse_sgdma_tx_out_startofpacket,                    //                                      .startofpacket
		output wire [1:0]  tse_sgdma_tx_out_empty,                            //                                      .empty
		output wire        tse_tse_mac_mac_mdio_connection_mdc,               //       tse_tse_mac_mac_mdio_connection.mdc
		input  wire        tse_tse_mac_mac_mdio_connection_mdio_in,           //                                      .mdio_in
		output wire        tse_tse_mac_mac_mdio_connection_mdio_out,          //                                      .mdio_out
		output wire        tse_tse_mac_mac_mdio_connection_mdio_oen,          //                                      .mdio_oen
		output wire        tse_tse_mac_mac_misc_connection_ff_tx_septy,       //                                      .ff_tx_septy
		output wire        tse_tse_mac_mac_misc_connection_tx_ff_uflow,       //                                      .tx_ff_uflow
		output wire        tse_tse_mac_mac_misc_connection_ff_tx_a_full,      //                                      .ff_tx_a_full
		output wire        tse_tse_mac_mac_misc_connection_ff_tx_a_empty,     //                                      .ff_tx_a_empty
		output wire [17:0] tse_tse_mac_mac_misc_connection_rx_err_stat,       //                                      .rx_err_stat
		output wire [3:0]  tse_tse_mac_mac_misc_connection_rx_frm_type,       //                                      .rx_frm_type
		output wire        tse_tse_mac_mac_misc_connection_ff_rx_dsav,        //                                      .ff_rx_dsav
		output wire        tse_tse_mac_mac_misc_connection_ff_rx_a_full,      //                                      .ff_rx_a_full
		output wire        tse_tse_mac_mac_misc_connection_ff_rx_a_empty,     //                                      .ff_rx_a_empty
		output wire        tse_tse_mac_serdes_control_connection_sd_loopback, // tse_tse_mac_serdes_control_connection.sd_loopback
		output wire        tse_tse_mac_serdes_control_connection_powerdown,   //                                      .powerdown
		output wire        tse_tse_mac_status_led_connection_crs,             //     tse_tse_mac_status_led_connection.crs
		output wire        tse_tse_mac_status_led_connection_link,            //                                      .link
		output wire        tse_tse_mac_status_led_connection_panel_link,      //                                      .panel_link
		output wire        tse_tse_mac_status_led_connection_col,             //                                      .col
		output wire        tse_tse_mac_status_led_connection_an,              //                                      .an
		output wire        tse_tse_mac_status_led_connection_char_err,        //                                      .char_err
		output wire        tse_tse_mac_status_led_connection_disp_err,        //                                      .disp_err
		input  wire        tse_tse_mac_tbi_connection_rx_clk,                 //            tse_tse_mac_tbi_connection.rx_clk
		input  wire        tse_tse_mac_tbi_connection_tx_clk,                 //                                      .tx_clk
		input  wire [9:0]  tse_tse_mac_tbi_connection_rx_d,                   //                                      .rx_d
		output wire [9:0]  tse_tse_mac_tbi_connection_tx_d,                   //                                      .tx_d
		input  wire [31:0] tse_tse_mac_transmit_data,                         //                  tse_tse_mac_transmit.data
		input  wire        tse_tse_mac_transmit_endofpacket,                  //                                      .endofpacket
		input  wire        tse_tse_mac_transmit_error,                        //                                      .error
		input  wire [1:0]  tse_tse_mac_transmit_empty,                        //                                      .empty
		output wire        tse_tse_mac_transmit_ready,                        //                                      .ready
		input  wire        tse_tse_mac_transmit_startofpacket,                //                                      .startofpacket
		input  wire        tse_tse_mac_transmit_valid,                        //                                      .valid
		output wire        xcvr_ethernet_tx_ready,                            //                                  xcvr.ethernet_tx_ready
		output wire        xcvr_ethernet_rx_ready,                            //                                      .ethernet_rx_ready
		output wire        xcvr_xcvr_clk_pll_locked,                          //                                      .xcvr_clk_pll_locked
		output wire        xcvr_SFP_TX,                                       //                                      .SFP_TX
		input wire         xcvr_SFP_RX,                                       //                                      .SFP_RX
		output wire        xcvr_rx_is_lockedtoref,                            //                                      .rx_is_lockedtoref
		output wire        xcvr_rx_is_lockedtodata,                           //                                      .rx_is_lockedtodata
		output wire        xcvr_rx_signaldetect,                              //                                      .rx_signaldetect
		input  wire        xcvr_tx_forceelecidle,                             //                                      .tx_forceelecidle
		output wire        xcvr_busy,                                         //                                      .busy
		output wire        xcvr_tx_cal_busy,                                  //                                      .tx_cal_busy
		output wire        xcvr_rx_cal_busy                                   //                                      .rx_cal_busy
	);

wire        xcvr_tbi_tx_clkout;                             
wire        xcvr_tbi_rx_clkout;                             
wire [9:0]  xcvr_tbi_tx_d;                                  
wire [9:0]  xcvr_tbi_rx_d;     

tse_w_sfp tse_w_sfp_inst (
		.clk_100_clk                                   (clk_100_clk                                     )  ,            //                               clk_100.clk
		.clk_125_control_clk                           (clk_125_control_clk                             )  ,            //                       clk_125_control.clk
		.clk_125_enet_base_in_clk_clk                  (clk_125_enet_base_in_clk_clk                    )  ,            //              clk_125_enet_base_in_clk.clk
		.clk_50_clk                                    (clk_50_clk                                      )  ,            //                                clk_50.clk
		.mm_bridge_0_s0_waitrequest                    (mm_bridge_0_s0_waitrequest                      )  ,            //                        mm_bridge_0_s0.waitrequest
		.mm_bridge_0_s0_readdata                       (mm_bridge_0_s0_readdata                         )  ,            //                                      .readdata
		.mm_bridge_0_s0_readdatavalid                  (mm_bridge_0_s0_readdatavalid                    )  ,            //                                      .readdatavalid
		.mm_bridge_0_s0_burstcount                     (mm_bridge_0_s0_burstcount                       )  ,            //                                      .burstcount
		.mm_bridge_0_s0_writedata                      (mm_bridge_0_s0_writedata                        )  ,            //                                      .writedata
		.mm_bridge_0_s0_address                        (mm_bridge_0_s0_address                          )  ,            //                                      .address
		.mm_bridge_0_s0_write                          (mm_bridge_0_s0_write                            )  ,            //                                      .write
		.mm_bridge_0_s0_read                           (mm_bridge_0_s0_read                             )  ,            //                                      .read
		.mm_bridge_0_s0_byteenable                     (mm_bridge_0_s0_byteenable                       )  ,            //                                      .byteenable
		.mm_bridge_0_s0_debugaccess                    (mm_bridge_0_s0_debugaccess                      )  ,            //                                      .debugaccess
		.reset_100_reset_n                             (reset_100_reset_n                               )  ,            //                             reset_100.reset_n
		.reset_125_control_reset_n                     (reset_125_control_reset_n                       )  ,            //                     reset_125_control.reset_n
		.reset_50_reset_n                              (reset_50_reset_n                                )  ,            //                              reset_50.reset_n
		.tse_sgdma_rx_csr_irq_irq                      (tse_sgdma_rx_csr_irq_irq                        )  ,            //                  tse_sgdma_rx_csr_irq.irq
		.tse_sgdma_rx_m_write_waitrequest              (tse_sgdma_rx_m_write_waitrequest                )  ,            //                  tse_sgdma_rx_m_write.waitrequest
		.tse_sgdma_rx_m_write_address                  (tse_sgdma_rx_m_write_address                    )  ,            //                                      .address
		.tse_sgdma_rx_m_write_write                    (tse_sgdma_rx_m_write_write                      )  ,            //                                      .write
		.tse_sgdma_rx_m_write_writedata                (tse_sgdma_rx_m_write_writedata                  )  ,            //                                      .writedata
		.tse_sgdma_rx_m_write_byteenable               (tse_sgdma_rx_m_write_byteenable                 )  ,            //                                      .byteenable
		.tse_sgdma_tx_csr_irq_irq                      (tse_sgdma_tx_csr_irq_irq                        )  ,            //                  tse_sgdma_tx_csr_irq.irq
		.tse_sgdma_tx_m_read_readdata                  (tse_sgdma_tx_m_read_readdata                    )  ,            //                   tse_sgdma_tx_m_read.readdata
		.tse_sgdma_tx_m_read_readdatavalid             (tse_sgdma_tx_m_read_readdatavalid               )  ,            //                                      .readdatavalid
		.tse_sgdma_tx_m_read_waitrequest               (tse_sgdma_tx_m_read_waitrequest                 )  ,            //                                      .waitrequest
		.tse_sgdma_tx_m_read_address                   (tse_sgdma_tx_m_read_address                     )  ,            //                                      .address
		.tse_sgdma_tx_m_read_read                      (tse_sgdma_tx_m_read_read                        )  ,            //                                      .read
		.tse_sgdma_tx_out_data                         (tse_sgdma_tx_out_data                           )  ,            //                      tse_sgdma_tx_out.data
		.tse_sgdma_tx_out_valid                        (tse_sgdma_tx_out_valid                          )  ,            //                                      .valid
		.tse_sgdma_tx_out_ready                        (tse_sgdma_tx_out_ready                          )  ,            //                                      .ready
		.tse_sgdma_tx_out_endofpacket                  (tse_sgdma_tx_out_endofpacket                    )  ,            //                                      .endofpacket
		.tse_sgdma_tx_out_startofpacket                (tse_sgdma_tx_out_startofpacket                  )  ,            //                                      .startofpacket
		.tse_sgdma_tx_out_empty                        (tse_sgdma_tx_out_empty                          )  ,            //                                      .empty
		.tse_tse_mac_mac_mdio_connection_mdc           (tse_tse_mac_mac_mdio_connection_mdc             )  ,     //       tse_tse_mac_mac_mdio_connection.mdc
		.tse_tse_mac_mac_mdio_connection_mdio_in       (tse_tse_mac_mac_mdio_connection_mdio_in         )  ,     //                                      .mdio_in
		.tse_tse_mac_mac_mdio_connection_mdio_out      (tse_tse_mac_mac_mdio_connection_mdio_out        )  ,     //                                      .mdio_out
		.tse_tse_mac_mac_mdio_connection_mdio_oen      (tse_tse_mac_mac_mdio_connection_mdio_oen        )  ,     //                                      .mdio_oen
		.tse_tse_mac_mac_misc_connection_xon_gen          (1'b0),     //       tse_tse_mac_mac_misc_connection.xon_gen
		.tse_tse_mac_mac_misc_connection_xoff_gen         (1'b0),     //                                      .xoff_gen
		.tse_tse_mac_mac_misc_connection_ff_tx_crc_fwd    (1'b0),     //                                      .ff_tx_crc_fwd
		.tse_tse_mac_mac_misc_connection_ff_tx_septy      (tse_tse_mac_mac_misc_connection_ff_tx_septy       ),     //                                      .ff_tx_septy
		.tse_tse_mac_mac_misc_connection_tx_ff_uflow      (tse_tse_mac_mac_misc_connection_tx_ff_uflow       ),     //                                      .tx_ff_uflow
		.tse_tse_mac_mac_misc_connection_ff_tx_a_full     (tse_tse_mac_mac_misc_connection_ff_tx_a_full      ),     //                                      .ff_tx_a_full
		.tse_tse_mac_mac_misc_connection_ff_tx_a_empty    (tse_tse_mac_mac_misc_connection_ff_tx_a_empty     ),     //                                      .ff_tx_a_empty
		.tse_tse_mac_mac_misc_connection_rx_err_stat      (tse_tse_mac_mac_misc_connection_rx_err_stat       ),     //                                      .rx_err_stat
		.tse_tse_mac_mac_misc_connection_rx_frm_type      (tse_tse_mac_mac_misc_connection_rx_frm_type       ),     //                                      .rx_frm_type
		.tse_tse_mac_mac_misc_connection_ff_rx_dsav       (tse_tse_mac_mac_misc_connection_ff_rx_dsav        ),     //                                      .ff_rx_dsav
		.tse_tse_mac_mac_misc_connection_ff_rx_a_full     (tse_tse_mac_mac_misc_connection_ff_rx_a_full      ),     //                                      .ff_rx_a_full
		.tse_tse_mac_mac_misc_connection_ff_rx_a_empty    (tse_tse_mac_mac_misc_connection_ff_rx_a_empty     ),     //                                      .ff_rx_a_empty
		.tse_tse_mac_transmit_data                        (tse_tse_mac_transmit_data                         ),                //                  tse_tse_mac_transmit.data
		.tse_tse_mac_transmit_endofpacket                 (tse_tse_mac_transmit_endofpacket                  ),                //                                      .endofpacket
		.tse_tse_mac_transmit_error                       (tse_tse_mac_transmit_error                        ),                //                                      .error
		.tse_tse_mac_transmit_empty                       (tse_tse_mac_transmit_empty                        ),                //                                      .empty
		.tse_tse_mac_transmit_ready                       (tse_tse_mac_transmit_ready                        ),                //                                      .ready
		.tse_tse_mac_transmit_startofpacket               (tse_tse_mac_transmit_startofpacket                ),                //                                      .startofpacket
		.tse_tse_mac_transmit_valid                       (tse_tse_mac_transmit_valid                        ),                //                                      .valid
		.xcvr_ethernet_tx_ready                           (xcvr_ethernet_tx_ready                            ),                          //                                  xcvr.ethernet_tx_ready
		.xcvr_ethernet_rx_ready                           (xcvr_ethernet_rx_ready                            ),                          //                                      .ethernet_rx_ready
		.xcvr_xcvr_clk_pll_locked                         (xcvr_xcvr_clk_pll_locked                          ),                          //                                      .xcvr_clk_pll_locked
		.xcvr_SFP_TX                                      (xcvr_SFP_TX                                       ),                                       //                                      .SFP_TX
		.xcvr_SFP_RX                                      (xcvr_SFP_RX                                       ),                                       //                                      .SFP_RX
		.xcvr_tbi_tx_clkout                                (xcvr_tbi_tx_clkout),                                //                                      .tbi_tx_clkout
		.xcvr_tbi_rx_clkout                                (xcvr_tbi_rx_clkout),                                //                                      .tbi_rx_clkout
		.xcvr_tbi_tx_d                                     (xcvr_tbi_tx_d),                                     //                                      .tbi_tx_d
		.xcvr_tbi_rx_d                                     (xcvr_tbi_rx_d),                                     //                                      .tbi_rx_d
		.xcvr_rx_is_lockedtoref                            (xcvr_rx_is_lockedtoref    ) ,                           //                                      .rx_is_lockedtoref
		.xcvr_rx_is_lockedtodata                           (xcvr_rx_is_lockedtodata   ) ,                           //                                      .rx_is_lockedtodata
		.xcvr_rx_signaldetect                              (xcvr_rx_signaldetect      ) ,                             //                                      .rx_signaldetect
		.xcvr_tx_forceelecidle                             (xcvr_tx_forceelecidle     ) ,                             //                                      .tx_forceelecidle
		.xcvr_busy                                         (xcvr_busy                 ) ,                                 //                                      .busy
		.xcvr_tx_cal_busy                                  (xcvr_tx_cal_busy          ) ,                                 //                                      .tx_cal_busy
		.xcvr_rx_cal_busy                                  (xcvr_rx_cal_busy          ) ,                                 //                                      .rx_cal_busy
		.tse_tse_mac_tbi_connection_rx_clk                 (xcvr_tbi_rx_clkout),                 //            tse_tse_mac_tbi_connection.rx_clk
		.tse_tse_mac_tbi_connection_tx_clk                 (xcvr_tbi_tx_clkout),                 //                                      .tx_clk
		.tse_tse_mac_tbi_connection_rx_d                   (xcvr_tbi_rx_d),                   //                                      .rx_d
		.tse_tse_mac_tbi_connection_tx_d                   (xcvr_tbi_tx_d),                   //                                      .tx_d
		.tse_tse_mac_status_led_connection_crs             (tse_tse_mac_status_led_connection_crs             ), //     tse_tse_mac_status_led_connection.crs
		.tse_tse_mac_status_led_connection_link            (tse_tse_mac_status_led_connection_link            ), //                                      .link
		.tse_tse_mac_status_led_connection_panel_link      (tse_tse_mac_status_led_connection_panel_link      ), //                                      .panel_link
		.tse_tse_mac_status_led_connection_col             (tse_tse_mac_status_led_connection_col             ), //                                      .col
		.tse_tse_mac_status_led_connection_an              (tse_tse_mac_status_led_connection_an              ), //                                      .an
		.tse_tse_mac_status_led_connection_char_err        (tse_tse_mac_status_led_connection_char_err        ), //                                      .char_err
		.tse_tse_mac_status_led_connection_disp_err        (tse_tse_mac_status_led_connection_disp_err        ), //                                      .disp_err
		.tse_tse_mac_serdes_control_connection_sd_loopback (tse_tse_mac_serdes_control_connection_sd_loopback ), // tse_tse_mac_serdes_control_connection.sd_loopback
		.tse_tse_mac_serdes_control_connection_powerdown   (tse_tse_mac_serdes_control_connection_powerdown   )  //                                      .powerdown
	);
	
endmodule
`default_nettype wire