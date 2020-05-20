
module multi_channel_14bit_reframer_w_8b10b_decode
#(
      parameter numchannels = 2,
	  parameter lock_wait_counter_bits = 8
)
(
  input clk,
  input reset,
  input  [13:0] data_in   [numchannels-1:0],
  output [11:0] data_out  [numchannels-1:0],
  input  transpose_28bit_data_bits,
  input  transpose_channel_data_halves,
  input  ignore_disparity_err,
  input  ignore_coding_err,
  input  [lock_wait_counter_bits-1:0] lock_wait,
  input  enable_8b_10b_lock_scan,
  
  
  //debugging outputs
  output [3:0] frame_select                               [numchannels-1:0],
  output [27:0] raw_28_bit_data                           [numchannels-1:0],
  output [numchannels-1:0]  decoder_control_character_detected,
  output [numchannels-1:0]  coding_err                        ,
  output [numchannels-1:0]  disparity                         ,
  output [numchannels-1:0]  disparity_err                     ,  
  output [numchannels-1:0]  is_locked_8b_10b                  ,
  output [lock_wait_counter_bits-1:0] lock_wait_counter   [numchannels-1:0],
  output [3:0] lock_wait_machine_state_num                [numchannels-1:0],
  output [9:0] frame_region_8b_10b                        [numchannels-1:0],
  output [7:0] decoded_8b_10b_data_fragment               [numchannels-1:0],
  output [13:0] selected_data_out_14_bit                  [numchannels-1:0],
  output [27:0] raw_raw_28_bit_data                       [numchannels-1:0],
  output [3:0] decoder_pipeline_delay_of_bits_3_to_0      [numchannels-1:0],
  output [numchannels-1:0] clear_scan_counter_8b_10b,
  output [numchannels-1:0] inc_scan_counterm_8b_10b                         
  
);

			  genvar i;
			  generate
			              for (i = 0; i < numchannels; i++)
			              begin : reframe
			 	               single_channel_14bit_reframer_w_8b10b_decode
								#(
								.lock_wait_counter_bits(lock_wait_counter_bits)
								)
								single_channel_14bit_reframer_w_8b10b_decode_inst
								(
								  .frame_clk                                 (clk                                       ),
								  .reset                                     (reset                                     ),
								  .data_in                                   (data_in                                [i]),
								  .data_out                                  (data_out                               [i]),
								  .transpose_28bit_data_bits                 (transpose_28bit_data_bits                 ),
								  .transpose_channel_data_halves             (transpose_channel_data_halves             ),
								  .enable_8b_10b_lock_scan                   (enable_8b_10b_lock_scan                   ),
								  .lock_wait                                 (lock_wait                                 ),
								  .frame_select                              (frame_select                           [i]),
								  .ignore_disparity_err                      (ignore_disparity_err                      ),
								  .ignore_coding_err                         (ignore_coding_err                         ),								  
								  
								  
								  //debugging outputs
								  .coding_err                                (coding_err                             [i]),								  
								  .raw_28_bit_data                           (raw_28_bit_data                        [i]),
								  .decoder_control_character_detected        (decoder_control_character_detected     [i]),
								  .disparity                                 (disparity                              [i]),
								  .disparity_err                             (disparity_err                          [i]),
								  .is_locked_8b_10b                          (is_locked_8b_10b                       [i]),
								  .lock_wait_counter                         (lock_wait_counter                      [i]),
								  .lock_wait_machine_state_num               (lock_wait_machine_state_num            [i]),
								  .frame_region_8b_10b                       (frame_region_8b_10b                    [i]),
								  .decoded_8b_10b_data_fragment              (decoded_8b_10b_data_fragment           [i]),
								  .selected_data_out_14_bit                  (selected_data_out_14_bit               [i]),
								  .raw_raw_28_bit_data                       (raw_raw_28_bit_data                    [i]),
								  .decoder_pipeline_delay_of_bits_3_to_0     (decoder_pipeline_delay_of_bits_3_to_0  [i]),
								  .clear_scan_counter_8b_10b                 (clear_scan_counter_8b_10b              [i]),
								  .inc_scan_counterm_8b_10b                  (inc_scan_counterm_8b_10b               [i])								  
								);
										
			              end				      					   
              endgenerate
endmodule

