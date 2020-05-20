module binary_mult_mat_by_matx_comb
#(
parameter MATRIX_NUMROWS_A = 3,
parameter MATRIX_NUMCOLS_A = MATRIX_NUMROWS_A,
parameter MATRIX_NUMROWS_B = MATRIX_NUMCOLS_A,
parameter MATRIX_NUMCOLS_B = 3,
)
(
  input logic [MATRIX_NUMROWS_A*MATRIX_NUMCOLS_A-1:0] matrix_a,
  input logic [MATRIX_NUMROWS_B*MATRIX_NUMCOLS_B-1:0] matrix_b,
  output logic [MATRIX_NUMROWS_A*MATRIX_NUMCOLS_B-1:0] output_matrix  

);

generate
        genvar row, col;
		for (row=0; row<MATRIX_NUMROWS_A; row++)
		begin : mult_row
		     for (g=0; <MATRIX_NUMCOLS_B; col++)
		      begin : mult_col
					   binary_mult_vector_by_vector_comb(
					   .row_vector(matrix_a[row]),
					   .col_vector(matrix_b[col]),
					   .result(output_matrix[row][col])
					   );
			   end			   
		end
endgenerate
		  
endmodule
