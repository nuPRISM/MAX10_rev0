`default_nettype none
`include "interface_defs.v"
`include "uart_regfile_interface_defs.v"
module generic_jesd_adc_support
#(
parameter current_FMC = 1,
parameter REGFILE_DEFAULT_BAUD_RATE = 2000000,
parameter ENABLE_KEEPS = 0,
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS  = 1'b0,
parameter GENERATE_SPI_TEST_CLOCK_SIGNALS=1'b1,
parameter UART_CLOCK_SPEED_IN_HZ  = 50000000,
parameter UDP_CLOCK_SPEED_IN_HZ  = 100000000,
parameter ONE_CONVERTER_IN_PARALLEL_PADDED_BIT_WIDTH           = 16,
parameter ONE_CONVERTER_SINGLE_DATA_VALUE_PADDED_BIT_WIDTH     = 16,
parameter ONE_CONVERTER_SINGLE_DATA_VALUE_ACTUAL_BIT_WIDTH    = 16,
parameter FFT_ONE_CONVERTER_IN_PARALLEL_PADDED_BIT_WIDTH           = 16,
parameter FFT_ONE_CONVERTER_SINGLE_DATA_VALUE_PADDED_BIT_WIDTH     = 16,
parameter FFT_ONE_CONVERTER_SINGLE_DATA_VALUE_ACTUAL_BIT_WIDTH    = 16,
parameter NIOS_DACS_WISHBONE_INTERFACE_IS_PART_OF_BRIDGE  = 1'b0,
parameter NIOS_DACS_WISHBONE_CONTROL_BASE_ADDRESS = 32'hEAAEAA, 
parameter NIOS_DACS_WISHBONE_STATUS_BASE_ADDRESS  = 32'hEAAEAA,
parameter NIOS_DACS_EXT_MEMORY_WISHBONE_CONTROL_BASE_ADDRESS = 32'hEAAEAA, 
parameter NIOS_DACS_EXT_MEMORY_WISHBONE_STATUS_BASE_ADDRESS  = 32'hEAAEAA,
parameter NIOS_DACS_STATUS_WISHBONE_NUM_ADDRESS_BITS = 8,
parameter NIOS_DACS_CONTROL_WISHBONE_NUM_ADDRESS_BITS= 8,
parameter DACS_CHANGE_FORMAT_DEFAULT = 1,
parameter COMPILE_TEST_SIGNAL_DDS  = 1,                 
parameter ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION = 1,
parameter [0:0] USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS = 1,
parameter [0:0] SUPPORT_INPUT_DESCRIPTIONS = 1,
parameter HW_TRIGGER_CTRL_DEFAULT = 32'h0,
parameter [0:0] ENABLE_HW_TRIGGER_INTERFACE = 1,
parameter [0:0] NIOS_DAC_USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS = 1,
parameter [63:0]  adc_name_prefix = "xxxx",
parameter [63:0]  multi_stream_packetizer_uart_prefix = {adc_name_prefix,"dac"},
parameter [63:0]  test_signal_generator_uart_prefix = {adc_name_prefix,"tst"},
parameter [63:0]  spi_support_uart_prefix = {adc_name_prefix,"spi"},
parameter [63:0]  fft_uart_prefix = {adc_name_prefix,"fft"},
parameter DEFAULT_ACTUAL_NUM_OF_DATA_VALUES_TO_ACQUIRE = 16384,
parameter NUM_BITS_DECIMATION_COUNTER = 16,
parameter [7:0] PACKET_WORD_COUNTER_WIDTH = 32,
parameter [7:0] NUM_OF_DATA_STREAMS = 2,
parameter [15:0] POST_PROCESSED_ACTUAL_BITWIDTH_OF_STREAMS = ONE_CONVERTER_SINGLE_DATA_VALUE_ACTUAL_BIT_WIDTH;
parameter [15:0] POST_PROCESSED_NUM_OF_STREAMS             = NUM_OF_DATA_STREAMS;
parameter [0:0] ENABLE_MULTI_STREAM_TEST_GENERATOR_FOR_ADC_EMULATION = 0,
parameter math_format_type MATH_FORMAT_DEFAULT = TWOS_COMPLEMENT_FORMAT_ENUM_VAL,
parameter COMPILE_FFT_X4_W_UART = 1,
parameter SUPPORT_SPI_FOR_JESDADC = 0,
parameter POST_PROCESSED_BITWIDTH_RATIO = ONE_CONVERTER_IN_PARALLEL_PADDED_BIT_WIDTH/ONE_CONVERTER_SINGLE_DATA_VALUE_PADDED_BIT_WIDTH
)
(
wishbone_interface                      nios_dacs_external_nios_status_wishbone_interface_pins ,
wishbone_interface                      nios_dacs_external_nios_control_wishbone_interface_pins,
generic_spi_interface                   jesd_adc_generic_spi_pins,

multi_data_stream_interface                jesd_adc_input_streams_interface_pins,
multiple_2d_synced_st_streaming_interfaces jesd_adc_2d_avst_stream_to_external_memory,
 multiple_synced_st_streaming_interfaces                jesd_adc_avst_stream_to_external_memory,


input                                   async_hw_trigger ,
output                                  actual_hw_trigger,
  
input                                   uart_rx,
output                                  uart_tx,
input                                   CLK_50MHZ,
input                                   TOP_UART_IS_SECONDARY_UART     ,
input [7:0]                             TOP_ADDRESS_OF_THIS_UART       ,   
input [7:0]                             TOP_UART_NUM_OF_SECONDARY_UARTS,
output logic [7:0]                      NUM_OF_UARTS_HERE
); 
 
import uart_regfile_types::*;
import utilities::*;
logic [7:0] local_num_uarts_here[256];


 wire  external_hw_trigger_reset = 0;
 wire [NUM_BITS_DECIMATION_COUNTER-1:0] external_sample_acquisition_decimation = 0;
 wire [PACKET_WORD_COUNTER_WIDTH-1:0] measured_time_between_triggers;
 
uart_struct uart_pins; 
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic     jesd_adc_txd;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic     dacs_txd;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic     fft_txd;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic     dacs_to_external_memory_txd;
 
assign uart_pins.rx = uart_rx;
assign uart_tx = uart_pins.tx;
assign uart_pins.tx = jesd_adc_txd & dacs_txd & dacs_to_external_memory_txd & fft_txd;

assign NUM_OF_UARTS_HERE = sum_num_uarts_here(local_num_uarts_here);
	
multi_data_stream_interface
#(
.num_data_streams    (jesd_adc_input_streams_interface_pins.get_num_data_streams()    ),
.data_width          (jesd_adc_input_streams_interface_pins.get_data_width()          ),
.num_description_bits(jesd_adc_input_streams_interface_pins.get_num_description_bits())
) 
processed_input_streams_interface_pins();
	
	
	
multiple_synced_st_streaming_interfaces 
#(
.num_channels        (jesd_adc_input_streams_interface_pins.get_num_data_streams()       ),
.num_data_bits       (jesd_adc_input_streams_interface_pins.get_data_width()             )
)
avst_out_raw();



multi_stream_packetizer
#(
.NUM_OF_DATA_STREAMS                       (NUM_OF_DATA_STREAMS),
.ENABLE_CONTROL_WISHBONE_INTERFACE         (1'b1),
.ENABLE_STATUS_WISHBONE_INTERFACE          (1'b1),
.USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS (NIOS_DAC_USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS),
.in_data_bits                              (ONE_CONVERTER_IN_PARALLEL_PADDED_BIT_WIDTH),
.out_data_bits                             (ONE_CONVERTER_SINGLE_DATA_VALUE_PADDED_BIT_WIDTH),
.ACTUAL_BITWIDTH_OF_STREAMS                (ONE_CONVERTER_SINGLE_DATA_VALUE_ACTUAL_BIT_WIDTH),
.ENABLE_KEEPS                              (ENABLE_KEEPS),
.OMIT_CONTROL_REG_DESCRIPTIONS             (OMIT_CONTROL_REG_DESCRIPTIONS),
.OMIT_STATUS_REG_DESCRIPTIONS              (OMIT_STATUS_REG_DESCRIPTIONS),
.UART_CLOCK_SPEED_IN_HZ                    (UART_CLOCK_SPEED_IN_HZ),
.REGFILE_BAUD_RATE                         (REGFILE_DEFAULT_BAUD_RATE),
.prefix_uart_name                          (multi_stream_packetizer_uart_prefix),
.UART_REGFILE_TYPE                         (uart_regfile_types::MULTI_STREAM_PACKETIZER_UART_REGFILE),
.USE_GENERIC_ATTRIBUTE_FOR_READ_LD         (1'b0),
.change_format_default                     (DACS_CHANGE_FORMAT_DEFAULT),
.WISHBONE_INTERFACE_IS_PART_OF_BRIDGE      (NIOS_DACS_WISHBONE_INTERFACE_IS_PART_OF_BRIDGE ),
.WISHBONE_CONTROL_BASE_ADDRESS        	   (NIOS_DACS_EXT_MEMORY_WISHBONE_CONTROL_BASE_ADDRESS        ),	 
.WISHBONE_STATUS_BASE_ADDRESS         	   (NIOS_DACS_EXT_MEMORY_WISHBONE_STATUS_BASE_ADDRESS         ),
.STATUS_WISHBONE_NUM_ADDRESS_BITS          (NIOS_DACS_STATUS_WISHBONE_NUM_ADDRESS_BITS     ),
.CONTROL_WISHBONE_NUM_ADDRESS_BITS         (NIOS_DACS_CONTROL_WISHBONE_NUM_ADDRESS_BITS    ),
.COMPILE_TEST_SIGNALS                      (COMPILE_TEST_SIGNAL_DDS                     ),
.ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION  (ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION),
.HW_TRIGGER_CTRL_DEFAULT                   (HW_TRIGGER_CTRL_DEFAULT),
.SUPPORT_INPUT_DESCRIPTIONS                (SUPPORT_INPUT_DESCRIPTIONS),
.DEFAULT_ACTUAL_NUM_OF_DATA_VALUES_TO_ACQUIRE (DEFAULT_ACTUAL_NUM_OF_DATA_VALUES_TO_ACQUIRE),
.NUM_BITS_DECIMATION_COUNTER               (NUM_BITS_DECIMATION_COUNTER),
.PACKET_WORD_COUNTER_WIDTH                 (PACKET_WORD_COUNTER_WIDTH),
.POST_PROCESSED_ACTUAL_BITWIDTH_OF_STREAMS (POST_PROCESSED_ACTUAL_BITWIDTH_OF_STREAMS),
.POST_PROCESSED_NUM_OF_STREAMS             (POST_PROCESSED_NUM_OF_STREAMS            ),
.MATH_FORMAT_DEFAULT                       (MATH_FORMAT_DEFAULT)

)
nios_dacs_to_external_memory_inst
(
	.CLKIN          (CLK_50MHZ),
	.RESET_FOR_CLKIN(1'b0),
	
	.input_streams_interface_pins(processed_input_streams_interface_pins),
	
	.uart_tx(dacs_to_external_memory_txd),
	.uart_rx(uart_pins.rx),
	
   .UART_IS_SECONDARY_UART(TOP_UART_IS_SECONDARY_UART),
   .UART_NUM_SECONDARY_UARTS(TOP_UART_NUM_OF_SECONDARY_UARTS),
   .UART_ADDRESS_OF_THIS_UART(TOP_ADDRESS_OF_THIS_UART),
   .NUM_UARTS_HERE(local_num_uarts_here[0]),
   .avst_out(avst_out_raw),
   
	.status_wishbone_interface_pins (nios_dacs_external_nios_status_wishbone_interface_pins),
	.control_wishbone_interface_pins(nios_dacs_external_nios_control_wishbone_interface_pins),
	.async_hw_trigger, 
	.actual_hw_trigger,
	.external_hw_trigger_reset,
	.external_sample_acquisition_decimation
);	

generate  
		if (ENABLE_MULTI_STREAM_TEST_GENERATOR_FOR_ADC_EMULATION)
		begin	
				multi_stream_test_signal_gen_w_uart
				#(
				.NUM_OF_DATA_STREAMS                       (NUM_OF_DATA_STREAMS),
				.ENABLE_CONTROL_WISHBONE_INTERFACE         (1'b0),
				.ENABLE_STATUS_WISHBONE_INTERFACE          (1'b0),
				.USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS (NIOS_DAC_USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS),
				.in_data_bits                              (ONE_CONVERTER_IN_PARALLEL_PADDED_BIT_WIDTH),
				.out_data_bits                             (ONE_CONVERTER_SINGLE_DATA_VALUE_PADDED_BIT_WIDTH),
				.ACTUAL_BITWIDTH_OF_STREAMS                (ONE_CONVERTER_SINGLE_DATA_VALUE_ACTUAL_BIT_WIDTH),
				.ENABLE_KEEPS                              (ENABLE_KEEPS),
				.OMIT_CONTROL_REG_DESCRIPTIONS             (OMIT_CONTROL_REG_DESCRIPTIONS),
				.OMIT_STATUS_REG_DESCRIPTIONS              (OMIT_STATUS_REG_DESCRIPTIONS),
				.UART_CLOCK_SPEED_IN_HZ                    (UART_CLOCK_SPEED_IN_HZ),
				.REGFILE_BAUD_RATE                         (REGFILE_DEFAULT_BAUD_RATE),
				.prefix_uart_name                          (test_signal_generator_uart_prefix),
				.UART_REGFILE_TYPE                         (uart_regfile_types::MULTI_TEST_SIGNAL_GENERATOR_UART_REGFILE),
				.USE_GENERIC_ATTRIBUTE_FOR_READ_LD         (1'b0),
				.COMPILE_TEST_SIGNALS                      (COMPILE_TEST_SIGNAL_DDS                    ),
				.ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION  (ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION),
				.USER_INPUT_INTERFACE_FOR_CLOCK_SOURCE     (1'b1),
				.DEFINE_WISHBONE_INTERFACES_IF_NOT_ENABLED (1'b1),
				.POST_PROCESSED_BITWIDTH_RATIO(POST_PROCESSED_BITWIDTH_RATIO)
				)
				inject_test_signal_to_simulate_adc_inst
				(
					.CLKIN(CLK_50MHZ),
					.RESET_FOR_CLKIN(1'b0),
					
					.input_streams_interface_pins(jesd_adc_input_streams_interface_pins),
					.output_streams_interface_pins(processed_input_streams_interface_pins),
					
					.uart_tx(dacs_txd),
					.uart_rx(uart_pins.rx),
					
				   .UART_IS_SECONDARY_UART(1),
				   .UART_NUM_SECONDARY_UARTS(0),
				   .UART_ADDRESS_OF_THIS_UART(TOP_ADDRESS_OF_THIS_UART  + sum_num_uarts_here(local_num_uarts_here,0,0)),
				   .NUM_UARTS_HERE(local_num_uarts_here[1])
					
				);				
			end else
			begin
						assign dacs_txd = 1;
						assign local_num_uarts_here[1] = 0;
						assign processed_input_streams_interface_pins.clk = jesd_adc_input_streams_interface_pins.clk;
						assign processed_input_streams_interface_pins.data = jesd_adc_input_streams_interface_pins.data;
						assign processed_input_streams_interface_pins.valid = jesd_adc_input_streams_interface_pins.valid;
						assign processed_input_streams_interface_pins.desc  = jesd_adc_input_streams_interface_pins.desc;
			end
endgenerate			
	
generate
		if (SUPPORT_SPI_FOR_JESDADC)
		begin	
					generic_spi_support_encapsulator
					#(
					.REGFILE_DEFAULT_BAUD_RATE               (REGFILE_DEFAULT_BAUD_RATE               ),
					.UART_CLOCK_SPEED_IN_HZ                  (UART_CLOCK_SPEED_IN_HZ                  ),
					.ENABLE_KEEPS                            (ENABLE_KEEPS                            ),
					.prefix_uart_name                        (spi_support_uart_prefix                        ),
					.OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS(1'b1),
					.OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS (1'b1 ),
					.GENERATE_SPI_TEST_CLOCK_SIGNALS         (GENERATE_SPI_TEST_CLOCK_SIGNALS)
					)
					jesd_adc_standalone_opencores_spi_w_uart_control
					(
					 .generic_spi_pins(jesd_adc_generic_spi_pins),
					 .uart_clk_50_MHz(CLK_50MHZ),
					 .RESET_FOR_CLKIN_50MHz(1'b0),
					 .uart_rx(uart_pins.rx),
					 .uart_tx(jesd_adc_txd),
					 
					 .TOP_UART_IS_SECONDARY_UART     (1), 
					 .TOP_UART_NUM_OF_SECONDARY_UARTS(0),
					 .TOP_ADDRESS_OF_THIS_UART       (TOP_ADDRESS_OF_THIS_UART + sum_num_uarts_here(local_num_uarts_here,0,1)),   
					 .NUM_OF_UARTS_HERE              (local_num_uarts_here[2])
					); 
		end else
		begin
		            assign local_num_uarts_here[2] = 0;
					assign jesd_adc_txd = 1'b1;			
		end
endgenerate

genvar current_stream;
generate
		if (COMPILE_FFT_X4_W_UART)
		begin
				fft_x4_w_uart
				#(
				.COMPILE_TEST_SIGNALS                      (1),
				.COMPILE_STREAM_SPECIFIC_STATUS_REGS       (1),
				.OMIT_CONTROL_REG_DESCRIPTIONS             (OMIT_CONTROL_REG_DESCRIPTIONS),
				.OMIT_STATUS_REG_DESCRIPTIONS              (OMIT_STATUS_REG_DESCRIPTIONS),
				.UART_CLOCK_SPEED_IN_HZ                    (UART_CLOCK_SPEED_IN_HZ),
				.REGFILE_BAUD_RATE                         (REGFILE_DEFAULT_BAUD_RATE),
				.prefix_uart_name                          (fft_uart_prefix),
				.NUM_STREAMS                               (NUM_OF_DATA_STREAMS),
				.synchronizer_depth(3),
				.pipeline_match_delay_val   (30),
				.delay_val_for_sop_eop_valid(128),
				.DEFAULT_PIPELINE_MATCH_DELAY_VAL(8),
				.DEFAULT_DELAY_VAL_FOR_SOP_EOP_VALID(31),
				.dds_num_phase_bits                     (24), 
				.dds_num_output_bits                    (16),
				.fft_output_bits_per_component                       (16),
				.fft_input_bits_per_component                        (ONE_CONVERTER_SINGLE_DATA_VALUE_ACTUAL_BIT_WIDTH),
				.fft_input_bit_padded_length_per_component           (ONE_CONVERTER_SINGLE_DATA_VALUE_PADDED_BIT_WIDTH),
				.num_output_bits_per_fixed_point_output              (ONE_CONVERTER_SINGLE_DATA_VALUE_PADDED_BIT_WIDTH)
				)
				fft_x4_w_uart_inst
				(    
					.avst_indata(avst_out_raw),
					.jesd_adc_2d_avst_stream_to_external_memory(jesd_adc_2d_avst_stream_to_external_memory),
					.reset(1'b0),
					.clk(avst_out_raw.clk),
				 
					.UART_REGFILE_CLK          (CLK_50MHZ),
					.RESET_FOR_UART_REGFILE_CLK(1'b0),

					.uart_rx(uart_pins.rx),
					.uart_tx(fft_txd),
					
					.UART_IS_SECONDARY_UART   (1), 
					.UART_NUM_SECONDARY_UARTS (0),
					.UART_ADDRESS_OF_THIS_UART(TOP_ADDRESS_OF_THIS_UART + sum_num_uarts_here(local_num_uarts_here,0,2)), 
					.NUM_UARTS_HERE           (local_num_uarts_here[3]),
					.connected_uart_primary  (),
					.connected_uart_secondary()
					
				);
		end else
		begin
			   assign fft_txd = 1'b1;
			   assign local_num_uarts_here[3] = 0;
			   /*
			   for (current_stream = 0; current_stream < NUM_OF_DATA_STREAMS; current_stream++)
               begin : assign_data_0_to_jesd_adc_avst_stream_to_external_memory
			   		assign jesd_adc_2d_avst_stream_to_external_memory.data[0][current_stream] = avst_out_raw.data [current_stream];
               end
			   
			   assign jesd_adc_2d_avst_stream_to_external_memory.valid[0] = avst_out_raw.valid;			   
			   assign jesd_adc_2d_avst_stream_to_external_memory.clk  [0] = avst_out_raw.clk  ;
			   assign jesd_adc_2d_avst_stream_to_external_memory.eop  [0] = avst_out_raw.eop  ;
			   assign jesd_adc_2d_avst_stream_to_external_memory.sop  [0] = avst_out_raw.sop  ;
			   assign jesd_adc_2d_avst_stream_to_external_memory.error[0] = avst_out_raw.error;
			   assign avst_out_raw.ready = jesd_adc_2d_avst_stream_to_external_memory.ready[0];
			   */
			   
			   assign jesd_adc_avst_stream_to_external_memory.data = avst_out_raw.data;
               assign jesd_adc_avst_stream_to_external_memory.valid = avst_out_raw.valid;			   
			   assign jesd_adc_avst_stream_to_external_memory.clk   = avst_out_raw.clk  ;
			   assign jesd_adc_avst_stream_to_external_memory.eop   = avst_out_raw.eop  ;
			   assign jesd_adc_avst_stream_to_external_memory.sop   = avst_out_raw.sop  ;
			   assign jesd_adc_avst_stream_to_external_memory.error = avst_out_raw.error;
			   assign avst_out_raw.ready = jesd_adc_avst_stream_to_external_memory.ready;
			   
		end
endgenerate

endmodule
`default_nettype wire