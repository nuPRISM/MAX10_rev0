module to_fast_clk_interface(indata,outdata,inclk,outclk);
//the purpose of this module is to ensure that the CE of the 
//output data does not change near the output clock to avoid a race.
//inclk must be much slower than outclk

parameter width = 32;
input [width-1:0]  indata;
output [width-1:0] outdata;
input inclk,outclk;


reg[width-1:0] outdata;
reg actual_CE;
reg clk_delay1,clk_delay2;

always @ (negedge outclk)
begin
		actual_CE <= clk_delay2;
end

always @ (posedge outclk)
begin
		clk_delay1 <= inclk;
		clk_delay2 <= clk_delay1;
end

always @ (posedge outclk)
begin
      if (actual_CE)
		begin
			  outdata <= indata;
		end
end

endmodule
