module test_multiple_parallel_output_lfsrs_with_clk_enable
#(
parameter [31:0] NUM_LFSRS = 3,
parameter [31:0] MAX_LFSR_WIDTH = 9,
parameter [31:0] NUM_OUTPUT_BITS = 10,
parameter bit [31:0] LFSR_WIDTHS[NUM_LFSRS] = '{3, 7, 9},
parameter bit [MAX_LFSR_WIDTH-1:0] FEEDBACK_TAPS[NUM_LFSRS] =  '{3'b010, 7'b0100000, 9'b000010000},
parameter bit [MAX_LFSR_WIDTH-1:0] INITIAL_LFSR_VALS[NUM_LFSRS] = '{NUM_LFSRS{1'b1}}
)
(
output  logic   [MAX_LFSR_WIDTH-1:0]  in_vector[NUM_LFSRS],
output  logic   [NUM_OUTPUT_BITS-1:0] out_data[NUM_LFSRS],
input do_not_transpose_output_data,
input clk,
input reset,
input in_vector_clock_enable,
input out_data_clock_enable
);

multiple_parallel_output_lfsrs_with_clk_enable
#(
.NUM_LFSRS                   (NUM_LFSRS                   ),
.MAX_LFSR_WIDTH              (MAX_LFSR_WIDTH              ),
.NUM_OUTPUT_BITS             (NUM_OUTPUT_BITS             ),
.LFSR_WIDTHS                 (LFSR_WIDTHS                 ),
.FEEDBACK_TAPS               (FEEDBACK_TAPS               ),
.INITIAL_LFSR_VALS           (INITIAL_LFSR_VALS           )
)
multiple_parallel_output_lfsrs_with_clk_enable_inst
(
.*
);

endmodule
