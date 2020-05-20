module combinatorial_controlled_transpose
#(
parameter numbits = 32
)
(
input [numbits-1:0] indata,
output reg [numbits-1:0] outdata,
input transpose
);

always_comb
begin
      if (transpose)
	  begin
	       for (int i = 0; i < numbits; i++)
		   begin
	            outdata[i] = indata[numbits-1-i];
           end						   
	  end else
	  begin
		  outdata = indata;
	  end
end	

endmodule
