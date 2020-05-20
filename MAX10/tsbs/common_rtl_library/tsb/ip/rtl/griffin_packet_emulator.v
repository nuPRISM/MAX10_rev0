module griffin_packet_emulator
#(
parameter [6:0] unique_index = 0
)
(
input clk,
output reg [31:0] outdata = 0,
output reg [23:0] packet_count = 0,
output reg [23:0] packet_word_counter = 0,
output reg [23:0] total_word_counter = 0,
input      [23:0] packet_words_before_new_packet
);

always @(posedge clk)
begin
     if (packet_word_counter >= packet_words_before_new_packet)
	 begin 
	      packet_count <= packet_count + 1;
	      packet_word_counter <= 0;
	 end else
	 begin
          packet_word_counter <= packet_word_counter + 1;
	 end
end

always @(posedge clk)
begin
     total_word_counter <= total_word_counter + 1;
end

always @(posedge clk)
begin
     case (packet_word_counter)
	 24'd0    : outdata <= {8'h08,packet_count}; 
	 24'd63   : outdata <= {8'h0E,packet_count}; 	 
	 default : outdata <=  {1'b1,unique_index,total_word_counter}; 
	 endcase
end

endmodule

