	bootloader_control_1_interconnect u0 (
		.avalon_mm_slave_waitrequest              (<connected-to-avalon_mm_slave_waitrequest>),              //                   avalon_mm_slave.waitrequest
		.avalon_mm_slave_readdata                 (<connected-to-avalon_mm_slave_readdata>),                 //                                  .readdata
		.avalon_mm_slave_readdatavalid            (<connected-to-avalon_mm_slave_readdatavalid>),            //                                  .readdatavalid
		.avalon_mm_slave_burstcount               (<connected-to-avalon_mm_slave_burstcount>),               //                                  .burstcount
		.avalon_mm_slave_writedata                (<connected-to-avalon_mm_slave_writedata>),                //                                  .writedata
		.avalon_mm_slave_address                  (<connected-to-avalon_mm_slave_address>),                  //                                  .address
		.avalon_mm_slave_write                    (<connected-to-avalon_mm_slave_write>),                    //                                  .write
		.avalon_mm_slave_read                     (<connected-to-avalon_mm_slave_read>),                     //                                  .read
		.avalon_mm_slave_byteenable               (<connected-to-avalon_mm_slave_byteenable>),               //                                  .byteenable
		.avalon_mm_slave_debugaccess              (<connected-to-avalon_mm_slave_debugaccess>),              //                                  .debugaccess
		.boot_loader_enable_and_params_pio_export (<connected-to-boot_loader_enable_and_params_pio_export>), // boot_loader_enable_and_params_pio.export
		.boot_loader_gpio_out_export              (<connected-to-boot_loader_gpio_out_export>),              //              boot_loader_gpio_out.export
		.boot_loader_main_nios_pc_monitor_export  (<connected-to-boot_loader_main_nios_pc_monitor_export>),  //  boot_loader_main_nios_pc_monitor.export
		.boot_loader_timer_irq_irq                (<connected-to-boot_loader_timer_irq_irq>),                //             boot_loader_timer_irq.irq
		.clk_50_clk                               (<connected-to-clk_50_clk>),                               //                            clk_50.clk
		.jtag_uart_1_irq_irq                      (<connected-to-jtag_uart_1_irq_irq>),                      //                   jtag_uart_1_irq.irq
		.main_cpu_reset_pio_in_port               (<connected-to-main_cpu_reset_pio_in_port>),               //                main_cpu_reset_pio.in_port
		.main_cpu_reset_pio_out_port              (<connected-to-main_cpu_reset_pio_out_port>),              //                                  .out_port
		.pio_reset_and_bootloader_request_export  (<connected-to-pio_reset_and_bootloader_request_export>),  //  pio_reset_and_bootloader_request.export
		.reset_50_reset_n                         (<connected-to-reset_50_reset_n>),                         //                          reset_50.reset_n
		.spi_master_to_maxv_external_MISO         (<connected-to-spi_master_to_maxv_external_MISO>),         //       spi_master_to_maxv_external.MISO
		.spi_master_to_maxv_external_MOSI         (<connected-to-spi_master_to_maxv_external_MOSI>),         //                                  .MOSI
		.spi_master_to_maxv_external_SCLK         (<connected-to-spi_master_to_maxv_external_SCLK>),         //                                  .SCLK
		.spi_master_to_maxv_external_SS_n         (<connected-to-spi_master_to_maxv_external_SS_n>),         //                                  .SS_n
		.spi_master_to_maxv_irq_irq               (<connected-to-spi_master_to_maxv_irq_irq>)                //            spi_master_to_maxv_irq.irq
	);

