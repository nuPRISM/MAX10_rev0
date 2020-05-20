`default_nettype none
`include "interface_defs.v"
`include "carrier_board_interface_defs.v"
`include "uart_regfile_interface_defs.v"

module lt2260_support_encapsulator
#(
parameter current_FMC = 1,
parameter REGFILE_DEFAULT_BAUD_RATE = 2000000,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter ENABLE_KEEPS = 0,
parameter OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS=1'b0,
parameter [63:0]  prefix_uart_name = "undef",
parameter USE_FIXED_CLOCK_FOR_UDP_STREAMER = 4'b0000,
parameter REAL_DATA_REORDER_DEFAULT        = 4'b0000,
parameter SELECT_REAL_DATA_DEFAULT         = 4'b0011,
parameter TEST_DATA_REORDER_DEFAULT        = 4'b0000
)
(
 avalon_st_32_bit_packet_interface avalon_st_to_udp_streamer_0,
 avalon_st_32_bit_packet_interface avalon_st_to_udp_streamer_1,
 avalon_st_32_bit_packet_interface avalon_st_to_udp_streamer_2,
 avalon_st_32_bit_packet_interface avalon_st_to_udp_streamer_3, 
 avalon_st_32_bit_packet_interface real_avalon_st_to_udp_streamer_0,
 avalon_st_32_bit_packet_interface real_avalon_st_to_udp_streamer_1,
 avalon_st_32_bit_packet_interface real_avalon_st_to_udp_streamer_2,
 avalon_st_32_bit_packet_interface real_avalon_st_to_udp_streamer_3,
 generic_spi_interface ltc2260_generic_spi_pins,
 input udp_clk,
 input packet_word_clk_base_clk,
 input uart_clk,
 input uart_rx,
 output uart_tx,
 input              TOP_UART_IS_SECONDARY_UART, 
 input [7:0]        TOP_ADDRESS_OF_THIS_UART,   
 input [7:0]        TOP_UART_NUM_OF_SECONDARY_UARTS,
 output logic [7:0] NUM_OF_UARTS_HERE
) ;
logic [7:0] local_num_uarts_here[2];
logic udp_streamer_txd;
logic lt2260_spi_support_txd;

assign uart_tx = udp_streamer_txd & lt2260_spi_support_txd;

assign NUM_OF_UARTS_HERE = local_num_uarts_here[0] + local_num_uarts_here[1];

four_udp_streamer_sources_w_uart_support
#(
.current_FMC(current_FMC),
.REGFILE_DEFAULT_BAUD_RATE(REGFILE_DEFAULT_BAUD_RATE),
.UART_CLOCK_SPEED_IN_HZ(UART_CLOCK_SPEED_IN_HZ),
.ENABLE_KEEPS(ENABLE_KEEPS),
.OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS(OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS),
.OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS(OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS),
.prefix_uart_name(prefix_uart_name),
.USE_FIXED_CLOCK_FOR_UDP_STREAMER(USE_FIXED_CLOCK_FOR_UDP_STREAMER),
.REAL_DATA_REORDER_DEFAULT (REAL_DATA_REORDER_DEFAULT  ),    
.SELECT_REAL_DATA_DEFAULT  (SELECT_REAL_DATA_DEFAULT   ),    
.TEST_DATA_REORDER_DEFAULT (TEST_DATA_REORDER_DEFAULT  )    
)
four_udp_streamer_sources_w_uart_support_inst
(
 .*,
 .uart_tx(udp_streamer_txd),
 .TOP_UART_IS_SECONDARY_UART     (TOP_UART_IS_SECONDARY_UART     ), 
 .TOP_ADDRESS_OF_THIS_UART       (TOP_ADDRESS_OF_THIS_UART       ),   
 .TOP_UART_NUM_OF_SECONDARY_UARTS(TOP_UART_NUM_OF_SECONDARY_UARTS),
 .NUM_OF_UARTS_HERE              (local_num_uarts_here[0])
);

lt2260_spi_support_encapsulator
#(
.current_FMC(current_FMC),
.REGFILE_DEFAULT_BAUD_RATE(REGFILE_DEFAULT_BAUD_RATE),
.ENABLE_KEEPS(1'b1),
.OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS(1'b0),
.OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS(1'b0),
.GENERATE_SPI_TEST_CLOCK_SIGNALS(1'b1)
)
(
  .*,
 .uart_clk_50_MHz(uart_clk),
 .uart_tx(lt2260_spi_support_txd),
 .TOP_UART_IS_SECONDARY_UART     (1), 
 .TOP_ADDRESS_OF_THIS_UART       (TOP_ADDRESS_OF_THIS_UART+local_num_uarts_here[0]),   
 .TOP_UART_NUM_OF_SECONDARY_UARTS(0),
 .NUM_OF_UARTS_HERE(local_num_uarts_here[1])
);

endmodule
`default_nettype wire