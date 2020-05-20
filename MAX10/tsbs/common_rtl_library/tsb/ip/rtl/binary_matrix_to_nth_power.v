module binary_matrix_to_nth_power
#(
parameter MATRIX_NUMROWS = 3,
parameter N = 2
)
(
  input logic [MATRIX_NUMROWS-1:0] in_matrix[MATRIX_NUMROWS],
  output logic [MATRIX_NUMROWS-1:0] out_matrix[MATRIX_NUMROWS]  
);

logic [MATRIX_NUMROWS-1:0] intermediate_matrix[N][MATRIX_NUMROWS];

assign intermediate_matrix[0] = in_matrix;

generate
        genvar n;
		for (n=1; n<N; n++)
		begin : make_intermediate_matrix
		    logic [MATRIX_NUMROWS-1:0] multiplier_matrix[MATRIX_NUMROWS];
		   
		    binary_matrix_other_diag_transpose_comb
			#(
			.MATRIX_NUMROWS(MATRIX_NUMROWS),
			.MATRIX_NUMCOLS(MATRIX_NUMROWS)
			)
			generate_multiplier_matrix
			(
			.in_matrix(intermediate_matrix[n-1]),
			.out_matrix(multiplier_matrix)  
			);

			//assign multiplier_matrix = intermediate_matrix[n-1]
			binary_mult_matrix_by_matrix_comb
			#(
			.MATRIX_NUMROWS_A(MATRIX_NUMROWS),
			.MATRIX_NUMCOLS_A(MATRIX_NUMROWS),
			.MATRIX_NUMROWS_B(MATRIX_NUMROWS),
			.MATRIX_NUMCOLS_B(MATRIX_NUMROWS)
			)
			mult_matrices
			(
			  .matrix_a(in_matrix),
			  .matrix_b(multiplier_matrix),
			  .output_matrix(intermediate_matrix[n])  
			);

		end
endgenerate
assign out_matrix = intermediate_matrix[N-1];

endmodule
