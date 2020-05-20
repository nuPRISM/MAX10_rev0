four_lane_seriallite_reconfig_aeq	four_lane_seriallite_reconfig_aeq_inst (
	.aeq_fromgxb ( aeq_fromgxb_sig ),
	.logical_channel_address ( logical_channel_address_sig ),
	.read ( read_sig ),
	.reconfig_clk ( reconfig_clk_sig ),
	.reconfig_fromgxb ( reconfig_fromgxb_sig ),
	.reconfig_mode_sel ( reconfig_mode_sel_sig ),
	.reconfig_reset ( reconfig_reset_sig ),
	.tx_vodctrl ( tx_vodctrl_sig ),
	.write_all ( write_all_sig ),
	.aeq_togxb ( aeq_togxb_sig ),
	.busy ( busy_sig ),
	.data_valid ( data_valid_sig ),
	.error ( error_sig ),
	.reconfig_togxb ( reconfig_togxb_sig ),
	.tx_vodctrl_out ( tx_vodctrl_out_sig )
	);
