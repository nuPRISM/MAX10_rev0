
module linnux_support_reduced_uarts_min (
	clk_50_clk,
	counter_64_bit_0_current_count_export,
	fmc_present_external_connection_export,
	generic_hdl_info_word_export,
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
	reset_reset_n,
	uart_0_external_connection_rxd,
	uart_0_external_connection_txd,
	uart_0_irq_irq,
	uart_10_external_connection_rxd,
	uart_10_external_connection_txd,
	uart_10_irq_irq,
	uart_13_external_connection_rxd,
	uart_13_external_connection_txd,
	uart_13_irq_irq,
	uart_7_external_connection_rxd,
	uart_7_external_connection_txd,
	uart_7_irq_irq,
	uart_enabled_word_export,
	uart_internal_disable_external_connection_export,
	uart_internal_enable_external_connection_export,
	uart_is_regfile_external_connection_export);	

	input		clk_50_clk;
	output	[63:0]	counter_64_bit_0_current_count_export;
	input	[15:0]	fmc_present_external_connection_export;
	input	[31:0]	generic_hdl_info_word_export;
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
	input		reset_reset_n;
	input		uart_0_external_connection_rxd;
	output		uart_0_external_connection_txd;
	output		uart_0_irq_irq;
	input		uart_10_external_connection_rxd;
	output		uart_10_external_connection_txd;
	output		uart_10_irq_irq;
	input		uart_13_external_connection_rxd;
	output		uart_13_external_connection_txd;
	output		uart_13_irq_irq;
	input		uart_7_external_connection_rxd;
	output		uart_7_external_connection_txd;
	output		uart_7_irq_irq;
	input	[31:0]	uart_enabled_word_export;
	output	[31:0]	uart_internal_disable_external_connection_export;
	output	[31:0]	uart_internal_enable_external_connection_export;
	input	[31:0]	uart_is_regfile_external_connection_export;
endmodule
