module make_lfsr_transition_matrix_comb
#(
parameter N = 3
)
(
  output logic [N-1:0] the_matrix[N],
  input  logic [N-1:0] feedback_taps
);

generate
        genvar row,col;
		for (row=0; row<N; row++)
		begin : make_rows
			for (col=0; col<N; col++)
			begin : make_cols
			        if (row == 0)
					begin
					      if (col == N-1)
						  begin
						   assign the_matrix[row][N-1-col] = 1;
						  end else
						  begin
				            assign the_matrix[row][N-1-col] = feedback_taps[N-2-col];
						  end
					end else
					begin
					        if ((row > 0) && (col == row-1)) 
							begin
							      assign the_matrix[row][N-1-col] = 1;
							end
					end
			end
		end
endgenerate
		  
endmodule
