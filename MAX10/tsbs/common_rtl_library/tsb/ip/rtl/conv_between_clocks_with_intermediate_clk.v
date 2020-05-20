`default_nettype none
module conv_between_clocks_with_intermediate_clk(
indata,
outdata,
inclk,
outclk,
intermediate_clk,
intermediate_data,
actual_ce_conv_up,
actual_ce_conv_down
);
//convert from inclk to outclk using intermediate clock. Intermediate clock should be at least 5x of highest frequency of inclk or outclk

parameter width = 32;
input [width-1:0]  indata;
output [width-1:0] outdata;
output reg [width-1:0] intermediate_data;
input inclk,intermediate_clk,outclk;
output actual_ce_conv_up;
output actual_ce_conv_down;


to_fast_clk_interface_better
conv_in_clk_to_intermediate_clock
(
.indata(indata),
.outdata(intermediate_data),
.inclk(inclk),
.outclk(intermediate_clk),
.actual_CE(actual_ce_conv_up)
);

to_slow_clk_interface_better
conv_from_intermediate_clock_to_outclk
(
.indata(intermediate_data),
.outdata(outdata),
.inclk(intermediate_clk),
.outclk(outclk),
.actual_CE(actual_ce_conv_down)
);

endmodule
`default_nettype none