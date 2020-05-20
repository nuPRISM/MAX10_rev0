module sign_extend_and_amplify #(parameter indata_width = 8,
parameter outdata_width = 14)
(input [indata_width-1:0] indata, 
output [outdata_width-1:0] outdata);

 

localparam bits_to_sign_extend = outdata_width-indata_width;
localparam bits_to_sign_extend_minus_1 = bits_to_sign_extend-1;
wire [bits_to_sign_extend-1:0] sign_extension_LSBs = {{bits_to_sign_extend_minus_1{~indata[indata_width-1]}},indata[indata_width-1]};

generate
			if (outdata_width <= indata_width)
			    assign outdata = indata[indata_width-1 -:outdata_width];
			else
				assign outdata = {indata,sign_extension_LSBs};
endgenerate
endmodule