`default_nettype none
module calculate_parity
#(
parameter width = 8
)
(
input clk,
input [width-1:0] data_in,
output [width:0] data_out,
input use_even_parity
);

always @(posedge clk)
begin
   data_out <= {(use_even_parity^(^data_in)),data_in};
end

endmodule

`default_nettype wire
