`default_nettype none
module multi_channel_generic_reframer
#(
parameter lock_wait_counter_bits = 9,
parameter numbits_datain = 14,
parameter num_data_channels = 8
)
(
   frame_clk,
   reset,
   frame_select,
   data_in,
   data_out,
   frame_sampled_clock_in,
   frame_sampled_clock_out,  
   frame_lock_mask,
   raw_2x_bit_data,
   raw_raw_2x_bit_data,   
   raw_2x_bit_frame,
   raw_raw_2x_bit_frame,
   transpose_2xbit_data_bits,
   transpose_channel_data_halves,
   lock_wait,
   reframer_is_locked,
   lock_wait_counter,
   lock_wait_machine_state_num,
   enable_lock_scan,
   clear_scan_counter,
   inc_scan_counter,
   frame_to_data_offset,
   actual_data_selection_value
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
  input      [log2(numbits_datain)-1:0] frame_to_data_offset;
  input      [numbits_datain-1:0] data_in[num_data_channels];
  input      [numbits_datain-1:0] frame_lock_mask;
  input      [numbits_datain-1:0] frame_sampled_clock_in;
  output reg [numbits_datain-1:0] data_out[num_data_channels];
  output reg [numbits_datain-1:0] frame_sampled_clock_out;
  output reg [2*numbits_datain-1:0] raw_2x_bit_data[num_data_channels];
  output reg [2*numbits_datain-1:0] raw_2x_bit_frame;
  output reg [2*numbits_datain-1:0] raw_raw_2x_bit_data[num_data_channels];
  output reg [2*numbits_datain-1:0] raw_raw_2x_bit_frame;
  output logic [log2(numbits_datain)-1:0] actual_data_selection_value;
  input transpose_2xbit_data_bits;
  input transpose_channel_data_halves;
  input [lock_wait_counter_bits-1:0] lock_wait;
  output  reg reframer_is_locked;
  output [lock_wait_counter_bits-1:0] lock_wait_counter;
  output [3:0] lock_wait_machine_state_num;
  input enable_lock_scan;
  output clear_scan_counter;
  output inc_scan_counter;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Data Section
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


assign actual_data_selection_value = frame_select + frame_to_data_offset;

genvar channel_num;
generate
			for (channel_num = 0; channel_num < num_data_channels; channel_num++)
			begin : possibly_transpose_data_channels
						always @(posedge frame_clk)
						begin
							 raw_raw_2x_bit_data[channel_num] <= transpose_channel_data_halves ? {data_in[channel_num],raw_raw_2x_bit_data[channel_num][2*numbits_datain-1:numbits_datain]} : {raw_raw_2x_bit_data[channel_num][numbits_datain-1:0],data_in[channel_num]};
						end

						always @(posedge frame_clk)
						begin
							 for (int i = 0; i < 2*numbits_datain; i++)
							 begin
								   if (transpose_2xbit_data_bits)
								   begin
										 raw_2x_bit_data[channel_num][i] <= raw_raw_2x_bit_data[channel_num][2*numbits_datain-1-i];
								   end else
								   begin 
										 raw_2x_bit_data[channel_num][i] <= raw_raw_2x_bit_data[channel_num][i];
								   end			   
							 end
						end
						data_chooser_according_to_frame_position 
						#(
						.numbits_dataout(numbits_datain)
						)
						data_chooser_according_to_frame_position_inst 
						(
						 .data_reg_contents(raw_2x_bit_data[channel_num]),
						 .selection_value(actual_data_selection_value),
						 .selected_data_reg_contents(data_out[channel_num]),
						 .clk(frame_clk)
						);
			end			
endgenerate




///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Frame Section
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always @(posedge frame_clk)
begin
     raw_raw_2x_bit_frame <= transpose_channel_data_halves ? {frame_sampled_clock_in,raw_raw_2x_bit_frame[2*numbits_datain-1:numbits_datain]} : {raw_raw_2x_bit_frame[numbits_datain-1:0],frame_sampled_clock_in};
end

always @(posedge frame_clk)
begin
     for (int i = 0; i < 2*numbits_datain; i++)
	 begin
		   if (transpose_2xbit_data_bits)
		   begin
				 raw_2x_bit_frame[i] <= raw_raw_2x_bit_frame[2*numbits_datain-1-i];
		   end else
		   begin 
				 raw_2x_bit_frame[i] <= raw_raw_2x_bit_frame[i];
		   end			   
	 end
end


data_chooser_according_to_frame_position 
#(
.numbits_dataout(numbits_datain)
)
frame_chooser_according_to_frame_position_inst 
(
 .data_reg_contents(raw_2x_bit_frame),
 .selection_value(frame_select),
 .selected_data_reg_contents(frame_sampled_clock_out),
 .clk(frame_clk)
);

always @(posedge frame_clk)
begin
      reframer_is_locked <= (frame_sampled_clock_out == frame_lock_mask);
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
 .lock_indication(reframer_is_locked),
 .max_scan_offset(numbits_datain-1),
 .enable_scan(enable_lock_scan),
 .clear_scan_counter(clear_scan_counter),
 .inc_scan_counter  (inc_scan_counter)
);


endmodule
`default_nettype wire
