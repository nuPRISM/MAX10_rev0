
module udp_streamer_subsystem (
	clk_100_clk,
	dc_fifo_0_in_clk_clk,
	dc_fifo_1_in_clk_clk,
	dc_fifo_2_in_clk_clk,
	dc_fifo_3_in_clk_clk,
	external_avalon_st_packet_in_data,
	external_avalon_st_packet_in_valid,
	external_avalon_st_packet_in_ready,
	external_avalon_st_packet_in_startofpacket,
	external_avalon_st_packet_in_endofpacket,
	external_avalon_st_packet_in_empty,
	external_packet_clk_clk,
	external_packet_reset_reset_n,
	nios_bridge_s0_100_mhz_waitrequest,
	nios_bridge_s0_100_mhz_readdata,
	nios_bridge_s0_100_mhz_readdatavalid,
	nios_bridge_s0_100_mhz_burstcount,
	nios_bridge_s0_100_mhz_writedata,
	nios_bridge_s0_100_mhz_address,
	nios_bridge_s0_100_mhz_write,
	nios_bridge_s0_100_mhz_read,
	nios_bridge_s0_100_mhz_byteenable,
	nios_bridge_s0_100_mhz_debugaccess,
	out_to_tse_mac_data,
	out_to_tse_mac_valid,
	out_to_tse_mac_ready,
	out_to_tse_mac_startofpacket,
	out_to_tse_mac_endofpacket,
	out_to_tse_mac_empty,
	out_to_tse_mac_error,
	reset_100_reset_n,
	udp_inserter_0_snk_data,
	udp_inserter_0_snk_valid,
	udp_inserter_0_snk_ready,
	udp_inserter_0_snk_startofpacket,
	udp_inserter_0_snk_endofpacket,
	udp_inserter_0_snk_empty,
	udp_inserter_1_snk_data,
	udp_inserter_1_snk_valid,
	udp_inserter_1_snk_ready,
	udp_inserter_1_snk_startofpacket,
	udp_inserter_1_snk_endofpacket,
	udp_inserter_1_snk_empty,
	udp_inserter_2_snk_data,
	udp_inserter_2_snk_valid,
	udp_inserter_2_snk_ready,
	udp_inserter_2_snk_startofpacket,
	udp_inserter_2_snk_endofpacket,
	udp_inserter_2_snk_empty,
	udp_inserter_3_snk_data,
	udp_inserter_3_snk_valid,
	udp_inserter_3_snk_ready,
	udp_inserter_3_snk_startofpacket,
	udp_inserter_3_snk_endofpacket,
	udp_inserter_3_snk_empty);	

	input		clk_100_clk;
	input		dc_fifo_0_in_clk_clk;
	input		dc_fifo_1_in_clk_clk;
	input		dc_fifo_2_in_clk_clk;
	input		dc_fifo_3_in_clk_clk;
	input	[31:0]	external_avalon_st_packet_in_data;
	input		external_avalon_st_packet_in_valid;
	output		external_avalon_st_packet_in_ready;
	input		external_avalon_st_packet_in_startofpacket;
	input		external_avalon_st_packet_in_endofpacket;
	input	[1:0]	external_avalon_st_packet_in_empty;
	input		external_packet_clk_clk;
	input		external_packet_reset_reset_n;
	output		nios_bridge_s0_100_mhz_waitrequest;
	output	[31:0]	nios_bridge_s0_100_mhz_readdata;
	output		nios_bridge_s0_100_mhz_readdatavalid;
	input	[0:0]	nios_bridge_s0_100_mhz_burstcount;
	input	[31:0]	nios_bridge_s0_100_mhz_writedata;
	input	[9:0]	nios_bridge_s0_100_mhz_address;
	input		nios_bridge_s0_100_mhz_write;
	input		nios_bridge_s0_100_mhz_read;
	input	[3:0]	nios_bridge_s0_100_mhz_byteenable;
	input		nios_bridge_s0_100_mhz_debugaccess;
	output	[31:0]	out_to_tse_mac_data;
	output		out_to_tse_mac_valid;
	input		out_to_tse_mac_ready;
	output		out_to_tse_mac_startofpacket;
	output		out_to_tse_mac_endofpacket;
	output	[1:0]	out_to_tse_mac_empty;
	output		out_to_tse_mac_error;
	input		reset_100_reset_n;
	input	[31:0]	udp_inserter_0_snk_data;
	input		udp_inserter_0_snk_valid;
	output		udp_inserter_0_snk_ready;
	input		udp_inserter_0_snk_startofpacket;
	input		udp_inserter_0_snk_endofpacket;
	input	[1:0]	udp_inserter_0_snk_empty;
	input	[31:0]	udp_inserter_1_snk_data;
	input		udp_inserter_1_snk_valid;
	output		udp_inserter_1_snk_ready;
	input		udp_inserter_1_snk_startofpacket;
	input		udp_inserter_1_snk_endofpacket;
	input	[1:0]	udp_inserter_1_snk_empty;
	input	[31:0]	udp_inserter_2_snk_data;
	input		udp_inserter_2_snk_valid;
	output		udp_inserter_2_snk_ready;
	input		udp_inserter_2_snk_startofpacket;
	input		udp_inserter_2_snk_endofpacket;
	input	[1:0]	udp_inserter_2_snk_empty;
	input	[31:0]	udp_inserter_3_snk_data;
	input		udp_inserter_3_snk_valid;
	output		udp_inserter_3_snk_ready;
	input		udp_inserter_3_snk_startofpacket;
	input		udp_inserter_3_snk_endofpacket;
	input	[1:0]	udp_inserter_3_snk_empty;
endmodule
