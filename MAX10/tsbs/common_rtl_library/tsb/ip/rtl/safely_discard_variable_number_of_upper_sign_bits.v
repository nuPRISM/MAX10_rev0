module safely_discard_variable_number_of_upper_sign_bits
#(
  parameter inwidth = 16,
  parameter outwidth = 8,
  parameter discard_control_bits = 8
 )
 (
  input [inwidth-1:0] indata,
  output [outwidth-1:0] outdata,
  input [discard_control_bits-1:0] number_of_bits_to_discard,
  output logic [outwidth-1:0] overflow_output_value[inwidth-1:0],
  output logic [outwidth-1:0] outdata_raw[inwidth-1:0],
  output logic overflow_situation_occurred[inwidth-1:0],
  output overflow_is_occurring_now  
  );
   wire sign_bit = indata[inwidth-1];
               
  genvar current_numbits_to_discard;
  generate           
           //for (current_numbits_to_discard = 0; current_numbits_to_discard < inwidth-1; current_numbits_to_discard++)
		   for (current_numbits_to_discard = 0; current_numbits_to_discard < inwidth-2-(outwidth-1); current_numbits_to_discard++)
		     begin : out_data_generation
                assign outdata_raw[current_numbits_to_discard] = {indata[inwidth-1], indata[inwidth-2-current_numbits_to_discard -: (outwidth-1)]};
                wire [current_numbits_to_discard-1:0] discarded_bits = indata[inwidth-2 -: current_numbits_to_discard];
                assign overflow_situation_occurred[current_numbits_to_discard] = (current_numbits_to_discard == 0) ? 
					 (outdata_raw[current_numbits_to_discard] == {1'b1,{(outwidth-1){1'b0}}}) : ((|(discarded_bits ^{current_numbits_to_discard{sign_bit}})) | (outdata_raw[current_numbits_to_discard] == {1'b1,{(outwidth-1){1'b0}}}));
                assign overflow_output_value[current_numbits_to_discard] = {sign_bit,{(outwidth-2){~sign_bit}},1'b1}; //avoid unsymmetric 2's complemente range
		    end
 endgenerate
 
 assign overflow_is_occurring_now = overflow_situation_occurred[number_of_bits_to_discard];
 assign outdata = ( overflow_is_occurring_now ? 
 overflow_output_value[number_of_bits_to_discard] : outdata_raw[number_of_bits_to_discard]); 
  
 endmodule
 