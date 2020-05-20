`default_nettype none
module parallel_dds_test_signal_generation_one_channel_only
#(
 parameter use_explicit_blockram = 1,
 parameter TEST_SIGNAL_DDS_NUM_PHASE_BITS = 16,
 parameter ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION = 1,
 parameter NUM_NET_OUTPUT_BITS_PER_CHANNEL = 14,
 parameter NUM_GROSS_OUTPUT_BITS_PER_CHANNEL = 16,
 parameter NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL = 8,
 parameter TOTAL_OUTPUT_BITS = NUM_GROSS_OUTPUT_BITS_PER_CHANNEL*NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL
 
)
(
 input  clk,
 output logic [NUM_NET_OUTPUT_BITS_PER_CHANNEL-1:0] generated_net_test_signal[NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL],
 output logic [NUM_GROSS_OUTPUT_BITS_PER_CHANNEL-1:0] generated_gross_test_signal[NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL],
 output logic [NUM_GROSS_OUTPUT_BITS_PER_CHANNEL-1:0] generated_sign_extended_test_signal[NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL],
 output logic [TOTAL_OUTPUT_BITS-1:0] generated_parallel_test_signal,
 input [TEST_SIGNAL_DDS_NUM_PHASE_BITS-1:0] dds_phase_word,
 input [1:0] select_test_signal,
 input output_unsigned_signal
);
 logic  internal_clk[1];
 logic [NUM_NET_OUTPUT_BITS_PER_CHANNEL-1:0] internal_generated_net_test_signal[1][NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL];
 logic [NUM_GROSS_OUTPUT_BITS_PER_CHANNEL-1:0] internal_generated_gross_test_signal[1][NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL];
 logic [NUM_GROSS_OUTPUT_BITS_PER_CHANNEL-1:0] internal_generated_sign_extended_test_signal[1][NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL];
 logic [TOTAL_OUTPUT_BITS-1:0] internal_generated_parallel_test_signal[1];
 logic[TEST_SIGNAL_DDS_NUM_PHASE_BITS-1:0] internal_dds_phase_word[1];
 logic [1:0] internal_select_test_signal[1];
 logic internal_output_unsigned_signal[1];
 
 assign internal_clk[0] = clk;
 assign internal_dds_phase_word[0] = dds_phase_word;
 assign internal_select_test_signal[0] = select_test_signal;
 assign internal_output_unsigned_signal[0] = output_unsigned_signal;
 assign generated_net_test_signal = internal_generated_net_test_signal[0];
 assign generated_gross_test_signal = internal_generated_gross_test_signal[0];
 assign generated_sign_extended_test_signal = internal_generated_sign_extended_test_signal[0];
 assign generated_parallel_test_signal = internal_generated_parallel_test_signal[0];
 
		 parallel_dds_test_signal_generation
		 #(
		.use_explicit_blockram(use_explicit_blockram),
		.TEST_SIGNAL_DDS_NUM_PHASE_BITS(TEST_SIGNAL_DDS_NUM_PHASE_BITS),
		.ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION(ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION),
		.NUM_NET_OUTPUT_BITS_PER_CHANNEL(NUM_NET_OUTPUT_BITS_PER_CHANNEL),
		.NUM_GROSS_OUTPUT_BITS_PER_CHANNEL(NUM_GROSS_OUTPUT_BITS_PER_CHANNEL),
		.NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL(NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL),
		.TOTAL_OUTPUT_BITS(TOTAL_OUTPUT_BITS),
		.NUM_TEST_CHANNELS(1)
		 )
		 parallel_dds_test_signal_generation_inst 
		 (
	.clk(internal_clk),
	.generated_net_test_signal(internal_generated_net_test_signal),
	.generated_gross_test_signal(internal_generated_gross_test_signal),
	.generated_sign_extended_test_signal(internal_generated_sign_extended_test_signal),
	.generated_parallel_test_signal(internal_generated_parallel_test_signal),
	.dds_phase_word(internal_dds_phase_word),
	.select_test_signal(internal_select_test_signal),
	.output_unsigned_signal(internal_output_unsigned_signal)
		);
		
 endmodule
`default_nettype wire
