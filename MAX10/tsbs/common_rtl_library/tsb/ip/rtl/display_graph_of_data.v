`default_nettype none
`include "interface_defs.v"
`include "carrier_board_interface_defs.v"
`include "uart_regfile_interface_defs.v"

module display_graph_of_data
#(
parameter current_FMC = 1, //dummy parameter
parameter ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS = 14,
parameter FULL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS = 16,
parameter REGFILE_DEFAULT_BAUD_RATE = 2000000,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter CHANGE_FORMAT_OF_ACQUIRED_DATA = 3,
parameter NIOS_DACS_WISHBONE_INTERFACE_IS_PART_OF_BRIDGE  = 1'b0,
parameter NIOS_DACS_WISHBONE_CONTROL_BASE_ADDRESS = 32'hEAAEAA, 
parameter NIOS_DACS_WISHBONE_STATUS_BASE_ADDRESS  = 32'hEAAEAA,
parameter NIOS_DACS_STATUS_WISHBONE_NUM_ADDRESS_BITS = 8,
parameter NIOS_DACS_CONTROL_WISHBONE_NUM_ADDRESS_BITS= 8,
parameter [63:0] uart_name_prefix = "Undef",
parameter num_samples_per_frame = 1,
parameter num_bits_per_sample = 16,
parameter DATA_WIDTH_TO_COMPOSITE_FIFO = num_samples_per_frame*num_bits_per_sample,
parameter USE_RATE_MATCH_FIFO = 1,
parameter [0:0] ENABLE_HW_TRIGGER_INTERFACE = 1
)
(
 avalon_st_streaming_interface  avalon_st_streaming_data_to_display,
 input uart_clk,
 input rate_match_clk,
 wishbone_interface external_nios_dacs_status_wishbone_interface_pins,
 wishbone_interface external_nios_dacs_control_wishbone_interface_pins,
 
  input uart_rx,
  output uart_tx,
 
  input wire       UART_IS_SECONDARY_UART,
  input wire [7:0] UART_NUM_SECONDARY_UARTS,
  input wire [7:0] UART_ADDRESS_OF_THIS_UART,
  output     [7:0] NUM_UARTS_HERE
);

import uart_regfile_types::*;

uart_struct uart_pins; 
logic [7:0] LOCAL_NUM_UARTS_HERE[2];
wire dacs_txd;
logic TxRMrate_match_fifo_uart_tx;
assign uart_tx = dacs_txd & TxRMrate_match_fifo_uart_tx; 

wire rate_matched_rx_data_valid;
logic [DATA_WIDTH_TO_COMPOSITE_FIFO-1:0] rate_matched_rx_data;

multi_dac_interface  
#(
.num_dacs(2),
.data_width(DATA_WIDTH_TO_COMPOSITE_FIFO),
.num_selection_bits(1)
) 
nios_dac_pins_of_composite_signal();

avalon_st_streaming_interface  
#(
.num_data_bits(DATA_WIDTH_TO_COMPOSITE_FIFO)
) 
actual_avalon_st_streaming_data_to_display();

 assign NUM_UARTS_HERE = LOCAL_NUM_UARTS_HERE[0] + LOCAL_NUM_UARTS_HERE[1];

generate
		if (USE_RATE_MATCH_FIFO)
		begin
		            assign actual_avalon_st_streaming_data_to_display.clk = rate_match_clk;
					rate_matching_fifo_w_uart
					#(
					.data_width (DATA_WIDTH_TO_COMPOSITE_FIFO),
					.OMIT_CONTROL_REG_DESCRIPTIONS(1'b0),
					.OMIT_STATUS_REG_DESCRIPTIONS(1'b0),
					.UART_CLOCK_SPEED_IN_HZ(UART_CLOCK_SPEED_IN_HZ),
					.REGFILE_BAUD_RATE(REGFILE_DEFAULT_BAUD_RATE),
					.prefix_uart_name(uart_name_prefix),
					.ASSUME_ALL_INPUT_DATA_IS_VALID(0)
					)
					Slite_TX_rate_matching_fifo_w_uart_inst
					(
					   .UART_REGFILE_CLK(uart_clk),
					   .RESET_FOR_UART_REGFILE_CLK(1'b0),
						
						.uart_tx(TxRMrate_match_fifo_uart_tx),
						.uart_rx(uart_rx),
						
						.indata       (avalon_st_streaming_data_to_display.data),
						.indata_valid (avalon_st_streaming_data_to_display.valid),
						.indata_clk   (avalon_st_streaming_data_to_display.clk),

						.outdata      (actual_avalon_st_streaming_data_to_display.data),
						.outdata_valid(actual_avalon_st_streaming_data_to_display.valid),
						.outdata_clk  (actual_avalon_st_streaming_data_to_display.clk),
						.external_fifo_reset(1'b0),
						
						.UART_IS_SECONDARY_UART   (1),
						.UART_NUM_SECONDARY_UARTS (0),
						.UART_ADDRESS_OF_THIS_UART(UART_ADDRESS_OF_THIS_UART+1),
						.NUM_UARTS_HERE(LOCAL_NUM_UARTS_HERE[1]),
					);
		end else
		begin
              assign actual_avalon_st_streaming_data_to_display.clk = avalon_st_streaming_data_to_display.clk;
              assign actual_avalon_st_streaming_data_to_display.data = avalon_st_streaming_data_to_display.data;
              assign actual_avalon_st_streaming_data_to_display.valid = avalon_st_streaming_data_to_display.valid;
			  assign TxRMrate_match_fifo_uart_tx = 1;
			  assign LOCAL_NUM_UARTS_HERE[1] = 0;
		end

endgenerate

genvar current_nios_dac;
generate
		for (current_nios_dac = 0; current_nios_dac < 2; current_nios_dac++)
		begin : assign_dac_input_signals		       		          			
				assign nios_dac_pins_of_composite_signal.selected_clk_to_dac[current_nios_dac] = actual_avalon_st_streaming_data_to_display.clk;				
				always_ff @(posedge nios_dac_pins_of_composite_signal.selected_clk_to_dac[current_nios_dac])
				begin 
					 case (nios_dac_pins_of_composite_signal.select_channel_to_dac[current_nios_dac])
					  1'b0: begin
								 nios_dac_pins_of_composite_signal.selected_channel_to_dac[current_nios_dac] <= actual_avalon_st_streaming_data_to_display.data;
								 nios_dac_pins_of_composite_signal.valid_to_dac[current_nios_dac] <= actual_avalon_st_streaming_data_to_display.valid;
							 end
							 
					 	
						1'b1: begin 
									nios_dac_pins_of_composite_signal.selected_channel_to_dac[current_nios_dac] <= actual_avalon_st_streaming_data_to_display.data;
								     nios_dac_pins_of_composite_signal.valid_to_dac[current_nios_dac] <= 1;
							   end		
					  endcase 
				end
			   assign nios_dac_pins_of_composite_signal.dac_descriptions[current_nios_dac][0] = "data";
		       assign nios_dac_pins_of_composite_signal.dac_descriptions[current_nios_dac][1] = "dataValidIs1";
		end	
endgenerate

reformat_and_connect_parallel_bus_to_nios_dacs
#(
.ENABLE_CONTROL_WISHBONE_INTERFACE (1'b1),
.ENABLE_STATUS_WISHBONE_INTERFACE  (1'b1),
.in_data_bits(DATA_WIDTH_TO_COMPOSITE_FIFO),
.out_data_bits(FULL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS),
.ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS(ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS),
.ENABLE_KEEPS(1),
.OMIT_CONTROL_REG_DESCRIPTIONS (1'b0),
.OMIT_STATUS_REG_DESCRIPTIONS  (1'b0),
.UART_CLOCK_SPEED_IN_HZ(UART_CLOCK_SPEED_IN_HZ),
.REGFILE_BAUD_RATE(REGFILE_DEFAULT_BAUD_RATE),
.prefix_uart_name(uart_name_prefix),
.UART_REGFILE_TYPE(uart_regfile_types::JESD_NIOS_DACS_STANDALONE_REGFILE),
.USE_GENERIC_ATTRIBUTE_FOR_READ_LD(1'b0),
.change_format_default(CHANGE_FORMAT_OF_ACQUIRED_DATA),
.WISHBONE_INTERFACE_IS_PART_OF_BRIDGE   (NIOS_DACS_WISHBONE_INTERFACE_IS_PART_OF_BRIDGE ),
.WISHBONE_CONTROL_BASE_ADDRESS        	(NIOS_DACS_WISHBONE_CONTROL_BASE_ADDRESS        ),	 
.WISHBONE_STATUS_BASE_ADDRESS         	(NIOS_DACS_WISHBONE_STATUS_BASE_ADDRESS         ),
.STATUS_WISHBONE_NUM_ADDRESS_BITS       (NIOS_DACS_STATUS_WISHBONE_NUM_ADDRESS_BITS     ),
.CONTROL_WISHBONE_NUM_ADDRESS_BITS      (NIOS_DACS_CONTROL_WISHBONE_NUM_ADDRESS_BITS    ),
.COMPILE_TEST_SIGNAL_DDS(1'b1),
.ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION(1'b1),
.ENABLE_HW_TRIGGER_INTERFACE(ENABLE_HW_TRIGGER_INTERFACE)
)
reformat_and_connect_parallel_bus_to_nios_dacs_inst
(
	.CLKIN(uart_clk),
	.RESET_FOR_CLKIN(1'b0),
	
	.nios_dac_pins(nios_dac_pins_of_composite_signal),
	
	.uart_tx(dacs_txd),
	.uart_rx(uart_rx),
	
   .UART_IS_SECONDARY_UART   (UART_IS_SECONDARY_UART),
   .UART_NUM_SECONDARY_UARTS (UART_NUM_SECONDARY_UARTS),
   .UART_ADDRESS_OF_THIS_UART(UART_ADDRESS_OF_THIS_UART),
	.NUM_UARTS_HERE(LOCAL_NUM_UARTS_HERE[0]),
    .status_wishbone_interface_pins(external_nios_dacs_status_wishbone_interface_pins),
    .control_wishbone_interface_pins(external_nios_dacs_control_wishbone_interface_pins)
	
);

	
endmodule
`default_nettype wire