module binary_matrix_transpose_comb
#(
parameter MATRIX_NUMROWS = 3,
parameter MATRIX_NUMCOLS = MATRIX_NUMROWS
)
(
  input logic [MATRIX_NUMCOLS-1:0] in_matrix[MATRIX_NUMROWS],
  output logic [MATRIX_NUMROWS-1:0] out_matrix[MATRIX_NUMCOLS]
  
);
generate
        genvar row, col;
		for (row=0; row<MATRIX_NUMROWS; row++)
		begin : make_row
		     for (col=0; col<MATRIX_NUMCOLS; col++)
		      begin : make_col
				    assign out_matrix[col][row] = in_matrix[row][col];
			  end			   
		end
endgenerate

endmodule