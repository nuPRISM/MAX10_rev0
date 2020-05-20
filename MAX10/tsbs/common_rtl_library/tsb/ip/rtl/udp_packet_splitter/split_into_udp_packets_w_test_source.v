`default_nettype none
import math_func_package::*;

module split_into_udp_packets_w_test_source  #(
    parameter DATA_WIDTH=32,
	 parameter counter_width = 24,
	 parameter NUM_OF_USER_HEADER_PACKET_WORDS = 4,
	 parameter NUM_OF_FIXED_HEADER_PACKET_WORDS = 7,
	 parameter [31:0] HEADER_SIZE_IN_WORDS = NUM_OF_USER_HEADER_PACKET_WORDS + NUM_OF_FIXED_HEADER_PACKET_WORDS,
	 parameter NUM_BITS_PACKET_WORD_COUNTER = math_func_package::my_clog2(HEADER_SIZE_IN_WORDS)+1
)
(
	input clk,
	input enable,
	input reset_n,

	input   wire [6:0] unique_index,
	input        [counter_width-1:0] test_packet_words_before_new_packet,
	input        [3:0] CLOG2_NUM_OF_PACKETS_PER_IMAGE_WIDTH,
	input        [15:0] image_width_in_pixels,
    input        [15:0] image_height_in_pixels,
	input        [counter_width-1:0] test_packet_length_in_words,
    input logic select_real_data,
    input logic block_unselected_avalon_st,
 	input extend_short_frames,

	
    interface avalon_st_to_udp_streamer,
    interface avalon_st_input_packet,
	interface avalon_st_to_udp_packet_splitter,
    interface avalon_st_packet_test_data,
		
	
	/* debugging outputs */
	output logic [counter_width-1:0] test_packet_count,
	output logic [counter_width-1:0] test_packet_word_counter,
	output logic [counter_width-1:0] test_total_word_counter,
    output logic [7:0] num_of_packets_per_width,
    output logic [7:0] index_of_packet_in_width,
	output logic [counter_width-1:0] packet_count,
    output logic [counter_width-1:0] packet_word_counter,
	output reg [DATA_WIDTH-1:0] delayed_indata,
	input logic [31:0] user_packet_words[NUM_OF_USER_HEADER_PACKET_WORDS],

	output  logic [15:0] packet_data_length_in_pixels,
	output  logic [NUM_BITS_PACKET_WORD_COUNTER-1:0 ] packet_word_index,
	output  logic [23:0] state,
	output  logic [15:0] data_word_counter,
	output  logic [15:0] x1,    
    output  logic [15:0] y1,
	output  logic [31:0] frameID,
	output  logic [13:0] split_packet_length_in_words,
	output logic found_in_sop,
	output logic [DATA_WIDTH-1:0] out_data_raw,
	output logic out_valid_raw,
	output logic out_eop_raw,
    output logic out_sop_raw,  
    output logic allow_in_ready
);
				
choose_between_two_avalon_st_interfaces
#(
  .connect_clocks(0)
)
choose_between_emulated_and_real_data_packet
(
  .avalon_st_interface_in0(avalon_st_packet_test_data),
  .avalon_st_interface_in1(avalon_st_input_packet),
  .avalon_st_interface_out(avalon_st_to_udp_packet_splitter),
  .sel(select_real_data),
  .block_unconnected_interface(block_unselected_avalon_st)
);
					 
				
assign avalon_st_to_udp_packet_splitter.clk = clk;				

generic_avalon_st_packet_emulator_w_ready
#(
.counter_width(counter_width),
.data_width(DATA_WIDTH)
)
generic_avalon_st_packet_emulator_w_ready_inst
(
.clk,                           
.outdata                        (avalon_st_packet_test_data.data ),
.packet_count                   (test_packet_count),
.packet_word_counter            (test_packet_word_counter),
.total_word_counter             (test_total_word_counter),
.packet_words_before_new_packet (test_packet_words_before_new_packet),
.packet_length_in_words         (test_packet_length_in_words),
.ready                          (avalon_st_packet_test_data.ready),
.sop                            (avalon_st_packet_test_data.sop),
.eop                            (avalon_st_packet_test_data.eop),
.valid                          (avalon_st_packet_test_data.valid)
);


assign avalon_st_packet_test_data.clk    = clk;
assign avalon_st_to_udp_streamer.clk    = clk;


split_image_into_udp_packets 
#(
.DATA_WIDTH(DATA_WIDTH),
.NUM_OF_FIXED_HEADER_PACKET_WORDS(NUM_OF_FIXED_HEADER_PACKET_WORDS),
.NUM_OF_USER_HEADER_PACKET_WORDS(NUM_OF_USER_HEADER_PACKET_WORDS),
.counter_width(counter_width)
)
split_image_into_udp_packets_inst
(
	 .clk,
	 .enable,
	 .reset_n,
	 .extend_short_frames, 
	  
	 .out_sop       (avalon_st_to_udp_streamer.sop  ),
	 .out_eop       (avalon_st_to_udp_streamer.eop  ),
	 .out_valid     (avalon_st_to_udp_streamer.valid),
	 .out_data      (avalon_st_to_udp_streamer.data ),
	 .out_ready     (avalon_st_to_udp_streamer.ready),
	
	 .in_sop        (avalon_st_to_udp_packet_splitter.sop  ),
	 .in_eop        (avalon_st_to_udp_packet_splitter.eop  ),
	 .in_valid      (avalon_st_to_udp_packet_splitter.valid),
	 .in_data       (avalon_st_to_udp_packet_splitter.data ),
	 .in_ready      (avalon_st_to_udp_packet_splitter.ready),
	 
	 .delayed_indata,

	 .packet_count,                     
    .packet_word_counter,
	 .num_of_packets_per_width,
     .index_of_packet_in_width,
	 .CLOG2_NUM_OF_PACKETS_PER_IMAGE_WIDTH,
	 .packet_data_length_in_pixels,
	 .image_width_in_pixels,
     .image_height_in_pixels,
	 .packet_word_index                 ,
	 .state                       ,
	 .data_word_counter,
	 .x1,    
     .y1,
	 .frameID,
	 .packet_length_in_words(split_packet_length_in_words),
	 .user_packet_words,

	 .out_data_raw,
	 .out_valid_raw,
	 .out_eop_raw,
     .out_sop_raw,  
     .allow_in_ready  
);

endmodule
`default_nettype wire