`default_nettype none

module append_two_parity_bits
#(
parameter width = 8
)
(
input clk,
input [width-1:0] data_in,
output [width+1:0] data_out,
input use_even_parity
);

calculate_parity
#(
.width(width/2)
)
calculate_parity_lower_half
(.clk(clk),
.data_in(data_in[width/2-1:0]),
.data_out({data_out[width],data_out[width/2-1:0]}),
.use_even_parity(use_even_parity)
);

calculate_parity
#(
.width(width/2)
)
calculate_parity_upper_half
(.clk(clk),
.data_in(data_in[width-1 -:width/2]),
.data_out({data_out[width+1],data_out[width-1 -:width/2]}),
.use_even_parity(use_even_parity)
);

endmodule
`default_nettype wire

