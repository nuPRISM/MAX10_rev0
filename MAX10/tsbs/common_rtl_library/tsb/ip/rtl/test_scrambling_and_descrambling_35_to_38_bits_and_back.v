module test_scrambling_and_descrambling_35_to_38_bits_and_back
(
input [34:0] data_in,
output [34:0] data_out,
output [37:0] scrambled_data,
input bypass,
input clk
);



scrambler_35_to_38_bits
scrambler_35_to_38_bits_inst
(
.data_in(data_in),
.data_out(scrambled_data),
.clk(clk),
.bypass(bypass),
.chosen_scramble_word()
);

descrambler_38_to_35_bits
descrambler_38_to_35_bits_inst
(
.scrambled_data_in(scrambled_data),
.descrambled_data_out(data_out),
.clk(clk),
.bypass(bypass),
.chosen_descramble_word()
);

endmodule
