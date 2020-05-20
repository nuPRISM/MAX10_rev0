	basic_processor_support u0 (
		.peripheral_clk_clk            (<connected-to-peripheral_clk_clk>),            //       peripheral_clk.clk
		.hires_timer_irq_irq           (<connected-to-hires_timer_irq_irq>),           //      hires_timer_irq.irq
		.pio_button_export             (<connected-to-pio_button_export>),             //           pio_button.export
		.pio_button_irq_irq            (<connected-to-pio_button_irq_irq>),            //       pio_button_irq.irq
		.pio_dips_export               (<connected-to-pio_dips_export>),               //             pio_dips.export
		.pio_leds_export               (<connected-to-pio_leds_export>),               //             pio_leds.export
		.reset_peripheral_clk_reset_n  (<connected-to-reset_peripheral_clk_reset_n>),  // reset_peripheral_clk.reset_n
		.jtag_uart_irq_irq             (<connected-to-jtag_uart_irq_irq>),             //        jtag_uart_irq.irq
		.timer_irq_irq                 (<connected-to-timer_irq_irq>),                 //            timer_irq.irq
		.nios_clk_clk                  (<connected-to-nios_clk_clk>),                  //             nios_clk.clk
		.reset_nios_clk_reset_n        (<connected-to-reset_nios_clk_reset_n>),        //       reset_nios_clk.reset_n
		.avalon_mm_slave_waitrequest   (<connected-to-avalon_mm_slave_waitrequest>),   //      avalon_mm_slave.waitrequest
		.avalon_mm_slave_readdata      (<connected-to-avalon_mm_slave_readdata>),      //                     .readdata
		.avalon_mm_slave_readdatavalid (<connected-to-avalon_mm_slave_readdatavalid>), //                     .readdatavalid
		.avalon_mm_slave_burstcount    (<connected-to-avalon_mm_slave_burstcount>),    //                     .burstcount
		.avalon_mm_slave_writedata     (<connected-to-avalon_mm_slave_writedata>),     //                     .writedata
		.avalon_mm_slave_address       (<connected-to-avalon_mm_slave_address>),       //                     .address
		.avalon_mm_slave_write         (<connected-to-avalon_mm_slave_write>),         //                     .write
		.avalon_mm_slave_read          (<connected-to-avalon_mm_slave_read>),          //                     .read
		.avalon_mm_slave_byteenable    (<connected-to-avalon_mm_slave_byteenable>),    //                     .byteenable
		.avalon_mm_slave_debugaccess   (<connected-to-avalon_mm_slave_debugaccess>)    //                     .debugaccess
	);

