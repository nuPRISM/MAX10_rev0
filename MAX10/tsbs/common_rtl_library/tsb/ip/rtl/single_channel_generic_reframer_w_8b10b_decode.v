`default_nettype none
module single_channel_generic_reframer_w_8b10b_decode
#(
parameter lock_wait_counter_bits = 9,
parameter numbits_datain = 40,
parameter numbits_dataout = numbits_datain-2
)
(
   frame_clk,
   reset,
   frame_select,
   data_in,
   data_out,
   raw_data_out,
   raw_2x_bit_data,
   raw_raw_2x_bit_data,
   transpose_2xbit_data_bits,
   transpose_channel_data_halves,
   raw_decoder_control_character_detected,
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
   decoder_pipeline_delay_of_uncoded_bits,
   clear_scan_counter_8b_10b,
   inc_scan_counterm_8b_10b,
   delay_data_out_for_lane_alignment,
   fixed_delay_data_out_prior_to_lane_alignment,
   fixed_delay_decoder_control_character_detected
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
  input frame_clk;
  input reset;
  output     [log2(numbits_datain)-1:0] frame_select;
  input      [numbits_datain-1:0] data_in;
  output reg [numbits_dataout-1:0] data_out;
  output reg [numbits_dataout-1:0] fixed_delay_data_out_prior_to_lane_alignment;
  output reg fixed_delay_decoder_control_character_detected = 0;
  output reg [numbits_dataout-1:0] raw_data_out;
  output reg [2*numbits_datain-1:0] raw_2x_bit_data;
  output reg [2*numbits_datain-1:0] raw_raw_2x_bit_data;
  input transpose_2xbit_data_bits;
  input transpose_channel_data_halves;
  output raw_decoder_control_character_detected;
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
  output [numbits_datain-1:0] selected_data_out;
  output [numbits_datain-1:10] decoder_pipeline_delay_of_uncoded_bits;
  output clear_scan_counter_8b_10b;
  output inc_scan_counterm_8b_10b;
  input delay_data_out_for_lane_alignment;

always @(posedge frame_clk)
begin
     raw_raw_2x_bit_data <= transpose_channel_data_halves ? {data_in,raw_raw_2x_bit_data[2*numbits_datain-1:numbits_datain]} : {raw_raw_2x_bit_data[numbits_datain-1:0],data_in};
end

always @(posedge frame_clk)
begin
     for (int i = 0; i < 2*numbits_datain; i++)
	 begin
		   if (transpose_2xbit_data_bits)
		   begin
				 raw_2x_bit_data[i] <= raw_raw_2x_bit_data[2*numbits_datain-1-i];
		   end else
		   begin 
				 raw_2x_bit_data[i] <= raw_raw_2x_bit_data[i];
		   end			   
	 end
end

data_chooser_according_to_frame_position 
#(
.numbits_dataout(numbits_datain)
)
data_chooser_according_to_frame_position_inst 
(
 .data_reg_contents(raw_2x_bit_data),
 .selection_value(frame_select),
 .selected_data_reg_contents(selected_data_out),
 .clk(frame_clk)
);


decode_lower_10_bits_of_frame_with_8b_10b_generic 
#(
.input_frame_length(numbits_datain)
)
decode_lower_10_bits_of_frame_with_8b_10b_inst
(
.reset(reset),
.data_in(selected_data_out),
.data_out(raw_data_out),
.clk(frame_clk),
.control_character_detected(raw_decoder_control_character_detected),
.decoded_8b_10b_data_fragment(decoded_8b_10b_data_fragment),
.pipeline_delay_of_uncoded_bits(decoder_pipeline_delay_of_uncoded_bits),
.frame_region_8b_10b(frame_region_8b_10b),
.coding_err       (coding_err),
.disparity        (disparity),
.disparity_err    (disparity_err)
);

always_ff @(posedge frame_clk)
begin
      fixed_delay_data_out_prior_to_lane_alignment <= raw_data_out;
      fixed_delay_decoder_control_character_detected <= raw_decoder_control_character_detected;
      data_out <= delay_data_out_for_lane_alignment ? fixed_delay_data_out_prior_to_lane_alignment : raw_data_out;      
      decoder_control_character_detected <= delay_data_out_for_lane_alignment ? fixed_delay_decoder_control_character_detected : raw_decoder_control_character_detected;      
end

always @(posedge frame_clk)
begin
      is_locked_8b_10b <= !((disparity_err & (!ignore_disparity_err)) || (coding_err & (!ignore_coding_err)));
end
  

wait_and_check_for_lock_and_scan
#(
.wait_counter_bits(lock_wait_counter_bits),
.scan_counter_bits(log2(numbits_datain))
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
 .max_scan_offset(numbits_datain-1),
 .enable_scan(enable_8b_10b_lock_scan),
 .clear_scan_counter(clear_scan_counter_8b_10b),
 .inc_scan_counter  (inc_scan_counterm_8b_10b)
);


endmodule

