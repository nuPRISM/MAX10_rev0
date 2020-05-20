
module arria_v_sfp (
	alt_xcvr_reconfig_reconfig_busy_reconfig_busy,
	alt_xcvr_reconfig_reconfig_from_xcvr_reconfig_from_xcvr,
	alt_xcvr_reconfig_reconfig_to_xcvr_reconfig_to_xcvr,
	alt_xcvr_reconfig_rx_cal_busy_tx_cal_busy,
	alt_xcvr_reconfig_tx_cal_busy_tx_cal_busy,
	arriav_v_standalone_gigabit_xcvr_tx_ready,
	arriav_v_standalone_gigabit_xcvr_rx_ready,
	arriav_v_standalone_gigabit_xcvr_pll_ref_clk,
	arriav_v_standalone_gigabit_xcvr_tx_serial_data,
	arriav_v_standalone_gigabit_xcvr_tx_forceelecidle,
	arriav_v_standalone_gigabit_xcvr_pll_locked,
	arriav_v_standalone_gigabit_xcvr_rx_serial_data,
	arriav_v_standalone_gigabit_xcvr_rx_is_lockedtoref,
	arriav_v_standalone_gigabit_xcvr_rx_is_lockedtodata,
	arriav_v_standalone_gigabit_xcvr_rx_signaldetect,
	arriav_v_standalone_gigabit_xcvr_tx_clkout,
	arriav_v_standalone_gigabit_xcvr_rx_clkout,
	arriav_v_standalone_gigabit_xcvr_tx_parallel_data,
	arriav_v_standalone_gigabit_xcvr_rx_parallel_data,
	arriav_v_standalone_gigabit_xcvr_reconfig_from_xcvr,
	arriav_v_standalone_gigabit_xcvr_reconfig_to_xcvr,
	avalon_slave_waitrequest,
	avalon_slave_readdata,
	avalon_slave_readdatavalid,
	avalon_slave_burstcount,
	avalon_slave_writedata,
	avalon_slave_address,
	avalon_slave_write,
	avalon_slave_read,
	avalon_slave_byteenable,
	avalon_slave_debugaccess,
	ethernet_clk_125mhz_clk,
	ethernet_clk_125mhz_reset_reset_n);	

	output		alt_xcvr_reconfig_reconfig_busy_reconfig_busy;
	input	[91:0]	alt_xcvr_reconfig_reconfig_from_xcvr_reconfig_from_xcvr;
	output	[139:0]	alt_xcvr_reconfig_reconfig_to_xcvr_reconfig_to_xcvr;
	output		alt_xcvr_reconfig_rx_cal_busy_tx_cal_busy;
	output		alt_xcvr_reconfig_tx_cal_busy_tx_cal_busy;
	output		arriav_v_standalone_gigabit_xcvr_tx_ready;
	output		arriav_v_standalone_gigabit_xcvr_rx_ready;
	input		arriav_v_standalone_gigabit_xcvr_pll_ref_clk;
	output		arriav_v_standalone_gigabit_xcvr_tx_serial_data;
	input		arriav_v_standalone_gigabit_xcvr_tx_forceelecidle;
	output		arriav_v_standalone_gigabit_xcvr_pll_locked;
	input		arriav_v_standalone_gigabit_xcvr_rx_serial_data;
	output		arriav_v_standalone_gigabit_xcvr_rx_is_lockedtoref;
	output		arriav_v_standalone_gigabit_xcvr_rx_is_lockedtodata;
	output		arriav_v_standalone_gigabit_xcvr_rx_signaldetect;
	output		arriav_v_standalone_gigabit_xcvr_tx_clkout;
	output		arriav_v_standalone_gigabit_xcvr_rx_clkout;
	input	[9:0]	arriav_v_standalone_gigabit_xcvr_tx_parallel_data;
	output	[9:0]	arriav_v_standalone_gigabit_xcvr_rx_parallel_data;
	output	[91:0]	arriav_v_standalone_gigabit_xcvr_reconfig_from_xcvr;
	input	[139:0]	arriav_v_standalone_gigabit_xcvr_reconfig_to_xcvr;
	output		avalon_slave_waitrequest;
	output	[31:0]	avalon_slave_readdata;
	output		avalon_slave_readdatavalid;
	input	[0:0]	avalon_slave_burstcount;
	input	[31:0]	avalon_slave_writedata;
	input	[15:0]	avalon_slave_address;
	input		avalon_slave_write;
	input		avalon_slave_read;
	input	[3:0]	avalon_slave_byteenable;
	input		avalon_slave_debugaccess;
	input		ethernet_clk_125mhz_clk;
	input		ethernet_clk_125mhz_reset_reset_n;
endmodule
