
module basic_processor_support (
	peripheral_clk_clk,
	hires_timer_irq_irq,
	pio_button_export,
	pio_button_irq_irq,
	pio_dips_export,
	pio_leds_export,
	reset_peripheral_clk_reset_n,
	jtag_uart_irq_irq,
	timer_irq_irq,
	nios_clk_clk,
	reset_nios_clk_reset_n,
	avalon_mm_slave_waitrequest,
	avalon_mm_slave_readdata,
	avalon_mm_slave_readdatavalid,
	avalon_mm_slave_burstcount,
	avalon_mm_slave_writedata,
	avalon_mm_slave_address,
	avalon_mm_slave_write,
	avalon_mm_slave_read,
	avalon_mm_slave_byteenable,
	avalon_mm_slave_debugaccess);	

	input		peripheral_clk_clk;
	output		hires_timer_irq_irq;
	input	[7:0]	pio_button_export;
	output		pio_button_irq_irq;
	input	[7:0]	pio_dips_export;
	output	[8:0]	pio_leds_export;
	input		reset_peripheral_clk_reset_n;
	output		jtag_uart_irq_irq;
	output		timer_irq_irq;
	input		nios_clk_clk;
	input		reset_nios_clk_reset_n;
	output		avalon_mm_slave_waitrequest;
	output	[31:0]	avalon_mm_slave_readdata;
	output		avalon_mm_slave_readdatavalid;
	input	[0:0]	avalon_mm_slave_burstcount;
	input	[31:0]	avalon_mm_slave_writedata;
	input	[6:0]	avalon_mm_slave_address;
	input		avalon_mm_slave_write;
	input		avalon_mm_slave_read;
	input	[3:0]	avalon_mm_slave_byteenable;
	input		avalon_mm_slave_debugaccess;
endmodule
