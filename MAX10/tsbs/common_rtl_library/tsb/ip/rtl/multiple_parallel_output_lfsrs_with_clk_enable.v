module multiple_parallel_output_lfsrs_with_clk_enable
#(
parameter [31:0] NUM_LFSRS = 2,
parameter [31:0] MAX_LFSR_WIDTH = 3,
parameter [31:0] NUM_OUTPUT_BITS = 10,
parameter bit [31:0] LFSR_WIDTHS[NUM_LFSRS] = '{NUM_LFSRS{MAX_LFSR_WIDTH}},
parameter bit [MAX_LFSR_WIDTH-1:0] FEEDBACK_TAPS[NUM_LFSRS] =  '{NUM_LFSRS{3'b010}},
parameter bit [MAX_LFSR_WIDTH-1:0] INITIAL_LFSR_VALS[NUM_LFSRS] = '{NUM_LFSRS{3'b001}}
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

genvar i;
generate
         for (i = 0; i < NUM_LFSRS; i++)
		 begin : make_lfsrs		 
				parallel_output_lfsr_with_clk_enable
				#(
				.LFSR_WIDTH         (LFSR_WIDTHS[i]     ),
				.NUM_OUTPUT_BITS    (NUM_OUTPUT_BITS    ),
				.FEEDBACK_TAPS      (FEEDBACK_TAPS[i]   ),
				.INITIAL_LFSR_VAL   (INITIAL_LFSR_VALS[i]),
				.INITIAL_OUTDATA_VAL(0)
				)
				parallel_output_lfsr_with_clk_enable_inst
				(
				 .in_vector(in_vector[i]),
				 .out_data(out_data[i]),				 
                 .clk,
                 .reset,
                 .in_vector_clock_enable,
                 .out_data_clock_enable,
				 .do_not_transpose_output_data
				);		 
		 end
endgenerate

endmodule
