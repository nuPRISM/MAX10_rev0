
module single_channel_14bit_reframer_w_8b10b_decode
#(
parameter lock_wait_counter_bits = 9
)
(
  input frame_clk,
  input reset,
  output     [3:0] frame_select,
  input      [13:0] data_in,
  output reg [11:0] data_out,
  output reg [27:0] raw_28_bit_data,
  input transpose_28bit_data_bits,
  input transpose_channel_data_halves,
  output decoder_control_character_detected,
  output coding_err,
  output disparity,
  output disparity_err,  
  input ignore_disparity_err,
  input ignore_coding_err,
  input [lock_wait_counter_bits-1:0] lock_wait,
  output  reg is_locked_8b_10b,
  output [lock_wait_counter_bits-1:0] lock_wait_counter,
  output [3:0] lock_wait_machine_state_num,
  input enable_8b_10b_lock_scan,
  output [9:0] frame_region_8b_10b,
  output [7:0] decoded_8b_10b_data_fragment,
  output [13:0] selected_data_out_14_bit,
  output reg [27:0] raw_raw_28_bit_data,
  output [3:0] decoder_pipeline_delay_of_bits_3_to_0,
  output clear_scan_counter_8b_10b,
  output inc_scan_counterm_8b_10b
);


always @(posedge frame_clk)
begin
     raw_raw_28_bit_data <= transpose_channel_data_halves ? {data_in,raw_raw_28_bit_data[27:14]} : {raw_raw_28_bit_data[13:0],data_in};
end

always @(posedge frame_clk)
begin
     for (int i = 0; i < 28; i++)
	 begin
		   if (transpose_28bit_data_bits)
		   begin
				 raw_28_bit_data[i] <= raw_raw_28_bit_data[27-i];
		   end else
		   begin 
				 raw_28_bit_data[i] <= raw_raw_28_bit_data[i];
		   end			   
	 end
end

data_chooser_14bit_according_to_frame_position 
data_chooser_14bit_according_to_frame_position_inst 
(
 .data_reg_contents(raw_28_bit_data),
 .selection_value(frame_select),
 .selected_data_reg_contents(selected_data_out_14_bit),
 .clk(frame_clk)
);


decode_upper_10_bits_of_14bit_frame_with_8b_10b 
decode_upper_10_bits_of_14bit_frame_with_8b_10b_inst
(
.reset(reset),
.data_in(selected_data_out_14_bit),
.data_out(data_out),
.clk(frame_clk),
.control_character_detected(decoder_control_character_detected),
.decoded_8b_10b_data_fragment(decoded_8b_10b_data_fragment),
.pipeline_delay_of_bits_3_to_0(decoder_pipeline_delay_of_bits_3_to_0),
.frame_region_8b_10b(frame_region_8b_10b),
.coding_err       (coding_err),
.disparity        (disparity),
.disparity_err    (disparity_err)
);

always @(posedge frame_clk)
begin
      is_locked_8b_10b <= !((disparity_err & (!ignore_disparity_err)) || (coding_err & (!ignore_coding_err)));
end
  

wait_and_check_for_lock_and_scan
#(
.wait_counter_bits(lock_wait_counter_bits),
.scan_counter_bits(4)
)
wait_and_check_for_lock_and_scan_inst
(
 .clk(frame_clk),
 .reset(reset),
 .counter(lock_wait_counter),
 .scan_counter(frame_select),
 .state(lock_wait_machine_state_num),
 .wait_cycles(lock_wait),
 .lock_indication(is_locked_8b_10b),
 .max_scan_offset(13),
 .enable_scan(enable_8b_10b_lock_scan),
 .clear_scan_counter(clear_scan_counter_8b_10b),
 .inc_scan_counter  (inc_scan_counterm_8b_10b)
);


endmodule

