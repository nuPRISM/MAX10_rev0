`default_nettype none
module ddr_input_register_emulate
#(
parameter numbits = 1
)
(
input  in_clk,
input  in_clk_shifted_270_degrees,
input  in_clk_div2,
input  [numbits-1:0] indata,
output logic  [2*numbits-1:0] outdata,

);


always @(posedge in_clk)
begin
      if (in_clk_shifted_270_degrees)
      begin
	        outdata_raw[numbits-1:0] <= indata;
	  end else
	  begin
	       outdata_raw[2*numbits-1:numbits] <= indata;
	  end	  
end

always @(posedge in_clk_div2)
begin
      if (in_clk)
      begin
	        outdata <= outdata_raw;
	  end  
end

endmodule
`default_nettype wire