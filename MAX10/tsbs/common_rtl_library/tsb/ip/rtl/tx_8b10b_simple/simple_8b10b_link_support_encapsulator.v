`default_nettype none
`include "interface_defs.v"
`include "uart_regfile_interface_defs.v"

module alphag_component_support_encapsulator
#(
parameter current_FMC = 1,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_DEFAULT_BAUD_RATE = 2000000,
parameter ENABLE_KEEPS = 0,
parameter OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS=1'b0,
parameter GENERATE_SPI_TEST_CLOCK_SIGNALS=1'b1,
parameter [0:0] COMPILE_TEMP_MON = 1'b0
)
(
 input  uart_rx,
 output uart_tx,
 input  uart_clk,
 input              TOP_UART_IS_SECONDARY_UART     , 
 input [7:0]        TOP_ADDRESS_OF_THIS_UART       ,   
 input [7:0]        TOP_UART_NUM_OF_SECONDARY_UARTS,
 output logic [7:0] NUM_OF_UARTS_HERE
);

import uart_regfile_types::*;
logic [7:0] local_num_uarts_here[5];
logic sca_txd;
logic sca_is_first_spi;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic lt2263_1_spi_support_txd;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic lt2263_2_spi_support_txd;
 
localparam UART_CLOCK_SPEED_IN_HZ = 50000000; //must be 50 MHz
uart_struct uart_pins; 

(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic     ltc2983_txd;
 
assign uart_pins.rx = uart_rx;
assign uart_tx = uart_pins.tx;
assign uart_pins.tx = ltc2983_txd & sca_txd & lt2263_1_spi_support_txd & lt2263_2_spi_support_txd;

assign NUM_OF_UARTS_HERE = local_num_uarts_here[0] + local_num_uarts_here[1] + local_num_uarts_here[2] + local_num_uarts_here[3] + local_num_uarts_here[4];	
 
generate
		if (COMPILE_TEMP_MON)
		begin
			generic_spi_support_encapsulator
			#(
			.REGFILE_DEFAULT_BAUD_RATE               (REGFILE_DEFAULT_BAUD_RATE               ),
			.UART_CLOCK_SPEED_IN_HZ                  (UART_CLOCK_SPEED_IN_HZ                  ),
			.ENABLE_KEEPS                            (ENABLE_KEEPS                            ),
			.prefix_uart_name                        ("TempMon"                               ),
			.OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS(OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS),
			.OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS (OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS ),
			.GENERATE_SPI_TEST_CLOCK_SIGNALS         (GENERATE_SPI_TEST_CLOCK_SIGNALS         )
			)
			temperature_spi
			(
			 .generic_spi_pins(ltc2983_generic_spi_pins),
			 .uart_clk_50_MHz(CLK_50MHZ),
			 .RESET_FOR_CLKIN_50MHz(1'b0),
			 .uart_rx(uart_pins.rx),
			 .uart_tx(ltc2983_txd),

			  .TOP_UART_IS_SECONDARY_UART     (TOP_UART_IS_SECONDARY_UART), 
			  .TOP_ADDRESS_OF_THIS_UART       (TOP_ADDRESS_OF_THIS_UART)     ,   
			  .TOP_UART_NUM_OF_SECONDARY_UARTS(TOP_UART_NUM_OF_SECONDARY_UARTS),
			  .NUM_OF_UARTS_HERE(local_num_uarts_here[0])
			);
			assign sca_is_first_spi = 0;
		end else
		begin
		   assign local_num_uarts_here[0] = 0;
		   assign sca_is_first_spi = 1;
		   assign ltc2983_txd = 1;
		end
endgenerate


generic_spi_support_encapsulator
#(
.REGFILE_DEFAULT_BAUD_RATE               (REGFILE_DEFAULT_BAUD_RATE               ),
.UART_CLOCK_SPEED_IN_HZ                  (UART_CLOCK_SPEED_IN_HZ                  ),
.ENABLE_KEEPS                            (ENABLE_KEEPS                            ),
.prefix_uart_name                        ("sca_0"                                ),
.OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS(OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS),
.OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS (OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS ),
.GENERATE_SPI_TEST_CLOCK_SIGNALS         (GENERATE_SPI_TEST_CLOCK_SIGNALS         )
)
sca_0_standalone_opencores_spi_w_uart_control
(
 .generic_spi_pins(sca_0_generic_spi_pins),
 .uart_clk_50_MHz(CLK_50MHZ),
 .RESET_FOR_CLKIN_50MHz(1'b0),
 .uart_rx(uart_pins.rx),
 .uart_tx(sca_txd),
 
 .TOP_UART_IS_SECONDARY_UART     (sca_is_first_spi ? TOP_UART_IS_SECONDARY_UART : 1), 
 .TOP_ADDRESS_OF_THIS_UART       (TOP_ADDRESS_OF_THIS_UART+local_num_uarts_here[0]),   
 .TOP_UART_NUM_OF_SECONDARY_UARTS(sca_is_first_spi ? TOP_UART_NUM_OF_SECONDARY_UARTS : 0),
 .NUM_OF_UARTS_HERE(local_num_uarts_here[1])
);

lt2263_spi_support_encapsulator
#(
.prefix_uart_name("ADC1"),
.current_FMC(current_FMC),
.REGFILE_DEFAULT_BAUD_RATE(REGFILE_DEFAULT_BAUD_RATE),
.ENABLE_KEEPS(ENABLE_KEEPS),
.OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS(OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS),
.OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS(OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS),
.GENERATE_SPI_TEST_CLOCK_SIGNALS(GENERATE_SPI_TEST_CLOCK_SIGNALS)
)
lt2263_spi_support_encapsulator_adc1
(
  .*,
 .ltc2263_generic_spi_pins(ltc2263_1_generic_spi_pins),
 .uart_clk_50_MHz(CLK_50MHZ),
 .uart_rx(uart_pins.rx),
 .uart_tx(lt2263_1_spi_support_txd),
 .TOP_UART_IS_SECONDARY_UART     (1), 
 .TOP_ADDRESS_OF_THIS_UART       (TOP_ADDRESS_OF_THIS_UART+local_num_uarts_here[0] + local_num_uarts_here[1]),   
 .TOP_UART_NUM_OF_SECONDARY_UARTS(0),
 .NUM_OF_UARTS_HERE(local_num_uarts_here[2])
);

lt2263_spi_support_encapsulator
#(
.prefix_uart_name("ADC2"),
.current_FMC(current_FMC),
.REGFILE_DEFAULT_BAUD_RATE(REGFILE_DEFAULT_BAUD_RATE),
.ENABLE_KEEPS(ENABLE_KEEPS),
.OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS(OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS),
.OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS(OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS),
.GENERATE_SPI_TEST_CLOCK_SIGNALS(GENERATE_SPI_TEST_CLOCK_SIGNALS)
)
lt2263_spi_support_encapsulator_adc2
(
 .*,
 .ltc2263_generic_spi_pins(ltc2263_2_generic_spi_pins),
 .uart_clk_50_MHz(CLK_50MHZ),
 .uart_rx(uart_pins.rx),
 .uart_tx(lt2263_2_spi_support_txd),
 .TOP_UART_IS_SECONDARY_UART     (1), 
 .TOP_ADDRESS_OF_THIS_UART       (TOP_ADDRESS_OF_THIS_UART+local_num_uarts_here[0] + local_num_uarts_here[1] + local_num_uarts_here[2]),   
 .TOP_UART_NUM_OF_SECONDARY_UARTS(0),
 .NUM_OF_UARTS_HERE(local_num_uarts_here[3])
);
 endmodule
 `default_nettype wire