module generate_multi_parallel_powered_matrix_mults_comb
#(
parameter MATRIX_NUMROWS = 3,
parameter NUM_OUTPUT_BITS = 10,
parameter N_PER_STAGE = MATRIX_NUMROWS,
parameter ROUND_DOWN_NUM_MATRICES =  NUM_OUTPUT_BITS/MATRIX_NUMROWS,
parameter NUM_MATRICES = (ROUND_DOWN_NUM_MATRICES*MATRIX_NUMROWS >= NUM_OUTPUT_BITS) ? ROUND_DOWN_NUM_MATRICES : (ROUND_DOWN_NUM_MATRICES+1)
)
(
input  logic [MATRIX_NUMROWS-1:0] in_vector,
input  logic [MATRIX_NUMROWS-1:0] the_matrix[MATRIX_NUMROWS],
output  logic [MATRIX_NUMROWS-1:0] exact_out_matrix[MATRIX_NUMROWS],
output logic [MATRIX_NUMROWS-1:0] out_vectors[NUM_MATRICES],
output  logic [MATRIX_NUMROWS-1:0] the_matrix_to_desired_power[NUM_MATRICES][MATRIX_NUMROWS],
output logic [NUM_OUTPUT_BITS-1:0] out_data,
output logic [NUM_MATRICES*MATRIX_NUMROWS-1:0] raw_out_data,
input logic do_not_transpose_output_data,
output logic [MATRIX_NUMROWS-1:0] next_in_vector
);

genvar num_matrix;
generate
          for (num_matrix = 0; num_matrix < NUM_MATRICES; num_matrix++)
		  begin: make_output_chunk	
		  
					binary_matrix_to_nth_power
					#(
					 .MATRIX_NUMROWS(MATRIX_NUMROWS),
					 .N(N_PER_STAGE*(num_matrix+1))
					)
					make_current_mult_matrix
					(
					  .in_matrix(the_matrix),
					  .out_matrix(the_matrix_to_desired_power[num_matrix]) 
					);
					
					binary_mult_vector_by_matrix_comb
					#(
					.VECTOR_LENGTH(MATRIX_NUMROWS),
                    .MATRIX_NUMROWS(MATRIX_NUMROWS)				
					)
					make_out_vector
					(
					.the_input_vector(in_vector),
					.the_matrix(the_matrix_to_desired_power[num_matrix]),
					.the_output_vector(out_vectors[num_matrix])
					);
					
					combinatorial_controlled_transpose
					#(
					.numbits(MATRIX_NUMROWS)
					)
					combinatorial_controlled_transpose_inst
					(
					.indata(out_vectors[num_matrix]),
					.outdata(raw_out_data[(num_matrix+1)*MATRIX_NUMROWS-1 -: MATRIX_NUMROWS]),
					.transpose(!do_not_transpose_output_data)
					);
		  end
		  
endgenerate


assign out_data = raw_out_data;

binary_matrix_to_nth_power
#(
 .MATRIX_NUMROWS(MATRIX_NUMROWS),
 .N(NUM_OUTPUT_BITS)
)
make_exact_out_matrix
(
  .in_matrix(the_matrix),
  .out_matrix(exact_out_matrix) 
);

binary_mult_vector_by_matrix_comb
#(
.VECTOR_LENGTH(MATRIX_NUMROWS),
.MATRIX_NUMROWS(MATRIX_NUMROWS)				
)
make_next_in_vector
(
.the_input_vector(in_vector),
.the_matrix(exact_out_matrix),
.the_output_vector(next_in_vector)
);


endmodule

