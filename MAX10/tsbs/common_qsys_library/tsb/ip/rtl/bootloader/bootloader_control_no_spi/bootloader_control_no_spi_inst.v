	bootloader_control_no_spi u0 (
		.avalon_mm_slave_joint_waitrequest        (<connected-to-avalon_mm_slave_joint_waitrequest>),        //             avalon_mm_slave_joint.waitrequest
		.avalon_mm_slave_joint_readdata           (<connected-to-avalon_mm_slave_joint_readdata>),           //                                  .readdata
		.avalon_mm_slave_joint_readdatavalid      (<connected-to-avalon_mm_slave_joint_readdatavalid>),      //                                  .readdatavalid
		.avalon_mm_slave_joint_burstcount         (<connected-to-avalon_mm_slave_joint_burstcount>),         //                                  .burstcount
		.avalon_mm_slave_joint_writedata          (<connected-to-avalon_mm_slave_joint_writedata>),          //                                  .writedata
		.avalon_mm_slave_joint_address            (<connected-to-avalon_mm_slave_joint_address>),            //                                  .address
		.avalon_mm_slave_joint_write              (<connected-to-avalon_mm_slave_joint_write>),              //                                  .write
		.avalon_mm_slave_joint_read               (<connected-to-avalon_mm_slave_joint_read>),               //                                  .read
		.avalon_mm_slave_joint_byteenable         (<connected-to-avalon_mm_slave_joint_byteenable>),         //                                  .byteenable
		.avalon_mm_slave_joint_debugaccess        (<connected-to-avalon_mm_slave_joint_debugaccess>),        //                                  .debugaccess
		.avalon_mm_slave_private_waitrequest      (<connected-to-avalon_mm_slave_private_waitrequest>),      //           avalon_mm_slave_private.waitrequest
		.avalon_mm_slave_private_readdata         (<connected-to-avalon_mm_slave_private_readdata>),         //                                  .readdata
		.avalon_mm_slave_private_readdatavalid    (<connected-to-avalon_mm_slave_private_readdatavalid>),    //                                  .readdatavalid
		.avalon_mm_slave_private_burstcount       (<connected-to-avalon_mm_slave_private_burstcount>),       //                                  .burstcount
		.avalon_mm_slave_private_writedata        (<connected-to-avalon_mm_slave_private_writedata>),        //                                  .writedata
		.avalon_mm_slave_private_address          (<connected-to-avalon_mm_slave_private_address>),          //                                  .address
		.avalon_mm_slave_private_write            (<connected-to-avalon_mm_slave_private_write>),            //                                  .write
		.avalon_mm_slave_private_read             (<connected-to-avalon_mm_slave_private_read>),             //                                  .read
		.avalon_mm_slave_private_byteenable       (<connected-to-avalon_mm_slave_private_byteenable>),       //                                  .byteenable
		.avalon_mm_slave_private_debugaccess      (<connected-to-avalon_mm_slave_private_debugaccess>),      //                                  .debugaccess
		.boot_loader_enable_and_params_pio_export (<connected-to-boot_loader_enable_and_params_pio_export>), // boot_loader_enable_and_params_pio.export
		.boot_loader_gpio_out_export              (<connected-to-boot_loader_gpio_out_export>),              //              boot_loader_gpio_out.export
		.boot_loader_main_nios_pc_monitor_export  (<connected-to-boot_loader_main_nios_pc_monitor_export>),  //  boot_loader_main_nios_pc_monitor.export
		.boot_loader_timer_irq_irq                (<connected-to-boot_loader_timer_irq_irq>),                //             boot_loader_timer_irq.irq
		.clk_50_clk                               (<connected-to-clk_50_clk>),                               //                            clk_50.clk
		.jtag_uart_1_irq_irq                      (<connected-to-jtag_uart_1_irq_irq>),                      //                   jtag_uart_1_irq.irq
		.main_cpu_reset_pio_in_port               (<connected-to-main_cpu_reset_pio_in_port>),               //                main_cpu_reset_pio.in_port
		.main_cpu_reset_pio_out_port              (<connected-to-main_cpu_reset_pio_out_port>),              //                                  .out_port
		.pio_reset_and_bootloader_request_export  (<connected-to-pio_reset_and_bootloader_request_export>),  //  pio_reset_and_bootloader_request.export
		.reset_50_reset_n                         (<connected-to-reset_50_reset_n>)                          //                          reset_50.reset_n
	);

