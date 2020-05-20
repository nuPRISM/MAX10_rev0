module signed_bigger_than(A,B,result);

parameter width = 32;
input [width-1:0] A,B;
output result;

reg result; //note that result is synthesized as a wire
wire sign_A = A[width-1];
wire sign_B = B[width-1];


always @(A or B or sign_A or sign_B)
begin
	  case ({sign_A,sign_B})
	  		 2'b00: result <= (A>B);
			 2'b10: result <= 0;
			 2'b01: result <= 1;
			 2'b11: result <= ((~A)<(~B));
	  endcase
end

endmodule
