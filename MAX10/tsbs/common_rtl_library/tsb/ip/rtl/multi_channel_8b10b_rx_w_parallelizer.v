`default_nettype none
module multi_channel_8b10b_rx_w_parallelizer
#(
parameter numchannels = 2,
parameter lock_wait_counter_bits = 9,
parameter num_bits_in_raw_frame = 8,
parameter num_bits_in_coded_frame = num_bits_in_raw_frame+2,
parameter output_data_parallelization_ratio = 4,
parameter valid_output_word_counter_bits = 32,
parameter USE_PLL_x20_CLOCK_TO_CLOCK_RX_DATA = 0,
parameter synchronizer_depth = 2
)
(
   frame_clk,
   data_out_parallel_clock,
   pll_generated_20x_of_data_out_parallel_clock,
   reset,
   frame_select,
   data_in,
   data_out,
   resynced_parallelized_data_out,
   raw_resynced_parallelized_data_out,
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
   parallelizer_total_output_reg,
   valid_data_word_count,
   delay_data_out_for_lane_alignment,
   fixed_delay_data_out_prior_to_lane_alignment,
   fixed_delay_decoder_control_character_detected,
   enable_clocking_of_output_data,
   new_data_word_ready_now,
   intermediate_clk,
   intermediate_data,
   actual_ce_conv_up,  
   actual_ce_conv_down
   
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

  input                                      frame_clk;
  input  data_out_parallel_clock;
  input                                      reset;
  output  [num_selection_bits-1:0]        frame_select[numchannels];
  output  [num_bits_in_raw_frame-1:0]     data_out[numchannels];
  input  [num_bits_in_coded_frame-1:0]     data_in[numchannels];
  output  [2*num_bits_in_coded_frame-1:0] raw_2x_coded_bit_data[numchannels];
  input                                   transpose_2x_coded_bit_data_bits;
  input                                   transpose_channel_data_halves;
  output [numchannels-1:0]                   decoder_control_character_detected;
  output [numchannels-1:0]                   coding_err;
  output [numchannels-1:0]                   disparity;
  output [numchannels-1:0]                   disparity_err;  
  input  [numchannels-1:0]                   ignore_disparity_err;
  input  [numchannels-1:0]                   ignore_coding_err;
  input  [lock_wait_counter_bits-1:0]        lock_wait;
  output                                     is_locked_8b_10b[numchannels];
  output [lock_wait_counter_bits-1:0]        lock_wait_counter[numchannels];
  output [3:0] lock_wait_machine_state_num[numchannels];
  input  [numchannels-1:0] enable_8b_10b_lock_scan;
  output [9:0] frame_region_8b_10b[numchannels];
  output [7:0] decoded_8b_10b_data_fragment[numchannels];
  output [num_bits_in_coded_frame-1:0] selected_data_out[numchannels];
  output [2*num_bits_in_coded_frame-1:0] raw_raw_2x_coded_bit_data[numchannels];
  output [num_bits_in_coded_frame-1:0] decoder_pipeline_delay_of_uncoded_bits[numchannels];
  output [numchannels-1:0] clear_scan_counter_8b_10b;
  output [numchannels-1:0] inc_scan_counterm_8b_10b;
  output [output_data_parallelization_ratio-1:0] parallelizer_current_byte_enable[numchannels];
  output [num_bits_in_raw_frame-1:0] parallelizer_output_regs[numchannels][output_data_parallelization_ratio-1];
  output [output_data_parallelization_ratio*num_bits_in_raw_frame-1:0] parallelizer_total_output_reg[numchannels];
  output [valid_output_word_counter_bits-1:0] valid_data_word_count[numchannels];
  input logic [numchannels-1:0] delay_data_out_for_lane_alignment;
  output logic [num_bits_in_raw_frame-1:0] fixed_delay_data_out_prior_to_lane_alignment[numchannels];
  output logic [numchannels-1:0] fixed_delay_decoder_control_character_detected;
  output [output_data_parallelization_ratio*num_bits_in_raw_frame-1:0] resynced_parallelized_data_out[numchannels];
  output [output_data_parallelization_ratio*num_bits_in_raw_frame-1:0] raw_resynced_parallelized_data_out[numchannels];
  input pll_generated_20x_of_data_out_parallel_clock;
  input intermediate_clk;
  output logic [output_data_parallelization_ratio*num_bits_in_raw_frame-1:0] intermediate_data[numchannels];
  output logic actual_ce_conv_up  [numchannels];
  output logic actual_ce_conv_down[numchannels];
  output logic enable_clocking_of_output_data[numchannels];
  output logic new_data_word_ready_now[numchannels];

  genvar i;
			  generate
			              for (i = 0; i < numchannels; i++)
			              begin : rx_8b10b_and_parallelize
                         
                         
                                          if (USE_PLL_x20_CLOCK_TO_CLOCK_RX_DATA)
                                          begin
														async_trap_and_reset_gen_1_pulse_robust
                                                        #(.synchronizer_depth(synchronizer_depth))
														trap_data_valid_now(
														.async_sig(new_data_word_ready_now[i]), 
														.outclk(pll_generated_20x_of_data_out_parallel_clock), 
														.out_sync_sig(), 
														.unregistered_out_sync_sig(enable_clocking_of_output_data[i]),
														.auto_reset(1'b1), 
														.reset(1'b1)
														);
														
														always_ff @(posedge pll_generated_20x_of_data_out_parallel_clock)
														begin
															 if (enable_clocking_of_output_data[i])
															 begin
																  raw_resynced_parallelized_data_out[i] <= parallelizer_total_output_reg[i];
															 end
														end
														
														always_ff @(posedge data_out_parallel_clock)
														begin
															 resynced_parallelized_data_out[i] <= raw_resynced_parallelized_data_out[i];												 
														end
										  end else
										  begin
                                          
                                                            conv_between_clocks_with_intermediate_clk
															#(
                                                            .width(output_data_parallelization_ratio*num_bits_in_raw_frame)
                                                            )
                                                            resync_output_data
															(
															.indata ( parallelizer_total_output_reg[i]       ),
															.outdata( raw_resynced_parallelized_data_out[i]  ),
															.inclk  ( frame_clk                              ),
															.outclk ( data_out_parallel_clock                ),
															.intermediate_clk                               (intermediate_clk ),
															.intermediate_data                              (intermediate_data[i]),
															.actual_ce_conv_up                              (actual_ce_conv_up  [i]),
															.actual_ce_conv_down                            (actual_ce_conv_down[i])
															);                                           
												
														assign resynced_parallelized_data_out[i] = raw_resynced_parallelized_data_out[i];												 
														
                                          end
                                       
                                           
											single_8b10b_rx_w_parallelizer
											#(
											.lock_wait_counter_bits(lock_wait_counter_bits),
											.num_bits_in_raw_frame(num_bits_in_raw_frame),
											.num_bits_in_coded_frame(num_bits_in_coded_frame),
											.output_data_parallelization_ratio(output_data_parallelization_ratio),
											.valid_output_word_counter_bits(valid_output_word_counter_bits)
											)
											single_8b10b_rx_w_parallelizer_inst
											(
											   /* input logic                                                                   */ .frame_clk                                             (frame_clk                                        ),
											  /* input logic                                                                    */ .reset                                                 (reset                                            ),
											  /* input logic [num_bits_in_coded_frame-1:0]                                      */ .data_in                                               (data_in                                       [i]),
											  /* input logic                                                                    */ .transpose_2x_coded_bit_data_bits                      (transpose_2x_coded_bit_data_bits                 ),
											  /* input logic                                                                    */ .transpose_channel_data_halves                         (transpose_channel_data_halves                    ),
											  /* input logic                                                                    */ .ignore_disparity_err                                  (ignore_disparity_err                          [i]),
											  /* input logic                                                                    */ .ignore_coding_err                                     (ignore_coding_err                             [i]),
											  /* input logic [lock_wait_counter_bits-1:0]                                       */ .lock_wait                                             (lock_wait                                        ),
											  /* input */                                                                          .delay_data_out_for_lane_alignment                     (delay_data_out_for_lane_alignment             [i]),
																																														 
											  /* output logic [output_data_parallelization_ratio*num_bits_in_raw_frame-1:0]     */ .data_out                                              (parallelizer_total_output_reg                 [i]),
											  /* output logic [valid_output_word_counter_bits-1:0]                              */ .valid_data_word_count                                 (valid_data_word_count                         [i]),
											  /* output logic                                                                   */ .decoder_control_character_detected                    (decoder_control_character_detected            [i]),
											  /* output logic [num_bits_in_raw_frame-1:0]                                       */ .decoded_data                                          (data_out                                      [i]),
											  /* output logic                                                                   */ .coding_err                                            (coding_err                                    [i]),
											  /* output logic                                                                   */ .disparity                                             (disparity                                     [i]),
											  /* output logic                                                                   */ .disparity_err                                         (disparity_err                                 [i]),
																																														   
											  /* output logic [num_selection_bits-1:0]                                          */  .frame_select                                         (frame_select                                  [i]),
											  /* output logic [2*num_bits_in_coded_frame-1:0]                                   */  .raw_2x_coded_bit_data                                (raw_2x_coded_bit_data                         [i]),
											  /* output logic                                                                   */  .is_locked_8b_10b                                     (is_locked_8b_10b                              [i]),
											  /* output logic [lock_wait_counter_bits-1:0]                                      */  .lock_wait_counter                                    (lock_wait_counter                             [i]),
											  /* output logic [3:0]                                                             */  .lock_wait_machine_state_num                          (lock_wait_machine_state_num                   [i]),
											  /* input  logic                                                                   */  .enable_8b_10b_lock_scan                              (enable_8b_10b_lock_scan                       [i]),
											  /* output logic [9:0]                                                             */  .frame_region_8b_10b                                  (frame_region_8b_10b                           [i]),
											  /* output logic [7:0]                                                             */  .decoded_8b_10b_data_fragment                         (decoded_8b_10b_data_fragment                  [i]),
											  /* output logic [num_bits_in_coded_frame-1:0]                                     */  .selected_data_out                                    (selected_data_out                             [i]),
											  /* output logic [2*num_bits_in_coded_frame-1:0]                                   */  .raw_raw_2x_coded_bit_data                            (raw_raw_2x_coded_bit_data                     [i]),
											  /* output logic [num_bits_in_coded_frame-1:0]                                     */  .decoder_pipeline_delay_of_uncoded_bits               (decoder_pipeline_delay_of_uncoded_bits        [i]),
											  /* output logic                                                                   */  .clear_scan_counter_8b_10b                            (clear_scan_counter_8b_10b                     [i]),
											  /* output logic                                                                   */  .inc_scan_counterm_8b_10b                             (inc_scan_counterm_8b_10b                      [i]),
											  /* output logic [output_data_parallelization_ratio-1:0]                           */  .parallelizer_current_byte_enable                     (parallelizer_current_byte_enable              [i]),
											  /* output logic [num_bits_in_raw_frame-1:0] x[output_data_parallelization_ratio-1]*/  .parallelizer_output_regs                             (parallelizer_output_regs                      [i]),
											  /* output logic [numbits_dataout-1:0] */                                              .fixed_delay_data_out_prior_to_lane_alignment         (fixed_delay_data_out_prior_to_lane_alignment  [i]),                                                                                       
											  /* output */                                                                          .fixed_delay_decoder_control_character_detected       (fixed_delay_decoder_control_character_detected[i]),
											                                                                                        .new_data_word_ready_now                              (new_data_word_ready_now[i])              

											);
                         end				      					   
              endgenerate

endmodule
`default_nettype wire

