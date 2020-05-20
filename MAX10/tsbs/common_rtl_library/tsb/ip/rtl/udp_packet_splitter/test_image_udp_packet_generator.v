`default_nettype none
module test_image_udp_packet_generator  #(
    parameter DATA_WIDTH=32
)(
	input clk,
	input enable,
	input reset_n,
	output sop,
	output eop,
	output valid,
	output reg [DATA_WIDTH-1:0] outdata,
	

	output reg [23:0] packet_count = 0,
    output reg [23:0] packet_word_counter = 0,
	output reg [23:0] total_word_counter = 0,
	input  [23:0] packet_words_before_new_packet,
	input   [3:0] CLOG2_NUM_OF_PACKETS_PER_IMAGE_WIDTH,
	output  [15:0] packet_data_length_in_pixels,
	input  [15:0] image_width_in_pixels,
    input  [15:0] image_height_in_pixels,
	output reg [2:0 ] packet_word_index=3'd0,
	output reg [23:0] state,
	output reg [15:0] data_word_counter=0,
	output reg [15:0] x1=0,    
    output reg [15:0] y1=0,
	output reg [31:0] frameID=0,
	output logic   [13:0] packet_length_in_words,

	output logic [DATA_WIDTH-1:0] outdata_raw,
	output logic valid_raw,
	output logic eop_raw,
    output logic sop_raw  
);

localparam [31:0] HEADER_SIZE_IN_WORDS = 7;
assign packet_data_length_in_pixels = image_width_in_pixels >> CLOG2_NUM_OF_PACKETS_PER_IMAGE_WIDTH;
assign     packet_length_in_words = (packet_data_length_in_pixels >> 1) + HEADER_SIZE_IN_WORDS;
wire       [31:0] NUM_DATA_WORDS_TO_SEND  = packet_length_in_words - HEADER_SIZE_IN_WORDS;
wire       [31:0] NUM_PIXELS_PER_PACKET   = {NUM_DATA_WORDS_TO_SEND,1'b0};
wire       [31:0] size_of_packet_in_bytes = {packet_length_in_words,2'b00};

parameter idle                                       = 24'b0000_0000_0000_0000_0000_0000; 
parameter send_header                                = 24'b0000_0101_1001_0011_0000_0001; 
parameter send_data                                  = 24'b0000_0100_1011_0101_0000_0010; 
parameter wait_for_next_packet                       = 24'b0000_0100_0000_0000_0000_0100; 
parameter wait_for_next_packet_for_new_frame         = 24'b0000_0100_0100_0000_0000_0101; 

wire reset_packet_word_index                 =  !state[8];
wire inc_packet_word_index                   =  state[9];
wire inc_pixel_count                         =  state[10];
wire reset_data_word_counter                 =  !state[12];
wire inc_data_word_counter                   =  state[13];
wire reset_pixel                             =  state[14];
assign valid_raw                               =  state[15];
assign sop_raw                                 =  (state[16] && (enable && (packet_word_counter == 0)));
wire inc_frame_id                            =  state[17];
wire reset_packet_word_counter               =  !state[18];

	
always @(posedge clk)
begin
     if ((!reset_n) || reset_packet_word_counter)
	 begin
	 	  packet_count <= 0;
		  packet_word_counter <= 0;
	 end else
	 begin
			 if (packet_word_counter >= (packet_words_before_new_packet-1))
			 begin 
				  packet_count <= packet_count + 1;
				  packet_word_counter <= 0;
			 end else
			 begin
			      if (enable)
				  begin				  
				       packet_count <= packet_count;
				       packet_word_counter <= packet_word_counter + 1;
				  end
			 end
	 end
end

always @(posedge clk)
begin
     total_word_counter <= total_word_counter + 1;
end			

wire end_of_frame_detected =  (packet_word_counter ==  (packet_length_in_words-1))&& (y1 ==(image_height_in_pixels-1));

reg [63:0] timestamp=64'd0;
reg [15:0] pixel=0;



logic [31:0] prepacket[HEADER_SIZE_IN_WORDS+1];

assign prepacket[0]=packet_length_in_words;
assign prepacket[1]=packet_count;
assign prepacket[2]=frameID;
assign prepacket[3]=timestamp[63:32];
assign prepacket[4]=timestamp[31:0];
assign prepacket[5]={x1[15:0],y1[15:0]};
assign prepacket[6]={(x1+packet_data_length_in_pixels-16'd1),y1[15:0]};
assign prepacket[7]={pixel[15:0],(pixel[15:0] + 16'd1)};

always @(posedge clk)
begin

	if (!reset_n)
	begin
             x1<=0;
             y1<=0;             
	end else
	begin
			if (eop_raw)
			begin
			    x1<= (x1 + packet_data_length_in_pixels >= image_width_in_pixels) ? 0 : x1 + packet_data_length_in_pixels;
				y1<= (x1 + packet_data_length_in_pixels >= image_width_in_pixels) ?  ((y1 >= (image_height_in_pixels-1)) ?  0 : (y1 + 1) ) : y1;
			end				
	end     
end

assign eop_raw  = (packet_word_counter ==  (packet_length_in_words-1));
assign outdata_raw = (packet_word_counter > (packet_length_in_words-1)) ? 32'hEAAEAA : prepacket[packet_word_index];
//data to be sent to the streamer
always @(posedge clk)
begin
     outdata   <= outdata_raw;
	 valid     <= valid_raw ;
	 eop       <= eop_raw   ;
	 sop       <= sop_raw   ;
end

//timestamp generator
always@(posedge clk)
begin
	timestamp[63:0]<=timestamp[63:0]+64'd1;
end
always@(posedge clk)
begin	
	
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
		if (reset_pixel || (!reset_n))
		begin
			pixel<=16'd0;
		end
		else
		begin
			if(inc_pixel_count)
			begin
				pixel<=pixel+2;
			end
		end
end


always@(posedge clk)
begin
	if(reset_data_word_counter)
	begin
		data_word_counter <= 0;
	end
	else
	begin
		if(inc_data_word_counter)
		begin
			data_word_counter <=data_word_counter + 1;
		end
	end
	
end

//Generate FrameID
always@(posedge clk)
begin	
		if (!reset_n)
		begin
		     frameID <= 0;
		end else
		begin
				if (end_of_frame_detected)
				begin
					frameID<= frameID + 1;
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
		 idle                                 : state <= send_header;
		 
		 send_header                          : if (enable)
		                                        begin 
														if (packet_word_index >= (HEADER_SIZE_IN_WORDS-1))
														begin
															  state <= send_data;
														end
												end
												
		 send_data                            : if (end_of_frame_detected)
		                                        begin
												        state <= wait_for_next_packet_for_new_frame;
												end else
												begin
														if  (packet_word_counter  >= (packet_length_in_words-1))
														begin
															  state <= wait_for_next_packet;
														end												
												end		 
		                                        
		 wait_for_next_packet                 :  if (packet_word_counter >= (packet_words_before_new_packet-1))
												 begin
												        state <= send_header;
												 end
												 
		 wait_for_next_packet_for_new_frame   :  if (packet_word_counter >= (packet_words_before_new_packet-1))
												 begin
												        state <= send_header;
												 end
		
		
		endcase
	end
end
endmodule
`default_nettype wire