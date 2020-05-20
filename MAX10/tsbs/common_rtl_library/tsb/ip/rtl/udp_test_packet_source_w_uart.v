`default_nettype none
`include "interface_defs.v"
`include "carrier_board_interface_defs.v"
`include "uart_regfile_interface_defs.v"
import uart_regfile_types::*;

module udp_test_packet_source_w_uart
#(
parameter DEFAULT_WORDS_BEFORE_NEW_PACKET = 5000,
parameter REGFILE_DEFAULT_BAUD_RATE = 2000000,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter ENABLE_KEEPS = 0,
parameter OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS=1'b0,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"_UDPTest"},
parameter [15:0] Packet_Clock_Word_Clock_Divisor_DEFAULT = 16'h7AAA,
parameter [23:0] PACKET_LENGTH_IN_WORDS_DEFAULT = 24'h40,
parameter [0:0] streamer_enable_default = 1'b1,
parameter UART_REGFILE_TYPE = uart_regfile_types::UDP_TEST_PACKET_GENERATOR_REGFILE,
parameter [0:0] test_packet_source = 1'b0
)
(
 
	input  UART_CLKIN,
	input  RESET_FOR_UART_CLKIN,
	
	output uart_tx,
	input  uart_rx,
	
	input udp_clk,
	input packet_word_clk_base_clk,
	
    input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,
	output logic [7:0] NUM_OF_UARTS_HERE,
    avalon_st_32_bit_packet_interface avalon_st_to_udp_streamer
);

assign NUM_OF_UARTS_HERE = 1;
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//  Start Streaming Support
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
												 
	
(* keep = 1 *) avalon_st_32_bit_packet_interface  avalon_st_packet_tx_out_to_udp_0();
		
	
	  concat_avalon_st_interfaces
	  #(
	  	  .connect_clocks(0) //assume clocks are correct (100MHz)
	  )
      concat_avalon_st_interfaces_to_udp_streamer_0
      (
        .avalon_st_interface_in  (avalon_st_packet_tx_out_to_udp_0),
        .avalon_st_interface_out (avalon_st_to_udp_streamer)
      );
	

	
(* keep = 1, preserve = 1 *) wire griffin_packet_word_clk;
(* keep = 1, preserve = 1 *) wire griffin_streamer_to_udp_tx_packet_tx_reset;
(* keep = 1, preserve = 1 *) wire griffin_streamer_to_udp_tx_packet_tx_enable;
 (* keep = 1, preserve = 1 *) wire [23:0] griffin_packet_words_before_new_packet;
 (* keep = 1, preserve = 1 *) wire [23:0] griffin_packet_length_in_words;
 (* keep = 1, preserve = 1 *) wire [23:0] griffin_streamer_to_udp_packet_count ;
 (* keep = 1, preserve = 1 *) wire [23:0] griffin_streamer_to_udp_packet_word_counter;
 (* keep = 1, preserve = 1 *) wire [23:0] griffin_streamer_to_udp_total_word_counter;
 
 logic [3:0]  clog2_packets_per_image_width;
 logic [13:0] calculated_packet_length_in_words;
 
 wire [1:0] input_fifo_for_udp_inserter_0_sc_fifo_0_almost_empty_data;
 wire input_fifo_for_udp_inserter_0_sc_fifo_0_almost_full_data; 
 
wire [15:0] Griffin_Packet_Clock_Word_Clock_Divisor;
wire [7:0] UniqueIDAdd;
logic [15:0]  image_width_in_pixels;
logic [15:0] image_height_in_pixels;

Divisor_frecuencia
#(.Bits_counter(16))
Generate_pw_clock
 (	
  .CLOCK(packet_word_clk_base_clk),
  .TIMER_OUT(griffin_packet_word_clk),
  .Comparator(Griffin_Packet_Clock_Word_Clock_Divisor)
 );	 
		
 
griffin_avalon_st_fifoed_packet_source
#(
.test_packet_source(test_packet_source)
)
udp_avalon_st_fifoed_packet_source_inst
(
.image_width_in_pixels,
.image_height_in_pixels,
.clog2_packets_per_image_width,
.calculated_packet_length_in_words,
.unique_index(UniqueIDAdd),
.avalon_st_packet_tx_out        (avalon_st_packet_tx_out_to_udp_0                             ),
.reset                          (griffin_streamer_to_udp_tx_packet_tx_reset                   ),
.enable                         (griffin_streamer_to_udp_tx_packet_tx_enable                  ),
.packet_clk                     (griffin_packet_word_clk                                      ),
.avalon_st_clk                  (udp_clk                                                      ),                                      
.packet_words_before_new_packet (griffin_packet_words_before_new_packet                       ),
.packet_length_in_words         (griffin_packet_length_in_words                               ),
.packet_count                   (griffin_streamer_to_udp_packet_count                         ),
.packet_word_counter            (griffin_streamer_to_udp_packet_word_counter                  ),
.total_word_counter             (griffin_streamer_to_udp_total_word_counter                   ),
.fifo_almost_empty              (input_fifo_for_udp_inserter_0_sc_fifo_0_almost_empty_data    ),
.fifo_almost_full               (input_fifo_for_udp_inserter_0_sc_fifo_0_almost_full_data     ) 
);
	

	
//===========================================================================
// For GP UART Regfile 0
//===========================================================================						
					
	
			
    parameter local_regfile_data_numbytes        =   4;
    parameter local_regfile_data_width           =   8*local_regfile_data_numbytes;
    parameter local_regfile_desc_numbytes        =  16;
    parameter local_regfile_desc_width           =   8*local_regfile_desc_numbytes;
    parameter num_of_local_regfile_control_regs  =  9;
    parameter num_of_local_regfile_status_regs   =  7;
	
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
	 
			 	
	assign local_regfile_control_regs_default_vals[3] = Packet_Clock_Word_Clock_Divisor_DEFAULT;
    assign local_regfile_control_desc[3] = "PackClkWordDiv";
    assign Griffin_Packet_Clock_Word_Clock_Divisor = local_regfile_control_regs[3];
    assign local_regfile_control_regs_bitwidth[3] = 16;		
	    	 
	assign local_regfile_control_regs_default_vals[4] = DEFAULT_WORDS_BEFORE_NEW_PACKET;
    assign local_regfile_control_desc[4] = "PackWodBfrNew";
    assign griffin_packet_words_before_new_packet = local_regfile_control_regs[4];
    assign local_regfile_control_regs_bitwidth[4] = 24;		
    		
    
    assign local_regfile_control_regs_default_vals[5] = 0;
    assign local_regfile_control_desc[5] = "UniqueIDAdd";
    assign UniqueIDAdd = local_regfile_control_regs[5];
    assign local_regfile_control_regs_bitwidth[5] = 8;		 	  
	 
	 assign local_regfile_control_regs_default_vals[6] = 64;
    assign local_regfile_control_desc[6] = "img_width";
    assign image_width_in_pixels = local_regfile_control_regs[6];
    assign local_regfile_control_regs_bitwidth[6] = 16;	
	 
	 assign local_regfile_control_regs_default_vals[7] = 128;
    assign local_regfile_control_desc[7] = "img_height";
    assign image_height_in_pixels = local_regfile_control_regs[7];
    assign local_regfile_control_regs_bitwidth[7] = 16;	
	 
	 	 
	assign local_regfile_control_regs_default_vals[8] = 0;
    assign local_regfile_control_desc[8] = "clog2_pkts2width";
    assign clog2_packets_per_image_width = local_regfile_control_regs[8];
    assign local_regfile_control_regs_bitwidth[8] = 4;	
	 
	 
	 
			 
	assign local_regfile_control_status[0] = {
	   input_fifo_for_udp_inserter_0_sc_fifo_0_almost_empty_data,
	   input_fifo_for_udp_inserter_0_sc_fifo_0_almost_full_data	
	};		     
	       
	assign local_regfile_status_desc[0] = "fifo_stats";
	
		
    assign local_regfile_control_status[1] = griffin_streamer_to_udp_packet_count;
	assign local_regfile_status_desc[1]    = "packet_count";
	
	assign local_regfile_control_status[2] = griffin_streamer_to_udp_packet_word_counter;
	assign local_regfile_status_desc[2]    = "packet_wrd_count";
			
	assign local_regfile_control_status[3] = griffin_streamer_to_udp_total_word_counter;
	assign local_regfile_status_desc[3]    = "total_wrd_count";
	
	assign local_regfile_control_status[4] = {
	test_packet_source,
	avalon_st_to_udp_streamer.empty, 
	avalon_st_to_udp_streamer.error,
	avalon_st_to_udp_streamer.eop,
	avalon_st_to_udp_streamer.sop, 
	avalon_st_to_udp_streamer.valid,
	avalon_st_to_udp_streamer.ready
	};		 
	
	assign local_regfile_status_desc[4] = "avst_ctrl_out";
	
		
    assign local_regfile_control_status[5] = avalon_st_to_udp_streamer.data;
	assign local_regfile_status_desc[5]    = "avst_data";

    assign local_regfile_control_status[6] = calculated_packet_length_in_words;
	assign local_regfile_status_desc[6]    = "calc_pkt_length";
		
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