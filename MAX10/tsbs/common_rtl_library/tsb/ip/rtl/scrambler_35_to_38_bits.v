
module scrambler_35_to_38_bits
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
input  logic [34:0] data_in,
output logic [37:0] data_out,
input  clk,
input  bypass,
output logic [2:0] chosen_scramble_word
);

logic [34:0] pipelined_data_in;

Serial_Markov_Sequence_Generator
#(
  .LFSR_LENGTH(3),
  .lfsr_init_val(1)
)
Markov_PN3_Serial_gen_inst
(
  .LFSR_Transition_Matrix(9'b101100010),
  .clk(clk),
  .lfsr (chosen_scramble_word),
  .reset(1'b1),
  .serial_output(),
  .reverse_serial_output(1'b0)
);

always_ff @(posedge clk)
begin
      pipelined_data_in <= data_in;
end

always_ff @(posedge clk)
begin

      if (bypass)
	  begin
	         data_out <= {3'h0,pipelined_data_in};
	  end else
	  begin
			  case (chosen_scramble_word)
			  3'h0:  data_out <= {chosen_scramble_word,pipelined_data_in};
			  3'h1:  data_out <= {chosen_scramble_word,pipelined_data_in^scramble_word1};
			  3'h2:  data_out <= {chosen_scramble_word,pipelined_data_in^scramble_word2};
			  3'h3:  data_out <= {chosen_scramble_word,pipelined_data_in^scramble_word3};
			  3'h4:  data_out <= {chosen_scramble_word,pipelined_data_in^scramble_word4};
			  3'h5:  data_out <= {chosen_scramble_word,pipelined_data_in^scramble_word5};
			  3'h6:  data_out <= {chosen_scramble_word,pipelined_data_in^scramble_word6};
			  3'h7:  data_out <= {chosen_scramble_word,pipelined_data_in^scramble_word7};
			  endcase
	  end
end
	
endmodule

