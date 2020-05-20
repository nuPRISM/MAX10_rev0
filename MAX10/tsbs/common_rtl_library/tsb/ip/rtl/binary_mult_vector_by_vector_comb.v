module binary_mult_vector_by_vector_comb
#(
parameter VECTOR_LENGTH = 3
)
(
  input logic [VECTOR_LENGTH-1:0] row_vector,
  input logic [VECTOR_LENGTH-1:0] col_vector,
  output logic result

);

assign result = ^(row_vector & col_vector);

endmodule

