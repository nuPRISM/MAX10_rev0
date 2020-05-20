	CycloneV_System u0 (
		.aligner_ctrl_aligner_ena   (<connected-to-aligner_ctrl_aligner_ena>),   // aligner_ctrl.aligner_ena
		.aligner_ctrl_aligner_shift (<connected-to-aligner_ctrl_aligner_shift>), //             .aligner_shift
		.aligner_ctrl_aligner_oos   (<connected-to-aligner_ctrl_aligner_oos>),   //             .aligner_oos
		.clk_clk                    (<connected-to-clk_clk>),                    //          clk.clk
		.lvds_rx_lvds               (<connected-to-lvds_rx_lvds>),               //      lvds_rx.lvds
		.lvds_tx_lvds               (<connected-to-lvds_tx_lvds>),               //      lvds_tx.lvds
		.reset_reset_n              (<connected-to-reset_reset_n>),              //        reset.reset_n
		.tg_reset_n                 (<connected-to-tg_reset_n>),                 //           tg.reset_n
		.txclk_out_clk              (<connected-to-txclk_out_clk>)               //    txclk_out.clk
	);

