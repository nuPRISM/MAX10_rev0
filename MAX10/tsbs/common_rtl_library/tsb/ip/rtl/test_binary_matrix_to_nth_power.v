module test_binary_matrix_to_nth_power
(
 output logic [3-1:0] in_matrix3[3] 
 ,output logic [7-1:0] in_matrix7[7] 
 //,output logic [9-1:0] in_matrix9[9] 
 , output logic [3-1:0] out_matrix3[3]  
 , output logic [7-1:0] out_matrix7[7]  
 //, output logic [9-1:0] out_matrix9[9]  
);


assign in_matrix3 = '{
                     3'b101,
                     3'b100,
                     3'b010
                     };					 
     
     assign in_matrix7 = '{
   7'b1000001,
   7'b1000000,
   7'b0100000,
   7'b0010000,
   7'b0001000,
   7'b0000100,
   7'b0000010
                     };	
                     
                   // assign in_matrix9 = '{
                   // 3'b101,
                   // 3'b100,
                   // 3'b010
                   // };	                 


binary_matrix_to_nth_power
#(
 .MATRIX_NUMROWS(3),
 .N(6)
)
make_lfsr_3_transition_matrix
(
  .in_matrix(in_matrix3),
  .out_matrix(out_matrix3) 
);

binary_matrix_to_nth_power
#(
 .MATRIX_NUMROWS(7),
 .N(6)
)
make_lfsr_7_transition_matrix
(
  .in_matrix(in_matrix7),
  .out_matrix(out_matrix7) 
);


endmodule
