`default_nettype none
`include "interface_defs.v"
`include "keep_defines.v"
import uart_regfile_types::*;

module reformat_and_connect_parallel_bus_to_multiple_nios_dacs
#(
parameter device_family = "Arria V",
parameter  [7:0] ENABLE_CONTROL_WISHBONE_INTERFACE = 1'b1,
parameter  [7:0] ENABLE_STATUS_WISHBONE_INTERFACE  = 1'b1,
parameter in_data_bits   = 16,
parameter out_data_bits  = 16,
parameter bitwidth_ratio = in_data_bits/out_data_bits;
parameter ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS = out_data_bits,
parameter NUM_OUTPUT_SAMPLES_IN_FIFO = 16384,
parameter num_locations_in_fifo = NUM_OUTPUT_SAMPLES_IN_FIFO/bitwidth_ratio,
parameter Synchronize_Capture_Both_GP_FIFOs_DEFAULT = 1,
parameter num_words_bits = $clog2(num_locations_in_fifo),
parameter DEFAULT_CHANNEL_TO_DAC0 = 0,
parameter DEFAULT_CHANNEL_TO_DAC1 = 0,
parameter ENABLE_KEEPS = 0,
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"_NiosDAC"},
parameter UART_REGFILE_TYPE = uart_regfile_types::NIOS_MULTI_DAC_STANDALONE_REGFILE,
parameter [0:0] IGNORE_TIMING_TO_READ_LD = 1'b0,
parameter [0:0] USE_GENERIC_ATTRIBUTE_FOR_READ_LD = 1'b0,
parameter GENERIC_ATTRIBUTE_FOR_READ_LD = "ERROR",
parameter change_format_default = 1'b0,
parameter [0:0]  WISHBONE_INTERFACE_IS_PART_OF_BRIDGE = 1'b0,
parameter [31:0] WISHBONE_CONTROL_BASE_ADDRESS        = 0,
parameter [31:0] WISHBONE_STATUS_BASE_ADDRESS         = 0,
parameter [7:0]  STATUS_WISHBONE_NUM_ADDRESS_BITS     = 8,
parameter [7:0]  CONTROL_WISHBONE_NUM_ADDRESS_BITS     = 8,
parameter [0:0] COMPILE_TEST_SIGNAL_DDS = 0,
parameter [0:0] ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION = 0,
parameter NUM_OF_NIOS_DACS = 2,
parameter [0:0] USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS = 1,
parameter [7:0] TEST_SIGNAL_DDS_NUM_PHASE_BITS     = 24,
parameter       TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD = {5'b0,1'b1,{(TEST_SIGNAL_DDS_NUM_PHASE_BITS-10){1'b0}},1'b1},
parameter [0:0] SUPPORT_INPUT_DESCRIPTIONS = 1
)
(
	input  CLKIN,
	input  RESET_FOR_CLKIN,
	
	multi_dac_interface nios_dac_pins,
	
	output uart_tx,
	input  uart_rx,
	
    input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,
	
    wishbone_interface status_wishbone_interface_pins,
    wishbone_interface control_wishbone_interface_pins,
	
	output logic [in_data_bits-1:0]  test_selected_data[NUM_OF_NIOS_DACS]
	
);
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  UART Controlled NIOS DACs
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			
multi_data_acq_fifo_interface #(
.num_fifos(NUM_OF_NIOS_DACS),
.in_data_bits(in_data_bits),	
.out_data_bits(out_data_bits),
.num_locations_in_fifo(num_locations_in_fifo)
)
interface_to_adc_fifo();

genvar current_fifo;
generate
			for (current_fifo = 0; current_fifo < NUM_OF_NIOS_DACS; current_fifo++)
			begin : generate_fifos 	
					parameterized_daq_fifo
					#(
					.device_family(device_family),
					.num_output_locations(NUM_OUTPUT_SAMPLES_IN_FIFO),
					.input_to_output_ratio(bitwidth_ratio),
					.num_output_bits(out_data_bits)
					)
					fifo
					 (
					.data       ( interface_to_adc_fifo.data   [current_fifo]),
					.rdclk      ( interface_to_adc_fifo.rdclk  [current_fifo]),
					.rdreq      ( interface_to_adc_fifo.rdreq  [current_fifo]),
					.wrclk      ( interface_to_adc_fifo.wrclk  [current_fifo]),
					.wrreq      ( interface_to_adc_fifo.wrreq  [current_fifo]),
					.q          ( interface_to_adc_fifo.q      [current_fifo]),
					.rdempty    ( interface_to_adc_fifo.rdempty[current_fifo]),
					.rdfull     ( interface_to_adc_fifo.rdfull [current_fifo]),
					.wrempty    ( interface_to_adc_fifo.wrempty[current_fifo]),
					.wrfull     ( interface_to_adc_fifo.wrfull [current_fifo]),
					.wrusedw    ( interface_to_adc_fifo.wrusedw[current_fifo])
					);			
			end			
endgenerate

uart_controlled_multi_nios_dacs
#(
.ENABLE_CONTROL_WISHBONE_INTERFACE         (ENABLE_CONTROL_WISHBONE_INTERFACE        ),
.ENABLE_STATUS_WISHBONE_INTERFACE          (ENABLE_STATUS_WISHBONE_INTERFACE         ),
.in_data_bits                              (in_data_bits                             ),
.out_data_bits                             (out_data_bits                            ),
.ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS   (ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS  ),
.Synchronize_Capture_Both_GP_FIFOs_DEFAULT (Synchronize_Capture_Both_GP_FIFOs_DEFAULT),
.num_locations_in_fifo                     (num_locations_in_fifo                    ),
.num_words_bits                            (num_words_bits                           ),
.DEFAULT_CHANNEL_TO_DAC0                   (DEFAULT_CHANNEL_TO_DAC0                  ),
.DEFAULT_CHANNEL_TO_DAC1                   (DEFAULT_CHANNEL_TO_DAC1                  ),
.ENABLE_KEEPS                              (ENABLE_KEEPS                             ),
.OMIT_CONTROL_REG_DESCRIPTIONS             (OMIT_CONTROL_REG_DESCRIPTIONS            ),
.OMIT_STATUS_REG_DESCRIPTIONS              (OMIT_STATUS_REG_DESCRIPTIONS             ),
.UART_CLOCK_SPEED_IN_HZ                    (UART_CLOCK_SPEED_IN_HZ                   ),
.REGFILE_BAUD_RATE                         (REGFILE_BAUD_RATE                        ),
.prefix_uart_name                          (prefix_uart_name                         ),
.uart_name                                 (uart_name                                ),
.UART_REGFILE_TYPE                         (UART_REGFILE_TYPE                        ),
.IGNORE_TIMING_TO_READ_LD                  (IGNORE_TIMING_TO_READ_LD                 ),
.USE_GENERIC_ATTRIBUTE_FOR_READ_LD         (USE_GENERIC_ATTRIBUTE_FOR_READ_LD        ),
.GENERIC_ATTRIBUTE_FOR_READ_LD             (GENERIC_ATTRIBUTE_FOR_READ_LD            ),
.change_format_default                     (change_format_default                    ),
.WISHBONE_INTERFACE_IS_PART_OF_BRIDGE      (WISHBONE_INTERFACE_IS_PART_OF_BRIDGE     ),
.WISHBONE_CONTROL_BASE_ADDRESS             (WISHBONE_CONTROL_BASE_ADDRESS            ),
.WISHBONE_STATUS_BASE_ADDRESS              (WISHBONE_STATUS_BASE_ADDRESS             ),
.STATUS_WISHBONE_NUM_ADDRESS_BITS          (STATUS_WISHBONE_NUM_ADDRESS_BITS         ),
.CONTROL_WISHBONE_NUM_ADDRESS_BITS         (CONTROL_WISHBONE_NUM_ADDRESS_BITS        ),
.COMPILE_TEST_SIGNAL_DDS                   (COMPILE_TEST_SIGNAL_DDS                  ),
.ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION  (ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION ),
.NUM_OF_NIOS_DACS                          (NUM_OF_NIOS_DACS                         ),
.USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS (USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS),
.TEST_SIGNAL_DDS_NUM_PHASE_BITS            (TEST_SIGNAL_DDS_NUM_PHASE_BITS           ),
.TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD        (TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD       ),
.SUPPORT_INPUT_DESCRIPTIONS                (SUPPORT_INPUT_DESCRIPTIONS               )
)
reformatter_nios_dacs_inst
(
 .*,
 .data_acq_fifo_interface(interface_to_adc_fifo)
 ); 
endmodule
