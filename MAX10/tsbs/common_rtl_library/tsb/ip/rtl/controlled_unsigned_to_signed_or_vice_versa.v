module controlled_unsigned_to_signed_or_vice_versa
#(
parameter width = 8
)
(
input [width-1:0] in,
output [width-1:0] out,
input change_format
);

assign out = {(change_format ^ in[width-1]),in[width-2 : 0]};

endmodule
