
`default_nettype none
`include "interface_defs.v"

module multi_stream_test_generator
#(
parameter [0:0] COMPILE_TEST_SIGNAL_DDS = 0,
parameter [7:0] TEST_SIGNAL_DDS_NUM_PHASE_BITS = 24,
parameter TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD = {5'b0,1'b1,{(TEST_SIGNAL_DDS_NUM_PHASE_BITS-10){1'b0}},1'b1},
parameter bitwidth_ratio = in_data_bits/out_data_bits,
parameter [15:0] in_data_bits   = 16,
parameter [15:0] out_data_bits  = 16,
parameter [15:0] ACTUAL_BITWIDTH_OF_STREAMS = out_data_bits,
parameter ENABLE_KEEPS = 0,
parameter [7:0] NUM_OF_DATA_STREAMS = 2,
parameter [7:0] PACKET_WORD_COUNTER_WIDTH = in_data_bits,
parameter [0:0] ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION  = 0,
parameter [0:0] USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS = 1,
parameter synchronizer_depth = 3,
parameter add_extra_pipelining_for_test_signals = 1,
parameter NUM_BITS_TEST_SIGNAL_SELECTION = 3
)
(
    input clk,	
	input reset,
    multi_data_stream_interface input_streams_interface_pins,
	input  logic select_test_dds[NUM_OF_DATA_STREAMS],
    output logic [in_data_bits-1:0]  test_selected_data[NUM_OF_DATA_STREAMS],
    output logic [in_data_bits-1:0]  ramp_plus1[NUM_OF_DATA_STREAMS],
    output logic [in_data_bits-1:0]  channel_index[NUM_OF_DATA_STREAMS],
	input  logic [PACKET_WORD_COUNTER_WIDTH-1:0] packet_counter,
    input  logic [NUM_BITS_TEST_SIGNAL_SELECTION-1:0] select_test_dds_signal[NUM_OF_DATA_STREAMS],
	input  logic output_test_signal_as_unsigned[NUM_OF_DATA_STREAMS],
	input  logic [TEST_SIGNAL_DDS_NUM_PHASE_BITS-1:0] test_dds_phi_inc_i[NUM_OF_DATA_STREAMS],
    output logic [in_data_bits+1:0] registered_selected_data[NUM_OF_DATA_STREAMS],
	input  logic [out_data_bits-1:0] constant_test_data[NUM_OF_DATA_STREAMS]
);


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Macro definitions  
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`define current_subrange(chan) ((chan)*out_data_bits+ACTUAL_BITWIDTH_OF_STREAMS-1):((chan)*out_data_bits)
`define current_padded_subrange(chan) (((chan)+1)*out_data_bits-1):((chan)*out_data_bits)
`define current_subword_range (((current_subword)+1)*out_data_bits-1):((current_subword)*out_data_bits)
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	//     Wire and register definitions
	//
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [NUM_BITS_TEST_SIGNAL_SELECTION-1:0] actual_select_test_dds_signal[NUM_OF_DATA_STREAMS];
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [1:0] parallel_dds_select_test_dds_signal[NUM_OF_DATA_STREAMS];
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic select_constant_output[NUM_OF_DATA_STREAMS];	    
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic actual_output_test_signal_as_unsigned[NUM_OF_DATA_STREAMS];
      	 
	   genvar current_data_stream;
	   genvar current_subword;
	   genvar current_bit;
	   generate
	
			if (COMPILE_TEST_SIGNAL_DDS)
			begin : generate_test_dds_signal
							 parallel_dds_test_signal_generation
							 #(
								.use_explicit_blockram(USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS),
								.TEST_SIGNAL_DDS_NUM_PHASE_BITS(TEST_SIGNAL_DDS_NUM_PHASE_BITS),
								.ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION(ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION),
								.NUM_NET_OUTPUT_BITS_PER_CHANNEL(ACTUAL_BITWIDTH_OF_STREAMS),
								.NUM_GROSS_OUTPUT_BITS_PER_CHANNEL(out_data_bits),
								.NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL(bitwidth_ratio),
								.TOTAL_OUTPUT_BITS(in_data_bits),
								.NUM_TEST_CHANNELS(NUM_OF_DATA_STREAMS),
								.add_extra_pipelining(add_extra_pipelining_for_test_signals)
							  )
							  parallel_dds_test_signal_generation_inst 
							  (
								.clk('{NUM_OF_DATA_STREAMS{clk}}),
								.reset(reset),
								.generated_parallel_test_signal(test_selected_data),
								.dds_phase_word(test_dds_phi_inc_i),
								.select_test_signal(parallel_dds_select_test_dds_signal),
								.output_unsigned_signal(actual_output_test_signal_as_unsigned),
								.ramp_plus1(ramp_plus1),
								.channel_index(channel_index)
							  );
						
						  for (current_data_stream = 0; current_data_stream < NUM_OF_DATA_STREAMS; current_data_stream++)
						  begin : per_nios_dac		
  										  
										  assign parallel_dds_select_test_dds_signal[current_data_stream][1:0] = actual_select_test_dds_signal[current_data_stream];
										  
										  always_ff @(posedge clk)
										  begin														
										       registered_selected_data[current_data_stream][in_data_bits]   <= select_test_dds[current_data_stream]  ?  1'b1 : input_streams_interface_pins.valid;
											   registered_selected_data[current_data_stream][in_data_bits+1] <= select_test_dds[current_data_stream]  ?  1'b0 : input_streams_interface_pins.superframe_start_n;
										  end
										  
										  for (current_subword = 0; current_subword < bitwidth_ratio; current_subword++)
										  begin : per_subword	
																			  
														  always_ff @(posedge clk)
														  begin	
																if (select_test_dds[current_data_stream])
																begin
																	case (actual_select_test_dds_signal[current_data_stream])
																		3'b000, 3'b001, 3'b010, 3'b011 :  registered_selected_data[current_data_stream][`current_subword_range] <= test_selected_data[current_data_stream][`current_subword_range];
																		3'b100 : registered_selected_data[current_data_stream][`current_subword_range]<= constant_test_data[current_data_stream][out_data_bits-1:0];
																		3'b101 : registered_selected_data[current_data_stream][`current_subword_range] <= ramp_plus1[0][`current_subword_range]  + constant_test_data[current_data_stream][out_data_bits-1:0];																							
																		3'b110 : registered_selected_data[current_data_stream][`current_subword_range] <= packet_counter;
																		3'b111 : registered_selected_data[current_data_stream][`current_subword_range] <= channel_index[current_data_stream][`current_subword_range]  + constant_test_data[current_data_stream][out_data_bits-1:0];
																		endcase
																end else
																begin																		
																			registered_selected_data[current_data_stream][`current_subword_range] <= input_streams_interface_pins.data[current_data_stream][`current_subword_range];										
																end
														  end	
										end : per_subword				
										  	
								doublesync_no_reset #(.synchronizer_depth(2))  //syncing is mainly for timing analysis, don't care about metastability
								sync_output_test_signal_as_unsigned
								(
								.indata(output_test_signal_as_unsigned[current_data_stream]),
								.outdata(actual_output_test_signal_as_unsigned[current_data_stream]),
								.clk(clk)
								);
								
								for ( current_bit = 0; current_bit < NUM_BITS_TEST_SIGNAL_SELECTION; current_bit++)
								begin : sync_select_test_dds_signal_for_timing_analysis
										doublesync_no_reset #(.synchronizer_depth(2)) //syncing is mainly for timing analysis, don't care about metastability
										sync_select_test_dds_signal
										(
										.indata(select_test_dds_signal[current_data_stream][current_bit]),
										.outdata(actual_select_test_dds_signal[current_data_stream][current_bit]),
										.clk(clk)
										);
								end
																  
						  end
			end else
			begin
			     for (current_data_stream = 0; current_data_stream < NUM_OF_DATA_STREAMS; current_data_stream++)
				 begin : per_nios_dac								  
									  always_ff @(posedge clk)
									  begin												
											   registered_selected_data[current_data_stream] <= {input_streams_interface_pins.superframe_start_n,input_streams_interface_pins.valid,input_streams_interface_pins.data[current_data_stream]};
									  end						
				 end
			end	
	endgenerate
      
 endmodule
 `default_nettype wire
 