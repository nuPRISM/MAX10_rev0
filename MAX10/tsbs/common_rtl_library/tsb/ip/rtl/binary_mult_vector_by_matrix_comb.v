module binary_mult_vector_by_matrix_comb
#(
parameter VECTOR_LENGTH = 3,
parameter MATRIX_NUMROWS = VECTOR_LENGTH
)
(
  input logic [VECTOR_LENGTH-1:0] the_matrix[MATRIX_NUMROWS],
  output logic [MATRIX_NUMROWS-1:0] the_output_vector,
  output logic [VECTOR_LENGTH-1:0] the_transposed_input_vector,
  input logic [VECTOR_LENGTH-1:0] the_input_vector

);

combinatorial_controlled_transpose
#(
.numbits(VECTOR_LENGTH)
)
combinatorial_controlled_transpose_inst
(
.indata(the_input_vector),
.outdata(the_transposed_input_vector),
.transpose(1'b1)
);

generate
        genvar i;
		for (i=0; i<MATRIX_NUMROWS; i++)
		begin : mult_vector
		    assign the_output_vector[i] = ^(the_matrix[i] & the_transposed_input_vector);
		end
endgenerate
		  
endmodule
