`default_nettype none
`include "interface_defs.v"
`include "keep_defines.v"
import uart_regfile_types::*;


module simple_reformat_and_connect_to_nios_dacs
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
parameter UART_REGFILE_TYPE = uart_regfile_types::NIOS_DACS_STANDALONE_REGFILE,
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
parameter [0:0] ENABLE_STREAMING_TO_EXTERNAL_MEMORY = 0,
parameter [NUM_OF_NIOS_DACS-1:0] NIOS_DAC_FIFO_IS_DUMMY = 0,
parameter [0:0] USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS = 1,
parameter [7:0] TEST_SIGNAL_DDS_NUM_PHASE_BITS     = 24,
parameter       TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD = {5'b0,1'b1,{(TEST_SIGNAL_DDS_NUM_PHASE_BITS-10){1'b0}},1'b1},
parameter [0:0] SUPPORT_INPUT_DESCRIPTIONS = 1,
parameter HW_TRIGGER_CTRL_DEFAULT = 32'h18,
parameter [0:0] ENABLE_HW_TRIGGER_INTERFACE = 1,
parameter DEFAULT_ACTUAL_NUM_OF_DATA_VALUES_TO_ACQUIRE = NUM_OUTPUT_SAMPLES_IN_FIFO,
parameter NUM_BITS_DECIMATION_COUNTER = 16,
parameter [7:0] PACKET_WORD_COUNTER_WIDTH = 32
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
	output [7:0] NUM_UARTS_HERE,
    wishbone_interface status_wishbone_interface_pins,
    wishbone_interface control_wishbone_interface_pins,
	input async_hw_trigger,
	output actual_hw_trigger,
	input external_hw_trigger_reset,

	output logic [in_data_bits-1:0]  test_selected_data[NUM_OF_NIOS_DACS],
    multiple_synced_st_streaming_interfaces avst_out,
	output logic hw_trigger_with_sop_interrupt,
	output logic hw_trigger_with_eop_interrupt,
	output logic eop_interrupt,
	output logic sop_interrupt,
	input logic  [NUM_BITS_DECIMATION_COUNTER-1:0] external_sample_acquisition_decimation,
    output logic [PACKET_WORD_COUNTER_WIDTH-1:0] measured_time_between_triggers,
	output logic synced_to_CLKIN_HW_Trigger_Has_Happened
);

simple_dual_external_nios_dacs
#(
.ENABLE_CONTROL_WISHBONE_INTERFACE            (ENABLE_CONTROL_WISHBONE_INTERFACE           ),
.ENABLE_STATUS_WISHBONE_INTERFACE             (ENABLE_STATUS_WISHBONE_INTERFACE            ),
.in_data_bits                                 (in_data_bits                                ),
.out_data_bits                                (out_data_bits                               ),
.ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS      (ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS     ),
.Synchronize_Capture_Both_GP_FIFOs_DEFAULT    (Synchronize_Capture_Both_GP_FIFOs_DEFAULT   ),
.num_locations_in_fifo                        (num_locations_in_fifo                       ),
.num_words_bits                               (num_words_bits                              ),
.DEFAULT_CHANNEL_TO_DAC0                      (DEFAULT_CHANNEL_TO_DAC0                     ),
.DEFAULT_CHANNEL_TO_DAC1                      (DEFAULT_CHANNEL_TO_DAC1                     ),
.ENABLE_KEEPS                                 (ENABLE_KEEPS                                ),
.OMIT_CONTROL_REG_DESCRIPTIONS                (OMIT_CONTROL_REG_DESCRIPTIONS               ),
.OMIT_STATUS_REG_DESCRIPTIONS                 (OMIT_STATUS_REG_DESCRIPTIONS                ),
.UART_CLOCK_SPEED_IN_HZ                       (UART_CLOCK_SPEED_IN_HZ                      ),
.REGFILE_BAUD_RATE                            (REGFILE_BAUD_RATE                           ),
.prefix_uart_name                             (prefix_uart_name                            ),
.uart_name                                    (uart_name                                   ),
.UART_REGFILE_TYPE                            (UART_REGFILE_TYPE                           ),
.IGNORE_TIMING_TO_READ_LD                     (IGNORE_TIMING_TO_READ_LD                    ),
.USE_GENERIC_ATTRIBUTE_FOR_READ_LD            (USE_GENERIC_ATTRIBUTE_FOR_READ_LD           ),
.GENERIC_ATTRIBUTE_FOR_READ_LD                (GENERIC_ATTRIBUTE_FOR_READ_LD               ),
.change_format_default                        (change_format_default                       ),
.WISHBONE_INTERFACE_IS_PART_OF_BRIDGE         (WISHBONE_INTERFACE_IS_PART_OF_BRIDGE        ),
.WISHBONE_CONTROL_BASE_ADDRESS                (WISHBONE_CONTROL_BASE_ADDRESS               ),
.WISHBONE_STATUS_BASE_ADDRESS                 (WISHBONE_STATUS_BASE_ADDRESS                ),
.STATUS_WISHBONE_NUM_ADDRESS_BITS             (STATUS_WISHBONE_NUM_ADDRESS_BITS            ),
.CONTROL_WISHBONE_NUM_ADDRESS_BITS            (CONTROL_WISHBONE_NUM_ADDRESS_BITS           ),
.COMPILE_TEST_SIGNAL_DDS                      (COMPILE_TEST_SIGNAL_DDS                     ),
.ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION     (ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION    ),
.NUM_OF_NIOS_DACS                             (NUM_OF_NIOS_DACS                            ),
.USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS    (USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS   ),
.TEST_SIGNAL_DDS_NUM_PHASE_BITS               (TEST_SIGNAL_DDS_NUM_PHASE_BITS              ),
.TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD           (TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD          ),
.SUPPORT_INPUT_DESCRIPTIONS                   (SUPPORT_INPUT_DESCRIPTIONS                  ),
.HW_TRIGGER_CTRL_DEFAULT                      (HW_TRIGGER_CTRL_DEFAULT                     ),
.ENABLE_HW_TRIGGER_INTERFACE                  (ENABLE_HW_TRIGGER_INTERFACE                 ),
.NIOS_DAC_FIFO_IS_DUMMY                       (NIOS_DAC_FIFO_IS_DUMMY                      ),
.ENABLE_STREAMING_TO_EXTERNAL_MEMORY          (ENABLE_STREAMING_TO_EXTERNAL_MEMORY         ),
.DEFAULT_ACTUAL_NUM_OF_DATA_VALUES_TO_ACQUIRE (DEFAULT_ACTUAL_NUM_OF_DATA_VALUES_TO_ACQUIRE),
.PACKET_WORD_COUNTER_WIDTH                    (PACKET_WORD_COUNTER_WIDTH                   ),
.NUM_BITS_DECIMATION_COUNTER                  (NUM_BITS_DECIMATION_COUNTER                 )
)
reformatter_nios_dacs_inst
(
 .*,
 .HW_Trigger_Has_Happened(),
 .NUM_UARTS_HERE(NUM_UARTS_HERE)
 ); 
endmodule
