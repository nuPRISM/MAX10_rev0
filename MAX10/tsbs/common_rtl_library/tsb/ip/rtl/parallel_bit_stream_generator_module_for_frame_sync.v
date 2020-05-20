module parallel_bit_stream_generator_module_for_frame_sync
#(
parameter atrophy_everything_to_save_space=0,
parameter log2_numbitstreams=4,
parameter numbitstreams=16,
parameter user_seq_bit_pattern_length = 24,
parameter user_seq_bit_pattern_counter_width = 5,
parameter output_width = 10,
parameter log2_output_width = 4
)
(
input clk,
input sm_clk,
output reg [output_width-1:0] out_bit_stream,
output wire [numbitstreams-1:0] all_finish,
output[output_width-1:0] all_bit_streams[numbitstreams-1:0],
input [log2_numbitstreams-1:0] sel_output_bitstream,
input [user_seq_bit_pattern_length-1:0] user_bit_pattern,
input [output_width-1:0] external_sequence,
input [output_width-1:0] pattern_to_output_for_atrophied_generation,

output finish
);

wire Parallel_LFSR_Start;

async_trap_and_reset 
make_start_sig
(.async_sig(clk), 
.outclk(sm_clk), 
.out_sync_sig(Parallel_LFSR_Start), 
.auto_reset(1'b1), 
.reset(1'b1));

  assign finish = Parallel_LFSR_Start;
  always @ (posedge clk)
  begin
		   out_bit_stream <= pattern_to_output_for_atrophied_generation;
  end
			
endmodule		