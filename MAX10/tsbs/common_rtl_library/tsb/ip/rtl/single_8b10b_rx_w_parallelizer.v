`default_nettype none
module single_8b10b_rx_w_parallelizer
#(
parameter lock_wait_counter_bits = 9,
parameter num_bits_in_raw_frame = 8,
parameter num_bits_in_coded_frame = num_bits_in_raw_frame+2,
parameter output_data_parallelization_ratio = 4,
parameter valid_output_word_counter_bits = 32
)
(
   frame_clk,
   reset,
   frame_select,
   data_in,
   data_out,
   decoded_data,
   raw_2x_coded_bit_data,
   transpose_2x_coded_bit_data_bits,
   transpose_channel_data_halves,
   decoder_control_character_detected,
   coding_err,
   disparity,
   disparity_err,  
   ignore_disparity_err,
   ignore_coding_err,
   lock_wait,
   is_locked_8b_10b,
   lock_wait_counter,
   lock_wait_machine_state_num,
   enable_8b_10b_lock_scan,
   frame_region_8b_10b,
   decoded_8b_10b_data_fragment,
   selected_data_out,
   raw_raw_2x_coded_bit_data,
   decoder_pipeline_delay_of_uncoded_bits,
   clear_scan_counter_8b_10b,
   inc_scan_counterm_8b_10b,
   parallelizer_current_byte_enable,
   parallelizer_output_regs,
   valid_data_word_count,
   delay_data_out_for_lane_alignment,
   fixed_delay_data_out_prior_to_lane_alignment,
   fixed_delay_decoder_control_character_detected,
   new_data_word_ready_now
);


	function automatic int log2 (input int n);
						int original_n;
						original_n = n;
						if (n <=1) return 1; // abort function
						log2 = 0;
						while (n > 1) begin
						    n = n/2;
						    log2++;
						end
						
						if (2**log2 != original_n)
						begin
						     log2 = log2 + 1;
						end
						
						endfunction
						
localparam num_selection_bits = log2(num_bits_in_coded_frame);

  input logic frame_clk;
  input logic reset;
  input logic [num_bits_in_coded_frame-1:0] data_in;
  input logic transpose_2x_coded_bit_data_bits;
  input logic transpose_channel_data_halves;
  input logic ignore_disparity_err;
  input logic ignore_coding_err;
  input logic [lock_wait_counter_bits-1:0] lock_wait;
  input logic delay_data_out_for_lane_alignment;


  output logic [output_data_parallelization_ratio*num_bits_in_raw_frame-1:0] data_out;
  output logic [valid_output_word_counter_bits-1:0] valid_data_word_count;
  output logic decoder_control_character_detected;
  output logic [num_bits_in_raw_frame-1:0] decoded_data;
  output logic coding_err;
  output logic disparity;
  output logic disparity_err;  
  output logic new_data_word_ready_now;
  
  output logic [num_selection_bits-1:0] frame_select;
  output logic [2*num_bits_in_coded_frame-1:0] raw_2x_coded_bit_data;

  output logic is_locked_8b_10b;
  output logic [lock_wait_counter_bits-1:0] lock_wait_counter;
  output logic [3:0] lock_wait_machine_state_num;
  input  logic enable_8b_10b_lock_scan;
  output logic [9:0] frame_region_8b_10b;
  output logic [7:0] decoded_8b_10b_data_fragment;
  output logic [num_bits_in_coded_frame-1:0] selected_data_out;
  output logic [2*num_bits_in_coded_frame-1:0] raw_raw_2x_coded_bit_data;
  output logic [num_bits_in_coded_frame-1:0] decoder_pipeline_delay_of_uncoded_bits;
  output logic clear_scan_counter_8b_10b;
  output logic inc_scan_counterm_8b_10b;
  output logic [output_data_parallelization_ratio-1:0] parallelizer_current_byte_enable;
  output logic [num_bits_in_raw_frame-1:0] parallelizer_output_regs[output_data_parallelization_ratio-1];
  output logic [num_bits_in_raw_frame-1:0] fixed_delay_data_out_prior_to_lane_alignment;
  output reg fixed_delay_decoder_control_character_detected;

single_channel_generic_reframer_w_8b10b_decode
#(
.numbits_datain(num_bits_in_coded_frame),
.lock_wait_counter_bits(lock_wait_counter_bits)
)
single_channel_generic_reframer_w_8b10b_decode_inst
(
  .frame_clk                                 (frame_clk                                ),
  .reset                                     (reset                                    ),
  .frame_select                              (frame_select                             ),
  .data_in                                   (data_in                                  ),
  .data_out                                  (decoded_data                             ),
  .raw_2x_bit_data                           (raw_2x_coded_bit_data                    ),
  .transpose_2xbit_data_bits                 (transpose_2x_coded_bit_data_bits         ),
  .transpose_channel_data_halves             (transpose_channel_data_halves            ),
  .decoder_control_character_detected        (decoder_control_character_detected       ),
  .coding_err                                (coding_err                               ),
  .disparity                                 (disparity                                ),
  .disparity_err                             (disparity_err                            ),
  .ignore_disparity_err                      (ignore_disparity_err                     ),
  .ignore_coding_err                         (ignore_coding_err                        ),
  .lock_wait                                 (lock_wait                                ),
  .is_locked_8b_10b                          (is_locked_8b_10b                         ),
  .lock_wait_counter                         (lock_wait_counter                        ),
  .lock_wait_machine_state_num               (lock_wait_machine_state_num              ),
  .enable_8b_10b_lock_scan                   (enable_8b_10b_lock_scan                  ),
  .frame_region_8b_10b                       (frame_region_8b_10b                      ),
  .decoded_8b_10b_data_fragment              (decoded_8b_10b_data_fragment             ),
  .selected_data_out                         (selected_data_out                        ),
  .raw_raw_2x_bit_data                       (raw_raw_2x_coded_bit_data                ),
  .decoder_pipeline_delay_of_uncoded_bits    (decoder_pipeline_delay_of_uncoded_bits   ),
  .clear_scan_counter_8b_10b                 (clear_scan_counter_8b_10b                ),
  .inc_scan_counterm_8b_10b                  (inc_scan_counterm_8b_10b                 ),
  .fixed_delay_data_out_prior_to_lane_alignment (fixed_delay_data_out_prior_to_lane_alignment),
  .delay_data_out_for_lane_alignment            (delay_data_out_for_lane_alignment),
  .fixed_delay_decoder_control_character_detected(fixed_delay_decoder_control_character_detected)
  
);

controlled_parallelize_input_data
#(
.parallelization_ratio(output_data_parallelization_ratio),
.num_input_data_bits(num_bits_in_raw_frame),
.valid_output_word_counter_bits(valid_output_word_counter_bits)
)
controlled_parallelize_input_data_inst
(
.clk(frame_clk),
.data_in(decoded_data),
.output_regs(parallelizer_output_regs),
.current_byte_enable(parallelizer_current_byte_enable),
.reset_byte_count(decoder_control_character_detected),
.data_valid(is_locked_8b_10b),
.data_out(data_out),
.valid_data_word_count(valid_data_word_count),
.reset_valid_word_count(reset),
.new_data_word_ready_now(new_data_word_ready_now)
);

endmodule
`default_nettype wire

