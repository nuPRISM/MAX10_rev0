`default_nettype none
`include "interface_defs.v"
`include "uart_regfile_interface_defs.v"

module generic_spi_support_encapsulator
#(
parameter current_FMC                              = 1,
parameter REGFILE_DEFAULT_BAUD_RATE                = 2000000,
parameter UART_CLOCK_SPEED_IN_HZ                   = 50000000,
parameter ENABLE_KEEPS                             = 0,
parameter prefix_uart_name                         = "undef",
parameter OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS  = 1'b0,
parameter GENERATE_SPI_TEST_CLOCK_SIGNALS          = 1'b1,
parameter MAIN_UART_REGFILE_TYPE                   = uart_regfile_types::OPENCORES_SPI_UART_REGFILE,
parameter DIAGNOSTIC_UART_REGFILE_TYPE             = uart_regfile_types::OPENCORES_SPI_DIAGNOSTIC_UART_REGFILE
)
(
 generic_spi_interface generic_spi_pins,
 input  uart_clk_50_MHz,
 input  RESET_FOR_CLKIN_50MHz,
 input  uart_rx,
 output uart_tx,
 input              TOP_UART_IS_SECONDARY_UART     , 
 input [7:0]        TOP_ADDRESS_OF_THIS_UART       ,   
 input [7:0]        TOP_UART_NUM_OF_SECONDARY_UARTS,
 output logic [7:0] NUM_OF_UARTS_HERE
);
import uart_regfile_types::*;

typedef struct 
{
logic tx;
logic rx;
} uart_struct;

uart_struct uart_pins; 
(* keep = 1, preserve = 1 *)  wire     generic_spi_main_local_txd; 
(* keep = 1, preserve = 1 *) wire     generic_spi_diagnostic_local_txd;

assign uart_tx = uart_pins.tx;
assign uart_pins.rx = uart_rx; 
assign uart_pins.tx = generic_spi_main_local_txd & generic_spi_diagnostic_local_txd;	

	
standalone_opencores_spi_w_uart_control
#(
.ENABLE_KEEPS(ENABLE_KEEPS),
.OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS (OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS),
.OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS  (OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS),
.GENERATE_SPI_TEST_CLOCK_SIGNALS(GENERATE_SPI_TEST_CLOCK_SIGNALS),
.UART_CLOCK_SPEED_IN_HZ (UART_CLOCK_SPEED_IN_HZ),
.REGFILE_BAUD_RATE      (REGFILE_DEFAULT_BAUD_RATE),
.prefix_uart_name      (prefix_uart_name),
.MAIN_UART_REGFILE_TYPE       (MAIN_UART_REGFILE_TYPE),
.DIAGNOSTIC_UART_REGFILE_TYPE (DIAGNOSTIC_UART_REGFILE_TYPE)
)
standalone_opencores_spi_w_uart_control_inst
(
	.CLKIN_50MHz(uart_clk_50_MHz),
	.RESET_FOR_CLKIN_50MHz(RESET_FOR_CLKIN_50MHz),
	.diagnostic_uart_tx(generic_spi_diagnostic_local_txd),
	.diagnostic_uart_rx(uart_pins.rx),
	.opencores_spi_uart_tx(generic_spi_main_local_txd),
	.opencores_spi_uart_rx(uart_pins.rx),
	.spi_pins(generic_spi_pins),
    .NUM_OF_UARTS_HERE(NUM_OF_UARTS_HERE),
   
    .DIAGNOSTIC_UART_IS_SECONDARY_UART      (1'b1),
    .DIAGNOSTIC_UART_NUM_SECONDARY_UARTS    (0),
    .DIAGNOSTIC_UART_ADDRESS_OF_THIS_UART   (TOP_ADDRESS_OF_THIS_UART+1),    
	.OPENCORES_SPI_UART_IS_SECONDARY_UART   (TOP_UART_IS_SECONDARY_UART),
    .OPENCORES_SPI_UART_NUM_SECONDARY_UARTS (TOP_UART_NUM_OF_SECONDARY_UARTS),
    .OPENCORES_SPI_UART_ADDRESS_OF_THIS_UART(TOP_ADDRESS_OF_THIS_UART)

);
  
endmodule
`default_nettype wire