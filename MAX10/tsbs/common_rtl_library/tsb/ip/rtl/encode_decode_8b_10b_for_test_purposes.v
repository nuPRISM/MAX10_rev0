module encode_decode_8b_10b_for_test_purposes
(
  frame_clk,
  reset,
  frame_select,
  data_in,
  data_out,
  raw_2x_bit_data,
  transpose_2xbit_data_bits,
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
  raw_raw_2x_bit_data,
  decoder_pipeline_delay_of_uncoded_bits,
  encoder_data_out,
  encoder_disparity,
  encoder_is_control_code,
  encoder_coded_8b_10b_data_fragment,
  intermediate_2x_bit_data,
  intermediate_frame_select,
  selected_encoder_data_out,
  clear_scan_counter_8b_10b,
  inc_scan_counterm_8b_10b
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
  
  parameter numbits_datain = 12;
  parameter lock_wait_counter_bits = 9;
  parameter numbits_encoded = numbits_datain + 2;				
   
  input frame_clk;
  input reset;
  output [log2(numbits_encoded)-1:0] frame_select;
  input [numbits_datain-1:0] data_in;
  output reg [numbits_datain-1:0] data_out;
  output reg [2*numbits_encoded-1:0] raw_2x_bit_data;
  input transpose_2xbit_data_bits;
  input transpose_channel_data_halves;
  output decoder_control_character_detected;
  output coding_err;
  output disparity;
  output disparity_err;  
  input ignore_disparity_err;
  input ignore_coding_err;
  input [lock_wait_counter_bits-1:0] lock_wait;
  output  reg is_locked_8b_10b;
  output [lock_wait_counter_bits-1:0] lock_wait_counter;
  output [3:0] lock_wait_machine_state_num;
  input enable_8b_10b_lock_scan;
  output [9:0] frame_region_8b_10b;
  output [7:0] decoded_8b_10b_data_fragment;
  output [numbits_encoded-1:0] selected_data_out;
  output reg [2*numbits_encoded-1:0] raw_raw_2x_bit_data;
  output [numbits_datain-1:8] decoder_pipeline_delay_of_uncoded_bits;
  output [numbits_encoded-1:0] encoder_data_out;
  output encoder_disparity;
  input  encoder_is_control_code;
  output [9:0] encoder_coded_8b_10b_data_fragment;
  output reg [2*numbits_encoded-1:0] intermediate_2x_bit_data;
  input [log2(numbits_encoded)-1:0] intermediate_frame_select;
  output [numbits_encoded-1:0] selected_encoder_data_out;
  output clear_scan_counter_8b_10b;
  output inc_scan_counterm_8b_10b;

 encode_lower_bits_of_frame_with_8b_10b 
#(
.input_frame_length(numbits_datain)
)
encode_lower_bits_of_frame_with_8b_10b_inst
(
.reset(reset),
.data_in(data_in),
.data_out(encoder_data_out),
.clk(frame_clk),
.disparity(encoder_disparity),
.is_control_code(encoder_is_control_code),
.coded_8b_10b_data_fragment(encoder_coded_8b_10b_data_fragment)
);


always @(posedge frame_clk)
begin
     intermediate_2x_bit_data <= {intermediate_2x_bit_data[numbits_encoded-1:0],encoder_data_out};
end

data_chooser_according_to_frame_position 
#(
   .numbits_dataout(numbits_encoded)
 )
data_chooser_according_to_frame_position_inst 
(
 .data_reg_contents(intermediate_2x_bit_data),
 .selection_value(intermediate_frame_select),
 .selected_data_reg_contents(selected_encoder_data_out),
 .clk(frame_clk)
);

single_channel_generic_reframer_w_8b10b_decode
#(
.numbits_datain(numbits_encoded),
.lock_wait_counter_bits(lock_wait_counter_bits)
)
single_channel_reframer_w_8b10b_decode_inst
(
  .frame_clk                                 (frame_clk                                ),
  .reset                                     (reset                                    ),
  .frame_select                              (frame_select                             ),
  .data_in                                   (selected_encoder_data_out                ),
  .data_out                                  (data_out                                 ),
  .raw_2x_bit_data                           (raw_2x_bit_data                          ),
  .transpose_2xbit_data_bits                 (transpose_2xbit_data_bits                ),
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
  .raw_raw_2x_bit_data                       (raw_raw_2x_bit_data                      ),
  .decoder_pipeline_delay_of_uncoded_bits    (decoder_pipeline_delay_of_uncoded_bits    ),
  .clear_scan_counter_8b_10b                 (clear_scan_counter_8b_10b),
  .inc_scan_counterm_8b_10b                  (inc_scan_counterm_8b_10b)
  
);

endmodule
