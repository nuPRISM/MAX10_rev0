`default_nettype none
module parallel_dds_test_signal_generation
#(
 parameter use_explicit_blockram = 1,
 parameter TEST_SIGNAL_DDS_NUM_PHASE_BITS = 16,
 parameter ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION = 1,
 parameter NUM_NET_OUTPUT_BITS_PER_CHANNEL = 14,
 parameter NUM_GROSS_OUTPUT_BITS_PER_CHANNEL = 16,
 parameter NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL = 8,
 parameter NUM_TEST_CHANNELS = 2,
 parameter TOTAL_OUTPUT_BITS = NUM_GROSS_OUTPUT_BITS_PER_CHANNEL*NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL,
 parameter add_extra_pipelining = 0
 
)
(
 input clk[NUM_TEST_CHANNELS],
 input reset,
 output logic [NUM_NET_OUTPUT_BITS_PER_CHANNEL-1:0] generated_net_test_signal[NUM_TEST_CHANNELS][NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL],
 output logic [NUM_GROSS_OUTPUT_BITS_PER_CHANNEL-1:0] generated_gross_test_signal[NUM_TEST_CHANNELS][NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL],
 output logic [NUM_GROSS_OUTPUT_BITS_PER_CHANNEL-1:0] generated_sign_extended_test_signal[NUM_TEST_CHANNELS][NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL],
 output logic [TOTAL_OUTPUT_BITS-1:0] generated_parallel_test_signal[NUM_TEST_CHANNELS],
 output logic [TOTAL_OUTPUT_BITS-1:0] ramp_plus1[NUM_TEST_CHANNELS],
 output logic [TOTAL_OUTPUT_BITS-1:0] channel_index[NUM_TEST_CHANNELS],
 output logic [NUM_NET_OUTPUT_BITS_PER_CHANNEL-1:0] ramp_plus1_accumulator[NUM_TEST_CHANNELS][NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL],
 input [TEST_SIGNAL_DDS_NUM_PHASE_BITS-1:0] dds_phase_word[NUM_TEST_CHANNELS],
 input [1:0] select_test_signal[NUM_TEST_CHANNELS],
 input output_unsigned_signal[NUM_TEST_CHANNELS]
);

`define current_subrange(chan) chan*NUM_GROSS_OUTPUT_BITS_PER_CHANNEL+NUM_NET_OUTPUT_BITS_PER_CHANNEL-1:chan*NUM_GROSS_OUTPUT_BITS_PER_CHANNEL
    logic [NUM_NET_OUTPUT_BITS_PER_CHANNEL-1:0] test_dds_triangular_waveform_out[NUM_TEST_CHANNELS][NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL];
    logic [NUM_NET_OUTPUT_BITS_PER_CHANNEL-1:0] sine_waveform_out[NUM_TEST_CHANNELS][NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL];
    logic [NUM_NET_OUTPUT_BITS_PER_CHANNEL-1:0] cosine_waveform_out[NUM_TEST_CHANNELS][NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL];
    logic [TEST_SIGNAL_DDS_NUM_PHASE_BITS-1:0]  test_dds_phase_accumulator[NUM_TEST_CHANNELS][NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL];
	logic [NUM_NET_OUTPUT_BITS_PER_CHANNEL-1:0] oscillator_id[NUM_TEST_CHANNELS][NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL];

	genvar current_dds_test_channel;
	genvar current_test_channel;
	generate
	 
			
		  for (current_test_channel = 0; current_test_channel < NUM_TEST_CHANNELS; current_test_channel++)
		  begin : per_test_channel		
		               logic [NUM_NET_OUTPUT_BITS_PER_CHANNEL-1:0] sign_inversion_mask;
                       assign sign_inversion_mask = {output_unsigned_signal[current_test_channel],{(NUM_NET_OUTPUT_BITS_PER_CHANNEL-1){1'b0}}};

						multiple_parallel_advanced_dds
						#(
						.use_explicit_blockram(use_explicit_blockram),
						.num_phase_bits (TEST_SIGNAL_DDS_NUM_PHASE_BITS), 
						.num_output_bits (NUM_NET_OUTPUT_BITS_PER_CHANNEL),
						.num_parallel_oscillators(NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL),
						.add_extra_pipelining(add_extra_pipelining)
						)
						multiple_parallel_advanced_dds_inst
						(
						.clk(clk[current_test_channel]),
						.reset_n(!reset),
						.clken(1'b1),
						.phi_inc_i(dds_phase_word[current_test_channel]),
						.triangular_waveform_out(test_dds_triangular_waveform_out[current_test_channel]),
						.cosine_waveform_out(cosine_waveform_out[current_test_channel]),
						.sine_waveform_out(sine_waveform_out[current_test_channel]),
						.phase_accumulator(test_dds_phase_accumulator[current_test_channel]),
						.ramp_plus1_accumulator(ramp_plus1_accumulator[current_test_channel]),
						.oscillator_id(oscillator_id[current_test_channel])
						);
						
												
						for (current_dds_test_channel = 0; current_dds_test_channel < NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL; current_dds_test_channel++)
						begin : make_dds_registered_signals
								always @(posedge clk[current_test_channel])
								begin																										 
								   case (select_test_signal[current_test_channel])
								   2'b00:  generated_parallel_test_signal[current_test_channel][`current_subrange(current_dds_test_channel)]    <=  sign_inversion_mask ^ (test_dds_triangular_waveform_out[current_test_channel][current_dds_test_channel]);
								   2'b01:  generated_parallel_test_signal[current_test_channel][`current_subrange(current_dds_test_channel)]    <=  sign_inversion_mask ^ (test_dds_phase_accumulator[current_test_channel][current_dds_test_channel][TEST_SIGNAL_DDS_NUM_PHASE_BITS-1 -:NUM_NET_OUTPUT_BITS_PER_CHANNEL]); 
								   2'b10:  generated_parallel_test_signal[current_test_channel][`current_subrange(current_dds_test_channel)]    <=  sign_inversion_mask ^ (ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION ? sine_waveform_out[current_test_channel][current_dds_test_channel] : 0);  
								   2'b11:  generated_parallel_test_signal[current_test_channel][`current_subrange(current_dds_test_channel)]    <=  sign_inversion_mask ^ (ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION ? cosine_waveform_out[current_test_channel][current_dds_test_channel] : 0);  
								   endcase																							
								end		

								if (add_extra_pipelining)
								begin
								      always @(posedge clk[current_test_channel])
									  begin
								            ramp_plus1[current_test_channel][`current_subrange(current_dds_test_channel)]  <= ramp_plus1_accumulator[current_test_channel][current_dds_test_channel];
									  end
								end else
								begin
                                        assign ramp_plus1[current_test_channel][`current_subrange(current_dds_test_channel)]  = ramp_plus1_accumulator[current_test_channel][current_dds_test_channel];
								end
								
								assign channel_index[current_test_channel][`current_subrange(current_dds_test_channel)]  = oscillator_id[current_test_channel][current_dds_test_channel];

																		
								assign generated_net_test_signal[current_test_channel][current_dds_test_channel] = generated_parallel_test_signal[current_test_channel][`current_subrange(current_dds_test_channel)];							  											  
								
								//note that upper bits of gross test signal are always 0. They are not a sign extension
								assign generated_gross_test_signal[current_test_channel][current_dds_test_channel] = generated_parallel_test_signal[current_test_channel][`current_subrange(current_dds_test_channel)];							  											  
								
								assign generated_sign_extended_test_signal[current_test_channel][current_dds_test_channel] 
						                   = {{(NUM_GROSS_OUTPUT_BITS_PER_CHANNEL-NUM_NET_OUTPUT_BITS_PER_CHANNEL){generated_net_test_signal[current_test_channel][current_dds_test_channel][NUM_NET_OUTPUT_BITS_PER_CHANNEL-1]}},
						                       generated_net_test_signal[current_test_channel][current_dds_test_channel]};	
						end																				
		end
			
	endgenerate
	
	`undef current_subrange
 endmodule
	
`default_nettype wire
	