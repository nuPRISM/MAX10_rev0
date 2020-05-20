`default_nettype none
module test_multi_channel_generic_reframer
#(
parameter lock_wait_counter_bits = 9,
parameter numbits_datain = 14,
parameter num_data_channels = 2
)
(
  frame_clk,
  reset,
  frame_select,
  data_in,
  actual_data_in,
  frame_lock_mask,
  frame_sampled_clock_in,
  data_out,
  frame_sampled_clock_out,
  raw_2x_bit_data,
  raw_2x_bit_frame,
  raw_raw_2x_bit_data,
  raw_raw_2x_bit_frame,
  intermediate_data,
  intermediate_frame,
  intermediate_frame_select,
  transpose_2xbit_data_bits,
  transpose_channel_data_halves,
  lock_wait,
  reframer_is_locked,
  lock_wait_counter,
  lock_wait_machine_state_num,
  enable_lock_scan,
  clear_scan_counter,
  inc_scan_counter,
  frame_to_data_offset 
);




`include "log2_function.v"

  input frame_clk;
  input reset;
  output   logic [log2(numbits_datain)-1:0] frame_select;  
  input   [log2(numbits_datain)-1:0] frame_to_data_offset;

  output   logic  [numbits_datain-1:0] data_in[num_data_channels];
  output   logic  [numbits_datain-1:0] actual_data_in[num_data_channels];

  input      [numbits_datain-1:0] frame_lock_mask;
  output logic [numbits_datain-1:0] frame_sampled_clock_in;
  output logic [numbits_datain-1:0] data_out[num_data_channels];
  output logic [numbits_datain-1:0] frame_sampled_clock_out;
  output logic [2*numbits_datain-1:0] raw_2x_bit_data[num_data_channels];
  output logic [2*numbits_datain-1:0] raw_2x_bit_frame;
  output logic [2*numbits_datain-1:0] raw_raw_2x_bit_data[num_data_channels];
  output logic [2*numbits_datain-1:0] raw_raw_2x_bit_frame;
  output logic [2*numbits_datain-1:0] intermediate_data[num_data_channels];
  output logic [2*numbits_datain-1:0] intermediate_frame;
  input  [log2(numbits_datain)-1:0]  intermediate_frame_select;
  input  transpose_2xbit_data_bits;
  input  transpose_channel_data_halves;
  input  [lock_wait_counter_bits-1:0] lock_wait;
  output logic reframer_is_locked;
  output logic [lock_wait_counter_bits-1:0] lock_wait_counter;
  output [3:0] lock_wait_machine_state_num;
  input  enable_lock_scan;
  output clear_scan_counter;
  output inc_scan_counter;

genvar channel_num;
generate
			for (channel_num = 0; channel_num < num_data_channels; channel_num++)
			begin : generate_data_in
					Serial_Markov_Sequence_Generator
					#(
					  .LFSR_LENGTH(15),
					  .lfsr_init_val(channel_num+1)
					)
					Markov_PN15_Serial_gen_inst
					(
					  .LFSR_Transition_Matrix(225'b100000000000001100000000000000010000000000000001000000000000000100000000000000010000000000000001000000000000000100000000000000010000000000000001000000000000000100000000000000010000000000000001000000000000000100000000000000010),
					  .clk(frame_clk),
					  .lfsr(data_in[channel_num]),
					  .reset(!reset),
					  .serial_output(),
					  .reverse_serial_output()
					);

					always @(posedge frame_clk)
					begin
						 intermediate_data[channel_num] <= {intermediate_data[channel_num][numbits_datain-1:0],data_in[channel_num]};
					end

					data_chooser_according_to_frame_position 
					#(
					   .numbits_dataout(numbits_datain)
					 )
					data_chooser_according_to_frame_position_inst 
					(
					 .data_reg_contents(intermediate_data[channel_num]),
					 .selection_value(intermediate_frame_select),
					 .selected_data_reg_contents(actual_data_in[channel_num]),
					 .clk(frame_clk)
					);
			end
endgenerate

assign intermediate_frame = {{(numbits_datain/2){1'b1}},{(numbits_datain/2){1'b0}},{(numbits_datain/2){1'b1}},{(numbits_datain/2){1'b0}}};

data_chooser_according_to_frame_position 
#(
   .numbits_dataout(numbits_datain)
 )
frame_chooser_according_to_frame_position_inst 
(
 .data_reg_contents(intermediate_frame),
 .selection_value(intermediate_frame_select),
 .selected_data_reg_contents(frame_sampled_clock_in),
 .clk(frame_clk)
);



multi_channel_generic_reframer
#(
.lock_wait_counter_bits(lock_wait_counter_bits),
.numbits_datain(numbits_datain),
.num_data_channels(num_data_channels)
)
multi_channel_generic_reframer_inst
(
.data_in(actual_data_in),
  .*
);

endmodule
`default_nettype wire
