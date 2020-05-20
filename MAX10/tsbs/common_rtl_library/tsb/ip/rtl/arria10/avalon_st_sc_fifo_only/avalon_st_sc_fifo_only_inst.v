	avalon_st_sc_fifo_only u0 (
		.clk_clk                 (<connected-to-clk_clk>),                 //           clk.clk
		.reset_reset_n           (<connected-to-reset_reset_n>),           //         reset.reset_n
		.almost_empty_data       (<connected-to-almost_empty_data>),       //  almost_empty.data
		.almost_full_data        (<connected-to-almost_full_data>),        //   almost_full.data
		.out_data_data           (<connected-to-out_data_data>),           //      out_data.data
		.out_data_valid          (<connected-to-out_data_valid>),          //              .valid
		.out_data_ready          (<connected-to-out_data_ready>),          //              .ready
		.out_data_startofpacket  (<connected-to-out_data_startofpacket>),  //              .startofpacket
		.out_data_endofpacket    (<connected-to-out_data_endofpacket>),    //              .endofpacket
		.out_data_empty          (<connected-to-out_data_empty>),          //              .empty
		.in_data_data            (<connected-to-in_data_data>),            //       in_data.data
		.in_data_valid           (<connected-to-in_data_valid>),           //              .valid
		.in_data_ready           (<connected-to-in_data_ready>),           //              .ready
		.in_data_startofpacket   (<connected-to-in_data_startofpacket>),   //              .startofpacket
		.in_data_endofpacket     (<connected-to-in_data_endofpacket>),     //              .endofpacket
		.in_data_empty           (<connected-to-in_data_empty>),           //              .empty
		.avalon_mm_slv_address   (<connected-to-avalon_mm_slv_address>),   // avalon_mm_slv.address
		.avalon_mm_slv_read      (<connected-to-avalon_mm_slv_read>),      //              .read
		.avalon_mm_slv_write     (<connected-to-avalon_mm_slv_write>),     //              .write
		.avalon_mm_slv_readdata  (<connected-to-avalon_mm_slv_readdata>),  //              .readdata
		.avalon_mm_slv_writedata (<connected-to-avalon_mm_slv_writedata>)  //              .writedata
	);

