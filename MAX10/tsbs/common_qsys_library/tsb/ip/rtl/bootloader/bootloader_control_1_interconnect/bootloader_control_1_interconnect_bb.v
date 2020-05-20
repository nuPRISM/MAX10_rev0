
module bootloader_control_1_interconnect (
	avalon_mm_slave_waitrequest,
	avalon_mm_slave_readdata,
	avalon_mm_slave_readdatavalid,
	avalon_mm_slave_burstcount,
	avalon_mm_slave_writedata,
	avalon_mm_slave_address,
	avalon_mm_slave_write,
	avalon_mm_slave_read,
	avalon_mm_slave_byteenable,
	avalon_mm_slave_debugaccess,
	boot_loader_enable_and_params_pio_export,
	boot_loader_gpio_out_export,
	boot_loader_main_nios_pc_monitor_export,
	boot_loader_timer_irq_irq,
	clk_50_clk,
	jtag_uart_1_irq_irq,
	main_cpu_reset_pio_in_port,
	main_cpu_reset_pio_out_port,
	pio_reset_and_bootloader_request_export,
	reset_50_reset_n,
	spi_master_to_maxv_external_MISO,
	spi_master_to_maxv_external_MOSI,
	spi_master_to_maxv_external_SCLK,
	spi_master_to_maxv_external_SS_n,
	spi_master_to_maxv_irq_irq);	

	output		avalon_mm_slave_waitrequest;
	output	[31:0]	avalon_mm_slave_readdata;
	output		avalon_mm_slave_readdatavalid;
	input	[0:0]	avalon_mm_slave_burstcount;
	input	[31:0]	avalon_mm_slave_writedata;
	input	[15:0]	avalon_mm_slave_address;
	input		avalon_mm_slave_write;
	input		avalon_mm_slave_read;
	input	[3:0]	avalon_mm_slave_byteenable;
	input		avalon_mm_slave_debugaccess;
	input	[31:0]	boot_loader_enable_and_params_pio_export;
	output	[7:0]	boot_loader_gpio_out_export;
	input	[31:0]	boot_loader_main_nios_pc_monitor_export;
	output		boot_loader_timer_irq_irq;
	input		clk_50_clk;
	output		jtag_uart_1_irq_irq;
	input		main_cpu_reset_pio_in_port;
	output		main_cpu_reset_pio_out_port;
	output	[31:0]	pio_reset_and_bootloader_request_export;
	input		reset_50_reset_n;
	input		spi_master_to_maxv_external_MISO;
	output		spi_master_to_maxv_external_MOSI;
	output		spi_master_to_maxv_external_SCLK;
	output		spi_master_to_maxv_external_SS_n;
	output		spi_master_to_maxv_irq_irq;
endmodule
