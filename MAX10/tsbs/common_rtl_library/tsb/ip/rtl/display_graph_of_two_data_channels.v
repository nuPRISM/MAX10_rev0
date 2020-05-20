`default_nettype none
`include "interface_defs.v"
`include "carrier_board_interface_defs.v"
`include "uart_regfile_interface_defs.v"

module display_graph_of_two_data_channels
#(
parameter current_FMC = 1, //dummy parameter
parameter device_family = "Stratix IV",
parameter num_delay_fifo_locations = 256,
parameter DELAY_DAC0_INPUT = 0,
parameter DELAY_DAC1_INPUT = 0,
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
parameter HW_TRIGGER_CTRL_DEFAULT = 32'h18,
parameter PACKET_GENERATOR_NUM_PACKET_WORDS  = 1024,
parameter [0:0] ENABLE_HW_TRIGGER_INTERFACE = 1
)
(
 avalon_st_streaming_interface  avalon_st_streaming_data_to_display_dac0,
 avalon_st_streaming_interface  avalon_st_streaming_data_to_display_dac1,
 avalon_st_streaming_interface  dac0_packet_out,
 avalon_st_streaming_interface  dac1_packet_out,
 input uart_clk,
 input rate_match_clk,
 wishbone_interface external_nios_dacs_status_wishbone_interface_pins,
 wishbone_interface external_nios_dacs_control_wishbone_interface_pins,
 
  input uart_rx,
  output uart_tx,
  
  input async_hw_trigger,
  output actual_hw_trigger,
  input wire       UART_IS_SECONDARY_UART,
  input wire [7:0] UART_NUM_SECONDARY_UARTS,
  input wire [7:0] UART_ADDRESS_OF_THIS_UART,
  output     [7:0] NUM_UARTS_HERE
);

import uart_regfile_types::*;

uart_struct uart_pins; 
logic [7:0] LOCAL_NUM_UARTS_HERE[3];
wire dacs_txd;
logic TxRMrate_match_fifo_uart_tx[2];
assign uart_tx = dacs_txd & TxRMrate_match_fifo_uart_tx[0]& TxRMrate_match_fifo_uart_tx[1]; 

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
actual_avalon_st_streaming_data_to_display_dac0();

avalon_st_streaming_interface  
#(
.num_data_bits(DATA_WIDTH_TO_COMPOSITE_FIFO)
) 
actual_avalon_st_streaming_data_to_display_dac1();

avalon_st_streaming_interface  
#(
.num_data_bits(DATA_WIDTH_TO_COMPOSITE_FIFO)
) 
possibly_delayed_avalon_st_streaming_data_to_display_dac0();

avalon_st_streaming_interface  
#(
.num_data_bits(DATA_WIDTH_TO_COMPOSITE_FIFO)
) 
possibly_delayed_avalon_st_streaming_data_to_display_dac1();


assign NUM_UARTS_HERE = LOCAL_NUM_UARTS_HERE[0] + LOCAL_NUM_UARTS_HERE[1] + LOCAL_NUM_UARTS_HERE[2];

assign possibly_delayed_avalon_st_streaming_data_to_display_dac0.clk   = avalon_st_streaming_data_to_display_dac0.clk  ;
assign possibly_delayed_avalon_st_streaming_data_to_display_dac1.clk   = avalon_st_streaming_data_to_display_dac1.clk  ;

logic [1:0] edge_detect_actual_hw_trigger;

 edge_detector
 edge_detector_trigger_dac0 (
 .insignal  (actual_hw_trigger), 
 .outsignal (edge_detect_actual_hw_trigger[0]), 
 .clk       (possibly_delayed_avalon_st_streaming_data_to_display_dac0.clk)
 );

 edge_detector
 edge_detector_trigger_dac1 (
 .insignal  (actual_hw_trigger), 
 .outsignal (edge_detect_actual_hw_trigger[1]), 
 .clk       (possibly_delayed_avalon_st_streaming_data_to_display_dac1.clk)
 );


make_st_packet_from_triggered_data_w_info_in_lower_bits
#(
.num_packet_words   (PACKET_GENERATOR_NUM_PACKET_WORDS   ),
.num_input_data_bits(DATA_WIDTH_TO_COMPOSITE_FIFO        )
)
make_st_packet_from_triggered_data_dac0
(
.clk(possibly_delayed_avalon_st_streaming_data_to_display_dac0.clk),
.reset(1'b0),
.trigger(edge_detect_actual_hw_trigger[0]),
.indata(possibly_delayed_avalon_st_streaming_data_to_display_dac0.data),
.avalon_st_source_out(dac0_packet_out),
.packet_word_counter(),
.currently_processing_packet()
);


make_st_packet_from_triggered_data_w_info_in_lower_bits
#(
.num_packet_words   (PACKET_GENERATOR_NUM_PACKET_WORDS   ),
.num_input_data_bits(DATA_WIDTH_TO_COMPOSITE_FIFO        )
)
make_st_packet_from_triggered_data_dac1
(
.clk(possibly_delayed_avalon_st_streaming_data_to_display_dac1.clk),
.reset(1'b0),
.trigger(edge_detect_actual_hw_trigger[1]),
.indata(possibly_delayed_avalon_st_streaming_data_to_display_dac1.data),
.avalon_st_source_out(dac1_packet_out),
.packet_word_counter(),
.currently_processing_packet()
);

generate
	
        if (DELAY_DAC0_INPUT) 
		begin
		     simple_fifo_delay_line
			#(
			 .device_family(device_family),
			 .num_locations(num_delay_fifo_locations),
			 .num_data_bits(DATA_WIDTH_TO_COMPOSITE_FIFO)
			)
			simple_fifo_delay_line_dac0
			(
				.async_clear_fifo(1'b0),
				.clock(avalon_st_streaming_data_to_display_dac0.clk),
				.data_in(avalon_st_streaming_data_to_display_dac0.data),
				.data_in_valid(avalon_st_streaming_data_to_display_dac0.valid),	
				.data_out(possibly_delayed_avalon_st_streaming_data_to_display_dac0.data),
				.usedw(),
				.delay_achieved(possibly_delayed_avalon_st_streaming_data_to_display_dac0.valid)	
			); 
        end else
		begin
              assign possibly_delayed_avalon_st_streaming_data_to_display_dac0.data  = avalon_st_streaming_data_to_display_dac0.data ;
              assign possibly_delayed_avalon_st_streaming_data_to_display_dac0.valid = avalon_st_streaming_data_to_display_dac0.valid;
		end
		
		 if (DELAY_DAC1_INPUT) 
		 begin
		     simple_fifo_delay_line
			#(
			 .device_family(device_family),
			 .num_locations(num_delay_fifo_locations),
			 .num_data_bits(DATA_WIDTH_TO_COMPOSITE_FIFO)
			)
			simple_fifo_delay_line_dac1
			(
				.async_clear_fifo(1'b0),
				.clock(avalon_st_streaming_data_to_display_dac1.clk),
				.data_in(avalon_st_streaming_data_to_display_dac1.data),
				.data_in_valid(avalon_st_streaming_data_to_display_dac1.valid),	
				.data_out(possibly_delayed_avalon_st_streaming_data_to_display_dac1.data),
				.usedw(),
				.delay_achieved(possibly_delayed_avalon_st_streaming_data_to_display_dac1.valid)	
			); 
         end else
		 begin
              assign possibly_delayed_avalon_st_streaming_data_to_display_dac1.data  = avalon_st_streaming_data_to_display_dac1.data ;
              assign possibly_delayed_avalon_st_streaming_data_to_display_dac1.valid = avalon_st_streaming_data_to_display_dac1.valid;
		 end	 
		 

		if (USE_RATE_MATCH_FIFO)
		begin
		            assign actual_avalon_st_streaming_data_to_display_dac0.clk = rate_match_clk;
					rate_matching_fifo_w_uart
					#(
					.data_width (DATA_WIDTH_TO_COMPOSITE_FIFO),
					.OMIT_CONTROL_REG_DESCRIPTIONS(1'b0),
					.OMIT_STATUS_REG_DESCRIPTIONS(1'b0),
					.UART_CLOCK_SPEED_IN_HZ(UART_CLOCK_SPEED_IN_HZ),
					.REGFILE_BAUD_RATE(REGFILE_DEFAULT_BAUD_RATE),
					.prefix_uart_name({uart_name_prefix,"0"}),
					.ASSUME_ALL_INPUT_DATA_IS_VALID(0)
					)
					rate_matching_fifo_w_uart_dac0
					(
					   .UART_REGFILE_CLK(uart_clk),
					   .RESET_FOR_UART_REGFILE_CLK(1'b0),
						
						.uart_tx(TxRMrate_match_fifo_uart_tx[0]),
						.uart_rx(uart_rx),
						
						.indata       (possibly_delayed_avalon_st_streaming_data_to_display_dac0.data),
						.indata_valid (possibly_delayed_avalon_st_streaming_data_to_display_dac0.valid),
						.indata_clk   (possibly_delayed_avalon_st_streaming_data_to_display_dac0.clk),

						.outdata      (actual_avalon_st_streaming_data_to_display_dac0.data),
						.outdata_valid(actual_avalon_st_streaming_data_to_display_dac0.valid),
						.outdata_clk  (actual_avalon_st_streaming_data_to_display_dac0.clk),
						.external_fifo_reset(1'b0),
						
						.UART_IS_SECONDARY_UART   (1),
						.UART_NUM_SECONDARY_UARTS (0),
						.UART_ADDRESS_OF_THIS_UART(UART_ADDRESS_OF_THIS_UART+LOCAL_NUM_UARTS_HERE[0]),
						.NUM_UARTS_HERE(LOCAL_NUM_UARTS_HERE[1])
					);

		            assign actual_avalon_st_streaming_data_to_display_dac1.clk = rate_match_clk;
					rate_matching_fifo_w_uart
					#(
					.data_width (DATA_WIDTH_TO_COMPOSITE_FIFO),
					.OMIT_CONTROL_REG_DESCRIPTIONS(1'b0),
					.OMIT_STATUS_REG_DESCRIPTIONS(1'b0),
					.UART_CLOCK_SPEED_IN_HZ(UART_CLOCK_SPEED_IN_HZ),
					.REGFILE_BAUD_RATE(REGFILE_DEFAULT_BAUD_RATE),
					.prefix_uart_name({uart_name_prefix,"1"}),
					.ASSUME_ALL_INPUT_DATA_IS_VALID(0)
					)
					rate_matching_fifo_w_uart_dac1
					(
					   .UART_REGFILE_CLK(uart_clk),
					   .RESET_FOR_UART_REGFILE_CLK(1'b0),
						
						.uart_tx(TxRMrate_match_fifo_uart_tx[1]),
						.uart_rx(uart_rx),
						
						.indata       (possibly_delayed_avalon_st_streaming_data_to_display_dac1.data),
						.indata_valid (possibly_delayed_avalon_st_streaming_data_to_display_dac1.valid),
						.indata_clk   (possibly_delayed_avalon_st_streaming_data_to_display_dac1.clk),

						.outdata      (actual_avalon_st_streaming_data_to_display_dac1.data),
						.outdata_valid(actual_avalon_st_streaming_data_to_display_dac1.valid),
						.outdata_clk  (actual_avalon_st_streaming_data_to_display_dac1.clk),
						.external_fifo_reset(1'b0),
						
						.UART_IS_SECONDARY_UART   (1),
						.UART_NUM_SECONDARY_UARTS (0),
						.UART_ADDRESS_OF_THIS_UART(UART_ADDRESS_OF_THIS_UART+LOCAL_NUM_UARTS_HERE[0]+LOCAL_NUM_UARTS_HERE[1]),
						.NUM_UARTS_HERE(LOCAL_NUM_UARTS_HERE[2])
					);
		end else
		begin
              assign actual_avalon_st_streaming_data_to_display_dac0.clk   = possibly_delayed_avalon_st_streaming_data_to_display_dac0.clk;
              assign actual_avalon_st_streaming_data_to_display_dac0.data  = possibly_delayed_avalon_st_streaming_data_to_display_dac0.data;
              assign actual_avalon_st_streaming_data_to_display_dac0.valid = possibly_delayed_avalon_st_streaming_data_to_display_dac0.valid;
			  assign actual_avalon_st_streaming_data_to_display_dac1.clk   = possibly_delayed_avalon_st_streaming_data_to_display_dac1.clk;
              assign actual_avalon_st_streaming_data_to_display_dac1.data  = possibly_delayed_avalon_st_streaming_data_to_display_dac1.data;
              assign actual_avalon_st_streaming_data_to_display_dac1.valid = possibly_delayed_avalon_st_streaming_data_to_display_dac1.valid;
			  assign TxRMrate_match_fifo_uart_tx[0] = 1;
			  assign TxRMrate_match_fifo_uart_tx[1] = 1;
			  assign LOCAL_NUM_UARTS_HERE[1] = 0;
			  assign LOCAL_NUM_UARTS_HERE[2] = 0;
		end

endgenerate

genvar current_nios_dac;
generate
		for (current_nios_dac = 0; current_nios_dac < 2; current_nios_dac++)
		begin : assign_dac_input_signals
                if (current_nios_dac == 0)	
                begin				
				       assign nios_dac_pins_of_composite_signal.selected_clk_to_dac[current_nios_dac] = actual_avalon_st_streaming_data_to_display_dac0.clk;				
					    always_ff @(posedge nios_dac_pins_of_composite_signal.selected_clk_to_dac[current_nios_dac])
						begin 
							 case (nios_dac_pins_of_composite_signal.select_channel_to_dac[current_nios_dac])
							  1'b0: begin
										 nios_dac_pins_of_composite_signal.selected_channel_to_dac[current_nios_dac] <= actual_avalon_st_streaming_data_to_display_dac0.data;
										 nios_dac_pins_of_composite_signal.valid_to_dac[current_nios_dac] <= actual_avalon_st_streaming_data_to_display_dac0.valid;
									 end
									 
								
								1'b1: begin 
											nios_dac_pins_of_composite_signal.selected_channel_to_dac[current_nios_dac] <= actual_avalon_st_streaming_data_to_display_dac0.data;
											 nios_dac_pins_of_composite_signal.valid_to_dac[current_nios_dac] <= 1;
									   end		
							  endcase 
						end
				end else
				begin
				       assign nios_dac_pins_of_composite_signal.selected_clk_to_dac[current_nios_dac] = actual_avalon_st_streaming_data_to_display_dac1.clk;		
					   always_ff @(posedge nios_dac_pins_of_composite_signal.selected_clk_to_dac[current_nios_dac])
						begin 
							 case (nios_dac_pins_of_composite_signal.select_channel_to_dac[current_nios_dac])
							  1'b0: begin
										 nios_dac_pins_of_composite_signal.selected_channel_to_dac[current_nios_dac] <= actual_avalon_st_streaming_data_to_display_dac1.data;
										 nios_dac_pins_of_composite_signal.valid_to_dac[current_nios_dac] <= actual_avalon_st_streaming_data_to_display_dac1.valid;
									 end
									 
								
								1'b1: begin 
											nios_dac_pins_of_composite_signal.selected_channel_to_dac[current_nios_dac] <= actual_avalon_st_streaming_data_to_display_dac1.data;
											 nios_dac_pins_of_composite_signal.valid_to_dac[current_nios_dac] <= 1;
									   end		
							  endcase 
						end
				end
				
			   assign nios_dac_pins_of_composite_signal.dac_descriptions[current_nios_dac][0] = current_nios_dac == 0 ? "data0" : "data1";
		       assign nios_dac_pins_of_composite_signal.dac_descriptions[current_nios_dac][1] = current_nios_dac == 0 ? "data0Vis1" : "data1Vis1";
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
.HW_TRIGGER_CTRL_DEFAULT(HW_TRIGGER_CTRL_DEFAULT),
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
     .async_hw_trigger(async_hw_trigger),
     .actual_hw_trigger(actual_hw_trigger),
    .status_wishbone_interface_pins(external_nios_dacs_status_wishbone_interface_pins),
    .control_wishbone_interface_pins(external_nios_dacs_control_wishbone_interface_pins)	
);

	
endmodule
`default_nettype wire