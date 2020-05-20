
module linnux_support_simplified (
	clk_50_clk,
	counter_64_bit_0_current_count_export,
	fmc_present_external_connection_export,
	generic_hdl_info_word_export,
	gp_fifo_0_control_in_port,
	gp_fifo_0_control_out_port,
	gp_fifo_0_flags_export,
	gp_fifo_0_read_data_export,
	gp_fifo_1_control_in_port,
	gp_fifo_1_control_out_port,
	gp_fifo_1_flags_export,
	gp_fifo_1_read_data_export,
	hires_timer_irq_irq,
	nios_avalon_mm_50mhz_waitrequest,
	nios_avalon_mm_50mhz_readdata,
	nios_avalon_mm_50mhz_readdatavalid,
	nios_avalon_mm_50mhz_burstcount,
	nios_avalon_mm_50mhz_writedata,
	nios_avalon_mm_50mhz_address,
	nios_avalon_mm_50mhz_write,
	nios_avalon_mm_50mhz_read,
	nios_avalon_mm_50mhz_byteenable,
	nios_avalon_mm_50mhz_debugaccess,
	pio_button_export,
	pio_button_irq_irq,
	pio_dips_export,
	pio_leds_export,
	reset_reset_n,
	sd_clk_export,
	sd_spi_cs_n_export,
	sd_spi_miso_export,
	sd_spi_mosi_export,
	spi_master_to_maxv_MISO,
	spi_master_to_maxv_MOSI,
	spi_master_to_maxv_SCLK,
	spi_master_to_maxv_SS_n,
	spi_master_to_maxv_irq_irq,
	uart_0_external_connection_rxd,
	uart_0_external_connection_txd,
	uart_0_irq_irq,
	uart_10_external_connection_rxd,
	uart_10_external_connection_txd,
	uart_10_irq_irq,
	uart_11_external_connection_rxd,
	uart_11_external_connection_txd,
	uart_11_irq_irq,
	uart_12_external_connection_rxd,
	uart_12_external_connection_txd,
	uart_12_irq_irq,
	uart_13_external_connection_rxd,
	uart_13_external_connection_txd,
	uart_13_irq_irq,
	uart_1_external_connection_rxd,
	uart_1_external_connection_txd,
	uart_1_irq_irq,
	uart_2_external_connection_rxd,
	uart_2_external_connection_txd,
	uart_2_irq_irq,
	uart_3_external_connection_rxd,
	uart_3_external_connection_txd,
	uart_3_irq_irq,
	uart_4_external_connection_rxd,
	uart_4_external_connection_txd,
	uart_4_irq_irq,
	uart_5_external_connection_rxd,
	uart_5_external_connection_txd,
	uart_5_irq_irq,
	uart_6_external_connection_rxd,
	uart_6_external_connection_txd,
	uart_6_irq_irq,
	uart_7_external_connection_rxd,
	uart_7_external_connection_txd,
	uart_7_irq_irq,
	uart_8_external_connection_rxd,
	uart_8_external_connection_txd,
	uart_8_irq_irq,
	uart_9_external_connection_rxd,
	uart_9_external_connection_txd,
	uart_9_irq_irq,
	uart_enabled_word_export,
	uart_internal_disable_external_connection_export,
	uart_internal_enable_external_connection_export,
	uart_is_regfile_external_connection_export);	

	input		clk_50_clk;
	output	[63:0]	counter_64_bit_0_current_count_export;
	input	[15:0]	fmc_present_external_connection_export;
	input	[31:0]	generic_hdl_info_word_export;
	input	[7:0]	gp_fifo_0_control_in_port;
	output	[7:0]	gp_fifo_0_control_out_port;
	input	[31:0]	gp_fifo_0_flags_export;
	input	[31:0]	gp_fifo_0_read_data_export;
	input	[7:0]	gp_fifo_1_control_in_port;
	output	[7:0]	gp_fifo_1_control_out_port;
	input	[31:0]	gp_fifo_1_flags_export;
	input	[31:0]	gp_fifo_1_read_data_export;
	output		hires_timer_irq_irq;
	output		nios_avalon_mm_50mhz_waitrequest;
	output	[31:0]	nios_avalon_mm_50mhz_readdata;
	output		nios_avalon_mm_50mhz_readdatavalid;
	input	[0:0]	nios_avalon_mm_50mhz_burstcount;
	input	[31:0]	nios_avalon_mm_50mhz_writedata;
	input	[26:0]	nios_avalon_mm_50mhz_address;
	input		nios_avalon_mm_50mhz_write;
	input		nios_avalon_mm_50mhz_read;
	input	[3:0]	nios_avalon_mm_50mhz_byteenable;
	input		nios_avalon_mm_50mhz_debugaccess;
	input	[7:0]	pio_button_export;
	output		pio_button_irq_irq;
	input	[7:0]	pio_dips_export;
	output	[8:0]	pio_leds_export;
	input		reset_reset_n;
	output		sd_clk_export;
	output		sd_spi_cs_n_export;
	input		sd_spi_miso_export;
	output		sd_spi_mosi_export;
	input		spi_master_to_maxv_MISO;
	output		spi_master_to_maxv_MOSI;
	output		spi_master_to_maxv_SCLK;
	output		spi_master_to_maxv_SS_n;
	output		spi_master_to_maxv_irq_irq;
	input		uart_0_external_connection_rxd;
	output		uart_0_external_connection_txd;
	output		uart_0_irq_irq;
	input		uart_10_external_connection_rxd;
	output		uart_10_external_connection_txd;
	output		uart_10_irq_irq;
	input		uart_11_external_connection_rxd;
	output		uart_11_external_connection_txd;
	output		uart_11_irq_irq;
	input		uart_12_external_connection_rxd;
	output		uart_12_external_connection_txd;
	output		uart_12_irq_irq;
	input		uart_13_external_connection_rxd;
	output		uart_13_external_connection_txd;
	output		uart_13_irq_irq;
	input		uart_1_external_connection_rxd;
	output		uart_1_external_connection_txd;
	output		uart_1_irq_irq;
	input		uart_2_external_connection_rxd;
	output		uart_2_external_connection_txd;
	output		uart_2_irq_irq;
	input		uart_3_external_connection_rxd;
	output		uart_3_external_connection_txd;
	output		uart_3_irq_irq;
	input		uart_4_external_connection_rxd;
	output		uart_4_external_connection_txd;
	output		uart_4_irq_irq;
	input		uart_5_external_connection_rxd;
	output		uart_5_external_connection_txd;
	output		uart_5_irq_irq;
	input		uart_6_external_connection_rxd;
	output		uart_6_external_connection_txd;
	output		uart_6_irq_irq;
	input		uart_7_external_connection_rxd;
	output		uart_7_external_connection_txd;
	output		uart_7_irq_irq;
	input		uart_8_external_connection_rxd;
	output		uart_8_external_connection_txd;
	output		uart_8_irq_irq;
	input		uart_9_external_connection_rxd;
	output		uart_9_external_connection_txd;
	output		uart_9_irq_irq;
	input	[31:0]	uart_enabled_word_export;
	output	[31:0]	uart_internal_disable_external_connection_export;
	output	[31:0]	uart_internal_enable_external_connection_export;
	input	[31:0]	uart_is_regfile_external_connection_export;
endmodule
