module generic_avalon_st_packet_emulator_w_ready
#(
parameter data_width = 32,
parameter counter_width = 24
)
(
input clk,
output reg [data_width-1:0   ] outdata = 0,
output reg [counter_width-1:0] packet_count = 0,
output reg [counter_width-1:0] packet_word_counter = 0,
output reg [counter_width-1:0] total_word_counter = 0,
input      [counter_width-1:0] packet_words_before_new_packet,
input      [counter_width-1:0] packet_length_in_words,
input  ready,
output logic sop,
output logic eop,
output logic valid
);

always_ff @(posedge clk)
begin
     if (ready)
	 begin
			 if (packet_word_counter >= (packet_words_before_new_packet-1))
			 begin 
				  packet_count <= packet_count + 1;
				  packet_word_counter <= 0;
			 end else
			 begin
			      packet_count <= packet_count;
				  packet_word_counter <= packet_word_counter + 1;
			 end
			 total_word_counter <= total_word_counter + 1;
	 end
end

always_comb
begin
     if (packet_word_counter == 0)
	 begin
	       outdata = {packet_word_counter}; 
		   valid = 1;
		   sop = 1;
		   eop = 0;
	 end else 
			if (packet_word_counter == (packet_length_in_words-1))
			begin
				    outdata = {packet_word_counter}; 	 
					valid = 1;
		            sop = 0;
		            eop = 1;
	        end else if ((packet_word_counter > 0) && (packet_word_counter  < (packet_length_in_words-1)))
			         begin
						  outdata ={packet_word_counter}; 
						  valid = 1;
						  sop = 0;
						  eop = 0;					 
					 end else
					 begin
					      outdata =32'hEAAEAA; //not a valid word 
						  valid = 0;
						  sop = 0;
						  eop = 0;		
					 end	 	
end

endmodule

