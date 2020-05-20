module griffin_packet_emulator_ver2
(
input clk,
output reg [31:0] outdata = 0,
output reg [23:0] packet_count = 0,
output reg [23:0] packet_word_counter = 0,
output reg [23:0] total_word_counter = 0,
input      [23:0] packet_words_before_new_packet,
input      [13:0] packet_length_in_words,
output logic sop,
output logic eop,
output logic valid,
input wire [6:0] unique_index
);

always @(posedge clk)
begin
     if (packet_word_counter >= (packet_words_before_new_packet-1))
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
     if (packet_word_counter == 0)
	 begin
	       outdata <= {8'h80,8'h00,2'b00,packet_length_in_words[13:0]}; 
		   valid <= 1;
		   sop <= 1;
		   eop <= 0;

	 end else 
			if (packet_word_counter == (packet_length_in_words-1))
			begin
					outdata <= {8'hE0,packet_count}; 	 
					valid <= 1;
		            sop <= 0;
		            eop <= 1;
	        end else if ((packet_word_counter > 0) && (packet_word_counter  < (packet_length_in_words-1)))
			         begin
						  outdata <={1'b0,unique_index,total_word_counter}; 
						  valid <= 1;
						  sop <= 0;
						  eop <= 0;					 
					 end else
					 begin
					      outdata <=32'hEAAEAA; //not a valid word 
						  valid <= 0;
						  sop <= 0;
						  eop <= 0;		
					 end	 	
end

endmodule

