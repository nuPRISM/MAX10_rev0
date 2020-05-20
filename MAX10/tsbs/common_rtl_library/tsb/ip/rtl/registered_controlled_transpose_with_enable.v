module registered_controlled_transpose_with_enable
#(
parameter numbits = 32
)
(
input [numbits-1:0] indata,
output reg [numbits-1:0] outdata,
input clk,
input enable,
input transpose
);

always @(posedge clk)
begin
      if (enable)
	  begin
			  if (transpose)
			  begin
				   for (int i = 0; i < numbits; i++)
				   begin
						outdata[i] <= indata[numbits-1-i];
				   end						   
			  end else
			  begin
				  outdata <= indata;
			  end
	  end
end	

endmodule
