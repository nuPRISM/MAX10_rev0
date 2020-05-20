`default_nettype none
module calculate_parity_comb
#(
parameter width = 8
)
(
input [width-1:0] data_in,
output [width:0] data_out,
output parity,
input use_even_parity
);

always_comb
begin
   parity = use_even_parity^(^data_in);
   data_out = {parity,data_in};
end

endmodule

`default_nettype wire
