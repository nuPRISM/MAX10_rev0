`default_nettype none
module ddr_output_register_emulate
#(
parameter numbits = 1
)
(
input  in_clk,
input  in_clk_x2,
input  [numbits-1:0] indata_posedge,
input  [numbits-1:0] indata_negedge,
output logic  [numbits-1:0] outdata
);


always @(posedge in_clk_x2)
begin
      if (in_clk)
      begin
	        outdata <= indata_negedge;
	  end else
	  begin
	        outdata <= indata_posedge
	  end	  
end

endmodule
`default_nettype wire