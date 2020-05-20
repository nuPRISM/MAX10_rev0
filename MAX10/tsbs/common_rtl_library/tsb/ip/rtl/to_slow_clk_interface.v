module to_slow_clk_interface(indata,outdata,inclk,outclk);
//the purpose of this module is to ensure that the CE of the 
//output data does not change near the output clock to avoid a race.
//inclk must be much faster than outclk

parameter width = 32;
input [width-1:0]  indata;
output [width-1:0] outdata;
input inclk,outclk;


reg[width-1:0] outdata, raw_outdata;
wire  actual_CE;
reg clk_delay1,clk_delay2;

always @ (negedge inclk)
begin
		clk_delay1 <= outclk;
		clk_delay2 <= clk_delay1;
end

assign actual_CE  = clk_delay2;

always @ (posedge inclk)
begin
      if (actual_CE)
		begin
			  raw_outdata <= indata;
		end
end


always @ (posedge outclk)
begin
      outdata <= raw_outdata;
end
endmodule
