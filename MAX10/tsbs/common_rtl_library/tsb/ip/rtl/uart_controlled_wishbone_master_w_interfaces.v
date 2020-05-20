
`include "interface_defs.v"
`include "uart_regfile_interface_defs.v"

module uart_controlled_wishbone_master_w_interfaces
#(
	parameter  [15:0] DATA_NUMBYTES        =   4,
    parameter  [15:0] DESC_NUMBYTES        =  16,
    parameter  [15:0] NUM_OF_CONTROL_REGS  =  32,
    parameter [15:0] ADDRESS_WIDTH_IN_BITS =  16,
    parameter  [7:0]                 USE_AUTO_RESET                         = 1'b1,
    parameter                        CLOCK_SPEED_IN_HZ    = 50000000,
    parameter                        UART_BAUD_RATE_IN_HZ = 115200,
    parameter [0:0]    DISABLE_ERROR_MONITORING = 1'b1
)
(
 uart_wishbone_bridge_interface uart_regfile_interface_pins,
 wishbone_interface wishbone_master_interface_pins
);

uart_controlled_wishbone_master
#(
 .DATA_WIDTH_IN_BYTES              ( DATA_NUMBYTES                    ),
 .DESC_WIDTH_IN_BYTES              ( DESC_NUMBYTES                    ),
 .NUM_OF_CONTROL_REGS              ( NUM_OF_CONTROL_REGS              ),
 .ADDRESS_WIDTH_IN_BITS            (ADDRESS_WIDTH_IN_BITS),		  
 .USE_AUTO_RESET                   ( USE_AUTO_RESET                   ),
 .CLOCK_SPEED_IN_HZ                ( CLOCK_SPEED_IN_HZ                ),
 .UART_BAUD_RATE_IN_HZ             ( UART_BAUD_RATE_IN_HZ             ),
 .DISABLE_ERROR_MONITORING         (DISABLE_ERROR_MONITORING          ) 
 )
uart_regfile_internal
(	
 .CLK                         (uart_regfile_interface_pins.clk              ),
 .REG_ACTIVE_HIGH_ASYNC_RESET (uart_regfile_interface_pins.reset              ),
 .CONTROL_DESC                (uart_regfile_interface_pins.control_desc              ),
 .CONTROL_OMIT_DESC           (uart_regfile_interface_pins.control_omit_desc              ),
 .TRANSACTION_ERROR           (uart_regfile_interface_pins.transaction_error              ),
 .WR_ERROR                    (uart_regfile_interface_pins.wr_error              ),
 .RD_ERROR                    (uart_regfile_interface_pins.rd_error              ),
 .DISPLAY_NAME                (uart_regfile_interface_pins.display_name              ),
 .USER_TYPE                   (uart_regfile_interface_pins.user_type              ),
 .NUM_SECONDARY_UARTS         (uart_regfile_interface_pins.num_secondary_uarts              ),
 .ADDRESS_OF_THIS_UART        (uart_regfile_interface_pins.address_of_this_uart              ),
 .IS_SECONDARY_UART           (uart_regfile_interface_pins.is_secondary_uart              ),
 .enable_watchdog             (uart_regfile_interface_pins.enable_watchdog              ),
 .reset_watchdog              (uart_regfile_interface_pins.reset_watchdog              ),
 .watchdog_reset_pulse        (uart_regfile_interface_pins.watchdog_reset_pulse              ),
 .watchdog_limit              (uart_regfile_interface_pins.watchdog_limit              ),
 .watchdog_reset_pulse_width  (uart_regfile_interface_pins.watchdog_reset_pulse_width              ),
 .current_watchdog_count      (uart_regfile_interface_pins.current_watchdog_count              ),
 .watchdog_event_count        (uart_regfile_interface_pins.watchdog_event_count              ),
 .uart_active_high_async_reset(uart_regfile_interface_pins.uart_active_high_async_reset              ),
 .rxd                         (uart_regfile_interface_pins.rxd              ),
 .txd                         (uart_regfile_interface_pins.txd              ),
 .main_sm                     (uart_regfile_interface_pins.main_sm              ),
 .tx_sm                       (uart_regfile_interface_pins.tx_sm              ),
 .command_count               (uart_regfile_interface_pins.command_count              ),


  .wbm_adr_o(wishbone_master_interface_pins.wbs_adr_i),
  .wbm_dat_i(wishbone_master_interface_pins.wbs_dat_o),
  .wbm_dat_o(wishbone_master_interface_pins.wbs_dat_i),
  .wbm_sel_o(wishbone_master_interface_pins.wbs_sel_i),
  .wbm_cyc_o(wishbone_master_interface_pins.wbs_cyc_i),
  .wbm_stb_o(wishbone_master_interface_pins.wbs_stb_i),
  .wbm_we_o (wishbone_master_interface_pins.wbs_we_i ),
  .wbm_ack_i(wishbone_master_interface_pins.wbs_ack_o),
  .wbm_rty_i(wishbone_master_interface_pins.wbs_rty_o),
  .wbm_err_i(wishbone_master_interface_pins.wbs_err_o)
 
 
);
 
endmodule
