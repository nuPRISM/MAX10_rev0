`default_nettype none

module extract_two_parity_bits
#(
parameter data_in_width = 16,
parameter data_out_width = data_in_width-2
)
(
input clk,
input  [data_in_width-1:0] data_in,
output logic [data_out_width-1:0] data_out,
output logic [1:0] parity_out
);

always @(posedge clk)
begin
   parity_out <= data_in[data_in_width-1 -: 2];
   data_out <= data_in[data_out_width-1:0];
end

endmodule
`default_nettype wire

