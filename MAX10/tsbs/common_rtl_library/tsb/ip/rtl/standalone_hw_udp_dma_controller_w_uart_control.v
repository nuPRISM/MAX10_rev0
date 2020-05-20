`ifndef STANDALONE_HW_UDP_DMA_CONTROLLER_W_UART_CONTROL_V
`define STANDALONE_HW_UDP_DMA_CONTROLLER_W_UART_CONTROL_V

`default_nettype none
`include "interface_defs.v"
//`include "carrier_board_interface_defs.v"
`include "keep_defines.v"
import uart_regfile_types::*;

module standalone_hw_udp_dma_controller_w_uart_control
#(
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"_DMAUDP"},
parameter UART_REGFILE_TYPE = uart_regfile_types::STANDALONE_HW_UDP_DMA_UART_REGFILE,
parameter [7:0] NUM_PREAMBLE_WORDS = 14,
parameter [7:0] NUM_USER_PREAMBLE_WORDS = 6,
parameter [7:0] DESCRIPTOR_NUMBITS = 128,
parameter [7:0] DESCRIPTOR_ADDRESS_INCREMENT = DESCRIPTOR_NUMBITS/8,
parameter [7:0] LOG2_DESCRIPTOR_ADDRESS_INCREMENT = $clog2(DESCRIPTOR_ADDRESS_INCREMENT),
parameter ENABLE_KEEPS = 0
//parameter bit [31:0] DEFAULT_USER_PREAMBLE[NUM_USER_PREAMBLE_WORDS-1:0] = {{32'h0},{32'h0},{32'h0},{32'h0},{32'h0},{32'h0}}
)
(
	input  UART_CLK,
	input  RESET_FOR_UART_CLK,
	input  dma_clk,
	output uart_tx,
	input  uart_rx,

	input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,
	
    avalon_mm_simple_bridge_interface msgdma_descriptor_ram_read_avalon_mm_interface_pins,
    avalon_mm_simple_bridge_interface smart_buf_ram_write_avalon_mm_interface_pins,
    avalon_mm_simple_bridge_interface msgdma_avalon_mm_interface_pins,
	avalon_st_streaming_interface     msgdma_response,
    input [63:0]  current_hw_timestamp_count,
	input timestamp_clk,
    external_hw_dma_interface external_hw_dma_interface_pins,
    avalon_st_32_bit_packet_interface avalon_st_packet_total_tx_snoop,
    avalon_st_32_bit_packet_interface avalon_st_packet_net_tx_snoop
);
 parameter ZERO_IN_ASCII = 48;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// DMA descriptor DMA
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

wire [15:0] avalon_st_total_tx_packet_length_in_bytes;
wire [47:0] avalon_st_total_tx_packet_count;
wire [63:0] avalon_st_total_tx_total_byte_count;
wire        avalon_st_total_tx_packet_ended_now;
logic        reset_total_packet_performance_monitor, reset_net_packet_performance_monitor;

assign reset_net_packet_performance_monitor = reset_total_packet_performance_monitor;

determine_avalon_st_packet_length
total_tx_avalon_st_packet_performance_monitor
(
.avalon_st_interface_in(avalon_st_packet_total_tx_snoop),
.reset_n(!reset_total_packet_performance_monitor),
.packet_length_in_bytes(avalon_st_total_tx_packet_length_in_bytes),
.raw_packet_length(),
.packet_count(avalon_st_total_tx_packet_count),
.total_byte_count(avalon_st_total_tx_total_byte_count),
.packet_ended_now(avalon_st_total_tx_packet_ended_now)
);


wire [15:0] avalon_st_net_tx_packet_length_in_bytes;
wire [47:0] avalon_st_net_tx_packet_count;
wire [63:0] avalon_st_net_tx_total_byte_count;
wire        avalon_st_net_tx_packet_ended_now;

determine_avalon_st_packet_length
net_tx_avalon_st_packet_performance_monitor
(
.avalon_st_interface_in(avalon_st_packet_net_tx_snoop),
.reset_n(!reset_net_packet_performance_monitor),
.packet_length_in_bytes(avalon_st_net_tx_packet_length_in_bytes),
.raw_packet_length(),
.packet_count(avalon_st_net_tx_packet_count),
.total_byte_count(avalon_st_net_tx_total_byte_count),
.packet_ended_now(avalon_st_net_tx_packet_ended_now)
);



logic [31:0]  check_edge_event_concordance_negative_discord_thresh_correction;
logic [31:0]  check_edge_event_concordance_positive_discord_thresh_correction;
logic [31:0]  check_edge_event_concordance_counter_a_correction;
logic [31:0]  check_edge_event_concordance_counter_b_correction;
logic [31:0]  check_edge_event_concordance_counter_a_clock_count;
logic [31:0]  check_edge_event_concordance_counter_b_clock_count;


(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         reset_check_edge_event_concordance;      
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         check_edge_event_concordance_clear_event_discord;      
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         check_edge_event_concordance_event_discord;      
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         check_edge_event_concordance_event_enable;      
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0]  check_edge_event_concordance_counter_a;      
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0]  check_edge_event_concordance_counter_b;      
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0]  check_edge_event_concordance_diff_counter;      


     
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0]  hw_triggered_dma_write_control_avalon_anti_master_address;     
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         hw_triggered_dma_write_control_avalon_anti_master_waitrequest_read;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         hw_triggered_dma_write_control_avalon_anti_master_waitrequest_write;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [3:0]  hw_triggered_dma_write_control_avalon_anti_master_byteenable; 
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         hw_triggered_dma_write_control_avalon_anti_master_write;  
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0] hw_triggered_dma_write_control_avalon_anti_master_writedata;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         hw_triggered_dma_write_control_avalon_anti_master_read;  
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0] hw_triggered_dma_write_control_avalon_anti_master_readdata;


(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         dma_async_start;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         actual_dma_async_start;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         dma_finished;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0]  user_logic_read_master_control_read_base       ;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0]  user_logic_read_master_control_read_length     ;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         user_logic_read_master_control_fixed_location  ;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0]  user_logic_the_fixed_address_to_write_to       ;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [15:0]  read_dma_state       ;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [15:0]  transfer_word_state       ;

(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0] bridge_to_udp_st_dma_initiator_address       ;       //            (<connected-to-bridge_to_udp_st_dma_initiator_address>),                            //                        bridge_to_udp_st_dma_initiator.address
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic        bridge_to_udp_st_dma_initiator_waitrequest   ;       //            (<connected-to-bridge_to_udp_st_dma_initiator_waitrequest>),                        //                                                      .waitrequest
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [3:0]  bridge_to_udp_st_dma_initiator_byteenable    ;       //            (<connected-to-bridge_to_udp_st_dma_initiator_byteenable>),                         //                                                      .byteenable
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic        bridge_to_udp_st_dma_initiator_write         ;       //            (<connected-to-bridge_to_udp_st_dma_initiator_write>),                              //                                                      .write
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0] bridge_to_udp_st_dma_initiator_writedata     ;       //            (<connected-to-bridge_to_udp_st_dma_initiator_writedata>)                           //                                                      .writedata
 
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [15:0]  avalon_mm_master_state;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [15:0]  assemble_packet_state;	
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [15:0]  initiator_state;	
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0]  descriptor_space_address;	
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         enable_hw_udp;	
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         enable_msgdma_write;	
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [7:0]   msgdma_wait_cycles;	
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [7:0]   hw_dma_wait_cycles;	
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0]  preamble_words     [NUM_PREAMBLE_WORDS     -1:0];	
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0]  user_preamble_words[NUM_USER_PREAMBLE_WORDS-1:0];	

	        

(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire dma_start_snoop;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire periodic_dma_trigger;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire select_per_dma_trigger;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire actual_dma_trigger;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire periodic_dma_trigger_edge;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire [31:0] periodic_dma_clk_divisor;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire dma_finish_snoop;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [31:0] actual_user_preamble_words[NUM_USER_PREAMBLE_WORDS-1:0];
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [31:0] actual_data_start_address;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [31:0] actual_num_descriptors_to_write;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [31:0] local_first_descriptor_number;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic select_external_trigger;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic select_external_dma_settings;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic synced_dma_async_start;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic retransmit_now;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic local_retransmit_now;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [31:0] smartbuf_retransmit_address;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [31:0] smartbuf_retransmit_length;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [31:0] local_smartbuf_retransmit_address;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [31:0] local_smartbuf_retransmit_length;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [31:0] external_smartbuf_retransmit_address;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [31:0] external_smartbuf_retransmit_length;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [15:0] TDM_state;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [1:0]	TDM_start_status;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic retransmission_in_progress;

assign actual_data_start_address       = select_external_dma_settings ?  
                                              (user_logic_read_master_control_read_base + ({16'b0,external_hw_dma_interface_pins.external_dma_first_descriptor_number[15:0]} <<  LOG2_DESCRIPTOR_ADDRESS_INCREMENT))
                                          :   (user_logic_read_master_control_read_base + ({16'b0,local_first_descriptor_number[15:0]} <<  LOG2_DESCRIPTOR_ADDRESS_INCREMENT));
										  
assign actual_num_descriptors_to_write = select_external_dma_settings ?  external_hw_dma_interface_pins.external_dma_num_descriptors : user_logic_read_master_control_read_length;
assign actual_user_preamble_words      = select_external_dma_settings ?  external_hw_dma_interface_pins.external_user_preamble_words : user_preamble_words;
assign retransmit_now      = select_external_dma_settings ?  external_hw_dma_interface_pins.external_retransmit_now : local_retransmit_now;
assign smartbuf_retransmit_address      = select_external_dma_settings ?  external_hw_dma_interface_pins.external_smartbuf_retransmit_address : local_smartbuf_retransmit_address;
assign smartbuf_retransmit_length     = select_external_dma_settings ?  external_hw_dma_interface_pins.external_smartbuf_retransmit_length : local_smartbuf_retransmit_length;
assign external_hw_dma_interface_pins.dma_clk = dma_clk;	
assign external_hw_dma_interface_pins.hw_retransmission_in_progress = retransmission_in_progress;

handle_mm_to_mm_response_port_and_generate_udp_packets_ver2
handle_mm_to_mm_response_port_and_generate_udp_packets_inst
 (
	.clk(dma_clk),
	.finish(dma_finish_snoop),
	.reset_n(1'b1),
	.timestamp_in(current_hw_timestamp_count),
	.timestamp_clk(timestamp_clk),		
    .src_response_data(msgdma_response.data),  
    .src_response_valid(msgdma_response.valid),
    .src_response_ready(msgdma_response.ready),
	.master_address(msgdma_avalon_mm_interface_pins.address),
	.master_write(msgdma_avalon_mm_interface_pins.write),
	.master_read(),
	.master_byteenable(msgdma_avalon_mm_interface_pins.byteenable),
	.master_readdata(),
	.master_writedata(msgdma_avalon_mm_interface_pins.writedata),
	.master_waitrequest(msgdma_avalon_mm_interface_pins.waitrequest),
	.descriptor_space_address(descriptor_space_address),
	.aux_user_control_word(0),
	.preamble_words(preamble_words),     
	.user_preamble_words(actual_user_preamble_words),
	.enable(enable_hw_udp),
	.enable_msgdma_write(enable_msgdma_write),
	.wait_cycles(msgdma_wait_cycles),
	.retransmit_now,
	.smartbuf_retransmit_address,
	.smartbuf_retransmit_length,
	.TDM_state,
	.TDM_start_status,
	.retransmission_in_progress,
	
	//debug outputs
	.state(initiator_state),
	.avalon_mm_master_state(avalon_mm_master_state),
	.assemble_packet_state(assemble_packet_state)
);	


	
	hw_dma_to_descriptors_via_state_machine_w_separate_masters 
    #(
	 .DATAWIDTH(32),	
	 .ADDRESSWIDTH(32)
    )
    hw_dma_to_descriptors_via_state_machine_inst	
	(
	.clk(dma_clk),
	
	.data_start_address            (actual_data_start_address),
	.descriptor_space_start_address(user_logic_the_fixed_address_to_write_to),
	.num_descriptors_to_write      (actual_num_descriptors_to_write),

	.finish(dma_finished),
	//.start(dma_start_snoop),

	.master_address          (hw_triggered_dma_write_control_avalon_anti_master_address)       ,
	.master_write            (hw_triggered_dma_write_control_avalon_anti_master_write)    ,
	.master_byteenable       (hw_triggered_dma_write_control_avalon_anti_master_byteenable),
	.master_waitrequest_read (hw_triggered_dma_write_control_avalon_anti_master_waitrequest_read),  	
	.master_waitrequest_write(hw_triggered_dma_write_control_avalon_anti_master_waitrequest_write),  	
	.master_writedata        (hw_triggered_dma_write_control_avalon_anti_master_writedata),
	.master_read             (hw_triggered_dma_write_control_avalon_anti_master_read),
	.master_readdata         (hw_triggered_dma_write_control_avalon_anti_master_readdata),

	.reset_n(1'b1),
	.start(1'b0),
	.async_start(actual_dma_async_start),
	.state(read_dma_state),
	.transfer_word_state(transfer_word_state),
	.wait_cycles(hw_dma_wait_cycles),

	.sync_start(synced_dma_async_start)
//unused debug signals
	/*
	.inc_current_word_counter(inc_current_word_counter),
	.is_write(is_write),
	.latch_read_now(latch_read_now),	
	.current_word_counter(current_word_counter),
	.num_words_to_write(num_words_to_write),
	.read_address(read_address),
	.reset_current_word_counter(reset_current_word_counter),	
	.transfer_word_finish(transfer_word_finish),
	.transfer_word_start(transfer_word_start),
	.user_address(user_address),	
	.write_address(write_address),
	.user_byteenable(user_byteenable),
	.user_read_data(user_read_data),
	.user_write_data(user_write_data),
	.actual_reset_current_word_counter_n(actual_reset_current_word_counter_n)
	.avalon_mm_master_finish            (avalon_mm_master_finish            )
	.avalon_mm_master_start             (avalon_mm_master_start             )
	.avalon_mm_master_state             (avalon_mm_master_state             )
	*/
	
);
	

assign msgdma_descriptor_ram_read_avalon_mm_interface_pins.address        = hw_triggered_dma_write_control_avalon_anti_master_address      ;   
assign msgdma_descriptor_ram_read_avalon_mm_interface_pins.byteenable     = hw_triggered_dma_write_control_avalon_anti_master_byteenable   ;
assign hw_triggered_dma_write_control_avalon_anti_master_waitrequest_read = msgdma_descriptor_ram_read_avalon_mm_interface_pins.waitrequest;
assign msgdma_descriptor_ram_read_avalon_mm_interface_pins.write          = 0;	
assign msgdma_descriptor_ram_read_avalon_mm_interface_pins.writedata      = 0;
assign msgdma_descriptor_ram_read_avalon_mm_interface_pins.read           = hw_triggered_dma_write_control_avalon_anti_master_read;            	
assign hw_triggered_dma_write_control_avalon_anti_master_readdata         = msgdma_descriptor_ram_read_avalon_mm_interface_pins.readdata;

	
	
assign smart_buf_ram_write_avalon_mm_interface_pins.address        = hw_triggered_dma_write_control_avalon_anti_master_address      ;   
assign smart_buf_ram_write_avalon_mm_interface_pins.byteenable     = hw_triggered_dma_write_control_avalon_anti_master_byteenable   ;
assign hw_triggered_dma_write_control_avalon_anti_master_waitrequest_write = smart_buf_ram_write_avalon_mm_interface_pins.waitrequest;
assign smart_buf_ram_write_avalon_mm_interface_pins.write          = hw_triggered_dma_write_control_avalon_anti_master_write;	
assign smart_buf_ram_write_avalon_mm_interface_pins.writedata      = hw_triggered_dma_write_control_avalon_anti_master_writedata;
assign smart_buf_ram_write_avalon_mm_interface_pins.read           = 0;            	

			
Divisor_frecuencia
#(
.Bits_counter(32)
)
Generate_periodic_dma_trigger
 (	
  .CLOCK(dma_clk),
  .TIMER_OUT(periodic_dma_trigger),
  .Comparator(periodic_dma_clk_divisor)
 );

/* 
edge_detector periodic_dma_trigger_edge_detector
	(
	 .insignal (periodic_dma_trigger), 
	 .outsignal(periodic_dma_trigger_edge), 
	 .clk      (dma_clk)
	);
*/

assign actual_dma_async_start = select_external_trigger ? external_hw_dma_interface_pins.external_trigger : (select_per_dma_trigger ? periodic_dma_trigger : dma_async_start);
	
	
check_edge_event_concordance
#(
.counter_bits(32)
)
check_edge_event_concordance_inst
(
 .event_a(synced_dma_async_start),
 .event_b(dma_finish_snoop),
 .clk(dma_clk),
 .async_reset(reset_check_edge_event_concordance),
 .counter_a(check_edge_event_concordance_counter_a),
 .counter_b(check_edge_event_concordance_counter_b),
 .counter_a_clock_count(check_edge_event_concordance_counter_a_clock_count),
 .counter_b_clock_count(check_edge_event_concordance_counter_b_clock_count),
 .diff_counter(check_edge_event_concordance_diff_counter),
 .event_discord(check_edge_event_concordance_event_discord),
 .async_clear_event_discord(check_edge_event_concordance_clear_event_discord),
 .enable(check_edge_event_concordance_event_enable),
 .counter_a_increment    (actual_num_descriptors_to_write+check_edge_event_concordance_counter_a_correction),
 .counter_b_increment    (1+check_edge_event_concordance_counter_b_correction),
 .negative_discord_thresh((~actual_num_descriptors_to_write+1) + check_edge_event_concordance_negative_discord_thresh_correction),
 .positive_discord_thresh(actual_num_descriptors_to_write + check_edge_event_concordance_positive_discord_thresh_correction)
);
			
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   Diagnostic UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 32;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = 40;			
            localparam  STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      = 1;
			localparam  STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   = UART_CLOCK_SPEED_IN_HZ;
			localparam  STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                = REGFILE_BAUD_RATE;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    = 0;
			localparam  STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  = 0;
			
			uart_regfile_interface 
			#(                                                                                                     
			.DATA_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       ),
			.DESC_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       ),
			.NUM_OF_CONTROL_REGS                          (STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 ),
			.NUM_OF_STATUS_REGS                           (STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  ),
			.INIT_ALL_CONTROL_REGS_TO_DEFAULT             (STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    ),
			.CONTROL_REGS_DEFAULT_VAL                     (STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            ),
			.USE_AUTO_RESET                               (STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      ),
			.CLOCK_SPEED_IN_HZ                            (STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   ),
			.UART_BAUD_RATE_IN_HZ                         (STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                ),
			.ENABLE_CONTROL_WISHBONE_INTERFACE            (STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   ),
			.ENABLE_STATUS_WISHBONE_INTERFACE             (STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    ),
			.DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  )
			)
			uart_regfile_interface_pins();

	        assign uart_regfile_interface_pins.display_name         = uart_name;
			assign uart_regfile_interface_pins.num_secondary_uarts  = UART_NUM_SECONDARY_UARTS;
			assign uart_regfile_interface_pins.is_secondary_uart    = UART_IS_SECONDARY_UART;
			assign uart_regfile_interface_pins.address_of_this_uart = UART_ADDRESS_OF_THIS_UART;
			assign uart_regfile_interface_pins.rxd = uart_rx;
			assign uart_tx = uart_regfile_interface_pins.txd;
			assign uart_regfile_interface_pins.clk       = UART_CLK;
			assign uart_regfile_interface_pins.reset     = 1'b0;
			assign uart_regfile_interface_pins.user_type = UART_REGFILE_TYPE;	
			
			uart_controlled_register_file_w_interfaces
			#(
			 .DATA_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                      ),
			 .DESC_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                      ),
			 .NUM_OF_CONTROL_REGS                          (STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                ),
			 .NUM_OF_STATUS_REGS                           (STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                 ),
			 .INIT_ALL_CONTROL_REGS_TO_DEFAULT             (STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT   ),
			 .CONTROL_REGS_DEFAULT_VAL                     (STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL           ),
			 .USE_AUTO_RESET                               (STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                     ),
			 .CLOCK_SPEED_IN_HZ                            (STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                  ),
			 .UART_BAUD_RATE_IN_HZ                         (STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ               ),
			 .ENABLE_CONTROL_WISHBONE_INTERFACE            (STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE  ),
			 .ENABLE_STATUS_WISHBONE_INTERFACE             (STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE   ),
 			 .DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS)
			)		
			control_and_status_regfile
			(
			  .uart_regfile_interface_pins(uart_regfile_interface_pins)		
			);
			
			genvar sreg_count;
			genvar creg_count;
			
			generate
					for ( sreg_count=0; sreg_count < STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS; sreg_count++)
					begin : clear_status_descs
						  assign uart_regfile_interface_pins.status_omit_desc[sreg_count] = OMIT_STATUS_REG_DESCRIPTIONS;
					end
					
						
					for (creg_count=0; creg_count < STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS; creg_count++)
					begin : clear_control_descs
						  assign uart_regfile_interface_pins.control_omit_desc[creg_count] = OMIT_CONTROL_REG_DESCRIPTIONS;
					end
			endgenerate
			
    assign uart_regfile_interface_pins.control_regs_default_vals[0]  =  0;
    assign uart_regfile_interface_pins.control_desc[0]               = "dma_read_base";
    assign user_logic_read_master_control_read_base                           = uart_regfile_interface_pins.control[0];
    assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = 32;		
	 
	assign uart_regfile_interface_pins.control_regs_default_vals[1]  =  0;
    assign uart_regfile_interface_pins.control_desc[1]               = "dma_read_length";
    assign user_logic_read_master_control_read_length                     = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = 32;		
	 
	assign uart_regfile_interface_pins.control_regs_default_vals[2]  =  0;
    assign uart_regfile_interface_pins.control_desc[2]               = "dma_wr_fix_addr";
    assign user_logic_the_fixed_address_to_write_to                  = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2]      = 32;		
	 
	assign uart_regfile_interface_pins.control_regs_default_vals[3]  =  0;
    assign uart_regfile_interface_pins.control_desc[3]               = "dma_astart_w_fix";
    assign {enable_msgdma_write,enable_hw_udp,user_logic_read_master_control_fixed_location,dma_async_start} = uart_regfile_interface_pins.control[3];
    assign uart_regfile_interface_pins.control_regs_bitwidth[3]      = 4;		
	 
		
    assign uart_regfile_interface_pins.control_regs_default_vals[4]  =  0;
    assign uart_regfile_interface_pins.control_desc[4]               = "desc_addr_space";
    assign descriptor_space_address                                  = uart_regfile_interface_pins.control[4];
    assign uart_regfile_interface_pins.control_regs_bitwidth[4]      = 32;			 	

    assign uart_regfile_interface_pins.control_regs_default_vals[5] = 0;
    assign uart_regfile_interface_pins.control_desc[5] = "msgdma_wait_cycles";
    assign msgdma_wait_cycles  = uart_regfile_interface_pins.control[5];
    assign uart_regfile_interface_pins.control_regs_bitwidth[5] = 8;		
		
    assign uart_regfile_interface_pins.control_regs_default_vals[6] = 0;
    assign uart_regfile_interface_pins.control_desc[6] = "mmdmaWaitCycles";
    assign hw_dma_wait_cycles  = uart_regfile_interface_pins.control[6];
    assign uart_regfile_interface_pins.control_regs_bitwidth[6] = 8;		
	
	assign uart_regfile_interface_pins.control_regs_default_vals[7] = 10000;
    assign uart_regfile_interface_pins.control_desc[7] = "per_dma_cnt";
    assign periodic_dma_clk_divisor = uart_regfile_interface_pins.control[7];
    assign uart_regfile_interface_pins.control_regs_bitwidth[7] = 32;			
	
	assign uart_regfile_interface_pins.control_regs_default_vals[8] = 0;
    assign uart_regfile_interface_pins.control_desc[8] = "per_dma_ctrl";
    assign {reset_total_packet_performance_monitor, check_edge_event_concordance_clear_event_discord,reset_check_edge_event_concordance,check_edge_event_concordance_event_enable,select_per_dma_trigger} = uart_regfile_interface_pins.control[8];
    assign uart_regfile_interface_pins.control_regs_bitwidth[8] = 16;			
		
	assign uart_regfile_interface_pins.control_regs_default_vals[9] = 0;
    assign uart_regfile_interface_pins.control_desc[9] = "cnt_a_corr";
    assign check_edge_event_concordance_counter_a_correction = uart_regfile_interface_pins.control[9];
    assign uart_regfile_interface_pins.control_regs_bitwidth[9] = 32;			
		
	assign uart_regfile_interface_pins.control_regs_default_vals[10] = 0;
    assign uart_regfile_interface_pins.control_desc[10] = "cnt_b_corr";
    assign check_edge_event_concordance_counter_b_correction = uart_regfile_interface_pins.control[10];
    assign uart_regfile_interface_pins.control_regs_bitwidth[10] = 32;				
		
	assign uart_regfile_interface_pins.control_regs_default_vals[11] = 0;
    assign uart_regfile_interface_pins.control_desc[11] = "thr_neg_corr";
    assign check_edge_event_concordance_negative_discord_thresh_correction = uart_regfile_interface_pins.control[11];
    assign uart_regfile_interface_pins.control_regs_bitwidth[11] = 32;			
		
	assign uart_regfile_interface_pins.control_regs_default_vals[12] = 0;
    assign uart_regfile_interface_pins.control_desc[12] = "thr_pos_corr";
    assign check_edge_event_concordance_positive_discord_thresh_correction = uart_regfile_interface_pins.control[12];
    assign uart_regfile_interface_pins.control_regs_bitwidth[12] = 32;	
	
	assign uart_regfile_interface_pins.control_regs_default_vals[13] = 3;
    assign uart_regfile_interface_pins.control_desc[13] = "sel_extern_dma";
    assign {select_external_dma_settings,select_external_trigger} = uart_regfile_interface_pins.control[13];
    assign uart_regfile_interface_pins.control_regs_bitwidth[13] = 4;	
	
	assign uart_regfile_interface_pins.control_regs_default_vals[14] = 0;
    assign uart_regfile_interface_pins.control_desc[14] = "first_description_number";
    assign local_first_descriptor_number= uart_regfile_interface_pins.control[14];
    assign uart_regfile_interface_pins.control_regs_bitwidth[14] = 16;	
	
	assign uart_regfile_interface_pins.control_regs_default_vals[15] = 0;
    assign uart_regfile_interface_pins.control_desc[15] = "retrans_addr";
    assign local_smartbuf_retransmit_address = uart_regfile_interface_pins.control[15];
    assign uart_regfile_interface_pins.control_regs_bitwidth[15] = 32;	
	
	assign uart_regfile_interface_pins.control_regs_default_vals[16] = 0;
    assign uart_regfile_interface_pins.control_desc[16] = "retrans_length";
    assign local_smartbuf_retransmit_length = uart_regfile_interface_pins.control[16];
    assign uart_regfile_interface_pins.control_regs_bitwidth[16] = 32;	
	
	assign uart_regfile_interface_pins.control_regs_default_vals[17] = 0;
    assign uart_regfile_interface_pins.control_desc[17] = "retransmit_now";
    assign local_retransmit_now = uart_regfile_interface_pins.control[17];
    assign uart_regfile_interface_pins.control_regs_bitwidth[17] = 1;	
	
	genvar i;
	localparam user_preamble_ctrl_start = 18;
	
    generate
               for (i = 0; i < NUM_USER_PREAMBLE_WORDS; i++)
			   begin : make_user_preamble
			   		    wire [7:0] char1 = ((i/10)+ZERO_IN_ASCII);
			            wire [7:0] char2 = ((i % 10)+ZERO_IN_ASCII);
						assign uart_regfile_interface_pins.control_regs_default_vals[user_preamble_ctrl_start+i]  =  0; //DEFAULT_USER_PREAMBLE[i];
						assign uart_regfile_interface_pins.control_desc[user_preamble_ctrl_start+i]               = {"user_preamble",char1,char2};
						assign user_preamble_words[i]                                    = uart_regfile_interface_pins.control[user_preamble_ctrl_start+i];
						assign uart_regfile_interface_pins.control_regs_bitwidth[user_preamble_ctrl_start+i]      = 32;		
	           end
	 endgenerate
	 
	assign uart_regfile_interface_pins.status[0] = 32'h12345678;
	assign uart_regfile_interface_pins.status_desc[0]    ="StatusAlive";	
	/*
	assign uart_regfile_interface_pins.status[1] = msgdma_avalon_mm_0_fifo_data_debug[31:0];
	assign uart_regfile_interface_pins.status_desc[1]="fifo_dbg_rd_addr";

	assign uart_regfile_interface_pins.status[2] = msgdma_avalon_mm_0_fifo_data_debug[63:32];
	assign uart_regfile_interface_pins.status_desc[2]="fifo_dbg_wr_addr";

	assign uart_regfile_interface_pins.status[3] = msgdma_avalon_mm_0_fifo_data_debug[95:64];
	assign uart_regfile_interface_pins.status_desc[3]="fifo_debug_len";									
	*/
	
	assign uart_regfile_interface_pins.status[1] = check_edge_event_concordance_counter_a_clock_count;
	assign uart_regfile_interface_pins.status_desc[1] = "trigger_count";
	
	assign uart_regfile_interface_pins.status[2] = check_edge_event_concordance_counter_b_clock_count;
	assign uart_regfile_interface_pins.status_desc[2] = "desc_processed";	
		
	assign uart_regfile_interface_pins.status[4] ={dma_finished,actual_dma_async_start,check_edge_event_concordance_event_discord};
	assign uart_regfile_interface_pins.status_desc[4]="dma_fin_ev_disc";									
				
	assign uart_regfile_interface_pins.status[5] =read_dma_state;
	assign uart_regfile_interface_pins.status_desc[5]="read_dma_state";				
	
	assign uart_regfile_interface_pins.status[6] =avalon_mm_master_state;
	assign uart_regfile_interface_pins.status_desc[6]="avmm_state";		
	
	assign uart_regfile_interface_pins.status[7] =assemble_packet_state;
	assign uart_regfile_interface_pins.status_desc[7]="assembler_state";				
	
	assign uart_regfile_interface_pins.status[8] =initiator_state;
	assign uart_regfile_interface_pins.status_desc[8]="initiator_state";									
						

	assign uart_regfile_interface_pins.status[9] =transfer_word_state;
	assign uart_regfile_interface_pins.status_desc[9]="xfer_word_state";		
	
	assign uart_regfile_interface_pins.status[10] =check_edge_event_concordance_counter_a;
	assign uart_regfile_interface_pins.status_desc[10]="counter_a";		
	
	assign uart_regfile_interface_pins.status[11] =check_edge_event_concordance_counter_b;
	assign uart_regfile_interface_pins.status_desc[11]="counter_b";		
	
	assign uart_regfile_interface_pins.status[12] =check_edge_event_concordance_diff_counter;
	assign uart_regfile_interface_pins.status_desc[12]="diff_counter";

	
	assign uart_regfile_interface_pins.status[13] = avalon_st_total_tx_packet_length_in_bytes;
	assign uart_regfile_interface_pins.status_desc[13]    = "TotTxPktLenBytes"; 
	

	assign uart_regfile_interface_pins.status[14] = avalon_st_net_tx_packet_length_in_bytes;
	assign uart_regfile_interface_pins.status_desc[14]    = "NetTxPktLenBytes"; 
	
	assign uart_regfile_interface_pins.status[15] = avalon_st_total_tx_packet_count[47:32];
	assign uart_regfile_interface_pins.status_desc[15]    = "tot_pkt_cnt_47_32"; 
	
	assign uart_regfile_interface_pins.status[16] = avalon_st_total_tx_packet_count[31:0];
	assign uart_regfile_interface_pins.status_desc[16]    = "tot_pkt_cnt_31_0"; 
	
	assign uart_regfile_interface_pins.status[17] = avalon_st_net_tx_packet_count[47:32];
	assign uart_regfile_interface_pins.status_desc[17]    = "net_pkt_cnt_47_32"; 
	
	assign uart_regfile_interface_pins.status[18] = avalon_st_net_tx_packet_count[31:0];
	assign uart_regfile_interface_pins.status_desc[18]    = "net_pkt_cnt_31_0"; 
			
	assign uart_regfile_interface_pins.status[19] = avalon_st_total_tx_total_byte_count[63:32];
	assign uart_regfile_interface_pins.status_desc[19]    = "TotByteCnt_63_32"; 
	
	assign uart_regfile_interface_pins.status[20] = avalon_st_total_tx_total_byte_count[31:0];
	assign uart_regfile_interface_pins.status_desc[20]    = "TotByteCnt_31_0"; 
	
	assign uart_regfile_interface_pins.status[21] = avalon_st_net_tx_total_byte_count[63:32];
	assign uart_regfile_interface_pins.status_desc[21]    = "NetByteCnt_63_32"; 
	
	assign uart_regfile_interface_pins.status[22] = avalon_st_net_tx_total_byte_count[31:0];
	assign uart_regfile_interface_pins.status_desc[22]    = "NetByteCnt_31_0"; 
	
	assign uart_regfile_interface_pins.status[23] = TDM_state;
	assign uart_regfile_interface_pins.status_desc[23]    = "TDM_state"; 
				
	assign uart_regfile_interface_pins.status[24] = TDM_start_status;
	assign uart_regfile_interface_pins.status_desc[24]    = "TDM_start_status"; 
	
	assign uart_regfile_interface_pins.status[25] = retransmission_in_progress;
	assign uart_regfile_interface_pins.status_desc[25]    = "retrans_in_prog"; 
			
			
			
	localparam preamble_status_start = 26;
    genvar j;
	generate
            for (j = 0; j < NUM_PREAMBLE_WORDS; j++)
	      begin : assign_preamble_status
	  		    wire [7:0] char1 = ((j/10)+ZERO_IN_ASCII);
	              wire [7:0] char2 = ((j % 10)+ZERO_IN_ASCII);					
	              assign uart_regfile_interface_pins.status[preamble_status_start+j] =preamble_words[j];
	              assign uart_regfile_interface_pins.status_desc[preamble_status_start+j]={"preamble_",char1,char2};																
	        end
	endgenerate
	
endmodule
`default_nettype wire
`endif
