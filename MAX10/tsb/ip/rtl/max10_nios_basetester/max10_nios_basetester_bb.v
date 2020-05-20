
module max10_nios_basetester (
	clk_clk,
	pio_0_external_connection_export,
	reset_reset_n,
	uart_0_external_connection_rxd,
	uart_0_external_connection_txd);	

	input		clk_clk;
	output	[7:0]	pio_0_external_connection_export;
	input		reset_reset_n;
	input		uart_0_external_connection_rxd;
	output		uart_0_external_connection_txd;
endmodule
