`default_nettype none
`include "interface_defs.v"
`include "carrier_board_interface_defs.v"
`include "uart_regfile_interface_defs.v"

module multi_channel_generic_half_frame_to_full_sync
#(
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ  = 50000000,
parameter BERC_SM_CLK_CLOCK_SPEED = 50000000,
parameter REGFILE_DEFAULT_BAUD_RATE = 2000000,
parameter [63:0] uart_parellelizer_2x_prefix = "rxlvdsin",
parameter [63:0] uart_reframer_prefix = "rxlvdsin",
parameter [63:0] uart_dac_prefix = "rxlvdsin",
parameter [63:0] uart_berc_prefix = "rxlvdsin",
parameter LOCK_WAIT_COUNTER_BITS = 9,
parameter NUMBITS_DATAIN_FULL_WIDTH = 14,
parameter NUM_DATA_CHANNELS = 2,
parameter GENERATE_FRAME_CLOCK_ON_NEGEDGE = 1,
parameter CHANNEL_TO_LOOK_AT_FOR_DEBUGGING = 0,
parameter DEFAULT_PARALLELIZER_TRANSPOSE_CTRL = 0,
parameter DEFAULT_SIMULATED_FULL_FRAME_DATA = 14'h2FC0,
parameter DEFAULT_SIMULATED_HALF_FRAME_DATA = 7'h30,
parameter DEFAULT_FRAME_LOCK_MASK = {{(NUMBITS_DATAIN_FULL_WIDTH){1'b1}},{(NUMBITS_DATAIN_FULL_WIDTH){1'b0}}},
parameter DEFAULT_REFRAMER_TRANSPOSE_CTRL = 0,
parameter DEFAULT_LOCK_WAIT = 50,
parameter DEFAULT_ENABLE_LOCK_SCAN = 1,
parameter DEFAULT_FRAME_TO_DATA_OFFSET = 0,
parameter COMPILE_DACS = 1,
parameter NIOS_DACS_WISHBONE_INTERFACE_IS_PART_OF_BRIDGE  = 1'b0,
parameter NIOS_DACS_WISHBONE_CONTROL_BASE_ADDRESS = 32'hEAAEAA, 
parameter NIOS_DACS_WISHBONE_STATUS_BASE_ADDRESS  = 32'hEAAEAA,
parameter NIOS_DACS_STATUS_WISHBONE_NUM_ADDRESS_BITS = 8,
parameter NIOS_DACS_CONTROL_WISHBONE_NUM_ADDRESS_BITS= 8,
parameter ENABLE_KEEPS_ON_DACS = 0,
parameter ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS = 16,
parameter DACS_CHANGE_FORMAT_DEFAULT = 1,
parameter COMPILE_TEST_SIGNAL_DDS  = 1,                 
parameter ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION = 1,
parameter DEFINE_WISHBONE_INTERFACES_FOR_DACS_IF_DISABLED = 1,
parameter [0:0] GENERATE_DDS_TEST_SIGNALS = 1,
parameter [0:0] ALLOW_2X_REPARELLELIZER_SINE_COSINE_TEST_SIGNAL_GENERATION  = 1,
parameter [0:0] USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS = 1,
parameter ACTIVITY_MONITOR_NUMBITS = 32,
parameter [0:0] ALLOW_2X_TO_LOOK_AT_ALL_CHANNELS = 0,
parameter [0:0] ALLOW_REFRAMER_TO_LOOK_AT_ALL_CHANNELS = 0,
parameter [0:0] COMPILE_BER_METER = 1,
parameter [0:0] SUPPORT_INPUT_DESCRIPTIONS = 1,
parameter HW_TRIGGER_CTRL_DEFAULT = 32'h18,

 //===================================================================================================================
  //
  //        BERC
  //
  //===================================================================================================================
			 
   parameter NUM_OF_LVDS_ADC_FRAMES_IN_ONE_BERC_FRAME = 6,
   parameter Parallel_BERC_input_width = NUMBITS_DATAIN_FULL_WIDTH*NUM_OF_LVDS_ADC_FRAMES_IN_ONE_BERC_FRAME,
   parameter Parallel_BERC_number_of_inwidths_in_corr_length = 2,
   
   parameter [15:0] BERC_corr_reg_length = Parallel_BERC_number_of_inwidths_in_corr_length*Parallel_BERC_input_width,
   parameter BERC_corr_count_bits = 8,
   parameter BERC_bit_count_reg_width = 48,
   parameter BERC_error_counter_width = 48,
   parameter [47:0] BERC_bits_to_count_default = 48'd10000,
   parameter [0:0] BERC_TRANSPOSE_REFSEQ_DEFAULT = 1,
   parameter [0:0] BERC_TRANSPOSE_INSEQ_DEFAULT  = 1,
   parameter [7:0] DEFAULT_BERC_DATA_SOURCE = 0,
   parameter [0:0] ENABLE_BERC_PN_SEQUENCE_FUNCTIONALITY = 1,
   parameter [0:0] ENABLE_HW_TRIGGER_INTERFACE = 1,
	parameter       NIOS_DAC_NUM_OUTPUT_SAMPLES_IN_FIFO = 16384,
	parameter NIOS_DAC_FIFO_IS_DUMMY = 0,
	parameter [0:0] NIOS_DAC_USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS = 1


)
(
 input logic [NUMBITS_DATAIN_FULL_WIDTH/2-1:0] half_frame_data_in[NUM_DATA_CHANNELS],
 input logic [NUMBITS_DATAIN_FULL_WIDTH/2-1:0] half_frame_frame_in,
 input  logic half_frame_clk,
 output logic frame_clk,
 output logic [NUMBITS_DATAIN_FULL_WIDTH-1:0] data_out[NUM_DATA_CHANNELS],
 output logic reframer_is_locked,
 input  UART_REGFILE_CLK,
 input  RESET_FOR_UART_REGFILE_CLK,
 input  BERC_sm_clk,
 input  half_frame_clk_valid,
 input  frame_clk_valid,

 input  uart_rx,
 output uart_tx,

 input [7:0] TOP_UART_IS_SECONDARY_UART,   
 input [7:0] TOP_UART_NUM_SECONDARY_UARTS,  
 input [7:0] TOP_UART_ADDRESS_OF_THIS_UART,
 output [7:0] NUM_UARTS_HERE ,
 input [NUMBITS_DATAIN_FULL_WIDTH-1:0] base_pattern_to_output_for_atrophied_generation,
 
  wishbone_interface external_nios_dacs_status_wishbone_interface_pins,
  wishbone_interface external_nios_dacs_control_wishbone_interface_pins,
  input  async_hw_trigger ,
  output actual_hw_trigger
);
 localparam ZERO_IN_ASCII = 48;

import uart_regfile_types::*;

uart_struct uart_pins; 
logic parallelizer_txd;
logic reframer_txd;
logic dacs_txd;
logic berc_txd;
logic [7:0] num_uarts_here[4];
assign NUM_UARTS_HERE = num_uarts_here[0] + num_uarts_here[1] + num_uarts_here[2]  + num_uarts_here[3];
assign uart_pins.rx = uart_rx;
assign uart_tx = uart_pins.tx;

assign uart_pins.tx = parallelizer_txd & reframer_txd & dacs_txd & berc_txd;

logic [NUMBITS_DATAIN_FULL_WIDTH/2-1:0] half_frame_data_in_w_frame[NUM_DATA_CHANNELS+1];
logic [NUMBITS_DATAIN_FULL_WIDTH-1:0] outdata_from_2x_parallelizer[NUM_DATA_CHANNELS+1];
logic [NUMBITS_DATAIN_FULL_WIDTH-1:0] data_only_from_2x_parallelizer[NUM_DATA_CHANNELS];
logic [NUMBITS_DATAIN_FULL_WIDTH-1:0] frame_only_from_2x_parallelizer;
logic [NUMBITS_DATAIN_FULL_WIDTH-1:0] frame_sampled_clock_out;

genvar i;
generate
         for (i = 0; i < NUM_DATA_CHANNELS; i++)
		 begin : assign_data_part
		       assign half_frame_data_in_w_frame[i] = half_frame_data_in[i];
			   assign data_only_from_2x_parallelizer[i] = outdata_from_2x_parallelizer[i];
		 end
endgenerate

assign half_frame_data_in_w_frame[NUM_DATA_CHANNELS] =  half_frame_frame_in;
assign frame_only_from_2x_parallelizer = outdata_from_2x_parallelizer[NUM_DATA_CHANNELS];
/////////////////////////////////////////////////
//
// BERC
//
/////////////////////////////////////////////////

wire [Parallel_BERC_input_width-1:0] pattern_to_output_for_atrophied_generation;
assign pattern_to_output_for_atrophied_generation = {NUM_OF_LVDS_ADC_FRAMES_IN_ONE_BERC_FRAME{base_pattern_to_output_for_atrophied_generation}};
		 


multi_channel_2x_generic_parallelizer_w_uart_support
#(
.OMIT_CONTROL_REG_DESCRIPTIONS(OMIT_CONTROL_REG_DESCRIPTIONS),
.OMIT_STATUS_REG_DESCRIPTIONS (OMIT_STATUS_REG_DESCRIPTIONS ),
.UART_CLOCK_SPEED_IN_HZ       (UART_CLOCK_SPEED_IN_HZ       ),
.REGFILE_BAUD_RATE            (REGFILE_DEFAULT_BAUD_RATE            ),
.prefix_uart_name(uart_parellelizer_2x_prefix),
.NUMBITS_DATAIN_FULL_WIDTH (NUMBITS_DATAIN_FULL_WIDTH),
.NUM_DATA_CHANNELS(NUM_DATA_CHANNELS + 1),
.GENERATE_FRAME_CLOCK_ON_NEGEDGE(GENERATE_FRAME_CLOCK_ON_NEGEDGE),
.CHANNEL_TO_LOOK_AT_FOR_DEBUGGING(CHANNEL_TO_LOOK_AT_FOR_DEBUGGING),
.DEFAULT_TRANSPOSE_CTRL(DEFAULT_PARALLELIZER_TRANSPOSE_CTRL),
.DEFAULT_SIMULATED_FULL_FRAME_DATA(DEFAULT_SIMULATED_FULL_FRAME_DATA),
.DEFAULT_SIMULATED_HALF_FRAME_DATA(DEFAULT_SIMULATED_HALF_FRAME_DATA),
.GENERATE_DDS_TEST_SIGNALS(GENERATE_DDS_TEST_SIGNALS),
.ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION(ALLOW_2X_REPARELLELIZER_SINE_COSINE_TEST_SIGNAL_GENERATION),
.USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS(USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS),
.ACTIVITY_MONITOR_NUMBITS(ACTIVITY_MONITOR_NUMBITS),
.ALLOW_LOOK_AT_ALL_CHANNELS(ALLOW_2X_TO_LOOK_AT_ALL_CHANNELS)
)
multi_channel_2x_generic_parallelizer_w_uart_support_inst
(
	.UART_REGFILE_CLK,
	.RESET_FOR_UART_REGFILE_CLK,
	
  .half_frame_data_in(half_frame_data_in_w_frame),
  .outdata(outdata_from_2x_parallelizer),
  .half_frame_clk,
   .frame_clk,
	.half_frame_clk_valid,
	.uart_tx(parallelizer_txd),
	.uart_rx(uart_pins.rx),
	
    .UART_IS_SECONDARY_UART(TOP_UART_IS_SECONDARY_UART),
    .UART_NUM_SECONDARY_UARTS(TOP_UART_NUM_SECONDARY_UARTS),
    .UART_ADDRESS_OF_THIS_UART(TOP_UART_ADDRESS_OF_THIS_UART),
	.NUM_UARTS_HERE(num_uarts_here[0])
	
);

multi_channel_generic_reframer_w_uart_support
#(
.OMIT_CONTROL_REG_DESCRIPTIONS   (OMIT_CONTROL_REG_DESCRIPTIONS   ),
.OMIT_STATUS_REG_DESCRIPTIONS    (OMIT_STATUS_REG_DESCRIPTIONS    ),
.UART_CLOCK_SPEED_IN_HZ          (UART_CLOCK_SPEED_IN_HZ          ),
.REGFILE_BAUD_RATE               (REGFILE_DEFAULT_BAUD_RATE               ),
.prefix_uart_name                (uart_reframer_prefix            ),
.lock_wait_counter_bits          (LOCK_WAIT_COUNTER_BITS          ),
.numbits_datain                  (NUMBITS_DATAIN_FULL_WIDTH       ),
.num_data_channels               (NUM_DATA_CHANNELS               ),
.DEFAULT_FRAME_LOCK_MASK         (DEFAULT_FRAME_LOCK_MASK         ),
.DEFAULT_TRANSPOSE_CTRL          (DEFAULT_REFRAMER_TRANSPOSE_CTRL          ),
.DEFAULT_LOCK_WAIT               (DEFAULT_LOCK_WAIT               ),
.DEFAULT_ENABLE_LOCK_SCAN        (DEFAULT_ENABLE_LOCK_SCAN        ),
.DEFAULT_FRAME_TO_DATA_OFFSET    (DEFAULT_FRAME_TO_DATA_OFFSET    ),
.CHANNEL_TO_LOOK_AT_FOR_DEBUGGING(CHANNEL_TO_LOOK_AT_FOR_DEBUGGING),
.ACTIVITY_MONITOR_NUMBITS(ACTIVITY_MONITOR_NUMBITS),
.ALLOW_LOOK_AT_ALL_CHANNELS(ALLOW_REFRAMER_TO_LOOK_AT_ALL_CHANNELS)
)
multi_channel_generic_reframer_w_uart_support_inst
(
	.UART_REGFILE_CLK,
	.RESET_FOR_UART_REGFILE_CLK,
	
   .frame_clk,
   .data_in(data_only_from_2x_parallelizer),
   .frame_sampled_clock_in(frame_only_from_2x_parallelizer),
   .frame_sampled_clock_out(frame_sampled_clock_out),
   .data_out,
   .reframer_is_locked,
	.frame_clk_valid,
	.uart_tx(reframer_txd),
	.uart_rx(uart_pins.rx),
	
    .UART_IS_SECONDARY_UART   (1),
    .UART_NUM_SECONDARY_UARTS (0),
    .UART_ADDRESS_OF_THIS_UART(TOP_UART_ADDRESS_OF_THIS_UART+num_uarts_here[0]),
	.NUM_UARTS_HERE(num_uarts_here[1])
	
);
	
genvar current_chan;
genvar current_dac;
generate
		if (COMPILE_DACS)
		begin		
		        multi_dac_interface  
				#(
				.num_dacs(2),
				.data_width(NUMBITS_DATAIN_FULL_WIDTH),
				.num_selection_bits($clog2(2*NUM_DATA_CHANNELS+2)),
				.actual_num_selections(2*NUM_DATA_CHANNELS+2)
				) 
				nios_dac_pins_of_composite_signal();
				
                for (current_dac = 0; current_dac < 2; current_dac++)
				begin : go_over_dacs
						 for (current_chan = 0; current_chan < NUM_DATA_CHANNELS; current_chan++)
						 begin : assign_data_part
							   wire [7:0] char1 = ((current_chan/10)+ZERO_IN_ASCII);
							   wire [7:0] char2 = ((current_chan % 10)+ZERO_IN_ASCII);
 	   						   assign nios_dac_pins_of_composite_signal.dac_descriptions[current_dac][current_chan] = {"adc",char1,char2};
  	   						   assign nios_dac_pins_of_composite_signal.dac_descriptions[current_dac][current_chan+2+NUM_DATA_CHANNELS] = {"pre_adc",char1,char2};
						 end	   
															        
                        always @(posedge frame_clk)
						begin
								case (nios_dac_pins_of_composite_signal.select_channel_to_dac[current_dac])								
								NUM_DATA_CHANNELS   : begin nios_dac_pins_of_composite_signal.selected_channel_to_dac[current_dac] <= frame_only_from_2x_parallelizer; end
								NUM_DATA_CHANNELS+1 : begin nios_dac_pins_of_composite_signal.selected_channel_to_dac[current_dac]<= frame_sampled_clock_out; end
								default: begin 
											  nios_dac_pins_of_composite_signal.selected_channel_to_dac[current_dac] <= (nios_dac_pins_of_composite_signal.select_channel_to_dac[current_dac] < NUM_DATA_CHANNELS) ?
											     data_out[nios_dac_pins_of_composite_signal.select_channel_to_dac[current_dac]] 
											     : data_only_from_2x_parallelizer[nios_dac_pins_of_composite_signal.select_channel_to_dac[current_dac]]; 
											  
										  end
								endcase		
						end
						
						assign nios_dac_pins_of_composite_signal.valid_to_dac[current_dac] = 1;
						assign nios_dac_pins_of_composite_signal.selected_clk_to_dac[current_dac] = frame_clk;
						assign nios_dac_pins_of_composite_signal.dac_descriptions[current_dac][NUM_DATA_CHANNELS] = "frameIn";
						assign nios_dac_pins_of_composite_signal.dac_descriptions[current_dac][NUM_DATA_CHANNELS+1] = "frameOUT";
				end
				
				reformat_and_connect_parallel_bus_to_nios_dacs
				#(
				.ENABLE_CONTROL_WISHBONE_INTERFACE      (1'b1),
				.ENABLE_STATUS_WISHBONE_INTERFACE       (1'b1),
				.USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS(NIOS_DAC_USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS),
				.NUM_OUTPUT_SAMPLES_IN_FIFO               (NIOS_DAC_NUM_OUTPUT_SAMPLES_IN_FIFO),
				.in_data_bits                           (NUMBITS_DATAIN_FULL_WIDTH),
				.out_data_bits                          (NUMBITS_DATAIN_FULL_WIDTH),
				.ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS(NUMBITS_DATAIN_FULL_WIDTH),
				.ENABLE_KEEPS                           (ENABLE_KEEPS_ON_DACS),
				.OMIT_CONTROL_REG_DESCRIPTIONS          (OMIT_CONTROL_REG_DESCRIPTIONS),
				.OMIT_STATUS_REG_DESCRIPTIONS           (OMIT_STATUS_REG_DESCRIPTIONS),
				.UART_CLOCK_SPEED_IN_HZ                 (UART_CLOCK_SPEED_IN_HZ),
				.REGFILE_BAUD_RATE                      (REGFILE_DEFAULT_BAUD_RATE),
				.prefix_uart_name                       (uart_dac_prefix),
				.UART_REGFILE_TYPE                      (uart_regfile_types::JESD_NIOS_DACS_STANDALONE_REGFILE),
				.USE_GENERIC_ATTRIBUTE_FOR_READ_LD      (1'b0),
				.change_format_default                  (DACS_CHANGE_FORMAT_DEFAULT),
				.WISHBONE_INTERFACE_IS_PART_OF_BRIDGE   (NIOS_DACS_WISHBONE_INTERFACE_IS_PART_OF_BRIDGE ),
				.WISHBONE_CONTROL_BASE_ADDRESS        	(NIOS_DACS_WISHBONE_CONTROL_BASE_ADDRESS        ),	 
				.WISHBONE_STATUS_BASE_ADDRESS         	(NIOS_DACS_WISHBONE_STATUS_BASE_ADDRESS         ),
				.STATUS_WISHBONE_NUM_ADDRESS_BITS       (NIOS_DACS_STATUS_WISHBONE_NUM_ADDRESS_BITS     ),
				.CONTROL_WISHBONE_NUM_ADDRESS_BITS      (NIOS_DACS_CONTROL_WISHBONE_NUM_ADDRESS_BITS    ),
				.COMPILE_TEST_SIGNAL_DDS                 (COMPILE_TEST_SIGNAL_DDS                     ),
				.ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION(ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION),
				.NIOS_DAC_FIFO_IS_DUMMY                  (NIOS_DAC_FIFO_IS_DUMMY),
				.ENABLE_HW_TRIGGER_INTERFACE             (ENABLE_HW_TRIGGER_INTERFACE),
				.HW_TRIGGER_CTRL_DEFAULT                 (HW_TRIGGER_CTRL_DEFAULT),

				.SUPPORT_INPUT_DESCRIPTIONS              (SUPPORT_INPUT_DESCRIPTIONS)

				)
				reformat_and_connect_parallel_bus_to_nios_dacs_inst
				(
					.CLKIN(UART_REGFILE_CLK),
					.RESET_FOR_CLKIN(1'b0),
					
					.nios_dac_pins(nios_dac_pins_of_composite_signal),
					
					.uart_tx(dacs_txd),
					.uart_rx(uart_pins.rx),
					
				   .UART_IS_SECONDARY_UART(1),
				   .UART_NUM_SECONDARY_UARTS(0),
				   .UART_ADDRESS_OF_THIS_UART(TOP_UART_ADDRESS_OF_THIS_UART+num_uarts_here[0]+num_uarts_here[1]),
				   .NUM_UARTS_HERE(num_uarts_here[2]),

					.status_wishbone_interface_pins(external_nios_dacs_status_wishbone_interface_pins),
					.control_wishbone_interface_pins(external_nios_dacs_control_wishbone_interface_pins),
					.async_hw_trigger, 
					.actual_hw_trigger
				);	
				end else
				begin
				      assign dacs_txd = 1;
					  assign num_uarts_here[2] = 0;
					  if (DEFINE_WISHBONE_INTERFACES_FOR_DACS_IF_DISABLED)
					  begin
							  wishbone_interface external_nios_dacs_status_wishbone_interface_pins();
							  wishbone_interface external_nios_dacs_control_wishbone_interface_pins();	
					  end
				end
endgenerate		


generate
         if (COMPILE_BER_METER)
		 begin
		        BERC_with_uart_regfile
				#(
				.BERC_bits_to_count_default                          (BERC_bits_to_count_default), 
				.frame_width                                         (NUMBITS_DATAIN_FULL_WIDTH),
				.Parallel_BERC_input_width                           (Parallel_BERC_input_width),
				.number_of_inwidths_in_corr_length                   (Parallel_BERC_number_of_inwidths_in_corr_length),
				.corr_count_bits                                     (BERC_corr_count_bits),
				.bit_count_reg_width                                 (BERC_bit_count_reg_width),
				.CLOCK_SPEED_IN_HZ                                   (BERC_SM_CLK_CLOCK_SPEED),
				.UART_BAUD_RATE_IN_HZ                                (REGFILE_DEFAULT_BAUD_RATE),
				.Output_DATA_CAPTURE_FIFO_WIDTH                      (16),
				.Num_of_input_channels                               (NUM_DATA_CHANNELS),
				.Default_Channel                                     (CHANNEL_TO_LOOK_AT_FOR_DEBUGGING),
				.transpose_refseq_default                            (BERC_TRANSPOSE_REFSEQ_DEFAULT ),
				.transpose_inseq_default                             (BERC_TRANSPOSE_INSEQ_DEFAULT  ),
				.try_align_default                                   (0),
				.ref_data_source_default                             (DEFAULT_BERC_DATA_SOURCE),
				.frame_wait_between_aligns_default                   (15),
				.USE_INCREASING_INDICES_INPUT_DATA_ARRAY             (1),
                .ENABLE_BERC_PN_SEQUENCE_FUNCTIONALITY(ENABLE_BERC_PN_SEQUENCE_FUNCTIONALITY)				
				)
				BERC_with_uart_regfile_inst
				( 
				 .DISPLAY_NAME                                                   ({uart_berc_prefix,"BERC"}),
				 .sm_clk                                                         (BERC_sm_clk),
				 .frame_in_clk                                                   (frame_clk),
				 .frame_in_data                                                  (data_out),
				 .frame_in_data_increasing_indices                               (data_out),
				 .request_adc_realign                                            (),
				 .data_to_the_Output_Signal_Capture_FIFO                         (),
				 .wrclk_to_the_Output_Signal_Capture_FIFO                        (),
				 .external_ref_sequence_from_pattern_RAM                         (),
				 .pattern_to_output_for_atrophied_generation                     (pattern_to_output_for_atrophied_generation),
				 .info_only_base_frame_pattern_to_output_for_atrophied_generation(base_pattern_to_output_for_atrophied_generation),
				 .IS_SECONDARY_UART(1),
				 .NUM_SECONDARY_UARTS(0),
				 .ADDRESS_OF_THIS_UART(TOP_UART_ADDRESS_OF_THIS_UART+num_uarts_here[0]+num_uarts_here[1]+num_uarts_here[2]),
				 .NUM_OF_UARTS_HERE(num_uarts_here[3]),
				 .rxd(uart_pins.rx),
				 .txd(berc_txd)
				);
		end else
		begin
		      assign num_uarts_here[3] = 0;
			  assign berc_txd = 1;
		
		end		
endgenerate				
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//  End GRIFFIN support
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
endmodule
`default_nettype wire