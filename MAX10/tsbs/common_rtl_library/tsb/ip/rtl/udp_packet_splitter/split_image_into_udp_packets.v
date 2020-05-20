`default_nettype none
import math_func_package::*;

module split_image_into_udp_packets  #(
    parameter DATA_WIDTH=32,
    parameter counter_width = 24,
	 parameter NUM_OF_USER_HEADER_PACKET_WORDS = 4,
	 parameter NUM_OF_FIXED_HEADER_PACKET_WORDS = 7,
	 parameter [31:0] HEADER_SIZE_IN_WORDS = NUM_OF_USER_HEADER_PACKET_WORDS + NUM_OF_FIXED_HEADER_PACKET_WORDS,
	 parameter NUM_BITS_PACKET_WORD_COUNTER = math_func_package::my_clog2(HEADER_SIZE_IN_WORDS)+1

)(
	input clk,
	input enable,
	input reset_n,
	
	input extend_short_frames,
	output out_sop,
	output out_eop,
	output out_valid,
	output reg [DATA_WIDTH-1:0] out_data,
	input  out_ready,
	
	input in_sop,
	input in_eop,
	input in_valid,
	input reg [DATA_WIDTH-1:0] in_data,
	output reg [DATA_WIDTH-1:0] delayed_indata,
	output reg delayed_in_eop,
	output reg delayed_in_valid,
	output reg in_ready,
	

	output logic got_in_eop,
	output reg [counter_width-1:0] packet_count = 0,
    output reg [counter_width-1:0] packet_word_counter = 0,
	input   [3:0] CLOG2_NUM_OF_PACKETS_PER_IMAGE_WIDTH,
	output  [15:0] packet_data_length_in_pixels,
	input  [15:0] image_width_in_pixels,
    input  [15:0] image_height_in_pixels,
    output logic  [7:0] num_of_packets_per_width,
    output reg [7:0] index_of_packet_in_width = 0,
	output reg [NUM_BITS_PACKET_WORD_COUNTER-1:0 ] packet_word_index=0,
	output reg [23:0] state,
	output reg [15:0] data_word_counter=0,
	output reg [15:0] x1=0,    
    output reg [15:0] y1=0,
	output reg [31:0] frameID=0,
	input logic [31:0] user_packet_words[NUM_OF_USER_HEADER_PACKET_WORDS],
	output reg found_in_sop,
	output logic   [13:0] packet_length_in_words,

	output logic [DATA_WIDTH-1:0] out_data_raw,
	output logic out_valid_raw,
	output logic out_eop_raw,
    output logic out_sop_raw,  
    output logic allow_in_ready,  
    output logic inc_index_of_packet_in_width  
);

assign packet_data_length_in_pixels = image_width_in_pixels >> CLOG2_NUM_OF_PACKETS_PER_IMAGE_WIDTH;
assign num_of_packets_per_width = (1 << CLOG2_NUM_OF_PACKETS_PER_IMAGE_WIDTH) ;
assign     packet_length_in_words = (packet_data_length_in_pixels >> 1) + HEADER_SIZE_IN_WORDS;
wire       [31:0] NUM_DATA_WORDS_TO_SEND  = packet_length_in_words - HEADER_SIZE_IN_WORDS;
wire       [31:0] NUM_PIXELS_PER_PACKET   = {NUM_DATA_WORDS_TO_SEND,1'b0};
wire       [31:0] size_of_packet_in_bytes = {packet_length_in_words,2'b00};

parameter idle                                       = 24'b0000_0000_0000_0000_0000_0000; 
parameter wait_for_sop                               = 24'b0001_0000_0000_0000_0000_0001; 
parameter send_header                                = 24'b0001_0111_1001_0011_0000_0010; 
parameter send_data                                  = 24'b0001_0100_1011_0101_0000_0011; 
parameter wait_for_next_packet                       = 24'b0001_1110_0000_0000_0000_0100; 
parameter wait_for_next_packet_for_new_frame         = 24'b0000_0110_0100_0000_0000_0101; 

wire reset_packet_word_index                 =  !state[8] ;
wire inc_packet_word_index                   =  (state[9] && out_ready && out_valid && in_valid);
wire inc_pixel_count                         =  state[10] && out_ready && out_valid && in_valid; 
wire reset_data_word_counter                 =  !state[12];
wire inc_data_word_counter                   =  state[13] ;
wire reset_pixel                             =  state[14] ;
assign out_valid_raw                         =  state[15] && (((state ==  send_data) && in_valid) || (state == send_header)) ;
assign out_sop_raw                           =  (state[16] && (enable && (packet_word_index == 0)));
assign allow_in_ready                        =  !state[17];
wire reset_packet_word_counter               =  !state[18];
assign inc_index_of_packet_in_width          =  state[19];
wire reset_found_sop                       =  !state[20];

assign in_ready =      (((state ==  send_data) && out_ready && ((extend_short_frames && (!in_eop)) || !extend_short_frames))
                    || (((state ==  wait_for_sop) && (!found_in_sop && !(in_sop && in_valid))) && out_ready));
					//|| ((state ==  send_header) && (packet_word_index == (HEADER_SIZE_IN_WORDS-1)) && out_ready && out_valid)) && (!(packet_word_counter ==  (packet_length_in_words-1)));
	
assign got_in_eop = in_ready && in_valid && in_eop;
	
always @(posedge clk)
begin
     if ((!reset_n) || reset_packet_word_counter)
	 begin
	 	  packet_count <= 0;
		  packet_word_counter <= 0;
	 end else
	 begin	     
             if (out_ready && (((state == send_data) && in_valid) || (state == send_header))) 
             begin			 
					 if (packet_word_counter >= (packet_length_in_words-1))
					 begin 
						  packet_count <= packet_count + 1;
						  packet_word_counter <= 0;
					 end else
					 begin
							  packet_count <= packet_count;
							 packet_word_counter <= packet_word_counter + 1;						 							
					 end
			end
	 end
end

wire end_of_frame_detected =  ((index_of_packet_in_width == (num_of_packets_per_width-1)) && (packet_word_counter ==  (packet_length_in_words-1)) && (y1 >= (image_height_in_pixels-1)));

logic edge_detect_of_end_of_frame_detected;

non_sync_edge_detector 
detect_edge_of_end_of_frame_detected (
.insignal (  end_of_frame_detected                ), 
.outsignal(  edge_detect_of_end_of_frame_detected ), 
.clk      (  clk                                  )
);

reg [63:0] timestamp=64'd0;
reg [63:0] captured_timestamp=64'd0;
reg [15:0] pixel=0;

logic capture_timestamp_now;

logic [31:0] prepacket[HEADER_SIZE_IN_WORDS+1];

assign prepacket[0]=packet_length_in_words;
assign prepacket[1]=packet_count;
assign prepacket[2]=frameID;
assign prepacket[3]=captured_timestamp[63:32];
assign prepacket[4]=captured_timestamp[31:0];
assign prepacket[5]={x1[15:0],y1[15:0]};
assign prepacket[6]={(x1+packet_data_length_in_pixels-16'd1),y1[15:0]};

genvar current_prepacket_word;
generate
        if (NUM_OF_USER_HEADER_PACKET_WORDS != 0)
		  begin
              for (current_prepacket_word = NUM_OF_FIXED_HEADER_PACKET_WORDS; current_prepacket_word < HEADER_SIZE_IN_WORDS; current_prepacket_word++)
				  begin	: assign_user_packet_words		  
				          assign prepacket[current_prepacket_word]=user_packet_words[current_prepacket_word-NUM_OF_FIXED_HEADER_PACKET_WORDS];
				  end
		  end
endgenerate

assign prepacket[HEADER_SIZE_IN_WORDS]={in_data[31:0]};


always @(posedge clk)
begin
     delayed_indata   <= in_data;
     delayed_in_eop   <= in_eop;
     delayed_in_valid <= in_valid;
end

always @(posedge clk)
begin

	if (!reset_n)
	begin
             x1<=0;
             y1<=0;             
	end else
	begin
			if (out_eop_raw && out_ready && out_valid_raw)
			begin
				x1<= (x1 + packet_data_length_in_pixels >= image_width_in_pixels) ? 0 : x1 + packet_data_length_in_pixels;
				y1<= (x1 + packet_data_length_in_pixels >= image_width_in_pixels) ?  ((y1 >= (image_height_in_pixels-1)) ?  0 : (y1 + 1) ) : y1;
			end				
	end     
end

assign out_eop_raw  = ((packet_word_counter ==  (packet_length_in_words-1)) && (state == send_data)) || ((state == send_data) && (!extend_short_frames) && got_in_eop);
assign out_data_raw = (packet_word_counter > (packet_length_in_words-1)) ? 32'hEAAEAA : prepacket[packet_word_index];

//data to be sent to the streamer
always_comb 
begin
     if (out_ready)
	 begin
			 out_valid     = out_valid_raw;
			 out_eop       = out_eop_raw  ;
			 out_sop       = out_sop_raw   ;
			 out_data      = out_data_raw;
	 end else 
	 begin
	         out_valid     = 0;
			 out_eop       = 0  ;
			 out_sop       = 0   ;
			 out_data      = 0;
	 end
end



//timestamp generator
always@(posedge clk)
begin
	timestamp<=timestamp+1;
end

assign capture_timestamp_now = (packet_word_index == 0);

//timestamp generator
always@(posedge clk)
begin
      if (capture_timestamp_now)
	  begin
	        captured_timestamp <= timestamp;
	  end
end




always@(posedge clk)
begin	
	if (reset_packet_word_index)
	begin
		packet_word_index<=0;
	end
	else
	begin
		if (inc_packet_word_index)
		begin
			packet_word_index<=packet_word_index+1'b1;
		end
	end
end

always@(posedge clk)
begin	
		if (reset_found_sop || (!reset_n))
		begin
			pixel<=16'd0;
			found_in_sop <= 0;
		end
		else
		begin
			if (((inc_pixel_count) && in_sop && in_valid) || found_in_sop)
			begin
				pixel<=pixel+2;
			    found_in_sop <= 1;
			end
		end
end


always@(posedge clk)
begin
	if (reset_data_word_counter)
	begin
		data_word_counter <= 0;
	end
	else
	begin
		if (inc_data_word_counter && in_valid) 
		begin
			data_word_counter <= data_word_counter + 1;
		end
	end	
end

always@(posedge clk)
begin	
		if (!reset_n)
		begin
		     frameID <= 0;
		end else
		begin
				if (edge_detect_of_end_of_frame_detected)
				begin
					frameID <= frameID + 1;
				end
		end
end
	
always@(posedge clk)
begin	
		if ((!reset_n) || reset_packet_word_counter)
		begin
		     index_of_packet_in_width <= 0;
		end else
		begin
				if (inc_index_of_packet_in_width)
				begin
				    if (index_of_packet_in_width == (num_of_packets_per_width-1))
					begin
					     index_of_packet_in_width <= 0;
					end else
					begin
					     index_of_packet_in_width <= index_of_packet_in_width + 1;
					end
				end
		end
end

always@(posedge clk)
begin
	if(!reset_n)
	begin
		state<=idle;
	end
	else
	begin
		 case(state)
		 idle                                 :  state <= wait_for_sop;
												
		 wait_for_sop                          : if (enable && in_sop && in_valid)
		                                        begin
		                                                state <= send_header;
												end
		 
		 send_header                          : if ((packet_word_index >= (HEADER_SIZE_IN_WORDS-1)) && out_ready)
												begin
													  state <= send_data;
												end
										
		send_data                            :  if (out_ready)
												begin 
														if (end_of_frame_detected || ((!extend_short_frames) && got_in_eop))
														begin
																state <= wait_for_next_packet_for_new_frame;
														end else
														begin
																if  (out_eop_raw)
																begin
																	  state <= wait_for_next_packet;
																end												
														end		 
												end
		                                        
		 wait_for_next_packet                 :  state <= send_header;
												 
		 wait_for_next_packet_for_new_frame   :  state <= wait_for_sop;
												 
		
		
		endcase
	end
end
endmodule
`default_nettype wire