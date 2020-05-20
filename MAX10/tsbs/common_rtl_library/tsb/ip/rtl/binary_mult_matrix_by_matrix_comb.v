module binary_mult_matrix_by_matrix_comb
#(
parameter MATRIX_NUMROWS_A = 3,
parameter MATRIX_NUMCOLS_A = MATRIX_NUMROWS_A,
parameter MATRIX_NUMROWS_B = MATRIX_NUMCOLS_A,
parameter MATRIX_NUMCOLS_B = 3
)
(
  input logic [MATRIX_NUMCOLS_A-1:0] matrix_a[MATRIX_NUMROWS_A],
  input logic [MATRIX_NUMROWS_B-1:0] matrix_b[MATRIX_NUMCOLS_B],
  output logic [MATRIX_NUMCOLS_B-1:0] output_matrix[MATRIX_NUMROWS_A]  

);

generate
        genvar row, col;
		for (row=0; row<MATRIX_NUMROWS_A; row++)
		begin : mult_row
		     for (col=0; col<MATRIX_NUMCOLS_B; col++)
		      begin : mult_col
					   binary_mult_vector_by_vector_comb
					   #(
			           .VECTOR_LENGTH(MATRIX_NUMCOLS_A)			           
			           )
					   binary_mult_vector_by_vector_comb_inst(
					   .row_vector(matrix_a[row]),
					   .col_vector(matrix_b[col]),
					   .result(output_matrix[row][col])
					   );
			   end			   
		end
endgenerate
		  
endmodule
