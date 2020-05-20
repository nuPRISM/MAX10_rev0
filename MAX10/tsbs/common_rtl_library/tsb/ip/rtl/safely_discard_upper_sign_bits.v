module safely_discard_upper_sign_bits
#(
  parameter inwidth = 16,
  parameter number_of_bits_to_discard = 1,
  parameter outwidth = 8
 )
 (
  input [inwidth-1:0] indata,
  output [outwidth-1:0] outdata
  );
  
  wire [outwidth-1:0] outdata_raw = {indata[inwidth-1], indata[inwidth-2-number_of_bits_to_discard -: (outwidth-1)]};
  wire [number_of_bits_to_discard-1:0] discarded_bits = indata[inwidth-2 -: number_of_bits_to_discard];
  wire sign_bit = indata[inwidth-1];
  wire overflow_situation_occurred = (|(discarded_bits ^{number_of_bits_to_discard{sign_bit}})) | (outdata_raw == {1'b1,{(outwidth-1){1'b0}}});
  wire [outwidth-1:0] overflow_output_value = {sign_bit,{(outwidth-2){~sign_bit}},1'b1}; //avoid unsymmetric 2's complemente range
  
  assign outdata = overflow_situation_occurred ? overflow_output_value : outdata_raw;
 
 endmodule