
`include "log2_function.v"

module parallel_bit_stream_generator_fast
#(
    parameter numbitstreams=16,
    parameter log2_numbitstreams=log2(numbitstreams),
    parameter output_width = 10,
    parameter log2_output_width = log2(output_width),
    parameter user_seq_bit_pattern_length = 24,
    parameter user_seq_bit_pattern_counter_width = 5,
	parameter [7:0] counter_bits = 8,
	parameter [31:0] NUM_LFSRS = 3,
	parameter [31:0] MAX_LFSR_WIDTH = 9,
	parameter [31:0] NUM_OUTPUT_BITS = output_width,
	parameter bit [31:0] LFSR_WIDTHS[NUM_LFSRS] = '{3, 7, 9},
	parameter bit [MAX_LFSR_WIDTH-1:0] FEEDBACK_TAPS[NUM_LFSRS] =  '{3'b010, 7'b0100000, 9'b000010000},
	parameter bit [MAX_LFSR_WIDTH-1:0] INITIAL_LFSR_VALS[NUM_LFSRS] = '{NUM_LFSRS{1'b1}},
	parameter START_INDEX_OF_PN_SEQUENCES = numbitstreams/2
)
(
output logic [output_width-1:0] out_bit_stream,
output logic [output_width-1:0] all_bit_streams[numbitstreams],
input do_not_transpose_output_data,
input clk,
input reset,
input start,
input [counter_bits-1:0] wait_count,
output logic finish,
input [log2_numbitstreams-1:0] sel_output_bitstream,
input [user_seq_bit_pattern_length-1:0] user_bit_pattern,
input [output_width-1:0] external_sequence,
input [output_width-1:0] pattern_to_output_for_atrophied_generation,

//debugging
output logic in_vector_clock_enable,
output logic out_data_clock_enable,
output logic  [counter_bits-1:0] counter = 0,
output logic  reset_counter,
output logic  cnt_en,
output logic [15:0] state,
output logic raw_finish,
output  logic   [MAX_LFSR_WIDTH-1:0]  in_vector[NUM_LFSRS],
output  logic   [NUM_OUTPUT_BITS-1:0] out_data[NUM_LFSRS]
);

genvar i;
generate
         for (i = START_INDEX_OF_PN_SEQUENCES; i < START_INDEX_OF_PN_SEQUENCES+NUM_LFSRS; i++)
		 begin : assign_lfsr_outputs_to_streams
		       assign all_bit_streams[i] = out_data[i-START_INDEX_OF_PN_SEQUENCES];
		 end
endgenerate

assign all_bit_streams[0] = pattern_to_output_for_atrophied_generation;

always @ (posedge clk)
begin     
      out_bit_stream <= all_bit_streams[sel_output_bitstream];
      finish <= raw_finish;
end

parallel_multiple_parallel_output_lfsrs_w_sm
#(
.counter_bits                (counter_bits                ),
.NUM_LFSRS                   (NUM_LFSRS                   ),
.MAX_LFSR_WIDTH              (MAX_LFSR_WIDTH              ),
.NUM_OUTPUT_BITS             (NUM_OUTPUT_BITS             ),
.LFSR_WIDTHS                 (LFSR_WIDTHS                 ),
.FEEDBACK_TAPS               (FEEDBACK_TAPS               ),
.INITIAL_LFSR_VALS           (INITIAL_LFSR_VALS           )
)
parallel_multiple_parallel_output_lfsrs_w_sm_inst
(
.*,
.finish(raw_finish)
);

endmodule		