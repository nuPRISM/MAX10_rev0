`default_nettype none

module extract_two_parity_bits_comb
#(
parameter data_in_width = 16,
parameter data_out_width = data_in_width-2
)
(
input  [data_in_width-1:0] data_in,
output logic [data_out_width-1:0] data_out,
output logic [1:0] parity_out
);

always_comb
begin
   parity_out = data_in[data_in_width-1 -: 2];
   data_out = data_in[data_out_width-1:0];
end

endmodule
`default_nettype wire

