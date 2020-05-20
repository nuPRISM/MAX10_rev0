
`include "interface_defs.v"
`include "uart_regfile_interface_defs.v"

module uart_controlled_register_file_w_interfaces
#(
	parameter  [15:0] DATA_NUMBYTES        =   4,
    parameter  [15:0] DESC_NUMBYTES        =  16,
	parameter  [15:0] DATA_WIDTH           =   8*DATA_NUMBYTES,
	parameter  [15:0] DESC_WIDTH           =   8*DESC_NUMBYTES,	
    parameter  [15:0] NUM_OF_CONTROL_REGS  =  32,
    parameter  [15:0] NUM_OF_STATUS_REGS   =  32,
    parameter  [15:0]            INIT_ALL_CONTROL_REGS_TO_DEFAULT  =  0,
    parameter  [DATA_WIDTH-1:0]  CONTROL_REGS_DEFAULT_VAL   =  0,
    parameter  [7:0]             USE_AUTO_RESET                         = 1'b1,
    parameter                   CLOCK_SPEED_IN_HZ    = 50000000,
    parameter                   UART_BAUD_RATE_IN_HZ = 115200,
    parameter  [7:0]                 ENABLE_CONTROL_WISHBONE_INTERFACE = 1'b0,
    parameter  [7:0]                 ENABLE_STATUS_WISHBONE_INTERFACE = 1'b0,
                parameter   [7:0]                DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS = 1'b0,
  parameter [0:0]    DISABLE_ERROR_MONITORING = 1'b1,
    parameter [0:0]    IGNORE_TIMING_TO_READ_LD = 1'b0,
  /*
  parameter [0:0]    SET_MAX_DELAY_TIMING_TO_READ_LD = 1'b0,
  parameter [31:0]    MAX_DELAY_TIMING_TO_READ_LD = 1'b0,
  */
  parameter [0:0] USE_GENERIC_ATTRIBUTE_FOR_READ_LD = 1'b0,
  parameter GENERIC_ATTRIBUTE_FOR_READ_LD = "ERROR",
  parameter [7:0] STATUS_WISHBONE_NUM_ADDRESS_BITS = ENABLE_STATUS_WISHBONE_INTERFACE ? $clog2(NUM_OF_STATUS_REGS) : 0,
  parameter [7:0] CONTROL_WISHBONE_NUM_ADDRESS_BITS = ENABLE_CONTROL_WISHBONE_INTERFACE ? $clog2(NUM_OF_CONTROL_REGS) : 0,
  parameter [31:0] WISHBONE_CONTROL_BASE_ADDRESS     = 0,
  parameter [31:0] WISHBONE_STATUS_BASE_ADDRESS      = 0,
  parameter [0:0] WISHBONE_INTERFACE_IS_PART_OF_BRIDGE = 1'b0,
  parameter [0:0] UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK = 1'b0,
  parameter [0:0] USE_LEGACY_UART_PARSER = 0,
  parameter [0:0] COMPILE_CRC_ERROR_CHECKING_IN_PARSER = 0

)
(
 uart_regfile_interface uart_regfile_interface_pins,
 wishbone_interface control_wishbone_interface_pins,
 wishbone_interface status_wishbone_interface_pins
);

uart_controlled_register_file_ver3
#(
 .DATA_WIDTH_IN_BYTES              ( DATA_NUMBYTES                    ),
 .DESC_WIDTH_IN_BYTES              ( DESC_NUMBYTES                    ),
 .NUM_OF_CONTROL_REGS              ( NUM_OF_CONTROL_REGS              ),
 .NUM_OF_STATUS_REGS               ( NUM_OF_STATUS_REGS               ),
 .INIT_ALL_CONTROL_REGS_TO_DEFAULT ( INIT_ALL_CONTROL_REGS_TO_DEFAULT ),
 .CONTROL_REGS_DEFAULT_VAL         ( CONTROL_REGS_DEFAULT_VAL         ),
 .USE_AUTO_RESET                   ( USE_AUTO_RESET                   ),
 .CLOCK_SPEED_IN_HZ                ( CLOCK_SPEED_IN_HZ                ),
 .UART_BAUD_RATE_IN_HZ             ( UART_BAUD_RATE_IN_HZ             ),
 .ENABLE_CONTROL_WISHBONE_INTERFACE( ENABLE_CONTROL_WISHBONE_INTERFACE),
 .ENABLE_STATUS_WISHBONE_INTERFACE ( ENABLE_STATUS_WISHBONE_INTERFACE ),
 .DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS(DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS),
 .DISABLE_ERROR_MONITORING(DISABLE_ERROR_MONITORING),
 .IGNORE_TIMING_TO_READ_LD(IGNORE_TIMING_TO_READ_LD),
 .USE_GENERIC_ATTRIBUTE_FOR_READ_LD(USE_GENERIC_ATTRIBUTE_FOR_READ_LD),
 .GENERIC_ATTRIBUTE_FOR_READ_LD(GENERIC_ATTRIBUTE_FOR_READ_LD), 
 .STATUS_WISHBONE_NUM_ADDRESS_BITS      ( STATUS_WISHBONE_NUM_ADDRESS_BITS   ),
 .CONTROL_WISHBONE_NUM_ADDRESS_BITS     ( CONTROL_WISHBONE_NUM_ADDRESS_BITS  ),
 .WISHBONE_CONTROL_BASE_ADDRESS         ( WISHBONE_CONTROL_BASE_ADDRESS      ),
 .WISHBONE_STATUS_BASE_ADDRESS          ( WISHBONE_STATUS_BASE_ADDRESS       ),
 .WISHBONE_INTERFACE_IS_PART_OF_BRIDGE  ( WISHBONE_INTERFACE_IS_PART_OF_BRIDGE ),
 .UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK  ( UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK ),
 .USE_LEGACY_UART_PARSER(USE_LEGACY_UART_PARSER),
 .COMPILE_CRC_ERROR_CHECKING_IN_PARSER(COMPILE_CRC_ERROR_CHECKING_IN_PARSER)
 )
uart_regfile_internal
(	
 .CLK                         (uart_regfile_interface_pins.clk              ),
 .data_clock                  (uart_regfile_interface_pins.data_clk              ),
 .REG_ACTIVE_HIGH_ASYNC_RESET (uart_regfile_interface_pins.reset              ),
 .CONTROL                     (uart_regfile_interface_pins.control              ),
 .CONTROL_BITWIDTH            (uart_regfile_interface_pins.control_regs_bitwidth              ),
 .CONTROL_DESC                (uart_regfile_interface_pins.control_desc              ),
 .STATUS                      (uart_regfile_interface_pins.status             ),
 .STATUS_BITWIDTH             (                                               ),
 .STATUS_DESC                 (uart_regfile_interface_pins.status_desc                               ),
 .CONTROL_INIT_VAL            (uart_regfile_interface_pins.control_regs_default_vals              ),
 .STATUS_OMIT_DESC            (uart_regfile_interface_pins.status_omit_desc              ),
 .CONTROL_OMIT_DESC           (uart_regfile_interface_pins.control_omit_desc              ),
 .CONTROL_SHORT_TO_DEFAULT    (uart_regfile_interface_pins.control_short_to_default              ),
 .STATUS_OMIT                 (uart_regfile_interface_pins.status_omit              ),
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
 .ignore_crc_value_for_debugging (uart_regfile_interface_pins.ignore_crc_value_for_debugging ),
 .control_wishbone_interface_pins (control_wishbone_interface_pins ),
 .status_wishbone_interface_pins  (status_wishbone_interface_pins  )
);
 
endmodule
