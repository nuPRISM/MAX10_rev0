
module descrambler_38_to_35_bits
#(
parameter scramble_word1 = 35'h3C14FE162,
parameter scramble_word2 = 35'h018601CBA,
parameter scramble_word3 = 35'h2B26D5B63,
parameter scramble_word4 = 35'h14C263CED,
parameter scramble_word5 = 35'h65AB1DA6E,
parameter scramble_word6 = 35'h27D5E4FDC,
parameter scramble_word7 = 35'h43A6F949E
)
(
input  logic [37:0] scrambled_data_in,
output logic [34:0] descrambled_data_out,
input  clk,
input  bypass,
output logic [2:0] chosen_descramble_word
);

logic [37:0] pipelined_data_in;

always_ff @(posedge clk)
begin
      pipelined_data_in <= scrambled_data_in;
end

assign chosen_descramble_word = pipelined_data_in[37:35];

always_ff @(posedge clk)
begin
      if (bypass)
	  begin
	         descrambled_data_out <= pipelined_data_in[34:0];
	  end else
	  begin
			  case (chosen_descramble_word)
			  3'h0:  descrambled_data_out <= {pipelined_data_in[34:0]};
			  3'h1:  descrambled_data_out <= {pipelined_data_in[34:0]^scramble_word1};
			  3'h2:  descrambled_data_out <= {pipelined_data_in[34:0]^scramble_word2};
			  3'h3:  descrambled_data_out <= {pipelined_data_in[34:0]^scramble_word3};
			  3'h4:  descrambled_data_out <= {pipelined_data_in[34:0]^scramble_word4};
			  3'h5:  descrambled_data_out <= {pipelined_data_in[34:0]^scramble_word5};
			  3'h6:  descrambled_data_out <= {pipelined_data_in[34:0]^scramble_word6};
			  3'h7:  descrambled_data_out <= {pipelined_data_in[34:0]^scramble_word7};
			  endcase
	  end
end
	
endmodule

