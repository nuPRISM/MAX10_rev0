
module CycloneV_System (
	aligner_ctrl_aligner_ena,
	aligner_ctrl_aligner_shift,
	aligner_ctrl_aligner_oos,
	clk_clk,
	lvds_rx_lvds,
	lvds_tx_lvds,
	reset_reset_n,
	tg_reset_n,
	txclk_out_clk);	

	input		aligner_ctrl_aligner_ena;
	input		aligner_ctrl_aligner_shift;
	output		aligner_ctrl_aligner_oos;
	input		clk_clk;
	input	[1:0]	lvds_rx_lvds;
	output	[1:0]	lvds_tx_lvds;
	input		reset_reset_n;
	input		tg_reset_n;
	output		txclk_out_clk;
endmodule
