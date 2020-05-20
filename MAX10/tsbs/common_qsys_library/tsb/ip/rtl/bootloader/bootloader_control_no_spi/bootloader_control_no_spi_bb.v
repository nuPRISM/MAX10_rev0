
module bootloader_control_no_spi (
	avalon_mm_slave_joint_waitrequest,
	avalon_mm_slave_joint_readdata,
	avalon_mm_slave_joint_readdatavalid,
	avalon_mm_slave_joint_burstcount,
	avalon_mm_slave_joint_writedata,
	avalon_mm_slave_joint_address,
	avalon_mm_slave_joint_write,
	avalon_mm_slave_joint_read,
	avalon_mm_slave_joint_byteenable,
	avalon_mm_slave_joint_debugaccess,
	avalon_mm_slave_private_waitrequest,
	avalon_mm_slave_private_readdata,
	avalon_mm_slave_private_readdatavalid,
	avalon_mm_slave_private_burstcount,
	avalon_mm_slave_private_writedata,
	avalon_mm_slave_private_address,
	avalon_mm_slave_private_write,
	avalon_mm_slave_private_read,
	avalon_mm_slave_private_byteenable,
	avalon_mm_slave_private_debugaccess,
	boot_loader_enable_and_params_pio_export,
	boot_loader_gpio_out_export,
	boot_loader_main_nios_pc_monitor_export,
	boot_loader_timer_irq_irq,
	clk_50_clk,
	jtag_uart_1_irq_irq,
	main_cpu_reset_pio_in_port,
	main_cpu_reset_pio_out_port,
	pio_reset_and_bootloader_request_export,
	reset_50_reset_n);	

	output		avalon_mm_slave_joint_waitrequest;
	output	[31:0]	avalon_mm_slave_joint_readdata;
	output		avalon_mm_slave_joint_readdatavalid;
	input	[0:0]	avalon_mm_slave_joint_burstcount;
	input	[31:0]	avalon_mm_slave_joint_writedata;
	input	[15:0]	avalon_mm_slave_joint_address;
	input		avalon_mm_slave_joint_write;
	input		avalon_mm_slave_joint_read;
	input	[3:0]	avalon_mm_slave_joint_byteenable;
	input		avalon_mm_slave_joint_debugaccess;
	output		avalon_mm_slave_private_waitrequest;
	output	[31:0]	avalon_mm_slave_private_readdata;
	output		avalon_mm_slave_private_readdatavalid;
	input	[0:0]	avalon_mm_slave_private_burstcount;
	input	[31:0]	avalon_mm_slave_private_writedata;
	input	[15:0]	avalon_mm_slave_private_address;
	input		avalon_mm_slave_private_write;
	input		avalon_mm_slave_private_read;
	input	[3:0]	avalon_mm_slave_private_byteenable;
	input		avalon_mm_slave_private_debugaccess;
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
endmodule
