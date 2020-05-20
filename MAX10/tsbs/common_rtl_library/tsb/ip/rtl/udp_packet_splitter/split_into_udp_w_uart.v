`default_nettype none
`include "interface_defs.v"
`include "carrier_board_interface_defs.v"
`include "uart_regfile_interface_defs.v"
import uart_regfile_types::*;

module split_into_udp_w_uart
#(
parameter DEFAULT_WORDS_BEFORE_NEW_PACKET = 32'h138800,
parameter REGFILE_DEFAULT_BAUD_RATE = 2000000,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter ENABLE_KEEPS = 0,
parameter OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS=1'b0,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"_UDPsplt"},
parameter [23:0] PACKET_LENGTH_IN_WORDS_DEFAULT = 24'h20000,
parameter [0:0] streamer_enable_default = 1'b1,
parameter UART_REGFILE_TYPE = uart_regfile_types::UDP_PACKET_SPLITTER_UART_REGFILE,
parameter DATA_WIDTH=32,
parameter counter_width = 24,
parameter TEST_PACKET_CTRL_DEFAULT = 2,
parameter IMG_WIDTH_DEFAULT = 32'h200,
parameter IMG_HEIGHT_DEFAULT = 32'h400,
 parameter NUM_OF_USER_HEADER_PACKET_WORDS = 4,
	 parameter NUM_OF_FIXED_HEADER_PACKET_WORDS = 7,
	 parameter [31:0] HEADER_SIZE_IN_WORDS = NUM_OF_USER_HEADER_PACKET_WORDS + NUM_OF_FIXED_HEADER_PACKET_WORDS,
	 parameter NUM_BITS_PACKET_WORD_COUNTER = math_func_package::my_clog2(HEADER_SIZE_IN_WORDS)+1
)
(
 
	input  UART_CLKIN,
	input  RESET_FOR_UART_CLKIN,
	
	output uart_tx,
	input  uart_rx,
	
	input udp_clk,	
	
    input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,
	output logic [7:0] NUM_OF_UARTS_HERE,
	
	 input logic [31:0] user_packet_words[NUM_OF_USER_HEADER_PACKET_WORDS],

    avalon_st_32_bit_packet_interface avalon_st_to_udp_streamer,
    avalon_st_32_bit_packet_interface avalon_st_input_packet
);

assign NUM_OF_UARTS_HERE = 1;
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//  Start Streaming Support
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
												 
	
(* keep = ENABLE_KEEPS *) avalon_st_32_bit_packet_interface  avalon_st_to_udp_packet_splitter();
(* keep = ENABLE_KEEPS *) avalon_st_32_bit_packet_interface  avalon_st_packet_test_data      ();
		
	
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic griffin_streamer_to_udp_tx_packet_tx_reset;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic griffin_streamer_to_udp_tx_packet_tx_enable;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [counter_width-1:0] griffin_packet_words_before_new_packet;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [counter_width-1:0] griffin_packet_length_in_words;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [counter_width-1:0] griffin_streamer_to_udp_packet_count ;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [counter_width-1:0] griffin_streamer_to_udp_packet_word_counter;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [counter_width-1:0] griffin_streamer_to_udp_total_word_counter;
 
logic [3:0]  clog2_packets_per_image_width;
logic [13:0] calculated_packet_length_in_words;
 
logic [15:0] image_width_in_pixels;
logic [15:0] image_height_in_pixels;
logic [23:0] splitter_state;
logic [15:0] x1, y1;

logic [NUM_BITS_PACKET_WORD_COUNTER-1:0 ] packet_word_index;
logic [15:0] data_word_counter;
logic [31:0] frameID;
logic extend_short_frames;
logic select_real_data          ;
logic block_unselected_avalon_st; 

split_into_udp_packets_w_test_source
#(
    .DATA_WIDTH(DATA_WIDTH),
    .counter_width(counter_width),
	 .NUM_OF_FIXED_HEADER_PACKET_WORDS(NUM_OF_FIXED_HEADER_PACKET_WORDS),
	 .NUM_OF_USER_HEADER_PACKET_WORDS(NUM_OF_USER_HEADER_PACKET_WORDS)
)
split_into_udp_packets_w_test_source_inst
(
	.clk(udp_clk),
	.enable(griffin_streamer_to_udp_tx_packet_tx_enable),
	.reset_n(!griffin_streamer_to_udp_tx_packet_tx_reset),
   .extend_short_frames,
	.CLOG2_NUM_OF_PACKETS_PER_IMAGE_WIDTH(clog2_packets_per_image_width),
	.image_width_in_pixels ,
    .image_height_in_pixels,
    .select_real_data          ,
    .block_unselected_avalon_st,
	 .state(splitter_state),
    .split_packet_length_in_words(calculated_packet_length_in_words),
	.avalon_st_input_packet(avalon_st_input_packet),
    .avalon_st_to_udp_streamer(avalon_st_to_udp_streamer),

    .avalon_st_to_udp_packet_splitter(avalon_st_to_udp_packet_splitter),
    .avalon_st_packet_test_data      (avalon_st_packet_test_data),
	
    .test_packet_words_before_new_packet (griffin_packet_words_before_new_packet                       ),
    .test_packet_length_in_words         (griffin_packet_length_in_words                               ),
    .test_packet_count                   (griffin_streamer_to_udp_packet_count                         ),
    .test_packet_word_counter            (griffin_streamer_to_udp_packet_word_counter                  ),
    .test_total_word_counter             (griffin_streamer_to_udp_total_word_counter                   ),
   
    .frameID,
    .packet_word_index,
 	 .user_packet_words,
    .data_word_counter     	
 );
	
//===========================================================================
// For GP UART Regfile 0
//===========================================================================						
			
    parameter local_regfile_data_numbytes        =   4;
    parameter local_regfile_data_width           =   8*local_regfile_data_numbytes;
    parameter local_regfile_desc_numbytes        =  16;
    parameter local_regfile_desc_width           =   8*local_regfile_desc_numbytes;
    parameter num_of_local_regfile_control_regs  =  9;
    parameter num_of_local_regfile_status_regs   =  16;
	
    wire [local_regfile_data_width-1:0] local_regfile_control_regs_default_vals[num_of_local_regfile_control_regs-1:0];
    wire [local_regfile_data_width-1:0] local_regfile_control_regs             [num_of_local_regfile_control_regs-1:0];
    wire [local_regfile_data_width-1:0] local_regfile_control_regs_bitwidth    [num_of_local_regfile_control_regs-1:0];
    wire [local_regfile_data_width-1:0] local_regfile_control_status           [num_of_local_regfile_status_regs -1:0];
    wire [local_regfile_desc_width-1:0] local_regfile_control_desc             [num_of_local_regfile_control_regs-1:0];
    wire [local_regfile_desc_width-1:0] local_regfile_status_desc              [num_of_local_regfile_status_regs -1:0];
	
    wire local_regfile_control_rd_error;
	wire local_regfile_control_async_reset = RESET_FOR_UART_CLKIN;
	wire local_regfile_control_wr_error;
	wire local_regfile_control_transaction_error;
	
	
	wire [3:0] local_regfile_main_sm;
	wire [2:0] local_regfile_tx_sm;
	wire [7:0] local_regfile_command_count;
	
		
	assign local_regfile_control_regs_default_vals[0] = 0;
    assign local_regfile_control_desc[0] = "StreamerRst";
    assign griffin_streamer_to_udp_tx_packet_tx_reset = local_regfile_control_regs[0];
    assign local_regfile_control_regs_bitwidth[0] = 1;		
	 
	assign local_regfile_control_regs_default_vals[1] = streamer_enable_default;
    assign local_regfile_control_desc[1] = "StreamerEna";
    assign griffin_streamer_to_udp_tx_packet_tx_enable = local_regfile_control_regs[1];
    assign local_regfile_control_regs_bitwidth[1] = 1;		
	 
	assign local_regfile_control_regs_default_vals[2] = PACKET_LENGTH_IN_WORDS_DEFAULT;
    assign local_regfile_control_desc[2] = "PacketLengthInWords";
    assign griffin_packet_length_in_words  = local_regfile_control_regs[2];
    assign local_regfile_control_regs_bitwidth[2] = 24;		
	 			 	/*
	assign local_regfile_control_regs_default_vals[3] = Packet_Clock_Word_Clock_Divisor_DEFAULT;
    assign local_regfile_control_desc[3] = "PackClkWordDiv";
    assign Griffin_Packet_Clock_Word_Clock_Divisor = local_regfile_control_regs[3];
    assign local_regfile_control_regs_bitwidth[3] = 16;		
	    	 */
	assign local_regfile_control_regs_default_vals[4] = DEFAULT_WORDS_BEFORE_NEW_PACKET;
    assign local_regfile_control_desc[4] = "PackWodBfrNew";
    assign griffin_packet_words_before_new_packet = local_regfile_control_regs[4];
    assign local_regfile_control_regs_bitwidth[4] = 24;		
    		    
    assign local_regfile_control_regs_default_vals[5] = TEST_PACKET_CTRL_DEFAULT;
    assign local_regfile_control_desc[5] = "test_packt_ctrl";
    assign {extend_short_frames,select_real_data, block_unselected_avalon_st}	= local_regfile_control_regs[5];
    assign local_regfile_control_regs_bitwidth[5] = 8;		 	  
	 
	 assign local_regfile_control_regs_default_vals[6] = IMG_WIDTH_DEFAULT;
    assign local_regfile_control_desc[6] = "img_width";
    assign image_width_in_pixels = local_regfile_control_regs[6];
    assign local_regfile_control_regs_bitwidth[6] = 16;	
	 
	 assign local_regfile_control_regs_default_vals[7] = IMG_HEIGHT_DEFAULT;
    assign local_regfile_control_desc[7] = "img_height";
    assign image_height_in_pixels = local_regfile_control_regs[7];
    assign local_regfile_control_regs_bitwidth[7] = 16;	
	 	 	 
	assign local_regfile_control_regs_default_vals[8] = 0;
    assign local_regfile_control_desc[8] = "clog2_pkts2width";
    assign clog2_packets_per_image_width = local_regfile_control_regs[8];
    assign local_regfile_control_regs_bitwidth[8] = 4;		 	 
			 
	assign local_regfile_control_status[0] = splitter_state;		     	       
	assign local_regfile_status_desc[0] = "splitter_state";	
		
    assign local_regfile_control_status[1] = griffin_streamer_to_udp_packet_count;
	assign local_regfile_status_desc[1]    = "packet_count";
	
	assign local_regfile_control_status[2] = griffin_streamer_to_udp_packet_word_counter;
	assign local_regfile_status_desc[2]    = "packet_wrd_count";
			
	assign local_regfile_control_status[3] = griffin_streamer_to_udp_total_word_counter;
	assign local_regfile_status_desc[3]    = "total_wrd_count";
	
	assign local_regfile_control_status[4] = {
	avalon_st_to_udp_streamer.empty, 
	avalon_st_to_udp_streamer.error,
	avalon_st_to_udp_streamer.eop,
	avalon_st_to_udp_streamer.sop, 
	avalon_st_to_udp_streamer.valid,
	avalon_st_to_udp_streamer.ready
	};		 
	
	assign local_regfile_status_desc[4] = "avst2udp_ctrl";
	
		
    assign local_regfile_control_status[5] = avalon_st_to_udp_streamer.data;
	assign local_regfile_status_desc[5]    = "avst_to_udp_data";
		
    assign local_regfile_control_status[6] = calculated_packet_length_in_words;
	assign local_regfile_status_desc[6]    = "calc_pkt_length";
	
	assign local_regfile_control_status[7] = {
		avalon_st_input_packet.empty, 
		avalon_st_input_packet.error,
		avalon_st_input_packet.eop,
		avalon_st_input_packet.sop, 
		avalon_st_input_packet.valid,
		avalon_st_input_packet.ready
	};		 
	
	assign local_regfile_status_desc[7] = "avst_input_out";
	
    assign local_regfile_control_status[8] = avalon_st_input_packet.data;
	assign local_regfile_status_desc[8]    = "avst_input_data";
	
		
	assign local_regfile_control_status[9] = {
		avalon_st_to_udp_packet_splitter.empty, 
		avalon_st_to_udp_packet_splitter.error,
		avalon_st_to_udp_packet_splitter.eop,
		avalon_st_to_udp_packet_splitter.sop, 
		avalon_st_to_udp_packet_splitter.valid,
		avalon_st_to_udp_packet_splitter.ready
	};		 
	
	assign local_regfile_status_desc[9] = "avst2splt_ctrl";
	
    assign local_regfile_control_status[10] = avalon_st_to_udp_packet_splitter.data;
	assign local_regfile_status_desc[10]    = "avst2splt_data";
	
	assign local_regfile_control_status[11] = {
		avalon_st_packet_test_data.empty, 
		avalon_st_packet_test_data.error,
		avalon_st_packet_test_data.eop,
		avalon_st_packet_test_data.sop, 
		avalon_st_packet_test_data.valid,
		avalon_st_packet_test_data.ready
	};		 
	
	assign local_regfile_status_desc[11] = "testpkt_ctrl";
	
    assign local_regfile_control_status[12] = avalon_st_packet_test_data.data;
	assign local_regfile_status_desc[12]    = "testpkt_data";
		
    assign local_regfile_control_status[13] = {x1,y1};
	assign local_regfile_status_desc[13]    = "x1_y1";
	
    assign local_regfile_control_status[14] = {
												packet_word_index,
												data_word_counter
											  };
	assign local_regfile_status_desc[14]    = "data_word_cnt";
	
		
    assign local_regfile_control_status[15] = frameID;
	assign local_regfile_status_desc[15]    = "frameID";
	
		uart_controlled_register_file_ver3
		#( 
		  .NUM_OF_CONTROL_REGS(num_of_local_regfile_control_regs),
		  .NUM_OF_STATUS_REGS(num_of_local_regfile_status_regs),
		  .DATA_WIDTH_IN_BYTES  (local_regfile_data_numbytes),
          .DESC_WIDTH_IN_BYTES  (local_regfile_desc_numbytes),
		  .INIT_ALL_CONTROL_REGS_TO_DEFAULT (1'b0),  
		  .CONTROL_REGS_DEFAULT_VAL         (0),
		  .CLOCK_SPEED_IN_HZ(UART_CLOCK_SPEED_IN_HZ),
          .UART_BAUD_RATE_IN_HZ(REGFILE_DEFAULT_BAUD_RATE)
		)
		local_uart_register_file
		(	
		 .DISPLAY_NAME(uart_name),
		 .CLK(UART_CLKIN),
		 .REG_ACTIVE_HIGH_ASYNC_RESET(local_regfile_control_async_reset),
		 .CONTROL(local_regfile_control_regs),
		 .CONTROL_DESC(local_regfile_control_desc),
		 .CONTROL_BITWIDTH(local_regfile_control_regs_bitwidth),
		 .STATUS(local_regfile_control_status),
		 .STATUS_DESC (local_regfile_status_desc),
		 .CONTROL_INIT_VAL(local_regfile_control_regs_default_vals),
		 .TRANSACTION_ERROR(local_regfile_control_transaction_error),
		 .WR_ERROR(local_regfile_control_wr_error),
		 .RD_ERROR(local_regfile_control_rd_error),
		 .USER_TYPE(UART_REGFILE_TYPE),
		 .NUM_SECONDARY_UARTS(UART_NUM_SECONDARY_UARTS), 
         .ADDRESS_OF_THIS_UART(UART_ADDRESS_OF_THIS_UART),
         .IS_SECONDARY_UART(UART_IS_SECONDARY_UART),
		 
		 //UART
		 .uart_active_high_async_reset(1'b0),
		 .rxd(uart_rx),
		 .txd(uart_tx),
		 
		 //UART DEBUG
		 .main_sm               (local_regfile_main_sm),
		 .tx_sm                 (local_regfile_tx_sm),
		 .command_count         (local_regfile_command_count)
		  
		);
		
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//  End GRIFFIN support
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
endmodule
`default_nettype wire