
module tse_w_sfp (
	clk_10_clk,
	clk_100_clk,
	clk_125_control_clk,
	clk_125_enet_base_in_clk_clk,
	clk_50_clk,
	mm_bridge_0_s0_waitrequest,
	mm_bridge_0_s0_readdata,
	mm_bridge_0_s0_readdatavalid,
	mm_bridge_0_s0_burstcount,
	mm_bridge_0_s0_writedata,
	mm_bridge_0_s0_address,
	mm_bridge_0_s0_write,
	mm_bridge_0_s0_read,
	mm_bridge_0_s0_byteenable,
	mm_bridge_0_s0_debugaccess,
	reset_100_reset_n,
	reset_125_control_reset_n,
	reset_50_reset_n,
	tse_sgdma_rx_csr_irq_irq,
	tse_sgdma_rx_m_write_waitrequest,
	tse_sgdma_rx_m_write_address,
	tse_sgdma_rx_m_write_write,
	tse_sgdma_rx_m_write_writedata,
	tse_sgdma_rx_m_write_byteenable,
	tse_sgdma_tx_csr_irq_irq,
	tse_sgdma_tx_m_read_readdata,
	tse_sgdma_tx_m_read_readdatavalid,
	tse_sgdma_tx_m_read_waitrequest,
	tse_sgdma_tx_m_read_address,
	tse_sgdma_tx_m_read_read,
	tse_sgdma_tx_out_data,
	tse_sgdma_tx_out_valid,
	tse_sgdma_tx_out_ready,
	tse_sgdma_tx_out_endofpacket,
	tse_sgdma_tx_out_startofpacket,
	tse_sgdma_tx_out_empty,
	tse_tse_mac_mac_mdio_connection_mdc,
	tse_tse_mac_mac_mdio_connection_mdio_in,
	tse_tse_mac_mac_mdio_connection_mdio_out,
	tse_tse_mac_mac_mdio_connection_mdio_oen,
	tse_tse_mac_mac_misc_connection_xon_gen,
	tse_tse_mac_mac_misc_connection_xoff_gen,
	tse_tse_mac_mac_misc_connection_ff_tx_crc_fwd,
	tse_tse_mac_mac_misc_connection_ff_tx_septy,
	tse_tse_mac_mac_misc_connection_tx_ff_uflow,
	tse_tse_mac_mac_misc_connection_ff_tx_a_full,
	tse_tse_mac_mac_misc_connection_ff_tx_a_empty,
	tse_tse_mac_mac_misc_connection_rx_err_stat,
	tse_tse_mac_mac_misc_connection_rx_frm_type,
	tse_tse_mac_mac_misc_connection_ff_rx_dsav,
	tse_tse_mac_mac_misc_connection_ff_rx_a_full,
	tse_tse_mac_mac_misc_connection_ff_rx_a_empty,
	tse_tse_mac_serdes_control_connection_sd_loopback,
	tse_tse_mac_serdes_control_connection_powerdown,
	tse_tse_mac_status_led_connection_crs,
	tse_tse_mac_status_led_connection_link,
	tse_tse_mac_status_led_connection_panel_link,
	tse_tse_mac_status_led_connection_col,
	tse_tse_mac_status_led_connection_an,
	tse_tse_mac_status_led_connection_char_err,
	tse_tse_mac_status_led_connection_disp_err,
	tse_tse_mac_tbi_connection_rx_clk,
	tse_tse_mac_tbi_connection_tx_clk,
	tse_tse_mac_tbi_connection_rx_d,
	tse_tse_mac_tbi_connection_tx_d,
	tse_tse_mac_transmit_data,
	tse_tse_mac_transmit_endofpacket,
	tse_tse_mac_transmit_error,
	tse_tse_mac_transmit_empty,
	tse_tse_mac_transmit_ready,
	tse_tse_mac_transmit_startofpacket,
	tse_tse_mac_transmit_valid,
	xcvr_ethernet_tx_ready,
	xcvr_ethernet_rx_ready,
	xcvr_xcvr_clk_pll_locked,
	xcvr_SFP_TX,
	xcvr_SFP_RX,
	xcvr_tbi_tx_clkout,
	xcvr_tbi_rx_clkout,
	xcvr_tbi_tx_d,
	xcvr_tbi_rx_d,
	xcvr_rx_is_lockedtoref,
	xcvr_rx_is_lockedtodata,
	xcvr_rx_signaldetect,
	xcvr_tx_forceelecidle,
	xcvr_busy,
	xcvr_tx_cal_busy,
	xcvr_rx_cal_busy);	

	input		clk_10_clk;
	input		clk_100_clk;
	input		clk_125_control_clk;
	input		clk_125_enet_base_in_clk_clk;
	input		clk_50_clk;
	output		mm_bridge_0_s0_waitrequest;
	output	[31:0]	mm_bridge_0_s0_readdata;
	output		mm_bridge_0_s0_readdatavalid;
	input	[0:0]	mm_bridge_0_s0_burstcount;
	input	[31:0]	mm_bridge_0_s0_writedata;
	input	[18:0]	mm_bridge_0_s0_address;
	input		mm_bridge_0_s0_write;
	input		mm_bridge_0_s0_read;
	input	[3:0]	mm_bridge_0_s0_byteenable;
	input		mm_bridge_0_s0_debugaccess;
	input		reset_100_reset_n;
	input		reset_125_control_reset_n;
	input		reset_50_reset_n;
	output		tse_sgdma_rx_csr_irq_irq;
	input		tse_sgdma_rx_m_write_waitrequest;
	output	[31:0]	tse_sgdma_rx_m_write_address;
	output		tse_sgdma_rx_m_write_write;
	output	[31:0]	tse_sgdma_rx_m_write_writedata;
	output	[3:0]	tse_sgdma_rx_m_write_byteenable;
	output		tse_sgdma_tx_csr_irq_irq;
	input	[31:0]	tse_sgdma_tx_m_read_readdata;
	input		tse_sgdma_tx_m_read_readdatavalid;
	input		tse_sgdma_tx_m_read_waitrequest;
	output	[31:0]	tse_sgdma_tx_m_read_address;
	output		tse_sgdma_tx_m_read_read;
	output	[31:0]	tse_sgdma_tx_out_data;
	output		tse_sgdma_tx_out_valid;
	input		tse_sgdma_tx_out_ready;
	output		tse_sgdma_tx_out_endofpacket;
	output		tse_sgdma_tx_out_startofpacket;
	output	[1:0]	tse_sgdma_tx_out_empty;
	output		tse_tse_mac_mac_mdio_connection_mdc;
	input		tse_tse_mac_mac_mdio_connection_mdio_in;
	output		tse_tse_mac_mac_mdio_connection_mdio_out;
	output		tse_tse_mac_mac_mdio_connection_mdio_oen;
	input		tse_tse_mac_mac_misc_connection_xon_gen;
	input		tse_tse_mac_mac_misc_connection_xoff_gen;
	input		tse_tse_mac_mac_misc_connection_ff_tx_crc_fwd;
	output		tse_tse_mac_mac_misc_connection_ff_tx_septy;
	output		tse_tse_mac_mac_misc_connection_tx_ff_uflow;
	output		tse_tse_mac_mac_misc_connection_ff_tx_a_full;
	output		tse_tse_mac_mac_misc_connection_ff_tx_a_empty;
	output	[17:0]	tse_tse_mac_mac_misc_connection_rx_err_stat;
	output	[3:0]	tse_tse_mac_mac_misc_connection_rx_frm_type;
	output		tse_tse_mac_mac_misc_connection_ff_rx_dsav;
	output		tse_tse_mac_mac_misc_connection_ff_rx_a_full;
	output		tse_tse_mac_mac_misc_connection_ff_rx_a_empty;
	output		tse_tse_mac_serdes_control_connection_sd_loopback;
	output		tse_tse_mac_serdes_control_connection_powerdown;
	output		tse_tse_mac_status_led_connection_crs;
	output		tse_tse_mac_status_led_connection_link;
	output		tse_tse_mac_status_led_connection_panel_link;
	output		tse_tse_mac_status_led_connection_col;
	output		tse_tse_mac_status_led_connection_an;
	output		tse_tse_mac_status_led_connection_char_err;
	output		tse_tse_mac_status_led_connection_disp_err;
	input		tse_tse_mac_tbi_connection_rx_clk;
	input		tse_tse_mac_tbi_connection_tx_clk;
	input	[9:0]	tse_tse_mac_tbi_connection_rx_d;
	output	[9:0]	tse_tse_mac_tbi_connection_tx_d;
	input	[31:0]	tse_tse_mac_transmit_data;
	input		tse_tse_mac_transmit_endofpacket;
	input		tse_tse_mac_transmit_error;
	input	[1:0]	tse_tse_mac_transmit_empty;
	output		tse_tse_mac_transmit_ready;
	input		tse_tse_mac_transmit_startofpacket;
	input		tse_tse_mac_transmit_valid;
	output		xcvr_ethernet_tx_ready;
	output		xcvr_ethernet_rx_ready;
	output		xcvr_xcvr_clk_pll_locked;
	output		xcvr_SFP_TX;
	input		xcvr_SFP_RX;
	output		xcvr_tbi_tx_clkout;
	output		xcvr_tbi_rx_clkout;
	input	[9:0]	xcvr_tbi_tx_d;
	output	[9:0]	xcvr_tbi_rx_d;
	output		xcvr_rx_is_lockedtoref;
	output		xcvr_rx_is_lockedtodata;
	output		xcvr_rx_signaldetect;
	input		xcvr_tx_forceelecidle;
	output		xcvr_busy;
	output		xcvr_tx_cal_busy;
	output		xcvr_rx_cal_busy;
endmodule
