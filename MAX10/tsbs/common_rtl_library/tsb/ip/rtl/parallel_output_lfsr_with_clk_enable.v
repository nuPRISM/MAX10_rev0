module parallel_output_lfsr_with_clk_enable
#(
parameter LFSR_WIDTH = 3,
parameter NUM_OUTPUT_BITS = 10,
parameter [LFSR_WIDTH-1:0] FEEDBACK_TAPS = 3'b010,
parameter [LFSR_WIDTH-1:0] INITIAL_LFSR_VAL = 3'b001,
parameter [NUM_OUTPUT_BITS-1:0] INITIAL_OUTDATA_VAL = 0
)
(
output  reg   [LFSR_WIDTH-1:0] in_vector = INITIAL_LFSR_VAL,
output  logic [NUM_OUTPUT_BITS-1:0] out_data,
output  logic [NUM_OUTPUT_BITS-1:0] raw_out_data,
output  logic [LFSR_WIDTH-1:0] transition_matrix[LFSR_WIDTH],
output  logic [LFSR_WIDTH-1:0] exact_out_matrix[LFSR_WIDTH],
output  logic [LFSR_WIDTH-1:0] next_in_vector,
input do_not_transpose_output_data,
input clk,
input reset,
input in_vector_clock_enable,
input out_data_clock_enable
);

make_lfsr_transition_matrix_comb
#(
.N(LFSR_WIDTH)
)
make_matrix3
(
  .the_matrix(transition_matrix),
  .feedback_taps(FEEDBACK_TAPS)
);

                      
always_ff @(posedge clk)
begin
       if (reset)
	   begin
               in_vector <= INITIAL_LFSR_VAL;
	   end
       else
	   begin  
	          if (in_vector_clock_enable)
			  begin
                   in_vector <=  (in_vector == 0) ? INITIAL_LFSR_VAL : next_in_vector;
			  end
	   end	
end
always_ff @(posedge clk)
begin
       if (reset)
	   begin
 	         out_data <= INITIAL_OUTDATA_VAL;
	   end
       else
	   begin  
	          if (out_data_clock_enable)
			  begin
                   out_data <=  raw_out_data;
			  end
	   end	
end

//assign in_vector = 1;

generate_multi_parallel_powered_matrix_mults_comb
#(
.MATRIX_NUMROWS(LFSR_WIDTH),
.NUM_OUTPUT_BITS(NUM_OUTPUT_BITS)
)
generate_multi_parallel_powered_matrix_mults_comb_inst
(
.in_vector(in_vector),
.the_matrix(transition_matrix),
.exact_out_matrix(exact_out_matrix),
.out_vectors(),
.the_matrix_to_desired_power(),
.out_data(raw_out_data),
.raw_out_data(),
.do_not_transpose_output_data(do_not_transpose_output_data),
.next_in_vector(next_in_vector)
);

endmodule
